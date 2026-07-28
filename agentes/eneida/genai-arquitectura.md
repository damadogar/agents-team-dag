# Arquitectura de IA / LLMs en los sistemas asesorados

Cómo Eneida diseña **IA dentro del producto** del cliente (distinto de elegir el
modelo con el que Eneida trabaja, que está en `llm-stack.md`).

Regla previa: **IA solo con ROI claro, datos disponibles y guardrails**. Si una
heurística o un sistema determinista resuelve mejor, no uses LLM.

---

## 1. Patrones de solución (de menor a mayor complejidad)

1. **Prompting directo** (zero/few-shot) — tareas simples y acotadas.
2. **RAG (Retrieval-Augmented Generation)** — respuestas ancladas en datos
   propios; reduce alucinaciones. Componentes: ingesta → **chunking** →
   **embeddings** → **vector store** → recuperación (híbrida: semántica + BM25) →
   **re-ranking** → generación con citas.
3. **Tool use / function calling** — el modelo invoca herramientas/APIs.
4. **Agentes** — planificación multi-paso con herramientas, memoria y bucles de
   verificación. Úsalos solo cuando el flujo lo requiera (cuestan latencia,
   costo y previsibilidad). Prefiere flujos dirigidos sobre autonomía total.
5. **Fine-tuning / adaptadores** — solo cuando prompting+RAG no bastan y hay
   datos de calidad; evalúa costo/beneficio vs RAG.

---

## 2. Memoria y datos

- **Memoria**: de corto plazo (contexto de la sesión) y de largo plazo
  (resúmenes, perfiles) con políticas de retención y privacidad.
- **Embeddings + vector store** (pgvector, FAISS, o gestionado): define
  dimensión, métrica (cosine), estrategia de chunking y metadatos para filtrado.
- **Calidad del retrieval** manda: mide recall/precisión del contexto antes de
  culpar al modelo.

---

## 3. Guardrails y anti-alucinación

- **Entrada**: validación, detección de prompt injection, límites de longitud,
  sanitización de contenido no confiable (RAG/herramientas son superficie de
  ataque).
- **Salida**: validación de esquema (JSON), verificación de hechos contra
  fuentes, **citas obligatorias** en RAG, filtros de toxicidad/PII, límites de
  acción para agentes (allowlist de herramientas, confirmación humana en
  acciones sensibles — human-in-the-loop).
- **Grounding**: responde "no sé" cuando no hay evidencia; no inventes.
- **OWASP LLM Top 10** como checklist de riesgos.

---

## 4. Evaluación continua (evals)

- Construye un **dataset de evaluación** representativo (golden set) y mide:
  exactitud, fidelidad al contexto (faithfulness), relevancia, toxicidad, costo
  y latencia.
- **LLM-as-judge** con cautela (sesgos); combina con métricas determernistas y
  revisión humana en muestras.
- Evals en CI: una nueva versión de prompt/modelo no entra si baja la calidad.
- Observabilidad específica: trazas de prompts, tokens, costo por request,
  tasa de fallback.

---

## 5. Gobernanza y operación de modelos

- **Versionado** de prompts, modelos y datos (reproducibilidad).
- **Rollback/fallback de modelos**: enruta a un modelo alterno si el primario
  falla, se degrada o cambia (basado en **changelogs y release notes oficiales**
  del proveedor). No te ates a un solo proveedor sin plan B.
- **Abstracción de proveedor** (capa anticorrupción) para cambiar de modelo sin
  reescribir el sistema.
- **Costos**: caché de respuestas/embeddings, modelos pequeños para tareas
  simples (routing), límites por usuario.
- **Privacidad/cumplimiento**: no enviar PII/secretos a modelos sin control;
  residencia de datos; acuerdos de no-entrenamiento cuando aplique.
- **Seguridad**: trata la salida del LLM como no confiable; nunca ejecutes
  código/SQL generado sin sandbox y validación.

---

## Checklist de diseño GenAI
```
- [ ] ¿El problema justifica IA (ROI) o basta algo determinista?
- [ ] ¿RAG con citas para anclar respuestas? ¿calidad de retrieval medida?
- [ ] ¿Guardrails de entrada/salida + anti prompt-injection?
- [ ] ¿Evals con golden set en CI? ¿métricas de costo/latencia?
- [ ] ¿Versionado + rollback/fallback de modelos + abstracción de proveedor?
- [ ] ¿Privacidad de datos y salida del LLM tratada como no confiable?
```

## Referencias
- OWASP Top 10 for LLM Applications: https://genai.owasp.org/
- NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework
- Documentación/eval de Anthropic, OpenAI, Google (RAG, tool use, safety).
