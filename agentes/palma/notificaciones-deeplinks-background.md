# Notificaciones, enlaces profundos y ejecución en segundo plano

Este satélite gobierna cómo la app **alcanza al usuario** (notificaciones), cómo **lleva al usuario al lugar correcto** (deep links) y cómo **trabaja cuando nadie mira** (segundo plano). El eje transversal es la neutralidad: los servicios de transporte de notificaciones (p. ej. APNs en iOS, FCM en Android/multiplataforma, o proveedores de mensajería como capa opcional) son intercambiables; la app se diseña contra **abstracciones**, no contra un vendor. La regla de oro: **el SO manda**. El presupuesto de batería, los estados de proceso y los límites de background no se negocian; se respetan y se aprovechan.

## 1. Push: transporte, tokens y payloads

El push es un **canal best-effort**, no un bus confiable. Nunca asumas entrega ni orden; para estado crítico, sincroniza contra el backend al abrir (el push solo es una señal de "hay algo nuevo").

| Concepto | iOS (p. ej. APNs) | Android/multi (p. ej. FCM) |
|---|---|---|
| Registro | `registerForRemoteNotifications` → device token | SDK entrega registration token |
| Rotación de token | tras reinstalar, restaurar, migrar | tras limpiar datos, reinstalar, expirar |
| Silenciosas / data | `content-available: 1` | mensaje *data-only* |
| Prioridad | `apns-priority` 5/10 | `high` / `normal` |

**Ciclo de vida del token.** El token **cambia** (reinstalación, restauración de backup, migración de dispositivo, expiración del proveedor). Trátalo como efímero: (1) obténlo en cada arranque, (2) súbelo al backend solo si difiere del último enviado, (3) asócialo a usuario+dispositivo con timestamp, (4) purga tokens que el proveedor reporte inválidos (feedback de baja). El **registro** del token en el backend es de [motor](interoperabilidad-y-aliados.md); palma garantiza obtenerlo, detectar cambios y entregarlo con fiabilidad local.

**Payload.** Mantén el cuerpo **pequeño** (hay límites de tamaño por proveedor) y sin datos sensibles: el payload puede quedar en logs del SO y en el centro de notificaciones. Lleva solo un identificador y el mínimo para el routing; el detalle se hidrata desde el backend.

**Silenciosas / data.** Útiles para pre-fetch o invalidar caché, pero el SO **estrangula** su frecuencia y puede descartarlas si la app abusa o está en bajo consumo. No dependas de ellas para lógica crítica ni las uses como "cron encubierto".

## 2. Notificaciones locales, programadas y ricas

Las **locales** no requieren red: recordatorios, alarmas, geofencing, temporizadores. Se programan con disparadores por tiempo, calendario o ubicación.

- **Rich / actionable.** Botones de acción, respuestas en línea (text input), imágenes/media adjuntos, vistas de contenido personalizadas. Las acciones deben resolverse **rápido** y, si tocan red, encolar trabajo diferible.
- **Canales / categorías.** En Android los *notification channels* dan al usuario control granular (sonido, importancia, override de No molestar) y son **inmutables** tras crearse — planifica la taxonomía desde el diseño. En iOS las *categories* agrupan acciones; los *interruption levels* (passive/active/time-sensitive/critical) calibran urgencia.
- **Agrupación.** Agrupa por hilo/tema (thread-id, group key) para evitar saturar el centro de notificaciones; usa resúmenes y colapsado.
- **Payload de notificaciones ricas y de Live Activities.** Este satélite es dueño del **contrato de canal y del formato del mensaje**: tipo/prioridad, `mutable-content`, claves del payload y el **push-to-update** dirigido a una actividad en vivo. La **extensión** que muta/enriquece ese payload en el dispositivo (Notification Service/Content) y la superficie visual las construye [extensiones-y-superficies-del-sistema.md](extensiones-y-superficies-del-sistema.md); la **emisión** desde el servidor es de `motor`.

## 3. Permisos de notificación

En plataformas modernas **el push no se da por sentado**: requiere permiso explícito y revocable. Pedirlo en frío en el primer arranque quema la conversión.

1. **Priming (pre-permission).** Una pantalla propia que explica el *valor* antes de disparar el diálogo del SO. Si el usuario duda, no dispares el diálogo nativo (que solo se muestra una vez de forma efectiva).
2. **Contexto.** Solicita en el momento de valor (tras configurar una alerta que el usuario mismo pidió), no antes.
3. **Provisional.** Cuando exista, la autorización provisional permite entregar de forma silenciosa (a la bandeja, sin interrumpir) y "promocionar" según el comportamiento del usuario — excelente para probar valor sin fricción.
4. **Estado revocable.** Relee el estado del permiso en cada arranque; el usuario pudo cambiarlo en Ajustes. Ofrece un camino a Ajustes cuando esté denegado.

## 4. Deep links, Universal Links y App Links

Un deep link lleva a un destino interno concreto. Hay dos familias: **esquemas propios** (`miapp://`) —frágiles, sin verificación, secuestrables— y **enlaces verificados por dominio** (Universal Links en iOS, App Links en Android), que abren la app desde una URL `https://` real y **prueban** la propiedad del dominio.

| Aspecto | iOS (Universal Links) | Android (App Links) |
|---|---|---|
| Archivo de verificación | AASA (`apple-app-site-association`) | `assetlinks.json` |
| Ubicación | `/.well-known/` del dominio, por HTTPS, sin redirección | `/.well-known/` del dominio |
| Efecto | abre la app sin diálogo intermedio | abre la app sin desambiguación |

