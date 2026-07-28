# Medición y observabilidad — medir con rigor

Sin medición honesta no hay performance engineering: hay superstición. Este satélite define **cómo** medir para que los datos sean confiables, comparables y accionables. Es el cimiento de todo lo demás: [estrategia-performance.md](estrategia-performance.md) fija las metas (SLI/SLO/budgets) y aquí se establece cómo instrumentarlas y verificarlas. La instrumentación es **cross-cutting Tier-1**: la implementa `peakformance` directamente (ver modelo TIERED en [estrategia-performance.md](estrategia-performance.md)).

Principio rector: **evidencia, nunca moda**. Toda herramienta aparece como *p. ej.* con 2-3 opciones de ecosistemas distintos; se elige por contexto (stack, escala, presupuesto, madurez, restricciones de datos). Aplica a greenfield (instrumenta desde el diseño) y brownfield (instrumenta incrementalmente por el borde antes de tocar el núcleo).

## Por qué percentiles y no promedios

El promedio es una mentira estadística cómoda: colapsa una distribución en un número que **nadie experimenta**. La latencia de un sistema real es asimétrica y con cola pesada (long tail). La cola es donde vive el usuario frustrado, el timeout, el retry, la cascada.

| Métrica | Qué dice | Riesgo |
|---|---|---|
| Promedio (media) | Centro de masa; sensible a outliers | Oculta la cola; un p99 malo puede dar buen promedio |
| p50 (mediana) | Experiencia típica | No dice nada de los peores casos |
| p95 | 1 de 20 peticiones peor que esto | Frontera de "molesto" |
| p99 | 1 de 100; SLO común de usuario | Donde empieza el dolor real |
| p99.9 | Cola crítica; afecta a usuarios activos con muchas peticiones | Donde mueren las sesiones y los fan-outs |

Reglas duras:
- **Nunca promediar percentiles.** El promedio de p99 de dos ventanas/instancias NO es el p99 global. Los percentiles no son aditivos; agréguese sobre histogramas (t-digest, HDR Histogram, DDSketch) o percentiles calculados sobre el conjunto completo.
- En sistemas con **fan-out**, la latencia percibida tiende al percentil alto de sus dependencias: si una petición toca 100 backends, su p50 se acerca al p99 individual (efecto "tail-at-scale"). Presupuestar la cola, no la media.
- Reportar siempre **con la carga y el contexto**: "p99 = 120 ms @ 2 000 RPS, 8 vCPU, dataset representativo". Un percentil sin caudal ni entorno es ruido.

## Benchmarking honesto

Un benchmark sin rigor produce números que se contradicen entre corridas y engañan a todos. Requisitos mínimos:

- **Warmup**: descartar las primeras iteraciones (JIT, cache frío, connection pools vacíos, autoscaling no estabilizado). Medir sólo estado estacionario.
- **Repeticiones y varianza**: N corridas; reportar distribución (mediana + IQR o percentiles), no una sola cifra. Si la varianza entre corridas es alta, el resultado no es concluyente.
- **Control de ruido**: entorno estable y aislado (sin vecinos ruidosos, sin GC/cron/antivirus/thermal throttling, CPU pinning si aplica, frecuencia fija). Documentar hardware, versión, flags, dataset.
- **Aislamiento de variable**: cambiar **una** cosa a la vez. Antes/después con el mismo arnés, misma carga, mismo entorno.
- **Significancia**: si dos medias caen dentro del rango de ruido, no hay mejora. Preferir pruebas de hipótesis o intervalos de confianza sobre "se ve más rápido".
- **Micro vs macro**: los microbenchmarks mienten por optimizaciones del compilador (dead-code elimination); usar arneses que impidan la eliminación (consumir el resultado). Preferir benchmarks a nivel de sistema cuando la pregunta es sobre el sistema.

Herramientas *p. ej.*: arneses de microbenchmark del propio lenguaje (JMH en JVM, `criterion`/BenchmarkDotNet, `pytest-benchmark`/`hyperfine`); para carga ver [pruebas-de-carga.md](pruebas-de-carga.md).

## Coordinated omission (omisión coordinada)

El error más peligroso y más común en medición de latencia. Ocurre cuando el generador de carga **espera** la respuesta de una petición lenta antes de enviar la siguiente: las peticiones que "debieron" enviarse durante el estancamiento nunca se emiten, y sus latencias (que habrían sido enormes) **no se registran**. Resultado: el sistema parece rápido justo cuando peor está. Subestima brutalmente p99/p99.9.

```
# Modelo ingenuo (SUFRE coordinated omission):
loop:
    t0 = now()
    send_request(); wait_response()      # si el sistema se atasca, aquí nos bloqueamos
    record(now() - t0)                    # sólo medimos lo que logramos enviar
    # NO se envían las peticiones que "tocaban" durante el atasco → cola invisible

# Modelo corregido (schedule-based / tasa constante):
schedule = 0
interval = 1 / target_rate
loop:
    schedule += interval
    sleep_until(schedule)                 # el reloj manda, no la respuesta
    intended = schedule
    send_request(); wait_response()
    record(now() - intended)              # latencia medida desde cuándo DEBIÓ salir
```

