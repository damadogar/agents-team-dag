# integracion.md — Integración e ingeniería de datos (cobertura adjunta, calidad y gobierno operativo)

Detalle operativo del **dato en movimiento**: ingesta, transformación (ETL/ELT),
captura de cambios (CDC), orquestación, *streaming*, contratos y calidad de datos,
observabilidad de *pipelines*, catálogo/linaje, MDM y ciclo de vida del dato.

> **Frontera de responsabilidad (ver [SKILL.md](SKILL.md) §4 y
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)):** la ingeniería de
> datos es ownership del **Data Engineer** (y el modelado semántico/datasets de
> consumo, del **Analytics Engineer**, agente `brujula`). Andulfo es **C** (constraints de
> plataforma, performance, integridad y gobernanza) cuando esos roles existen, y
> solo asume **A/R** de forma **temporal y declarada** —marcando los entregables
> como **`[COBERTURA ADJUNTA]`** y documentando el handoff— cuando esos roles
> **no** existen (regla de extensión, SKILL.md §4.1).
>
> Lo que **sí** es foco central de Andulfo en este documento: las **garantías de
> plataforma** que todo pipeline debe respetar (integridad, idempotencia,
> seguridad, gobernanza estructural, linaje técnico y ciclo de vida del dato).

> Principio rector: **un pipeline es un cambio de datos en producción.** Aplica el
> mismo rigor que a una migración: idempotencia, *backfill* seguro, verificación y
> rollback. Ver método universal en [ejecucion.md](ejecucion.md).

---

## 1. Patrones de ingesta

| Patrón | Cuándo | Riesgos que Andulfo vigila |
|---|---|---|
| **Batch / bulk load** | Cargas periódicas, ventanas, *backfills* | Ventana, bloqueo del destino, idempotencia, *late data* |
| **Micro-batch** | Casi-tiempo-real con tolerancia de minutos | Tamaño de lote vs latencia, reprocesos |
| **Streaming** | Eventos continuos, baja latencia | Orden, duplicados, *backpressure*, *consumer lag* |
| **CDC log-based** | Replicar cambios sin tocar la app (WAL/binlog/redo) | *Slot* huérfano que llena disco, esquema cambiante, *snapshot* inicial |
| **CDC query-based** | Sin acceso al log; columna `updated_at`/versión | Pérdida de *deletes*, relojes desincronizados, *full scans* |
| **API / archivo (S3/GCS)** | Terceros, *flat files* | *Schema drift*, archivos parciales, reintentos, formato |

Reglas: **ingesta idempotente** (claves de deduplicación), **marcas de agua**
(*watermarks*) para reanudar sin perder ni duplicar, y **zona de aterrizaje**
(*landing/staging*) inmutable antes de transformar.

## 2. ETL vs ELT y transformación

- **ETL** (transforma antes de cargar): útil cuando el destino es caro/limitado o
  hay limpieza/PII que filtrar antes de aterrizar.
- **ELT** (carga cruda y transforma en el destino): por defecto en DW/lakehouse
  modernos (Snowflake/BigQuery/Databricks); aprovecha el cómputo del motor.
- **Capas medallón:** *bronze* (crudo) → *silver* (limpio/conformado) → *gold*
  (modelado para consumo). Cada capa es reproducible desde la anterior.
- **Transformación como código:** dbt/SQL versionado, *idempotente* y testeable;
  modelos incrementales con clave única y estrategia de *merge*.
- **Reglas:** transformaciones **deterministas** y **reentrantes**; nunca mutar la
  zona cruda; separar lógica de negocio de la de movimiento.

## 3. Orquestación

- **Herramientas:** Airflow, Dagster, Prefect, Step Functions, ADF, Cloud
  Composer, Databricks Workflows.
- **Diseño de DAGs:** tareas idempotentes, *retries* con *backoff*, *timeouts*,
  dependencias explícitas, particiones por fecha para *backfill* selectivo.
- **SLAs de datos:** *freshness* objetivo por dataset; alertas si un dataset no se
  actualizó a tiempo.
- **Backfill seguro:** reprocesar rangos acotados (por partición), con *dry-run* de
  volumen y sin pisar datos correctos; reanudable.
