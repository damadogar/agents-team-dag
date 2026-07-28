# Rendimiento mobile: craft de implementación performante

Este archivo es **craft de rendimiento bajo el ownership de [peakformance](interoperabilidad-y-aliados.md)**. La frontera es rectora y no admite ambigüedad:

- **peakformance es el DUEÑO INTEGRAL del performance.** Fija metas, presupuestos (budgets) y estrategia: TTID/TTFD, cold/warm/hot start, ANR/hangs, presupuesto de frame, energía, retención por rendimiento. Hace el **profiling profundo** y el **RUM de performance**, define percentiles objetivo y es quien decide la pregunta rectora: *"¿es suficientemente rápido?"*.
- **palma NO es dueño del performance.** palma es maestro de la **implementación performante como craft**: escribe código de arranque, memoria, frame y red que **respeta y cumple** los budgets que peakformance fijó, y aporta **evidencia en dispositivo** de ese cumplimiento.

Regla operativa: si algo es *meta, umbral, estrategia o veredicto* → es de peakformance. Si algo es *cómo se implementa en la app para cumplir esa meta* → es craft de palma. Este documento cubre solo lo segundo.

## 1. Arranque (startup): cold / warm / hot

El arranque es la primera impresión y correlaciona con retención. Los tres estados a distinguir:

| Estado | Qué ocurre | Craft de palma |
|---|---|---|
| **Cold** | Proceso creado desde cero, no hay estado en memoria | Minimizar trabajo antes de la primera pantalla útil |
| **Warm** | Proceso vivo, actividad/escena recreada | Preservar estado barato de reconstruir, evitar re-fetch |
| **Hot** | Vista en foreground, solo se trae al frente | Casi gratis; no introducir trabajo en el retorno |

Craft esencial:

- **Medir primero.** No optimizar arranque a ciegas. iOS: `MetricKit` (`MXAppLaunchMetric`) y firmas de `os_signpost`; Android: `Macrobenchmark` (`StartupTimingMetric`), `reportFullyDrawn()` y el trace de Perfetto. TTID (initial display) vs TTFD (full display) los define peakformance; palma los **instrumenta** correctamente.
- **Deferir trabajo.** Nada de analítica pesada, warm-up de SDKs, migraciones de BD o lectura de disco síncrona en el hilo principal durante el arranque. Mover a post-first-frame o a inicialización perezosa.
- **Lazy init.** Inicializar dependencias en el primer uso, no en el `Application.onCreate`/`didFinishLaunching`. En Android, auditar/retirar inicializadores automáticos (App Startup, content providers de terceros) que inflan el cold start.
- **Presupuesto de arranque.** peakformance fija el budget (p. ej. TTID pXX). palma lo respeta, presupuesta cada inicializador y falla en CI si un cambio lo excede.

## 2. Memoria

La app muere por OOM sin previo aviso: el SO no negocia. El craft es no llegar ahí.

- **Fugas y ciclos de retención.** iOS: capturas fuertes en closures (`[weak self]`/`[unowned self]` con criterio), delegados `strong`, `Timer`/`NotificationCenter` sin invalidar. Android: `Activity`/`Context` retenidos por singletons, listeners, handlers, corrutinas sin `scope` atado al ciclo de vida. Detección: Instruments (Leaks/Allocations), LeakCanary, Android Studio Memory Profiler.
- **Bitmaps e imágenes.** Suelen ser el mayor consumidor. Decodificar al tamaño de destino (downsampling), no cargar full-res para un thumbnail; usar formatos eficientes; liberar en `onTrimMemory`/advertencias de memoria. Delegar el pipeline a librerías de imagen probadas antes que reinventar caché.
- **Cachés de memoria acotadas.** Toda caché en RAM debe tener límite y política de evicción (LRU) sensible a la presión de memoria; nunca crecer sin techo.
- **Presión de memoria.** Responder a `onTrimMemory`/`didReceiveMemoryWarning` liberando cachés no esenciales. Medir el *memory footprint* real (no el reservado) y vigilar el crecimiento monótono (síntoma de fuga).

Ver también [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md) para límites por gama de dispositivo.

## 3. Batería y energía

El usuario percibe el gasto de batería y castiga a la app. Energía = craft transversal.

