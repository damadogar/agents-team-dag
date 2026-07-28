# Performance backend / servidor

Rendimiento del lado servidor, **agnóstico de lenguaje y runtime**: cómo un
servicio convierte trabajo en respuestas (latencia, throughput, concurrencia,
memoria, I/O, caché, serialización, resiliencia, diseño de API). Aplica a
**greenfield** (dimensionado predictivo desde el diseño) y **brownfield**
(perfilar y corregir lo existente). Nada se elige por moda: se mide, se
diagnostica el recurso saturado y se verifica antes/después bajo carga
representativa. Runtimes solo como **p. ej.** (JVM, .NET/CLR, Go, Node/V8,
Python, Rust…); la elección es del contexto y de `eneida`, no de este documento.

> **Reparto tiered (§9 SKILL):** peakformance **implementa directo (T1)** lo
> cross-cutting —caché distribuida, tuning de pools/GC/flags, perf harness,
> instrumentación—; el fix en la **lógica/servicio se entrega o co-implementa vía
> `motor`** (dueño del backend) como **T2**; acceso a datos profundo →
> **`andulfo`/`motor`** (ver [datos-performance.md](datos-performance.md)); **T3**
> fallback directo si el dueño no existe, marcado "pendiente de revisión".

Hermanos: [estrategia-performance.md](estrategia-performance.md) · [metodologia-diagnostico.md](metodologia-diagnostico.md) · [medicion-observabilidad.md](medicion-observabilidad.md) · [frontend-performance.md](frontend-performance.md) · [datos-performance.md](datos-performance.md) · [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) · [infra-capacidad-costo.md](infra-capacidad-costo.md) · [pruebas-de-carga.md](pruebas-de-carga.md) · [performance-cicd.md](performance-cicd.md) · [ia-ml-performance.md](ia-ml-performance.md) · [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md) · [sistemas-hardware.md](sistemas-hardware.md) · [tiempo-real-embebido.md](tiempo-real-embebido.md) · [plantillas.md](plantillas.md) · [ejemplos.md](ejemplos.md).

## 1. Latencia, throughput y concurrencia (Little's Law)

Tres variables acopladas; no se optimizan por separado:

```
L = λ · W    →   concurrencia = throughput (req/s) × latencia
L = peticiones en vuelo    λ = req/s    W = tiempo de respuesta
```

- Para sostener **λ** con **W** dado necesitas **L** concurrencia; si el sistema no
  la mantiene, se forma cola y **W** explota de forma no lineal al acercarse a la
  saturación (teoría de colas en [metodologia-diagnostico.md](metodologia-diagnostico.md)).
- Añadir concurrencia por encima del recurso saturado **no sube λ**: solo alarga
  colas y degrada p99 (Universal Scalability Law: contención y coherencia revierten
  la ganancia). No prometas escalado lineal.
- Bolsillo: si p99 se dispara con la CPU ociosa, el cuello **no es CPU** → I/O,
  locks, pool agotado o espera aguas abajo.

| Objetivo | Palanca dominante | Riesgo si se abusa |
|----------|-------------------|--------------------|
| Bajar p99 | menos trabajo/request, menos saltos, caché | staleness, complejidad |
| Subir throughput | concurrencia hasta el recurso saturado, batching | colas, memoria, tail |
| Estabilidad en pico | backpressure, límites, bulkheads | rechazo de carga (explícito) |

## 2. Modelos de concurrencia (neutral, por trade-off)

No hay modelo "mejor"; hay ajuste al perfil (CPU-bound vs I/O-bound).

| Modelo | p. ej. runtime | Fuerte en | Cuidado |
|--------|----------------|-----------|---------|
| Threads/pool bloqueante | JVM clásico, .NET sync | simple, CPU-bound | memoria/hilo, context-switch, no escala a C10k |
| Event loop / async-await | Node/V8, asyncio, .NET async | mucho I/O, poca memoria | un bloqueo o CPU pesada **congela** el loop |
| Coroutines / hilos ligeros | Go, virtual threads | I/O masivo estilo secuencial | scheduler+GC bajo presión, fugas |
| Actores / CSP | message-passing | aislamiento, estado sin locks | mailboxes crecen, backpressure explícito |

**No bloquees el hilo/loop equivocado** (separa pools CPU-bound de I/O-bound); lo
CPU-bound no se cura con más async; lo I/O-bound rara vez necesita más hilos que
conexiones. Verifica con profiling qué domina: **on-CPU vs off-CPU (espera)**.

