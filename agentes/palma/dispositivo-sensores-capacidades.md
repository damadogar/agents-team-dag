# Dispositivo, sensores y telemetría de aplicación

El dispositivo móvil es un sensor rico y una plataforma de captura permanente. Dominar sus **capacidades de hardware** (cámara, ubicación, biometría, sensores inerciales, radios de proximidad) y su **telemetría de aplicación** (crashes, ANR, analítica, RUM de cliente, logging remoto, session replay) es identidad central de palma. La primera regla que atraviesa todo este documento: **se pide lo mínimo, se explica el porqué, se degrada con gracia y se emite solo lo consentido**. La política de privacidad y consentimiento no la fija palma — la fijan [gobernanza-y-etica.md](gobernanza-y-etica.md) y el dueño de seguridad; palma integra e instrumenta según esa decisión.

---

## BLOQUE A · Capacidades de dispositivo

### 1. Cámara y multimedia

Casos: captura de foto/video, escaneo (QR, códigos de barras, documentos con detección de bordes), OCR en dispositivo, selección desde galería.

| Función | Consideración de ingeniería | Frontera |
|---|---|---|
| Captura foto/video | Resolución vs. peso; compresión antes de subir; orientación EXIF; HDR/formatos modernos (HEIC/HEVC) | Presupuesto de subida y batería lo respeta [performance-mobile.md](performance-mobile.md) |
| Escaneo QR / barras | API de escaneo nativa o en dispositivo; enfoque continuo; feedback háptico al detectar | — |
| Escaneo de documentos | Detección de bordes, corrección de perspectiva, binarización; OCR local para no exfiltrar PII | PII y retención → [seguridad-mobile.md](seguridad-mobile.md) |
| Galería | Selectores acotados (photo picker moderno) que NO exigen permiso total de biblioteca | Permiso mínimo (§4) |

**Principios**: preferir selectores del sistema que devuelven solo lo elegido (sin permiso de galería completa); procesar y comprimir en dispositivo; nunca subir el original crudo por defecto; borrar temporales tras el uso.

### 2. Ubicación

| Nivel | Uso legítimo | Coste |
|---|---|---|
| Coarse (aproximada) | Contenido regional, moneda, sucursal cercana | Bajo |
| Fine (precisa) | Navegación, entrega, mapa en vivo | Medio |
| Background (segundo plano) | Tracking de ruta, entrega, recordatorios por lugar | **Alto** — batería + privacidad |
| Geofencing | Entrar/salir de zona sin polling continuo | Bajo (lo gestiona el SO) |

**Presupuesto de batería**: usar el nivel de precisión más bajo que resuelva el caso; preferir geofencing y APIs de "cambio significativo de ubicación" sobre polling de alta frecuencia; agrupar (batch) actualizaciones; detener el stream cuando la pantalla no lo necesita.

**Privacidad**: la ubicación en segundo plano es un permiso de alta sensibilidad — se solicita por separado, con justificación fuerte, y muchas plataformas la revisan en la tienda. Estados posibles: *permitir siempre*, *solo mientras se usa*, *solo esta vez*, *aproximada*. La app debe funcionar de forma degradada en cada uno. La retención de trazas de ubicación la decide [gobernanza-y-etica.md](gobernanza-y-etica.md).

### 3. Biometría

Face ID / Touch ID (iOS), BiometricPrompt / clases de fuerza (Android). Regla de palma:

- La biometría es **conveniencia de desbloqueo local**, no un factor de identidad transmitible por sí solo. Autentica *localmente* que el poseedor del dispositivo está presente.
- Para operaciones sensibles, la biometría desbloquea un **secreto respaldado por hardware** (Keychain/Keystore, Secure Enclave/TEE); nunca es "el sistema confía porque la cara coincidió" del lado servidor.
- **La política de qué exige biometría, cuándo y como parte de qué esquema de factores la fija el dueño de seguridad** — ver [seguridad-mobile.md](seguridad-mobile.md). palma implementa el prompt, el fallback (PIN/passcode del dispositivo) y el manejo de "biometría cambiada/invalidada".
- Nunca usar biometría como *único* control para transacciones de alto valor sin el segundo factor que dicte la política.

### 4. Permisos: contexto y gracia

Modelo mental correcto: **el permiso es una conversación, no un peaje al arrancar.**

1. **Purpose strings claros** (iOS `NSUsage*Description`, Android runtime + rationale): decir por qué, en lenguaje del usuario.
2. **Pedir en contexto**: solicitar la cámara cuando el usuario toca "escanear", no en el splash. Un *pre-prompt* propio ("para escanear tu documento necesitaremos la cámara") antes del diálogo del sistema reduce negativas irreversibles.
3. **Gracia**: aceptar el "no". Si se niega, ofrecer camino alterno (subir desde galería, ingresar manualmente) y un enlace a Ajustes si el usuario cambia de opinión.
4. **Degradación explícita**: cada permiso denegado debe tener una ruta de producto definida. Una app que se rompe sin un permiso opcional es un defecto.

