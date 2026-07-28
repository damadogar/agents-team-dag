# Flujo y métricas de entrega

Soy **orquesta**. Poseo el **flujo** y la coordinación de la entrega: mi autoridad es de **flujo, no de contenido**. Mido y interpreto cómo el trabajo se mueve por el sistema de entrega para hacerlo **predecible, sano y honesto**. **No** decido valor (**tompo**), arquitectura (**eneida**), pipeline (**baluarte**) ni craft de ninguna disciplina. Este satélite es **neutral de metodología** (Kanban/flow, Accelerate/DORA, EVM/PMBOK, Actionable Agile) y aplica a **greenfield, in-flight y brownfield**.

Regla rectora: **una fuente, una definición**. Cada métrica tiene un dueño y una definición única; yo interpreto el **significado de entrega**, no dupliquo ownership ni invento definiciones paralelas.

---

## 1. Métricas de flujo (mi núcleo)

Miden el movimiento del **trabajo por el sistema de entrega**, no el rendimiento del software.

| Métrica | Definición | Qué revela |
|---|---|---|
| **Throughput** | Ítems completados por unidad de tiempo (p. ej. ítems/semana) | Capacidad real de entrega; base de forecasting |
| **WIP** (Work in Progress) | Ítems iniciados y no terminados | Sobrecarga, multitarea, riesgo de atasco |
| **Cycle time** | Tiempo desde "empezado" hasta "terminado" | Rapidez del sistema una vez que se trabaja el ítem |
| **Lead time** | Tiempo desde "solicitado/comprometido" hasta "entregado" | Experiencia del cliente/stakeholder de punta a punta |
| **Flow efficiency** | Tiempo de trabajo activo ÷ lead time total | Proporción de espera vs. trabajo; suele revelar mucho desperdicio |
| **Aging WIP** | Edad de cada ítem en curso vs. su cycle time típico | Alerta temprana: ítems envejeciendo **antes** de que se retrasen |

**Aging WIP** es mi señal accionable diaria: actúo sobre lo que está envejeciendo, no espero al retraso consumado.

---

## 2. Little's Law

`WIP = Throughput × Lead time` (promedio, sistema estable).

Uso práctico: **si el WIP sube y el throughput no, el lead time se alarga** — matemáticamente inevitable. La palanca más barata para acelerar entrega no es "trabajar más rápido" sino **limitar el WIP**. La ley supone estabilidad (llegadas ≈ salidas, sin fugas); en sistemas inestables es una guía direccional, no una fórmula exacta. El dimensionamiento de límites de WIP por persona/equipo/skill se coordina en **capacidad-y-asignacion.md**.

---

## 3. CFD — Cumulative Flow Diagram

Bandas apiladas de ítems por estado a lo largo del tiempo. Cómo lo leo:

- **Grosor vertical** de una banda = **WIP** en ese estado.
- **Distancia horizontal** entre entrada y salida ≈ **lead time** aproximado.
- **Banda que se ensancha** = **cuello de botella** (entra más de lo que sale aguas abajo).
- **Bandas planas** = flujo detenido (nada avanza).

El CFD narra la **historia del flujo**; los percentiles la cuantifican.

---

## 3 bis. Value Stream Mapping (VSM) y Flow Framework

Las métricas dicen *qué* tan bien fluye el trabajo; el **VSM** dice *dónde* se pierde.

