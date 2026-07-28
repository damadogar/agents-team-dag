# Infraestructura, Capacidad, Costo y Sostenibilidad

Aquí peakformance trata **rendimiento, costo y energía como una sola función de optimización**, no como tres metas separadas. Un sistema no es "bueno" porque sea rápido: es bueno cuando entrega el percentil objetivo a la **utilización correcta**, con **unit economics** defendibles y la **menor huella energética** posible. Neutralidad total: nubes, proveedores y topologías aparecen solo como **p. ej.** (multi-cloud, on-prem, edge, híbrido); ninguno se favorece por defecto — se elige por **contexto y evidencia, no por moda**. Rige greenfield (dimensionar desde el diseño) y brownfield (medir utilización real y recuperar terreno sin romper). Principio raíz heredado de [estrategia-performance.md](estrategia-performance.md): **"Mide, no adivines"**, con percentiles y utilización reales, y comparación **antes/después**.

Marcos: **Well-Architected — pilares Performance Efficiency + Cost Optimization**, **FinOps**, **Green Software Foundation (SCI)**, **Google SRE (capacity planning)**, **USE (Utilization/Saturation/Errors)**.

## 1. Capacity planning: headroom y punto de saturación

Capacidad no es "cuántos servidores tengo" sino **cuánta demanda absorbo antes de que la latencia explote**. La teoría de colas manda: al acercarse a la saturación (utilización → 1), la latencia crece **no linealmente** — el p99 se dispara mucho antes de agotar la CPU.

| Concepto | Definición | Cómo se mide |
|---|---|---|
| **Punto de saturación** | Utilización a partir de la cual el p99 se degrada | Prueba de carga escalonada hasta el codo (ver [pruebas-de-carga.md](pruebas-de-carga.md)) |
| **Headroom** | Margen entre demanda pico y punto de saturación | (capacidad_saturación − pico_actual) / capacidad_saturación |
| **Margen para picos** | Reserva para ráfagas y estacionalidad | Relación pico/promedio × factor de crecimiento |
| **Forecasting de demanda** | Proyección de tráfico/datos a 6-18 meses | Serie histórica + eventos conocidos + tendencia |

Regla operativa: **fija el objetivo de utilización por debajo del codo, no del 100%**. Un sistema al 90% de CPU "aprovechado" suele estar ya fuera de SLO. El headroom es un **seguro pagado**, no desperdicio; su tamaño se decide por criticidad y por cuán rápido puedes escalar. Método para hallar el codo: [metodologia-diagnostico.md](metodologia-diagnostico.md).

## 2. Right-sizing y utilización objetivo

El pecado más caro de la infra es el **desajuste**: sobre-aprovisionar (pagar aire) o infra-aprovisionar (romper SLO). Right-sizing = ajustar recursos a la **utilización real observada**, no a la solicitada ni a la "por si acaso".

| Síntoma | Diagnóstico | Acción T1 |
|---|---|---|
| Utilización sostenida muy baja (p. ej. CPU <15%, memoria holgada) | Sobre-aprovisionamiento | Reducir tamaño/instancias; consolidar |
| Saturación recurrente, p99 fuera de SLO | Infra-aprovisionamiento | Subir tamaño o réplicas; revisar autoscaling |
| Reserva alta pero uso pico bajo | Requests/limits mal fijados | Ajustar request al p95 real, limit al pico |
| Densidad baja por límites conservadores | Miedo, no dato | Aumentar densidad con guardas de saturación |

**Utilización objetivo ≠ utilización máxima.** Se apunta a una banda (p. ej. 50-70% en cómputo elástico) que deja headroom para el pico entre ciclos de escalado. El **sobre-aprovisionamiento es deuda financiera silenciosa**: no rompe nada, solo drena presupuesto mes a mes. Medir siempre **request vs. uso real** (el gap es dinero tirado).

## 3. Autoscaling desde la economía

Autoscaling no es un botón "on": es una **decisión económica** con costo propio. La elasticidad tiene precio (cold starts, sobre-escalado, complejidad).

