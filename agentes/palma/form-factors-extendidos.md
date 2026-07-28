# Form-factors extendidos: wearable, TV, automotriz y superficies embebidas

Este satélite cubre la **construcción** de aplicaciones para form-factors más allá del teléfono, la tablet y el plegable: **muñeca (wearable), sala (TV), vehículo (automotriz) y superficies dedicadas (kioscos/embebido con UI)**. Cada uno tiene su propio SDK, su propio modelo de interacción, sus propias restricciones de recursos y sus propias reglas de tienda. No son "la app de teléfono en otra pantalla": son entornos con contratos distintos.

El adaptive de teléfono/tablet/plegable (breakpoints, ventanas redimensionables, foldable postures, size classes/window size classes) **no se repite aquí**: vive en [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md). Este archivo es exclusivamente los form-factors extendidos y su estrategia de código compartido.

## 1. Wearables (p. ej. watchOS / Wear OS)

El reloj es una superficie de **glanceabilidad**: interacciones de segundos, no de minutos. El modelo de construcción se decide primero por dos ejes.

**Companion vs standalone.** Una app *companion* depende del teléfono para lógica, red y datos; el reloj es un cliente delgado que refleja y notifica. Una app *standalone* corre por sí misma (red propia por Wi-Fi/celular, cuenta propia, instalable sin el teléfono). El estándar actual de ambas plataformas favorece experiencias standalone o híbridas; construir "solo companion" limita el alcance y hoy suele penalizarse en la tienda del reloj. Diseña el reloj para funcionar aunque el teléfono no esté cerca, con degradación elegante cuando falte conectividad.

**Superficies propias del reloj:**

| Superficie | Propósito | Restricción de construcción |
|---|---|---|
| Complications / Tiles | Datos vivos en la esfera o en cards deslizables | Presupuesto estricto de refresco; el sistema decide cuándo actualizar |
| Notificaciones en muñeca | Alertas cortas con acciones rápidas | Payload mínimo, acciones limitadas, texto muy corto |
| App full-screen | Interacción activa breve | Navegación por corona/gestos, targets grandes |
| Fondos/always-on | Vista tenue permanente | UI reducida, sin animación, bajo consumo |

**Salud/fitness y sensores.** El reloj es la mejor fuente de frecuencia cardíaca, movimiento, cadencia y sesiones de ejercicio; la construcción se apoya en las APIs de salud/actividad del sistema y en sesiones de workout que mantienen el sensor activo con permiso del usuario. El detalle de captura, permisos y precisión de sensores se documenta en [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md); aquí importa que **la sesión de ejercicio es lo que autoriza CPU/sensor sostenido en background** dentro del presupuesto del sistema.

**Restricciones de batería/CPU.** El wearable es el dispositivo más restringido de la familia. Reglas de construcción: trabajo en ráfagas cortas, no polling; delegar lo pesado al teléfono cuando exista; respetar los ciclos de refresco que otorga el sistema en vez de forzarlos; animaciones mínimas en always-on. Las **metas y presupuestos** de energía/latencia en dispositivo restringido son craft y su dueño es peakformance; palma implementa dentro de esos presupuestos.

**Sincronización con el teléfono.** Usa el canal de mensajería/transferencia del propio SDK (mensajes en vivo cuando ambos están activos, transferencias en cola cuando no). Modela el estado como *eventualmente consistente*: el reloj puede quedar desconectado y reconciliar después. Nunca asumas entrega inmediata ni orden garantizado.

## 2. TV (p. ej. tvOS / Android TV / Google TV)

La TV se opera **a tres metros de distancia con un control remoto**, no con el dedo sobre el pixel. Dos conceptos gobiernan la construcción.

**Focus engine y navegación por D-pad.** No hay cursor: existe un elemento *enfocado* y el usuario se mueve arriba/abajo/izquierda/derecha con el D-pad, más un botón de selección y uno de retroceso. Construir para TV es construir un **grafo de foco** correcto: todo elemento interactivo debe ser alcanzable, el foco debe moverse de forma predecible y visible, y el elemento enfocado debe destacar con claridad (escala, brillo, sombra/parallax). El motor de foco del sistema resuelve buena parte si se usan los contenedores nativos; el error clásico es UI custom que rompe el recorrido del D-pad y deja controles inalcanzables.

