# Ejemplos resueltos end-to-end

Casos reales-plausibles donde **peakformance** actúa como dueño integral del performance del ecosistema. Cada caso mide **antes/después con percentiles** (nunca promedios), aplica marcos (USE/RED, Little's Law, USL, SLO/error budget) y hace explícito el **modelo TIERED**:

- **T1** = lo que peakformance implementa directamente (instrumentación, caché, timeouts/backoff, load shedding, batching, budgets).
- **T2** = lo entregado/co-implementado vía el **dueño de dominio** (farola, motor, andulfo, eneida, sysuniversal-ai…).
- **T3** = fallback cuando no existe dueño de dominio: peakformance cubre de forma **temporal y declarada**, y deja el handoff documentado.

Neutralidad total: los stacks citados son **ejemplos intercambiables**, no recomendaciones. La decisión se toma por **evidencia y medición**, no por moda. Ver método en [metodologia-diagnostico.md](metodologia-diagnostico.md) y estrategia en [estrategia-performance.md](estrategia-performance.md).

---

## Ejemplo 0 — Greenfield: diseñar el performance antes de que exista el sistema

**Contexto/estado.** Plataforma nueva de reservas: **aún no hay código**. Meta de negocio: sostener el pico de campaña (5.000 reservas/min) con experiencia fluida, sin sobre-aprovisionar. No hay nada que medir todavía.

**Reformulación.** El trabajo greenfield es **modelar y presupuestar**, no diagnosticar. Traducimos la meta de negocio a budgets por capa y de-riesgamos la arquitectura con evidencia. Método en [metodologia-diagnostico.md](metodologia-diagnostico.md) §1.1.

**Modelado (sin sistema, con teoría).**
- Carga objetivo: 5.000 reservas/min ≈ 83 req/s de escritura; con lecturas 10:1 → ~900 req/s pico.
- **Little's Law**: si el servicio objetivo es W = 50 ms, la concurrencia en vuelo L = λ·W = 900 × 0.05 ≈ 45 → dimensiona pools/instancias **desde el diseño**.
- **USL**: se fija objetivo de escalado casi-lineal (σ, κ bajos) → decisión de evitar estado compartido caliente (idempotencia, sharding por reserva) desde el día 0.

**Budgets top-down (T1, derivados de la meta, no de un baseline).**

| Capa | Budget objetivo |
|---|---|
| API p99 (escritura) | ≤ 300 ms |
| LCP p75 (web) | ≤ 2.5 s |
| Query p99 | ≤ 20 ms |
| Costo | ≤ $X / 1.000 reservas |

**De-risking con PoC (evidencia, no fe).** Antes de comprometer arquitectura: micro-benchmark/spike de 2–3 candidatos de almacenamiento con **datos a escala simulada** y prueba de carga del PoC en **modelo abierto** ([pruebas-de-carga.md](pruebas-de-carga.md)) para validar el modelo y elegir por medición.

**Optimización tiered (preventiva).**
- **T1 (peakformance):** define budgets, monta el **esqueleto de observabilidad** (SLI/percentiles, RUM, tracing) y los **perf gates en CI** *antes del primer deploy* ([performance-cicd.md](performance-cicd.md)), para que la primera medición real valide el modelo.
- **T2 (dueños):** farola/motor/andulfo construyen dentro de los budgets; peakformance revisa contra presupuesto en cada PR.

**Verificación (modelo vs primer medido, no antes/después).** En el primer PoC bajo carga: p99 escritura = 240 ms (≤ 300 objetivo) y escalado 1→4 nodos = 3.6× (σ/κ dentro de lo previsto). Si el medido se desvía del modelo, se corrige **el modelo** antes de construir más.

**Trade-offs.** Modelar y observar antes del producto cuesta tiempo inicial; evita deuda de performance estructural, cara de revertir. Estrategia greenfield en [estrategia-performance.md](estrategia-performance.md).

---

## Ejemplo 1 — E-commerce brownfield: "la web va lenta" (LCP alto)

**Contexto/estado.** Tienda brownfield (podría ser Next.js, Nuxt o Astro; da igual). Rebote alto en móvil 4G. Quejas cualitativas, sin números.

**Reformulación.** No es "va lenta", es: *el LCP en p75 móvil viola el objetivo de negocio de conversión*. Medimos experiencia real, no laboratorio aislado.

**Baseline medido (RUM móvil, p75).**

| Métrica | Antes |
|---|---|
| LCP p75 | 4.8 s |
| CLS p75 | 0.22 |
| Imagen hero | 1.9 MB PNG sin dimensionar |
| Peso JS render-blocking | 640 KB |

**Diagnóstico (recurso saturado, causa raíz).** Recurso crítico = **red + main thread** en el arranque. Causa raíz: hero pesado sin `preload`/formato moderno, CSS/JS render-blocking, sin caché de borde. USE sobre el navegador: utilización alta del hilo principal durante el primer render.

**Meta/SLO.** LCP p75 ≤ 2.5 s; CLS p75 ≤ 0.1. Error budget de web vitals definido en [frontend-performance.md](frontend-performance.md).

**Optimización tiered.**
- **T1 (peakformance):** instrumenta **RUM** (percentiles reales por dispositivo/red), define budgets de peso, configura **CDN/caché de borde** con política de `Cache-Control` e `immutable` para estáticos, y añade `preload` del recurso LCP.
- **T2 (handoff → farola):** implementa imagen responsive (AVIF/WebP con fallback), `width/height` para reservar layout, code-splitting y diferido del JS no crítico. peakformance entrega presupuesto y criterio de aceptación; farola construye.

**Verificación antes/después (RUM p75).**

| Métrica | Antes | Después |
|---|---|---|
| LCP p75 | 4.8 s | 2.1 s |
| CLS p75 | 0.22 | 0.06 |
| Hero transferido | 1.9 MB | 140 KB |
| JS bloqueante | 640 KB | 210 KB |

**Trade-offs.** AVIF ahorra bytes pero cuesta CPU de decodificación en gama baja; se valida en dispositivo real. La caché de borde exige invalidación disciplinada en despliegues (ver [performance-cicd.md](performance-cicd.md)).

---

## Ejemplo 2 — API backend brownfield: p99 disparado bajo carga

**Contexto/estado.** Servicio de checkout (podría ser JVM, Go o Node). p50 sano, pero p99 explota cuando sube el tráfico.

**Reformulación.** *Bajo concurrencia creciente, el tiempo en cola domina el tiempo de servicio*: síntoma clásico de saturación de pool.

**Baseline medido (prueba de carga, 800 rps).**

| Métrica | Antes |
|---|---|
| Latencia p50 | 40 ms |
| Latencia p99 | 2 300 ms |
| Pool DB | 10 conexiones |
| Utilización pool | ~99% |
| Errores/timeout | 3.1% |

**Diagnóstico (Little's Law).** L = λ·W. Con λ=800 rps y servicio real ~25 ms, la concurrencia necesaria supera con creces las 10 conexiones → cola. El recurso saturado es el **pool de conexiones**, no la CPU (RED: Rate alto, Errors por timeout, Duration en cola). Ver [backend-performance.md](backend-performance.md) y [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).

**Meta/SLO.** p99 ≤ 300 ms a 800 rps; errores < 0.5% *durante la prueba de estrés* (umbral de la corrida). El **error budget** (ventana rolling de 28 días) en operación normal es 0.1% — son ventanas distintas, no una contradicción.

**Optimización tiered.**
- **T1 (peakformance):** añade **caché distribuida** (read-through) para lecturas calientes, **timeouts** agresivos + **backoff con jitter**, y **bulkheads** para aislar dependencias lentas. Define la matriz de reintentos para no amplificar la saturación.
- **T1→T2 (co-implementado → motor):** peakformance provee el **modelo de sizing** del pool (política/target = **T1**); **motor** lo configura en el servicio (config = **T2**), convierte llamadas bloqueantes en **async/no-bloqueante** y ajusta transacciones.

**Verificación antes/después (misma prueba de carga, 800 rps).**

| Métrica | Antes | Después |
|---|---|---|
| p99 | 2 300 ms | 240 ms |
| p50 | 40 ms | 22 ms |
| Utilización pool | 99% | 62% |
| Errores | 3.1% | 0.2% |
| Throughput sostenible | ~820 rps | ~1 950 rps |

**Trade-offs.** Pool mayor consume conexiones del motor de datos (coordinar con andulfo). La caché introduce ventana de consistencia: se acota TTL por criticidad del dato. Detalle del ensayo en [pruebas-de-carga.md](pruebas-de-carga.md).

---

## Ejemplo 3 — Reporte/consulta lenta: N+1 + índice faltante

**Contexto/estado.** Pantalla de reportes tarda "una eternidad" (brownfield, motor relacional cualquiera). Empeora con volumen.

**Reformulación.** *La latencia crece de forma superlineal con las filas*: huele a acceso N+1 y/o full scan por índice ausente.

**Baseline medido.**

| Métrica | Antes |
|---|---|
| Latencia p95 endpoint | 9.4 s |
| Consultas por request | 1 + 480 (N+1) |
| Plan de ejecución | Seq/Full Scan en tabla de 12 M filas |
| Lecturas lógicas | ~3.1 M |

**Diagnóstico (plan de ejecución).** Se captura el **execution plan**: filtro sin índice → scan completo; además el ORM emite una consulta por fila (N+1). Recurso saturado = **I/O de datos + round-trips**. USE sobre el almacenamiento: alta utilización de I/O y espera. Ver [datos-performance.md](datos-performance.md).

**Meta/SLO.** p95 endpoint ≤ 800 ms.

**Optimización tiered.**
- **T1 (peakformance):** introduce **caché de resultados** del reporte (con invalidación por evento de escritura) y define budget de round-trips (máx. 5 por request). Instrumenta la consulta con trazas.
- **T2 (handoff):** **andulfo** diseña el **índice compuesto**/covering y revisa el esquema; **motor** corrige el patrón de acceso (eager loading / batch fetch / proyección) para eliminar el N+1. peakformance especifica el objetivo; los dueños ejecutan.

**Verificación antes/después.**

| Métrica | Antes | Después |
|---|---|---|
| p95 endpoint | 9.4 s | 420 ms |
| Consultas por request | 481 | 3 |
| Plan | Full Scan | Index Range Scan |
| Lecturas lógicas | 3.1 M | 4 800 |

**Trade-offs.** El índice acelera lectura pero añade coste de escritura y almacenamiento (aceptable: ratio lectura/escritura ~50:1). La caché exige invalidación correcta para no servir datos rancios.

---

## Ejemplo 4 — Servicio se cae en el pico (spike): falta backpressure/autoscaling

**Contexto/estado.** Campaña relámpago tumba el servicio (greenfield o brownfield). Sin protección ante avalancha.

**Reformulación.** *El sistema no degrada con gracia*: ante λ por encima de capacidad, colapsa en lugar de rechazar selectivamente. Modelo USL: al añadir carga sin control, la coherencia/contención hace **caer** el throughput.

**Baseline medido (prueba de spike: 200 → 5 000 rps en 30 s).**

| Métrica | Antes |
|---|---|
| Disponibilidad en pico | 71% (caída total ~90 s) |
| p99 antes de caer | 6 s |
| Throughput máximo real | ~1 400 rps (luego colapsa a ~0) |
| Autoscaling | reactivo por CPU, ~4 min de retardo |

**Diagnóstico.** Recurso saturado = **capacidad de cómputo + colas internas sin límite**. Causa raíz: sin **load shedding**, sin **rate limiting**, y autoscaling demasiado lento frente a la pendiente del spike.

**Meta/SLO.** Disponibilidad ≥ 99% durante el pico; degradar rechazando (429) el exceso, nunca caer. Error budget explícito.

**Optimización tiered.**
- **T1 (peakformance):** implementa **load shedding** (prioriza tráfico crítico), **rate limiting** por cliente/token, colas acotadas con **backpressure**, y una **política de autoscaling predictiva** (métrica adelantada: profundidad de cola/rps, no solo CPU) con calentamiento previo.
- **T2 (coordinación → eneida):** cambios estructurales (desacoplar con cola/buffer, idempotencia, partición del punto caliente). peakformance opera los controles de tráfico; eneida rediseña los límites del sistema.

**Verificación antes/después (mismo spike).**

| Métrica | Antes | Después |
|---|---|---|
| Disponibilidad en pico | 71% | 99.6% |
| Throughput útil sostenido | colapsa a ~0 | ~4 200 rps |
| Exceso gestionado | caída | 429 controlado, reintentable |
| p99 del tráfico admitido | 6 s | 310 ms |

**Trade-offs.** Rechazar tráfico (429) es intencional: se protege al usuario admitido a costa del rechazado, que reintenta con backoff. El autoscaling predictivo puede sobreaprovisionar en falsos picos → ver coste en [infra-capacidad-costo.md](infra-capacidad-costo.md). Protocolo del ensayo en [pruebas-de-carga.md](pruebas-de-carga.md).

---

## Ejemplo 5 — Inferencia LLM: TTFT alto y $/token caro

**Contexto/estado.** Feature con LLM (proveedor gestionado o modelo self-hosted; indistinto). Respuestas lentas y factura creciente.

**Reformulación.** *Dos objetivos distintos*: latencia percibida (**TTFT** y tokens/s) y **coste unitario** ($/1k tokens). Se optimizan por separado con SLOs propios. Ver [ia-ml-performance.md](ia-ml-performance.md).

**Baseline medido.**

| Métrica | Antes |
|---|---|
| TTFT p95 | 3.2 s |
| Throughput | 18 tokens/s |
| Coste por respuesta | $0.021 |
| Utilización GPU (si self-host) | ~35% (batch=1) |
| Cache hit prompts | 0% |

**Diagnóstico.** Recurso saturado = **cómputo de inferencia infrautilizado** por batch=1 y ausencia de reuso. Causa raíz: sin **batching**, sin caché de prompts/respuestas, sin streaming, precisión mayor de la necesaria.

**Meta/SLO.** TTFT p95 ≤ 1 s; coste por respuesta ≤ $0.008; sin degradar calidad (validado con evals de amado si aplica).

**Optimización tiered.**
- **T1 (peakformance):** activa **streaming** para bajar TTFT percibido, **caché semántica** de prompts frecuentes, **batching dinámico** con ventana acotada, y budget de coste por request con circuit breaker.
- **T2 (co-implementado → sysuniversal-ai):** **serving** optimizado (batching continuo, paginación KV), **cuantización** (p. ej. 8/4-bit) tras validar calidad, y enrutado de modelos por dificultad. peakformance fija metas de latencia/coste; sysuniversal-ai implementa el serving.

**Verificación antes/después.**

| Métrica | Antes | Después |
|---|---|---|
| TTFT p95 | 3.2 s | 0.7 s |
| Throughput | 18 tok/s | 74 tok/s |
| Coste por respuesta | $0.021 | $0.006 |
| Utilización GPU | 35% | 82% |
| Cache hit | 0% | 41% |

**Trade-offs.** El batching sube throughput pero puede añadir latencia de espera a la primera petición → ventana acotada. La cuantización reduce coste/latencia con posible pérdida de calidad: **se mide con evals antes de promover**, no se asume. La caché semántica requiere umbral de similitud bien calibrado para no servir respuestas erróneas.

---

## Ejemplo 6 — Sistemas/hardware brownfield: p99 alto por false sharing y NUMA remoto

**Contexto/estado.** Servicio de alto QPS (podría ser C++, Rust o Go; indistinto) sobre servidor multi-socket. p50 sano, pero p99 alto y CPU al 100% sin escalar al añadir hilos. Brownfield, sin instrumentación de bajo nivel.

**Reformulación.** *No es falta de CPU, es CPU malgastada*: el trabajo útil por ciclo cae al escalar. Sospecha de **mechanical sympathy** rota — contención en la jerarquía de caché y accesos a memoria cruzando socket. Ver [sistemas-hardware.md](sistemas-hardware.md).

**Baseline medido (prueba de carga + PMU, 200k QPS).**

| Métrica | Antes |
|---|---|
| Latencia p50 | 90 µs |
| Latencia p99 | 1 100 µs |
| IPC (instrucciones/ciclo) | 0.42 |
| LLC-misses | ~38% de accesos |
| Accesos NUMA remotos | ~55% |
| Escalado 1→2 sockets | 1.15× |

**Diagnóstico (recurso saturado, causa raíz).** Recurso saturado = **subsistema de memoria/caché**, no ALUs. Con la PMU (contadores de hardware) se ve **IPC bajo** y **LLC-misses altos**. Causa raíz doble: (1) **false sharing** — contadores compartidos por hilos distintos caen en la misma línea de caché (64 B), forzando invalidaciones (ping-pong de coherencia); (2) **accesos NUMA remotos** — hilos migran entre sockets y leen memoria del nodo lejano. USE sobre la memoria: alta contención de coherencia y latencia de acceso remoto.

**Meta/SLO.** p99 ≤ 300 µs a 200k QPS; IPC ≥ 1.5; escalado 1→2 sockets ≥ 1.8×.

**Optimización tiered.**
- **T1 (peakformance):** kernel-level cross-cutting — fija **afinidad/pinning NUMA** (hilo y su memoria en el mismo nodo, política *local-alloc*) y habilita **huge pages** para reducir presión de TLB; perfila con PMU y **especifica los objetivos** (IPC/miss-rate) del rediseño.
- **T2 (handoff → motor):** cambios en código de dominio — **padding/alineación a 64 B** o **sharded counters** por core para eliminar el false sharing, y rediseño de layout **AoS→SoA** para densidad de caché. peakformance especifica el objetivo; motor reescribe las estructuras. *(Coherente con [sistemas-hardware.md](sistemas-hardware.md) §4: estructuras sharded/SoA = T2.)*

**Verificación antes/después (misma prueba, 200k QPS + PMU).**

| Métrica | Antes | Después |
|---|---|---|
| p99 | 1 100 µs | 260 µs |
| IPC | 0.42 | 1.9 |
| LLC-misses | 38% | 9% |
| Accesos NUMA remotos | 55% | 6% |
| Escalado 1→2 sockets | 1.15× | 1.86× |

**Trade-offs.** El pinning NUMA reduce la flexibilidad del scheduler y puede desbalancear si la carga es irregular. Las huge pages ahorran TLB pero suben el uso de memoria residente y complican el sobre-aprovisionamiento. El padding gasta algo de memoria por línea. SoA mejora caché pero endurece el código frente a accesos por-registro. Detalle en [sistemas-hardware.md](sistemas-hardware.md).

---

## Ejemplo 7 — Embebido/tiempo real: deadline duro incumplido por jitter

**Contexto/estado.** Controlador con **deadline duro** de 1 ms por ciclo (podría ser un lazo de control industrial o automoción; indistinto). Cumple "casi siempre", pero **ocasionalmente lo incumple** — y un solo incumplimiento es un fallo. Brownfield sobre **RTOS** (apropiado para *hard real-time*; en Linux con PREEMPT_RT el objetivo realista es *firm*, ver [tiempo-real-embebido.md](tiempo-real-embebido.md) §5).

**Reformulación.** *Aquí la métrica rectora es el peor caso, no el p99*: en tiempo real duro, un percentil que ignora la cola no sirve — importa el **WCET** (Worst-Case Execution Time) y la **holgura de deadline** acotada. El enemigo es el **jitter** (GC, interrupciones, DVFS, migración de tarea). Ver [tiempo-real-embebido.md](tiempo-real-embebido.md).

**Baseline medido (on-device, contador de ciclos + GPIO en osciloscopio, 10⁶ ciclos).**

| Métrica | Antes |
|---|---|
| Tiempo de ejecución típico | 420 µs |
| **Peor caso (WCET medido)** | 1 480 µs (**> deadline**) |
| Holgura mínima de deadline | −480 µs (violación) |
| Deadline misses | 47 por 10⁶ ciclos |
| Fuente de jitter dominante | pausas de asignación + IRQ + cambio de frecuencia (DVFS) |

**Diagnóstico (recurso saturado, causa raíz).** El recurso no es throughput medio sino **determinismo temporal**. Midiendo on-device (contador de ciclos del core; pulso GPIO al inicio/fin observado en osciloscopio) se aíslan los picos. Causas raíz del jitter: (1) **asignación dinámica** en el camino crítico → pausas no acotadas; (2) **interrupciones** y tarea migrando entre cores; (3) **DVFS** bajando la frecuencia justo antes del ciclo → ejecución más lenta e impredecible.

**Meta/SLO.** **WCET acotado ≤ 800 µs** con holgura ≥ 200 µs; **cero deadline misses** en 10⁶ ciclos (objetivo determinista, no percentil).

**Optimización tiered.**
- **T1 (peakformance):** **fija afinidad y aísla el CPU** crítico (`isolcpus`/cpuset dedicado o su equivalente en el RTOS, IRQ afinadas a otro core); **deshabilita DVFS** en el core crítico (frecuencia fija/*performance governor*); define y verifica un **presupuesto de WCET** por sección; **elimina la asignación dinámica del camino crítico** (pre-reserva, pools). Todo validado con medición on-device.
- **T2 (firmware, vía su dueño):** refactor a **asignación estática** total (buffers pre-dimensionados en compilación) y revisión del scheduler de tareas. peakformance fija el presupuesto temporal y aísla el entorno; el dueño del firmware reescribe la gestión de memoria.

**Verificación antes/después (on-device, 10⁶ ciclos — peor caso, no percentil).**

| Métrica | Antes | Después |
|---|---|---|
| Tiempo típico | 420 µs | 410 µs |
| **WCET medido** | 1 480 µs | 690 µs |
| Holgura mínima de deadline | −480 µs | +310 µs |
| Deadline misses (10⁶ ciclos) | 47 | 0 |

**Trade-offs.** Aislar y fijar frecuencia del core crítico **cuesta eficiencia energética** y reserva un core que queda ocioso fuera del pico. La asignación estática pre-reserva memoria para el peor caso (mayor huella). Estas medidas acotan el peor caso, no el promedio — es la decisión correcta en tiempo real duro. Ampliación en [tiempo-real-embebido.md](tiempo-real-embebido.md).

---

## Cómo se conectan estos casos

Todos siguen el mismo esqueleto de [metodologia-diagnostico.md](metodologia-diagnostico.md): reformular → medir en percentiles → localizar el recurso saturado (USE/RED) → modelar (Little's Law/USL) → fijar SLO/budget → optimizar en **capas tiered** → verificar antes/después → declarar trade-offs. La instrumentación transversal vive en [medicion-observabilidad.md](medicion-observabilidad.md); los handoffs con dueños de dominio se formalizan en [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md); las plantillas reutilizables, en [plantillas.md](plantillas.md).
