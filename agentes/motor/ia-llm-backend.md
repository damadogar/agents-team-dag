# ia-llm-backend.md — IA y ecosistema LLM aplicado al backend

> Consulta esto para **integrar** LLMs/IA en productos backend con criterio de
> arquitectura, costo, latencia, fiabilidad y seguridad de integración.
>
> **Frontera de rol:** Motor cubre la **integración backend** del LLM. La
> **selección/comparativa de modelos** la decide `eneida` (arquitecto); las
> **evals, red-teaming y safety/calidad del modelo** las lidera `amado` (QA).
> Aquí encontrarás cómo instrumentar y exponer los puntos donde amado evalúa, y
> cómo implementar el modelo que eneida elija.

## 1. Cuándo aplica un LLM (la decisión es del arquitecto; reconócela)

> Si te ordenan integrar un LLM donde no aporta, **escala la observación**; la
> decisión de meterlo o no es del arquitecto/orquestador.

- **Encaja**: lenguaje natural, extracción/clasificación difusa, generación,
  resumen, asistencia, búsqueda semántica, automatización con error revisable.
- **No encaja**: cuando una regla/heurística/ML clásico es más barato,
  determinista y auditable; cálculos exactos; decisiones críticas sin humano en el
  loop; cuando no se tolera latencia/costo/no-determinismo.
- Trátalo siempre como una dependencia externa no fiable (timeout/retry/fallback).

## 2. Patrones de arquitectura backend para IA

- **LLM como servicio/dependencia**: trátalo como una integración externa no
  fiable → timeouts, retries (idempotentes), circuit breaker, fallback, colas.
- **RAG (Retrieval-Augmented Generation)**: ingestión → chunking → embeddings →
  **vector store** (pgvector, Qdrant, Weaviate, Milvas, Elasticsearch kNN) →
  retrieval (híbrido: keyword + vector + rerank) → prompt → generación. La
  calidad depende más del *retrieval* y los datos que del modelo.
- **Tool calling / function calling**: el modelo decide invocar herramientas;
  **valida y autoriza** cada herramienta como un endpoint normal (el modelo es
  input no confiable). Limita el alcance (least privilege).
- **Agentes**: orquestación de pasos/herramientas con memoria. Acota loops
  (límite de pasos/costo), añade observabilidad y *human-in-the-loop* en acciones
  sensibles. No sobre-agentices: muchos casos se resuelven con un flujo fijo.
- **Orquestación**: workflows deterministas (state machine/colas) alrededor del
  paso no determinista del LLM; cachea, paraleliza, degrada.
- **Batch vs streaming**: streaming de tokens para UX; batch para procesamiento
  masivo (más barato).

## 3. Datos y embeddings

- **Chunking** semántico, metadatos para filtrar, deduplicación, actualización
  incremental (re-embedding al cambiar contenido).
- **pgvector** si ya tienes Postgres y escala moderada; vector DB dedicada para
  escala/latencia alta. Indexa (HNSW/IVF) y mide recall vs latencia.
- **Búsqueda híbrida + reranking** suele superar a vector puro.

## 4. Fiabilidad, costo y latencia

- **Costo**: tokens in/out; controla con prompts compactos, contexto mínimo
  necesario, **caching** (prompt/respuesta/embedding), modelos pequeños para
  tareas simples (routing/cascade), y límites por usuario/tenant.
- **Latencia**: streaming, paralelización, modelos rápidos, recuperación
  eficiente, timeouts y *speculative*/cascada (modelo barato → caro si hace falta).
- **Fiabilidad**: reintentos, fallback entre proveedores/modelos, *graceful
  degradation* (responder sin IA si falla), rate limits del proveedor con colas.
- **Abstracción de proveedor**: capa que permita cambiar de modelo/proveedor
  (evita lock-in duro); gateway de LLM (LiteLLM/portkey) para routing, límites y
  observabilidad.

## 5. Calidad y evaluación (evals) — lo lidera `amado`

> Las **evals, red-teaming, safety y métricas de calidad del modelo son del QA
> (`amado`)**. La responsabilidad de Motor aquí es **habilitarlas**: exponer
> versiones de prompt/modelo, capturar entradas/salidas (con cuidado de PII),
> integrar el gate de evals en CI y registrar trazas/costos para que amado mida.

- **Evals** como tests (las define amado): datasets de referencia, métricas
  (exactitud, groundedness, relevancia, toxicidad), LLM-as-judge con cautela,
  *golden sets* y regresión en CI al cambiar prompt/modelo.
- Mide en producción: feedback de usuario, tasa de fallback, alucinaciones
  reportadas, satisfacción. Versiona prompts y modelos.

## 6. Seguridad de IA (OWASP Top 10 for LLM)

- **Prompt injection** (directa/indirecta): trata todo contenido recuperado/
  externo como no confiable; separa instrucciones de datos; no des herramientas
  peligrosas sin autorización; output filtering.
- **Insecure output handling**: nunca ejecutes/inyectes la salida del LLM sin
  validar (SQL, comandos, HTML, código).
- **Excessive agency**: limita herramientas y permisos del agente (least
  privilege, human approval en acciones sensibles).
- **Sensitive info disclosure**: no metas secretos/PII en prompts; redacta;
  controla qué datos entran al contexto y a proveedores externos (residencia de
  datos, DPA).
- **Data poisoning / supply chain** de modelos y datasets; **DoS por tokens/costo**
  (límites y cuotas).

## 7. Observabilidad de pipelines de IA

- Traza cada paso (retrieval, prompt, tokens, latencia, costo, herramienta
  invocada, resultado). Usa OpenTelemetry + herramientas LLM (Langfuse, Phoenix,
  etc.). Loguea prompts/respuestas con cuidado de PII.
- Métricas: costo por request/tenant, latencia por etapa, tasa de error/fallback,
  hit ratio de cache, calidad (de evals).

## 8. Disciplina de actualización

El ecosistema cambia a diario. La **elección del modelo concreto la decide
`eneida`** (con su método y snapshot de mercado); el rol de Motor es **aislar esa
elección tras una abstracción** (gateway/adaptador) para poder cambiarla sin
reescribir, y verificar las restricciones de integración (límites de API,
formato, latencia, costo) del modelo elegido. No fijes un "mejor modelo" en el
código.

## 9. Checklist de IA en backend

```
- [ ] El LLM resuelve un problema con ROI claro (no por moda)
- [ ] Tratado como dependencia no fiable: timeout/retry/circuit breaker/fallback
- [ ] RAG con retrieval híbrido + rerank; calidad de datos cuidada
- [ ] Tool calling validado y autorizado como endpoints (least privilege)
- [ ] Costo/latencia controlados: caching, modelos por tarea, límites por tenant
- [ ] Hooks para evals en CI habilitados (evals y métricas de calidad: `amado`); prompts/modelos versionados
- [ ] Seguridad OWASP-LLM: anti prompt-injection, output handling, sin PII/secretos
- [ ] Observabilidad por etapa (tokens, costo, latencia, herramientas)
- [ ] Abstracción de proveedor para evitar lock-in
```
