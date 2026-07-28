# Changelog — peakformance (Primer Maestro de Performance Engineering)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.4.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `interoperabilidad-y-aliadas.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.3.3] — 2026-07-12

### Added
- frontera explícita con **`baluarte`** en `interoperabilidad-y-aliadas.md` (§5
  protocolo de invocación cruzada y §9 límites de rol): *meta de rendimiento =
  peakformance; operación de la plataforma que la sostiene (disponibilidad/SLO,
  autoscaling, capacidad operada, CDN/edge, IaC de plataforma, FinOps operacional)
  = baluarte*. Añadida también fila **`certero`** (revisión de correctitud de los
  parches de optimización).

### Added (cierre QA-3)
- Añadida cláusula de invocación standalone (con fallback T3).

### Notas
- sin cambio de objetivo (dueño del performance); cierra solapamiento SRE detectado
  en la auditoría (2026-07-12).

## [1.3.2] — 2026-07-11

### Added — cross-link al nuevo agente mobile `palma`
- Se crea **`palma`** (Ingeniería Mobile). peakformance sigue siendo **dueño integral
  del performance** (incluida la app móvil nativa/cross-platform: budgets, estrategia,
  profiling on-device); `palma` conserva la **implementación performante como craft** y
  respeta esos budgets. Añadido `palma` a la tabla **Tier 2** (§3) y a la de **invocación
  cruzada** (§5): peakformance entrega budget mobile (TTID/TTFD, ANR, frame) y hallazgos
  de profiling; `palma` implementa el craft on-device. Sin cambios en el ownership ni en
  las demás relaciones de peakformance.

## [1.3.1] — 2026-07-08

### Fixed / Added — 5ª ronda de QA (5 revisores; modelo tiered verificado INTACTO)
La 5ª auditoría confirmó el **modelo tiered intacto** (audita Y corrige; T1/T2/T3 consistente en SKILL §9, interop §3, §2.1 y los 16 satélites), el nivel mundial y la conformidad con el equipo. Solo restaban pulidos BAJOS, ahora cerrados:

- **Lote J (coherencia/relaciones):** pseudo-enlaces `[farola]/[motor]/[andulfo]` → code-spans en `performance-cicd`; footer de `datos` ahora incluye `metodologia`; el bullet RDMA de `sistemas-hardware` aclara que el T2 del caso **multi-GPU** es de `sysuniversal-ai` (+ back-link a `ia-ml §7`); **compresión con etiqueta de tier** (motor→andulfo T2 / transporte→T1); celda "NO hace" de §2.1 con **excepción T3**; nota de desambiguación **zero-copy de serialización vs de kernel** en `backend §6`; cadencia de gobernanza "mensual"→"ventana 28 días"; `SKILL §9` T2 añade `eneida` (arquitectura full-system); índice §0 anuncia §2.1; `RDMA/RoCE` añadido a la lista de "degradado en cloud gestionado"; colectivos GPU con "p. ej." (NCCL/RCCL/oneCCL; NVLink/Infinity Fabric).
- **Lote K (profundidad de frontera):** **encodings columnares ligeros** (RLE/delta/dictionary/bit-packing/frame-of-reference) en `datos`; **profundidad de RDMA** (fabric lossless/PFC en RoCEv2, registro/pinning, *verbs* one-sided vs two-sided, variantes GPUDirect); **profundidad de BBR** (modelo BtlBw/RTprop, v2/v3, fairness); **frontera LLM 2024** (disaggregation prefill/decode, MoE/expert-parallelism) en `ia-ml`.

Verificado: 16 satélites, todos los enlaces cruzados resuelven, sin pseudo-enlaces, sin agente fantasma, sin frontmatter en satélites, sin sesgo.

## [1.3.0] — 2026-07-08

### Fixed / Added — 4ª ronda de QA (5 revisores, incl. conformidad con el equipo enterprise)
Auditoría contra el patrón del equipo (eneida/farola/amado): frontmatter, framing "Primer Maestro", esqueleto §1–§14, matriz, CHANGELOG y `sincronizar.ps1` **conformes**.

