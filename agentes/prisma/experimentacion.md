# experimentacion.md — Experimentación e inferencia causal

Cómo Prisma responde preguntas de **impacto** ("¿qué pasa si…?") con rigor:
diseño y análisis de experimentos y, cuando no hay experimento posible, inferencia
**causal** observacional con supuestos explícitos.

Ver [SKILL.md](SKILL.md) §13. Credo: **correlación ≠ causalidad.**

---

## 1. ¿Experimento o predicción?

- **Pregunta predictiva:** "¿qué valor tomará Y?" → modelado ([modelado.md](modelado.md)).
- **Pregunta causal:** "¿cuánto cambia Y si intervengo en X?" → experimento o
  diseño causal. **No** se responde con un modelo predictivo ni con correlaciones.

## 2. Diseño de experimentos (A/B y variantes)

Define **antes** de lanzar:

| Elemento | Descripción |
|---|---|
| **Hipótesis** | Efecto esperado, dirección y magnitud mínima relevante |
| **Unidad de aleatorización** | Usuario, sesión, cluster (cuida interferencia) |
| **Métrica primaria** | Una; alineada a la decisión |
| **Métricas guardrail** | Que no se degraden (latencia, ingresos, churn) |
| **MDE** | *Minimum Detectable Effect* que importa al negocio |
| **Tamaño/potencia** | n para detectar el MDE con α y potencia (típ. 0.05 / 0.8) |
| **Duración** | Cubrir ciclos (semana completa, estacionalidad) |

- **Variantes:** A/B, A/B/n, **multi-arm bandits** (cuando quieres optimizar y
  explotar a la vez), factoriales (varios factores).
- **Aleatorización válida:** verifica balance de covariables (*A/A test*).

## 3. Análisis de experimentos

- **Significancia e intervalos:** reporta el **efecto e intervalo de confianza**,
  no solo el *p-value*.
- **Peeking:** no concluyas mirando resultados a cada rato sin corrección
  (secuencial/*always-valid* o fija la duración).
- **Múltiples comparaciones:** corrige (Bonferroni/BH) si pruebas muchas métricas/
  variantes.
- **Heterogeneidad:** efectos por segmento (CATE), con cuidado de no *p-hackear*.
- **Validez:** *novelty effect*, interferencia entre unidades (red social/
  marketplace), contaminación, *sample ratio mismatch* (SRM).

## 4. Inferencia causal sin experimento (observacional)

Cuando no se puede experimentar, identifica el efecto con supuestos explícitos:

| Método | Idea | Supuesto clave |
|---|---|---|
| **Diff-in-Diff (DiD)** | Compara cambios tratado vs control en el tiempo | Tendencias paralelas |
| **Propensity Score (PSM/IPW)** | Empareja/pondera por probabilidad de tratamiento | *Ignorability* (no confusores ocultos) |
| **Variables instrumentales (IV)** | Usa un instrumento que afecta X pero no Y directo | Instrumento válido y relevante |
| **Regression Discontinuity (RDD)** | Salto en un umbral de asignación | Continuidad alrededor del corte |
| **Uplift / CATE** | Efecto incremental por individuo | Datos de tratamiento/control |

- **Confusores:** identifícalos (DAG causal) y contrólalos; declara los que no
  puedes observar.
- **Sensibilidad:** prueba qué tan robusto es el efecto a violar supuestos.

## 5. Errores comunes que prisma bloquea

- Afirmar **causalidad desde correlación** sin diseño/identificación.
- **Peeking** y parar el test al ver significancia.
- Ignorar **SRM** (proporciones de asignación no esperadas → experimento inválido).
- **MDE/potencia** no calculados → "no significativo" mal interpretado como "no
  efecto".
- **Interferencia** (efectos de red) tratada como unidades independientes.
- Múltiples métricas sin corrección → falso positivo.

## 6. De resultado a decisión

- Traduce el efecto a **impacto de negocio** (e intervalo), considerando costo de
  implementar.
- Recomendación clara: lanzar / no lanzar / iterar, con la **incertidumbre**
  explícita.
- Documenta como **registro de experimento** (ver [plantillas.md](plantillas.md)).

## 7. Reglas de oro de experimentación

1. **Diseña antes de lanzar** (hipótesis, métrica, MDE, potencia, guardrails).
2. **Correlación ≠ causalidad;** sin experimento, supuestos de identificación
   explícitos.
3. **No hagas peeking** ni *p-hacking*.
4. **Reporta efecto + intervalo**, no solo *p-value*.
5. **Verifica validez** (SRM, balance, interferencia, novelty).
6. **La decisión se toma con el negocio (PO/BA);** tú garantizas el rigor.
