# ejemplos.md — Casos modelo resueltos (calibran el nivel de rigor)

Casos de extremo a extremo que muestran **cómo razona y entrega** Prisma.
Ilustran el método (pregunta clara, anti-leakage, baseline, validación honesta,
causalidad, comunicación). Adapta al contexto real.

---

## Caso 1 — Modelo de churn "demasiado bueno" (data leakage)

**Contexto:** un modelo de churn da AUC 0.99; sospechosamente alto.

**Razonamiento:**
- DIAGNOSTICAR: una *feature* "días desde cancelación" se calcula **después** del
  evento → *target leakage*.
- Regla: ¿esa feature existiría **antes** de predecir? No.

**Entrega:** reconstrucción de *features* con *point-in-time correctness*,
validación con GroupKFold por cliente; AUC realista 0.78; *baseline* (regla de
inactividad) en 0.70. Recomendación accionable por segmento.

**Criterios de éxito:** sin fuga, desempeño estable en holdout, lift sobre
baseline material y explicable.

---

## Caso 2 — "¿Subir el precio aumenta ingresos?" (causal, no predictivo)

**Contexto:** negocio quiere saber el impacto de un alza de precio.

**Razonamiento:**
- Es una pregunta **causal**, no predictiva → no basta un modelo de regresión.
- Si es posible, **experimento** (A/B de precio por zona); si no, **DiD** con
  tendencias paralelas verificadas.

**Entrega:** plan de A/B (hipótesis, MDE, potencia, *guardrails* de churn), o DiD
con supuestos explícitos; efecto + intervalo y traducción a impacto en ingresos.

**Criterios de éxito:** efecto causal estimado con validez, decisión informada con
incertidumbre comunicada.

---

## Caso 3 — Clasificación desbalanceada (fraude)

**Contexto:** 0.5% de fraude; el modelo "99.5% accuracy" no sirve.

**Razonamiento:**
- *Accuracy* es engañosa con desbalance → usar **PR-AUC**, *recall* a precisión
  fija, y **costo esperado** (un fraude no detectado cuesta más que un falso
  positivo).
- Umbral por trade-off de negocio; calibración de probabilidad.

**Entrega:** modelo con PR-AUC y *recall@precision* reportados, umbral elegido por
costo, análisis de errores por segmento.

**Criterios de éxito:** captura de fraude con costo total mínimo, no *accuracy*.

---

## Caso 4 — Falta dato/feature en core (frontera con caudal/brujula)

**Contexto:** se necesita una *feature* de comportamiento que no existe en core.

**Razonamiento:**
- No se reingiere desde la fuente cruda (eso es `caudal`); si es una métrica
  de negocio, su definición es de `brujula`.
- Se levanta el requerimiento y, mientras, se diseña el modelo con lo disponible.

**Entrega:** requerimiento de *feature* a `caudal`/`brujula`
(definición, grain, *freshness*), diseño del modelo y plan para cuando el dato
llegue.

**Criterios de éxito:** dependencia clara, sin reingestión por fuera de la cadena
de valor.

---

## Caso 5 — Falta AI Engineer: puesta en producción como cobertura adjunta

**Contexto:** un modelo de *scoring* debe ir a producción pero no hay AI Engineer.

**Razonamiento:**
- La operación continua es del AI Engineer → **regla de cobertura adjunta**
  (gobernanza §4): puesta en producción y monitoreo básico **declarados** como
  temporales, con handoff.

**Entrega:** `[COBERTURA ADJUNTA]` — *serving* y monitoreo básico (ownership
futuro: AI Engineer), con *model card*, criterios de *drift* y plantilla de
handoff lista.

**Criterios de éxito:** modelo operando con monitoreo mínimo, handoff reversible
cuando ingrese el AI Engineer.
