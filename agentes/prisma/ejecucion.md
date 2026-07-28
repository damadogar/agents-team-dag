# ejecucion.md — Método reproducible de trabajo de Data Science

Método **agnóstico de técnica/librería** para abordar cualquier problema de Data
Science con **rigor y reproducibilidad**. Un resultado que no se puede reproducir
**no es válido**.

Secuencia: **FRAME → DATA → EDA → FEATURES → MODEL → VALIDATE → INTERPRET →
HANDOFF**, sobre una base de **reproducibilidad** y *experiment tracking*.

> Regla 0: **sin pregunta clara, no hay modelo.** Y nunca uses PII real sin
> autorización (entorno desconocido = producción).

---

## 1. FRAME — encuadrar el problema

- Define la **pregunta de negocio** y la **decisión/impacto** buscado (con PO/BA).
- Determina si es **predictiva** o **causal** (cambia todo el método).
- Define la **variable objetivo**/evento, la **unidad de análisis** (grain) y el
  **horizonte temporal**.
- Define la **métrica de éxito de negocio** y las restricciones (latencia, costo,
  explicabilidad, regulación).
- Establece el **baseline** contra el que se medirá el valor.

## 2. DATA — obtener el dato preparado

- Usa datasets de `caudal` (core) y métricas de `brujula`; **no
  reingieras**.
- Verifica representatividad, etiquetado y calidad (ver
  [exploracion.md](exploracion.md)).
- **Congela** una versión del dataset (versión/hash) para reproducibilidad.
- Maneja PII según política (minimiza/anonimiza; coordina con destroyer/andulfo).

## 3. EDA — explorar

- Calidad, distribuciones, relaciones, *drivers*, segmentos, anomalías.
- Formula **hipótesis** explícitas; marca señales de posible *leakage*.

## 4. FEATURES — construir sin fuga

- Construye *features* con **point-in-time correctness** y **consistencia
  train/serving** (ver [feature-engineering.md](feature-engineering.md)).
- Empaqueta el preprocesamiento en un **pipeline** (ajuste solo en train).

## 5. MODEL — entrenar candidatos

- Empieza por el **baseline** y sube en complejidad solo si paga.
- Registra cada experimento (parámetros, datos, código, métricas) en *tracking*.
- Fija **semillas** y entorno (dependencias) para reproducibilidad.

## 6. VALIDATE — validar honestamente

- *Split*/CV adecuados (temporal/grupo), **anti-leakage**, *nested CV* para tuning.
- Métricas alineadas a la decisión + intervalos; **calibración** si aplica.
- **Análisis de errores** y de **sesgo/fairness**; robustez y estabilidad.
- Compara contra *baseline*; el test se usa **una sola vez** al final.

## 7. INTERPRET — explicar y contextualizar

- Explicabilidad acorde al riesgo (SHAP/importance/PDP).
- Traduce a **impacto de negocio** con **incertidumbre** (ver
  [comunicacion.md](comunicacion.md)).
- Declara **limitaciones y supuestos**.

## 8. HANDOFF — entregar

- Si va a producción: **especificación** para el **AI Engineer** (artefacto,
  *features* y su lógica, latencia, criterios de monitoreo/*drift*) + **model
  card**.
- Si es un análisis *one-off*: informe reproducible + recomendación.
- Si asumes operación por ausencia de AI Engineer: **[COBERTURA ADJUNTA]** con
  handoff (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §4).

---

## 9. Reproducibilidad (base transversal)

- **Versionado:** datos (versión/hash), código (git), entorno (lockfile),
  experimentos (MLflow/W&B u otro).
- **Semillas** fijadas y documentadas.
- **Determinismo:** evita estado oculto; un tercero reproduce el resultado.
- **Documentación:** decisiones, supuestos y *caveats* registrados.

## 10. Guardas para trabajo de alto riesgo

| Situación | Guarda mínima |
|---|---|
| Modelo que decide sobre **personas** | Explicabilidad + auditoría de sesgo + revisión |
| Afirmación **causal** | Experimento o diseño de identificación con supuestos |
| Uso de **PII** | Autorización, minimización/anonimización (destroyer/andulfo) |
| **Handoff a producción** | Especificación + model card + criterios de monitoreo |
| Resultado que cambia una **decisión crítica** | Reproducibilidad verificada + incertidumbre comunicada |
