# llm-agentes.md — LLMs, RAG, agentes, guardrails y evaluación

Diseño y operación de sistemas basados en LLM: *prompt engineering*, RAG, agentes
con *tools*, **guardrails** y **evaluación** de calidad y seguridad. La
arquitectura general está en [arquitectura-ia.md](arquitectura-ia.md); el ciclo de
vida/versionado en [mlops.md](mlops.md); el costo/latencia en
[inferencia-performance.md](inferencia-performance.md).

> Seguridad coordinada con **destroyer**; datos/índices gobernados por **andulfo**.

---

## 1. Prompt engineering (con disciplina)

- **Prompts versionados** (no *hardcoded* dispersos); cada cambio se evalúa.
- Técnicas: instrucciones claras, *few-shot*, *chain-of-thought* donde aporta,
  *output schema* (JSON estructurado + validación), *system prompt* estable.
- **Separación** de instrucción vs datos del usuario (mitiga inyección).
- *Temperature*/parámetros por caso; determinismo donde se necesita reproducir.

## 2. RAG (Retrieval-Augmented Generation)

### 2.1 Indexación
- **Ingesta** del corpus (datos de caudal; índice gobernado por andulfo).
- **Chunking:** por estructura semántica, tamaño/overlap evaluados (no arbitrario).
- **Embeddings:** modelo adecuado al dominio/idioma; versiona el modelo de
  embeddings (reindexar si cambia).
- **Vector store:** metadatos para filtrado/seguridad por *tenant*/permiso.

### 2.2 Consulta
```
query → embed → retrieve(k) → rerank → context assembly → LLM → guardrails → respuesta + citations
```
- **Reranking** para precisión; **citations** para trazabilidad.
- **Filtros de acceso** (no recuperar lo que el usuario no puede ver).
- **Freshness:** estrategia de reindexado; versión/TTL del corpus.

### 2.3 Evaluación de RAG
- *Retrieval*: *recall@k*, *precision@k*, *context relevance*.
- *Generación*: *faithfulness*/*groundedness* (¿la respuesta se apoya en el
  contexto?), *answer relevance*, ausencia de *hallucination*.

## 3. Agentes y tool use

- **Cuándo usar agente:** tareas multi-paso, herramientas externas, planificación.
  Si un *prompt* o RAG simple basta, **no uses agente**.
- **Tools seguras:** contrato explícito, *allow-list*, validación de argumentos,
  **permisos mínimos**, *idempotencia* en acciones con efectos.
- **Límites (anti *excessive agency*):** máximo de pasos, presupuesto de costo,
  *timeouts*, *circuit breaker*, *human-in-the-loop* en acciones sensibles.
- **Observabilidad:** *tracing* de cada paso (decisión, tool, input/output, costo).

## 4. Guardrails (entrada y salida)

| Punto | Controles |
|---|---|
| **Entrada** | Detección/aislamiento de *prompt injection*, límites de tamaño, validación de formato, *PII detection* |
| **Salida** | *Content safety* (toxicidad/peligro), validación de *schema*, *PII redaction*, anti fuga de *system prompt*/secretos, verificación de *citations* |
| **Acciones (agentes)** | Confirmación humana, *allow-list* de *tools*, límites de alcance |
| **Transversal** | *Rate limiting*, *quota*, *audit* de prompts y respuestas |

> Alinea con **OWASP LLM Top 10** (ver §6) y con destroyer.

## 5. Evaluación (evals) — calidad, seguridad, costo

- **Eval sets ("golden set")** representativos, versionados; incluye casos
  adversariales y de borde.
- **Métricas de calidad:** exactitud/aciertos, *faithfulness* (RAG), formato
  válido, *helpfulness*.
- **Métricas de seguridad:** tasa de inyección exitosa, fugas de PII, salidas
  inseguras.
- **Métricas de costo/latencia:** tokens, costo por petición, p95.
- **LLM-as-judge:** útil pero **con cuidado** (sesgo del juez, calibración,
  *ground truth* cuando se pueda).
- **Offline antes de prod; online (canary/shadow) en prod** (ver [mlops.md](mlops.md)).

## 6. Seguridad de LLM — OWASP LLM Top 10 (operativo)

| Riesgo | Mitigación que aplica sysuniversal-ai |
|---|---|
| **Prompt injection** (directa/indirecta) | Separar instrucción/datos, *guardrails* de entrada, *retrieval* confiable, no ejecutar instrucciones de contenido recuperado |
| **Insecure output handling** | Validar/escapar salida antes de usarla (no *eval* ciego, no SQL/HTML directo) |
| **Sensitive info disclosure** | *PII redaction*, no poner secretos en *prompt*, filtros de salida |
| **Excessive agency** | Permisos mínimos de *tools*, límites de pasos, *human-in-the-loop* |
| **Model DoS / costo** | *Rate limiting*, *quota*, límites de tokens, timeouts |
| **Supply chain / model** | Fijar versión, fuente confiable de modelos/embeddings |
| **Data/prompt leakage** | *Audit*, aislamiento por *tenant*, no loguear PII en claro |

## 7. Fine-tuning / PEFT (cuándo)

- Solo si prompting + RAG **no** alcanzan estilo/formato/dominio.
- **Datos** de calidad y representativos (con prisma/caudal); evita
  *overfitting* y memorización de PII.
- Considera **PEFT/LoRA** (más barato/mantenible) antes de *full fine-tune*.
- Versiona dataset, modelo base y resultado; evalúa regresión vs baseline.

## 8. Responsible AI (LLM)

- *Evals* de sesgo/toxicidad; *system card* con límites y uso permitido.
- Transparencia: indicar al usuario cuando interactúa con IA si aplica.
- *Human oversight* proporcional al riesgo del caso de uso.

## 9. Checklist rápido de sistema LLM

- [ ] Prompts versionados + *eval set*
- [ ] Guardrails de entrada y salida activos
- [ ] (RAG) *retrieval* evaluado, *citations*, filtros de acceso, *freshness*
- [ ] (Agente) límites de pasos/costo, *tools* con permisos mínimos, *human-in-the-loop*
- [ ] OWASP LLM Top 10 revisado (con destroyer)
- [ ] Observabilidad: calidad, costo/token, latencia, seguridad
- [ ] Versión de modelo/proveedor fijada + alternativa (anti lock-in)
- [ ] Plan de rollback de prompt/modelo