- **Idempotencia de la corrida:** una re-ejecución no debe duplicar ni corromper
  (usa *merge*/*upsert*, particiones reemplazables, transacciones).

## 4. Streaming y mensajería

- **Plataformas:** Kafka, Pulsar, Kinesis, Pub/Sub, RabbitMQ; procesamiento con
  Flink, Kafka Streams, Spark Structured Streaming.
- **Garantías de entrega:** *at-least-once* (con dedupe) vs *exactly-once*
  (transaccional/idempotente); **declara cuál usas y por qué**.
- **Claves y particiones:** la *partition key* define orden y paralelismo; evita
  *hot partitions* y preserva orden por entidad cuando importa.
- **Salud:** *consumer lag*, *throughput*, *rebalanceos*, *backpressure*, DLQ
  (*dead-letter queue*) para mensajes irrecuperables.
- **Retención y *replay*:** define retención del *log*; el *replay* es la forma de
  reprocesar sin re-ingestar desde la fuente.

## 5. Esquemas y contratos de datos

- **Schema registry** (Avro/Protobuf/JSON Schema): compatibilidad
  *backward/forward/full*; nunca rompas consumidores con un cambio incompatible.
- **Data contracts:** acuerdo explícito productor↔consumidor (esquema, semántica,
  *freshness*, SLA, *ownership*); cambios versionados y comunicados.
- **Evolución segura:** añadir campos opcionales (compatible); renombrar/eliminar
  exige versión nueva y *deprecation* gradual (paralelo al *expand/contract* de
  esquemas de [ejemplos.md](ejemplos.md) Caso 3).

## 6. Calidad de datos (DQ)

Dimensiones: **completitud, unicidad, validez, consistencia, exactitud,
oportunidad (*timeliness*), integridad referencial**.

- **Pruebas automáticas:** `not_null`, `unique`, rangos, *accepted values*, FK
  lógicas, *row count* esperado, *freshness* (dbt tests / Great Expectations /
  Soda). Falla el pipeline o cuarentena, según criticidad.
- **Reconciliación:** conteos y *checksums* origen↔destino tras cada carga;
  cuadre de importes/totales en dominios financieros.
- **Cuarentena:** filas inválidas a una tabla de rechazos con motivo, no se
  descartan en silencio.
- **Detección de *drift*:** cambios bruscos de volumen, distribución, nulos o
  cardinalidad disparan alerta.

## 7. Observabilidad de datos (*data observability*)

Más allá de la infra: vigila el **dato mismo**. Pilares: *freshness*, volumen,
distribución/esquema, linaje y *data downtime* (tiempo con datos incorrectos o
ausentes).

- **Señales:** ¿llegó a tiempo?, ¿el volumen es el esperado?, ¿cambió el esquema?,
  ¿la distribución es normal?, ¿de dónde viene y a qué afecta (linaje)?
- **MTTD/MTTR de datos:** detectar y resolver incidentes de datos, no solo de
  servidores.
- Herramientas: dbt tests + *exposures*, Great Expectations/Soda, Monte Carlo/
  OpenLineage/Marquez para linaje.

## 8. Catálogo, linaje y MDM

- **Catálogo de datos:** inventario de datasets con esquema, *owner*,
  clasificación (PII/PCI/PHI), descripción y nivel de calidad/SLA.
- **Linaje (lineage):** trazabilidad columna-a-columna de origen a consumo; clave
  para análisis de impacto y cumplimiento (OpenLineage/Marquez, catálogos cloud).
- **MDM (Master Data Management):** entidades maestras (cliente, producto)
  conciliadas y deduplicadas; *golden record*, *matching/survivorship*.
- **Metadatos activos:** el catálogo alimenta gobierno, búsqueda y políticas
  (acceso, retención) — no es documentación muerta.

## 9. Ciclo de vida del dato (lifecycle)

- **Tiering / archivado:** mover datos fríos a almacenamiento barato (hot→warm→
  cold→archive) según patrón de acceso y costo.
- **Retención y purga:** políticas por dato/regulación; **borrado seguro** y
  verificable (derecho al olvido GDPR/Habeas Data).
- **Particionamiento por tiempo + *expiration*:** en DW/time-series para controlar
  costo y cumplir retención automáticamente.
- **Reprocesabilidad:** conservar la zona cruda el tiempo necesario para poder
  reconstruir capas derivadas.

## 10. Seguridad del dato en movimiento

- Cifrado en tránsito en todo *hop*; secretos de conexión en gestor (no en DAGs).
- **PII:** minimiza, enmascara o tokeniza **antes** de aterrizar en zonas de menor
  control (analítica, no-prod); nunca copies PII a entornos abiertos sin tratar.
- **Mínimo privilegio** para cuentas de pipeline; *scopes* acotados por dataset.
- Linaje + catálogo como evidencia de cumplimiento (dónde está cada PII y a dónde
  fluye).

## 11. Reglas transversales de ingeniería de datos

1. **Idempotencia siempre:** reejecutar un job no debe duplicar ni corromper.
2. **Crudo inmutable:** la zona de aterrizaje no se edita; todo se deriva de ella.
3. **Calidad como *gate*:** datos que fallan DQ crítico no avanzan a *gold*.
4. **Contrato antes que código:** acuerda esquema/SLA con consumidores y versiónalo.
5. **Observabilidad del dato, no solo del job:** "el pipeline corrió en verde" no
   significa que el dato esté correcto.
6. **Backfill como cambio crítico:** dry-run de volumen, rango acotado, rollback.
7. **OLTP ≠ pipeline:** no martirices la base transaccional con lecturas masivas;
   usa réplicas/CDC/export para alimentar analítica.
