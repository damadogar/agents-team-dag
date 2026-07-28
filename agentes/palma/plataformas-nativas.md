# Plataformas nativas: iOS y Android a fondo

Este satélite define la maestría en las dos plataformas móviles nativas dominantes. La regla es paridad estricta: iOS y Android reciben igual profundidad, igual rigor y ninguna preferencia por defecto. Cuando se citan herramientas, se hace como ejemplo intercambiable ("p. ej."), nunca como prescripción. La decisión nativa-vs-otra ruta se discute en [cross-platform.md](cross-platform.md); la capa de UI y accesibilidad en [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md).

## iOS nativo

### Lenguaje: Swift idiomático
Swift es el lenguaje de primera clase del ecosistema Apple. Lo idiomático incluye: `struct`/`enum` sobre clases cuando no hace falta identidad ni herencia (semántica de valor), `Optional` explícito con desempaquetado seguro (`if let`, `guard let`, `??`), inmutabilidad por defecto (`let` sobre `var`), protocolos y extensiones para composición (protocol-oriented programming), genéricos con restricciones, `Result`/`throws` para errores tipados, y `Codable` para serialización. Objective-C sigue vivo en interoperabilidad y bases heredadas: Swift lo consume vía puentes (`@objc`, bridging headers) y muchos frameworks del SO exponen ambas caras.

### SwiftUI vs UIKit
| Criterio | SwiftUI | UIKit |
|---|---|---|
| Paradigma | Declarativo, reactivo (estado→vista) | Imperativo, orientado a objetos |
| Madurez | Reciente, evoluciona rápido | Décadas de estabilidad y control fino |
| Cobertura | Amplia pero con huecos en casos límite | Prácticamente todo lo del SO |
| Interop | Aloja UIKit vía `UIViewRepresentable`/`UIViewControllerRepresentable` | Aloja SwiftUI vía `UIHostingController` |

Criterio: SwiftUI para UI nueva, productividad y multiplataforma Apple (iOS/iPadOS/macOS/watchOS/tvOS); UIKit cuando se requiere control fino de layout/animación, integración con bases existentes o APIs aún no cubiertas. Coexisten en la misma app sin fricción: es lo habitual en apps reales.

### Ciclo de vida
Con SwiftUI el `App` declara la jerarquía; las `Scene` representan instancias de UI (ventanas, multitarea en iPadOS). Los estados de app —no ejecutándose, inactivo, activo, background, suspendido— se observan con `ScenePhase` o, en UIKit, con `UIApplicationDelegate`/`UISceneDelegate`. El trabajo en background se gestiona con tareas acotadas y frameworks de planificación (p. ej. background tasks, procesamiento diferido).

### Swift Concurrency
Modelo estructurado moderno: `async`/`await` para asincronía legible, `Task` para unidades de trabajo, `TaskGroup` para paralelismo estructurado, `actor` para aislar estado mutable y prevenir data races, y `@MainActor` para garantizar ejecución en el hilo principal (UI). El compilador verifica el aislamiento (`Sendable`). Convive con y reemplaza gradualmente patrones previos (completion handlers, colas de despacho).

### Gestión de memoria
ARC (Automatic Reference Counting) libera objetos cuando su conteo de referencias fuertes llega a cero. El riesgo clásico son los ciclos de retención (retain cycles), que se rompen con `weak` (referencia que se vuelve `nil`) o `unowned` (cuando se garantiza vida igual o mayor). Las capturas en closures (`[weak self]`) son la fuente más común de fugas. Los tipos de valor (`struct`) no participan de ARC.

### Frameworks clave del SO
Foundation, Combine (reactividad), Core Data/SwiftData (persistencia), URLSession (red), Core Location, MapKit, AVFoundation (media), Core Bluetooth, HealthKit, StoreKit (compras), UserNotifications, Core ML (inferencia en dispositivo), entre muchos otros.

## Android nativo

