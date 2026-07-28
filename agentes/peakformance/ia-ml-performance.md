# Performance de IA/ML e inferencia (perspectiva de rendimiento, no de modelado)

peakformance es dueño integral del performance del ecosistema; en IA/ML eso significa gobernar la **latencia, el throughput y el costo por inferencia/token** de los sistemas inteligentes en producción, sin sesgo de acelerador, runtime ni proveedor de modelos: CPU/GPU/TPU/aceleradores y los distintos runtimes de inferencia son intercambiables y se eligen por contexto y evidencia, nunca por moda. Este archivo cubre métricas de inferencia (incl. LLMs), batching, concurrencia/colas, hardware y utilización, optimización de modelo **desde el rendimiento**, técnicas de serving para LLMs, autoscaling y cold start, costo por token, y latencia de pipelines RAG/agénticos, más el reparto tiered con **sysuniversal-ai** (dueño de construir y operar IA/MLOps) y **prisma** (dueño del modelado estadístico).

> Contexto hermano: estrategia global en [estrategia-performance.md](estrategia-performance.md); método de diagnóstico en [metodologia-diagnostico.md](metodologia-diagnostico.md); medición/telemetría en [medicion-observabilidad.md](medicion-observabilidad.md); colas y escalado horizontal en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md); costo y capacidad en [infra-capacidad-costo.md](infra-capacidad-costo.md); backend/red del pipeline en [backend-performance.md](backend-performance.md); recuperación/datos en [datos-performance.md](datos-performance.md).

## 1. Modelo TIERED de responsabilidad

| Tier | Qué | Dueño | Nota |
|------|-----|-------|------|
| **T1** | Cross-cutting de rendimiento: batching, caché (prompt/embedding/semántica), autoscaling de inferencia, instrumentación de latencia (TTFT/TPOT/tokens-s), colas, budgets de $/inferencia y gates | **peakformance** implementa | No depende del modelo concreto |
| **T2** | Serving/modelo/pipeline de IA (elección de runtime, cuantización aplicada, RAG, agentes, MLOps, drift/retraining) | se entrega/co-implementa vía **sysuniversal-ai** | Dueño de construir y operar IA/MLOps; peakformance especifica objetivo y evidencia |
| **T2-DS** | Modelado estadístico, elección de arquitectura del modelo, métricas de calidad predictiva | **prisma** (data science) | **NO** es de peakformance; el trade-off calidad↔latencia se decide con prisma/sysuniversal-ai |
| **T3** | Fallback: implementación directa de peakformance | peakformance | Solo si no hay dueño de IA disponible |

Regla: peakformance **mide en percentiles, define budgets de latencia/costo y prueba antes/después**; la construcción del serving y del modelo se coordina con sysuniversal-ai, no se secuestra. Marcos: **MLOps/LLMOps**, **Google SRE** (SLOs, error budgets), **Little's Law** (dimensionado de colas/concurrencia), **Well-Architected** (costo/confiabilidad).

## 2. Métricas de inferencia (percentiles, no promedios)

Siempre p95/p99 sobre **carga representativa** (mezcla real de prompts, longitudes y concurrencia), no un prompt de juguete en GPU ociosa.

| Métrica | Qué captura | Aplica a |
|---------|-------------|----------|
| **Latencia p99** | Cola de peor caso de una inferencia completa | Todo modelo |
| **Throughput** | Peticiones o tokens por segundo del servicio | Todo modelo |
| **TTFT** (time-to-first-token) | Cuánto tarda el primer token; domina la latencia percibida en streaming | LLM |
| **TPOT / inter-token** | Tiempo entre tokens sucesivos; gobierna la velocidad de lectura | LLM |
| **Tokens/seg** (por request y agregado) | Velocidad de generación y capacidad del servicio | LLM |
| **Cola / wait time** | Tiempo esperando acelerador libre; separa saturación de cómputo lento | Todo |
| **$/inferencia y $/token** | Eficiencia económica; se optimiza junto con latencia | Todo → [infra-capacidad-costo.md](infra-capacidad-costo.md) |

