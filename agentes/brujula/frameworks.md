# frameworks.md — Marcos de trabajo y fuentes técnicas

Marcos y referencias que fundamentan las decisiones de Brujula. Se usan
como **guía, no como dogma**: la neutralidad tecnológica manda y toda afirmación de
capacidad/"mejor opción" se **verifica con búsqueda web** antes de fijarla (ver
[SKILL.md](SKILL.md) §27).

---

## 1. Modelado de datos

- **Kimball / Dimensional Modeling:** hechos y dimensiones, *grain*, *bus matrix*,
  dimensiones conformadas, SCD (1/2/3), tipos de hechos (transaccional, snapshot,
  accumulating, factless).
- **Inmon / Data Vault:** referencia para escenarios de integración empresarial
  (no es el default de la capa de consumo, pero se conoce).
- **OBT / wide tables:** desnormalización para *self-service* y motores columnar.

## 2. Transformación y analytics engineering

- **dbt (best practices):** capas staging/intermediate/marts, modelos
  incrementales, snapshots, tests, docs, *exposures* — como **referencia de
  prácticas**, sin atarse a la herramienta.
- **Analytics Engineering** (rol y prácticas): el puente entre data engineering y
  analistas; *software engineering* aplicado a la analítica (versionado, CI,
  tests, modularidad).

## 3. Capa de métricas / semantic layer

- **Métricas como código:** dbt Semantic Layer / MetricFlow, Cube, LookML — define
  una vez, consume consistente. "Una métrica, una definición".
- **Headless BI:** desacoplar la definición de métricas de la herramienta de
  visualización.

## 4. Calidad y gobierno

- **DAMA-DMBOK:** calidad de datos, metadatos, gobierno, ciclo de vida.
- **Data contracts / data products:** contratos productor↔consumidor; en esta capa,
  contratos de **consumo**.
- **OpenLineage:** linaje para análisis de impacto y cumplimiento.

## 5. DataOps y entrega

- **DataOps:** automatización, pruebas continuas, *monitoring* y colaboración.
- **Google SRE / DORA:** SLI/SLO aplicados a *freshness* y disponibilidad de la
  capa; métricas de entrega.
- **CI/CD analítico:** *gates* de tests, *deferral*/*state*, despliegue por
  dominio, *deprecation* controlada.

## 6. Seguridad y cumplimiento (aplicado a consumo)

- **Exposición mínima de PII** en marts; control de acceso a métricas/modelos —
  coordinado con **destroyer** y **andulfo**.
- **GDPR / PCI-DSS / HIPAA / Ley 1581 (Habeas Data, Colombia)** según dominio.

## 7. BI / consumo

- Conocimiento de cómo consumen **Looker, Power BI, Tableau, Metabase, Superset**
  para modelar pensando en el consumo (sin favorecer ninguno).

---

> La documentación oficial de cada herramienta y las guías del proveedor del
> warehouse prevalecen sobre cualquier resumen aquí. Revisa prácticas y versiones
> periódicamente.
