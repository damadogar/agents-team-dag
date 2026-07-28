# Testing de sistemas de IA, LLM y ML (grado Anthropic / OpenAI / DeepMind)

Módulo de élite de Amado para **sistemas no deterministas**: LLMs, agentes, RAG,
modelos de ML clásico y pipelines de datos. Aquí está la diferencia entre un QA
tradicional y uno capaz de certificar productos de IA de frontera.

> Principio rector: **en IA no se "pasa/falla" un caso, se mide una distribución.**
> La calidad se gestiona con *evals* estadísticamente significativas, no con
> aserciones binarias. Todo cambio de modelo o prompt es un cambio de
> comportamiento que requiere regresión de evals.

---

## 1. Probar lo no determinista (fundamentos)

- **Salida estocástica:** fija `seed`/`temperature=0` para reproducibilidad donde
  se pueda; cuando no, mide sobre **N muestras** con intervalos de confianza.
- **Oráculo difuso:** no hay "resultado esperado exacto" → usa rúbricas,
  *LLM-as-judge*, *property checks*, *reference-based* y *human eval*.
- **Sensibilidad al prompt:** prueba invariancia ante paráfrasis, orden, idioma y
  formato; mide varianza entre *seeds*.
- **No regresión silenciosa:** un upgrade de modelo puede mejorar una métrica y
  degradar otra (capability vs safety). Mide el **vector completo**, no una cifra.

---

## 2. Eval-driven development (el corazón)

Flujo: **dataset dorado → métricas → baseline → cambio → comparar → gate en CI.**

### 2.1 Datasets de evaluación
- *Golden set* curado por humanos + casos adversariales + *long tail* + casos de
  producción muestreados (con consentimiento/anonimización).
- **Slicing:** segmenta por idioma, dominio, dificultad, tipo de usuario; un
  promedio alto puede ocultar un *slice* roto.
- Versiona el dataset; evita contaminación train/test (data leakage).

### 2.2 Métodos de evaluación
| Método | Cuándo | Notas |
|---|---|---|
| **Exact match / F1** | Salida estructurada/clasificación | Barato, objetivo |
| **Reference-based** (BLEU/ROUGE/BERTScore) | Resúmenes/traducción | Correlación débil con calidad real; usar con cuidado |
| **LLM-as-judge** | Calidad abierta, a escala | Validar contra humanos; cuidar *bias* de posición/verbosidad/auto-preferencia |
| **Rúbrica / grading guiado** | Criterios explícitos | Más estable que juicio libre |
| **Pairwise / A-B** | Comparar dos versiones | Robusto a calibración absoluta |
| **Human eval** | *Ground truth* final | Caro; reserva para validar los automáticos |
| **pass@k** | Generación de código | Ejecuta y verifica funcionalmente |

### 2.3 Rigor estadístico (lo que separa al maestro)
- Tamaño de muestra suficiente; reporta **intervalos de confianza** y varianza
  entre *seeds*/jueces.