Latencia total ≈ `cola + prefill (∝ tokens de entrada) + decode (∝ tokens de salida × TPOT)`. TTFT lo domina el **prefill**; el tiempo total de respuesta, el **decode**. Optimizaciones distintas para cada uno.

## 3. Batching y su trade-off latencia/throughput

El batching sube throughput y baja $/token a costa de latencia individual. Elegir por SLO, no por defecto.

| Tipo | Cómo | Trade-off |
|------|------|-----------|
| **Estático** | Tamaño de lote fijo; espera a llenar | Máximo throughput, peor TTFT (espera al lote) |
| **Dinámico** | Ventana de tiempo/tamaño; despacha lo acumulado | Balance configurable con `max_batch` + `max_wait` |
| **Continuous batching** (in-flight, para LLMs) | Nuevas peticiones entran/salen del lote token a token | Mejor uso de GPU y latencia sin esperar a que todo el lote termine |

Palancas T1: `max_batch_size`, `max_queue_wait_ms`, umbral de padding. Padding excesivo (secuencias de longitud dispar) desperdicia cómputo: agrupar por longitud o usar batching continuo. Validar cada cambio con **antes/después** en p99 y tokens/seg bajo carga representativa → [pruebas-de-carga.md](pruebas-de-carga.md).

## 4. Concurrencia y colas de inferencia

El serving de IA es un sistema de colas con servidores caros y escasos (aceleradores). Aplicar **Little's Law**: `L = λ × W` (peticiones en sistema = tasa de llegada × tiempo en sistema). Dimensionar concurrencia y réplicas para que la cola no explote antes de saturar el acelerador. Detalle de colas, backpressure y load shedding en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).

- **Límite de concurrencia por réplica** acorde a memoria del acelerador (KV cache ocupa VRAM por request activo).
- **Admission control / backpressure**: rechazar o degradar antes de colapsar TTFT; nunca cola infinita.
- **Prioridad de colas**: separar interactivo (bajo TTFT) de batch/offline (alto throughput).
- **Timeouts y cancelación**: cortar generaciones abandonadas para liberar KV cache.

## 5. Hardware y utilización

Neutralidad total: se mide y se elige por evidencia, no por marca.

| Cómputo | Fuerte en (p. ej.) | Señal de rendimiento |
|---------|--------------------|----------------------|
| **CPU** | Modelos pequeños, baja concurrencia, latencia predecible, borde | Coste/latencia aceptables sin acelerador |
| **GPU** | LLMs y deep learning con alto paralelismo | Ocupación de SMs, uso de VRAM |
| **TPU / aceleradores dedicados** | Cargas masivas específicas | Throughput por vatio y por $ |

- **Ocupación / utilización**: acelerador al 90% de VRAM pero 30% de cómputo = memory-bound (KV cache), no compute-bound → actuar sobre cache/batch, no sobre más FLOPs.
- **Memoria del acelerador**: pesos + KV cache + activaciones. La VRAM suele ser el límite de concurrencia en LLMs, no los FLOPs.
- **Roofline**: distinguir memory-bound de compute-bound antes de decidir la palanca. Perfilar (nsight-like/profilers del runtime) antes de optimizar. Fundamento del modelo roofline en [sistemas-hardware.md](sistemas-hardware.md) §1.

## 6. Optimización de modelo desde performance

peakformance especifica el objetivo de rendimiento y mide el impacto; la **aplicación y la validación de calidad** son de sysuniversal-ai (serving) y prisma (calidad del modelo). No se degrada precisión sin aprobación del dueño de calidad.

| Técnica | Efecto en rendimiento | Riesgo (dueño calidad: prisma/sysuniversal-ai) |
|---------|-----------------------|------------------------------------------------|
| **Cuantización** (p. ej. int8/int4/fp8) | Menos memoria y más throughput | Posible pérdida de precisión; validar |
| **Distilación** | Modelo más pequeño y rápido | Requiere reentrenar; brecha de calidad |
| **Pruning / sparsity** | Menos cómputo/memoria | Ganancia real depende de soporte de hardware |
| **Compilación / optimización de grafo** | Fusión y planificación estática | Coste de build; menos flexibilidad dinámica |
| **Fusión de kernels** | Menos overhead de lanzamiento y de memoria | Dependiente del runtime/acelerador |