### Lenguaje: Kotlin idiomático
Kotlin es el lenguaje de primera clase de Android. Lo idiomático incluye: null-safety en el sistema de tipos (`?`, `?.`, `?:`, `!!` evitado), `data class` para modelos, funciones de extensión, `sealed class`/`sealed interface` para jerarquías cerradas (ideal para estado de UI), `when` exhaustivo, scope functions (`let`, `apply`, `run`, `also`, `with`), inmutabilidad (`val` sobre `var`, colecciones read-only), y delegación de propiedades. Java sigue siendo interoperable al 100% y abunda en bases heredadas y bibliotecas.

### Jetpack Compose vs Views
| Criterio | Jetpack Compose | Sistema de Views (XML) |
|---|---|---|
| Paradigma | Declarativo, reactivo (estado→UI) | Imperativo, jerarquía de `View`/XML |
| Madurez | Reciente, evoluciona rápido | Años de estabilidad y ecosistema amplio |
| Cobertura | Amplia y creciente | Todo el legado y widgets consolidados |
| Interop | Aloja Views vía `AndroidView`; se embebe en Views vía `ComposeView` | Convive con Compose en ambos sentidos |

Criterio: Compose para UI nueva y velocidad de desarrollo; Views cuando hay bases existentes grandes, widgets específicos o dependencias aún no migradas. La interop bidireccional permite migración incremental pantalla a pantalla.

### Ciclo de vida
La `Activity` y el `Fragment` tienen callbacks (`onCreate`/`onStart`/`onResume`/`onPause`/`onStop`/`onDestroy`) que reflejan visibilidad y foco. El componente `Lifecycle` (Jetpack) expone estos estados de forma observable y `lifecycleScope`/`repeatOnLifecycle` acotan trabajo asíncrono a la vida del componente. A nivel de proceso, el SO puede terminar la app bajo presión de memoria; el estado se preserva con `SavedStateHandle`/`onSaveInstanceState` y almacenamiento persistente.

### Coroutines + Flow
Las coroutines son el modelo de asincronía: `suspend fun`, `launch`/`async`, `CoroutineScope` con contexto y `Dispatchers` (Main/IO/Default), `structuredConcurrency` vía jerarquía de scopes, y cancelación cooperativa. `Flow` modela flujos asíncronos de datos (frío), con `StateFlow`/`SharedFlow` para estado observable (caliente) y operadores (`map`, `filter`, `combine`, `flatMapLatest`). Es el equivalente conceptual directo del modelo estructurado de Swift.

### Jetpack (bibliotecas de arquitectura)
- **Lifecycle**: observación de estados de vida.
- **ViewModel**: retiene estado a través de recreaciones de configuración (rotación).
- **WorkManager**: trabajo diferido/garantizado en background con restricciones (red, carga).
- **Navigation**: grafo de navegación type-safe entre destinos.
- **Room**: capa sobre SQLite con verificación en compilación y `Flow`.
- **DataStore**: preferencias/proto persistentes y asíncronas (sucesor de SharedPreferences).

### Gestión de memoria
La JVM/ART usa recolección de basura generacional: no hay conteo manual, pero las fugas ocurren al retener referencias vivas indebidas (p. ej. una `Activity` referenciada por un objeto de vida mayor, listeners no removidos, `Context` filtrado, coroutines no canceladas). Herramientas de detección de fugas y el profiler de memoria son el instrumento habitual. La presión de memoria dispara `onTrimMemory` y posible terminación de proceso.

## Paridad y equivalencias iOS ↔ Android

| Concepto | iOS | Android |
|---|---|---|
| Lenguaje de 1ª clase | Swift | Kotlin |
| Legado interoperable | Objective-C | Java |
| UI declarativa | SwiftUI | Jetpack Compose |
| UI imperativa clásica | UIKit | Sistema de Views (XML) |
| Unidad de pantalla | UIViewController / View | Activity / Fragment / Composable |
| Asincronía estructurada | async/await, Task, actor | coroutines, structured concurrency |
| Flujos observables | AsyncSequence / Combine / `@Published` | Flow / StateFlow / SharedFlow |
| Estado ante recreación | `@State`/`@StateObject`, restauración de escena | ViewModel + SavedStateHandle |
| Persistencia local | Core Data / SwiftData / UserDefaults | Room / DataStore |
| Trabajo en background | Background Tasks | WorkManager |
| Red | URLSession | (cliente HTTP del ecosistema, p. ej.) |
| Inferencia en dispositivo | Core ML | (runtime de ML del ecosistema, p. ej.) |
| Gestión de memoria | ARC (conteo de referencias) | GC de ART (recolección) |
| Fuga típica | retain cycle en closure | referencia retenida / listener no liberado |
| Distribución | tienda oficial de Apple | tienda(s) de aplicaciones |

