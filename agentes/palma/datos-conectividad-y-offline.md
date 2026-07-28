# Datos, conectividad y offline en el cliente

En mobile la red no es un servicio garantizado: es un recurso intermitente, caro, lento y a veces ausente. El dispositivo entra a un ascensor, a un metro, a una zona rural, a un avión, o el usuario apaga los datos para ahorrar batería o dinero. Una app mobile de élite trata la conectividad como un lujo que aparece y desaparece, no como una precondición. Este documento cubre la persistencia LOCAL, la arquitectura **offline-first**, la sincronización, la resolución de conflictos, el caché, las migraciones de esquema local y los clientes de API resilientes. Todo esto es el **plano de datos del CLIENTE**: la parte del sistema de datos que vive dentro del teléfono.

## 1. Persistencia local: el arsenal en el dispositivo

Antes de sincronizar cualquier cosa, la app necesita un lugar propio donde guardar estado. Hay tres familias de almacenamiento local, cada una con un propósito distinto.

| Familia | Ejemplos (p. ej.) | Para qué sirve | Cuándo NO usarla |
|---|---|---|---|
| **BD embebida relacional/objetos** | SQLite, Room (Android), Core Data (Apple), Realm, SQLDelight, GRDB, ObjectBox | Datos estructurados, relaciones, queries, listas grandes, offline-first | Blobs binarios grandes; pares clave-valor triviales |
| **Key-value / preferencias** | DataStore, SharedPreferences, UserDefaults, MMKV | Flags, settings, tokens de sesión pequeños, feature toggles | Colecciones grandes o con relaciones |
| **Archivos / blob store** | File system, `Documents`/`Caches`, almacenamiento por scopes | Imágenes, PDFs, audio, video, adjuntos, exports | Datos que necesitan query o consistencia transaccional |

**Criterios de elección** — no hay ganador universal, se decide por forma del dato y patrón de acceso:

- **¿Necesitas queries, filtros, joins, orden?** → BD embebida. Si además quieres tipado fuerte y SQL verificado en compilación, valora un generador de queries tipadas (p. ej. SQLDelight, Room con KSP).
- **¿Es un puñado de valores simples de configuración?** → key-value. Prefiere las variantes **asíncronas y transaccionales** (p. ej. DataStore) sobre las síncronas legacy que bloquean el hilo principal.
- **¿Es un binario grande?** → archivo en disco, y guarda en la BD solo la **ruta/URI + metadatos** (nunca el blob completo dentro de la fila, salvo casos muy acotados).
- **¿Es secreto (token, clave, PII)?** → NO va en preferencias en claro ni en una BD sin cifrar. Va en el keystore/keychain o en almacenamiento cifrado. La decisión de qué es "sensible" y cómo se cifra la gobierna destroyer: ver [seguridad-mobile.md](seguridad-mobile.md).

Regla transversal: **toda escritura local pesada fuera del hilo principal (UI)**. Bloquear la UI thread con I/O de disco produce jank y ANRs.

## 2. Offline-first: la red es un lujo, no una precondición

**Offline-first** significa que la app funciona primero contra su propio almacenamiento local y trata la red como un mecanismo de *sincronización en segundo plano*, no como la fuente inmediata de cada pantalla. El usuario abre la app en el metro sin señal y **igual ve sus datos, crea registros, edita y navega**; los cambios se propagan al servidor cuando la red vuelve.

El patrón central es el **repositorio con single-source-of-truth (SSOT) LOCAL**:

```
        UI  ◄────── observa (Flow / Combine / stream) ─────┐
         │                                                  │
      acción                                                │
         ▼                                                  │
   ┌───────────────────────── Repositorio ─────────────────────────┐
   │  1. Escribe/lee SIEMPRE contra la BD local (SSOT)              │
   │  2. Encola el cambio en el outbox                              │
   │  3. Un sincronizador reconcilia BD local ↔ backend en 2.º plano│
   └───────────────────────────────────────────────────────────────┘
                              ▲   │
                         red intermitente
                              │   ▼
                           Backend (contrato = motor)
```

Principios:

- **La UI nunca habla con la red directamente.** Observa la BD local (un stream reactivo). Cuando el sync actualiza la BD, la UI se refresca sola.
- **Escrituras optimistas**: la acción del usuario impacta la BD local de inmediato y se refleja en pantalla; la confirmación del servidor llega después. Si el servidor rechaza, se revierte o se marca en conflicto.
- **La red es un detalle de implementación del repositorio**, no de la vista.