Regla: toda técnica se acepta solo con **antes/después** de latencia y $/token **y** con la métrica de calidad del modelo estable (la firma prisma/sysuniversal-ai). Velocidad que rompe calidad no es una mejora.

## 7. Técnicas de serving para LLMs (nivel conceptual)

Palancas de rendimiento propias de LLMs; peakformance las prioriza y mide, sysuniversal-ai las implementa en el runtime elegido.

- **KV cache**: reutiliza claves/valores de tokens ya procesados; evita recomputar el prefix en cada token. Es el mayor consumidor de VRAM y el límite práctico de concurrencia.
- **Paged attention**: gestiona el KV cache en bloques (como memoria paginada); reduce fragmentación y permite más peticiones concurrentes por réplica.
- **Speculative decoding**: un modelo pequeño propone tokens que el grande verifica en bloque; sube tokens/seg cuando la tasa de aceptación es alta.
- **Prefix / prompt caching**: cachear el prefill de prompts de sistema o contextos repetidos reduce TTFT y $/token.
- **Modelo que no cabe en un acelerador**: cuando pesos/KV exceden una GPU se reparte — **tensor parallelism** (dividir cada capa entre GPUs, mucho *all-reduce*; es *bandwidth-bound* → preferir intra-nodo por NVLink), **pipeline parallelism** (etapas en GPUs distintas, tolera inter-nodo; cuidar las *burbujas*) o **sharding** de pesos. Se paga con un salto de red entre GPUs (colectivos *p. ej.* NCCL/RCCL/oneCCL sobre NVLink/Infinity Fabric/RDMA → [sistemas-hardware.md](sistemas-hardware.md)). sysuniversal-ai lo implementa; peakformance mide el trade-off latencia↔throughput↔utilización.
- **Disaggregation prefill/decode**: separar el *prefill* (compute-bound, en ráfaga) del *decode* (memory-bound, token a token) en pools distintos evita que uno ahogue al otro y permite escalar TTFT y throughput por separado.
- **MoE / expert-parallelism**: en modelos *mixture-of-experts* solo se activan algunos expertos por token; se reparten entre aceleradores, con el reto de **balanceo de carga** entre expertos y el *all-to-all* de enrutamiento.

Todas son conceptuales aquí: la elección y el tuning fino pertenecen al serving (sysuniversal-ai); peakformance fija el SLO y verifica la ganancia.

## 8. Autoscaling de acelerador y cold start

- **Autoscaling de inferencia (T1)**: escalar por métrica correcta — profundidad de cola, TTFT p99 o utilización del acelerador, no solo CPU/RPS.
- **Cold start**: cargar pesos a VRAM y calentar el runtime cuesta segundos–minutos. Mitigar con **réplicas mínimas calientes**, pools pre-aprovisionados, snapshots de estado o carga perezosa por capas.
- **Scale-to-zero**: solo donde el SLO tolera el cold start; para interactivo, mantener piso caliente.
- **Trade-off costo↔latencia**: aceleradores ociosos son caros; sobre-suscribir arriesga TTFT. Se dimensiona con datos → [infra-capacidad-costo.md](infra-capacidad-costo.md).

## 9. Costo por token / inferencia y $/throughput

El performance de IA se mide en tres ejes acoplados: **latencia, throughput y costo**. Optimizar uno sin mirar los otros es engañoso.

- **$/token y $/inferencia** como métrica de primera clase, con budget y gate (T1).
- **$/throughput**: costo por unidad de capacidad útil; batching y cuantización lo bajan, réplicas ociosas lo suben.
- Comparar **self-hosted vs API de proveedor** por evidencia de costo+latencia+control, no por moda. Detalle económico en [infra-capacidad-costo.md](infra-capacidad-costo.md).

## 10. Latencia de pipelines RAG y agénticos

