# Planificación y cronograma

> Cómo **orquesta** convierte el roadmap de outcomes que fija **tompo** en un **plan de entrega** secuenciado, calendarizado y con forecast probabilístico. orquesta posee el **flujo**: descompone para planificar, agrega estimaciones ajenas, secuencia, calendariza, hace forecast y mantiene el baseline. **No decide valor** (eso es de tompo vía prioridad), **no decide la secuencia técnica de dependencias** (eso es de eneida) ni **la ventana técnica de deploy** (eso es de baluarte). orquesta calendariza y coordina lo que los dueños deciden.

Ver también: [gestion-de-dependencias.md](gestion-de-dependencias.md), [capacidad-y-asignacion.md](capacidad-y-asignacion.md), [flujo-y-metricas-de-entrega.md](flujo-y-metricas-de-entrega.md), [gestion-de-cambios-y-alcance.md](gestion-de-cambios-y-alcance.md), [gestion-de-programa.md](gestion-de-programa.md).

## 1. Del roadmap de outcomes al plan de entrega

El insumo es el **roadmap de outcomes** que fija tompo: qué resultados de negocio se buscan y en qué orden de valor. orquesta **no reordena por valor**; toma ese orden como restricción y produce un **plan de entrega**: la traducción de outcomes a un flujo de trabajo secuenciado, con hitos, dependencias resueltas y fechas defendibles.

| Artefacto | Lo fija | orquesta hace |
|---|---|---|
| Roadmap de outcomes / orden de valor | tompo | Lo toma como entrada; no lo altera |
| Secuencia técnica de dependencias | eneida | La respeta al secuenciar; la calendariza |
| Ventana/estrategia técnica de deploy | baluarte | La encaja en el cronograma; coordina la cadencia |
| Estimación del craft (por ítem) | cada dueño | La **agrega** y convierte en forecast |
| Plan de entrega, hitos, baseline, forecast | **orquesta** | Es su craft (T1) |

## 2. Descomposición del trabajo (insumo, no propiedad)

orquesta estructura el trabajo para **poder planificar** — WBS jerárquico o *story slicing* incremental — pero **no llena el contenido**: el valor de cada ítem lo define tompo, el desglose técnico lo define eneida y los ejecutores (motor, farola, palma, andulfo, etc.). orquesta cuida las propiedades **estructurales** del desglose para que sea planificable:

- **MECE / sin solapes**: cada pieza tiene un dueño claro y no se cuenta dos veces.
- **Granularidad planificable**: ítems lo bastante pequeños para fluir (vertical slicing sobre horizontal cuando aplica) y con *acceptance* dueño-definida.
- **Trazabilidad**: cada ítem cuelga de un outcome de tompo (evita trabajo huérfano).
- **DoR de flujo**: listo-para-empezar = dependencias identificadas, dueño asignado, tamaño estimado por el dueño. El DoR de **valor** lo pone tompo.

## 3. Estimación agregada (orquesta agrega, no estima el craft)