Mitigaciones:
- Usar generadores con **tasa de llegada constante / corrección de CO** (p. ej. `wrk2`, `k6` con llegada abierta, arneses basados en HdrHistogram; ver [pruebas-de-carga.md](pruebas-de-carga.md)).
- Preferir **modelo de carga abierto** (llegadas independientes del servicio) frente a cerrado (thread espera respuesta) cuando se modela tráfico real de usuarios.
- Medir latencia desde el **instante de llegada previsto**, no desde el envío efectivo.

## RUM vs sintético/lab

Dos lentes complementarias; ninguna basta sola.

| | RUM (Real User Monitoring) | Sintético / Lab |
|---|---|---|
| Qué mide | Usuarios reales, dispositivos/redes reales | Sondas controladas, entorno fijo |
| Fortaleza | Verdad de campo; distribución real; segmentable | Reproducible; detecta regresiones; pre-producción |
| Debilidad | Ruidoso; no controla variables; sólo post-hoc | No representa la diversidad real; puede mentir por optimismo |
| Uso | Verificar SLO reales, priorizar por impacto | CI/CD gates, alertas proactivas, comparabilidad |

Regla: **SLO se validan con RUM**; **regresiones se atrapan en lab/CI** (ver [performance-cicd.md](performance-cicd.md)). En frontend, Core Web Vitals se miden idealmente con RUM de campo y se vigilan con lab (ver [frontend-performance.md](frontend-performance.md)).

## Las tres señales de instrumentación

### Métricas
Series temporales numéricas agregables, baratas de almacenar.
- **Counter** (monótono: peticiones, errores) · **Gauge** (valor instantáneo: conexiones, memoria) · **Histograma/summary** (distribución de latencia → de aquí salen los percentiles).
- **Cardinalidad**: el asesino silencioso. Cada combinación única de labels es una serie. Etiquetar por `user_id`, `request_id` o URLs sin plantilla explota la cardinalidad y tumba el backend de métricas y el presupuesto. Regla: labels de **baja cardinalidad y acotada** (ruta plantillada, código de estado, región); lo de alta cardinalidad va a trazas/logs, no a métricas.
- Marcos de qué medir: **RED** (Rate, Errors, Duration — para servicios/request-driven), **USE** (Utilization, Saturation, Errors — para recursos), **Golden Signals** de Google SRE (latencia, tráfico, errores, saturación). Ver aplicación en [backend-performance.md](backend-performance.md) e [infra-capacidad-costo.md](infra-capacidad-costo.md).

*p. ej.*: Prometheus/OpenMetrics, StatsD/Graphite, OpenTelemetry Metrics.

### Logs
Eventos discretos con contexto. Preferir **structured logging** (clave-valor/JSON) sobre texto libre: consultable, correlacionable. Incluir siempre `trace_id`/`span_id` para saltar de log a traza. Controlar volumen y costo con niveles y sampling; los logs son la señal más cara por byte. No poner PII/secretos.

*p. ej.*: pila tipo ELK/OpenSearch, Loki, backends estilo Splunk.

### Trazas (tracing distribuido)
La única señal que reconstruye el **camino de una petición** a través de N servicios.
- **Span**: unidad de trabajo con inicio/fin, atributos, estado. Los spans forman un árbol por petición (trace).
- **Propagación de contexto**: el `trace_id` viaja por los límites (HTTP headers, mensajes de cola) — estándar W3C Trace Context. Sin propagación, las trazas se cortan en cada salto.
- **Sampling**: no se guarda todo (costo/volumen). *Head-based* (decidir al inicio, simple, puede perder los raros) vs *tail-based* (decidir al final: conservar las trazas lentas o con error — mejor para diagnóstico, más caro de operar). Elegir por costo vs valor diagnóstico.
- Las trazas absorben la **alta cardinalidad** que las métricas no pueden.

*p. ej.*: OpenTelemetry (estándar neutral de propagación e instrumentación), backends tipo Jaeger/Tempo/Zipkin. Ver cómo se usan en diagnóstico en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).

## Profiling

Responde **dónde** se va el tiempo/recurso dentro de un proceso, algo que métricas y trazas no ven.

| Tipo | Pregunta que responde |
|---|---|
| CPU | ¿Qué código quema ciclos? (on-CPU) |
| Wall-clock | Tiempo real incl. esperas (I/O, locks) — off-CPU |
| Heap / alloc | ¿Qué asigna/retiene memoria? (leaks, presión de GC) |
| Lock / contención | ¿Dónde se serializan los hilos esperando? |

- **Sampling** (muestreo periódico del stack; bajo overhead, apto para producción) vs **instrumentación** (instrumenta cada llamada; preciso pero costoso y puede distorsionar). Por defecto, sampling en prod.
- **Continuous profiling**: perfilado de baja sobrecarga siempre activo en producción, correlacionable en el tiempo; permite comparar antes/después de un despliegue y encontrar regresiones que sólo aparecen bajo carga real.
- Visualización: **flame graphs** para CPU/alloc.

*p. ej.*: perf/eBPF, pprof, async-profiler/JFR, y continuous profilers estilo Pyroscope/Parca.

