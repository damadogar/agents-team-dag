# Performance de datos y consultas (agnóstico de motor)

Dominio de peakformance sobre la capa de datos: **planes de ejecución, índices, patrones de acceso, particionado, caché y coherencia, pooling, OLTP/OLAP, ingesta y modelado orientado al acceso**. Neutralidad total: los motores/paradigmas (p. ej. relacional, documental, columnar, clave-valor, grafo, time-series) aparecen solo como ejemplo; el motor se elige por **contexto y evidencia**, nunca por defecto ni por moda. Aplica a greenfield y brownfield. Se mide con percentiles (p50/p95/p99), a escala real de datos y con **antes/después**; nunca con promedios ni datasets de juguete.

> Reparto TIERED (ver [interoperabilidad-y-aliadas](interoperabilidad-y-aliadas.md)):
> - **T1 — peakformance implementa** lo cross-cutting: caché de datos, afinado de plan en el borde de la consulta (hints/reescritura sin tocar esquema), connection management/pooling.
> - **T2 — se entrega/co-implementa**: cambio de **esquema/índice/plataforma de datos** vía **andulfo** (dueño de BD/plataforma); el **código de acceso a datos** vía **motor**.
> - **T3 — fallback directo** de peakformance cuando esos roles no están disponibles, dejando evidencia y handoff pendiente.

Encadena con [metodologia-diagnostico](metodologia-diagnostico.md) (medir antes de tocar), [medicion-observabilidad](medicion-observabilidad.md) (instrumentación), [backend-performance](backend-performance.md) (borde de aplicación) y [distribuidos-escalabilidad](distribuidos-escalabilidad.md) (datos a escala).

## 1. Leer y afinar un plan de ejecución

El plan es la fuente de verdad, no la intuición. Regla base: **medir con EXPLAIN + ejecución real** (equivalentes a `EXPLAIN ANALYZE`, "explain plan"/"profile" documental, plan de consulta columnar).

Qué buscar al leer un plan:

| Señal | Interpretación | Acción de primer orden |
|---|---|---|
| Escaneo completo sobre tabla/colección grande | Falta índice útil o predicado no *sargable* | Índice T2 (andulfo) o reescritura del predicado T1 |
| Estimado ≫/≪ real (filas) | Estadísticas obsoletas/sesgadas | Refrescar estadísticas; muestreo; histogramas |
| Orden de *join* subóptimo | Cardinalidades mal estimadas | Verificar estadísticas; forzar orden solo con evidencia |
| *Seek* vs *scan* | *Seek* accede por clave; *scan* recorre todo | Diseñar índice para habilitar *seek* selectivo |
| Materializaciones/spills a disco | Memoria de trabajo insuficiente | Reducir filas intermedias; ajustar memoria; paginar |
| *Nested loop* con muchas iteraciones | N+1 disfrazado en el motor | *Hash/merge join* o batch del lado app |

Distinguir **estimación vs realidad** es el diagnóstico central: un plan "bonito" con estimaciones erradas rinde mal a escala real. Afinado en el borde (T1) antes de escalar a T2: reescritura de predicados no sargables (evitar funciones sobre la columna indexada, evitar comodín inicial en búsquedas), proyección explícita (no traer columnas/campos que no se usan), límites y paginación por clave (*keyset*) en vez de desplazamiento profundo.

```
-- Ilustrativo, agnóstico: predicado NO sargable vs sargable
WHERE fn(col) = :v            -- impide uso de índice
WHERE col = :v_normalizado    -- sargable; normalizar en la app
```

## 2. Índices: selectividad, composición y costo de escritura

Un índice acelera lectura y **penaliza escritura y almacenamiento**. La decisión es un trade-off medido, no un reflejo.

| Concepto | Guía neutral |
|---|---|
| Selectividad | Indexar columnas/campos que filtran mucho (alta cardinalidad); baja selectividad rara vez ayuda |
| Índice compuesto | Orden de columnas = orden de uso: igualdad → rango → orden/salida |
| *Covering* | Incluir columnas de salida para resolver la consulta sin volver al dato base |
| Tipos | Elegir por acceso: p. ej. árbol balanceado (rango/orden), hash (igualdad), invertido/full-text, geoespacial, para vectores similitud |
| Cuándo NO indexar | Tablas muy escritas y poco leídas; columnas baja cardinalidad; sobre-indexación que degrada inserción/actualización |

