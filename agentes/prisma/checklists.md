# checklists.md — Checklists operativos de Data Science

Checklists accionables de Prisma. Úsalos como *gates* antes de modelar,
experimentar o entregar. Resumen en [SKILL.md](SKILL.md) §23.

---

## 1. Encuadre del problema (antes de tocar datos)

- [ ] Pregunta de negocio y decisión/impacto explícitos (con PO/BA)
- [ ] ¿Predictivo o causal? definido
- [ ] Variable objetivo / evento bien definido (sin ambigüedad)
- [ ] Unidad de análisis (grain) y horizonte temporal
- [ ] Métrica de éxito de negocio y restricciones (latencia, costo, explicabilidad)
- [ ] *Baseline* contra el que se medirá el valor

## 2. Datos y EDA

- [ ] Datos de core/semantic layer (caudal/brujula); no reingestión
- [ ] Representatividad y etiquetado verificados
- [ ] Calidad evaluada (nulos, duplicados, rangos, consistencia)
- [ ] Distribuciones, *drivers*, segmentos y anomalías explorados
- [ ] Señales de posible *data leakage* marcadas
- [ ] Versión del dataset congelada (reproducibilidad)

## 3. Feature engineering

- [ ] Cada feature pasa la prueba "¿existiría antes de predecir?" (anti-leakage)
- [ ] *Point-in-time correctness* en features temporales
- [ ] Transformaciones ajustadas **solo en train** (pipeline)
- [ ] Consistencia train/serving asegurada
- [ ] Reutiliza métricas certificadas de brujula
- [ ] Features documentadas (fuente, ventana, transformación, owner)

## 4. Modelado y validación

- [ ] *Baseline* implementado
- [ ] *Split*/CV adecuados al dato (temporal/grupo) y anti-leakage
- [ ] Métrica alineada al costo de error; umbral justificado
- [ ] Calibración verificada (si la probabilidad decide)
- [ ] Comparación contra baseline con intervalos/incertidumbre
- [ ] Análisis de errores y de robustez/estabilidad
- [ ] Explicabilidad acorde al riesgo
- [ ] Auditoría de sesgo/*fairness* (modelos que afectan personas)

## 5. Experimentación (si aplica)

- [ ] Hipótesis, métrica primaria y *guardrails* definidos *a priori*
- [ ] MDE y tamaño/potencia calculados antes de lanzar
- [ ] Aleatorización válida (A/A, balance, sin SRM)
- [ ] Sin *peeking*; corrección por múltiples comparaciones
- [ ] Efecto + intervalo reportados (no solo *p-value*)
- [ ] Validez revisada (interferencia, novelty)

## 6. Reproducibilidad y entrega

- [ ] Semillas fijadas; entorno y dependencias versionados
- [ ] Experimentos registrados (tracking)
- [ ] Resultado reproducible por un tercero
- [ ] Recomendación accionable con impacto e incertidumbre
- [ ] *Model card* y especificación para AI Engineer (si va a producción)
- [ ] Trabajo fuera del foco marcado `[COBERTURA ADJUNTA]` con handoff