- **Conformidad:** añadido el bloque **§2.1 "Alcance: SÍ hace / NO hace / colabora con"** (paridad con eneida/farola).
- **Lote H (relaciones y coherencia):** actualizado el **hub `interoperabilidad-y-aliadas.md`** — `sistemas-hardware` y `tiempo-real-embebido` añadidos a "Hermanos", descripción a **8 dominios**, nota de handoff hardware/RT; **`prisma`** añadido a la tabla de aliadas §5; unificado el **agente "infra" fantasma → `eneida`/plataforma** (metodologia, sistemas-hardware, tiempo-real); **footers** de los 6 satélites antiguos + hub ahora listan los 2 satélites nuevos; pseudo-enlaces **`[eneida]` → enlaces reales** (estrategia, infra); back-link `infra §5 → sistemas-hardware`; enumeración de dominios **6→8** (estrategia, hub, SKILL); numeración `metodologia §7.1/§7.2`; wording SLA/SLO reformulado; etiqueta `io_uring` con calificador genérico ("anillos de compleción"); ventana de error budget "mensual"→"28 días" en Ej.2.
- **Lote I (contenido de frontera):** serialización **zero-copy/access-in-place** (FlatBuffers/Cap'n Proto/Arrow) en `backend §6`; **RDMA/DMA/GPUDirect** en `sistemas-hardware` (I/O moderno); **inferencia multi-GPU** (tensor/pipeline parallelism, sharding de modelo) en `ia-ml`; **compresión zstd/LZ4/diccionarios** en `datos §Física`; **BBR** (congestion control moderno) en `sistemas-hardware §7`.

Verificado: 16 satélites, todos los enlaces cruzados resuelven, footers simétricos, sin agente fantasma, sin frontmatter en satélites, sin sesgo.

## [1.2.1] — 2026-07-08

### Fixed / Added — 3ª ronda de QA (4 revisores): correcciones + naming de frontera
- **Lote F (correcciones de defectos de la 2ª ronda):** tier corregido en `ejemplos` Ej.6 (padding/sharded counters → **T2** vía motor, coherente con `sistemas-hardware §4`); `datos §Física` reclasifica **fsync/durabilidad/config-de-motor a T2 co-implementado con andulfo** (Regla 7: no se relaja durabilidad en solitario); eliminado el **enlace colgante** `datos→sistemas-hardware` (`datos §Física` declarada canónica de la física del medio); **caveat de entornos gestionados** (cloud/serverless sin acceso a kernel) en `sistemas-hardware`; `ejemplos` Ej.7 acota "hard" a RTOS y "firm" a PREEMPT_RT; back-links (`backend §7`→I/O moderno, `distribuidos §1`→complejidad); playbook Greenfield/Brownfield de `sistemas-hardware` ahora cubre SIMD/I/O; "Complejidad algorítmica" pasa a subsección **§7.1**; **índice §0/§10 actualizado** para describir las 5 secciones nuevas (storage físico, SIMD, I/O moderno, JIT, complejidad).
- **Lote G (naming de frontera):** reclamación segura lock-free (**RCU / hazard pointers / seqlock**), **prefetch software** y **predicción de saltos/branchless**, **allocator NUMA-aware** y **tuning de allocator de espacio-usuario** (p. ej. jemalloc/tcmalloc/mimalloc).

Verificado: 16 satélites, todos los enlaces cruzados resuelven, sin frontmatter en satélites, sin sesgo.

## [1.2.0] — 2026-07-08

### Changed / Added — 2ª ronda de QA (4 revisores) + completitud de frontera
Re-auditoría de la v1.1.0 con 4 revisores independientes; correcciones y adiciones autorizadas en 2 lotes:

- **Lote D (correcciones):** unificación **completa** de la notación USL a σ/κ (quedaba un β residual en `metodologia-diagnostico.md` §6); versión del header sincronizada; fuente canónica de caché precisada a solo `datos §6`; back-links añadidos (transporte en `frontend §7`, roofline en `ia-ml §5`); etiqueta de tier del pool aclarada en `ejemplos` Ej.2; **`prisma`** (data science) añadido al roster de aliadas; encuadre greenfield/brownfield explícito en `backend`/`frontend`; nota de enrutado desktop/CLI/batch en `medicion`.
- **Lote E (completitud de frontera):** `datos-performance.md` — **física del motor de almacenamiento** (LSM vs B-tree/RUM conjecture, write amplification, NVMe/queue depth, WAL/fsync/group-commit); `sistemas-hardware.md` — **SIMD/vectorización** e **I/O moderno** (io_uring/zero-copy/kernel-bypass); `metodologia-diagnostico.md` — **complejidad algorítmica y estructuras de datos**; `backend-performance.md` §12 — **compilación/runtime** (JIT/warmup/PGO/LTO/inlining); `ejemplos.md` — **Ejemplo 6** (false sharing/NUMA) y **Ejemplo 7** (WCET/jitter en tiempo real).

Verificado: 16 satélites, todos los enlaces cruzados resuelven, sin frontmatter en satélites, sin sesgo.

## [1.1.0] — 2026-07-08

### Changed / Added — Endurecimiento tras QA multi-revisor
QA de 4 revisores independientes (coherencia/contradicciones, solapamientos/índice, completitud/nivel mundial, greenfield/sesgo/universalidad). Correcciones y adiciones autorizadas por el usuario, en 3 lotes:

- **Lote A (correcciones de correctitud/coherencia):** notación de la USL unificada a **σ/κ** (Gunther) en los 3 archivos; fórmula de dimensionado de pool corregida (`≈ concurrencia = tasa × t_servicio`) y su **tier** aclarado (política T1 / config en servicio T2); **caché** con fuente canónica declarada y enlaces cruzados (fin del aislamiento de `backend §4`); correcciones numéricas (error budget 1.0% ≈ 6h 43m, budget de imagen del ejemplo, desambiguación de budgets de bundle, CLS ≤ 0.1); autoscaling por **señal causal** (cola/latencia) en vez de CPU; OpenTelemetry como "p. ej."; enlace roto corregido.
- **Lote B (greenfield + universalidad):** método **performance-by-design** (`metodologia-diagnostico.md` §1.1); **Ejemplo 0 greenfield**; load testing de PoC en greenfield; variante greenfield en plantillas; **medición de sistemas no-online** (batch, on-device/embebido, desktop/CLI) en `medicion-observabilidad.md`; métricas de **móvil nativo** (TTID/TTFD, ANR, frame drops) en `frontend-performance.md`.
- **Lote C (huecos de élite):** dos satélites nuevos — **`sistemas-hardware.md`** (jerarquía de caché CPU, NUMA, mechanical sympathy, false sharing/atómicos/memory ordering, red de transporte/físico TCP/TLS/QUIC, coste de performance de la criptografía) y **`tiempo-real-embebido.md`** (WCET, scheduling RT, determinismo/jitter, deadlines, medición on-device); **ingeniería del caos** en `pruebas-de-carga.md`.

Matriz de cobertura ampliada de 12 a **14 disciplinas**; `SKILL.md` §0 (base de conocimiento + matriz) y §10 actualizados. Total: 16 satélites + SKILL + CHANGELOG.

## [1.0.0] — 2026-07-08

### Added — Creación del agente
- Nace **peakformance**, dueño integral del performance del ecosistema (frontend,
  backend, datos, sistemas distribuidos, infraestructura e IA), con neutralidad
  tecnológica total, aplicable a cualquier industria/dominio y a sistemas
  greenfield, en construcción y brownfield.
- **Modelo tiered de corrección** (no solo audita, también corrige): Tier 1
  implementa directo lo cross-cutting (caché, tuning, perf gates, harnesses,
  instrumentación); Tier 2 entrega/co-implementa el fix medido en dominio ajeno
  vía su dueño (`farola`/`motor`/`andulfo`/`sysuniversal-ai`); Tier 3 fallback a
  implementación directa si el dueño no existe.
- `SKILL.md` + 14 archivos satélite de conocimiento:
  `estrategia-performance.md`, `metodologia-diagnostico.md`,
  `medicion-observabilidad.md`, `frontend-performance.md`,
  `backend-performance.md`, `datos-performance.md`,
  `distribuidos-escalabilidad.md`, `infra-capacidad-costo.md`,
  `pruebas-de-carga.md`, `performance-cicd.md`, `ia-ml-performance.md`,
  `interoperabilidad-y-aliadas.md`, `plantillas.md`, `ejemplos.md`.
- `sincronizar.ps1` (mismo patrón que eneida, farola, uxuifull, andulfo…): 4
  junctions de directorio hacia `.cursor`, `.claude`, `.claude-trabajo`, `.agents`.

### Contexto
- Recibe el ownership de performance cedido por `uxuifull` (v1.2.3, conservó el
  rendimiento percibido) y `farola` (v1.3.0, conservó la implementación
  performante como craft). Reconciliación a tres bandas documentada en la
  gobernanza de `farola` §4.6.
