# Plantillas de entregables de peakformance

Estas son las plantillas maestras que peakformance usa para entregar performance de nivel mundial en cualquier ecosistema (greenfield o brownfield), con **sesgo cero**: todo se decide con **medición y evidencia**, se reporta en **percentiles (p50/p95/p99), no promedios**, y siempre con **antes/después**. Cada entregable lleva números y cierra con próximos pasos + criterios de éxito medibles.

Todas operan bajo el modelo **TIERED**: **T1** peakformance implementa lo cross-cutting; **T2** co-implementa o entrega vía el dueño de dominio ([interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md)); **T3** actúa como fallback cuando no hay dueño. Para el marco conceptual ver [estrategia-performance.md](estrategia-performance.md) y [metodologia-diagnostico.md](metodologia-diagnostico.md).

Copia el bloque, reemplaza los campos `[así]` y borra lo que no aplique. Para casos resueltos ver [ejemplos.md](ejemplos.md).

## 1. Línea base / diagnóstico de performance

Fotografía inicial y honesta del sistema bajo carga controlada. Es el punto de partida obligatorio en brownfield: sin línea base no hay "después". Método y percentiles se alinean con [medicion-observabilidad.md](medicion-observabilidad.md).

> **Variante greenfield.** Cuando el sistema aún no existe no hay línea base: sustituye el "Antes" por el **objetivo modelado** (budgets derivados de la meta + carga estimada con Little's Law/USL) y valida contra el primer PoC. Ver [metodologia-diagnostico.md](metodologia-diagnostico.md) §1.1 y el Ejemplo 0 de [ejemplos.md](ejemplos.md).

```markdown
# Línea base de performance — [sistema/servicio] — [fecha]

## Escenario
- Flujo/endpoint medido: [ej. POST /checkout]
- Entorno: [prod-like / staging / prod] — datos: [sintéticos / anonimizados / reales]
- Build/commit: [hash] — configuración: [flags, réplicas, tamaño instancia]

## Carga aplicada
- Modelo: [closed/open] — usuarios/RPS: [ej. 300 RPS constantes 15 min]
- Herramienta: [k6 / Locust / Gatling / wrk] — ver [pruebas-de-carga.md](pruebas-de-carga.md)

## Método
- Ventana de medición: [ej. 10 min tras 3 min de warm-up]
- Fuente de métricas: [APM/traces/logs] — descartado el warm-up y outliers de arranque en frío

## Resultados (percentiles, NO promedios)
| Métrica            | p50    | p95    | p99    | máx    |
|--------------------|--------|--------|--------|--------|
| Latencia (ms)      | [x]    | [x]    | [x]    | [x]    |
| Throughput (RPS)   | [x]    | —      | —      | —      |
| Tasa de error (%)  | [x]    | —      | —      | —      |

## Recurso saturado
- [CPU / memoria / I/O disco / red / conexiones DB / pool / GC / lock] al [x]%
- Evidencia: [gráfica, traza, flamegraph, query plan]

## Causa raíz (evidencia, no hipótesis)
- [Descripción con la señal que la prueba: ej. N+1 en query X, GC pausas de [x] ms]

## Cuellos de botella priorizados (impacto × esfuerzo × riesgo)
| # | Cuello               | Impacto | Esfuerzo | Riesgo | Prioridad | Dueño (tier)        |
|---|----------------------|---------|----------|--------|-----------|---------------------|
| 1 | [N+1 en listado]     | Alto    | Bajo     | Bajo   | P0        | andulfo (T2)        |
| 2 | [Bundle JS 2.1 MB]   | Alto    | Medio    | Bajo   | P1        | farola (T2)         |
| 3 | [Sin cache en /feed] | Medio   | Bajo     | Medio  | P1        | motor (T2)          |

## Próximos pasos + criterios de éxito medibles
- [Acción P0] → objetivo: p95 de [x] ms → [y] ms; error < [z]%.
```

## 2. Definición de SLI/SLO + error budget

Convierte "queremos que sea rápido" en objetivos medibles con presupuesto de error y política operativa. Base para priorizar trabajo y frenar features cuando el budget se agota.

```markdown
# SLI/SLO — [servicio] — [fecha]

## SLI (qué se mide)
- Definición: [ej. % de requests a /api con latencia < 300 ms y status < 500]
- Fuente: [server-side en gateway] — cómo se calcula: [good events / valid events]

## SLO (objetivo)
- Objetivo: [ej. 99.0% de requests cumplen el SLI]
- Umbral de latencia: p95 < [x] ms, p99 < [y] ms
- Ventana: [rolling 28 días]

## Error budget
- Presupuesto: [ej. 1.0% ≈ 6h 43m de incumplimiento / 28 días]
- Consumo actual: [x]% — quema (burn rate): [x]× en [ventana]

## Política al agotar el budget
- Al 50% consumido: [alerta al dueño, revisión de causas]
- Al 100%: [congelar features de riesgo; solo trabajo de fiabilidad/performance hasta recuperar]
- Excepción: [quién aprueba y bajo qué condición]

## Próximos pasos + criterio de éxito
- [Instrumentar SLI en [lugar]] → criterio: SLO reportado en dashboard, alerta de burn rate activa.
```

## 3. Performance budget + cost budget

Límites duros por escenario para latencia, tamaño y recursos, más el costo por request. Se aplican en CI para que ninguna regresión pase silenciosa. Ver enforcement en [performance-cicd.md](performance-cicd.md) y detalle de costo en [infra-capacidad-costo.md](infra-capacidad-costo.md).

```markdown
# Performance & Cost Budget — [escenario/página/endpoint] — [fecha]

## Performance budget
| Métrica              | Presupuesto | Actual | Estado |
|----------------------|-------------|--------|--------|
| LCP / p95 latencia   | [x] ms      | [y]    | [OK/FALLA] |
| Tamaño transferido   | [x] KB      | [y]    | [OK/FALLA] |
| JS ejecutado         | [x] KB      | [y]    | [OK/FALLA] |
| Queries por request  | [x]         | [y]    | [OK/FALLA] |
| CPU por request      | [x] ms      | [y]    | [OK/FALLA] |

## Cost budget
- $/1000 requests: presupuesto [$x] — actual [$y]
- $/usuario activo/mes: [$x] — driver principal de costo: [cómputo / egress / DB]

## Enforcement en CI
- Herramienta: [Lighthouse CI / bundlesize / k6 thresholds]
- Regla: el pipeline **falla** si se supera el presupuesto en [±x]%.

## Próximos pasos + criterio de éxito
- [Añadir gate en CI] → criterio: PR bloqueado ante regresión > [x]%.
```

## 4. Informe de optimización antes/después

El entregable estrella: prueba con números que un cambio mejoró algo, sin degradar otra cosa. Sin medición de "después" verificada, el cambio no se considera hecho.

```markdown
# Optimización antes/después — [título] — [fecha]

## Cambio aplicado
- [Descripción: ej. índice compuesto (tenant_id, created_at) + cache de 60s]
- Tier aplicado: [T1 peakformance implementó / T2 co-implementado con [dueño]]

## Hipótesis
- [Esperamos que el índice elimine el full scan y baje p95 de [x] a [y] ms]

## Métrica objetivo
- [p95 latencia de /reportes] bajo carga de [x RPS]

## Resultado medido (mismo escenario, misma carga)
| Métrica         | Antes  | Después | Δ       |
|-----------------|--------|---------|---------|
| Latencia p50    | [x] ms | [y] ms  | -[z]%   |
| Latencia p95    | [x] ms | [y] ms  | -[z]%   |
| Latencia p99    | [x] ms | [y] ms  | -[z]%   |
| CPU / recurso   | [x]%   | [y]%    | -[z]%   |
| $/1k requests   | [$x]   | [$y]    | -[z]%   |

## Trade-offs
- [ej. +[x] MB de RAM por cache; escritura +[y] ms por el índice]

## Verificación
- Re-corrida de la prueba: [enlace/artefacto] — regresión funcional: [ninguna / detalle por amado]

## Próximos pasos + criterio de éxito
- [Promover a prod tras 24h en staging] → criterio: p95 sostenido < [y] ms sin nuevos errores.
```

## 5. Handoff / parche a dueño de dominio

Cuando el fix vive en un dominio con dueño ([farola](frontend-performance.md), [motor](backend-performance.md), [andulfo](datos-performance.md), [sysuniversal-ai](ia-ml-performance.md), eneida, uxuifull, destroyer), peakformance entrega el diagnóstico y un PoC listo para aceptar/rechazar con criterios objetivos (modelo T2).

```markdown
# Handoff de performance — para [farola/motor/andulfo/sysuniversal-ai] — [fecha]

## Problema (con evidencia)
- [Descripción] — señal: [traza/flamegraph/query plan] — impacto: p95 [x] ms, [y]% de tráfico.

## Fix propuesto (diff / PoC)
- [Resumen del cambio]
```diff
- [línea antes]
+ [línea después]
```
- PoC / rama: [enlace]

## Medición esperada
- [p95 de [x] ms → [y] ms; -[z]% CPU] bajo [carga de referencia]

## Criterios de aceptación
- [ ] p95 < [x] ms con [carga]
- [ ] Sin regresión funcional (validado por amado)
- [ ] Dentro del [performance budget](performance-cicd.md)

## Cómo verificar
- [Correr [script/prueba]; comparar contra la línea base de la sección 1]

## Próximos pasos + criterio de éxito
- [Dueño implementa/ajusta] → criterio: criterios de aceptación en verde y antes/después publicado.
```

## 6. Plan de prueba de carga

Diseña cómo se estresará el sistema antes de tocarlo, con salvaguardas para no dañar entornos reales. Detalle metodológico en [pruebas-de-carga.md](pruebas-de-carga.md).

```markdown
# Plan de prueba de carga — [sistema] — [fecha]

## Tipo de prueba
- [load / stress / spike / soak / breakpoint]

## Workload model
- Perfil: [ej. 70% lectura, 30% escritura] — ramp: [0→500 RPS en 5 min, hold 20 min]
- Datos: [dataset de [x] filas, cardinalidad realista]

## Criterios (vs SLO)
- Aprueba si: p95 < [x] ms, error < [y]%, sin saturar recurso > [z]% — ver [SLO](medicion-observabilidad.md)

## Entorno
- [prod-like aislado] — paridad con prod: [réplicas, tamaño, red]

## Riesgos y salvaguardas
- Riesgo: [afectar datos/entorno compartido] — salvaguarda: [entorno aislado, kill-switch, límite de RPS, ventana horaria]

## Próximos pasos + criterio de éxito
- [Ejecutar y comparar contra línea base] → criterio: veredicto PASS/FAIL con percentiles publicados.
```

## 7. Plan de capacidad

Proyecta si el sistema aguantará la demanda futura, dónde se rompe, cuánto cuesta y cuándo escalar. Ver costo y headroom en [infra-capacidad-costo.md](infra-capacidad-costo.md) y escalabilidad en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).