| Eje | Reactivo | Predictivo |
|---|---|---|
| Disparador | Métrica actual cruza umbral (CPU, RPS, cola) | Forecast de demanda / patrón horario |
| Fortaleza | Simple, responde a lo inesperado | Adelanta el pico, absorbe cold start |
| Debilidad | Llega tarde al pico brusco; puede oscilar | Requiere patrón estable y modelo |
| Uso típico (p. ej.) | Cargas erráticas | Estacionalidad conocida (picos por hora/campaña) |

Parámetros que peakformance gobierna (T1):

- **Mínimos/máximos:** el mínimo protege del cold start y del "escalar desde cero" en el pico; el máximo es el **tope de gasto** y de blast radius.
- **Cold start:** medir su costo en latencia (p99 del primer request) y en dinero (capacidad tibia pre-provisionada vs. penalización de arranque). Elegir por SLO, no por dogma.
- **Umbrales y cooldown:** evitar **flapping** (escalar/desescalar en bucle) — cada ciclo cuesta y desestabiliza.
- **Métrica correcta:** escalar por la señal que refleja saturación real (a veces profundidad de cola o latencia, no CPU).

**Costo de la elasticidad:** escalar bajo demanda a precio on-demand puede salir más caro que capacidad base reservada. El patrón sano combina **base reservada + pico elástico**. Detalle de escalado horizontal/vertical y sus límites en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md).

## 4. Costo-performance / FinOps

Toda decisión de performance tiene precio; se gobierna con **unit economics**, no con la factura absoluta.

**Métricas núcleo:** **$/request**, **$/transacción**, **$/1k inferencias**, **$/tarea**, **costo por usuario activo**. Un sistema "más rápido" que duplica el $/request puede ser peor negocio. La meta es el **frente de Pareto latencia↔costo**, no el mínimo absoluto de latencia. Relación con budgets en [estrategia-performance.md](estrategia-performance.md).

### 4.1 Modelos de compra de cómputo (p. ej., neutral)

| Modelo | Cuándo conviene | Riesgo |
|---|---|---|
| **On-demand / bajo demanda** | Carga impredecible, corta, experimental | Precio unitario más alto |
| **Reservado / committed (1-3 años)** | Base estable y predecible | Compromiso rígido; desperdicio si baja la demanda |
| **Spot / interrumpible** | Tolerante a fallos, batch, stateless, reintentar barato | Puede evaporarse; requiere diseño resiliente |

Patrón recomendado: **base en reservado + pico en on-demand + trabajo diferible en spot**. No es un proveedor: es una **forma de razonar** aplicable on-prem (amortización de hardware) igual que en nube.

### 4.2 Costos ocultos

- **Egress y transferencia de datos:** el tráfico de salida y **entre zonas/regiones** suele ser el costo invisible que domina la factura; minimizar cruces, acercar cómputo al dato (ver [datos-performance.md](datos-performance.md)).
- **Almacenamiento por tiers:** clasificar **caliente/tibio/frío/archivo** según patrón de acceso; datos fríos en tier caliente es puro desperdicio. Tiering es una palanca **T1**.
- **Sobre-aprovisionamiento como deuda:** capacidad ociosa que nadie decidió apagar.
- **Idle y zombies:** entornos no-prod encendidos 24/7, recursos huérfanos.

## 5. Eficiencia de recursos

Eficiencia = **más trabajo útil por unidad de recurso**. Aplica el lente **USE** (Utilization / Saturation / Errors) a cada recurso.

| Recurso | Señal de ineficiencia | Palanca típica |
|---|---|---|
| **CPU** | Alta utilización con bajo throughput; busy-wait | Perfilado, algoritmo, concurrencia (→ [backend-performance.md](backend-performance.md)); tuning de bajo nivel/afinidad (→ [sistemas-hardware.md](sistemas-hardware.md)) |
| **Memoria** | Presión/GC agresivo; over-request | Right-sizing, pooling, evitar copias |
| **I/O / disco** | Saturación de cola de disco | Batching, formato/compresión, tiering (→ [datos-performance.md](datos-performance.md)) |
| **Red** | Egress alto, chatter entre servicios | Colocación, compresión, menos round-trips |
| **Densidad** | Pocos workloads por nodo sin razón | Bin-packing, límites realistas |

