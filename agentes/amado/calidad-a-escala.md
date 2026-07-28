# Calidad a escala y Quality Engineering (grado hyperscaler)

Módulo de élite de Amado para operar como **Quality Engineering** al nivel de
Google/Meta/Microsoft/AWS: inteligencia de calidad, selección predictiva de
pruebas, datos y entornos a escala, *testing in production* y madurez
organizacional.

> Principio rector: **a escala, no se prueba "todo"; se prueba lo correcto, en el
> momento correcto, automáticamente.** La calidad se vuelve un problema de datos,
> infraestructura y plataforma, no solo de casos de prueba.

---

## 1. Modelo operativo de QE (cómo se organizan los mejores)

- **"You build it, you test it"** + **SET/SETI** (Google: Software Engineer in
  Test): QE construye herramientas y plataformas, no solo ejecuta casos.
- **Quality as a Platform / Enabling team** (Team Topologies): QE provee
  frameworks, datos, entornos y *gates* como producto interno self-service.
- **Embedded quality:** calidad dentro del equipo de producto, no un gate externo
  tardío.
- **Shift-left** (prevención en diseño) **+ shift-right** (aprendizaje en prod).

---

## 2. Inteligencia de calidad (Quality Intelligence)

- **Test Impact Analysis (TIA):** ejecuta solo las pruebas afectadas por un
  cambio (Microsoft, Google) → minutos en vez de horas.
- **Predictive Test Selection (PTS):** ML que prioriza pruebas con mayor
  probabilidad de fallar dado el *diff* (Meta) — corre el 1-5% y atrapa el ~95%.
- **Flaky test detection:** identificación automática (re-runs, ML, análisis de
  varianza), cuarentena y *scoring* de estabilidad.
- **Defect prediction / hotspots:** *code churn × complejidad × historial de
  bugs* para predecir módulos riesgosos y enfocar pruebas.
- **Risk-based gating con datos:** el *gate* de release se alimenta de telemetría,
  no de opinión.

---

## 3. Optimización de la suite de regresión a escala

- Selección por riesgo + TIA/PTS; paralelización masiva; *sharding*; cachés de
  build/test (Bazel, Nx).
- Eliminación de pruebas redundantes (cobertura solapada) y *flaky*.
- Presupuesto de tiempo del pipeline como SLO (ej. PR feedback < 10 min).

---

## 4. Gestión de datos de prueba (Test Data Management)

- **Generación sintética** (Faker, Synthea, GANs/LLM para datos realistas).
- **Subsetting + masking** de producción (referential-integrity-aware),
  *tokenización*/anonimización para PII (GDPR/HIPAA/PCI/Habeas Data).
- **Datos como servicio:** *self-service*, seedable y determinista; *factories*.
- Aislamiento por test, *cleanup*/teardown, datos efímeros por ejecución.

---

## 5. Service virtualization y aislamiento de dependencias

- **Mocks/stubs/contract** + **service virtualization** (WireMock, mountebank,
  Hoverfly, Mockoon) para probar sin dependencias reales inestables/caras.
- **Consumer-Driven Contracts** (Pact) a escala entre cientos de servicios.
- Simulación de fallos de dependencia (latencia, errores) para resiliencia.

---

## 6. Entornos de prueba efímeros / on-demand

- **Preview/ephemeral environments** por PR (levantados y destruidos por IaC).
- **Testcontainers** para dependencias reales en contenedores dentro del test.
- Kubernetes namespaces efímeros, *infrastructure as code* para paridad con prod.
- Beneficio: paridad, aislamiento, reproducibilidad, costo controlado.

---

## 7. Testing in production / Shift-right

- **Progressive delivery:** *feature flags*, **canary**, **blue-green**,
  **ring deployment**, *percentage rollout* con *auto-rollback* por métricas.
- **Shadow / dark traffic:** envía tráfico real a la nueva versión sin afectar al
  usuario; compara salidas (diff testing en prod).
- **A/B testing y experimentación** con significancia estadística.
- **Synthetic monitoring** (smoke continuo externo) + **RUM** (Real User
  Monitoring).
- **Observability-driven testing:** SLI/SLO + *error budgets* como *gate* de
  release; *fault injection* en prod controlado.
- **Chaos en producción** (con blast radius) — ver `verificacion-avanzada.md`.

---

## 8. Internacionalización y localización (i18n / l10n)

- Locale, formatos (fecha/número/moneda), husos horarios, calendarios.
- **RTL** (árabe/hebreo), encoding (UTF-8, *emoji*, *grapheme clusters*).
- **Pseudo-localización** para detectar *hardcoded strings* y *truncation*.
- Pruebas de traducción, expansión de texto, *fallbacks* de idioma.

---

## 9. Testing de pipelines de datos / analítica

- **Dimensiones de calidad de datos:** completitud, exactitud, consistencia,
  unicidad, validez, *timeliness*.
- **Data contracts** y validación en cada etapa (Great Expectations, dbt tests,
  Soda, Pandera).
- **Reconciliación** origen↔destino, conteos, *checksums*; pruebas de
  idempotencia y reprocesamiento; *backfill*.
- Linaje y trazabilidad; *freshness* y *volume anomaly detection*.

---

## 10. Continuidad: validación de DR y backups (coord. con SRE/DBA)

- Probar **restore** (no solo backup), *failover* y *failback*; medir RTO/RPO
  reales en simulacros. Un backup no verificado no existe.

---

## 11. Economía de la calidad (FinOps de QA)

- **Cost of Quality:** costo de prevención + evaluación vs costo de fallo
  (interno/externo). Optimiza el total, no una parte.
- **ROI de automatización:** mantenimiento vs valor; evita automatizar lo volátil.
- **FinOps de infra de test:** *right-sizing* de runners, paralelismo vs costo,
  *spot* para cargas de fuzz/carga.

---

## 12. Madurez y gobierno de la calidad

- **Modelos de madurez:** **TMMi** (niveles 1-5), TPI Next; *assessment* y
  *roadmap* de mejora.
- **Quality gates as code / policy-as-code** (OPA/Conftest) para releases.
- **Métricas de organización:** DORA + calidad (fuga, estabilidad) por equipo;
  *quality scorecards*.
- **Programas:** dogfooding, beta/crowd testing, **bug bounty**, *error budgets*.

---

## 13. Checklist de calidad a escala

```
- [ ] ¿TIA/PTS reducen el tiempo de regresión sin perder cobertura efectiva?
- [ ] ¿Flaky tests detectados, en cuarentena y con causa raíz?
- [ ] ¿Defect prediction/hotspots guían el foco de pruebas?
- [ ] ¿Datos de prueba sintéticos/enmascarados, deterministas y conformes?
- [ ] ¿Dependencias virtualizadas + contract testing entre servicios?
- [ ] ¿Entornos efímeros por PR con paridad de producción?
- [ ] ¿Progressive delivery con canary + auto-rollback por SLO?
- [ ] ¿Synthetic + RUM + observabilidad como gate de release?
- [ ] ¿i18n/l10n y calidad de datos cubiertos donde aplica?
- [ ] ¿Madurez (TMMi) evaluada con roadmap; quality gates as code?
```