Regla del prefijo: un índice `(a, b, c)` sirve a filtros por `a`, `a+b`, `a+b+c`, no a `b` o `c` aislados. Antes de crear, **estimar** el impacto en escritura y verificar con carga real ([pruebas-de-carga](pruebas-de-carga.md)). La creación/modificación es **T2 → andulfo**; peakformance define el índice objetivo con evidencia del plan.

## 3. Problema N+1 y patrones de acceso

El N+1 (una consulta base + N consultas por fila) es la patología más común y suele nacer en el código de acceso. Detección: contar consultas por transacción en observabilidad; un pico lineal con el tamaño del resultado lo delata.

| Patrón | Uso | Nota |
|---|---|---|
| Batch / `IN (...)` | Reemplaza N consultas por 1 con lista de claves | Cuidar tamaño del lote (troceado) |
| Eager join | Traer relación en la misma consulta | Riesgo de multiplicación de filas |
| Lazy | Cargar bajo demanda | Origen frecuente de N+1 si se itera |
| Dataloader / agrupación por tick | Coalescer y deduplicar claves | Ideal en APIs/grafos |

Corrección: código de acceso es **T2 → motor**; peakformance especifica el patrón, el tamaño de lote y valida antes/después por percentiles. Ver [backend-performance](backend-performance.md).

## 4. Particionado, sharding y hot partitions

Particionar divide datos por una clave (p. ej. rango temporal, hash, lista, geografía) para acotar el trabajo por consulta y facilitar el ciclo de vida (purga por partición). *Sharding* distribuye entre nodos.

- **Elección de clave**: debe alinear con los predicados dominantes (*partition pruning*) y **repartir uniforme** la carga.
- **Skew / hot partitions**: una clave con distribución sesgada (p. ej. "cliente ancla", claves temporales "hoy") concentra tráfico. Mitigación: *salting* de la clave, sub-particiones, o clave compuesta.
- **Costo**: demasiadas particiones encarecen planeación y metadatos; muy pocas no acotan.

Diseño físico de partición/sharding = **T2 → andulfo**. peakformance aporta el análisis de distribución real y percentiles por partición.

## 5. Desnormalización con criterio

Normalizar protege integridad; desnormalizar (duplicar/pre-agregar, tablas anchas, campos calculados) reduce *joins* costosos en lecturas calientes. Es una **decisión medida**, no estética.

Aplicar cuando: lectura ≫ escritura, *joins* repetidos dominan el p95, y la redundancia es mantenible (coherencia por *trigger*, vista materializada, o proceso). Costo: escrituras más caras y riesgo de divergencia. Documentar el origen de verdad y la estrategia de refresco. Modelo de datos = **T2 → andulfo** (co-diseño con [eneida](interoperabilidad-y-aliadas.md)).

## 6. Caché de datos y coherencia (T1)

peakformance **implementa** la caché de datos como cross-cutting. Lo difícil no es cachear, es **invalidar**.

| Estrategia | Cuándo | Riesgo |
|---|---|---|
| *Cache-aside* (lazy) | Lectura general | *Stampede* en expiración simultánea |
| *Read-through* / *write-through* | Coherencia fuerte a costo de latencia de escritura | Acoplamiento |
| *Write-behind* | Escritura intensiva | Pérdida ante fallo |

Claves: TTL acorde a la tolerancia de obsolescencia del negocio; invalidación por evento/versión de clave; protección contra *stampede* (bloqueo o refresco anticipado); evitar *thundering herd*. Métrica rectora: *hit ratio* y su efecto en p95/p99 de origen, no solo el ratio aislado. Coherencia distribuida y niveles se tratan en [distribuidos-escalabilidad](distribuidos-escalabilidad.md).

## 7. Connection management y pooling (política T1; configuración en servicio T2)

