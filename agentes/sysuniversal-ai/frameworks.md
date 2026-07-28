# frameworks.md — Marcos, estándares y fuentes de referencia

Marcos que sustentan el criterio de SysUniversal-AI. **Neutralidad:** son
referencias para razonar, no herramientas obligatorias. Verifica con búsqueda web
antes de afirmar capacidades/costos/límites o "mejor modelo/herramienta" (el
panorama cambia muy rápido).

---

## 1. MLOps / LLMOps
- **MLOps (CI/CD/CT):** integración, entrega y **entrenamiento continuo**; niveles
  de madurez (manual → automatizado → CT).
- **Ciclo de vida del modelo:** datos → train → validación → registry → deploy →
  monitor → drift → retraining → rollback.
- **Model registry / feature store / experiment tracking** como pilares de
  reproducibilidad.
- **LLMOps:** prompts versionados, *eval sets*, *golden set*, drift de proveedor,
  costo/token como SLI.

## 2. Confiabilidad y operación
- **Google SRE:** SLI/SLO/SLA, *error budgets*, eliminación de *toil*,
  *postmortems* sin culpa.
- **DORA:** *deploy frequency*, *lead time*, *change failure rate*, MTTR aplicados
  a despliegues de modelos.
- **Estrategias de despliegue:** shadow, canary, blue-green, A/B.

## 3. Seguridad de IA
- **OWASP Top 10 for LLM Applications:** prompt injection, insecure output
  handling, sensitive info disclosure, excessive agency, model DoS, supply chain,
  etc.
- **MITRE ATLAS:** tácticas/técnicas de ataque adversarial a sistemas de ML.
- **Gestión de secretos, control de acceso, rate limiting** (con destroyer).

## 4. Gobernanza y Responsible AI
- **NIST AI Risk Management Framework (AI RMF):** *Govern, Map, Measure, Manage*.
- **ISO/IEC 42001** (sistema de gestión de IA) y **ISO/IEC 23894** (gestión de
  riesgo de IA) como referencias de gobernanza.
- **EU AI Act** (enfoque por riesgo) como referencia regulatoria cuando aplique.
- **Model cards / system cards / datasheets** para transparencia.
- **Responsible AI:** *fairness*, *transparency*, *accountability*,
  *explainability* (XAI: SHAP/LIME, según riesgo).

## 5. Evaluación
- **Métricas de modelo:** según tarea (clasificación/regresión/ranking) — alineadas
  con prisma.
- **Evals de LLM/RAG:** *faithfulness/groundedness*, *answer/context relevance*,
  *recall@k*; *LLM-as-judge* con calibración y cautela.
- **Evals de seguridad:** adversariales (inyección), fuga de PII, *content safety*.

## 6. Serving e inferencia (referencias neutrales)
- **Model servers:** Triton, TorchServe, KServe, BentoML, Ray Serve.
- **LLM serving:** vLLM (*paged attention*), TGI, TensorRT-LLM.
- **Optimización:** cuantización (int8/int4), *batching* dinámico, *KV cache*,
  *speculative decoding*, destilación.

## 7. RAG y vector stores (referencias neutrales)
- **Componentes:** *chunking*, *embeddings*, *vector store*, *retrieval*,
  *reranking*, *citations*.
- **Patrones:** *naive RAG*, *advanced RAG* (rerank, *query rewriting*),
  *agentic RAG*.

## 8. Cómo usar estos marcos
1. Parte del **problema y restricciones**, no del marco.
2. Elige el **enfoque más simple** que cumpla y justifícalo (ADR).
3. **Evalúa** antes de producción y **monitorea** después; sin esto no hay deploy.
4. **Seguridad y gobernanza desde el inicio** (OWASP LLM + NIST AI RMF).
5. **Verifica con búsqueda web** capacidades/costos/límites antes de afirmarlos.

> Estos marcos orientan el criterio; la decisión final es **del problema**, con
> trade-offs explícitos y respetando las fronteras con andulfo, caudal,
> brujula, prisma, eneida y destroyer.
