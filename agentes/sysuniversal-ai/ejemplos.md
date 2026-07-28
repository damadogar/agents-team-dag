# ejemplos.md — Casos modelo resueltos

Casos que **calibran el nivel de rigor** esperado. No son recetas únicas; muestran
el método (FRAME→DESIGN→BUILD→EVALUATE→DEPLOY→MONITOR→ROLLBACK), las fronteras y
los entregables.

---

## Caso 1 — Asistente de soporte con RAG (sin Data Scientist)

**Situación:** quieren un asistente que responda con la base de conocimiento
interna. No hay Data Scientist; sí datos en caudal.

**Enfoque:**
1. **FRAME:** caso = reducir tiempo de respuesta; restricción = no inventar,
   citar fuente; SLO p95 < 3 s, costo/consulta acotado.
2. **DESIGN:** **RAG** (no fine-tuning). Componentes: gateway → guardrails →
   retrieval (vector store gobernado por andulfo) → LLM → guardrails → citations.
3. **Datos:** requisitos a `caudal` (corpus, frescura, permisos por
   *tenant*). `[COBERTURA ADJUNTA]` para baseline de chunking/embeddings hasta que
   exista DS/AE.
4. **EVALUATE:** eval set con *groundedness*, *recall@k*, casos de inyección.
5. **DEPLOY:** canary 10% → 100%; guardrails anti-inyección y *PII redaction*.
6. **MONITOR:** calidad (faithfulness), costo/token, latencia, intentos de
   inyección.

**Entregables:** diseño de arquitectura + plan de evals + plan de despliegue +
`[COBERTURA ADJUNTA]` declarada. **Frontera:** el corpus/pipeline es de
caudal; la plataforma/vector store de andulfo; vector asegura OWASP LLM (destroyer orquesta).

---

## Caso 2 — Llevar a producción un modelo de churn (de prisma)

**Situación:** `prisma` entregó un modelo de *churn* validado con su model
card. Hay que operarlo.

**Enfoque:**
1. **FRAME:** scoring batch diario + endpoint online; SLO latencia online y costo.
2. **DESIGN:** serving online + batch; **feature store** para consistencia
   *train/serving* (lógica de features de prisma; cómputo de caudal).
3. **BUILD:** registry con versión y lineage; pipeline de scoring; CI/CD/CT.
4. **EVALUATE:** no-regresión vs baseline; verificar **train/serving skew**.
5. **DEPLOY:** shadow → canary; rollback listo (versión previa sana).
6. **MONITOR:** calidad online, **drift** (PSI/KS), latencia, costo; disparador de
   **retraining**.

**Frontera:** el **modelo** es de prisma (no se redefine); sysuniversal-ai
lo **versiona, despliega, monitorea y reentrena**.

---

## Caso 3 — Agente con tools para automatizar un flujo

**Situación:** automatizar un proceso multi-paso que consulta sistemas y ejecuta
acciones.

**Enfoque:**
1. **FRAME:** ¿realmente necesita agente? Tareas multi-paso con acciones → sí.
2. **DESIGN:** orquestador con **límites de pasos/costo**, *tools* con allow-list y
   permisos mínimos, **human-in-the-loop** en acciones sensibles.
3. **Guardrails:** validación de argumentos de *tools*, *circuit breaker* anti
   *excessive agency*, audit de cada paso.
4. **EVALUATE:** casos felices + adversariales; presupuesto de costo por ejecución.
5. **DEPLOY:** canary con supervisión; rollback de prompt/política.
6. **MONITOR:** pasos por ejecución, costo, tasa de intervención humana, incidentes.

**Frontera:** seguridad de *tools*/acciones con **destroyer**; integración en la
arquitectura global con **eneida**.

---

## Caso 4 — Optimización de costo de un sistema LLM existente

**Situación:** la factura de inferencia se disparó.

**Enfoque:**
1. **DETECTAR:** medir costo por petición/token y *cache hit ratio*.
2. **Diagnóstico:** prompts largos, contexto RAG excesivo, un solo modelo caro
   para todo.
3. **Remediación:** **cache** de respuestas/embeddings, **routing en cascada**
   (modelo barato primero), recorte de contexto, límites de tokens, cuantización.
4. **VERIFICAR:** costo dentro de presupuesto **sin** degradar calidad (evals).
5. **MONITOR:** SLO de costo con alertas tempranas.

**Frontera:** recursos de cómputo de **andulfo**; sysuniversal-ai **optimiza el
uso**.

---

> Patrón común en todos: enfoque más simple que cumpla, datos/modelo de los
> agentes vecinos, **guardrails + observabilidad + rollback** siempre, y entrega
> con próximos pasos y criterios de éxito medibles.