- Significancia (bootstrap, t-test pareado) antes de declarar "mejoró".
- Calibra el *LLM-judge* contra etiquetas humanas (acuerdo, Cohen's κ).

---

## 3. Métricas de calidad de LLM

- **Capacidad:** exactitud por tarea, *helpfulness*, completitud, *instruction
  following*, *pass@k* (código), razonamiento.
- **Fidelidad / *groundedness*:** ¿la respuesta se sustenta en el contexto?
  (clave en RAG). Detección de **alucinaciones**.
- **Seguridad:** tasa de contenido dañino, *refusal rate* (y su **calibración**:
  ni sobre-rechazo ni bajo-rechazo), toxicidad, sesgo/fairness, fuga de PII.
- **Robustez:** estabilidad ante adversarial/paráfrasis/ruido/idioma.
- **Operativas:** latencia (p50/p95/p99), costo por consulta/tokens, *throughput*.
- **Calibración:** ¿la confianza declarada corresponde a la exactitud real?

---

## 4. Evaluación de RAG

- **Retrieval:** recall@k, precision@k, MRR, nDCG, *context relevance*.
- **Generación:** *faithfulness* (sin inventar fuera del contexto), *answer
  relevance*, *context utilization*.
- **End-to-end:** correctitud final + atribución/citas correctas.
- **Fallos típicos a cazar:** *chunking* malo, contexto irrelevante recuperado,
  respuesta correcta pero no sustentada, ignorar el contexto, *lost in the middle*.
- Frameworks: **RAGAS**, TruLens, DeepEval, ARES.

---

## 5. Evaluación de agentes (multi-paso / tool use)

- **Task success rate** (objetivo cumplido de extremo a extremo).
- **Trajectory eval:** ¿los pasos/herramientas elegidos fueron correctos?
  (no solo el resultado).
- **Tool-use correctness:** argumentos válidos, manejo de errores de la tool,
  recuperación tras fallo.
- **Eficiencia:** nº de pasos, costo, latencia, *loops* infinitos.
- **Seguridad de acciones:** que no ejecute acciones destructivas/irreversibles
  sin confirmación; *sandboxing*; límites de permisos.
- Benchmarks/harness: SWE-bench, WebArena, τ-bench, AgentBench, **Inspect** (UK
  AISI), entornos propios reproducibles.

---

## 6. Red-teaming y seguridad ofensiva de IA

- **Jailbreaks:** *role-play*, *prefix/suffix injection*, codificación,
  *many-shot*, *crescendo*, ofuscación, multilenguaje.
- **Prompt injection:**
  - *Directa* (el usuario manipula la instrucción).
  - *Indirecta* (carga maliciosa en documentos/web/herramientas que el modelo
    lee) — vector crítico en RAG y agentes.
- **Exfiltración de datos / *system prompt leaking*.**
- **Abuso/uso dual:** armas, malware, fraude, contenido CSAM/ilegal, autolesión.
- **Automated red-teaming:** generación adversarial a escala + clasificadores;
  *red-team* humano para *long tail*.
- Marcos: **OWASP Top 10 for LLM Apps**, NIST AI RMF, MITRE ATLAS.

---

## 7. Safety / alignment (grado laboratorio de frontera)

- **HHH:** *Helpful, Honest, Harmless* — y sus tensiones (helpfulness vs
  harmlessness).
- **Políticas de uso:** mapear cada política a evals concretas (policy-as-evals).
- **Refusal calibration:** medir falsos rechazos (sobre-restricción) y falsas
  aceptaciones.
- **Sycophancy, deception, sandbagging:** pruebas específicas de honestidad.
- **Capabilities peligrosas:** evaluaciones de riesgo (cyber, bio, autonomía)
  estilo *Responsible Scaling Policy* / *Preparedness*.
- **Model cards / system cards:** documentar capacidades, límites y riesgos.

---

## 8. Testing de ML clásico (modelos predictivos)

- **Behavioral testing (CheckList):** *Minimum Functionality Tests*, **invarianza**
  (cambios que no deben alterar la salida) y **direccionales** (cambios que sí).
- **Metamorphic testing:** relaciones entrada↔salida cuando no hay oráculo.
- **Data validation:** esquema, rangos, nulos, cardinalidad, *freshness*
  (Great Expectations, TFDV, dbt tests, Pandera).
- **Drift:** *data drift* y *concept drift* (PSI, KS, KL); monitoreo en producción.
- **Training/serving skew** y reproducibilidad (mismas features online/offline).
- **Fairness/sesgo:** *demographic parity*, *equalized odds*, *disparate impact*;
  análisis por *slice* (Giskard, Fairlearn, What-If Tool).
- **Robustez adversarial** (FGSM/PGD en visión), *out-of-distribution*.
- **Explicabilidad** como evidencia (SHAP/LIME) para auditar comportamiento.

---

## 9. Guardrails y capa de seguridad del producto

- Filtros de entrada/salida (moderación, PII, *secrets*), *grounding* forzado,
  límites de herramientas, *rate limiting* de acciones.
- **Probar los guardrails como sistema:** bypass, falsos positivos/negativos,
  latencia añadida, *fail-open* vs *fail-closed*.

---

## 10. Regresión de prompts/modelos en CI/CD

- **Prompts y modelos versionados** como artefactos; cambios pasan por suite de
  evals con *gates* (no se promueve si cae *safety* o *faithfulness*).
- *Canary* por calidad: medir métricas online (thumbs up/down, tasa de retry).
- *Eval as code* en el pipeline; reportes con tendencia e intervalos.

---

## 11. Tooling de referencia (verificar versiones vigentes)

OpenAI Evals · Anthropic evals · **Inspect** (UK AISI) · **lm-evaluation-harness**
· **HELM** · Promptfoo · DeepEval · RAGAS · TruLens · LangSmith · Giskard ·
Garak / PyRIT (red-team) · Great Expectations / Pandera (datos) · Fairlearn.

---

## 12. Checklist de release de un producto de IA

```
- [ ] Suite de evals con dataset dorado + slices + adversariales
- [ ] Métricas con IC y significancia vs baseline (capability + safety)
- [ ] RAG: faithfulness y retrieval medidos; sin alucinación por encima de umbral
- [ ] Agente: task success + trajectory + seguridad de acciones
- [ ] Red-team: jailbreaks y prompt injection (directa e indirecta) cubiertos
- [ ] Refusal calibration dentro de rango; sin fuga de PII/secretos/system prompt
- [ ] Guardrails probados (bypass, fail-closed, latencia)
- [ ] Drift y data validation activos en producción
- [ ] Prompts/modelos versionados; gate de evals en CI; canary por calidad
- [ ] System/model card y mapeo política→eval documentados
```