La lección de paridad: casi todo concepto tiene análogo cruzado. Dominar uno acelera el otro, pero las diferencias de fondo (ARC vs GC, modelo de proceso, políticas de tienda y background) son reales y no deben aplanarse.

## Versiones de SO, fragmentación y soporte

- **Versión mínima soportada (deployment target / minSdk)**: se fija equilibrando alcance de base instalada contra costo de mantener compatibilidad. Regla práctica común: soportar las versiones que cubran la gran mayoría de dispositivos activos, revisándolo cada ciclo.
- **Fragmentación**: iOS concentra la base en pocas versiones recientes por su alta tasa de adopción; Android presenta mayor dispersión de versiones, fabricantes, capas de personalización y tamaños de pantalla. La estrategia de pruebas y capacidades debe reflejar esa diferencia.
- **APIs por nivel**: en Android cada capacidad se asocia a un nivel de API; el código consulta la versión y degrada con elegancia. En iOS se usa `@available`/`if #available` para condicionar por versión.
- **Política de soporte**: definir explícitamente qué versiones se soportan, cuándo se eleva el mínimo y cómo se comunica la deprecación. Elevar el mínimo simplifica el código pero excluye usuarios: es una decisión de producto, no solo técnica.

## Capacidades de plataforma y cómo se acceden

Cámara, ubicación, sensores, biometría, notificaciones push, Bluetooth/NFC, almacenamiento, contactos, salud y pagos se exponen mediante frameworks del SO y se gobiernan por permisos. Principios comunes a ambas plataformas:
- **Permisos**: solicitar en el momento de uso, con contexto, y manejar la negación con gracia. Ambas plataformas endurecen permisos versión a versión (ubicación aproximada, acceso parcial a fotos, permisos de notificación en tiempo de ejecución).
- **APIs tempranas vs estables**: las capacidades nuevas llegan primero como APIs recientes (a veces beta o limitadas por versión). Adoptarlas exige gating por versión y camino de degradación; las APIs estables consolidadas son la base segura. Evaluar madurez antes de comprometerlas en producción.
- **Privacidad**: ambas plataformas exigen declarar uso de datos y capacidades sensibles; tratar esto como requisito de primera clase junto con [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md).

## Greenfield, en construcción y brownfield

- **Greenfield**: elegir UI declarativa (SwiftUI / Compose) salvo restricción concreta; fijar mínimos de SO, arquitectura de estado (actor/ViewModel) y capa de persistencia desde el inicio; establecer límites de módulos limpios.
- **En construcción**: mantener coherencia idiomática, cerrar huecos de concurrencia y ciclo de vida, y no mezclar paradigmas de UI sin criterio; instrumentar memoria y fugas temprano.
- **Brownfield**: respetar la coexistencia (UIKit↔SwiftUI, Views↔Compose, Objective-C↔Swift, Java↔Kotlin); migrar incrementalmente por pantalla o módulo con interop; medir antes de reescribir. Auditar mínimos de SO obsoletos, fugas heredadas y APIs deprecadas.

## Cierre tiered

T1 palma construye lo nativo end-to-end: código idiomático Swift/Kotlin, UI, ciclo de vida, concurrencia, memoria, acceso a capacidades y empaquetado para tiendas. Se apoya en aliados sin invadir su dominio (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)):
- **Rendimiento** (arranque, jank, memoria bajo carga, consumo de batería, tamaño del binario) → se coordina con **peakformance**, dueño de la disciplina de performance; palma implementa la corrección en el nativo.
- **Seguridad** (almacenamiento seguro, biometría, pinning, ofuscación, secretos, superficie de ataque móvil) → decisión y auditoría con **destroyer**; palma integra en el nativo.
- **Arquitectura de sistema** (límites de servicios, contratos, decisiones macro de plataforma) → la define **eneida**; palma la construye con excelencia en iOS y Android.