## APM y observabilidad en producción

APM correlaciona métricas + trazas + logs + perfiles sobre transacciones de negocio, con detección de regresiones y mapas de dependencia. La meta no es sólo *monitoreo* (¿está roto lo que anticipé?) sino **observabilidad** (¿puedo responder preguntas nuevas sobre estados que no anticipé, sin desplegar código nuevo?). Eso exige eventos ricos y de alta cardinalidad, no sólo dashboards fijos. Estandarizar sobre un estándar abierto de instrumentación/telemetría (p. ej. OpenTelemetry) evita el lock-in de agente/vendor.

## Cómo definir y medir un SLI correctamente

Un **SLI** (Service Level Indicator) es una proporción de eventos buenos sobre eventos válidos, medida desde la perspectiva del usuario.

```
SLI = eventos_buenos / eventos_válidos     # p. ej. peticiones bajo umbral / peticiones totales
```

Buenas prácticas (Google SRE):
- **Definir "bueno" con un umbral explícito**, no un percentil vago: p. ej. "proporción de peticiones servidas en < 200 ms". Esto se agrega correctamente entre ventanas (a diferencia de promediar percentiles).
- Medir en el **punto más cercano al usuario** posible (load balancer, cliente), no en el corazón del servicio, para incluir colas y red.
- Especificar la **ventana** (rolling 28d) y el **denominador válido** (excluir tráfico no elegible con cuidado, sin inflar el numerador).
- Pocos SLI por servicio, alineados a journeys reales. El **SLO** es el objetivo sobre el SLI; el **error budget** deriva de él (ver [estrategia-performance.md](estrategia-performance.md)).

Alinea con DORA (los cuatro indicadores de entrega) y Well-Architected (pilar de rendimiento) para conectar performance con salud de entrega y arquitectura.

## Instrumentación como Tier-1

`peakformance` **implementa** la capa transversal de instrumentación (métricas RED/USE, trazas con propagación, histogramas de latencia, hooks de profiling, convenciones de labels y cardinalidad). Coordina con el equipo: `farola` (RUM y Core Web Vitals en cliente), `motor` (spans y métricas en backend), `andulfo` (métricas de motor de datos y consultas), `sysuniversal-ai` (latencia/costo de inferencia), `eneida` (que la observabilidad sea decisión de arquitectura de primera clase), `amado` (los SLI como criterio de calidad) y `destroyer` (que la telemetría no filtre PII/secretos). Fixes puntuales de rendimiento se entregan Tier-2 vía el dueño del componente; si no hay dueño, Tier-3 fallback.

## Medir sistemas no-online (batch, on-device/embebido, desktop/CLI)

El aparato de RUM/APM/tracing asume un **servicio online, multiusuario, request-driven**. Otros tipos de sistema —que peakformance también cubre— exigen otras métricas y otra instrumentación:

| Tipo de sistema | Métrica rectora | Instrumentación (p. ej.) |
|---|---|---|
| **Batch / data pipeline** | Tiempo de fin vs **ventana**, throughput por ventana, **stragglers**, frescura de datos | métricas de job/etapa, skew por partición, checkpointing → [datos-performance.md](datos-performance.md) |
| **Embebido / on-device / IoT** | **Peor caso** y deadline (no p99), jitter, latencia de interrupción, energía | contadores de ciclo, tracepoints, JTAG/analizador lógico, muestreo on-device |
| **Desktop / móvil nativo** | Arranque (cold/warm), footprint de memoria, frame time, ANR | perfiladores de plataforma, trazas del SO |
| **CLI / librería / job corto** | Tiempo de arranque, throughput, asignación/GC | micro-benchmarks con warmup y varianza controlada |

> **Enrutado de técnicas por tipo de sistema.** Desktop nativo reutiliza el trabajo de main-thread/frame de [frontend-performance.md](frontend-performance.md) §8-9 y de memoria/GC de [backend-performance.md](backend-performance.md) §5; **CLI/librería/job corto**, el arranque/asignación de `backend §5` y el micro-benchmarking de este archivo; **batch/data pipeline**, [datos-performance.md](datos-performance.md); **embebido/tiempo real**, disciplina propia en [tiempo-real-embebido.md](tiempo-real-embebido.md).

Regla: **medir donde el sistema realmente vive**. En sistemas de tiempo real/embebido la métrica rectora es la **garantía de peor caso**, no el percentil (tratamiento propio en [tiempo-real-embebido.md](tiempo-real-embebido.md)).

## Qué hacer con los datos

Medir es sólo el insumo. El diagnóstico —formular hipótesis, hallar el cuello de botella, aplicar Little's Law y USL, cerrar el bucle con antes/después— vive en [metodologia-diagnostico.md](metodologia-diagnostico.md). Cómo medir dentro del pipeline (gates, budgets, detección de regresiones automatizada) está en [performance-cicd.md](performance-cicd.md). Plantillas de dashboards, tarjetas de SLI y reportes en [plantillas.md](plantillas.md); casos aplicados en [ejemplos.md](ejemplos.md). Para el mapa de dependencias entre satélites y aliados, ver [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md).
