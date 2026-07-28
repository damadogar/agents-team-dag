# Cross-Platform e Híbrido

Este satélite cubre las estrategias para construir una sola base de código que se ejecute en múltiples plataformas móviles, y el modelo híbrido donde una UI web se empaqueta en un contenedor nativo. **palma** construye, empaqueta y opera estas soluciones con neutralidad total: ningún framework es "el correcto" por defecto; la elección se decide por contexto, restricciones y evidencia. La **decisión mayor** (nativo vs cross-platform vs híbrido, o migrar de framework) la valida [eneida](interoperabilidad-y-aliados.md) como arquitectura; **palma** la implementa con maestría.

Hermanos relacionados: [plataformas-nativas.md](plataformas-nativas.md) (cuando hay que bajar a iOS/Android nativo), [ecosistemas-y-herramientas.md](ecosistemas-y-herramientas.md) (build, CI/CD, tiendas) e [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) (frontera con farola y el resto del equipo).

## Panorama y ejes de comparación

Todo framework cross-platform resuelve la misma tensión: **compartir código** vs **acceder al SO** con fidelidad y rendimiento. Los ejes que **palma** evalúa en cualquier candidato:

| Eje | Pregunta clave |
|-----|----------------|
| Modelo de UI | ¿Renderiza widgets propios (canvas) o mapea a controles nativos del SO? |
| Lenguaje/runtime | ¿Qué lenguaje, qué runtime en el dispositivo (VM, AOT, JIT, intérprete)? |
| Puente a lo nativo | ¿Cómo llama a APIs del SO? ¿Síncrono, serializado, FFI directo? |
| Alcance de sharing | ¿Comparte lógica, UI, o ambos? |
| Ecosistema | Madurez de librerías, tooling, comunidad, soporte de plataforma. |
| Fidelidad de plataforma | ¿Se siente nativo? ¿Sigue guías de HIG/Material? |

Ninguna columna gana siempre. A continuación, los enfoques dominantes descritos con neutralidad.

## React Native

Framework donde la lógica corre en JavaScript/TypeScript y la UI se **mapea a componentes nativos** reales del SO (no dibuja su propio canvas).

- **Nueva arquitectura**: sustituye el "bridge" asíncrono y serializado (JSON por lotes) por un modelo directo.
  - **JSI (JavaScript Interface)**: capa C++ que permite al motor JS invocar funciones nativas de forma síncrona y sin serialización, sosteniendo referencias a objetos nativos.
  - **TurboModules**: módulos nativos con carga perezosa y tipado por contrato (codegen), invocables vía JSI.
  - **Fabric**: nuevo renderer que unifica el árbol de UI en C++, habilitando renders más consistentes y medición síncrona.
- **Hermes**: motor JS optimizado para móvil (bytecode precompilado, arranque rápido, menor consumo de memoria). Intercambiable, p. ej., por otros motores según necesidad.
- **Fortalezas**: enorme ecosistema JS/npm, hot reload, equipos web reaprovechables, UI con look-and-feel nativo real, code-push para lógica JS.
- **Límites**: el puente JS↔nativo sigue siendo el punto sensible en cargas intensas; animaciones/gestos complejos suelen requerir código nativo; fragmentación de librerías de terceros; el runtime JS añade overhead frente a nativo puro.

## Flutter

Framework donde tanto la lógica como la UI se escriben en **Dart** y la app **dibuja su propia interfaz** sobre un canvas, sin depender de widgets del SO.

- **Dart**: compila AOT a código nativo para release (arranque y rendimiento predecibles) y usa JIT en desarrollo (hot reload).
- **Widget tree**: todo es un widget; la UI es una función declarativa del estado. Composición sobre herencia, con un árbol de elementos y un árbol de render separados para eficiencia.
- **Motor de render**: pinta cada píxel por su cuenta (p. ej. **Impeller**, o **Skia** como motor histórico/alternativo), lo que da **consistencia pixel-perfect** entre plataformas y control total de la animación.
- **Fortalezas**: UI idéntica y controlada en todas las plataformas, rendimiento gráfico alto, un solo lenguaje para toda la app, tooling maduro, alcance más allá de móvil (desktop, web, embebido).
- **Límites**: al no usar controles nativos, la fidelidad de plataforma depende del equipo (accesibilidad, widgets de sistema, look nativo exacto); tamaño de binario mayor por incluir el motor; ecosistema Dart más pequeño que JS/JVM; integraciones muy específicas del SO requieren canales de plataforma hacia código nativo.

## Kotlin Multiplatform (KMP) + Compose Multiplatform

Enfoque que separa **compartir lógica** de **compartir UI**, permitiendo graduar cuánto se comparte.

