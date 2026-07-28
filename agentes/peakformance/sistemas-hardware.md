# Sistemas y Hardware — Mechanical Sympathy

La capa donde un experto real se separa del resto. Aquí no se optimiza "código": se optimiza cómo ese código conversa con silicio, memoria, kernel y cable. Regla madre: **medir, no adivinar**; **percentiles, no promedios**; **antes/después con evidencia**. Todo cuantificado en ciclos, bytes, RTT y vatios. Neutralidad total: x86/ARM, Linux/otros, perf/eBPF/VTune son *p. ej.*; se eligen por contexto y medición, jamás por moda.

Marcos operativos: **USE** (Brendan Gregg: Utilization/Saturation/Errors por recurso), **mechanical sympathy** (diseñar sabiendo cómo funciona la máquina), **roofline model** (techo de cómputo vs. de memoria) y **Little's Law** (L = λ·W). Cruces con [metodologia-diagnostico.md](metodologia-diagnostico.md) y [medicion-observabilidad.md](medicion-observabilidad.md).

## 1. Jerarquía de memoria — el 90% del rendimiento silencioso

La CPU no espera "un poco" por RAM: espera **~200-300 ciclos** por un fallo a memoria principal. La latencia es la nueva unidad de trabajo.

| Nivel | Latencia aprox. | Orden de magnitud |
|---|---|---|
| Registro / L1 | ~1-4 ciclos | ~1 ns |
| L2 | ~10-14 ciclos | ~4 ns |
| L3 (compartida) | ~40-75 ciclos | ~15-40 ns |
| RAM (DRAM) | ~200-300 ciclos | ~80-120 ns |
| RAM remota (NUMA) | +50-100% sobre local | ~130-200 ns |

Conceptos que gobiernan esto:
- **Línea de caché (~64 B)**: la unidad real de transferencia. No lees un `int`, traes 64 B. El **layout de datos** decide cuántas líneas tocas.
- **Localidad temporal/espacial**: reusar pronto (temporal) y recorrer contiguo (espacial). Un `array of structs` vs. `struct of arrays` (SoA) puede cambiar el throughput 3-10×.
- **Prefetching**: el HW predice patrones lineales; accesos por puntero/aleatorios lo derrotan → *pointer chasing* es veneno. El **prefetch software** (hints explícitos) ayuda en accesos predecibles-pero-no-lineales; medir, no rociar.
- **Predicción de saltos**: una *misprediction* vacía el pipeline (~15-20 ciclos). Donde los *branch-misses* (PMU, §6) dominen, ordena datos para ramas predecibles o usa **branchless** (tablas de lookup, movimientos condicionales/predicación).
- **Ancho de banda de memoria**: recurso finito y compartido entre cores. Saturarlo hace inútil añadir hilos.

**Memory-bound vs compute-bound** y **roofline**: se sitúa el kernel en (intensidad aritmética = FLOP/byte) vs. rendimiento alcanzable. Si estás bajo la recta inclinada, te limita el **ancho de banda** (optimiza layout/reuso/blocking); si estás bajo el techo plano, te limita el **cómputo** (vectorización/ILP). Aplicación directa a inferencia y kernels numéricos en [ia-ml-performance.md](ia-ml-performance.md).

```
perf: contar la evidencia, no suponerla
  LLC-load-misses, cache-misses, cycles, instructions → IPC
  IPC bajo + miss alto ⇒ memory-bound ⇒ atacar LAYOUT, no CPU
```

## 2. NUMA — la memoria tiene geografía

En sistemas multi-socket, cada core tiene memoria "cerca" (local) y "lejos" (remota, vía interconexión). Acceso remoto: **+50-100% de latencia** y ancho de banda compartido en el enlace.

- **First-touch**: la página se asigna físicamente en el nodo del hilo que la *escribe primero*, no del que la reserva. Inicializar en el hilo equivocado condena el acceso a remoto de por vida.
- **Colocación**: fijar (pin) el hilo y su memoria al mismo nodo; particionar datos por nodo; usar un **allocator consciente de NUMA** (arenas por nodo) donde el runtime lo permita.
- **Diagnóstico**: contadores de accesos remotos, herramientas de topología (*p. ej.* mapear nodos y distancias). Síntoma clásico: escala hasta N cores y colapsa al cruzar de socket.