Abrir conexiones es caro; agotarlas colapsa el sistema (aplica **Little's Law**: concurrencia = tasa × tiempo de servicio).

> **Reparto de tier** (igual que GC en [backend-performance](backend-performance.md) §5): la **política y el target de dimensionado** del pool son **T1** (peakformance, con evidencia del recurso); la **configuración del pool que vive en el servicio/ORM/driver** es **T2 → motor/andulfo**.

- Dimensionar el pool con evidencia: un pool sobredimensionado satura el motor; uno pequeño encola en la app.
- Fijar timeouts (adquisición, consulta, socket) y detectar *leaks* (conexiones no devueltas).
- Reutilizar sentencias preparadas; evitar transacciones largas que retienen conexiones.
- En serverless/borde: *pooler* externo o límites por instancia para no exceder el máximo del motor.

Fórmula de referencia (USE — utilización, saturación, errores del recurso "pool"):

```
pool_min ≈ concurrencia_p50   (concurrencia = tasa × t_servicio, Little's Law L = λ·W)
pool_max  = límite_motor / nº_instancias   (margen de seguridad)
```

## 8. OLTP vs OLAP awareness

Cargas y estructuras distintas; mezclarlas degrada ambas.

| Eje | OLTP | OLAP |
|---|---|---|
| Acceso | Muchas transacciones cortas, por clave | Pocas consultas amplias, agregaciones |
| Estructura | Orientada a fila, normalizada, indexada para *seek* | Orientada a columna, desnormalizada, *scan* eficiente |
| Métrica | Latencia p99 por operación | Throughput y tiempo total de barrido |

Separar cargas (réplicas de lectura, almacén analítico, CDC hacia OLAP) evita que reportes pesados ahoguen la transaccionalidad. La arquitectura de separación es **T2 → andulfo**; ver [infra-capacidad-costo](infra-capacidad-costo.md).

## 9. Ingesta: batch vs streaming

| Modo | Cuándo | Palancas de performance |
|---|---|---|
| Batch | Volumen alto, latencia tolerante | Carga masiva (*bulk*), desactivar/reconstruir índices por lote, transacciones agrupadas, formatos columnar/comprimidos |
| Streaming | Baja latencia, continuo | *Micro-batching*, control de contrapresión, idempotencia, particiones para paralelizar |

Evitar el anti-patrón de inserción fila a fila en cargas masivas. La ingesta continua debe respetar el presupuesto de escritura del motor y no invalidar cachés en cascada.

## 10. Data locality y modelado orientado al acceso

Rendir es **acercar el dato al cómputo** y **modelar según cómo se lee**.

- **Localidad**: co-ubicar datos que se leen juntos (misma partición/nodo/página) reduce *fan-out* y saltos de red; minimizar viajes de ida y vuelta.
- **Modelado por acceso** (clave en NoSQL/columnar/time-series): el esquema se diseña desde las consultas, no al revés.
  - Documental (p. ej.): embeber lo que se lee junto; referenciar lo que crece sin límite.
  - Columnar (p. ej.): agrupar por columnas consultadas; ordenar/clusterizar para *pruning*.
  - Time-series (p. ej.): particionar por tiempo, *downsampling*/retención por edad, *rollups* pre-agregados.
  - Clave-valor (p. ej.): clave compuesta que resuelva el acceso en una sola operación.
  - Grafo (p. ej.): índices sobre propiedades de arranque; acotar profundidad de recorrido.

Ninguno es "mejor"; se elige por el patrón de consulta y se valida con datos a escala real.

## Física del motor de almacenamiento (LSM vs B-tree, write amplification, NVMe, WAL/fsync)

Bajo el plan y el índice hay una **física de almacenamiento** que fija el techo de lo alcanzable. Conocerla evita "optimizar" contra una restricción del motor/medio. Neutralidad total: estructuras y hardware aparecen solo como **p. ej.**; se eligen por el patrón de carga **medido** (relación escritura/lectura W/R, tamaño de valor, latencia vs throughput), nunca por moda.

**LSM-tree vs B-tree — RUM conjecture.** No se optimizan simultáneamente las tres amplificaciones: **Read, Update (write) y Memory/space**; mejorar una empeora otra. Se elige por el patrón W/R real, no por defecto:

| Motor de almacenamiento (p. ej.) | Favorece | Mecanismo | Coste que paga |
|---|---|---|---|
| LSM-tree | Escritura, *write-heavy*, SSD | Escritura secuencial (append a memtable→SSTable) + compactación en background | *Read amplification* (varios niveles/*bloom filters*) y *space amplification* (datos duplicados hasta compactar) |
| B-tree / B+tree | Lectura puntual y **rango/orden**, *read-heavy* | Actualización *in-place* sobre páginas ordenadas | *Write amplification* (reescritura de página completa por cambio pequeño) y fragmentación/*page splits* |

Regla: medir W/R y tamaño de valor **antes** de asumir estructura. Ni LSM ni B-tree son "mejores"; la elección física del motor es **T2 → [andulfo](interoperabilidad-y-aliadas.md)**, alimentada por la evidencia de carga de peakformance.

**Write amplification (WA) — el multiplicador oculto de escritura.** Un byte lógico escrito genera *múltiples* bytes físicos, degradando throughput sostenido y desgaste:
- **En el medio (p. ej. SSD/NVMe)**: la NAND borra por bloque pero escribe por página → *garbage collection*, ciclo *program/erase* (P/E), y necesidad de *over-provisioning* y **TRIM** para sostener rendimiento; sin *headroom* libre, la GC compite con el tráfico y colapsa el p99 de escritura.
- **En el motor (p. ej. LSM)**: la **compactación** reescribe datos varias veces al subir de nivel → WA de motor que se suma a la del medio.
- WA alto = menos throughput útil por IOP y menor vida del dispositivo. Medir WA efectiva (bytes físicos / lógicos) es diagnóstico, no anécdota.

**NVMe y almacenamiento moderno — paralelismo, no seeks.** El medio dejó de girar: el modelo mental de "minimizar *seeks*" (p. ej. HDD, coste dominado por posicionamiento del cabezal) ya no aplica. En medios de estado sólido con **NVMe** el rendimiento nace del **paralelismo por colas**:
- Muchas colas profundas (*queue depth* alto) saturan los canales internos → **IOPS** sube con la concurrencia hasta el punto de codo.
- Existe un trade-off **IOPS vs latencia**: subir *queue depth* eleva throughput pero también la latencia por operación (colas → Little's Law, ver §7). Se busca el codo, no el máximo IOPS.
- Implicación agnóstica: la capa de datos debe **emitir I/O concurrente** (batch, prefetch, paralelismo controlado) para explotar el medio; una tras otra desperdicia el dispositivo.
- En *tiers* fríos/archivo el **disco giratorio (HDD) sigue vigente** y el coste por *seek* aplica: se elige por **medio y patrón**, no se asume estado sólido universal (ver [infra-capacidad-costo](infra-capacidad-costo.md)).

**Durabilidad y su costo — el fsync suele ser el cuello oculto.** La transaccionalidad se paga en el camino de escritura durable:
- **WAL / redo log**: se escribe primero el log secuencial y luego se aplica; permite recuperación y convierte escrituras aleatorias en secuenciales.
- **`fsync`**: forzar el vaciado a medio persistente es una operación de **latencia alta** (espera confirmación física). Un commit que hace `fsync` por transacción ata el throughput a la latencia de `fsync` del medio.
- **Group commit / batching de commits**: agrupar varios commits en un `fsync` amortiza el coste → sube throughput a costa de un poco de latencia por commit. Trade-off **durabilidad vs throughput** explícito, no accidental.

```
# Trade-off durabilidad/throughput (neutral, ilustrativo)
fsync_por_commit      → durabilidad máxima, throughput ≈ 1 / latencia_fsync
group_commit(N)       → throughput ↑ ~N×, latencia_commit ↑ (espera al lote)
fsync_diferido/relajado → throughput ↑↑, ventana de pérdida ante fallo (elegir por SLO de durabilidad)
```

**Reparto de tier.** La **caché de almacenamiento** cross-cutting es **T1** (peakformance). El **afinado de `fsync`/durabilidad y la configuración del motor de storage** tocan durabilidad y riesgo de **pérdida de datos**: son **T2 co-implementado con [andulfo](interoperabilidad-y-aliadas.md)** bajo el SLO de durabilidad del negocio — peakformance mide y propone el trade-off; andulfo lo aplica. **No se relaja `fsync` en solitario** (Regla 7 del SKILL: no se decide correctitud/pérdida de datos unilateralmente). El cambio de **esquema/motor** es **T2 → andulfo**; el **código de acceso/transacciones**, **T2 → motor**.

**Compresión y formato (breve).** Comprimir cambia **CPU por I/O**: menos bytes a mover/almacenar a cambio de ciclos de (des)compresión; conviene cuando el I/O es el cuello y hay CPU disponible. El **algoritmo** se elige por la curva **ratio↔velocidad** (p. ej. LZ4/Snappy = rápidos y ratio moderado; zstd = ratio alto con **niveles** ajustables; **diccionarios** para payloads pequeños y homogéneos). Los **formatos columnar** (ya tratados en §8 OLTP/OLAP y §10) comprimen mejor por homogeneidad de columna y habilitan *pruning*; sobre ellos, los **encodings ligeros por columna** (RLE, delta, dictionary, bit-packing, frame-of-reference) son más baratos de (des)comprimir que un compresor de bloque y suelen combinarse con él. Es decisión medida, no reflejo. **Tier:** la compresión/encoding del **motor de almacenamiento** (config del engine) es **T2 → andulfo**; la compresión de **transporte/aplicación** cross-cutting es **T1** (peakformance).

Reparto: dimensionar IOPS y *tiers* de almacenamiento (coste/rendimiento) → [infra-capacidad-costo](infra-capacidad-costo.md); metodología de medir-antes-de-tocar → [metodologia-diagnostico](metodologia-diagnostico.md). La **física del medio** (NAND, ciclo P/E, GC, over-provisioning, write amplification) tiene su **hogar canónico en esta sección**.

## Checklist de datos

- [ ] Plan capturado con ejecución real (EXPLAIN/ANALYZE), estimado vs real revisado.
- [ ] Predicados *sargables*; proyección mínima; paginación por clave, no por desplazamiento profundo.
- [ ] Índices justificados por selectividad y orden de columnas; costo de escritura estimado.
- [ ] N+1 descartado (conteo de consultas por transacción); batch/dataloader donde aplica.
- [ ] Clave de partición/sharding alineada a predicados y sin *hot partitions* (distribución medida).
- [ ] Desnormalización solo con lectura≫escritura y estrategia de coherencia documentada.
- [ ] Caché con TTL/invalidación definidos y protección contra *stampede*; *hit ratio* medido.
- [ ] Pool dimensionado por Little's Law; timeouts y *leaks* controlados.
- [ ] Motor de almacenamiento (LSM/B-tree, p. ej.) elegido por W/R medido; *write amplification* de motor y medio estimada (compactación, GC/over-provisioning/TRIM).
- [ ] Durabilidad afinada por SLO: WAL/`fsync` medido como posible cuello de escritura; *group commit*/batching evaluado; I/O concurrente (*queue depth*) para explotar NVMe.
- [ ] OLTP y OLAP separados según carga.
- [ ] Ingesta batch/streaming con *bulk*/idempotencia/contrapresión según corresponda.
- [ ] Antes/después en p50/p95/p99 con datos a escala real; evidencia archivada.
- [ ] Handoffs T2 declarados: esquema/índice/plataforma → **andulfo**; código de acceso → **motor**.

Relacionados: [estrategia-performance](estrategia-performance.md) · [metodologia-diagnostico](metodologia-diagnostico.md) · [medicion-observabilidad](medicion-observabilidad.md) · [backend-performance](backend-performance.md) · [distribuidos-escalabilidad](distribuidos-escalabilidad.md) · [pruebas-de-carga](pruebas-de-carga.md) · [performance-cicd](performance-cicd.md) · [ia-ml-performance](ia-ml-performance.md) · [frontend-performance](frontend-performance.md) · [infra-capacidad-costo](infra-capacidad-costo.md) · [sistemas-hardware](sistemas-hardware.md) · [tiempo-real-embebido](tiempo-real-embebido.md) · [plantillas](plantillas.md) · [ejemplos](ejemplos.md) · [interoperabilidad-y-aliadas](interoperabilidad-y-aliadas.md)
