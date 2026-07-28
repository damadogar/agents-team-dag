# engines.md — Capacidades y decisión por motor / familia de BD

Referencia de Andulfo para **elegir el motor correcto** y administrarlo con
criterio maestro. Regla base: **el patrón de acceso y los atributos de calidad
mandan**; nunca elijas por costumbre. Considera *polyglot persistence* (varios
motores por contexto) cuando un solo motor no cubre bien todos los patrones.

---

## 1. Árbol de decisión rápido

```
¿Necesitas transacciones ACID fuertes e integridad referencial?
  └─ Sí → Relacional (RDBMS). ¿Escala global + ACID? → NewSQL/distribuido.
  └─ No ↓
¿El acceso es por clave y necesitas latencia mínima / caché?
  └─ Sí → Clave-valor (Redis/Memcached).
  └─ No ↓
¿Datos semiestructurados, agregados por documento, esquema flexible?
  └─ Sí → Documental (MongoDB/DynamoDB/Cosmos).
  └─ No ↓
¿Escritura masiva, alta disponibilidad, escala horizontal lineal?
  └─ Sí → Columna-ancha (Cassandra/Scylla).
  └─ No ↓
¿Relaciones profundas y recorridos (grafos, recomendación, fraude)?
  └─ Sí → Grafo (Neo4j/Neptune).
  └─ No ↓
¿Series temporales / métricas / IoT con retención por tiempo?
  └─ Sí → Time-series (Timescale/Influx/Prometheus).
  └─ No ↓
¿Búsqueda full-text, relevancia, facetas?
  └─ Sí → Motor de búsqueda (Elasticsearch/OpenSearch).
  └─ No ↓
¿Similitud por embeddings / RAG / IA?
  └─ Sí → Vectorial (pgvector/Milvus/Qdrant/Pinecone).
  └─ No ↓
¿Analítica OLAP / agregaciones masivas / BI / lakehouse?
  └─ Sí → Columnar/MPP/Lakehouse (Snowflake/BigQuery/ClickHouse/Databricks).
```

---

## 2. Matriz de selección ponderada (plantilla)

Puntúa cada opción 1–5 por atributo, multiplica por el peso (definido por el
contexto) y suma. Recomienda la de mayor total y declara los trade-offs.

| Atributo (peso) | Opción A | Opción B | Opción C |
|---|---|---|---|
| Ajuste al patrón de acceso (×?) | | | |
| Consistencia/ACID requerida (×?) | | | |
| Escalabilidad (×?) | | | |
| Disponibilidad/HA-DR (×?) | | | |
| Rendimiento/latencia (×?) | | | |
| Seguridad/cumplimiento (×?) | | | |
| Costo total (TCO) (×?) | | | |
| Madurez operativa/ecosistema (×?) | | | |
| Riesgo de *lock-in* (×?) | | | |
| **Total ponderado** | | | |

---

## 3. Relacional (RDBMS)

**Cuándo:** transacciones ACID, integridad referencial, modelos normalizados,
reporting transaccional, la mayoría de aplicaciones de negocio (OLTP).

| Motor | Fortalezas | Notas de Andulfo |
|---|---|---|
| PostgreSQL | Extensible (PostGIS, pgvector), MVCC, JSONB, robusto | Vigila autovacuum/bloat, *connection limits* (usa pooler), *long transactions* |
| MySQL/MariaDB | Ubicuo, simple, replicación madura | InnoDB siempre; cuidado con DDL bloqueante y *replication lag* |
| SQL Server | T-SQL, Always On, herramientas, RLS/TDE | Licenciamiento; usa Query Store, espera tipos *wait* |
| Oracle Database | RAC, particionamiento avanzado, alta criticidad | Costo/licencia; complejidad operativa |
| IBM Db2 | Cargas empresariales y mainframe | Nicho; integración legacy |

**Internals a dominar:** MVCC, WAL/redo-undo, optimizador por costo,
estadísticas, niveles de aislamiento, *locking*, tipos de índice (B-tree, hash,
GIN/GiST/BRIN), particionamiento declarativo.

**Riesgos vigilados:** índices faltantes/duplicados/no usados, N+1 vía ORM,
bloat/vacuum, *lock contention*, conexiones sin pool, migraciones DDL bloqueantes.

---

## 4. NewSQL / distribuido (ACID + escala horizontal)

**Cuándo:** necesitas garantías ACID **y** escala horizontal/global o alta
disponibilidad sin sharding manual.

| Motor | Notas |
|---|---|
| CockroachDB / YugabyteDB / TiDB | SQL distribuido, *resilient*, geo-particionado |
| Google Spanner | ACID global, *TrueTime*; gestionado, costo alto |
| Amazon Aurora | Compatible Postgres/MySQL, storage distribuido, alta durabilidad |

**Trade-offs:** latencia inter-región, *clock skew*, costo operativo, madurez de
features SQL vs RDBMS clásico.

---

## 5. Documental (NoSQL)

**Cuándo:** agregados que se leen/escriben juntos, esquema flexible/evolutivo,
catálogos, perfiles, contenido.

| Motor | Notas |
|---|---|
| MongoDB | Rico en queries, agregaciones, *change streams*; modela por patrón de acceso |
| DynamoDB | *Serverless*, escala masiva; **diseño single-table** y claves bien pensadas; cuidado *hot partitions* y costo |
| Cosmos DB | Multi-API, multi-región, niveles de consistencia ajustables |
| Couchbase / Firestore | Memoria+SQL-like / móvil-realtime |

**Riesgos vigilados:** esquema implícito sin gobierno, documentos que crecen sin
límite, índices ausentes, consistencia eventual mal entendida.

---

## 6. Clave-valor / caché / in-memory