## 3. TLB, huge pages, page faults, swapping

La traducción virtual→física también cachea (TLB). Un *TLB miss* añade un *page walk*.
- **Huge pages** (*p. ej.* 2 MB/1 GB): menos entradas TLB para el mismo espacio ⇒ menos misses; útil en heaps grandes, bases de datos, buffers de red. Ojo con fragmentación y THP que introduce jitter (mejor páginas explícitas en cargas de baja latencia).
- **Page faults**: *minor* (mapeo sin I/O, barato) vs. **major** (requiere disco, milisegundos — catastrófico en la ruta caliente).
- **Swapping**: para latencia predecible suele ser enemigo; en sistemas críticos se controla o desactiva y se dimensiona RAM (ver [infra-capacidad-costo.md](infra-capacidad-costo.md)).

## 4. Concurrencia de bajo nivel — donde los promedios mienten

- **False sharing**: dos hilos escriben variables distintas que caen en la **misma línea de caché** → el protocolo de coherencia rebota la línea entre cores (ping-pong). Cura: **padding/alineación a 64 B** para separar campos calientes por hilo.
- **Atómicos / CAS**: un CAS bajo contención serializa; el coste no es la instrucción sino la **coherencia de línea**. La contención sobre una sola línea no escala aunque sea "lock-free".
- **Lock-free / wait-free**: eliminan bloqueos, no la contención de memoria. Valen cuando reducen líneas disputadas; medir, no asumir superioridad.
- **Reclamación segura** (la parte difícil del lock-free): liberar memoria sin que otro hilo la lea a medio-uso. Patrones (p. ej.): **RCU** (lecturas casi gratis, coste en la reclamación diferida), **hazard pointers** (marcas lo que lees), **seqlock** (el lector reintenta si el escritor pasó). Se elige por ratio lectura/escritura; medir.
- **Memory ordering / barreras**: *acquire/release* para publicar-consumir; *seq-cst* es el más caro (evítalo si no lo necesitas). El orden incorrecto es un bug, el orden excesivo es un impuesto de rendimiento.
- **Striped / sharded counters**: un contador global caliente se reparte en N líneas independientes (una por core/shard) y se agrega al leer → convierte contención en paralelismo.
- **Priority inversion** y **contención de línea**: vigilar hilos de baja prioridad reteniendo recursos de los críticos.

```
Contador global caliente  ⇒  reparte por shard
  cnt[core_id % N].value.fetch_add(1, relaxed)   // cada shard en su línea (padding 64B)
  total = Σ cnt[i].value                          // solo al leer
```

Este es territorio **T2**: el rediseño de estructuras (SoA, lock-free, sharding, algoritmos) es cambio en **código de dominio** → se entrega/co-implementa vía **motor** (backend) / **andulfo** (datos). Ver [backend-performance.md](backend-performance.md) y [datos-performance.md](datos-performance.md).

## 5. Sistema operativo y CPU

- **Context switches**: cada uno cuesta ciclos + contamina cachés/TLB. Exceso ⇒ demasiados hilos o I/O mal modelado.
- **Scheduler / affinity**: fijar hilos calientes a cores (**CPU affinity/pinning**) reduce migraciones y warm-up de caché.
- **CPU isolation** (*p. ej.* aislar cores del scheduler general) para cargas de latencia determinista.
- **IRQ affinity**: repartir/aislar interrupciones para que la NIC no golpee el core crítico.
- **DVFS / turbo**: el escalado de frecuencia introduce **jitter**; para benchmarks y baja latencia, fijar gobernador de rendimiento. Warm-up antes de medir.
- **Hyperthreading (SMT)**: dos hilos compartiendo recursos de un core físico; ayuda a cargas con stalls de memoria, perjudica a cargas compute-bound o sensibles a jitter. Decidir por medición.

