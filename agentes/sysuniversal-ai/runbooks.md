# runbooks.md — Runbooks de incidentes de IA

Procedimientos paso a paso. Patrón común: **DETECTAR → CONTENER → DIAGNOSTICAR →
REMEDIAR → VERIFICAR → POSTMORTEM**. Coordina seguridad con **destroyer** y
plataforma/datos con **andulfo**/`caudal`.

---

## 1. Model drift / degradación de calidad en producción
1. **Detectar:** alerta de métrica online < umbral o drift (PSI/KS) alto.
2. **Contener:** si impacto alto, **rollback** a versión previa sana o bajar canary.
3. **Diagnosticar:** ¿drift de datos, de concepto o *train/serving skew*? Revisa
   distribución de inputs y pipeline de features (con prisma/caudal).
4. **Remediar:** corregir features / **retraining** con datos recientes (gates).
5. **Verificar:** evals + canary; métricas online estables.
6. **Postmortem:** causa, ajuste de umbrales/cadencia de retraining.

## 2. Prompt injection / fuga de datos en LLM
1. **Detectar:** guardrail dispara, salida con system prompt/PII, reporte.
2. **Contener:** endurecer guardrails, bloquear patrón, *rate limit*; si fuga de
   PII, **incidente de seguridad con destroyer**.
3. **Diagnosticar:** vector (inyección directa o vía contenido recuperado en RAG).
4. **Remediar:** separar instrucción/datos, sanear retrieval, filtros de salida,
   reducir *agency*.
5. **Verificar:** evals adversariales pasan.
6. **Postmortem:** añadir caso al eval set; revisar OWASP LLM Top 10.

## 3. Explosión de costo de inferencia / tokens
1. **Detectar:** alerta de costo por petición/token o factura.
2. **Contener:** *rate limit*/quota, límite de tokens, activar cache, *routing* a
   modelo más barato.
3. **Diagnosticar:** prompts largos, contexto RAG excesivo, agente en bucle,
   tráfico anómalo.
4. **Remediar:** recortar contexto, caching, cascada de modelos, límites de pasos.
5. **Verificar:** costo dentro de presupuesto; calidad mantenida.
6. **Postmortem:** SLO de costo, alertas tempranas.

## 4. Latencia fuera de SLO / saturación GPU
1. **Detectar:** p95/p99 > SLO, *queue depth*/utilización GPU alta.
2. **Contener:** escalar réplicas, activar backpressure, degradar a modelo más
   rápido si procede.
3. **Diagnosticar:** batching mal calibrado, cold start, contexto largo, OOM.
4. **Remediar:** ajustar batching/cache/cuantización; autoscaling; cercanía.
5. **Verificar:** latencia dentro de SLO bajo carga.
6. **Postmortem:** capacity planning con andulfo.

## 5. Hallucination en uso sensible
1. **Detectar:** evals/usuarios reportan respuestas no fundamentadas.
2. **Contener:** activar RAG con citations / *grounding*, *human-in-the-loop*,
   disclaimers.
3. **Diagnosticar:** falta de contexto, retrieval pobre, prompt ambiguo.
4. **Remediar:** mejorar retrieval/reranking, *faithfulness* checks, restringir
   alcance.
5. **Verificar:** métricas de *groundedness* mejoran.
6. **Postmortem:** ¿caso apto para LLM? ajustar diseño.

## 6. Índice RAG desactualizado / baja calidad de retrieval
1. **Detectar:** respuestas con datos viejos, *recall@k* bajo.
2. **Contener:** marcar freshness, avisar a usuarios si crítico.
3. **Diagnosticar:** reindexado fallido, *chunking* pobre, embeddings inadecuados.
4. **Remediar:** reindexar, ajustar chunking/embeddings, reranking.
5. **Verificar:** métricas de retrieval/groundedness.
6. **Postmortem:** automatizar refresco del índice (con caudal).

## 7. Agente en bucle / excessive agency
1. **Detectar:** pasos/costo desbordados, acciones inesperadas.
2. **Contener:** *circuit breaker*, límite de pasos/costo, suspender tools.
3. **Diagnosticar:** planner sin límites, tool sin validación, prompt ambiguo.
4. **Remediar:** límites duros, allow-list, human-in-the-loop, permisos mínimos.
5. **Verificar:** ejecución acotada y segura.
6. **Postmortem:** revisar diseño de agente.

## 8. Rollback de modelo
1. Confirmar versión previa **sana** en registry.
2. Blue-green *switch* o canary a 0%.
3. Verificar señales (calidad/latencia/seguridad).
4. Comunicar e iniciar postmortem y plan de re-despliegue.

## 9. Train/serving skew detectado
1. Confirmar diferencia de features train vs serving.
2. Alinear definiciones/transformaciones (con prisma/caudal).
3. Reentrenar/re-desplegar con features consistentes; verificar.

> Todo runbook deja **registro** (timeline, causa, acciones, prevención) y
> actualiza checklists/evals según aprendizaje.
