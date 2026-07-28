# arquitectura-ia.md — Arquitectura de sistemas de IA

Diseño de soluciones de IA en producción: decisión de enfoque, componentes,
patrones (LLM-first, RAG, agentes, serving), *feature stores* y abstracción de
proveedor. La operación del ciclo de vida está en [mlops.md](mlops.md); LLMs y
agentes en [llm-agentes.md](llm-agentes.md); performance en
[inferencia-performance.md](inferencia-performance.md).

> Frontera (ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md)): el
> **modelo** lo diseña/valida `prisma`; los **datos** los preparan
> `caudal`/`brujula`; la **plataforma/infra** es de `andulfo`.
> SysUniversal-AI diseña **cómo el sistema de IA vive en producción**.

---

## 1. Principio: el enfoque más simple que cumpla

Sube de complejidad **solo si el anterior no alcanza** (calidad/control):

```
1) Prompting (zero/few-shot)        — más barato, más rápido de iterar
2) RAG (conocimiento propio)        — reduce hallucination, datos frescos
3) Fine-tuning / PEFT (LoRA)        — estilo/dominio, formato estable
4) Modelo propio / DL a medida      — máximo control y costo
```

Regla: **no entrenes lo que puedes recuperar; no hagas *fine-tuning* de lo que
resuelve un buen *prompt* + RAG.** Cada salto debe justificarse con evals.

## 2. Decisión de tipo de sistema

| Necesidad | Enfoque típico | Vigilar |
|---|---|---|
| Scoring tabular / predicción | Modelo ML clásico servido online/batch | *Train/serving skew*, drift, latencia |
| Comprensión/generación de texto | LLM (API o propio) | Costo/token, hallucination, inyección |
| Conocimiento propio / actualizado | **RAG** | Calidad de *retrieval*, *chunking*, *freshness* |
| Tareas multi-paso con acciones | **Agentes + tools** | Bucles, costo, seguridad de *tools* |
| Estilo/dominio específico estable | **Fine-tuning / PEFT** | Datos, *overfitting*, mantenimiento |
| Visión/audio/multimodal | DL especializado / modelos multimodales | Costo GPU, tamaño, latencia |
| Grandes volúmenes offline | **Batch scoring** | Idempotencia, ventana, reproceso |

## 3. Arquitectura de referencia (componentes lógicos)

```mermaid
flowchart LR
    U[Cliente / App] --> GW[AI Gateway / API de modelos]
    GW --> GRD[Guardrails entrada]
    GRD --> ORCH[Orquestador (chain / agente)]
    ORCH -->|features| FS[(Feature Store)]
    ORCH -->|retrieval| VS[(Vector Store)]
    ORCH --> MS[Model Server / LLM]
    MS --> GRDO[Guardrails salida]
    GRDO --> CACHE[(Cache)]
    CACHE --> U
    MS --> OBS[(Observabilidad: calidad/drift/costo/seguridad)]
    REG[(Model Registry)] --> MS
    FS -.gobernado por.-> ANDULFO[(andulfo / caudal)]
    VS -.gobernado por.-> ANDULFO
```

Componentes clave:

- **AI Gateway / API de modelos:** punto único de entrada; *routing*, *auth*,
  *rate limiting*, *logging*, *quota*.
- **Guardrails** (entrada y salida): validación, anti-inyección, *PII redaction*,
  *content safety* (ver [llm-agentes.md](llm-agentes.md)).
- **Orquestador:** *chain* o agente; decide pasos, *tools*, *retrieval*.
- **Model Server / LLM:** servicio de inferencia (propio o proveedor).
- **Feature Store:** *features* consistentes *train/serving* (infra de andulfo;
  datos de caudal).
- **Vector Store:** índice para RAG (gobernado por andulfo).
- **Cache:** respuestas/embeddings (ver
  [inferencia-performance.md](inferencia-performance.md)).
- **Model Registry:** versiones, *lineage*, *model cards* (ver
  [mlops.md](mlops.md)).
- **Observabilidad:** calidad, *drift*, costo y seguridad.

## 4. Patrones de serving

| Patrón | Cuándo | Notas |
|---|---|---|
| **Online (real-time)** | Respuesta inmediata por petición | Latencia/SLO críticos; *autoscaling*, GPU si aplica |
| **Batch** | Grandes volúmenes offline, sin urgencia | Idempotente, reproceso, ventana |
| **Streaming** | Scoring sobre eventos continuos | *Stateful*, *windowing*, *backpressure* |
| **Embedded / edge** | Latencia ultrabaja, sin red | Modelo pequeño/cuantizado, actualización compleja |

Model servers comunes (neutral, elige por caso): Triton, TorchServe, KServe,
BentoML, Ray Serve; para LLM: vLLM, TGI, TensorRT-LLM, o APIs gestionadas.

## 5. Feature store (lado serving)

- **Objetivo:** consistencia **train/serving** (mismas transformaciones y
  *point-in-time correctness*) — coordina con `prisma` (lógica de features)
  y `caudal` (cómputo/materialización).
- **Online store** (baja latencia) vs **offline store** (training/backfill).
- Evita *train/serving skew*: misma definición de feature en ambos caminos.

## 6. RAG (visión arquitectónica)

Detalle operativo en [llm-agentes.md](llm-agentes.md). A nivel arquitectura:

- **Indexación:** *ingest* → *chunking* → *embeddings* → *vector store* (gobernado
  por andulfo; datos por caudal).
- **Consulta:** *embed query* → *retrieve* (k) → *rerank* → *context assembly* →
  LLM → *guardrails* → respuesta con *citations*.
- **Freshness:** estrategia de reindexado/actualización del índice; *TTL* y
  versión del corpus.

## 7. Agentes (visión arquitectónica)

- **Orquestación:** planner/executor; límites de pasos, presupuesto de costo,
  *timeouts*.
- **Tools seguras:** contratos de *tools*, *allow-list*, validación de argumentos,
  permisos mínimos.
- **Control:** *human-in-the-loop* en acciones sensibles, *circuit breakers* anti
  *excessive agency*.

## 8. Abstracción de proveedor (anti lock-in)

- Capa de adaptación que normaliza la API de modelos (proveedor A/B/propio).
- Configuración de modelo/proveedor **externa** (no en código).
- *Routing* por costo/calidad/latencia y **estrategia de salida** documentada.
- Evita acoplar lógica de negocio a un SDK propietario.

## 9. Multi-entorno y promoción

- Entornos **dev → staging → prod** con datos y cuotas separadas.
- Promoción de modelos/prompts vía **registry** y *gates* (ver [mlops.md](mlops.md)).
- Configuración por entorno; **secretos** gestionados (con destroyer/andulfo).

## 10. NFRs que toda arquitectura de IA debe declarar

Latencia (p95/p99) · throughput · disponibilidad · costo por petición/token ·
calidad objetivo (eval) · seguridad (OWASP LLM) · privacidad (PII/residencia) ·
explicabilidad/trazabilidad · *recoverability* (rollback) · *freshness* de datos/
índice. Sin NFRs no hay diseño cerrado.

## 11. Anti-patrones

- LLM/agente **sin guardrails ni observabilidad** en producción.
- *Fine-tuning* como primer recurso (antes de prompting/RAG).
- Acoplar la app a un **único proveedor** sin abstracción.
- *Features* distintas en training y serving (**skew**).
- RAG con índice **desactualizado** o *chunking* arbitrario sin evaluar.
- Agentes con **acceso ilimitado** a *tools*/datos (*excessive agency*).
- Tratar la IA como **widget aislado** del resto del sistema y la operación.