Estos ajustes (pinning, isolation, IRQ, huge pages, DVFS, sysctl/kernel flags, tuning de NIC) son **cross-cutting = T1**: los implementa **peakformance** directamente, coordinando con **eneida** (arquitectura/plataforma).

## 6. Observabilidad a nivel kernel/hardware

- **PMU / perf**: contadores de rendimiento del silicio — ciclos, instrucciones (IPC), misses de caché/TLB, branch misses, stalls por frontend/backend. La verdad numérica de por qué el core espera.
- **eBPF**: instrumentación dinámica de kernel con overhead mínimo — latencia de syscalls, I/O, scheduler, red, sin recompilar ni reiniciar.
- **Flame graphs de kernel** y **off-CPU analysis**: on-CPU muestra dónde se quema CPU; **off-CPU** muestra dónde el hilo *espera* (locks, I/O, scheduler) — a menudo la causa real de la cola p99. Método en [metodologia-diagnostico.md](metodologia-diagnostico.md) y correlación en [medicion-observabilidad.md](medicion-observabilidad.md).

## 7. Red: transporte y físico

- **Latencia física**: la velocidad de la luz en fibra impone un **suelo irreducible** (~5 µs/km ida ⇒ intercontinental = decenas de ms de RTT). Ninguna optimización lo rompe: se ataca con **geografía** (edge/CDN/réplicas), no con código. Ver [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).
- **TCP**: *three-way handshake* (1 RTT antes del primer byte), **slow-start** (la ventana crece gradual: conexiones cortas nunca alcanzan el ancho pleno), **congestion control** (los modernos como **BBR** modelan ancho de banda de cuello (*BtlBw*) y RTT mínimo (*RTprop*) en vez de reaccionar a la pérdida como CUBIC/Reno — mejor en enlaces con pérdida no-congestiva; **BBRv1** puede ser injusto frente a CUBIC y sobre-encolar, atenuado en **v2/v3**; en cloud gestionado puede no estar bajo tu control), y **BDP** (bandwidth-delay product = ancho × RTT) que fija el tamaño de ventana necesario para saturar el enlace. **Nagle** puede añadir latencia en mensajes pequeños interactivos.
- **TLS**: el handshake añade RTTs y **coste asimétrico** (clave pública) al inicio; mitigadores: **1-RTT/0-RTT**, **session resumption**, y **AES-NI** que hace el cifrado simétrico casi gratis (el asimétrico del handshake es lo caro, no el bulk).
- **Head-of-line blocking**: en HTTP/2 sobre TCP, una pérdida bloquea todos los streams del socket. **HTTP/3 / QUIC** mueve el transporte a UDP con streams independientes y 0/1-RTT ⇒ elimina el HOL de transporte. Elegir por RTT/pérdida reales del canal, no por versión "más nueva". Ver [frontend-performance.md](frontend-performance.md).

| Palanca | Ataca | Suelo |
|---|---|---|
| Geografía / edge | RTT físico | velocidad de la luz |
| Keep-alive / resumption | handshakes repetidos | 1 RTT (o 0-RTT) |
| Ventana / BDP tuning | throughput en enlaces gordos | ancho × RTT |
| HTTP/3 / QUIC | HOL de transporte | pérdida del canal |

## 8. Coste de performance de la seguridad

La seguridad **no es gratis y no es opcional**: se **mide y se presupuesta**, no se elimina.
- **Cifrado**: con **AES-NI**, el simétrico (bulk) es marginal; el peso está en el **asimétrico del handshake TLS** → amortizar con resumption/keep-alive.
- **mTLS**: duplica verificación de certificados por conexión; reusar conexiones y session tickets.
- **WAF / inspección profunda**: añade latencia y CPU en la ruta caliente; medir su p99 aislado.

peakformance **cuantifica** ese coste (µs y CPU por request) y lo mete en el **performance budget**, pero **no invade seguridad**: **coordina con destroyer**. Se optimiza el *cómo* (reuso, AES-NI, ubicación del terminador TLS), nunca se debilita el *qué*.

## Reparto TIERED (explícito)