**Noisy neighbors:** en cómputo compartido, un vecino ruidoso roba CPU/I-O/red y arruina el p99 ajeno de forma **invisible en promedios**. Mitigación: aislamiento de recursos (límites/quotas), colocación consciente, o dedicar capacidad a lo crítico. **Densidad vs. aislamiento** es un trade-off explícito: más densidad baja costo pero sube el riesgo de interferencia; se calibra con SLO, no con corazonada.

## 6. Performance Efficiency ↔ Cost Optimization (Well-Architected)

Los dos pilares son **caras de la misma moneda**:

- **Performance Efficiency:** usar los recursos de forma que se cumpla el objetivo con lo mínimo — seleccionar el tipo de recurso adecuado, revisar continuamente (lo óptimo de ayer no lo es hoy), experimentar y medir.
- **Cost Optimization:** eliminar gasto que no entrega valor — apagar lo ocioso, comprar en el modelo correcto, atribuir costo a quien lo consume.

Convergen en una regla: **la forma más barata de servir el SLO suele ser también la más eficiente**. Cuando divergen (más caché baja latencia pero sube costo), se decide por **frente de Pareto** y por el valor de negocio del percentil ganado, no por el mínimo aislado de una sola variable.

## 7. Sostenibilidad / Green Software (SCI)

**Eficiencia = menos energía = menos carbono.** Performance y sostenibilidad **convergen**: el mismo trabajo hecho con menos ciclos, menos I/O y menos datos movidos consume menos energía. Optimizar por eficiencia es, casi siempre, optimizar por huella.

Marco **Green Software Foundation — SCI (Software Carbon Intensity)**:

```
SCI = ((E × I) + M) / R
```
- **E:** energía consumida por el software.
- **I:** intensidad de carbono de esa energía (gCO₂/kWh; depende de la red eléctrica y la hora).
- **M:** carbono embebido del hardware (fabricación), amortizado.
- **R:** unidad funcional (p. ej. por request, por usuario, por tarea) — mismo espíritu que $/request.

Palancas:

- **Carbon-aware scheduling:** diferir trabajo elástico/batch a horas o regiones con red más limpia (menor I), cuando el SLO lo permite.
- **Eficiencia de código y datos:** menos cómputo, menos egress, menos almacenamiento caliente ocioso — todo baja E.
- **Amortizar M:** mayor densidad y utilización útil aprovechan mejor el hardware ya fabricado; apagar zombies evita carbono sin valor.

Por qué convergen con el negocio: **la misma acción baja latencia potencial, costo y carbono a la vez**. Green no es un impuesto: es eficiencia con otra unidad de medida.

## 8. Trade-offs de topología: on-prem vs. cloud vs. edge

Decisión por contexto y evidencia — **ninguna gana por defecto**:

| Dimensión | On-prem (p. ej.) | Cloud (p. ej.) | Edge (p. ej.) |
|---|---|---|---|
| **Elasticidad** | Baja (capex, lead time) | Alta (bajo demanda) | Media, distribuida |
| **Costo unitario** | Bajo a alta utilización estable | Bajo a baja/variable utilización | Alto por sitio; ahorra egress/latencia |
| **Latencia al usuario** | Depende de ubicación | Regiones/AZ | Mínima (cerca del usuario) |
| **Control/soberanía** | Máximo | Compartido | Distribuido |
| **Encaje ideal** | Carga base estable, alto volumen | Demanda variable, time-to-market | Latencia ultrabaja, datos locales, offline |

Lo común es **híbrido**: base predecible donde el $/unidad es menor, elasticidad donde la demanda varía, edge donde la latencia o el egress lo justifican. La arquitectura profunda de estas decisiones es **T2 vía [eneida](interoperabilidad-y-aliadas.md)** (ver §9).

## 9. Modelo TIERED de intervención