## 3. Dimensionado de pools (por qué "más" no es mejor)

Connection y thread pools son **límites deliberados**, no cuellos a inflar sin
medir. Sobredimensionado traslada la cola al recurso escaso (BD, CPU) y empeora el
tail; pequeño serializa y sube W.

- **Punto de partida (Little's Law inverso):** `tamaño ≈ λ_objetivo · W_recurso`.
  BD a 5 ms y 2000 req/s → ~10 conexiones en media; margen para varianza, **no**
  cientos.
- Thread pool CPU-bound ≈ `nº núcleos (+1)`; I/O-bound mayor pero acotado por el
  recurso aguas abajo, no por optimismo.
- **El pool a BD casi nunca debe superar lo que la BD sostiene** (co-dimensiona con
  `andulfo`, ver [datos-performance.md](datos-performance.md)); más conexiones que
  núcleos de BD = contención pura.
- Instrumenta utilización, tiempo de adquisición, cola y rechazos.

```
Síntoma: latencia alta + CPU app ociosa + espera de adquisición alta
Causa probable: recurso downstream saturado → ampliar pool EMPEORA
Acción: optimizar la query/servicio downstream, no inflar el pool
```

## 4. Caché de servidor

Potente y peligrosa: introduce **coherencia** e **invalidación** como problemas
nuevos. Mide el hit ratio real bajo carga real; no la asumas gratis.

> **Fuente canónica compartida:** la taxonomía de estrategias (cache-aside/
> write-through/write-back), la invalidación y la mitigación de **stampede** son
> comunes a las tres capas; su detalle canónico vive en
> [datos-performance.md](datos-performance.md) §6, y la topología multinivel
> CDN/edge en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) §9.
> Esta sección se centra en el ángulo **servidor** (in-process vs distribuida,
> presión de GC).

| In-process (local) | Distribuida (store externo) |
|--------------------|------------------------------|
| latencia ns; capacidad = RAM del proceso (presiona GC) | latencia de red (sub-ms a ms); escalable |
| coherencia por instancia (diverge entre nodos) | estado compartido, sesiones, cross-service |

- **Cache-aside (lazy):** app puebla al fallar; simple, acceso frío + stampede.
- **Write-through:** caché+origen sincrónico; coherente, penaliza escritura.
- **Write-back:** difiere el origen; rápido, riesgo de pérdida y durabilidad.
- **Invalidación/TTL:** TTL + invalidación por evento; declara la ventana de
  staleness aceptable (decisión de negocio). Sin TTL, bugs silenciosos.

**Stampede / thundering herd** (muchas peticiones recomputan la misma clave al
expirar): single-flight/coalescing (1 recomputa, el resto espera), lock/lease por
clave, **TTL con jitter**, refresh anticipado del hot key, y
serve-stale-while-revalidate.

## 5. Memoria y garbage collection

- **La asignación cuesta:** menos objetos efímeros = menos presión de GC; reutiliza
  buffers/pools donde el profiling lo justifique (no antes).
- **Las pausas de GC dañan el tail (p99/p99.9), no la media.** En runtimes
  gestionados (p. ej. JVM, CLR, Go, V8) el tuning es elegir/afinar colector y heap
  para el objetivo (throughput vs latencia baja), **no** trucos mágicos.
- **T1:** flags de heap, colector, y límite de contenedor coherente con el heap (un
  límite por debajo del heap = OOM-kill). El **fix de asignación en la lógica**
  (evitar copias, streaming en vez de materializar) es **T2 vía `motor`**.
- No gestionados (p. ej. Rust, C/C++): sin GC, pero cuidado con fragmentación del
  allocator, copias y ownership costoso. La **elección/tuning del allocator**
  (p. ej. jemalloc/tcmalloc/mimalloc: arenas, *thread-caching*, tamaño de bin)
  reduce fragmentación y contención de asignación — palanca T1 de configuración.
- Fugas: heap monótono, colecciones que no liberan, caché sin cota → un soak test
  (ver [pruebas-de-carga.md](pruebas-de-carga.md)) las revela.

> Jerarquía de caché CPU, NUMA y concurrencia de bajo nivel (false sharing,
> atómicos/CAS, memory ordering) que afectan asignación y latencia de acceso:
> [sistemas-hardware.md](sistemas-hardware.md).

## 6. Serialización / deserialización

Cuello invisible: puede dominar la CPU en servicios "solo de I/O".