- **Wakeups y trabajo en background.** Coalescer y batchear tareas; usar los planificadores del sistema (WorkManager, `BGTaskScheduler`) que respetan Doze/App Standby y las ventanas del SO en lugar de timers propios. No mantener wakelocks.
- **Ubicación.** El GPS de alta precisión es de los mayores drenajes. Pedir la **mínima precisión** que resuelva el caso de uso, usar geofencing/updates significativos en vez de streaming continuo, y detener las actualizaciones al salir de foreground si el caso no lo exige.
- **Red.** Cada radio-encendido cuesta energía (tail energy del radio). Agrupar peticiones, evitar polling agresivo, preferir push. Ver §6.
- **Medición.** iOS: Energy Log de Instruments y `MXCPUMetric`/`MXAnimationMetric` de MetricKit; Android: Battery Historian, `JankStats` y las señales de energía de Perfetto. La *meta* de energía la fija peakformance; palma mide para demostrar cumplimiento.

## 4. Frame rendering y jank

Fluidez = mantener el **hilo principal/UI libre** para entregar cada frame a tiempo (16.6 ms a 60 fps; ~8.3 ms a 120 fps en pantallas ProMotion/alta tasa).

- **Hilo principal sagrado.** Cero I/O de disco/red, parsing pesado, o cálculos en el hilo de UI. Mover a background con estructuras de concurrencia idiomáticas (corrutinas, `async/await`, GCD) y publicar solo el resultado en el hilo principal.
- **Overdraw.** Reducir capas superpuestas, fondos redundantes y transparencias innecesarias; aplanar jerarquías de vistas.
- **Listas eficientes.** Reciclaje correcto (RecyclerView, celdas reutilizables, `LazyColumn`/`List`), diffing en vez de recargar todo, paginación, y trabajo de binding mínimo por celda. Evitar layouts anidados profundos y medir el costo de composición.
- **Frames largos y hangs.** Vigilar frozen frames y hitches. iOS: `MXHangDiagnostic`, hitch ratio; Android: `JankStats`, `FrameTimingMetric`. El *presupuesto de frame* lo fija peakformance; palma implementa para no romperlo.
- **ANR / hangs.** Un bloqueo del hilo principal se convierte en ANR (Android) o hang (iOS) — un fallo de rendimiento visible y penalizado por las tiendas. palma nunca bloquea el hilo principal en operaciones potencialmente lentas.

## 5. Tamaño de la app

El tamaño de descarga e instalación afecta directamente la **conversión de instalación y la retención** (más peso = más abandono, más desinstalaciones por falta de espacio).

- **App Thinning (iOS).** App slicing, bitcode/on-demand resources para entregar solo lo que el dispositivo necesita.
- **Android App Bundle + dynamic delivery.** AAB con split APKs por densidad/ABI/idioma; features on-demand y `Play Asset Delivery` para lo que no se necesita en la instalación base.
- **Minificación y shrinking.** R8/ProGuard (Android) para eliminar código muerto, ofuscar y reducir; strip de símbolos en release (iOS). Vigilar que el shrinking no rompa reflexión/serialización.
- **Recursos.** Comprimir y auditar assets, vectores en lugar de múltiples PNG cuando aplique, retirar recursos huérfanos, y evitar dependencias pesadas por una función marginal.
- **Presupuesto de tamaño.** peakformance puede fijar un budget de tamaño; palma lo vigila con reportes de APK/IPA size en CI y justifica cada crecimiento.

## 6. Eficiencia de red

La red es lenta, cara e intermitente en mobile. El craft es pedir **menos, mejor y a tiempo**.

- **Batching y coalescing.** Agrupar peticiones para reducir round-trips y encendidos de radio.
- **Compresión y formatos.** Compresión de transporte (gzip/brotli), formatos binarios/eficientes sobre texto verboso cuando el volumen lo justifica, imágenes en formatos modernos y al tamaño servido.
- **Caché y revalidación.** Respetar `ETag`/`Cache-Control`, cachear respuestas idempotentes, y evitar re-fetch de lo que no cambió.
- **Prefetch con criterio.** Prefetch solo cuando la probabilidad de uso es alta y hay red/energía favorables (Wi-Fi, cargando); nunca prefetch agresivo en datos móviles o batería baja. El prefetch mal calibrado gasta datos y batería del usuario.
- **Payloads mínimos.** Pedir solo los campos necesarios, paginar, y evitar sobre-fetch. La *estrategia* de qué es aceptable la valida peakformance; palma implementa.

Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para el contrato con backend y la frontera con andulfo/motor.

## 7. Cómo palma mide en dispositivo real

Regla innegociable: **el rendimiento mobile se mide en dispositivo real, en percentiles, no en promedios ni en simulador.**