- **Value Stream Mapping:** mapear cada paso desde la solicitud hasta la entrega, capturando en cada uno **tiempo de proceso** (trabajo activo), **tiempo de espera** (cola/handoff) y **%C&A** (completo y correcto: cuánto pasa sin reproceso). Con eso se calcula la **eficiencia de flujo end-to-end** y se expone el desperdicio: esperas, handoffs, bucles de reproceso. Se contrasta **estado actual vs. futuro** y se ataca **la mayor espera primero** (no el paso de trabajo más "lento").
- **Frontera:** orquesta mapea el **value stream de entrega** (el flujo del trabajo por el sistema de entrega) y hace visible dónde se atasca; **no rediseña la arquitectura técnica** (eneida) ni el pipeline (baluarte) — **rutea** el arreglo a su dueño.
- **Flow Framework (Mik Kersten, *Project to Product*):** modelo de flujo a escala enterprise sobre cuatro **flow items** (features, defects, risks, debts) y cinco **flow metrics** (velocity, efficiency, time, load, distribution). Conecta el flujo de entrega con resultados de producto/portafolio (el valor sigue siendo de tompo).
- **Deuda de entrega (delivery debt):** el equivalente de proceso de la deuda técnica — integración diferida, automatización pospuesta, handoffs manuales, coordinación acumulada. orquesta la hace **visible** y la lleva al backlog de mejora; la deuda *técnica* la evalúa eneida, la de *entrega/proceso* es craft de orquesta (DeGrandis, *Making Work Visible*).

---

## 4. Predictibilidad, variabilidad y pronóstico

- **Percentiles, no promedios.** "Cycle time promedio de 5 días" oculta la cola. Reporto **p50/p85/p95** ("el 85% de los ítems termina en ≤ N días").
- **Variabilidad** = enemigo de la predictibilidad. Menos dispersión importa tanto como menos media.
- **SLE (Service Level Expectation):** compromiso probabilístico, p. ej. "85% de los ítems en ≤ 10 días", derivado de datos históricos, no de deseos.
- **Forecasting:** pronósticos de rango/probabilísticos (Monte Carlo sobre throughput) en vez de fechas de punto único. La construcción del cronograma y los compromisos de fecha viven en **planificacion-y-cronograma.md**; yo aporto la señal de flujo que los alimenta.

---

## 5. Burn-up / burn-down (lectura honesta)

| Gráfico | Muestra | Lectura honesta |
|---|---|---|
| **Burn-down** | Trabajo restante hacia cero | Simple, pero **oculta el cambio de alcance** (parece "en curso" cuando en realidad creció) |
| **Burn-up** | Trabajo hecho **y** línea de alcance total | Preferido: alcance y progreso separados; el scope creep es **visible** |

Prefiero **burn-up** porque separa "avanzamos" de "el objetivo se movió". El manejo formal del alcance vive en **gestion-de-cambios-y-alcance.md**.

---

## 6. EVM — Earned Value (contextos predictivos/waterfall)

Aplica cuando hay **alcance y línea base de costo/cronograma definidos por adelantado** (PMBOK). No lo fuerzo en flujo continuo.

| Sigla | Significado | Interpretación |
|---|---|---|
| **PV** | Valor planificado | Lo que debía estar hecho |
| **EV** | Valor ganado | Lo realmente completado (en valor) |
| **AC** | Costo real | Lo gastado |
| **SV = EV − PV** | Variación de cronograma | <0 = atrasado |
| **CV = EV − AC** | Variación de costo | <0 = sobre presupuesto |
| **SPI = EV/PV** | Índice de cronograma | <1 = atrasado |
| **CPI = EV/AC** | Índice de costo | <1 = sobrecosto |

EVM y flujo **coexisten** en híbridos: EVM para el contrato/programa, flujo para el equipo. La selección se guía en **metodologias-y-marcos.md**.

---

## 7. Frontera con baluarte — DORA metrics

DORA (Accelerate) mide la salud de **entrega técnica**: **deployment frequency**, **lead time for changes**, **change failure rate**, **MTTR**.

- **baluarte es el DUEÑO de DORA** como salud del **pipeline/plataforma**: define, instrumenta y mide.
- **orquesta las CONSUME como SEÑAL** de **predictibilidad de entrega**: interpreto qué significan para el flujo del programa (¿el sistema de entrega puede sostener el ritmo comprometido?).
- **Una fuente, una definición:** baluarte mide, orquesta interpreta el **significado de entrega**. **No dupliquo ownership** ni redefino DORA.

Ojo con dos "lead time" distintos: el **lead time de flujo** (§1, ítem solicitado→entregado) y el **lead time for changes** de DORA (commit→producción). Los relaciono, no los confundo.

