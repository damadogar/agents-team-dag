# ejecucion.md — Método universal de despliegue seguro de IA

Todo despliegue de IA es **un cambio en producción**: aplica el mismo rigor que una
migración. Método: **FRAME → DESIGN → BUILD → EVALUATE → DEPLOY(canary) →
MONITOR → ROLLBACK/ITERATE**.

> Credo: **IA sin monitoreo es inaceptable; nada va a prod sin guardrails,
> observabilidad y rollback.**

---

## 1. FRAME (enmarcar)
- Caso de uso, decisión/acción que habilita, restricciones (latencia/calidad/
  seguridad/costo), criticidad.
- Define **criterios de éxito medibles** y SLOs. Si falta dato → **[SUPUESTO]**.

## 2. DESIGN (diseñar)
- Enfoque más simple que cumpla (prompting < RAG < fine-tuning < propio).
- Arquitectura, datos requeridos (a caudal/brujula), guardrails, observabilidad
  y plan de rollback (ver [arquitectura-ia.md](arquitectura-ia.md)).

## 3. BUILD (construir)
- Pipelines de training/serving, *features* consistentes (anti *skew*), registry,
  guardrails. Todo **versionado** (ver [mlops.md](mlops.md)).

## 4. EVALUATE (evaluar — antes de prod)
- **Eval set** de calidad y seguridad; umbrales definidos.
- No regresión vs versión actual; costo/latencia dentro de SLO.
- **Gate:** si no pasa, no se promueve.

## 5. DEPLOY (desplegar con seguridad)
- **Shadow** y/o **canary** (% gradual) o **blue-green**; nunca *big-bang* en
  sistemas con impacto.
- Aprobación según criticidad; secretos gestionados (con destroyer/andulfo).

## 6. MONITOR (monitorear)
- Calidad, *drift*, latencia, costo y seguridad activos **desde el minuto cero**.
- Alertas y baselines. Sin señales → revertir.

## 7. ROLLBACK / ITERATE
- Versión previa **sana y disponible**; *switch*/canary a 0% ante degradación.
- *Postmortem* y mejora; disparadores de *retraining* (ver [mlops.md](mlops.md)).

---

## 8. Guardas de seguridad (no negociables)

- [ ] Plan de **rollback** probado y versión previa disponible
- [ ] **Monitoreo** de calidad/drift/costo/seguridad antes de servir tráfico real
- [ ] **Guardrails** de entrada/salida activos (LLM)
- [ ] Sin **PII/secretos** a modelos no autorizados (gobernanza andulfo/destroyer)
- [ ] **Evals** superados (calidad y seguridad)
- [ ] Sin **train/serving skew**
- [ ] Estrategia de despliegue **gradual** (shadow/canary/blue-green)
- [ ] Aprobación y **audit** del cambio de modelo/prompt

## 9. Clasificación de cambios

| Tipo | Ejemplos | Exigencia |
|---|---|---|
| **Reversible** | canary de nuevo modelo, cambio de prompt versionado | rollback simple |
| **Semi-reversible** | reindexado RAG, cambio de embeddings | reindexar/restaurar índice |
| **Irreversible** | borrado de datos/artefactos, acción de agente con efecto externo | doble aprobación + backup (con andulfo) |

## 10. Regla final

Si no puedes **monitorear** y **revertir** un despliegue de IA, **no lo
despliegues**: rediseña hasta que sea observable y reversible.