| Tier | Qué | Quién |
|---|---|---|
| **T1** | Cross-cutting que *es* performance: pinning/affinity, huge pages, flags de kernel/sysctl, tuning de NIC/IRQ, isolcpus, DVFS, instrumentación PMU/eBPF, tuning TCP/TLS | **peakformance** implementa directo |
| **T2** | Cambio en código de dominio: layout data-oriented (SoA), estructuras lock-free/sharded, algoritmos, memory ordering | entrega/co-implementa vía **motor** / **andulfo**; coordina **eneida** (arquitectura/plataforma) |
| **T3** | Fallback: si el dueño no puede, peakformance implementa el fix medido y lo integra con revisión del dueño | peakformance con handoff documentado |

Seguridad → **destroyer**. Frontend/cliente → **farola** / **uxuifull**. IA/inferencia → **sysuniversal-ai**. QA de no-funcionales → **amado**. Interfaces y handoffs en [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md).

> **Entornos gestionados (cloud/serverless/contenedor sin privilegios).** Cuando **no controlas el kernel**, buena parte del T1 de kernel (isolcpus, sysctl, IRQ affinity, huge pages, DVFS, eBPF, io_uring/DPDK, RDMA/RoCE) **no está disponible** y **se degrada** a: elegir familia/tamaño de instancia, imagen base optimizada y petición al proveedor. Lo que **sí sigue aplicando** universalmente es el nivel de aplicación: layout data-oriented (SoA), complejidad algorítmica, evitar false sharing y diseño de I/O concurrente. Contexto gestionado también en [datos-performance.md](datos-performance.md) §7 e [infra-capacidad-costo.md](infra-capacidad-costo.md).

## Greenfield vs. Brownfield

**Greenfield** (diseñar con mechanical sympathy desde el día 0):
- Elegir layout **data-oriented** (SoA, contiguidad, alineación a línea) antes de escribir el hot path.
- Topología NUMA y estrategia de first-touch/pinning en el diseño, no como parche.
- Presupuestar RTT (geografía/edge) y coste TLS/seguridad desde la arquitectura.
- Instrumentación PMU/eBPF y perf gates conectados a [performance-cicd.md](performance-cicd.md) desde el inicio.
- Elegir **modelo de I/O concurrente** (anillos vs readiness) y **layout vectorizable** (SoA para SIMD) desde el diseño.

**Brownfield** (perfilar lo existente, evidencia primero):
1. USE por recurso → localizar el cuello (CPU, memoria-BW, red, I/O).
2. `perf`/PMU → IPC y misses: distinguir memory-bound de compute-bound.
3. Buscar **false sharing** (líneas rebotando), **accesos NUMA remotos**, **TLB misses**, **off-CPU** (esperas ocultas).
4. Medir baseline en percentiles → aplicar T1 (tuning) y proponer T2 (rediseño de layout/estructuras) con antes/después cuantificado.
5. Perfilar el **cruce de kernel/syscalls** (off-CPU) y evaluar **SIMD** en el hot path compute-bound.
6. Nunca "optimizar" sin flame graph + contadores que lo justifiquen.

Estrategia y gobernanza en [estrategia-performance.md](estrategia-performance.md); validación bajo carga en [pruebas-de-carga.md](pruebas-de-carga.md); plantillas y casos en [plantillas.md](plantillas.md) y [ejemplos.md](ejemplos.md).

## SIMD y vectorización

Paralelismo de datos a nivel de instrucción: una sola instrucción opera sobre un vector de N elementos. Es la palanca cuando el kernel es **compute-bound** bajo el techo plano del roofline (ver §1); si estás **memory-bound**, primero arregla layout/ancho de banda o el vector solo esperará a la DRAM.

Dos caminos, se eligen por perfil y target (SIMD/AVX/NEON/SVE solo como *p. ej.*):
- **Auto-vectorización del compilador**: gratis si el bucle es "amigable" (contiguo, sin dependencias, conteo conocido, sin llamadas). Frágil: un puntero *aliasing* o un `if` la desactiva en silencio. Verificar con reportes de vectorización y contadores, no asumir.
- **Intrínsecos / bibliotecas**: control explícito cuando el compilador no llega; más rápido pero acoplado al ISA y difícil de portar. Preferir bibliotecas vectorizadas antes que intrínsecos a mano si existen.