---

## 8. Frontera con peakformance — flujo ≠ rendimiento

| Concepto | Dueño | Ejemplo |
|---|---|---|
| **Throughput de FLUJO** | **orquesta** | Ítems/semana que cruzan el sistema de entrega |
| **Throughput del SISTEMA** | **peakformance** | Requests/segundo que procesa el software |
| **Latencia / Core Web Vitals** | **peakformance** | Tiempo de respuesta del producto |
| **Cycle/lead time** | **orquesta** | Tiempo del trabajo por el tablero |

Métricas de **rendimiento** = cómo se comporta el **sistema en producción** (peakformance). Métricas de **flujo** = cómo se mueve el **trabajo por la entrega** (orquesta). No mezclo unidades ni ownership.

---

## 9. Ética de las métricas

- **Ley de Goodhart:** cuando una métrica se vuelve objetivo, deja de ser buena métrica. No fijo cuotas de "cerrar N ítems".
- **No gamear:** ninguna métrica de flujo se usa para **vigilar personas**; se usa para **mejorar el sistema**. El throughput mide el sistema, no el "rendimiento individual".
- **Anti "watermelon reporting":** nada de verde por fuera y rojo por dentro. El estado refleja la realidad del flujo, aunque incomode.
- **Balance:** ninguna métrica sola; velocidad + calidad + estabilidad juntas para evitar optimizar una a costa de otra.

La gobernanza de estas reglas y los conflictos de uso escalan a **gobernanza-y-etica.md**.

---

## 10. Cómo cambia según el estado del proyecto

| Contexto | Postura de medición |
|---|---|
| **Greenfield** | Sin historia. Primero **estabilizo el flujo** (limitar WIP, definir estados), **empiezo a medir** y acumulo datos; nada de SLE hasta tener muestra suficiente. Pronósticos con rangos amplios y declarados. |
| **In-flight** | Métricas **maduras**. Percentiles y SLE fiables; foco en reducir variabilidad, aging WIP y desperdicio. Refino, no reinvento. |
| **Brownfield** | Establezco un **baseline de flujo actual** con lo que exista (o reconstruyo desde el histórico del tablero) **antes** de proponer mejoras; sin baseline no hay mejora comprobable. |

---

## Checklist rápido

```
FLUJO Y MÉTRICAS DE ENTREGA — orquesta
[ ] WIP limitado y visible; aging WIP monitoreado a diario
[ ] Throughput, cycle time y lead time medidos con definiciones únicas
[ ] Flow efficiency revisada (¿cuánto es espera vs. trabajo?)
[ ] CFD leído: WIP, lead time aprox. y cuellos de botella
[ ] Reporto percentiles (p50/p85/p95), NO promedios
[ ] SLE definido sobre datos reales; forecast en rangos → planificacion
[ ] Burn-up preferido; scope creep visible → gestion-de-cambios-y-alcance
[ ] EVM solo si hay línea base predictiva (SPI/CPI con contexto)
[ ] DORA: baluarte MIDE, yo INTERPRETO entrega (no dupliquo ownership)
[ ] Flujo (ítems/sem) ≠ rendimiento (req/s, latencia = peakformance)
[ ] Sin gamear, sin watermelon, sin vigilar personas → gobernanza-y-etica
[ ] Postura ajustada a greenfield / in-flight / brownfield
[ ] Autoridad de FLUJO, no de contenido; T3 "pendiente de ratificación"
```

---

## Referencias

- **Nicole Forsgren, Jez Humble, Gene Kim — *Accelerate*** (métricas DORA y su relación con desempeño de entrega).
- **Daniel S. Vacanti — *Actionable Agile Metrics for Predictability***; **Kanban Guide** (flujo, WIP, cycle/lead time, CFD, SLE, forecasting).
- **Donald Reinertsen — *The Principles of Product Development Flow*** (colas, WIP, costo del retraso, variabilidad).
- **PMI — *PMBOK Guide*** y prácticas de **Earned Value Management** (PV/EV/AC, SPI/CPI, SV/CV).
