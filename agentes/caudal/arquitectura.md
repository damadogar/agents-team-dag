# arquitectura.md — Arquitectura de datos: patrones, almacenamiento y decisión

Guía de **arquitectura de datos** de Caudal: cómo elegir y combinar
patrones de procesamiento (batch/streaming/lambda/kappa/event-driven), capas de
almacenamiento (lake/warehouse/lakehouse) y topologías de flujo, con
**neutralidad tecnológica total**. Decide por **volúmenes, latencias, criticidad,
equipo, costo y objetivos de negocio**, no por preferencia de herramienta.

Ver [SKILL.md](SKILL.md) §3, §10, §11 y la frontera con andulfo en
[gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §3.

---

## 1. Topología de referencia (capas)

```
Fuentes (BD / API / logs / archivos / eventos / SaaS)
   │  ingesta (batch | micro-batch | streaming | CDC)
   ▼
Landing / Raw (inmutable, formato crudo)        ← zona cruda, nunca se edita
   ▼  transformación
Staging / Cleansed (tipado, validado, dedupe)
   ▼
Core / Conformed (modelo integrado, dimensiones conformadas)
   ▼
Marts / Feature layers (listo para consumo: BI, producto, modelos, APIs)
```

- Cada capa es **reproducible** desde la anterior.
- La **zona cruda** se conserva el tiempo necesario para reconstruir capas
  derivadas (reprocesabilidad).
- La frontera **Marts/semántica** es donde entra el **Analytics Engineer** (agente
  `brujula`); las
  *feature layers* avanzadas, el **Data Scientist** (agente `prisma`) **/ AI
  Engineer**.

## 2. Patrones de procesamiento — árbol de decisión

```
¿Latencia requerida?
├─ horas/diaria ............................ BATCH / ELT
├─ minutos ................................. MICRO-BATCH
└─ segundos / continuo ..................... STREAMING
       │
       ├─ ¿necesitas vista exacta histórica + vista rápida? ... LAMBDA
       ├─ ¿todo como stream con reproceso por replay? ......... KAPPA
       └─ ¿propagar cambios entre sistemas desacoplados? ...... EVENT-DRIVEN / CDC
```

| Patrón | Fortalezas | Costos / riesgos | Cuándo NO |
|---|---|---|---|
| **Batch / ELT** | Simple, barato, fácil de reprocesar | Latencia alta; ventanas | Cuando el negocio exige tiempo real |
| **Micro-batch** | Casi-tiempo-real simple | Compromiso latencia/tamaño de lote | Latencia sub-segundo |
| **Streaming** | Baja latencia, continuo | Complejidad operativa, estado, orden | Volumen pequeño y latencia tolerante |
| **Lambda** | Exactitud batch + velocidad stream | **Doble lógica** divergente, costo | Si kappa o batch solo bastan |
| **Kappa** | Una sola ruta (stream + replay) | Retención del log, manejo de estado | Si no puedes reprocesar por replay |
| **Event-driven/CDC** | Desacople, propagación incremental | *Schema drift*, *slot* huérfano, *deletes* | Si la fuente no expone log/eventos fiables |

> Regla: **elige el patrón más simple que cumpla el SLA de *freshness*.** La
> complejidad de streaming solo se justifica con un requisito real de latencia.

## 3. Almacenamiento — lake vs warehouse vs lakehouse

| Opción | Cuándo | Riesgos que vigila caudal |
|---|---|---|
| **Data Lake** (objeto: S3/GCS/ADLS) | Crudo barato, volúmenes masivos, datos semi/no estructurados | "Data swamp" sin gobierno, *small files*, sin ACID |
| **Data Warehouse** (Snowflake/BigQuery/Redshift/Synapse) | SQL/BI gobernado, *concurrency*, semántica | Costo por escaneo/cómputo, modelado, *vendor lock-in* |
| **Lakehouse** (Delta/Iceberg/Hudi sobre lake) | OLAP/BI/ML con ACID sobre almacenamiento barato | *Compaction*, *table maintenance*, gobierno de tablas |
| **Híbrido / poliglota** | Distintas cargas con distintos motores | Consistencia entre copias, costo de duplicación |

- **Formatos de archivo:** Parquet/ORC (columnar analítico), Avro (registro/
  *streaming*), JSON (crudo/flexible).
- **Table formats:** Delta, Iceberg, Hudi → ACID, *time travel*, *schema
  evolution*, *upserts*. Elegir por ecosistema y necesidades de *concurrency*.

## 4. Decisión de partición y disposición física

- **Particiona por** la columna de filtrado más común (frecuentemente fecha) y
  por *granularidad* que evite *small files* y *over-partitioning*.
- **Clustering / Z-order** para columnas de filtro secundarias de alta
  cardinalidad.
- **Compaction** periódica para fusionar *small files* y mantener rendimiento.
- **Tamaño objetivo de archivo:** típicamente 128 MB–1 GB según motor (verificar
  por plataforma; no fijar como dogma).

## 5. Topologías de integración

- **Hub-and-spoke / data hub:** centraliza ingesta y reparte a consumidores.
- **Mesh (data mesh):** dominios dueños de sus *data products* con contratos;
  útil a gran escala organizacional, exige gobierno federado fuerte.
- **Medallion (bronze/silver/gold):** la más común dentro de lake/lakehouse.
- **Punto a punto:** solo para casos simples; escala mal (acoplamiento N×M).

## 6. Feature store y datos AI-ready (frontera con AI Engineer, agente `sysuniversal-ai`)

- **Feature store** (online/offline) para servir *features* consistentes a
  entrenamiento e inferencia; caudal construye el **pipeline de features**
  y la **infra**, el **AI Engineer** (agente `sysuniversal-ai`) es dueño del
  *serving*/modelo.
- **Datos no estructurados / embeddings:** pipelines de extracción,
  *chunking* y generación de *embeddings* hacia un *vector store* (la plataforma
  vectorial la gobierna **andulfo**; el modelo de *embeddings* y el RAG, el **AI
  Engineer**).

## 7. Trade-offs y criterios de decisión (matriz)

Pondera cada opción por atributo (1–5) según el caso:

| Atributo | Peso típico |
|---|---|
| Fiabilidad / consistencia | Alto |
| *Freshness* / latencia | Según caso de uso |
| Costo (almacenamiento + cómputo) | Alto |
| Operabilidad / complejidad | Alto |
| Escalabilidad | Medio/Alto |
| Evitar *lock-in* | Medio |

> Toda decisión arquitectónica relevante se documenta como **ADR de datos** con
> 2–3 alternativas (ver [plantillas.md](plantillas.md)).

## 8. Anti-patrones que caudal bloquea

- **Lecturas masivas contra OLTP** para analítica (usa réplica/CDC/export).
- **Lambda por defecto** cuando batch o kappa bastan (doble mantenimiento).
- **Lake sin gobierno** (data swamp): sin catálogo, sin contratos, sin linaje.
- **Transformaciones no idempotentes** o que mutan la zona cruda.
- **Sobre-particionamiento** y *small files* sin *compaction*.
- **Lock-in** sin justificación ni estrategia de salida.