Habilitadores estructurales:
- **Alineación de datos**: cargas/almacenes alineados al ancho del vector evitan penalizaciones o *faults*; desalineado obliga a *loads* partidos. Alinear buffers al ancho del registro.
- **SoA como habilitador**: `struct of arrays` deja cada campo contiguo → carga vectorial directa y sin *gather*. El mismo layout data-oriented de §1 (localidad) es el que habilita SIMD. Con AoS el compilador casi nunca vectoriza bien.
- **Gather/scatter**: leer/escribir por índices dispersos existe pero **cuesta** (múltiples líneas de caché, latencia alta); un *gather* puede anular la ganancia vectorial. Mídelo: a veces reordenar datos a contiguo gana más que vectorizar el acceso disperso.

**Cuándo NO ayuda**: control-flow divergente (ramas por elemento → *masking* que desperdicia carriles), dependencias entre iteraciones (*loop-carried*), o baja aritmética por byte (pocos FLOP/byte → memory-bound, ver roofline §1). En esos casos el vector espera y no acelera.

```
apto para SIMD          NO apto (revisar antes)
  bucle contiguo          gather/scatter dominante
  sin dependencias        dependencia iteración-a-iteración
  alta intensidad (FLOP/B) ramas divergentes por elemento
  SoA, alineado           AoS, desalineado
```

Los kernels numéricos e inferencia viven de esto: cruza con [ia-ml-performance.md](ia-ml-performance.md). El rediseño a SoA/alineación es **T2** (código de dominio, vía **motor** / **andulfo**); el perfilado y la decisión de ISA/flags de compilación son **T1** (peakformance).

## I/O moderno de alto rendimiento (io_uring, zero-copy, kernel-bypass)

En servidores de alta carga (no solo trading: proxies, bases de datos, streaming, almacenamiento) el cuello deja de ser el disco/red y pasa a ser el **coste del kernel**: syscalls, cambios de modo, copias user↔kernel. (La **física del medio de almacenamiento** —NAND, write amplification, `fsync`— vive en [datos-performance.md](datos-performance.md).) Se ataca reduciendo copias y amortizando el cruce al kernel. Medir siempre en **percentiles**, el promedio esconde la cola de syscall.

- **Modelo de anillos vs readiness**: la interfaz *readiness* (*p. ej.* epoll/kqueue) avisa "ya puedes leer" y aún exiges una syscall por operación; el modelo de **anillos de envío/compleción** (*p. ej.* io_uring) encola operaciones y recoge resultados en memoria compartida, con **batching** de muchas I/O por syscall (o cero, en modo *polled*). Menos transiciones = menos overhead por operación a alto QPS.
- **Zero-copy**: evitar la copia intermedia a espacio de usuario cuando el byte solo transita (*p. ej.* sendfile/splice para fichero→socket, o *scatter-gather* / `writev` para juntar fragmentos sin copiarlos). Sirve cuando no transformas el dato; si lo inspeccionas/comprimes, la copia ya está pagada.
- **Kernel-bypass / user-space networking** (*p. ej.* DPDK, o *busy-poll* en la pila estándar): cuando la propia pila del SO es el cuello, se saca del camino y la NIC habla casi directo con user-space. Coste: **CPU dedicada a poll** (quema un core al 100%), complejidad y pérdida de las abstracciones del SO.
- **RDMA / DMA / GPUDirect** (*p. ej.* RoCE/RoCEv2, InfiniBand, iWARP): acceso directo a memoria remota **sin CPU** del host destino ni copias de kernel — latencia ultra-baja para HPC, storage distribuido y **colectivos GPU-GPU** (*p. ej.* GPUDirect RDMA/P2P; NCCL/RCCL/oneCCL). Exige **fabric lossless** (PFC en RoCEv2), **registro/pinning de memoria** y distingue *verbs* **one-sided** (RDMA read/write puro) **vs two-sided** (send/recv). Nicho: se justifica solo si la copia/CPU de red es el cuello **medido**. En inferencia, el T2 del caso **multi-GPU** es de **sysuniversal-ai** (→ [ia-ml-performance.md](ia-ml-performance.md) §7).
- **Batching de syscalls**: agrupar operaciones (envíos, *timeouts*, *reads*) reduce el número de cruces; clave a alto throughput.

