# Extensiones de app y superficies del sistema

Una app móvil de élite no vive solo dentro de su propia ventana: **coloniza el sistema operativo**. Widgets en la pantalla de inicio y de bloqueo, actividades en vivo, experiencias sin instalación, acciones expuestas a los asistentes y un abanico de extensiones que se enganchan a share sheets, teclados, autofill y notificaciones ricas. Este es un **dominio T1 de construcción de palma**: el andamiaje de procesos, presupuestos, ciclos de vida y canales de datos que hacen que estas superficies existan y sean confiables.

El principio transversal que gobierna todo lo que sigue: **cada superficie del sistema es un proceso separado, efímero, con memoria y tiempo de CPU severamente acotados, que no comparte el estado en RAM del proceso principal de la app**. Diseñar para extensiones es diseñar para procesos hambrientos y de vida corta.

## Panorama de superficies (paridad de plataformas)

| Superficie | iOS (p. ej.) | Android (p. ej.) | Naturaleza |
|---|---|---|---|
| Widget de inicio/bloqueo | WidgetKit + SwiftUI | App Widgets + Glance/RemoteViews | Proceso de extensión, render por timeline |
| Actividad en curso | Live Activities / Dynamic Island (ActivityKit) | Ongoing/foreground notification + custom layout | Vive fuera de la app, actualización push/local |
| Experiencia ligera | App Clip | Instant App | Ejecutable parcial sin instalación |
| Acción al sistema/asistente | App Intents / Siri / App Shortcuts | App Actions / Quick Settings tiles / Assistant | Contrato declarado de acciones |
| Extensiones funcionales | Share/Action/Notification/Keyboard/Autofill/File Provider | Share targets, IME, Autofill, Documents Provider, Tiles | Enganche a puntos del sistema |
| Canal de datos compartido | App Group / shared container | shared prefs cifradas / ContentProvider / directorio compartido | Puente app ↔ extensión |

## 1. Widgets de pantalla de inicio y bloqueo

Los widgets **no ejecutan la app**: renderizan a partir de instantáneas que la extensión de widget produce bajo demanda. El modelo dominante es de **timeline**: la extensión entrega una serie de entradas (`estado + marca temporal`) y el sistema las presenta a lo largo del tiempo sin volver a invocar código.

- **Timeline y política de recarga.** Se declara cuándo pedir la siguiente timeline (al final de las entradas, tras un instante fijo, o de forma manual tras un evento de la app). El sistema no garantiza refrescos al segundo: aplica un **presupuesto de refresco** diario que se reparte según uso y visibilidad.
- **Presupuesto de refresco.** Cada widget dispone de un número limitado de recargas por día (p. ej. decenas de actualizaciones en iOS; ventanas mínimas de `updatePeriodMillis` y colas de trabajo diferido en Android). Agotarlo silencia el widget. La regla de élite: **empujar (push/broadcast) actualizaciones event-driven** en vez de sondear en intervalos cortos.
- **Límite de memoria de la extensión.** El proceso de render tiene un techo de memoria muy bajo (unas pocas decenas de MB). Cargar imágenes grandes o datasets completos hace que el sistema mate la extensión y deje un widget en blanco o desactualizado. Se pre-redimensionan imágenes y se persisten **modelos de vista ya cocinados**, no entidades crudas.
- **Familias y superficies.** Un mismo widget declara tamaños (pequeño/mediano/grande/extra) y superficies (inicio, bloqueo, standby/accesorios). El widget de **pantalla de bloqueo** es especialmente restringido: monocromo, minimalista, glanceable.
- **Interacción.** Los widgets modernos admiten controles interactivos que disparan un intent sin abrir la app (App Intents / acciones de RemoteViews). Toda interacción debe resolver rápido y ser idempotente.

El **diseño visual y de contenido glanceable** del widget lo aporta [uxuifull](interoperabilidad-y-aliados.md); palma construye la extensión, el proveedor de timeline, el presupuesto y el canal de datos.

## 2. Actividades en vivo y notificaciones en curso

Representan un **evento vivo y de duración acotada** (un pedido en camino, un partido, un temporizador) visible sin abrir la app: en isla dinámica, pantalla de bloqueo o como notificación persistente.

Ciclo de vida:

1. **Inicio local** desde la app en primer plano, con un estado inicial y atributos estáticos.
2. **Actualizaciones** por dos vías: **local** (mientras la app u otro proceso propio vive) y **remota push-to-update** (un push especial de baja prioridad, dirigido a la actividad, actualiza el estado sin abrir la app). En Android el equivalente es actualizar la notificación ongoing/foreground desde un servicio en primer plano o vía push.
3. **Fin.** La actividad se cierra explícitamente (evento completado) o el sistema la retira tras un tiempo máximo de vida. Siempre debe existir un **estado terminal** legible.

Consideraciones de élite:

- El **contenido de actualización remota se coordina con** [notificaciones-deeplinks-background.md](notificaciones-deeplinks-background.md): es el mismo canal de push, con un tipo/prioridad específico y un payload compacto que mapea al estado de la actividad.
- **Presupuesto y frecuencia:** las actualizaciones remotas son limitadas y priorizadas por el sistema; se envían solo cambios de estado significativos, no telemetría continua.
- **Estados alto/compacto/mínimo** (isla dinámica) o layouts colapsado/expandido (notificación) deben derivarse todos del mismo modelo de estado.
- El **tap** debe llevar por deep link a la vista canónica del evento (ver [notificaciones-deeplinks-background.md](notificaciones-deeplinks-background.md)).

## 3. Experiencias ligeras sin instalación (App Clips / Instant Apps)

Una porción de la app se ejecuta **sin instalación completa**, invocada desde un enlace, un código físico o NFC, para resolver una tarea puntual (pagar, reservar, ver un producto).