Este enfoque también mejora rendimiento percibido incluso *con* buena red: las pantallas pintan desde disco al instante mientras el sync corre por detrás (patrón *stale-while-revalidate*, §5).

## 3. Sincronización: mover cambios entre cliente y servidor

Sincronizar es el arte de reconciliar dos copias de la verdad. Patrones de modelo de autoridad:

| Patrón | Idea | Bueno para | Costo |
|---|---|---|---|
| **Server-authoritative** | El servidor manda; el cliente propone | La mayoría de apps de negocio | Conflictos se resuelven descartando/reintentando el cliente |
| **Last-write-wins (LWW)** | Gana la escritura con timestamp mayor | Datos simples, poco concurrentes | Puede perder ediciones silenciosamente |
| **CRDT** (Conflict-free Replicated Data Types) | Estructuras que *convergen* sin coordinación | Colaboración, notas, contadores, listas | Complejidad de modelo y tamaño de payload |
| **Operational Transform (OT)** | Transforma operaciones concurrentes | Edición colaborativa en tiempo real (texto) | Muy complejo de implementar bien |
| **Sync engines** (p. ej. motores de replicación/sync gestionados) | Delegar el protocolo de sync a una capa dedicada | Equipos que no quieren construir el protocolo | Acoplamiento a la solución |

**Cola de outbox (transactional outbox del lado cliente)** — el corazón de la escritura offline:

1. La operación del usuario se guarda como **intención** en una tabla `outbox` (tipo, payload, `local_id`, estado, intentos).
2. Un worker drena el outbox cuando hay red, envía al backend y marca cada ítem como confirmado/fallido.
3. Al confirmar, se reconcilian los IDs locales temporales con los IDs reales del servidor.

**Idempotencia — no negociable**: cada operación enviada lleva una **clave de idempotencia** (p. ej. un UUID generado en el cliente). Si el envío se reintenta tras un timeout ambiguo (¿llegó o no?), el servidor reconoce la clave y **no duplica**. Sin esto, la red intermitente crea registros fantasma. El *contrato* de idempotencia (header, comportamiento del endpoint) lo define **motor**; palma lo consume y garantiza que el cliente reintente con la misma clave.

Estrategias de alcance del sync: **full sync** (traer todo, solo para datasets chicos) vs **delta/incremental sync** (traer solo lo cambiado desde un `cursor`/`updated_since`/`syncToken`). Para móvil casi siempre delta, por batería y datos.

## 4. Resolución de conflictos

Un conflicto ocurre cuando el mismo dato cambió en el cliente y en el servidor (u otro dispositivo) desde la última sincronización. Estrategias:

| Estrategia | Cómo decide | Riesgo |
|---|---|---|
| **Last-write-wins** | Timestamp/versión mayor gana | Pérdida silenciosa de datos |
| **Server-wins** | El servidor siempre prevalece | Se descartan ediciones locales |
| **Client-wins** | El cliente prevalece | Se pisan cambios de otros |
| **Merge por campos** | Fusiona campos no colisionados | Requiere granularidad de campo |
| **Manual / user-mediated** | Se le pregunta al usuario | Requiere UX de conflicto |

**Versionado y detección**: cada entidad lleva una versión (número monotónico, `etag`, `rev`, o **vector clock**/version vector para detectar concurrencia real entre múltiples dispositivos). El vector clock distingue "esto es más nuevo" de "esto cambió en paralelo" — clave para no aplicar LWW ciegamente.

**UX de conflicto**: cuando la resolución no puede ser automática, el usuario debe entender qué pasó y elegir ("mantener mío", "usar del servidor", "combinar"). El **diseño de esa experiencia de conflicto se coordina con uxuifull**: mensajes claros, diffs comprensibles, cero jerga técnica. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para el handoff con diseño.

Recomendación práctica: minimizar conflictos por diseño (operaciones de grano fino, campos independientes, CRDTs donde aplique) es mejor que resolverlos elegantemente.

## 5. Caché: políticas e invalidación

El caché acelera y habilita el offline, pero **el caché mal invalidado es peor que no tener caché** (muestra datos viejos como si fueran verdad).

Políticas comunes:

- **TTL (time-to-live)**: el dato es válido N segundos/minutos; después se considera stale y se re-pide.
- **Stale-while-revalidate**: muestra el dato cacheado *inmediatamente* (buena UX) y dispara un refresh en segundo plano que actualiza cuando llega. Ideal para offline-first.
- **Cache-then-network**: pinta local, luego reconcilia con red.
- **Network-first con fallback a caché**: intenta red; si falla o hace timeout, sirve local.

**Invalidación** — las dos estrategias reales:

1. **Por tiempo** (TTL): simple, pero puede servir datos obsoletos dentro de la ventana.
2. **Por evento/versión**: el servidor notifica (push, `etag`, webhook→push) o el delta-sync marca qué invalidar. Más preciso, más complejo.

Distingue caché **efímero** (imágenes, respuestas HTTP, en `Caches/` — el SO puede purgarlo) de datos **de aplicación** (en la BD SSOT, no se purga solo). No confundas caché con persistencia offline: el caché es descartable; el SSOT local, no.

## 6. Migraciones de esquema local y evolución de datos

El servidor se despliega una vez; **las apps mobile viven fragmentadas en decenas de versiones** en dispositivos reales, algunas de hace años y que quizá nunca actualicen. Cada esquema de BD local que embarcaste sigue vivo en algún teléfono.

Reglas:

- **Numera y versiona el esquema local** y define **migraciones incrementales** v1→v2→v3. Un usuario que salta de v1 a v5 debe poder ejecutar la cadena completa o una migración directa probada.
- **Nunca borres y recrees la BD en producción** para "arreglar" un cambio de esquema: destruyes datos offline no sincronizados del usuario. Migra, no destruyas.
- **Prueba cada migración con datos reales** (incluyendo el outbox pendiente). Una migración que pierde el outbox pierde trabajo del usuario que nunca llegó al servidor.
- **Compatibilidad hacia atrás del CONTRATO**: un cliente viejo debe seguir hablando con el backend nuevo. La evolución del contrato (campos opcionales, deprecación, versionado de API) es de **motor**; palma garantiza que el cliente tolere campos desconocidos y ausentes (**parseo tolerante**: ignora lo que no conoce, no crashea).
- Herramientas de migración: usa el mecanismo del motor de persistencia elegido (p. ej. migraciones de Room, versiones de Core Data model, migraciones de Realm/SQLDelight) — neutralidad total.

## 7. Clientes de API

El cliente de red traduce el contrato del backend a objetos que la app usa. Estilos:

| Estilo | Ejemplos (p. ej.) | Fuerte en | Consideración mobile |
|---|---|---|---|
| **REST/JSON** | Cliente HTTP + serializador | Simplicidad, caché HTTP, ubicuidad | Over/under-fetching; muchas llamadas |
| **GraphQL** | Apollo, urql, cliente generado | Pedir exactamente lo necesario, 1 request | Normalización de caché, tamaño de librería |
| **gRPC / protobuf** | Stubs generados | Payloads binarios compactos, streaming, tipado | Menos amigable con proxies/CDN; setup |

**Generación de tipos**: prefiere **generar los modelos/cliente desde el contrato** (OpenAPI, esquema GraphQL, `.proto`) en vez de escribir DTOs a mano. Elimina drift entre cliente y servidor y da tipado en compilación. El contrato es autoridad de **motor**; palma genera y consume el cliente tipado.

**Manejo de errores** — un cliente serio distingue:

- Errores de **transporte** (sin red, timeout, DNS) → reintentables, van a la lógica de backoff.
- Errores de **protocolo/HTTP** (4xx vs 5xx): 5xx suele ser reintentable; 4xx (400, 401, 403, 422) es del cliente y **no** se reintenta a ciegas (401 → refresh de token; 409 → conflicto, §4).
- Errores de **deserialización** → parseo tolerante, telemetría, no crash.

Nunca dejes que un error de red burbujee a la UI como excepción cruda: tradúcelo a estado (`Loading`/`Content`/`Error`/`Offline`) que la vista sepa pintar.

## 8. Red intermitente: sobrevivir a la señal que va y viene

Técnicas obligatorias para operar sobre una red que no es de fiar:

- **Detección de conectividad**: observa el estado de red del SO (disponible / perdida / metered / VPN). Úsalo para **disparar el drenado del outbox** al recuperar red, no para bloquear la UI. Ojo: "hay interfaz de red" ≠ "hay internet" (portales cautivos); confirma con una petición real cuando importe.
- **Reintentos con backoff exponencial + jitter**: no reintentes en bucle apretado (drena batería y crea *thundering herd* al volver la señal). Aumenta el intervalo exponencialmente y añade aleatoriedad. Define un **tope de reintentos** y un estado terminal de fallo.
- **Timeouts explícitos** por request (conexión y lectura). Sin timeout, una request colgada retiene recursos indefinidamente.
- **Paginación**: nunca traigas listas ilimitadas en móvil. Cursor-based o keyset paging, carga incremental al hacer scroll, y persiste las páginas en el SSOT local.
- **Subida/descarga resumible**: archivos grandes sobre red móvil se cortan. Soporta reanudación por rangos/chunks (p. ej. uploads por partes, `Range` requests) para no reenviar todo desde cero.
- **Trabajo diferido y consciente de restricciones**: agenda el sync pesado con el planificador de background del SO respetando batería, red *no-metered* y carga (p. ej. WorkManager en Android, BackgroundTasks en Apple). El SO puede matar tu proceso; el trabajo debe ser reanudable y idempotente (§3).

## 9. Frontera explícita de responsabilidad

Los datos cruzan varias fronteras de ownership. Palma respeta las siguientes con precisión:

| Ámbito | Dueño | Qué implica |
|---|---|---|
| **Persistencia LOCAL del cliente** (BD embebida, key-value, archivos, caché, outbox) | **palma** | La construye e implementa |
| **Sync del CLIENTE** (repositorio SSOT, colas, reintentos, resolución de conflictos en el dispositivo) | **palma** | Lógica dentro de la app |
| **CONTRATO de API** (endpoints, esquemas, versionado, idempotencia server-side, códigos de error) y el backend | **motor** | palma lo consume; no lo define |
| **PLANO DE DATOS del backend** (motor de BD del servidor, esquema del servidor, HA/DR, backup **de datos**, replicación) | **andulfo** | palma no toca la BD del servidor |
| **Datos sensibles en reposo** (qué es sensible, cifrado, keystore/keychain) | **destroyer decide** | palma implementa según su directriz → [seguridad-mobile.md](seguridad-mobile.md) |

En una frase: **palma es dueña del plano de datos DENTRO del teléfono; motor es dueño del contrato; andulfo es dueño del plano de datos del servidor.** Los tres se encuentran en el sync. Detalles de handoff en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## 10. Greenfield, en construcción y brownfield

- **Greenfield**: diseña offline-first desde el día uno. Retrofitear offline sobre una app "online-only" es una de las reescrituras más caras del ciclo de vida — el SSOT local hay que meterlo en la base, no encima. Define esquema local, estrategia de sync y política de conflictos antes de la primera pantalla que persiste.
- **En construcción**: si el repositorio ya existe pero aún habla directo a la red, inserta la BD local como SSOT y mueve la red detrás del sincronizador **antes** de que más pantallas dependan del patrón online. Cada pantalla nueva que nace acoplada a la red aumenta el costo de la migración.
- **Brownfield**: audita primero qué datos ya viven en el dispositivo, en qué formato y sin cifrar; mapea el esquema local existente y sus versiones desplegadas antes de tocar nada; introduce migraciones incrementales y el outbox de forma no destructiva. Nunca una migración que pueda perder datos offline o el outbox pendiente sin una ruta de respaldo probada.

## 11. Modelo tiered de decisión

- **T1 — palma (cliente)**: persistencia local, arquitectura offline-first, repositorio SSOT, outbox, reintentos/backoff, caché, migraciones de esquema local, cliente de API tipado y resolución de conflictos en el dispositivo. Se decide y construye aquí.
- **T2 — escala al dueño del ámbito**:
  - Cambios o dudas sobre el **CONTRATO de API** (nuevos endpoints, semántica de idempotencia server-side, versionado, códigos de error, delta/cursor) → **motor**.
  - Cambios o dudas sobre el **PLANO DE DATOS del servidor** (esquema del backend, HA/DR, backup y retención de datos, replicación) → **andulfo**.
  - Clasificación de sensibilidad y estrategia de cifrado en reposo → **destroyer** (ver [seguridad-mobile.md](seguridad-mobile.md)).
