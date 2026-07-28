# frameworks.md — Marcos de referencia y fuentes técnicas

Base de conocimiento que Andulfo aplica. Usa el marco correcto según el problema y
**cita la fuente** en los entregables. Verifica versiones/novedades con búsqueda
web cuando la vigencia importe (CVE, EOL, límites de servicio, benchmarks).

---

## 1. Excelencia operativa y arquitectura en la nube

- **AWS Well-Architected Framework** — 6 pilares: Operational Excellence,
  Security, Reliability, Performance Efficiency, Cost Optimization,
  Sustainability. Aplica a diseño/revisión de cargas de datos en la nube.
  - **Data Analytics Lens** y guías específicas de RDS/Aurora/DynamoDB.
- **Azure Well-Architected Framework** — Reliability, Security, Cost
  Optimization, Operational Excellence, Performance Efficiency; guías de Azure
  SQL, Cosmos DB y *data platform security*.
- **Google Cloud Architecture Framework** — equivalente, con foco en datos
  (BigQuery, Spanner, Cloud SQL).
- **Cloud Adoption Framework** (Azure/AWS) — gobierno y *landing zones* de datos.

## 2. Fiabilidad y entrega

- **Google SRE** — SLI/SLO/SLA, *error budgets*, *toil reduction*, gestión de
  incidentes, postmortems sin culpa.
- **DORA** — métricas de rendimiento de entrega (lead time, deployment
  frequency, change failure rate, MTTR); aplica a cambios de base de datos.

## 3. Seguridad y cumplimiento

- **NIST** — SP 800-53 (controles), SP 800-209 (*Security Guidelines for Storage
  Infrastructure* / bases de datos), Cybersecurity Framework (CSF).
- **CIS Benchmarks** — líneas base de *hardening* por motor (PostgreSQL, MySQL,
  SQL Server, Oracle, MongoDB) y por nube.
- **ISO/IEC 27001 / 27002** — SGSI y controles de seguridad de la información.
- **OWASP** — Top 10, **ASVS**, y guía específica de inyección SQL/NoSQL.
- **Regulaciones**: GDPR (UE), HIPAA (salud, EE. UU.), PCI-DSS (tarjetas), SOX
  (financiero), CCPA, y **Ley 1581 / Habeas Data (Colombia)**. Mapea controles
  de datos (cifrado, acceso, retención, auditoría) a cada requisito aplicable.

## 4. Gobierno y gestión de datos

- **DAMA-DMBOK** — cuerpo de conocimiento de gestión de datos: gobierno,
  calidad, modelado, metadatos, seguridad, ciclo de vida, *master data*.
- **Data Mesh / Data as a Product** — descentralización con *ownership* y
  contratos de datos cuando la escala organizativa lo justifique.
- **Data contracts / lineage** — trazabilidad y calidad operativa.

## 4b. Integración e ingeniería de datos (DataOps)

- **DataOps** — principios de CI/CD, pruebas y observabilidad aplicados a
  *pipelines* de datos; entrega de datos confiable y reproducible.
- **Arquitectura medallón** (bronze/silver/gold) y **ELT moderno** (dbt) con
  modelos versionados, incrementales y testeados.
- **CDC** (Change Data Capture) log-based como patrón preferente de replicación e
  ingesta sin impacto en la fuente (Debezium y equivalentes nativos del motor).
- **Data contracts** y **schema registry** (Avro/Protobuf/JSON Schema) con
  compatibilidad *backward/forward*; evolución de esquema sin romper consumidores.
- **Calidad de datos:** Great Expectations / dbt tests / Soda; dimensiones de DQ
  (completitud, unicidad, validez, consistencia, exactitud, *timeliness*).
- **Observabilidad de datos y linaje:** *freshness/volumen/distribución/esquema*,
  *data downtime*, **OpenLineage/Marquez** para linaje columna-a-columna.
- **MDM** (Master Data Management): *golden record*, *matching/survivorship*.
- Detalle operativo en [integracion.md](integracion.md).

## 5. Modelado de datos

- **Modelo relacional** (Codd), formas normales (1FN–BCNF) y desnormalización
  dirigida por rendimiento.
- **Kimball** (modelado dimensional, *star/snowflake schema*) e **Inmon** (CIF)
  para data warehousing.
- **Data Vault 2.0** — modelado ágil y auditable para DW empresariales.
- **Modelado NoSQL** — *query-first*, *single-table design* (DynamoDB), modelado
  documental y de grafo por patrones de acceso.

## 6. Teoría y fundamentos

- **CAP** y **PACELC** — trade-offs de consistencia/disponibilidad/latencia en
  sistemas distribuidos.
- **Niveles de aislamiento ANSI** y anomalías (*dirty/non-repeatable/phantom*).
- **MVCC**, *write-ahead logging*, *LSM-tree* vs *B-tree*, teoría de índices.
- **Teorema de la base de datos**: durabilidad vs latencia vs disponibilidad.
- Lectura de referencia: *Designing Data-Intensive Applications* (Kleppmann).

## 7. Código y automatización crítica

- **NASA/JPL Power of 10** — reglas para scripts/automatización DBA crítica:
  control de flujo simple, límites acotados, validación de retornos y parámetros,
  análisis estático en cada cambio.
- **12-Factor App** (config/secretos fuera del código) aplicado a servicios de
  datos y *backing services*.
- **IaC**: Terraform, Bicep, CloudFormation, Pulumi. **Policy-as-code**: OPA/
  Conftest, Sentinel. **Migraciones**: Flyway, Liquibase, Alembic, Sqitch.

## 8. Continuidad y resiliencia

- **Patrones de DR**: backup&restore, pilot light, warm standby, multi-site
  active/active (clasificación por RTO/RTO decreciente y costo creciente).
- **Regla 3-2-1-1-0** de backups (3 copias, 2 medios, 1 offsite, 1 offline/
  inmutable, 0 errores verificados).
- **Chaos / Game Days** — validación práctica de resiliencia y runbooks.

## 9. Observabilidad

- **Golden Signals** (latencia, tráfico, errores, saturación) y **USE/RED**.
- **OpenTelemetry** para trazas/métricas/logs; instrumentar la BD en los *spans*.
- Stacks: Prometheus + Grafana, CloudWatch, Azure Monitor, Cloud Monitoring;
  *exporters* y vistas nativas (pg_stat_*, Performance Schema, Query Store, AWR).

## 10. Documentación oficial por motor (autoridad final)

La **documentación oficial del motor y del proveedor** es la fuente de verdad
para sintaxis, límites, parámetros y *security best practices*. Verifica siempre
la versión exacta en uso. Mantén un seguimiento de *release notes*, *security
advisories* (CVE) y fechas de **fin de soporte (EOL)** de cada motor.

---

## Cómo citar en entregables

- Indica el marco/fuente y, cuando aplique, la versión: p. ej. "Según AWS WAF
  (pilar Reliability)" o "CIS PostgreSQL Benchmark §X".
- Si verificaste con búsqueda web por vigencia, indícalo y la fecha de consulta.
- Distingue **hecho verificado** de **[SUPUESTO]** o recomendación general.