- **Dispositivo real, no emulador.** El emulador no reproduce térmica, radio, GPU ni la gama baja. Medir en un abanico representativo, incluyendo **dispositivos de gama baja y antiguos** donde el usuario real sufre.
- **Percentiles, no promedios.** Reportar pXX (p50/p75/p90/p95) — el promedio esconde la cola donde vive el mal rendimiento. Los percentiles objetivo los fija peakformance; palma reporta contra ellos.
- **Evidencia antes/después.** Todo cambio de rendimiento se acompaña de medición **antes** y **después** en el mismo dispositivo y condiciones, con la herramienta apropiada (Macrobenchmark, Instruments, MetricKit, Perfetto, traces). Sin evidencia, no hay afirmación de mejora.
- **Condiciones controladas.** Fijar estado térmico, batería, red y build (release, no debug) para que la comparación sea válida.

| Señal | Android | iOS |
|---|---|---|
| Startup | Macrobenchmark `StartupTimingMetric`, Perfetto | MetricKit `MXAppLaunchMetric`, signposts |
| Frame/jank | `JankStats`, `FrameTimingMetric` | Instruments, `MXHangDiagnostic`, hitch ratio |
| Memoria | Memory Profiler, LeakCanary | Instruments (Allocations/Leaks) |
| Energía | Battery Historian, Perfetto | Energy Log, `MXCPUMetric` |
| Tamaño | APK/AAB size analyzer | IPA/App size report |

## 8. Handoff con peakformance

El modelo es **de doble vía y sin solapamiento de ownership**:

| Actividad | Dueño | Rol de palma |
|---|---|---|
| Metas, budgets, percentiles objetivo | **peakformance** | Recibe y respeta |
| Profiling profundo / análisis de causa raíz | **peakformance** | Aporta traces del dispositivo, reproduce |
| RUM de performance y veredicto "¿es rápido?" | **peakformance** | Consume el veredicto |
| Estrategia de optimización cross-cutting | **peakformance** | Ejecuta la parte de implementación mobile |
| Implementación performante (arranque, memoria, frame, red) | **palma** | Dueño del craft |
| Evidencia de cumplimiento en dispositivo | **palma** | Produce y entrega |

Flujo típico: peakformance identifica un problema y fija la meta → palma implementa la corrección en el código mobile con las técnicas de este archivo → palma mide en dispositivo (percentiles, antes/después) → peakformance valida contra el budget y emite el veredicto. palma **nunca** declara por su cuenta que algo "ya es suficientemente rápido": esa es potestad de peakformance.

## 9. Cierre — Greenfield, en construcción y brownfield

- **Greenfield: budgets desde el diseño.** Desde la primera línea, palma pide a peakformance los presupuestos (arranque, frame, memoria, tamaño, energía) y **construye para cumplirlos**, con instrumentación y gates de CI desde el inicio. El rendimiento no se "añade después"; se diseña dentro.
- **En construcción: budgets vivos.** Mientras la app aún se está construyendo, palma instrumenta y mide desde el primer flujo funcional y ajusta el craft contra los budgets provisionales de peakformance, evitando que las regresiones se acumulen sin verse.
- **Brownfield: medir y recuperar.** En apps existentes, primero **medir** en dispositivo real (percentiles), localizar las regresiones con peakformance, y **recuperar** el rendimiento con cambios acotados y evidenciados antes/después, sin regresiones funcionales.

## 10. Cierre tiered

Todo lo aquí descrito es **craft de palma bajo el ownership de performance de peakformance**. El vocabulario tiered es el mismo del contrato maestro ([SKILL.md](SKILL.md) §9, [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) §3):

- **T1 — craft de implementación (palma, directo y rutinario).** La implementación performante en el código mobile (arranque, memoria, frame, tamaño, red) es **dominio propio** de palma: la ejecuta de forma directa, respetando y evidenciando el cumplimiento de los budgets de peakformance. No fija metas ni emite el veredicto de rapidez.
- **T2 — la estrategia sube a peakformance (DEFECTO en frontera).** Cuando la decisión es de *estrategia de performance*, *definición de budget/percentil* o *"¿es suficientemente rápido?"*, palma **escala a peakformance** y ejecuta la implementación resultante.
- **T3 — mitigación excepcional (potestad).** SOLO si peakformance está **ausente o saturado** y hay una regresión urgente, palma aplica una mitigación acotada en su capa, la marca **"pendiente de revisión de peakformance"** y devuelve la decisión de estrategia/budget a su dueño.
