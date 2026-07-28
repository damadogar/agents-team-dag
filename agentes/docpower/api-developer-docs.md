# api-developer-docs.md — Documentación de APIs y developer experience

> Documentación para developers en profundidad. La API docs es de las de mayor
> exigencia: el lector es técnico, impaciente y penaliza cualquier imprecisión.
>
> Frontera: el **comportamiento real** de la API y su **spec** son del SME
> (motor/farola/eneida); docpower asegura que la documentación sea **exacta,
> completa, navegable y con buena DX**, y que se **genere/valide contra la fuente**
> para no desviarse (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)).

---

## 1. Las tres capas de la documentación de API (Diátaxis aplicado)

1. **Quickstart** — de cero a la primera llamada exitosa en minutos (una sola ruta).
2. **Tutoriales / how-to** — casos de uso reales end-to-end (autenticarse, crear un
   recurso, manejar webhooks).
3. **Referencia** — exhaustiva y consistente: cada endpoint, parámetro, error.

La referencia sin quickstart frustra; el quickstart sin referencia deja a medias.
Se necesitan las tres, separadas por intención.

---

## 2. Especificaciones como fuente de verdad

- **OpenAPI (REST)** — describe endpoints, esquemas, auth, ejemplos. La referencia
  se **autogenera** desde aquí (Redoc, Scalar, Stoplight, Swagger UI) para que doc y
  API no diverjan.
- **AsyncAPI (event-driven / mensajería)** — para APIs de eventos, webhooks, colas,
  streaming.
- **Postman collections** — ejemplos ejecutables y exploración.
- Regla: **documentación de referencia generada desde la spec**, no escrita a mano
  en paralelo (el drift es inevitable si se mantienen dos fuentes). docpower valida
  la spec en CI (schema validation — ver [docs-as-code.md](docs-as-code.md)).

---

## 3. Autenticación y autorización

- Explica **cada método** soportado (API key, OAuth 2.0, JWT, mTLS…) con su flujo.
- Diagrama de flujo de auth (Mermaid/secuencia) para OAuth y similares.
- **Cómo obtener y rotar credenciales**; scopes/permisos y qué habilita cada uno.
- **Nunca** incluyas secretos reales en ejemplos; usa placeholders evidentes.
- Errores de auth (401 vs 403) y cómo diagnosticarlos.

---

## 4. Referencia de endpoint (plantilla consistente)

Cada endpoint documentado con la **misma estructura** (predecibilidad = usabilidad):

- Método + ruta + descripción de una línea.
- **Parámetros** (path, query, body): nombre, tipo, requerido/opcional, default,
  restricciones.
- **Petición de ejemplo** (curl + al menos un SDK) con valores realistas.
- **Respuesta de ejemplo** (éxito) con esquema y códigos posibles.
- **Errores**: tabla de códigos, significado y cómo resolverlos.
- **Notas** de rate limit, idempotencia, paginación, versionado.

---

## 5. Manejo de errores (crítico y a menudo descuidado)

- **Catálogo de errores** con código, mensaje, causa y **acción para resolver**.
- Distingue errores de cliente (4xx) de servidor (5xx) y qué debe hacer cada uno.
- Formato de error consistente (documenta el shape del cuerpo de error).
- Enlaza el troubleshooting ([tipos-de-documento.md](tipos-de-documento.md) §13).

---

## 6. Temas transversales de API

- **Rate limits**: límites, ventanas, headers de cuota, comportamiento al excederlos,
  backoff recomendado.
- **Paginación**: estrategia (cursor/offset), parámetros, cómo iterar.
- **Idempotencia**: claves de idempotencia y garantías.
- **Versionado**: esquema (URL/header), política de deprecación, breaking changes.
- **Webhooks**: eventos, payload, verificación de firma, reintentos, orden de entrega.
- **SDKs**: instalación, inicialización, mapeo a los endpoints, ejemplos idiomáticos
  por lenguaje.

---

## 7. Code samples (ejemplos de código)

- **Multi-lenguaje** cuando la audiencia lo requiere (curl + los SDKs oficiales).
- **Copiables y correctos**: probados en CI (docs-as-tests — [docs-as-code.md](docs-as-code.md)),
  no escritos a mano y nunca verificados.
- Valores realistas pero **seguros**; muestra petición **y** respuesta.
- Consistentes en estilo con el usage guide del proyecto.

---

## 8. Developer experience (DX) de la documentación

- **Time-to-first-call** como métrica norte: cuánto tarda un dev nuevo en su primera
  llamada exitosa. Optimiza el quickstart para minimizarlo.
- Buscador potente, navegación por recurso, "try it" cuando sea posible.
- **Consistencia** entre nombres de la API, SDK y docs (si difieren, es un bug que
  docpower señala al SME).
- Changelog de API claro y guías de migración para breaking changes
  ([tipos-de-documento.md](tipos-de-documento.md) §12).

---

## 9. Documentación de plataformas y CLIs

- **CLI**: referencia de comandos autogenerada desde `--help`/spec cuando sea
  posible; ejemplos por tarea; exit codes.
- **Integraciones/deployment**: setup de entorno, variables de configuración,
  requisitos, matrices de compatibilidad.
- **Config reference**: cada opción con tipo, default, efecto y ejemplo.

---

## 9 bis. Más allá de REST: GraphQL, gRPC y otros paradigmas

REST/OpenAPI no es el único mundo. Cada paradigma tiene su fuente de verdad y su forma
de documentar; docpower elige la correcta según la API real, sin forzar el molde REST.

- **GraphQL**: la fuente de verdad es el **schema (SDL)** + introspección. Documenta
  **tipos, queries, mutations, subscriptions**, y sobre todo **cómo componer una
  query** (el reto del novato no es el endpoint —hay uno— sino saber qué campos pedir).
  Autogenera la referencia de tipos desde el schema; añade ejemplos de query/variables/
  respuesta y notas de **paginación (connections/cursores)**, errores parciales y
  *deprecation* a nivel de campo (`@deprecated`).
- **gRPC / Protocol Buffers**: la fuente de verdad es el **`.proto`**. Documenta
  **servicios y métodos** (unary, server/client/bidi streaming), mensajes, enums, y la
  semántica de **status codes gRPC**, deadlines, metadata y streaming. Autogenera desde
  el `.proto`; complementa con quickstart por lenguaje (los stubs son generados).
- **Otros**: **WebSockets/SSE** (streaming en tiempo real), **webhooks** (ya en §6, con
  AsyncAPI), **SOAP/WSDL** (legacy empresarial que aún existe). Reconócelos y aplica el
  mismo principio: **referencia generada desde la fuente + quickstart + errores + DX**.

> Regla transversal: la "referencia de endpoint" REST (§4) es **una** plantilla; para
> GraphQL modela el **schema**, para gRPC el **servicio/método**. No fuerces
> method+path donde el paradigma no lo usa.

---

## 10. Antipatrones de API docs (prohibidos)

- Referencia escrita a mano en paralelo a la spec (garantiza drift).
- Ejemplos que nunca se ejecutan (mienten con el tiempo).
- Documentar solo el camino feliz; omitir errores, límites y edge cases.
- Secretos reales en ejemplos.
- Quickstart con diez decisiones que el novato no puede tomar.
- Inconsistencia de nombres entre API, SDK y docs.

> Estructura y plantillas: [plantillas.md](plantillas.md). Validación en CI:
> [docs-as-code.md](docs-as-code.md). Optimización para consumo por IA/agentes:
> [ia-y-documentacion.md](ia-y-documentacion.md).