Principio duro: **orquesta no estima el esfuerzo del craft**. Cada dueño estima en la unidad que le sirva (story points, tallas t-shirt, #-de-ítems, ideal-days). orquesta **consolida y normaliza** esas estimaciones y las convierte en **forecast**. La estimación es del especialista; el forecast es de orquesta.

| Unidad del dueño | Uso | Conversión de orquesta |
|---|---|---|
| Story points / velocity | Equipos Scrum con historia | Velocity media/percentil → capacidad por iteración |
| Tallas t-shirt (S/M/L) | Estimación gruesa temprana | Rango por talla → banda de esfuerzo |
| Conteo de ítems (#) | Kanban / flujo continuo | Throughput histórico → Monte Carlo |
| Ideal-days / horas | Trabajo determinista | Buffer de incertidumbre + calendario |

Sesgos a neutralizar al agregar: falacia de planificación, *padding* invisible, doble-conteo de contingencia. Preferir **rangos** sobre números únicos y **datos de flujo reales** sobre juicio cuando existan.

> Técnicas que orquesta puede pedir al dueño o aplicar al agregar: **tres puntos / PERT** (optimista, probable, pesimista → media ponderada y varianza para dimensionar el buffer), **right-sizing** (partir ítems a tamaño comparable para que baste el conteo) y, en equipos maduros de flujo, **#NoEstimates** (contar ítems right-sized y pronosticar por throughput, sin estimar cada uno). La elección es del contexto; **el esfuerzo del craft lo estima siempre el dueño**.

## 4. Ruta crítica (CPM) y cadena crítica (CCPM)

- **CPM (Critical Path Method)**: la cadena más larga de actividades dependientes fija la duración mínima. orquesta la calcula sobre las dependencias que **eneida** declara técnicas y las que emergen de capacidad. Vigila *float/slack*: cero holgura = crítico; adelgazar la ruta crítica es la palanca de aceleración de mayor retorno.
- **CCPM (Critical Chain, Goldratt)**: además de dependencias lógicas, considera la **contención de recursos** (un mismo dueño no puede estar en dos frentes). Se **quita** el padding de cada tarea y se consolida en **buffers explícitos**: *project buffer* al final y *feeding buffers* donde ramas alimentan la cadena crítica. Se gestiona por **consumo de buffer** (fever chart), no por cumplimiento tarea-a-tarea. Reduce estudiante/Parkinson y multitasking nocivo.

Regla de frontera: la **secuencia lógica** de qué-antes-de-qué por razones técnicas es de eneida; orquesta la traduce a fechas, holguras y buffers.

## 5. Hitos y release planning

Un **hito (milestone)** es un punto de verificación de duración cero: integración lista, gate de calidad, dependencia externa satisfecha, decisión go/no-go. orquesta define hitos **verificables** (criterio binario), no fechas de deseo.

- **Roadmap → releases/incrementos**: agrupa ítems en releases coherentes alineados a los outcomes de tompo. El *scope* del release lo gobierna tompo (valor); orquesta calendariza el release y coordina con baluarte la **ventana** y estrategia de despliegue (canary/blue-green/rolling las decide baluarte).
- **Release plan** = secuencia de incrementos + hitos + dependencias externas + forecast por incremento. En marcos escalados (PI/big-room planning) orquesta **facilita** el planning; las decisiones de contenido siguen siendo de sus dueños.

## 5 bis. Secuenciación económica: Cost of Delay, CD3 y WSJF

Ordenar por dependencias y capacidad no basta: cuando varios ítems compiten y el orden es libre, la pregunta económica es **qué secuencia minimiza el coste total de retraso**. Aquí orquesta reclama su mitad legítima de la secuenciación de flujo (Reinertsen).

- **Cost of Delay (CoD):** el coste económico por unidad de tiempo de **no** tener algo terminado — la variable más importante y peor cuantificada del desarrollo. Su **perfil de urgencia** (Reinertsen) marca la forma de la curva: *estándar* (decae con el tiempo), *fecha fija* (salto en una fecha), *expedite* (altísimo e inmediato), *intangible* (bajo hoy, sube después).
- **CD3 = CoD ÷ Duración** (Cost of Delay Divided by Duration): la regla de secuenciación óptima —primero lo de **mayor CoD y menor duración**— minimiza el retraso económico agregado (weighted shortest job first).
- **WSJF (SAFe) = Cost of Delay ÷ Job Size**, con CoD ≈ valor de negocio + criticidad temporal + reducción de riesgo/habilitación de oportunidad. Es la operacionalización escalada de CD3; misma idea económica.

**Frontera (clave):** los componentes de **valor** del CoD (valor de negocio, criticidad temporal, riesgo/oportunidad) son **insumo de tompo**; la **duración/tamaño** (el denominador) la calcula **orquesta** desde la estimación agregada y el flujo. orquesta **computa y propone la secuencia económica**; **no fija el valor**. Es exactamente el reparto **WSJF = CoD (valor + criticidad + riesgo, insumo de tompo) ÷ tamaño (orquesta)**.

> Uso: cuando tompo entrega prioridades de valor pero deja grados de libertad en el orden, orquesta secuencia por CD3/WSJF para minimizar el CoD total, respetando toda restricción dura de valor o de dependencia.

## 6. Forecasting probabilístico (el núcleo)

Una fecha única es una mentira de precisión. orquesta forecast en **distribuciones**, no puntos.

- **Monte Carlo sobre throughput**: se muestrea el histórico de *items completados por unidad de tiempo* miles de veces para responder **"¿cuándo estará?"** (dado un scope) y **"¿cuánto cabe?"** (dada una fecha). No requiere estimar cada ítem — basta el conteo y la historia de flujo.
- **Percentiles**: se comunica **P50 / P85** (y P95 para compromisos externos). P85 como fecha-compromiso razonable; P50 como expectativa interna. Nunca prometer el optimista.
- **Rango + confianza vs. fecha-promesa de punto único**: "80–95% de confianza de terminar entre la semana 9 y la 12" es honesto y accionable; "termina el día 74" no lo es. El rango explicita la incertidumbre y habilita conversación de scope con tompo.

| Pregunta del negocio | Método | Salida |
|---|---|---|
| ¿Cuándo estará *este* alcance? | MC "how long" | Distribución de fechas → P50/P85/P95 |
| ¿Cuánto cabe para *esta* fecha? | MC "how many" | Distribución de #ítems → rango |
| ¿Cuánto arriesga un cambio de scope? | Re-simular con nuevo backlog | Δ percentiles |

Prerrequisitos de calidad del forecast: throughput estable-suficiente, WIP acotado, definición consistente de "hecho", ítems de tamaño comparable (o *right-sizing* previo).

## 7. Baseline de cronograma y control de cambios

El **baseline** es la foto aprobada del plan (scope + secuencia + fechas/forecast) contra la cual se mide la desviación. Sin baseline no hay varianza medible ni honestidad sobre el *slip*.

- orquesta **mantiene y versiona** el baseline; toda re-baseline se **justifica y registra**.
- Un cambio de **scope** o de **prioridad** que mueva el baseline es un evento de [gestion-de-cambios-y-alcance.md](gestion-de-cambios-y-alcance.md): tompo autoriza el cambio de valor/alcance, orquesta re-planifica y re-forecast, y comunica el nuevo rango. **orquesta nunca absorbe scope en silencio** para "salvar la fecha".
- Distinguir **scope creep** (deriva no autorizada) de **cambio autorizado**. El primero se hace visible; el segundo se re-basela.

## 8. Cómo cambia el enfoque según el estado del sistema

| Contexto | Reto dominante | Enfoque de planificación |
|---|---|---|
| **Greenfield (0→1)** | Sin historia de flujo | Estimación por **analogía / clase de referencia** (reference-class forecasting), rangos amplios, hitos de descubrimiento, re-planificar frecuente conforme llega data. Evitar precisión falsa. |
| **In-flight (en construcción)** | Ya hay throughput real | **Monte Carlo** sobre datos propios, P50/P85, cadencia de re-forecast por iteración, control por consumo de buffer / burn-up. |
| **Brownfield / legacy** | Restricciones heredadas | Mapear **dependencias y ventanas** heredadas (freezes, migraciones, sistemas acoplados), coordinar **ventanas de migración/deploy** con baluarte, buffers mayores por incertidumbre de lo desconocido, secuencia técnica con eneida. |

En los tres casos el forecast es **vivo**: se actualiza con cada dato nuevo de flujo; una fecha no se defiende, se **re-forecast**.

## 9. Fronteras (dónde termina el flujo y empieza el contenido)

| Decisión | Dueño | orquesta |
|---|---|---|
| Valor y **orden de valor** | tompo | Lo respeta; no reordena por preferencia propia |
| **Secuencia técnica** de dependencias | eneida | La calendariza; no la inventa |
| **Ventana/estrategia técnica** de deploy | baluarte | La encaja en el cronograma; coordina cadencia |
| Estimación del craft por ítem | cada dueño | Agrega y forecast |
| **Calendario, hitos, baseline, forecast, secuenciación de flujo** | **orquesta** | Su craft |

**Modelo tiered META**: **T1** orquesta planifica y forecast directo (su craft). **T2** co-facilita el planning **con** el dueño (tompo prioriza, eneida secuencia, baluarte ubica ventana — ellos deciden). **T3** *potestad de flujo* solo si el dueño está ausente/saturado y el flujo se detiene: orquesta fija una **fecha/secuencia provisional** marcada **"pendiente de ratificación del dueño"** — jamás decide valor, arquitectura ni contenido.

## Referencias

- **PMI, PMBOK Guide** — WBS, CPM, gestión de cronograma y baselines.
- **E. Goldratt, *Critical Chain*** — CCPM, buffers de proyecto/alimentación, contención de recursos.
- **D. Vacanti, *Actionable Agile Metrics* / *When Will It Be Done?*** — forecasting Monte Carlo por throughput, percentiles.
- **D. Reinertsen, *The Principles of Product Development Flow*** — economía del flujo, WIP, colas.

```text
Checklist rápido — Planificación y cronograma
[ ] El plan cuelga del roadmap de outcomes de tompo (orden de valor respetado, no reordenado)
[ ] Descomposición estructurada MECE y planificable; contenido de valor=tompo, técnico=eneida
[ ] Estimaciones son de los dueños; orquesta las agregó/normalizó, NO las inventó
[ ] Ruta crítica identificada; holgura y buffers (project/feeding) explícitos (CCPM)
[ ] Hitos verificables (criterio binario), no fechas-deseo
[ ] Releases/incrementos calendarizados; ventana técnica de deploy coordinada con baluarte
[ ] Forecast probabilístico (Monte Carlo/throughput): P50/P85 comunicados como RANGO, no punto
[ ] Enfoque ajustado al contexto: analogía (greenfield) / MC real (in-flight) / ventanas (brownfield)
[ ] Baseline versionado; todo cambio de scope pasa por tompo y se re-basela (sin creep silencioso)
[ ] Forecast vivo: se re-actualiza con cada dato de flujo; no se "defiende" una fecha
[ ] T3 solo si el dueño está ausente y el flujo se detiene: decisión de FLUJO "pendiente de ratificación"
```