| Formato (p. ej.) | Perfil | Cuándo |
|------------------|--------|--------|
| Texto (JSON/XML) | legible, verboso, parse caro | APIs públicas, debug |
| Binario esquematizado (protobuf/avro/…) | compacto, rápido, requiere esquema | RPC interno, alto volumen |
| Columnar (parquet/…) | analítico, batch | datos, no request path |

Palancas: no serialices campos que nadie usa; **streaming** en vez de materializar;
reutiliza serializadores/buffers; mide el costo con profiling. El formato es
contrato con `eneida`/`motor`; el afinado de la ruta caliente es T2 vía `motor`.

**Zero-copy / access-in-place** (p. ej. FlatBuffers, Cap'n Proto, Arrow): leer
campos **sin deserializar** (acceso directo sobre el buffer, *mmap*-able) elimina
el costo de parse en RPC de alto volumen y en analítica en memoria; a cambio,
formato más rígido y mayor tamaño en reposo. Se elige por el ratio
parse/transferencia **medido**. No confundir con el **zero-copy de I/O de kernel**
(sendfile/splice → [sistemas-hardware.md](sistemas-hardware.md)): aquí se evita el
*parse*, allá la copia user↔kernel. Coste propio: validar punteros del buffer y
peor localidad de caché en acceso aleatorio.

## 7. I/O, syscalls, batching y buffering

- **Cada syscall/round-trip cuesta:** agrupa (batching de escrituras, lecturas en
  bloque, pipelining donde el protocolo lo permita).
- **Buffering** amortiza el costo fijo por operación; dimensiona al patrón (grande =
  latencia y memoria; pequeño = overhead).
- **N round-trips secuenciales** aguas abajo es un antipatrón: paraleliza lo
  independiente, agrupa lo relacionado; reutiliza conexiones (keep-alive/pools) en
  vez de abrir/cerrar por request.

> I/O de alto rendimiento a nivel de kernel (anillos/io_uring, zero-copy,
> kernel-bypass) y su reparto tiered: [sistemas-hardware.md](sistemas-hardware.md).

## 8. Problema N+1 y acceso a datos

El **N+1** (una consulta + N por cada fila) es de los cuellos más frecuentes y
baratos de arreglar: convierte N+1 round-trips en 1–2 (batch, join o carga
anticipada). Aplica a BD, cachés remotas y llamadas a servicios. El diagnóstico
profundo de consultas, índices y planes vive en
[datos-performance.md](datos-performance.md) y se corrige **vía `andulfo`/`motor`**
(T2); peakformance lo detecta por tracing, cuantifica impacto y entrega el fix medido.

## 9. Resiliencia con impacto en performance

Mal calibrada, **degrada** el performance en vez de protegerlo:

| Mecanismo | Bien usado | Antipatrón |
|-----------|-----------|-----------|
| **Timeouts** | budget por salto < timeout del cliente | ausentes o mayores que el del llamador |
| **Retries** | **backoff exponencial + jitter**, idempotentes, con tope | amplifican carga → retry storm |
| **Circuit breaker** | corta rápido si el downstream cae; libera recursos | umbral mal fijado, oscila |
| **Bulkhead** | aísla pools por dependencia | pool compartido → fallo en cascada |

**Timeout budget** de extremo a extremo repartido por salto: sin timeouts, un
downstream lento agota tus pools y tumba el servicio; retries sin jitter sincronizan
clientes y crean picos. Diseño con `motor`/`eneida`; los defaults/budgets
transversales son T1.

## 10. Diseño de API para performance

- **Paginación** siempre (cursor > offset a gran volumen); nunca conjuntos no acotados.
- **Payload mínimo:** solo campos necesarios (sparse fieldsets/GraphQL); evita over-fetching.
- **Compresión** cuando el tamaño lo justifique (CPU vs red).
- **N+1 en GraphQL:** el resolver ingenuo lo dispara; mitiga con batching/dataloader
  (coalescing por request) — el §8 en la capa API.
- **gRPC / streaming:** para alto volumen o payloads grandes, evita materializar en
  memoria y reduce latencia percibida; binario esquematizado baja el costo del §6.
- **Coherencia con el cliente:** coordina con
  [frontend-performance.md](frontend-performance.md) y `farola` — un payload
  "eficiente" que obliga al cliente a N llamadas no es eficiente de extremo a extremo.

## 11. Colas y trabajo asíncrono

Sacar de la ruta de request lo que no debe responder síncrono (correos, reportes,
side-effects) baja p99 y desacopla picos. Diseño de colas, backpressure,
particionado, entrega y escalado de consumidores →
**[distribuidos-escalabilidad.md](distribuidos-escalabilidad.md)**. Regla: **si el
usuario no necesita el resultado ahora, no lo hagas en la ruta caliente**; acepta,
responde rápido y procesa async con límites y observabilidad.

## 12. Compilación y runtime: JIT, warmup, PGO/LTO, inlining

Palanca frecuentemente olvidada: cómo el runtime **ejecuta** el mismo código.
No asumas que un build "release" ya es óptimo; **mide antes/después** y en
**percentiles**, no promedios. Aplica a **greenfield** (fijar flags y estrategia
desde el diseño) y **brownfield** (recuperar rendimiento sin tocar la lógica).

- **JIT vs AOT.** Runtimes con **JIT por niveles (tiered)** calientan gradualmente
  (interpretado → optimizado): p. ej. JVM, .NET/CLR. Implicaciones:
  - **Warmup:** los primeros requests son lentos → **daña p99 tras deploy o
    escalado**; conéctalo con el **cold start** de autoscaling (ver
    [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) §11).
  - **Deoptimizaciones** (el runtime revierte código optimizado ante supuestos
    rotos) y **code cache** limitado que puede llenarse y frenar la optimización.
  - **AOT** (p. ej. Go, Rust, C++) elimina el warmup a costa de **menos
    especialización** en tiempo de ejecución. Ni JIT ni AOT es "mejor": es
    trade-off según perfil de despliegue, arranque y forma de la carga.
- **PGO (profile-guided optimization):** compilar con **perfiles reales** para
  ordenar código caliente/frío y guiar inlining y *branch layout*; ganancias
  típicas medibles. Integra la captura de perfiles en el pipeline.
- **LTO (link-time optimization) e inlining:** eliminan límites de unidad de
  compilación y habilitan optimización entre módulos; trade-off en **tamaño y
  tiempo de build** frente a velocidad de ejecución.
- **Flags de optimización:** trátalos como cambio con hipótesis y **verifícalos
  antes/después** bajo carga representativa; documenta el delta.

> **Reparto tiered.** **T1** peakformance: flags de compilación/runtime,
> estrategia de **warmup/pre-calentamiento** (p. ej. tráfico sintético o rutas
> críticas antes de recibir carga) y **PGO en el pipeline** (ver
> [performance-cicd.md](performance-cicd.md)). **T2 vía `motor`:** cambios en el
> código que habilitan **inlining/monomorfización** (evitar megamorfismo, fijar
> tipos, reducir indirecciones) sin cambiar la semántica.

## 13. Checklist de cierre — backend

```
- [ ] ¿Latencia en PERCENTILES (p50/p95/p99/p99.9), no promedios, bajo carga representativa?
- [ ] ¿Recurso saturado identificado (CPU on/off, memoria/GC, I/O, locks, pool, downstream)?
- [ ] ¿Modelo de concurrencia acorde al perfil (CPU-bound vs I/O-bound)?
- [ ] ¿Pools dimensionados por Little's Law y el recurso downstream, no por "más es mejor"?
- [ ] ¿Caché con hit ratio medido, TTL/invalidación y mitigación de stampede?
- [ ] ¿Presión de GC/asignación revisada y límite-de-contenedor coherente con el heap?
- [ ] ¿Serialización no domina la CPU? ¿Streaming donde aplica?
- [ ] ¿Eliminados N round-trips (batching/buffering) y el N+1 (API y datos)?
- [ ] ¿Timeouts con budget, retries con backoff+jitter idempotentes, breakers y bulkheads?
- [ ] ¿API con paginación, payload mínimo, compresión y sin N+1 en GraphQL?
- [ ] ¿Movido a async lo que no requiere respuesta síncrona?
- [ ] ¿Flags de compilación/runtime verificados antes/después, warmup/PGO gestionados y warmup ligado al cold start?
- [ ] ¿Verificado ANTES/DESPUÉS y protegido con perf gate (performance-cicd.md)?
- [ ] ¿Reparto tiered claro: T1 propio vs T2/T3 entregado vía motor/andulfo?
```

peakformance firma el diagnóstico y la corrección; el código de servicio es de
`motor` y los datos de `andulfo` — se corrige **con** ellos, no por encima de ellos.