- **Invocación.** URLs verificadas (universal/app links) y códigos dedicados (App Clip Codes, QR, NFC, Instant App URLs). El sistema resuelve la superficie ligera en lugar de abrir la tienda.
- **Límite de tamaño.** El binario ligero está fuertemente acotado (orden de pocas a ~15 MB según plataforma). Obliga a **modularizar**: un objetivo/módulo con solo el flujo mínimo, assets recortados y dependencias podadas. Es una restricción de arquitectura de build (frontera con [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para modularización y feature modules).
- **Capacidades reducidas.** Permisos limitados, sin ejecución en background persistente y con un ciclo de vida efímero. Se piden solo los permisos imprescindibles del flujo.
- **Transición a la app completa.** El diseño clave: **traspasar el contexto** (carrito, sesión, progreso) del clip a la app instalada mediante el contenedor/grupo compartido, para que instalar no signifique empezar de cero.

## 4. Acciones expuestas al sistema y asistentes

El objetivo es que las capacidades de la app sean **invocables desde fuera**: asistentes de voz, búsqueda del sistema, atajos, y mosaicos de ajustes rápidos.

- **App Intents / App Actions.** Se declara un catálogo tipado de acciones con **parámetros** (entidades del dominio, enumeraciones, valores), resultados y frases de invocación. Este catálogo es el contrato con Siri/Assistant, la búsqueda y los atajos.
- **Donaciones (donations) y predicción.** La app **dona** intents tras acciones relevantes del usuario para que el sistema aprenda y sugiera atajos proactivos y accesos en pantalla de bloqueo/búsqueda.
- **App Shortcuts.** Atajos "de fábrica" disponibles sin configuración, con sinónimos de invocación por voz.
- **Quick Settings tiles / mosaicos.** Acciones de conmutación rápida desde el panel del sistema (p. ej. iniciar/detener un servicio propio), con estado reflejado y actualización eficiente.
- **Regla de correctitud:** cada acción expuesta debe ser **segura de ejecutar sin UI**, idempotente, y devolver un resultado o un deep link claro cuando requiera continuar en la app.

El **modelo de la experiencia conversacional/de atajos** lo diseña uxuifull; palma implementa el catálogo de intents, parámetros y donaciones.

## 5. App extensions (enganches funcionales al sistema)

Puntos de extensión que insertan la app en flujos del SO:

| Extensión | Función | Notas de construcción |
|---|---|---|
| Share | Recibir contenido compartido desde otras apps | Proceso corto; manejar tipos y tamaños de payload con cuidado |
| Action | Operar sobre contenido in situ | Enfoque en una sola tarea |
| **Notification Service** | Mutar/enriquecer el payload antes de mostrarlo | `mutable-content`: descarga y adjunta media, descifra o localiza texto |
| **Notification Content** | UI personalizada al expandir la notificación | Vistas ricas, interacción, media |
| Keyboard / IME | Teclado de sistema propio | Permisos y privacidad estrictos; sin acceso pleno salvo opt-in |
| Credenciales / Autofill | Rellenar/guardar credenciales y passkeys | Integra con el gestor del sistema; la **política de credenciales/passkey la decide `destroyer`**, palma construye la extensión |
| File Provider / Documents Provider | Exponer almacenamiento como origen de archivos | Sincronización y enumeración eficientes |

Las **extensiones de notificación** son la pieza que habilita las **notificaciones ricas** (imágenes, audio, video, contenido descifrado o localizado en el dispositivo). Su **contenido y el payload de push se coordinan con** [notificaciones-deeplinks-background.md](notificaciones-deeplinks-background.md): ese hermano es dueño del canal y del formato del mensaje; aquí se construye la extensión que lo transforma en experiencia visual, respetando su ventana de ejecución (segundos) antes de que el sistema entregue el fallback sin enriquecer.

## 6. Compartir datos entre app y extensiones

Como cada extensión es un **proceso aislado sin acceso a la RAM de la app**, el único canal fiable es el **almacenamiento compartido**:

- **iOS (p. ej.):** *App Group* → contenedor compartido (directorio, base de datos, defaults compartidos, Keychain con access group).
- **Android (p. ej.):** directorio/preferencias cifradas accesibles por los módulos, `ContentProvider` interno o almacenamiento de la aplicación compartido entre componentes.

Reglas de élite para este canal:

- **La frontera del dato la gobierna** [datos-conectividad-y-offline.md](datos-conectividad-y-offline.md): ese hermano define el modelo de persistencia, migraciones, cifrado en reposo y consistencia. Aquí solo se establece el **contenedor compartido como conducto** y el contrato de lectura entre procesos.
- **Escribir modelos de vista pre-cocinados**, no entidades crudas: la extensión tiene poco tiempo y memoria para transformar datos.
- **Concurrencia entre procesos.** App y extensión pueden leer/escribir a la vez: usar un almacén con acceso multi-proceso seguro (transacciones, WAL, o coordinación de archivos) y evitar formatos que se corrompan bajo escritura concurrente.
- **Límites de ejecución.** Las extensiones se miden en **segundos de CPU y decenas de MB**; superarlos provoca terminación abrupta. Todo trabajo pesado (red, descifrado, imágenes) debe caber en esa ventana o degradar con gracia a un fallback.
- **Seguridad.** Secretos y tokens compartidos van a un almacén cifrado con grupo de acceso; nunca en preferencias en claro. La **política** de endurecimiento la **decide el cluster de seguridad (`destroyer`)**; la **estructura/modularización** del contenedor la enmarca `eneida`. palma **integra** el control, no lo decide.

## Greenfield, en construcción y brownfield

- **Greenfield:** decidir desde el día uno qué superficies del sistema son parte del producto, y modularizar el build (feature modules / objetivos de extensión) y el contenedor de datos compartido **antes** de acumular deuda que impida extraer un App Clip/Instant App liviano.
- **En construcción:** introducir extensiones incrementalmente detrás del canal de datos compartido; cada nueva superficie reutiliza modelos de vista ya definidos, sin duplicar lógica de dominio.
- **Brownfield:** auditar presupuestos de refresco desperdiciados, extensiones que exceden memoria/tiempo, widgets en blanco, actividades en vivo sin estado terminal y datos crudos cruzando el contenedor compartido; refactorizar hacia empuje event-driven y modelos pre-cocinados.

## Frontera tiered

- **T1 — palma:** construcción de todas estas extensiones y superficies del sistema: proveedores de timeline, ciclo de vida de actividades en vivo, módulos de experiencias ligeras, catálogos de App Intents/acciones, extensiones funcionales y el contenedor de datos compartido entre procesos.
- **Diseño de la experiencia → uxuifull:** apariencia glanceable de widgets, layouts de isla dinámica/notificación en curso, experiencia de atajos y de la app ligera.
- **Emisión backend del push (envío desde el servidor) → motor:** el envío de push-to-update para actividades en vivo y del payload de notificaciones ricas. El **contrato de canal/formato en el cliente** lo posee el satélite hermano [notificaciones-deeplinks-background.md](notificaciones-deeplinks-background.md).