La latencia extremo a extremo la domina la **orquestación**, no solo el modelo. Presupuesto de latencia por etapa.

```
# presupuesto ilustrativo de un turno RAG (ajustar por contexto)
recuperacion (vector/keyword):   <=  80 ms   # embedding query + búsqueda ANN → datos-performance.md
construccion de prompt:          <=  20 ms   # armado + truncado de contexto
inferencia (TTFT):               <= 400 ms   # prefill del contexto recuperado
generacion (decode):             stream      # gobernada por TPOT
red / overhead de orquestacion:  <=  50 ms
```

- **RAG**: la recuperación (ANN, filtro, rerank) y el tamaño de contexto inflado disparan prefill y $/token; recortar contexto irrelevante. Rendimiento del vector store en [datos-performance.md](datos-performance.md).
- **Agéntico**: cada salto (tool call, modelo, red) suma latencia serial; paralelizar herramientas independientes, cachear pasos deterministas y limitar profundidad de razonamiento.
- **Caché por capas (T1)**: **prompt cache** (prefill repetido), **embedding cache** (evitar re-embeder textos vistos), **caché semántica** (responder consultas suficientemente similares sin llamar al modelo). Cada nivel baja latencia y $/token; medir hit-rate.

## 11. Cómo medir

- **Carga representativa**: mezcla real de longitudes de entrada/salida y concurrencia; sintético reproducible para CI y campo para verdad → [medicion-observabilidad.md](medicion-observabilidad.md).
- Instrumentar TTFT, TPOT, tokens/seg, cola, utilización de acelerador y $/token por request; percentiles segmentados por modelo/ruta.
- Toda intervención se justifica con **antes/después** en p95/p99 **y** en $/token, con la métrica de calidad del modelo estable (prisma/sysuniversal-ai). Gates en pipeline → [performance-cicd.md](performance-cicd.md); carga sostenida → [pruebas-de-carga.md](pruebas-de-carga.md).

## 12. Checklist de inferencia performante

- [ ] Métricas de inferencia instrumentadas: TTFT, TPOT, tokens/seg, latencia p99, cola, $/token (T1).
- [ ] Carga representativa definida (mezcla de longitudes y concurrencia real), no prompt de juguete.
- [ ] Batching elegido por SLO (estático/dinámico/continuous) con `max_batch`/`max_wait` tuneados; padding controlado.
- [ ] Concurrencia y réplicas dimensionadas con Little's Law; backpressure/admission control activos; sin cola infinita.
- [ ] Hardware elegido por evidencia; diagnosticado memory-bound vs compute-bound; VRAM/KV cache monitorizados.
- [ ] Optimización de modelo (cuantización/distilación/pruning/compilación/fusión) validada en latencia+$ **y** en calidad (firma prisma/sysuniversal-ai).
- [ ] Técnicas de serving LLM (KV cache, paged attention, speculative decoding, prompt cache) priorizadas y verificadas.
- [ ] Autoscaling por métrica correcta (cola/TTFT/utilización); cold start mitigado; piso caliente para interactivo.
- [ ] $/token y $/inferencia con budget y gate; $/throughput comparado self-hosted vs API por evidencia.
- [ ] Pipeline RAG/agéntico con presupuesto de latencia por etapa; contexto recortado; herramientas paralelizadas.
- [ ] Caché de prompts/embeddings/semántica con hit-rate medido.
- [ ] Reparto tiered explícito: T1 peakformance (cross-cutting), T2 sysuniversal-ai (serving/MLOps), modelado en prisma.
- [ ] Antes/después documentado en p95/p99 y $/token; sin regresiones de calidad.

Ver también: [frontend-performance.md](frontend-performance.md) · [backend-performance.md](backend-performance.md) · [datos-performance.md](datos-performance.md) · [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) · [infra-capacidad-costo.md](infra-capacidad-costo.md) · [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md) · [sistemas-hardware.md](sistemas-hardware.md) · [tiempo-real-embebido.md](tiempo-real-embebido.md) · [plantillas.md](plantillas.md) · [ejemplos.md](ejemplos.md).