| Mecanismo | Ataca | Trade-off |
|---|---|---|
| Anillos envío/compleción (*p. ej.* io_uring) | syscalls por op | complejidad, portabilidad/versión de kernel |
| Zero-copy (sendfile/splice, scatter-gather) | copias user↔kernel | solo si no transformas el dato |
| Kernel-bypass (*p. ej.* DPDK, busy-poll) | pila del SO como cuello | CPU dedicada, portabilidad, sin abstracciones SO |
| RDMA/DMA (*p. ej.* RoCE, InfiniBand) | copia y CPU de red | requiere tejido/NIC compatible; nicho HPC/GPU |
| Batching de syscalls | frecuencia de cruce | latencia de agrupado vs throughput |

Reparto **TIERED**: la elección del mecanismo de I/O, el *tuning* y el *benchmarking* comparativo son **T1** (peakformance implementa/mide directo); el cambio en el código del servicio para usar la API elegida es **T2**, vía **motor**. Enlaza [backend-performance.md](backend-performance.md) §7 (I/O/syscalls/batching) y [tiempo-real-embebido.md](tiempo-real-embebido.md) (kernel-bypass en baja latencia). Se elige por perfil y target, nunca por moda.

## Checklist de sistemas y hardware

- [ ] Hot path perfilado con PMU: IPC, cache-misses, TLB-misses, branch-misses medidos (no supuestos).
- [ ] Clasificado memory-bound vs compute-bound vía roofline; optimización acorde.
- [ ] Layout de datos revisado: contigüidad, SoA donde aplica, structs alineados/padded a 64 B.
- [ ] **False sharing** descartado en contadores/campos calientes multi-hilo.
- [ ] Topología **NUMA** conocida; first-touch correcto; hilos y memoria pinneados al nodo.
- [ ] **Huge pages** evaluadas para heaps/buffers grandes; sin *major page faults* en ruta caliente; swap controlado.
- [ ] Affinity/isolation/IRQ affinity aplicados en cargas de latencia determinista; DVFS/turbo fijado para medir.
- [ ] SMT/hyperthreading decidido por medición (ayuda o estorba según la carga).
- [ ] Contención de atómicos/locks medida; memory ordering mínimo suficiente (no seq-cst por inercia).
- [ ] **off-CPU analysis** hecho: esperas ocultas (lock/I/O/scheduler) cuantificadas.
- [ ] Red: RTT físico presupuestado (edge/geografía); slow-start/keep-alive/BDP considerados; Nagle evaluado.
- [ ] TLS: resumption/0-1-RTT y AES-NI activos; coste asimétrico amortizado.
- [ ] HTTP/2 vs HTTP/3/QUIC elegido por pérdida/RTT reales del canal, no por versión.
- [ ] **Coste de seguridad medido y presupuestado** (TLS/mTLS/WAF); coordinado con **destroyer**, sin debilitar controles.
- [ ] **SIMD**: hot path compute-bound evaluado para vectorización; auto-vectorización verificada (no supuesta); datos en SoA y alineados al ancho de vector; gather/scatter medido antes de confiar en él.
- [ ] **I/O moderno**: mecanismo elegido por perfil (anillos vs readiness, zero-copy donde el dato solo transita, kernel-bypass solo si la pila del SO es el cuello); batching de syscalls y coste de CPU dedicada presupuestados.
- [ ] Reparto TIERED explícito: T1 implementado por peakformance; T2 acordado con motor/andulfo/eneida (arquitectura/plataforma).
- [ ] Toda mejora reportada en **percentiles, antes/después**, con la evidencia (flame graph + contadores) adjunta.