```markdown
# Plan de capacidad — [servicio] — [horizonte: ej. 12 meses]

## Demanda proyectada
- Actual: [x] RPS pico / [y] usuarios — crecimiento: [z]%/mes
- Proyección a [horizonte]: [x] RPS pico

## Headroom
- Capacidad actual sostenible: [x] RPS al [y]% de recurso — headroom: [z]%

## Punto de saturación
- Se satura en [x] RPS por [recurso: CPU/DB/conexiones] — evidencia: [breakpoint test §6]

## Costo
- Costo actual: [$x]/mes — a demanda proyectada: [$y]/mes — $/request: [$z]

## Disparadores de autoscaling
- Escalar out cuando: [señal causal primaria: profundidad de cola > [x] o latencia p95 > [y] ms; CPU > 65% solo como señal secundaria] — escalar in cuando: [cola ~0 y p95 < [z] ms sostenido 10 min]
- Límites: min [x] / máx [y] réplicas — techo de costo: [$z]/mes

## Próximos pasos + criterio de éxito
- [Ajustar políticas / provisionar] → criterio: headroom ≥ [x]% al pico proyectado sin exceder costo budget.
```

---

**Recordatorio de cierre.** Ningún entregable de peakformance sale sin **números** (percentiles, no promedios), **evidencia** verificable y comparación **antes/después**. Todos cierran con **próximos pasos** y **criterios de éxito medibles**, y declaran el **tier** aplicado y el **dueño** cuando el fix vive en un dominio. Ver hermanos: [estrategia-performance.md](estrategia-performance.md), [medicion-observabilidad.md](medicion-observabilidad.md), [pruebas-de-carga.md](pruebas-de-carga.md), [performance-cicd.md](performance-cicd.md), [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md), [ejemplos.md](ejemplos.md).