- **Verificación de dominio.** El archivo debe servirse por HTTPS, con el `content-type` correcto y sin redirecciones. Un AASA/assetlinks mal publicado degrada silenciosamente el enlace al navegador — es la falla #1.
- **Routing interno.** Centraliza un *router* que mapea URL → pantalla/estado, idempotente y tolerante a rutas desconocidas (fallback a home, nunca crash). Preserva la pila de navegación esperada (back coherente).
- **Deferred deep linking.** Si el usuario no tiene la app instalada, guarda el destino, envíalo a la tienda y **resuelve el enlace tras el primer arranque** post-instalación.
- **Atribución.** Los parámetros de campaña/atribución llegan por el enlace, pero la **segmentación y las campañas** son de [tompo](interoperabilidad-y-aliados.md); palma solo transporta y enruta.
- **Seguridad.** Todo deep link es **entrada no confiable**: valida y sanea parámetros, nunca ejecutes acciones sensibles (pagos, borrado, cambio de cuenta) solo por un enlace sin reautenticación. La política de validación se integra según [destroyer](interoperabilidad-y-aliados.md); ver también entrada/superficie en [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md).

## 5. Ejecución en segundo plano y límites del SO

El background moderno es **cooperativo y presupuestado**. El SO decide cuándo corres, cuánto y con qué recursos; tu trabajo es ser **diferible, reanudable y barato**.

| Necesidad | Mecanismo (p. ej.) | Naturaleza |
|---|---|---|
| Sincronizar/refrescar | background fetch / app refresh | oportunista, sin garantía de horario |
| Trabajo diferible confiable | BGTaskScheduler (iOS), WorkManager (Android) | encolado, con restricciones (red, carga) |
| Procesamiento largo | background processing tasks | ventanas concedidas por el SO, cancelables |
| Continuidad visible | tarea/servicio en primer plano con notificación | el usuario ve que ocurre algo |

**Límites del SO que gobiernan todo:**

- **iOS.** Ventanas de ejecución cortas y a discreción del sistema; las tareas se **agendan**, no se ejecutan a demanda. Trabajo prolongado necesita *processing tasks* y debe manejar expiración (guardar y ceder).
- **Android — Doze y App Standby.** Con pantalla apagada y quietud, el SO agrupa trabajo en *maintenance windows*, difiere jobs y red, y coloca apps poco usadas en *standby buckets* con cuotas decrecientes. **Diseña para que el retraso sea aceptable.**
- **Límites de background execution.** Los servicios en segundo plano están restringidos; el trabajo que debe ser visible requiere una notificación de primer plano. Respeta las cuotas o el SO te matará.

**Presupuesto de batería.** Cada wake-up, radio encendida y CPU cuesta. Agrupa trabajo (*batching*/*coalescing*), exige condiciones (solo con Wi-Fi o en carga cuando aplique), respeta modos de ahorro de energía y **mide** el costo. Rendimiento/energía como disciplina se alinea con peakformance; palma implementa el patrón correcto. La sincronización de fondo se coordina con [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md) para ubicación y sensores.

## 6. Persistencia tras reinicio y muerte del proceso

El estado en memoria **se pierde**: por reinicio del dispositivo, por *kill* del sistema bajo presión de memoria, o por swipe del usuario.

- **Reprogramación tras reinicio.** Las tareas agendadas y alarmas pueden requerir **re-registro** cuando el dispositivo arranca (p. ej. escuchar el evento de boot en Android donde aplique). Reconstruye el schedule desde una fuente persistente al arrancar.
- **Fuente de verdad persistente.** No confíes en variables de proceso: guarda el trabajo pendiente en almacenamiento durable (cola/DB local) e **reconcilia** al iniciar. Todo job debe ser **idempotente** para sobrevivir a re-ejecuciones tras una muerte a mitad de camino.
- **Muerte a mitad de tarea.** Diseña con *checkpoints*: guarda progreso, y al reanudar continúa desde el último punto confirmado, sin duplicar efectos.
- **Comportamiento por *swipe kill*.** Algunos fabricantes matan agresivamente apps deslizadas y cancelan su background; comunica límites reales y evita prometer entregas que el OEM puede impedir.

## 7. Fronteras de responsabilidad

| Tema | Dueño | Rol de palma |
|---|---|---|
| Segmentación, campañas, negocio de notificaciones | tompo (producto) | consume, enruta, no decide a quién |
| Backend de push, envío, gestión server-side de tokens | motor | obtiene token, detecta cambios, lo entrega |
| Validación de entrada / política de deep links | destroyer | integra la validación en el router |
| Construcción cliente (registro local, canales, routing, background) | **palma** | **owner** |

Detalle de contratos y handoffs en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## Greenfield, en construcción y brownfield

- **Greenfield.** Define desde el día uno la taxonomía de canales/categorías, la estrategia de permisos con priming, el dominio verificado (AASA/assetlinks) y una capa de push **agnóstica del proveedor**. Diseña todo job de background como diferible e idempotente.
- **En construcción.** Introduce el router de deep links centralizado, migra de esquemas propios a enlaces verificados, y encapsula el proveedor de push tras una interfaz para poder cambiarlo o duplicarlo.
- **Brownfield.** Audita: tokens no purgados, permisos pedidos en frío, AASA/assetlinks mal publicados, background que ignora Doze/límites de iOS y drena batería, jobs no idempotentes que duplican efectos tras un kill. Prioriza por impacto en batería, entrega y experiencia.

## Modelo tiered

- **T1 — palma construye.** Registro y ciclo de vida del token, notificaciones locales/programadas/ricas, canales/categorías, permisos con priming, router de deep links, verificación de dominio en cliente, background tasks, persistencia y reprogramación tras reinicio, presupuesto de batería.
- **T2 — deriva al dueño.** Backend de push y gestión server-side de tokens → **motor**. Política y validación de deep links / superficie de ataque → **destroyer**. Segmentación, campañas y decisiones de negocio de notificaciones → **tompo**.
