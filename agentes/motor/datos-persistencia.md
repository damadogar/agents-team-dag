# datos-persistencia.md — Datos y persistencia (implementación)

> Para **implementar** acceso a datos con maestría: modelar, indexar, consultar,
> manejar transacciones/concurrencia, migrar. **La elección del motor de datos la
> hace el arquitecto**; la tabla §1 es para que entiendas el porqué y, si fuera
> inadecuado, lo **cuestiones con datos** (no para que decidas el cambio).

## 1. El motor lo elige el arquitecto (entiende el porqué por patrón de acceso)

| Familia | Úsala cuando | Ejemplos | Riesgos |
|---------|--------------|----------|---------|
| **Relacional (OLTP)** | Datos estructurados, relaciones, transacciones ACID, integridad fuerte. Default para la mayoría | PostgreSQL, MySQL, SQL Server, Oracle | Escala de escritura horizontal requiere sharding |
| **Documental** | Agregados auto-contenidos, esquema flexible, lectura por documento | MongoDB, DocumentDB, Couchbase | Joins/transacciones limitadas; modelado por consulta |
| **Clave-valor** | Lecturas/escrituras simples por clave, cache, sesiones, contadores | Redis, DynamoDB, Memcached | Sin queries complejas; modela acceso por adelantado |
| **Columnar/Wide-column** | Escritura masiva, series, escala horizontal extrema | Cassandra, ScyllaDB, Bigtable, HBase | Consistencia eventual; diseño dirigido por queries |
| **Search** | Búsqueda full-text, facetas, relevancia, agregaciones ad-hoc | Elasticsearch, OpenSearch, Meilisearch | No es fuente de verdad; sincronización vía CDC |
| **Time-series** | Métricas, IoT, telemetría, ventanas temporales | TimescaleDB, InfluxDB, Prometheus | Especializado; no para datos relacionales |
| **Grafo** | Relaciones profundas/transitivas (fraude, social, recomendación) | Neo4j, JanusGraph, Neptune | Nicho; curva de aprendizaje |
| **Analítico (OLAP/DW)** | Agregaciones sobre grandes volúmenes, BI, reporting | ClickHouse, BigQuery, Snowflake, Redshift | No para OLTP transaccional |
| **NewSQL/distribuido** | SQL + escala horizontal + ACID distribuido | CockroachDB, Spanner, YugabyteDB, TiDB | Costo/complejidad; latencia de consenso |

Heurística: **relacional por defecto**; añade un store especializado (cache,
search, OLAP) como complemento cuando el patrón lo exija (polyglot persistence),
no para reemplazar la fuente de verdad sin razón.

## 2. Modelado relacional

- **Normaliza** (3FN) para integridad; **desnormaliza con criterio** para
  rendimiento de lectura (con cuidado de anomalías y consistencia).
- **Claves**: prefiere claves sustitutas (BIGINT identity o UUIDv7/ULID ordenado
  por tiempo para evitar fragmentación de índices). Evita UUIDv4 como PK
  clustered en tablas grandes.
- **Restricciones** en la DB (FK, UNIQUE, CHECK, NOT NULL): la integridad es del
  motor, no solo de la app.
- **Tipos correctos**: dinero como `NUMERIC`/entero menor (nunca float); fechas en
  UTC `timestamptz`; enums controlados.

## 3. Índices y rendimiento de consultas

- Índices según **patrones de consulta** (WHERE, JOIN, ORDER BY). B-tree por
  defecto; GIN/GiST para texto/JSON/geo; parciales y compuestos (orden de
  columnas importa: igualdad → rango).
- **Covering indexes** para evitar lookups. Cuidado: cada índice ralentiza
  escrituras y ocupa espacio.
- Diagnostica con **EXPLAIN/ANALYZE**; evita N+1 (usa joins/batch/dataloader),
  SELECT *, funciones sobre columnas indexadas, y full scans en tablas grandes.
- **Connection pooling** (PgBouncer/proxy) obligatorio bajo concurrencia.

## 4. Transacciones, concurrencia y aislamiento