| Permiso | Si se niega, degradar a |
|---|---|
| Cámara | Subida desde galería / entrada manual |
| Ubicación | Entrada manual de dirección / selección de ciudad |
| Notificaciones | In-app inbox / recordatorios pasivos |
| Contactos | Invitación por enlace / entrada manual |

### 5. Sensores

| Sensor | Señal | Casos |
|---|---|---|
| Acelerómetro | Aceleración lineal | Detección de movimiento, shake-to-action, conteo de pasos |
| Giroscopio | Velocidad angular | AR, estabilización, gestos de orientación |
| Magnetómetro | Campo magnético / brújula | Navegación, orientación de mapa |
| Barómetro | Presión atmosférica | Altitud, pisos en interiores |
| Fusión (sensor fusion) | Orientación combinada | Actitud del dispositivo, AR robusto |

**Ingeniería**: elegir la tasa de muestreo mínima suficiente (las tasas altas drenan batería y saturan el bus); desuscribirse en background; considerar fusión del SO en vez de integrar señales crudas. Datos de sensores continuos pueden ser inferencia sensible (patrones de actividad) — su uso entra en el ámbito de [gobernanza-y-etica.md](gobernanza-y-etica.md).

### 6. Conectividad de dispositivo

| Tecnología | Alcance/energía | Casos de uso |
|---|---|---|
| BLE (Bluetooth Low Energy) | Corto, bajo consumo | Wearables, IoT, beacons, medición, periféricos |
| Bluetooth clásico | Corto, mayor consumo/ancho de banda | Audio, transferencia sostenida |
| NFC | Muy corto, pasivo | Tap-to-pay, tags, emparejamiento rápido, control de acceso |
| Wi-Fi Aware / P2P | Medio, sin infraestructura | Descubrimiento entre pares, transferencia local |

**Ingeniería**: BLE exige gestión cuidadosa de estados (escaneo, conexión, GATT, reconexión, background modes limitados por el SO); NFC suele requerir foreground y entitlements; el emparejamiento y los permisos de proximidad se han endurecido en versiones recientes de los SO. La seguridad del canal (cifrado del enlace, pairing, spoofing de beacons) se coordina con [seguridad-mobile.md](seguridad-mobile.md).

**Continuidad multi-dispositivo y casting.** La app puede extenderse a otros dispositivos: **casting sender/receiver** (p. ej. AirPlay / Chromecast) para enviar media a pantallas; **Handoff / continuidad** para retomar una tarea entre dispositivos del mismo usuario; **Matter / Thread** para interoperar con el ecosistema doméstico IoT. palma construye el rol de cliente (descubrimiento, emparejamiento, sesión, sincronización de estado); la decisión de alcance es de `tompo`/`eneida`.

---

## BLOQUE B · Telemetría completa de la aplicación

**Capacidad de primera clase de palma.** Una app sin telemetría es una app operada a ciegas: no se sabe si crashea, si arranca lento o si el flujo de compra convierte. palma **instrumenta la señal dentro del cliente** con el mismo rigor de craft que el código de producto. Ahora bien, hay cuatro fronteras que no se pisan (detalladas al final del bloque): **quién define las metas de performance, quién es dueño de la observabilidad de plataforma, quién diseña el warehouse y quién decide la privacidad de estos datos** no es palma.

### 7. Crash reporting

- Captura de crashes nativos (señales, excepciones no atrapadas) y de excepciones a nivel de lenguaje/framework.
- **Símbolos**: subir **dSYM (iOS)** y **mapping de ProGuard/R8 (Android)** en cada build para desimbolizar y desofuscar stacktraces; sin ellos los reportes son ruido. Automatizar la subida en el pipeline de release.
- Métrica norte: **crash-free rate** (sesiones y usuarios). Agrupar por versión, OS, dispositivo, y correlacionar con releases.
- Adjuntar breadcrumbs (últimas acciones), no PII cruda (§privacidad).

### 8. ANR / hangs

- **Android ANR** ("Application Not Responding"): el hilo principal bloqueado más allá del umbral del SO. Detectar con watchdog del hilo main y con las métricas del propio SO (vitals).
- **iOS hangs**: microcongelamientos del main thread; detectar con watchdog y métricas de tiempo de respuesta de UI.
- Reportar con el stacktrace del hilo principal en el momento del bloqueo. Un ANR/hang es un defecto de responsividad percibida, aunque la app no "muera".

### 9. Analítica de eventos

- **Eventos** con nombre estable y **propiedades** tipadas (esquema de eventos versionado, no strings sueltos).
- **Embudos (funnels)**: onboarding, checkout, activación; medir dónde se cae el usuario.
- **Identidad**: distinguir *device id* (anónimo, generado localmente) de *user id* (tras login, seudonimizado). Nunca mezclar PII en la clave de identidad sin la política que lo autorice.
- Adjuntar siempre **versión de app, build, OS y modelo** para segmentar.
- **Instrumentación como craft**: un taxonomía de eventos limpia (naming consistente, diccionario, propiedades obligatorias) es tan diseñada como una API. El "tracking plan" es un artefacto de ingeniería, revisable.