- **KMP**: comparte la **lógica de negocio** (modelos, casos de uso, red, persistencia, validación) compilando Kotlin a distintos targets (JVM/Android, binarios nativos para iOS vía Kotlin/Native, etc.). La **UI puede permanecer 100% nativa** en cada plataforma (SwiftUI/UIKit en iOS, Jetpack Compose/Views en Android).
- **Compose Multiplatform**: opción para compartir también la **UI** con el paradigma declarativo de Compose, renderizando en un canvas propio en las plataformas soportadas.
- **Interop nativo**: interoperabilidad directa con Swift/Objective-C y con el mundo JVM; `expect`/`actual` declara una API común con implementaciones específicas por plataforma.
- **Fortalezas**: adopción **incremental** (empezar compartiendo solo lógica sin tocar la UI), máxima fidelidad si se conserva UI nativa, sin runtime pesado impuesto a la UI.
- **Límites**: la interop con iOS y el tooling han madurado por etapas; compartir UI vía Compose Multiplatform tiene distintos grados de madurez según plataforma; requiere equipos cómodos con Kotlin y con ambos ecosistemas nativos.

## .NET MAUI

Framework de UI multiplataforma sobre .NET que **mapea a controles nativos** de cada SO desde una base común en C#/XAML, con acceso a APIs de plataforma mediante código específico condicional.

- **Fortalezas**: un solo stack .NET/C# para lógica y UI, fuerte para equipos y organizaciones ya invertidas en .NET, alcance a móvil y desktop, integración con el ecosistema .NET (herramientas, librerías, backend compartido).
- **Alternativas maduras/heredadas (contexto)**: el enfoque desciende de soluciones previas de UI nativa multiplataforma en .NET (p. ej. la generación anterior de Xamarin.Forms) y convive con la opción de UI **web-first sobre .NET** (p. ej. Blazor Hybrid) donde la interfaz es web dentro de un contenedor nativo — un caso híbrido (ver abajo).
- **Límites**: madurez y paridad de controles evaluables por caso; comunidad más pequeña que la de otros enfoques cross-platform; ciertas necesidades de plataforma exigen handlers/código nativo.

## Híbrido (Capacitor / Ionic y similares)

En el modelo híbrido, la **interfaz es una aplicación web** (HTML/CSS/JS con cualquier framework web) que se ejecuta dentro de un **WebView** embebido en una app nativa.

> **Frontera clara**: la **UI web** dentro del WebView (componentes, estado, estilos, rendimiento web, accesibilidad web) es dominio de [farola](interoperabilidad-y-aliados.md). **palma** es dueño del **shell nativo** que la contiene y de todo lo que la conecta al dispositivo. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

Responsabilidades de **palma** en el híbrido:

- **Shell/contenedor nativo**: el proyecto iOS/Android que hospeda el WebView, arranque, splash, ciclo de vida, deep links, permisos.
- **Plugins/puentes nativos**: exponer capacidades del SO (cámara, geolocalización, biometría, notificaciones push, almacenamiento seguro, Bluetooth, filesystem) a la capa web mediante plugins; escribir plugins a medida cuando no existan.
- **Empaquetado y publicación**: firma, capacidades/entitlements, builds, y el release en tiendas (ver [ecosistemas-y-herramientas.md](ecosistemas-y-herramientas.md)).
- **Rendimiento y límites del WebView**: arranque, memoria, cold start, y decidir cuándo una vista debe salir del WebView a nativo.

**Fortalezas**: reutiliza equipos y código web, iteración rápida, un solo modelo mental web. **Límites**: rendimiento y fidelidad acotados por el WebView; gestos/animaciones muy exigentes o hardware intensivo se sienten mejor en nativo; dependencia de plugins para todo lo que toca el SO.

## Módulos y puentes nativos: cuándo bajar a nativo

Ningún framework cross-platform o híbrido cubre el 100% del SO. **palma** desciende a código nativo (ver [plataformas-nativas.md](plataformas-nativas.md)) cuando:

- La API del SO es nueva, especializada o no está expuesta por el framework (widgets de home screen, App Clips/Instant Apps, sensores, NFC/HCE, integraciones de sistema).
- El rendimiento exige el hilo nativo (procesamiento de cámara/imagen/audio en tiempo real, ML on-device, render gráfico intensivo).
- Se necesita una experiencia con fidelidad de plataforma imposible de replicar en el puente.
- Hay que integrar un SDK nativo de terceros sin binding oficial.

El patrón común: **el framework para el 80–95% y un módulo nativo tipado y bien aislado para el resto**, con un contrato limpio en la frontera (JSI/TurboModule, platform channel, `expect`/`actual`, plugin de puente, handler).

## Matriz de decisión: nativo vs cross-platform vs híbrido

La decisión la **valida eneida**; **palma** aporta el análisis técnico y la implementa. Criterios:

| Criterio | Inclina a **nativo** | Inclina a **cross-platform** | Inclina a **híbrido** |
|----------|----------------------|------------------------------|-----------------------|
| Equipo/skills | Especialistas iOS/Android | Un stack común (JS, Dart, Kotlin, C#) | Fuerte equipo web |
| Time-to-market | Menos prioritario | Rápido en 2 plataformas | Muy rápido, reusa web |
| Integración con SO | Profunda y de vanguardia | Media, cubierta por plugins | Ligera, vía plugins |
| Rendimiento/UX | Máximo, gestos/gráficos exigentes | Alto en la mayoría de apps | Suficiente para CRUD/contenido |
| Ciclo de vida/mantenimiento | Dos bases de código | Una base + puentes puntuales | Una base web + shell |
| TCO (costo total) | Mayor por duplicidad | Menor si se comparte bien | Menor si ya hay activo web |
| Fidelidad de plataforma | Total | Depende del enfoque | Acotada por WebView |
| Riesgo de dependencia | Bajo (SO directo) | Ligado al framework | Ligado a WebView + plugins |

Regla práctica: **no hay ganador universal**. Apps con integración profunda al SO y UX de gama alta favorecen nativo o cross-platform con módulos nativos; productos con fuerte activo web y necesidades de dispositivo moderadas favorecen híbrido; equipos que buscan una base única con buena fidelidad favorecen cross-platform. La restricción real (equipo, plazo, presupuesto, roadmap de plataforma) suele decidir más que la preferencia técnica.

## Estrategia de code-sharing y sus límites

- **Gradiente de sharing**: se puede compartir desde solo lógica (KMP con UI nativa) hasta lógica + UI completa (Flutter, Compose MP, MAUI, RN). Más sharing = menos duplicación, pero más abstracción sobre las diferencias del SO.
- **Qué comparte bien**: modelos de dominio, validación, cliente de red, mapeo de datos, máquinas de estado, reglas de negocio.
- **Qué comparte con cuidado**: navegación, almacenamiento, notificaciones, permisos, deep linking — semánticas distintas por plataforma.
- **Qué rara vez conviene forzar**: UX idiomática de cada plataforma, integraciones muy específicas del SO, componentes de sistema.
- **Regla del contrato**: cada punto de sharing debe tener una frontera explícita hacia lo específico de plataforma. Compartir sin esa frontera produce abstracciones que se rompen (leaky) y deuda difícil de revertir.
- **Costo oculto**: mantener la capa de puente/abstracción, seguir los cambios de cada framework y de cada SO, y evitar que "compartir todo" degrade la calidad en la plataforma menos favorecida.

## Render intensivo y motores de juego embebidos

Cuando el producto es gráficamente intensivo (juegos, 3D, AR, visualización pesada), la capa
de UI declarativa cede a un **motor de render**: p. ej. Metal/Vulkan/OpenGL ES directo, o un
**game engine embebido** (p. ej. Unity/Unreal) integrado como vista dentro de la app nativa.
palma construye el **shell nativo, el puente y el ciclo de vida** que hospedan ese motor,
gestiona memoria/energía del render (craft; budgets de `peakformance`) y la interop con las
capacidades del dispositivo. AR se apoya en los frameworks del SO (p. ej. ARKit/ARCore) o en
sensores (ver [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md)). La
elección "motor vs UI nativa" es un trade-off de arquitectura (**eneida** decide, palma ejecuta).

## Greenfield, en construcción y brownfield

- **Greenfield**: **palma** implementa la decisión de arquitectura validada por eneida. Establece el esqueleto del proyecto cross-platform/híbrido, la frontera nativa, el pipeline y la estrategia de sharing desde el día uno.
- **En construcción**: introduce cross-platform de forma incremental donde aporta valor (p. ej. KMP compartiendo lógica sin reescribir UI), o añade módulos nativos a una base cross-platform existente sin romper el contrato.
- **Brownfield**: audita una app existente (nativa, cross-platform o híbrida), identifica fricción y deuda, y planifica **migración de framework** cuando esté justificada — de forma **incremental y reversible**, con vistas coexistiendo (nativo embebiendo cross-platform o viceversa, WebView conviviendo con pantallas nativas) antes de cualquier reescritura total. Una reescritura completa es la última opción y su decisión pertenece a eneida.

## Modelo de trabajo (tiered) y fronteras

- **T1 — palma construye**: implementa el proyecto cross-platform/híbrido, los módulos y puentes nativos, el empaquetado y el release. Es su ownership directo.
- **Decisión de arquitectura → eneida**: la elección estratégica (nativo vs cross-platform vs híbrido, qué framework, migrar o no) la valida [eneida](interoperabilidad-y-aliados.md). **palma** aporta evidencia técnica y ejecuta.
- **Frontera con farola**: en el híbrido, la **UI web dentro del WebView** es de [farola](interoperabilidad-y-aliados.md) (incluye web responsive y PWA); **palma** construye el **shell nativo, los plugins y el empaquetado** que la vuelven una app instalable. El contrato entre ambas capas se detalla en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).
- **Bajada a nativo**: cuando el framework no alcanza, [plataformas-nativas.md](plataformas-nativas.md) rige el código nativo; el build y las tiendas, [ecosistemas-y-herramientas.md](ecosistemas-y-herramientas.md).