| Tier | Alcance | Quién |
|---|---|---|
| **T1 — Directo** | **Cross-cutting de eficiencia:** right-sizing, políticas de autoscaling (mín/máx, umbrales, cooldown), tiering de almacenamiento, config de eficiencia de recursos, apagado de idle, budgets de costo/energía | peakformance implementa |
| **T2 — Vía dueño** | **Cambios de arquitectura/infra profundos:** rediseño de topología, límites de servicio, plataforma, migración on-prem/cloud/edge | vía **[eneida](interoperabilidad-y-aliadas.md)** / plataforma, con fix medido antes/después |
| **T3 — Fallback** | Si no existe el dueño de plataforma, peakformance aplica y **documenta la deuda de ownership** | directo, declarado |

## 10. Colaboración (handoff con evidencia)

| Situación | Handoff a | Archivo |
|---|---|---|
| Peso de payload/bundle que infla transferencia | farola / uxuifull | [frontend-performance.md](frontend-performance.md) |
| Costo de cómputo en lógica de servicio | motor | [backend-performance.md](backend-performance.md) |
| Tiering, egress, almacenamiento de datos | andulfo | [datos-performance.md](datos-performance.md) |
| Rediseño de topología / límites | eneida | [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md) |
| Costo/energía de inferencia (GPU, batching) | sysuniversal-ai | [ia-ml-performance.md](ia-ml-performance.md) |
| Validación de capacidad bajo carga | amado | [pruebas-de-carga.md](pruebas-de-carga.md) |
| Impacto de controles de seguridad en recursos | destroyer | [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md) |

Gates de costo/energía en CI e instrumentación en [performance-cicd.md](performance-cicd.md) y [medicion-observabilidad.md](medicion-observabilidad.md). Plantillas de capacity/FinOps en [plantillas.md](plantillas.md); casos aplicados en [ejemplos.md](ejemplos.md).

## 11. Anti-patrones

- **Dimensionar por request solicitado**, no por uso real medido → sobre-aprovisionamiento crónico.
- **Utilización objetivo = 100%:** el p99 ya rompió mucho antes del codo.
- **Autoscaling sin techo** (sin máximo): la factura y el blast radius sin límite.
- **Todo on-demand:** pagar precio premium por carga base predecible.
- **Ignorar egress y transferencia entre zonas:** el costo invisible que domina.
- **Datos fríos en tier caliente:** desperdicio puro.
- **Zombies y no-prod 24/7:** carbono y dinero sin valor.
- **Optimizar latencia disparando $/request o energía** sin acordarlo.
- **Tratar green como impuesto** en vez de como eficiencia medible (SCI).
- **Densidad máxima sin guardas de saturación:** noisy neighbors arruinan el p99.

## 12. Checklist de capacidad y costo

- [ ] Punto de saturación identificado por prueba escalonada; utilización objetivo fijada **por debajo del codo**.
- [ ] Headroom y margen para picos definidos por criticidad y velocidad de escalado.
- [ ] Forecast de demanda a 6-18 meses con eventos conocidos.
- [ ] Right-sizing: request/limit ajustados al p95/pico real; gap request-vs-uso revisado.
- [ ] Autoscaling con mín/máx, umbral y cooldown; sin flapping; cold start medido en latencia y costo.
- [ ] Base reservada + pico on-demand + diferible en spot, según patrón.
- [ ] Unit economics medidos: $/request, $/tarea, costo por usuario activo; frente de Pareto latencia↔costo.
- [ ] Egress y transferencia entre zonas cuantificados y minimizados.
- [ ] Tiering caliente/tibio/frío/archivo según patrón de acceso.
- [ ] Idle y zombies apagados; recursos huérfanos eliminados.
- [ ] Noisy neighbors acotados (aislamiento/quotas) donde el SLO lo exige.
- [ ] Huella medida con SCI (E, I, M por unidad funcional R); carbon-aware scheduling donde el SLO lo permita.
- [ ] Trade-off on-prem/cloud/edge decidido por evidencia, no por defecto; híbrido justificado.
- [ ] Budgets de costo y energía versionados y con gate en CI ([performance-cicd.md](performance-cicd.md)).
- [ ] Antes/después documentado en toda intervención de capacidad o costo.