**10-foot UI (legibilidad a distancia).** Tipografía grande, alto contraste, targets amplios, densidad baja, zonas seguras de pantalla (overscan) y navegación poco profunda. Menos elementos por pantalla que en teléfono, no más. El **diseño** de esta experiencia (jerarquía, tamaños, layout) es de uxuifull; palma lo construye respetando el motor de foco y las zonas seguras.

**Superficies del sistema:**

- **Top shelf / recomendaciones**: contenido destacado que la plataforma muestra por encima del ícono o en la home del televisor; requiere proveer un catálogo o feed en el formato que pide el sistema.
- **Reproducción de media**: usa el reproductor nativo y sus controles de transporte; integra *now playing*, pistas de audio/subtítulos, calidad adaptativa y continuación ("seguir viendo"). Respeta HDCP/DRM cuando el contenido lo exija.
- **Sign-in en TV**: escribir con D-pad es hostil. Ofrece **device/pairing code** (el usuario autentica en el teléfono o web y confirma un código en pantalla) o inicio delegado a la cuenta del televisor. Evita formularios de teclado en pantalla como único camino.

## 3. Automotriz (p. ej. CarPlay / Android Auto / Android Automotive OS)

El coche es el entorno **más regulado** por una razón de seguridad: la app no puede distraer al conductor. Aquí no se construye UI libre.

**Plantillas restringidas, no lienzo libre.** Las plataformas de proyección (el teléfono dibuja en la pantalla del coche) exponen un **conjunto cerrado de plantillas** —listas, grids, paneles de navegación, reproductor, mensajes, alertas, punto de interés— y la app rellena datos dentro de esas plantillas. No se dibujan vistas arbitrarias. Android Automotive OS (AAOS), donde el sistema corre *en* el vehículo sin teléfono, da algo más de margen pero sigue gobernado por librerías y restricciones del coche.

**Guidelines de distracción del conductor.** Límites de profundidad de navegación, número máximo de ítems visibles con el vehículo en marcha, sin video ni animaciones que distraigan, sin teclado libre en movimiento, tareas completables en pocos pasos. La tienda **rechaza** apps de coche que no cumplan estas reglas; son requisito de aprobación, no recomendación.

**Categorías permitidas.** No cualquier app entra al coche. Las categorías habilitadas giran en torno a **audio/media, navegación/mapas, comunicación (mensajería y llamadas) y algunas de estacionamiento/carga/POI y clima**, según la plataforma. Construir fuera de una categoría soportada no tiene plantillas ni aprobación posible; confirmar la categoría es un prerrequisito de alcance.

**Voz.** En el coche la voz es interacción de primera clase: manos al volante, ojos al frente. Integra el asistente del sistema y acciones por voz para leer/enviar mensajes, controlar reproducción y navegar. La entrada por voz suele ser preferible a cualquier interacción táctil en movimiento.

## 4. Embebido con UI, kioscos y otras superficies

Superficies dedicadas donde el dispositivo cumple **una sola función**: pedido en restaurante, check-in, señalización, punto de pago, panel de control, tótem informativo.

**Modo kiosco / single-app.** El sistema operativo puede fijar el dispositivo en una app (modo de app única, pantalla anclada, gestión por MDM/EMM). La construcción debe: bloquear salidas y gestos del sistema, ocultar barras de navegación, resistir el uso no supervisado, y recuperarse sola (relanzar tras crash, volver a la pantalla inicial tras inactividad, sobrevivir a reinicios y cortes de energía).

**Consideraciones de construcción para superficie dedicada:**

- **Sin autenticación personal por defecto**: es un dispositivo compartido y público; sesiones efímeras que se limpian solas al terminar o por timeout.
- **Orientación y hardware fijos**: layout para una pantalla y orientación conocidas; a menudo con periféricos (lector, impresora, datáfono, escáner) cuyo detalle vive en [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md).
- **Operación desatendida y offline-tolerante**: colas locales y reconciliación cuando la red vuelva; el equipo no siempre tiene conectividad estable.
- **Telemetría y gestión remota**: salud, versión y estado reportados a distancia, porque nadie está frente al equipo para diagnosticarlo.

## 4.1 Espacial / XR (p. ej. visionOS / Android XR)

