# mlops.md — Ciclo de vida del modelo (MLOps / LLMOps)

Operación del modelo en producción: CI/CD/CT, *model registry*, despliegue,
monitoreo, *drift*, *retraining*, *rollback* y gobernanza. El método de
**despliegue seguro paso a paso** está en [ejecucion.md](ejecucion.md).

> Frontera: el **modelo** lo entrega `prisma` (con su *model card* y
> métricas); SysUniversal-AI lo **versiona, despliega, monitorea y reentrena**.

---

## 1. Ciclo de vida (visión)

```
Datos (caudal/brujula) ─► Entrenamiento ─► Validación ─► Registro
        ▲                                                              │
        │                                                              ▼
   Retraining ◄── Drift/degradación ◄── Monitoreo ◄── Despliegue (canary) ◄─┘
        │                                                              │
        └────────────────────── Rollback ◄────────────────────────────┘
```

Cada transición tiene **gates** (calidad, seguridad, aprobación) y deja
**lineage** y **versión**.

## 2. Versionado y reproducibilidad (todo se versiona)

| Artefacto | Versionar | Por qué |
|---|---|---|
| **Datos** | snapshot/hash del dataset | reproducir entrenamiento |
| **Código** | git SHA | reproducibilidad |
| **Features** | definición + versión | evitar *skew* |
| **Modelo** | versión + *lineage* en registry | despliegue/rollback |
| **Prompts** (LLM) | versión + *eval set* | reproducir comportamiento |
| **Config/hiperparámetros** | versión | comparabilidad |
| **Entorno** | imagen/contenedor | "funciona en mi máquina" → no |

Regla: **un modelo en producción debe poder reconstruirse** desde sus versiones.

## 3. Model registry

- **Estados:** `none → staging → production → archived`.
- **Metadatos:** versión, *lineage* (datos/código/features), métricas de
  validación, *model card*, aprobador, fecha.
- **Promoción:** solo con *gates* aprobados; trazable y auditable.
- **Inmutabilidad:** un artefacto promovido no se sobrescribe; nueva versión.

## 4. CI/CD/CT

- **CI:** tests de código, *data validation*, tests de *features*, *unit evals*.
- **CD:** empaquetado del modelo + serving; promoción por entorno con aprobación.
- **CT (Continuous Training):** reentrenar disparado por *schedule*, *drift* o
  nuevos datos, con *gates* de calidad antes de promover.
- **Gates obligatorios:** calidad ≥ umbral, seguridad (guardrails/evals), no
  regresión vs versión actual, costo dentro de presupuesto.

## 5. Estrategias de despliegue

| Estrategia | Cómo | Cuándo |
|---|---|---|
| **Shadow** | El nuevo modelo recibe tráfico real **sin afectar** la respuesta; se compara | Validar antes de servir |
| **Canary** | % pequeño de tráfico al nuevo modelo, sube gradual | Despliegue estándar seguro |
| **Blue-green** | Dos entornos; *switch* atómico con rollback inmediato | Cambios mayores |
| **A/B** | Comparar variantes con métrica de negocio | Decidir entre modelos |

**Nunca** *big-bang* sin shadow/canary en sistemas con impacto. Siempre con
**rollback** disponible (ver [ejecucion.md](ejecucion.md)).

## 6. Monitoreo en producción (sin esto, no hay prod)

| Categoría | Señales | Acción |
|---|---|---|
| **Calidad del modelo** | métricas online vs umbral, *eval set* (LLM) | alerta / retraining |
| **Drift de datos** | cambio de distribución de inputs (PSI, KS) | investigar / reentrenar |
| **Drift de concepto** | relación input→output cambia | reentrenar / rediseñar |
| **Train/serving skew** | diferencia features train vs serving | corregir pipeline |
| **Sistema** | latencia p95/p99, throughput, errores | escalar / optimizar |
| **Costo** | costo por petición/token, GPU | FinOps / *routing* |
| **Seguridad** | inyección, salidas inseguras, fugas | guardrails / incidente |

Define **baselines** y **umbrales** con `prisma` (calidad) y destroyer
(seguridad).

## 7. Detección de drift y disparadores de retraining

- **Métricas:** PSI/KS para distribución; caída de métrica de calidad online;
  aumento de incertidumbre.
- **Disparadores de retraining:** *schedule* (cadencia), *drift* por encima de
  umbral, degradación de calidad, nuevos datos/etiquetas, cambio de negocio.
- **Política:** automático (con gates) vs con aprobación humana, según criticidad.

## 8. Rollback

- **Pre-requisito:** versión anterior **disponible y sana** en el registry.
- **Disparadores:** degradación de calidad/seguridad, incidente, costo desbocado.
- **Procedimiento:** *switch* a versión previa (blue-green) o bajar canary a 0%;
  verificar señales; *postmortem*. Runbook en [runbooks.md](runbooks.md).

## 9. Gobernanza del modelo

- **Model cards / system cards:** propósito, datos, *evals*, límites, riesgos,
  uso permitido (con `prisma` y destroyer).
- **Audit:** quién promovió/desplegó/cambió; *lineage* completo.
- **Control de acceso** a modelos/artefactos/serving (con andulfo/destroyer).
- **Responsible AI:** evals de sesgo/toxicidad, explicabilidad acorde al riesgo.
- **Cumplimiento:** residencia de datos, retención, regulación aplicable.

## 10. Especifico LLMOps

- **Prompts versionados** con *eval sets*; cambios de prompt = despliegue con
  shadow/canary.
- **Evaluación continua:** *golden set*, *LLM-as-judge* (con cuidado), métricas de
  calidad/seguridad/costo (ver [llm-agentes.md](llm-agentes.md)).
- **Drift de proveedor:** un modelo gestionado puede cambiar; **fija versión** y
  monitorea regresiones; ten alternativa (anti lock-in).
- **Costo/token** como SLI de primera clase.

## 11. Anti-patrones de MLOps

- Modelo en producción **sin monitoreo** ni baseline.
- **Sin rollback** ni versión previa sana.
- Reentrenar **manual y sin gates** (regresiones silenciosas).
- *Features* de training distintas a serving (**skew**).
- Prompt/model "hotfix" directo en prod sin versionar ni evaluar.
- Confiar en un proveedor gestionado **sin fijar versión** ni alternativa.
