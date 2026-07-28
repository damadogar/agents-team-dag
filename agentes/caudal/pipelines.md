# pipelines.md — Ingesta, transformación, orquestación, streaming y contratos

Detalle operativo de los **pipelines** que construye y opera Caudal.
Complementa [arquitectura.md](arquitectura.md) (el "qué/dónde") con el "cómo".
Todo pipeline es **un cambio de datos en producción** → idempotencia, dry-run de
volumen, verificación y rollback/reproceso (ver [ejecucion.md](ejecucion.md)).

---

## 1. Patrones de ingesta

| Patrón | Cuándo | Riesgos que vigila caudal |
|---|---|---|
| **Batch / bulk** | Cargas periódicas, *backfills* | Ventana, bloqueo del destino, idempotencia, *late data* |
| **Micro-batch** | Casi-tiempo-real (minutos) | Tamaño de lote vs latencia, reprocesos |
| **Streaming** | Eventos continuos, baja latencia | Orden, duplicados, *backpressure*, *consumer lag* |
| **CDC log-based** | Replicar cambios sin tocar la app (WAL/binlog/redo) | *Slot* huérfano que llena disco, *schema drift*, *snapshot* inicial |
| **CDC query-based** | Sin acceso al log; columna `updated_at`/versión | Pérdida de *deletes*, relojes desincronizados, *full scans* |
| **API / archivo (S3/GCS)** | Terceros, *flat files* | *Schema drift*, archivos parciales, reintentos, formato |

> CDC desde una base transaccional se coordina con **andulfo** (impacto del *slot*/
> replica en la base). Ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §3.

Reglas: **ingesta idempotente** (claves de dedupe), **watermarks** para reanudar
sin perder ni duplicar, y **landing inmutable** antes de transformar.

## 2. ETL vs ELT y transformación

- **ETL** (transforma antes de cargar): destino caro/limitado, o hay que filtrar
  PII antes de aterrizar.
- **ELT** (carga cruda y transforma en el destino): por defecto en DW/lakehouse
  modernos; aprovecha el cómputo del motor.
- **Capas medallón:** bronze (crudo) → silver (limpio/conformado) → gold
  (modelado para consumo). Cada capa reproducible desde la anterior.
- **Transformación como código:** dbt/SQL versionado, idempotente y testeable;
  modelos incrementales con clave única y estrategia de *merge*/*upsert*.
- **Reglas:** transformaciones **deterministas** y **reentrantes**; nunca mutar la
  zona cruda; separar lógica de negocio de la de movimiento.

## 3. Orquestación

- **Herramientas:** Airflow, Dagster, Prefect, Step Functions, ADF, Cloud
  Composer, Databricks Workflows (elige por ecosistema/equipo, sin sesgo).
- **Diseño de DAGs:** tareas idempotentes, *retries* con *backoff*, *timeouts*,
  dependencias explícitas, particiones por fecha para *backfill* selectivo.
- **SLAs de datos:** *freshness* objetivo por dataset; alerta si no se actualizó a
  tiempo.
- **Backfill seguro:** reprocesar rangos acotados (por partición), con *dry-run*
  de volumen, sin pisar datos correctos; reanudable.
- **Idempotencia de la corrida:** una reejecución no duplica ni corrompe (usa
  *merge*/*upsert*, particiones reemplazables, transacciones).

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
  reprocesar sin re-ingestar desde la fuente (base del patrón kappa).
- **Estado:** *windowing*, *watermarks* de evento, manejo de *late/out-of-order*.

## 5. Esquemas y contratos de datos

- **Schema registry** (Avro/Protobuf/JSON Schema): compatibilidad
  *backward/forward/full*; nunca rompas consumidores con un cambio incompatible.
- **Data contracts:** acuerdo explícito productor↔consumidor (esquema, semántica,
  *freshness*, SLA, *ownership*, política de cambios). Versionados y comunicados.
- **Schema evolution segura:** añadir campos opcionales (compatible);
  renombrar/eliminar exige versión nueva y *deprecation* gradual
  (*expand/contract*).
- **Frontera:** el contrato **técnico** lo posee caudal; el significado de
  negocio de las métricas finales, el **Analytics Engineer** (agente
  `brujula`).

## 6. Manejo de errores y reprocesos

- **Retries idempotentes** con *backoff* y límite; *circuit breakers* en fuentes
  inestables.
- **Poison messages / DLQ:** aísla lo irrecuperable sin frenar el flujo.
- **Cuarentena:** filas inválidas a tabla de rechazos con motivo (no se descartan
  en silencio); ver [calidad.md](calidad.md).
- **Reproceso/backfill:** rango acotado, *dry-run* de volumen, idempotente,
  rollback claro; tratar como cambio crítico.

## 7. Seguridad del dato en movimiento

- Cifrado en tránsito en cada *hop*; secretos de conexión en gestor (no en DAGs).
- **PII:** minimiza, enmascara o tokeniza **antes** de aterrizar en zonas de menor
  control; nunca a entornos abiertos sin tratar.
- **Mínimo privilegio** por cuenta de pipeline; *scopes* acotados por dataset.
- Linaje + catálogo como evidencia de cumplimiento.

## 8. Reglas transversales de pipelines

1. **Idempotencia siempre:** reejecutar no duplica ni corrompe.
2. **Crudo inmutable:** la zona de aterrizaje no se edita; todo deriva de ella.
3. **Calidad como *gate*:** datos que fallan DQ crítico no avanzan a consumo.
4. **Contrato antes que código:** acuerda esquema/SLA y versiónalo.
5. **Observabilidad del dato, no solo del job.**
6. **Backfill como cambio crítico:** dry-run de volumen, rango acotado, rollback.
7. **OLTP ≠ pipeline:** usa réplicas/CDC/export para alimentar analítica
   (constraint de andulfo).
