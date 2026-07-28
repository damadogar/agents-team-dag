# modelado.md — Modelado, métricas y validación

Cómo Prisma elige, entrena, valida y compara modelos con **rigor** y
**neutralidad de técnica**. El modelo más simple que cumple gana; la validación
honesta importa más que un punto extra de métrica.

Ver [SKILL.md](SKILL.md) §10, §12. Reproducibilidad en [ejecucion.md](ejecucion.md).

---

## 1. Selección de enfoque por problema

| Problema | Familias candidatas | Notas |
|---|---|---|
| **Regresión** | Lineal/regularizada (Ridge/Lasso), GBM, redes | Empieza simple; GBM para no linealidad/tabular |
| **Clasificación** | Logística, árboles, GBM (XGBoost/LightGBM), SVM | Logística como *baseline* explicable |
| **Clustering** | K-means, jerárquico, DBSCAN, GMM | Escala/normaliza; valida estabilidad |
| **Series de tiempo** | ETS/ARIMA, GBM con *features* temporales, jerárquicos | Validación temporal estricta |
| **Recomendación** | Colaborativo, contenido, híbrido, *embeddings* | Cuida *cold start* y sesgo de popularidad |
| **Causal/uplift** | DiD, PSM, IV, *uplift trees* | Ver [experimentacion.md](experimentacion.md) |
| **NLP/visión** | Transformers/*transfer learning* | Solo si el costo/beneficio supera a ML clásico |

> Regla: **baseline primero** (media, regla simple, modelo lineal). Un modelo
> complejo solo se justifica si supera al *baseline* de forma material.

## 2. Partición y validación (anti-leakage)

- **Split honesto:** train / validation / test; el test **no** se toca hasta el
  final.
- **Validación cruzada** apropiada al dato:
  - **K-fold** para datos i.i.d.;
  - **StratifiedKFold** para clases desbalanceadas;
  - **GroupKFold** cuando hay entidades repetidas (no mezcles el mismo cliente en
    train y test);
  - **validación temporal** (*forward chaining*) para series: nunca entrenes con
    el futuro.
- **Nested CV** para *tuning* de hiperparámetros sin contaminar la estimación.
- **Fuga (leakage) frecuente:** escalado/imputación ajustados sobre todo el
  dataset, *target encoding* sin CV, *features* con información del futuro.

## 3. Métricas según la decisión

| Tipo | Métricas | Cuándo |
|---|---|---|
| Regresión | RMSE, MAE, MAPE, R² | RMSE penaliza grandes errores; MAE robusto |
| Clasificación | ROC-AUC, **PR-AUC**, F1, recall, precision | PR-AUC y recall en clases raras/desbalance |
| Probabilidad | *log loss*, **calibración** (Brier, *reliability*) | Cuando la probabilidad se usa para decidir |
| Ranking/recom | Recall@k, NDCG, MAP, cobertura | Sistemas de recomendación |
| Series | RMSE, MAPE, *pinball loss* | *Pinball* para cuantiles/intervalos |
| Negocio | Costo esperado, *lift*, ROI | Traduce la métrica técnica a impacto |

- **Elige la métrica por el costo de error**, no por costumbre. Define el **umbral**
  de clasificación según el trade-off precision/recall del negocio.
- **Calibración:** si la probabilidad alimenta una decisión (precio, riesgo),
  calíbrala (Platt/Isotónica) y verifícala.

## 4. Comparación, robustez y análisis de errores

- **Contra baseline** y entre candidatos con la **misma** validación y métrica.
- **Intervalos/incertidumbre** de la métrica (CV *folds*, *bootstrap*).
- **Análisis de errores:** ¿dónde falla?, ¿en qué segmentos?, ¿qué casos?
- **Robustez:** sensibilidad a *outliers*, a cambios de distribución, estabilidad
  temporal.
- **Parsimonia:** ante empate, gana el modelo más simple/explicable/barato de
  operar (coordina operabilidad con el AI Engineer).

## 5. Explicabilidad

- **Globales:** *feature importance*, SHAP *summary*, *partial dependence*.
- **Locales:** SHAP/LIME por predicción para casos críticos.
- **Modelos intrínsecamente interpretables** (lineales, árboles poco profundos,
  *scorecards*) cuando la decisión lo exige (riesgo, crédito, salud).
- **Acorde al riesgo:** a mayor impacto sobre personas, mayor exigencia de
  interpretabilidad y auditoría de sesgo.

## 6. Overfitting / underfitting

- **Overfitting:** gran *gap* train↔validation → regulariza, simplifica, más datos,
  *early stopping*, menos *features*.
- **Underfitting:** mal en train y validation → más capacidad/*features*, mejor
  representación.
- **Curvas de aprendizaje** para diagnosticar datos vs capacidad.

## 7. Reglas de oro de modelado

1. **Baseline obligatorio**; el complejo debe ganarle de forma material.
2. **Validación honesta**: anti-leakage, split/CV adecuados al dato.
3. **Métrica = decisión y costo de error**, con umbral justificado.
4. **Calibra** si la probabilidad decide.
5. **Explica** acorde al riesgo; audita sesgo.
6. **El modelo vive en un contexto:** evalúa contra uso real y operabilidad.
7. **Reproducible**: semilla, versión de datos/código, *experiment tracking*.
