# frameworks.md — Marcos de trabajo y fuentes técnicas

Marcos y referencias que fundamentan las decisiones de Caudal. Se usan como
**guía, no como dogma**: la neutralidad tecnológica manda y toda afirmación de
capacidad/límite/"mejor opción" se **verifica con búsqueda web** antes de fijarla
(ver [SKILL.md](SKILL.md) §27).

---

## 1. DataOps y entrega de datos

- **DataOps** (principios DataOps Manifesto): automatización, pruebas continuas de
  datos, *monitoring*, colaboración y entrega iterativa.
- **Google SRE / DORA:** SLI/SLO/error budget aplicados a *freshness* y
  fiabilidad; métricas de entrega (lead time, *change failure rate*).
- **CI/CD de datos:** *gates* de calidad, *expand/contract*, despliegue repetible.

## 2. Gobierno y gestión de datos

- **DAMA-DMBOK:** áreas de conocimiento de gestión de datos (calidad, metadatos,
  arquitectura, seguridad, integración, ciclo de vida).
- **Data contracts / data products / data mesh:** ownership por dominio, contratos
  productor↔consumidor, gobierno federado.
- **OpenLineage / Marquez:** estándar de linaje para análisis de impacto y
  cumplimiento.

## 3. Arquitectura cloud (lentes de datos)

- **AWS Well-Architected** + **Data Analytics Lens**.
- **Azure Well-Architected** y guías de analítica/datos de Microsoft.
- **Google Cloud Architecture Framework** (analítica/datos).
- Pilares transversales: fiabilidad, seguridad, eficiencia de rendimiento, costo,
  excelencia operativa, sostenibilidad.

## 4. Procesamiento y formatos

- **Lambda / Kappa:** referencias clásicas de arquitectura de procesamiento de big
  data (Marz; Kreps "Questioning the Lambda Architecture").
- **Table formats:** Delta Lake, Apache Iceberg, Apache Hudi (ACID, *time travel*,
  *schema evolution*, *upserts*).
- **Formatos columnar/registro:** Parquet, ORC, Avro.
- **Streaming:** Kafka / Flink / Kafka Streams / Spark Structured Streaming;
  semánticas *at-least-once* vs *exactly-once*.

## 5. Calidad y observabilidad

- **Great Expectations / dbt tests / Soda:** pruebas de datos declarativas.
- **Data observability** (pilares: *freshness*, volumen, distribución, esquema,
  linaje); *data downtime* y MTTD/MTTR de datos.

## 6. Seguridad y cumplimiento (aplicado a pipelines)

- **OWASP** (Top 10, ASVS) para superficies expuestas por pipelines/APIs.
- **NIST / CIS** como líneas base; **GDPR, PCI-DSS, HIPAA, Ley 1581 (Habeas Data,
  Colombia)** según dominio — coordinado con **destroyer** y **andulfo**.

## 7. Automatización crítica

- **NASA/JPL Power of 10** para scripts/automatización crítica (simplicidad,
  límites, verificación).

---

> Documentación oficial de cada herramienta/motor y *security best practices* del
> proveedor prevalecen sobre cualquier resumen aquí. Revisar versiones, EOL y
> *advisories* periódicamente.