### 10. RUM mobile (Real User Monitoring)

Medición de la experiencia real en el cliente:

| Señal | Qué mide |
|---|---|
| **Arranque** | Cold/warm/hot start hasta primer frame y hasta interactividad |
| **Pantallas** | Tiempo de render por pantalla, transiciones, jank/frames perdidos |
| **Latencia percibida** | Tiempo desde la acción del usuario hasta la respuesta visible |
| **Red desde cliente** | Latencia y tasa de error de llamadas vistas *por la app* |

palma capta estas señales *en el dispositivo*. **La estrategia, metas y budgets de performance los define [performance-mobile.md](performance-mobile.md) y su dueño de disciplina** (ver frontera abajo): palma provee la instrumentación; peakformance gobierna el significado y los umbrales.

### 11. Logging remoto estructurado

- Logs **estructurados** (clave-valor / JSON), no strings concatenados.
- **Niveles** (`error`, `warn`, `info`, `debug`) con muestreo: `debug` verboso solo bajo bandera; en producción, presupuesto de volumen para no drenar batería/datos.
- Buffer local con envío por lotes y reintento; nunca bloquear el hilo principal por logging.
- **Jamás loguear secretos ni PII cruda** (tokens, claves, datos personales) — redacción en origen; ver [seguridad-mobile.md](seguridad-mobile.md).

### 12. Session replay mobile

Reconstrucción visual de la sesión (interacciones, pantallas, gestos).

- Uso **responsable y proporcional**: potente para depurar UX, pero de altísima sensibilidad.
- **Enmascaramiento por defecto** de campos de texto, PII y pantallas sensibles (pago, credenciales, salud); opt-in, no opt-out.
- Sujeto a **consentimiento y retención** que define [gobernanza-y-etica.md](gobernanza-y-etica.md) y el dueño de seguridad. palma implementa el masking y los controles; no decide la política.

### 13. Métricas de negocio en cliente

- Eventos de valor (compra, suscripción, activación, retención) instrumentados en el cliente con la misma disciplina de esquema.
- Distinguir la **señal de negocio** (¿convierte?) de la **señal técnica** (¿funciona?): ambas se emiten, se etiquetan y se separan.
- La instrumentación de negocio es craft: definida con producto, versionada, y validada como cualquier contrato.

---

## Fronteras explícitas (no pisar la manguera)

La telemetría toca disciplinas de las que palma **no es dueño**. palma **instrumenta y emite**; otros **gobiernan y consumen**.

| Ámbito | Dueño | Rol de palma |
|---|---|---|
| **Performance como disciplina** (metas, estrategia, RUM de performance, budgets) | **peakformance** | Instrumenta la telemetría de cliente y **respeta sus budgets**; peakformance gobierna la señal de performance |
| **Observabilidad de plataforma** (servidor, infra, backend) | **baluarte** | palma cubre la telemetría **dentro de la app** (cliente); se integra sin duplicar el plano servidor |
| **Plano de datos** (warehouse, modelado, pipelines) | **andulfo** | palma **emite eventos**; no diseña el destino ni el modelo analítico |
| **Privacidad de la telemetría** (consentimiento, PII, retención, minimización) | **destroyer / sello** | palma **integra según esa decisión**: masking, redacción, gating por consentimiento |
| **Testing** | **amado** | No confundir telemetría de **producción** con **pruebas**; amado prueba, palma observa lo real |

Ver también [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para el detalle de handoffs y contratos con estos aliados.

---

## Greenfield, en construcción y brownfield

- **Greenfield**: definir desde el día cero el *tracking plan*, la taxonomía de eventos, la subida automática de símbolos y los presupuestos de permisos y batería. La telemetría no es un "después".
- **En construcción**: instrumentar en paralelo al feature; cada pantalla nueva nace con su evento y su medición de render; cada permiso nuevo con su degradación.
- **Brownfield**: auditar qué se captura (a menudo demasiado o mal), desimbolización rota, permisos sobre-solicitados, eventos sin esquema y session replay sin masking. Remediar por riesgo: primero crash-free y privacidad, luego cobertura y calidad de la señal.

## Cierre tiered

- **T1 — palma instrumenta**: implementa captura de crashes/ANR, eventos, RUM de cliente, logging, session replay y las capacidades de dispositivo (cámara, ubicación, biometría, sensores, conectividad), con permisos en contexto y degradación con gracia.
- **T2 — se escala al dueño**: **privacidad** → destroyer/sello; **performance** (metas/budgets/estrategia) → peakformance; **plataforma/observabilidad servidor** → baluarte; **plano de datos** → andulfo. palma no fija esas políticas; las integra y las honra.