- **ACID** vs **BASE** (eventual). Elige por requisito de negocio, por operación.
- **Niveles de aislamiento**: Read Committed (default razonable), Repeatable Read,
  Serializable. Conoce anomalías: dirty read, non-repeatable read, phantom,
  **write skew** (solo Serializable lo evita).
- **Concurrencia optimista** (columna `version`/ETag, falla y reintenta) vs
  **pesimista** (`SELECT ... FOR UPDATE`, locks). Optimista escala con baja
  contención; pesimista para alta contención puntual.
- **Mantén transacciones cortas**; no hagas llamadas remotas dentro de una
  transacción de DB.
- **Across services**: evita 2PC; usa **saga + outbox** (consistencia eventual
  con compensaciones).

## 5. Replicación y particionamiento

- **Replicación**: primario-réplica (read scaling, HA), multi-primario (conflictos),
  síncrona (durabilidad, latencia) vs asíncrona (rendimiento, riesgo de pérdida).
- **Lag de réplica**: cuidado con *read-your-writes*; rutea lecturas críticas al
  primario o usa lecturas consistentes.
- **Sharding/partitioning**: por hash (distribución uniforme), rango (consultas
  por rango pero hot spots), o lista/geo. Clave de partición estable y de alta
  cardinalidad. Planea el **rebalanceo** y las cross-shard queries (caras).
- **Particionado declarativo** (Postgres partitions) para tablas grandes por
  tiempo/tenant: facilita archivado y mantenimiento.

## 6. Migraciones de esquema (seguras y reversibles)

- **Expand/Contract (parallel change)**: 1) añade lo nuevo compatible, 2) migra
  datos y código, 3) elimina lo viejo. Nunca rompas la versión en ejecución.
- Migraciones **versionadas** (Flyway, Liquibase, Alembic, EF, etc.), idempotentes
  y revisadas. Backfills en lotes para no bloquear.
- Cambios peligrosos: añadir columna NOT NULL sin default, renombrar/eliminar
  columnas en uso, crear índices bloqueantes (usa `CREATE INDEX CONCURRENTLY`).
- Ten plan de **rollback** y prueba en staging con volumen realista.

## 7. Patrones de integración de datos

- **Outbox**: persiste eventos en la misma transacción que el cambio; un relay/CDC
  publica al broker (evita doble escritura inconsistente).
- **CDC (Change Data Capture)**: Debezium/log-based para replicar a search/OLAP/
  cache sin tocar la app.
- **Event sourcing**: el log de eventos es la fuente de verdad; el estado se
  deriva (proyecciones, snapshots). Potente para auditoría; complejo de versionar.
- **Materialized views** y proyecciones para lectura (CQRS).

## 8. OLTP vs OLAP

- **No mezcles**: las cargas analíticas pesadas matan al OLTP. Separa con
  réplica de lectura dedicada, ETL/ELT a un DW/lakehouse, o CDC → OLAP.
- **Lakehouse/medallion** (bronze/silver/gold) para datos analíticos a escala.

## 9. Ciclo de vida y gobierno del dato

- Retención, archivado (cold storage), borrado (derecho al olvido / GDPR),
  anonimización/seudonimización de PII, clasificación de datos, linaje, calidad.
- **Backups**: automáticos, cifrados, probados (un backup no restaurado no
  existe), con RPO/RTO definidos. PITR (point-in-time recovery) cuando aplique.

## 10. Checklist de datos

```
- [ ] Motor de datos confirmado (lo elige el arquitecto); entiendo el porqué
- [ ] Modelo con restricciones e integridad en la DB; tipos correctos (dinero/fechas)
- [ ] Índices alineados a las queries; EXPLAIN revisado; sin N+1
- [ ] Nivel de aislamiento y estrategia de concurrencia definidos por operación
- [ ] Transacciones cortas; consistencia distribuida vía saga/outbox
- [ ] Replicación/sharding planificados con clave estable y rebalanceo
- [ ] Migraciones expand/contract, reversibles, backfill en lotes
- [ ] OLTP separado de OLAP (réplica/CDC/ETL)
- [ ] PII clasificada/cifrada; retención y borrado definidos
- [ ] Backups cifrados y restores probados; RPO/RTO definidos
```