**Cuándo:** latencia sub-milisegundo, sesiones, *rate limiting*, colas ligeras,
caché de lectura.

| Motor | Notas |
|---|---|
| Redis / ValKey / KeyDB | Estructuras ricas, *persistence* (RDB/AOF), Cluster, Streams, Pub/Sub |
| Memcached | Caché simple, multihilo |

**Riesgos vigilados:** estrategia de invalidación, política de *eviction*,
persistencia/durabilidad, *thundering herd*, *hot keys*, memoria.

---

## 7. Columna-ancha (wide-column)

**Cuándo:** escritura masiva, escala horizontal lineal, alta disponibilidad
multi-DC, series de eventos.

| Motor | Notas |
|---|---|
| Cassandra / ScyllaDB | *Tunable consistency*, sin punto único; diseña por *query-first* |
| HBase / Bigtable | Ecosistema Hadoop / GCP gestionado |

**Riesgos vigilados:** diseño de *partition key* (evita *hot partitions*),
*tombstones*, *large partitions*, reparación/compaction, consistencia.

---

## 8. Grafo

**Cuándo:** relaciones profundas y recorridos (redes sociales, recomendación,
detección de fraude, *knowledge graphs*, linaje).

| Motor | Notas |
|---|---|
| Neo4j | Cypher, maduro, ACID |
| Amazon Neptune | Gestionado, Gremlin/SPARQL/openCypher |
| JanusGraph / TigerGraph | Escala distribuida |

**Riesgos vigilados:** súper-nodos, modelado de aristas/propiedades, escalado
horizontal, consultas de recorrido costosas.

---

## 9. Time-series

**Cuándo:** métricas, IoT, telemetría, observabilidad, finanzas tick.

| Motor | Notas |
|---|---|
| TimescaleDB | Extensión Postgres, SQL completo, *hypertables* |
| InfluxDB / QuestDB | Especializados, ingestión alta |
| Prometheus | Monitoreo *pull*, retención corta + *remote write* |

**Riesgos vigilados:** **cardinalidad** de etiquetas, retención/downsampling,
compresión, *out-of-order writes*.

---

## 10. Búsqueda

**Cuándo:** full-text, relevancia/ranking, facetas, autocompletado, logs.

| Motor | Notas |
|---|---|
| Elasticsearch / OpenSearch | Mapping, análisis, agregaciones; sincroniza con la fuente |
| Solr | Maduro, Lucene |

**Riesgos vigilados:** diseño de *mapping*/analizadores, número de *shards*,
consistencia con la base de origen (CDC), costo de almacenamiento.

---

## 11. Vectorial (IA / embeddings / RAG)

**Cuándo:** búsqueda por similitud, recomendación semántica, RAG para LLMs.

| Motor | Notas |
|---|---|
| pgvector (Postgres) | Integra vectores con datos relacionales; simple, una sola base |
| Milvus / Qdrant / Weaviate | Especializados, filtrado híbrido, escala |
| Pinecone | Gestionado, *serverless* |

**Riesgos vigilados:** elección de índice (HNSW/IVF) y trade-off *recall* vs
latencia, dimensión/normalización, filtrado por metadatos, costo de memoria.

---

## 12. Analítico / columnar / MPP / Lakehouse

**Cuándo:** OLAP, agregaciones masivas, BI, *data warehouse*, lakehouse.

| Motor | Notas |
|---|---|
| Snowflake / BigQuery / Redshift / Synapse | DW gestionados/MPP; *clustering*, *partitioning*, control de costo por escaneo |
| ClickHouse / DuckDB | Columnar veloz; ClickHouse a escala, DuckDB embebido |
| Databricks / Delta / Iceberg / Hudi | Lakehouse, formatos abiertos, ACID sobre objeto |

**Riesgos vigilados:** costo por escaneo/cómputo, *partition pruning*,
*clustering keys*, formato de archivo, separación OLTP/OLAP (no mezclar cargas).

---

## 13. Embebidas / ligeras

| Motor | Notas |
|---|---|
| SQLite | Apps locales, edge, pruebas; un escritor a la vez |
| DuckDB | Analítica embebida sobre archivos (Parquet/CSV) |

---

## 14. Reglas transversales de selección

1. **OLTP ≠ OLAP:** no fuerces una sola base para ambos; usa réplicas/ETL/CDC.
2. **Consistencia primero:** si el dato es transaccional y crítico, no lo pongas
   en un motor de consistencia eventual sin entender el riesgo.
3. **Empieza simple:** un RDBMS bien diseñado resuelve la mayoría de casos; añade
   motores especializados cuando un patrón concreto lo justifique con datos.
4. **Gestionado por defecto en cloud**, self-managed solo si hay razón fuerte
   (control, costo a escala, features); *serverless* para cargas variables.
5. **Anti lock-in:** valora portabilidad, formatos abiertos y estrategia de
   salida en decisiones irreversibles.
6. **CAP/PACELC explícito:** declara qué sacrificas (consistencia o latencia)
   bajo partición/operación normal.
7. **Multi-tenancy consciente:** si hay múltiples clientes/tenants, elige el
   aislamiento (base-por-tenant *silo*, esquema-por-tenant *bridge*, tabla
   compartida con *tenant_id* + RLS *pool*) por seguridad, *blast radius*, costo
   y operación; nunca mezcles datos de tenants sin control de acceso a nivel fila.
8. **Migración entre motores (heterogénea):** trátala como proyecto reversible —
   conversión de esquema y tipos, equivalencia de features, *backfill* + CDC para
   sincronizar, fase de doble lectura/escritura y *cutover* con rollback. Ver el
   runbook de replatforming en [runbooks.md](runbooks.md).