La superficie inmersiva es un form-factor de primera clase en 2026: se construye con toolkits
declarativos (p. ej. SwiftUI/RealityKit, o el stack XR de Android) pero con un modelo de
interacción propio.
- **Interacción**: mirada + gestos de pinza (sin cursor ni touch directo), voz, anclaje
  espacial; ergonomía y comodidad (fatiga, campo de visión).
- **Contenido**: ventanas 2D flotantes, volúmenes 3D y espacios inmersivos; gestión de escena,
  oclusión y profundidad. Frontera con AR (ver [cross-platform.md](cross-platform.md) y
  [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md)).
- **Rendimiento**: presupuesto agresivo de fotogramas y térmico (craft; budgets de `peakformance`);
  memoria de activos 3D.
- **Estrategia**: reutiliza la lógica de dominio de la app de teléfono; la presentación es
  específica. La **decisión** de invertir en XR es de `tompo`/`eneida`; el **diseño espacial**
  de `uxuifull`; palma construye.

## 5. Estrategia: qué se comparte y cuándo justificar una app aparte

La regla rectora: **comparte el núcleo, especializa la superficie.** Lo que no depende de cómo se ve ni de cómo se toca puede y debe compartirse; lo que sí, se construye por form-factor.

| Capa | Reutilización esperada | Nota |
|---|---|---|
| Dominio, reglas de negocio, modelos | Alta — un solo núcleo | Idealmente un módulo/librería común |
| Datos, red, cache, auth, sync | Alta | Adaptando presupuestos por dispositivo (reloj, offline) |
| Presentación / navegación | Baja — específica | El grafo de foco de TV, las plantillas del coche y las complications no se comparten |
| Assets e íconos | Media | Densidades, zonas seguras y tamaños propios por superficie |

Sobre patrones de compartición de código multiplataforma (módulo común nativo, capa compartida cross-platform, contratos entre shell nativo y núcleo) ver [plataformas-nativas.md](plataformas-nativas.md) e [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md); no se reproduce aquí.

**¿App aparte o target adicional?** Señales para construir una app/target dedicado en vez de estirar la existente:

- La superficie tiene su propio SDK y modelo de interacción irreconciliable (TV, reloj, coche casi siempre lo son).
- La tienda o la plataforma la trata como binario/target propio.
- El caso de uso diverge del teléfono (glance en muñeca, lean-back en TV, manos-libres en coche) y forzar reutilización de UI degrada ambas.
- El presupuesto de recursos es incompatible (el reloj no tolera el peso del teléfono).

Señales para **no** hacer app aparte: la superficie solo consume el mismo flujo con otro layout, y el adaptive normal (que vive en [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md)) ya lo resuelve.

**Frontera de decisión.** Palma **no decide a qué form-factors ir**. Esa es una decisión de producto (tompo, ¿aporta valor a los usuarios?) y de arquitectura (eneida, ¿cómo se estructura el código compartido y los targets?). El **diseño de la experiencia** por form-factor —jerarquía 10-foot, flujo glanceable, plantillas de coche— es de uxuifull. Cuando esas decisiones existen, **palma construye**: implementa los targets, cablea SDKs, arma el grafo de foco, rellena las plantillas, integra complications/tiles, kiosco y sincronización.

## Greenfield, en construcción y brownfield

- **Greenfield**: define desde el inicio la frontera núcleo compartido / superficie específica, para que sumar un form-factor sea agregar un target sobre un dominio limpio, no reescribir.
- **En construcción**: introduce el nuevo form-factor detrás del núcleo ya existente; verifica presupuestos de recurso (peakformance) y reglas de tienda de esa superficie antes de invertir en UI.
- **Brownfield**: audita cuánto del legado es dominio reutilizable vs UI de teléfono acoplada; extrae el núcleo antes de intentar proyectar a TV/coche/reloj. No portes la UI de teléfono tal cual: casi siempre viola las reglas del nuevo entorno.

## Modelo tiered

- **T1 — palma (construcción)**: dueño de construir los targets de wearable, TV, automotriz y embebido, su cableado a SDKs, superficies del sistema, kiosco y sincronización, dentro de los presupuestos de recurso definidos.
- **Decisión de alcance (a qué form-factors ir)** → tompo (producto) y eneida (arquitectura).
- **Diseño de la experiencia por form-factor** → uxuifull.
- **Rendimiento en dispositivo restringido (metas/presupuestos)** → peakformance (craft); palma implementa conforme.
