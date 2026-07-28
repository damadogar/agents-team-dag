# frameworks.md — Marcos de trabajo y fuentes técnicas

Marcos y referencias que fundamentan las decisiones de Prisma. Se usan como
**guía, no como dogma**: la neutralidad tecnológica manda y toda afirmación de
"mejor modelo/método" se **verifica** antes de fijarla (ver [SKILL.md](SKILL.md)
§27).

---

## 1. Proceso de data science

- **CRISP-DM:** comprensión del negocio → comprensión del dato → preparación →
  modelado → evaluación → despliegue. Referencia clásica de ciclo.
- **TDSP (Team Data Science Process, Microsoft):** ciclo iterativo con roles y
  entregables.
- **Pregunta primero:** ninguna metodología sustituye un buen encuadre de la
  pregunta de negocio.

## 2. Estadística e inferencia

- **Inferencia frecuentista y bayesiana:** pruebas de hipótesis, intervalos,
  *bootstrap*, modelos jerárquicos.
- **Diseño experimental:** A/B, factorial, multi-arm; potencia y tamaño de muestra.
- **Buenas prácticas de testing online:** evitar *peeking*, SRM, corrección por
  múltiples comparaciones (referencias de experimentación de Kohavi et al.).

## 3. Inferencia causal

- **Marco de resultados potenciales (Rubin)** y **DAGs (Pearl)**.
- Métodos: **Diff-in-Diff, Propensity Score (matching/IPW), Variables
  Instrumentales, Regression Discontinuity, Uplift modeling**.
- Supuestos de identificación explícitos; análisis de sensibilidad.

## 4. Machine learning

- **Validación honesta:** *cross-validation* adecuada (temporal/grupo), *nested
  CV*, anti-leakage (referencias de *The Elements of Statistical Learning*).
- **GBM** (XGBoost/LightGBM/CatBoost) para tabular; lineales/regularizados como
  *baseline*; *deep learning* para no estructurado.
- **Calibración de probabilidades** (Platt, isotónica) cuando la probabilidad
  decide.

## 5. Explicabilidad y Responsible AI

- **Explicabilidad:** SHAP, LIME, *permutation importance*, *partial dependence*.
- **Fairness:** métricas de disparidad (paridad demográfica, *equalized odds*),
  *bias auditing*; trade-offs documentados.
- **Marcos:** NIST AI Risk Management Framework, principios de *responsible/
  trustworthy AI*; *model cards* y *datasheets for datasets*.
- **Privacidad:** anonimización, minimización de PII; coordinación con destroyer.

## 6. Reproducibilidad y MLOps (frontera)

- **Reproducibilidad:** versionado de datos/código (git, DVC), *experiment
  tracking* (MLflow/W&B), entornos (contenedores/lockfiles), semillas.
- **MLOps (ownership del AI Engineer):** *serving*, *monitoring*, *drift*,
  *retraining*; prisma **especifica y entrega**, no opera (ver
  [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §6.3).

## 7. Comunicación

- **Storytelling con datos** y visualización honesta (referencias tipo
  Tufte/Knaflic): conclusión primero, incertidumbre visible, sin distorsión de
  ejes/escalas.

---

> La documentación oficial de librerías/herramientas y el *state of the art*
> evolucionan; revisa periódicamente y valida antes de adoptar. Ningún modelo o
> método es "el mejor" fuera de su contexto.
