# Confiabilidad (SRE): SLI/SLO, error budgets y resiliencia

Este es el núcleo de la práctica de baluarte. Aquí se define **cómo se hace la confiabilidad como problema de ingeniería**, no como operación manual heroica. baluarte trata la fiabilidad como una *feature* medible, presupuestable y negociable: se define con números (SLI/SLO), se financia con un presupuesto de riesgo (error budget) y se protege con patrones de plataforma (resiliencia). Todo lo demás —observabilidad, incidentes, release, capacidad, DR— es instrumentación o consecuencia de lo que aquí se establece.

## 1. Qué es SRE y su relación con DevOps

SRE (Site/Service Reliability Engineering) es la disciplina que aplica principios de ingeniería de software al problema de operar sistemas fiables a escala. Su tesis central: **la fiabilidad es la característica más importante de cualquier sistema** —un sistema que no está disponible no entrega ningún otro valor— y por tanto debe diseñarse, medirse y presupuestarse, no perseguirse a mano.

Diferencia con la operación clásica:

| Operación tradicional | Enfoque SRE (baluarte) |
|---|---|
| Fiabilidad = esfuerzo humano y guardias | Fiabilidad = objetivo cuantificado (SLO) |
| "Cero caídas" como aspiración vaga | Error budget explícito y negociado |
| Trabajo manual repetitivo (toil) crece con la escala | Toil acotado; se automatiza o elimina |
| Estabilidad vs velocidad en conflicto perpetuo | Velocidad **hasta** agotar el budget, luego se frena |

Relación con DevOps: SRE es una implementación concreta y opinada de la filosofía DevOps ("una forma de hacer DevOps"). DevOps dice *rompe los silos entre desarrollo y operación*; SRE responde *con estos números, este budget y estas prácticas*. La cultura, los ritos y el modelo operativo se detallan en [metodologia-y-cultura.md](metodologia-y-cultura.md). baluarte no reemplaza a los equipos de producto: les entrega el marco de fiabilidad y co-implementa con ellos.

## 2. SLI — Service Level Indicator

Un **SLI es una medida cuantitativa de un aspecto del nivel de servicio**, expresada casi siempre como una proporción:

```
SLI = eventos_buenos / eventos_válidos  × 100
```

Este modelo *good events / valid events* es el corazón. Un "evento válido" es una unidad de trabajo que cuenta para el SLI (p. ej. una petición HTTP que llega al servicio, no las de health-check); un "evento bueno" es uno que cumple el criterio de calidad (p. ej. respondió sin error 5xx). El resultado vive naturalmente entre 0% y 100%, lo que lo hace comparable y presupuestable.

**Un buen SLI refleja la experiencia del usuario, no la comodidad de la máquina.** El CPU al 80% no le importa al usuario; que su petición falle sí. Criterios de un buen SLI: (a) sube cuando el usuario está feliz y baja cuando sufre; (b) es medible con la instrumentación disponible; (c) es simple de entender.

**Ejemplos de SLI por tipo de sistema** (baluarte es dueño de disponibilidad/errores/correctitud operacional; la **latencia** aparece porque baluarte la **mide/instrumenta** como SLI, pero el **objetivo (SLO) de latencia y su optimización los fija y posee `peakformance`** — ver §12):

| Tipo de sistema | SLI de disponibilidad/correctitud (baluarte) | SLI de latencia (baluarte instrumenta; su SLO lo fija peakformance) |
|---|---|---|
| Request/response (API, web) | % de peticiones sin error del servidor (no-5xx / válidas) | % de peticiones más rápidas que un umbral (p. ej. < 300 ms) |
| Pipeline de datos / batch | % de registros procesados sin error; % de jobs que completan | % de datos frescos dentro de la ventana (data freshness) |
| Storage / colas | % de operaciones de lectura/escritura exitosas; durabilidad* | % de operaciones bajo umbral de latencia |
| Streaming / eventos | % de mensajes entregados sin pérdida ni duplicado indebido | lag de consumo bajo umbral |

\* La **durabilidad** y la física de la réplica de datos son de `andulfo`, no de baluarte; baluarte consume esas garantías como dependencia.

**Ventanas y agregación.** Un SLI se mide sobre una *ventana* (rolling window de 28–30 días es común para SLOs; ventanas cortas de minutos para alertas). Agregar **por percentiles**, no por promedio: la media esconde a los usuarios peor servidos. Un p50 excelente con un p99 catastrófico significa que 1 de cada 100 peticiones es terrible —y ese usuario existe. Preferir p90/p95/p99 y "% bajo umbral" a promedios. La instrumentación que produce estos números (métricas, logs, trazas) se cubre en [observabilidad-operacional.md](observabilidad-operacional.md).

## 3. SLO — Service Level Objective

Un **SLO es un objetivo sobre un SLI durante una ventana**: "el 99.9% de las peticiones válidas serán no-error en 28 días". Es la línea que separa "suficientemente fiable" de "no suficientemente fiable".

**Por qué 100% es la meta equivocada.** Perseguir el 100% es un error de ingeniería, no una virtud:
- El costo de cada nueve adicional crece de forma más que lineal (a menudo ~10×).
- El usuario no distingue 100% de 99.99%: su propia cadena (ISP, wifi, dispositivo, DNS) ya introduce más indisponibilidad que ese margen. Invertir en fiabilidad que el usuario no percibe es desperdicio.
- El 100% prohíbe cambiar el sistema —y todo cambio (deploy, migración, experimento) consume riesgo. **Un objetivo de 100% congela la innovación.**

Por tanto el SLO correcto es "**tan alto como sea necesario, y ni un nueve más**". Se fija por *journey de usuario* (el checkout de compra puede exigir 99.95%; un panel interno, 99%), no un número único para todo. **Qué journey es crítico y con qué nivel objetivo** se **co-acuerda con `eneida` y el PO** (como la política de error budget y el RTO/RPO): baluarte propone, mide e instrumenta el SLO; la criticidad de negocio no la decide por su cuenta.

**Coste de los nueves** (disponibilidad → downtime permitido):

| SLO | Downtime/año | Downtime/mes (30 d) | Downtime/semana |
|---|---|---|---|
| 99% ("dos nueves") | 3 d 15 h | 7 h 18 m | 1 h 41 m |
| 99.9% ("tres nueves") | 8 h 46 m | 43 m 50 s | 10 m 5 s |
| 99.95% | 4 h 23 m | 21 m 55 s | 5 m 2 s |
| 99.99% ("cuatro nueves") | 52 m 36 s | 4 m 23 s | 1 m 0 s |
| 99.999% ("cinco nueves") | 5 m 15 s | 26 s | 6 s |

**SLOs realistas basados en historia.** No inventar el número: medir el SLI actual durante semanas y fijar el SLO cerca del desempeño real observado (ligeramente por debajo del p50 histórico), no en la aspiración. Un SLO que ya se incumple el día uno no sirve como control. En **greenfield** se empieza con un SLO provisional conservador y se recalibra tras 4–8 semanas de datos; en **brownfield** se mide primero y se formaliza lo que el sistema ya entrega; en **híbrido** cada dominio puede tener SLOs distintos según su madurez.

## 4. SLA vs SLO

| | SLO | SLA |
|---|---|---|
| Naturaleza | Objetivo **interno** de ingeniería | Contrato **externo** con el cliente |
| Consecuencia de incumplir | Se activa la política de error budget (frenar, priorizar) | Consecuencias legales/económicas (créditos, penalizaciones) |
| Quién lo usa | Equipos de ingeniería y SRE | Comercial, legal, clientes |

**Regla de oro: el SLO debe ser más estricto que el SLA.** Si el SLA promete 99.9% al cliente, el SLO interno debería ser 99.95% (o mejor). Ese margen es el colchón que permite detectar y corregir la degradación *antes* de romper el compromiso contractual. Si SLO = SLA, se incumple el contrato en el mismo instante en que se detecta el problema. Muchos sistemas ni siquiera tienen SLA (no todo servicio interno lo necesita), pero todo servicio con usuarios debería tener SLO.

## 5. Error budget — el presupuesto de riesgo

El **error budget es el complemento del SLO**:

```
error_budget = 100% − SLO
```

Con SLO = 99.9% en una ventana de 28 días, el budget es 0.1% del tiempo/eventos = **~40 minutos de indisponibilidad** (o 0.1% de las peticiones válidas); en una ventana de 30 días equivale a los ~43 min de la tabla de §3. Representa **cuánto fallo el negocio ha aceptado tolerar**: es un presupuesto de riesgo para gastar en cambio, experimentos, deploys arriesgados y hasta caídas.

**Consumo.** Cada incidente, deploy fallido, degradación o experimento consume budget en proporción a su impacto y duración. El budget se rastrea como un saldo que se agota y se **repone** al avanzar la ventana rodante.

**Uso como control de decisión (la clave).** El error budget convierte la eterna tensión "velocidad vs estabilidad" en una regla objetiva:
- **Budget disponible** → el equipo tiene permiso para lanzar, experimentar y tomar riesgo. La fiabilidad ya es suficiente; frenar sería desperdiciar la capacidad de innovar.
- **Budget agotado** → **se congela el release de features** y todo el esfuerzo se redirige a fiabilidad (hardening, corrección de causas raíz, reducción de toil) hasta recuperar saldo.

Esta regla debe ser una **política de error budget escrita y acordada** entre ingeniería, producto y negocio *antes* de necesitarla —no una negociación en caliente durante una crisis. Debe especificar: el SLO, quién puede aprobar excepciones, qué significa exactamente "congelar", y qué pasa con incumplimientos repetidos. Esta política es un artefacto de gobernanza; su encaje organizativo se detalla en [gobernanza-y-etica.md](gobernanza-y-etica.md).

El **gate de error budget en el pipeline** (bloquear despliegues de feature cuando el budget está agotado) se implementa en [cicd-y-release-engineering.md](cicd-y-release-engineering.md). Es donde la política deja de ser papel y se vuelve control automático.

## 6. Burn rate y alerting multi-ventana

El **burn rate** mide *a qué velocidad se consume el error budget* relativo a "gastarlo justo en la ventana". Burn rate = 1 significa que, a ese ritmo, se agota exactamente el budget al final de los 28 días. Burn rate = 14.4 significa consumir en 1 hora lo que correspondería a ~14 horas: una hemorragia.

**Por qué alertar sobre burn rate y no sobre "el SLO se rompió":** alertar cuando el SLO ya está incumplido llega tarde. Alertar por cada error individual genera ruido. La solución es **alerting multi-ventana y multi-burn-rate**:

| Severidad | Burn rate | Ventana(s) | % budget consumido antes de disparar | Acción |
|---|---|---|---|---|
| Crítica (página) | ~14.4 | 1 h **y** 5 m | ~2% | Respuesta inmediata |
| Alta | ~6 | 6 h **y** 30 m | ~5% | Investigar pronto |
| Media (ticket) | ~1 | 24 h **y** 2 h | ~10% | Revisar en horario laboral |

La **doble ventana** (larga *y* corta simultáneas) es esencial: la ventana larga confirma que el problema es real y sostenido; la ventana corta corta la alerta rápido cuando el problema se resuelve (evita alertas "colgadas" horas después de recuperado). Esto ataca los dos fallos del alerting: el **ruido** (fatiga, alertas ignoradas) y la **ceguera** (detectar demasiado tarde). La mecánica de la implementación de estas alertas vive en [observabilidad-operacional.md](observabilidad-operacional.md); la respuesta cuando disparan, en [incidentes-y-respuesta.md](incidentes-y-respuesta.md).

## 7. Toil — el enemigo medible

**Toil** no es "trabajo que no me gusta". Tiene definición precisa: es trabajo que es **manual, repetitivo, automatizable, táctico/reactivo (sin valor duradero), y que escala linealmente con el tamaño del servicio**. Reiniciar un proceso a mano, aprobar el mismo tipo de cambio una y otra vez, o mover datos manualmente son toil. Diseñar un sistema que se auto-repara no lo es (es ingeniería).

No todo trabajo operativo es toil: responder un incidente genuinamente novedoso, o tomar una decisión de diseño, es *overhead* o ingeniería, no toil.

**Medirlo.** Encuestar y registrar el tiempo del equipo por categoría. **Presupuesto de toil: un tope de ~50%** del tiempo de cada ingeniero de fiabilidad. Por encima de ese umbral, el equipo se convierte en un equipo de operaciones puro, deja de mejorar el sistema y el toil crece con la escala hasta colapsar. El otro ~50% debe ir a proyectos de ingeniería que **reduzcan el toil futuro**.

**Eliminar > automatizar.** El orden de preferencia es: (1) eliminar la necesidad de la tarea rediseñando el sistema; (2) si no, automatizarla; (3) solo si nada de lo anterior es viable, ejecutarla con un runbook claro. Automatizar un proceso roto solo lo hace fallar más rápido.

**La trampa del toil invisible.** El toil normalizado como "así se hace aquí" o celebrado como **heroísmo** ("¡el equipo trabajó todo el fin de semana!") no se mide y por tanto no se combate. baluarte lo hace visible: el heroísmo repetido es un síntoma de un sistema mal diseñado, no una virtud a premiar.

## 8. Patrones de resiliencia (plataforma)

La **resiliencia** es la capacidad de un sistema de seguir dando servicio (aunque sea degradado) ante fallos parciales. baluarte es dueño de estos patrones **a nivel de plataforma** (malla de servicios, gateways, sidecars, infra); su **implementación dentro del código** de un servicio se co-implementa con `motor` (ver §12).

> Frontera con `certero`: la **correctitud** de la lógica (un bug que da un resultado equivocado) es de `certero`. La **resiliencia** (que el sistema tolere que una dependencia falle) es patrón de plataforma de baluarte. Un retry no arregla un bug lógico; solo lo repite.

| Patrón | Qué resuelve | Cuándo usarlo | Riesgo / cómo se rompe |
|---|---|---|---|
| **Timeout** | Un cliente colgado esperando una dependencia lenta | Toda llamada remota, siempre | **Timeout infinito = recurso agotado**. Debe ser finito y menor al del llamante |
| **Retry con backoff exp. + jitter** | Fallos transitorios (blip de red, pico momentáneo) | Errores idempotentes y transitorios | **Retries sin límite/jitter → retry storm**: todos reintentan a la vez y tumban la dependencia que se recuperaba |
| **Circuit breaker** | Golpear una dependencia ya caída empeora todo | Dependencia con fallos sostenidos | Umbrales mal calibrados: abre de más (falsos negativos) o de menos (no protege) |
| **Bulkhead / aislamiento** | Un fallo satura recursos compartidos y hunde todo | Pools de conexiones/hilos por dependencia | Sobre-particionar desperdicia capacidad |
| **Load shedding** | Sobrecarga total: mejor rechazar algo que caer todo | Cuando la demanda supera la capacidad | Descartar tráfico valioso si no hay priorización |
| **Rate limiting** | Un cliente abusivo o un pico consume toda la capacidad | Fronteras de API, multi-tenant | Límite mal fijado bloquea uso legítimo |
| **Graceful degradation** | Servir parcial es mejor que no servir | Cuando una función no crítica falla | Requiere diseñar el modo degradado por adelantado |
| **Fallback** | Dar una respuesta alternativa (cache, valor por defecto) | Cuando existe una respuesta "suficiente" | Fallback obsoleto que engaña al usuario |
| **Colas + backpressure** | Absorber picos y desacoplar productor/consumidor | Cargas asíncronas, spikes | Cola sin límite → memoria agotada y latencia oculta creciente |
| **Idempotencia** | Hacer seguro reintentar sin duplicar efectos | Toda operación que pueda reintentarse | Sin clave de idempotencia, el retry duplica cobros/registros |

**El peligro de los retries** merece énfasis: reintentar sin límite y sin jitter (sin aleatorizar el tiempo de espera) sincroniza a todos los clientes y produce **retry storms** —oleadas coordinadas que impiden que la dependencia caída se recupere. Regla de baluarte: *todo retry lleva backoff exponencial, jitter, un tope de intentos, y respeta el circuit breaker.* Además del límite **por-petición**, conviene un **retry budget global**: un tope sobre el *ratio* de reintentos frente a peticiones totales a nivel de cliente/servicio (p. ej. no más del 10 % de reintentos) que **corta los reintentos agregados** cuando una dependencia está masivamente degradada —la última barrera contra el retry storm que el límite por-petición, por sí solo, no ve—. La **idempotencia** es el prerrequisito que hace seguro cualquier retry: sin ella, reintentar corrompe estado.

## 9. Degradación elegante y modos degradados

Principio: **servir una respuesta parcial o degradada casi siempre es mejor que caer por completo.** Un feed que muestra contenido cacheado en vez de personalizado, un buscador que devuelve resultados sin el ranking premium, un checkout que difiere el envío de la factura por correo: el usuario completa su objetivo esencial aunque pierda accesorios.

Herramienta clave: **feature flags** para apagar dinámicamente funcionalidad no crítica bajo estrés. Cuando el sistema está al límite, baluarte (o un control automático) apaga las funciones caras y prescindibles —recomendaciones, analítica en vivo, animaciones— para preservar el *core journey*. Esto exige haber clasificado antes qué es crítico y qué no (ver §10) y haber diseñado el modo degradado deliberadamente, no improvisarlo.

## 10. Dependencias y fallos en cascada

**La fiabilidad de un sistema está acotada por la de sus dependencias.** Si un servicio con SLO 99.99% depende síncronamente de otro con 99.9%, no puede superar 99.9% —hereda el techo del más débil (y peor si depende de varios: las probabilidades se multiplican).

Prácticas:
- **Criticality tiers:** clasificar cada dependencia como crítica (el journey falla sin ella) o no crítica (degradable). Solo las críticas justifican inversión máxima en fiabilidad. La criticidad de negocio del journey se **co-acuerda con `eneida`/PO**; baluarte la traduce a decisiones operativas (aislamiento, headroom, SLO).
- **Aislar lo crítico de lo no crítico:** que un fallo en analítica jamás pueda tumbar el pago. Bulkheads, pools separados, límites de recursos.
- **Evitar el acoplamiento síncrono frágil:** una cadena larga de llamadas síncronas convierte cualquier fallo local en un **fallo en cascada**. Desacoplar con colas/eventos, aplicar timeouts y circuit breakers en cada salto, y usar backpressure impide que un fallo se propague aguas arriba.

## 11. Capacidad como pilar de confiabilidad

Un sistema sin **headroom** (margen de capacidad) no es fiable: el primer pico lo tumba. La capacidad es un pilar de fiabilidad, no un tema aparte. Dos márgenes obligatorios:
1. **Headroom para picos** de demanda esperados (campañas, horas punta, efecto rebaño).
2. **Headroom para pérdida de una zona/región** (regla N+1 o N+2): el sistema debe absorber la carga con una zona menos sin degradar el SLO.

El dimensionamiento fino, el autoscaling y el trade-off costo/fiabilidad se desarrollan en [capacidad-y-costos.md](capacidad-y-costos.md); la tolerancia a pérdida de zona/región completa y los objetivos RPO/RTO, en [continuidad-y-dr.md](continuidad-y-dr.md).

## 12. Fronteras de ownership (explícitas)

baluarte no trabaja solo. Sus fronteras son deliberadas:

- **baluarte ↔ `peakformance` (la frontera clave).** baluarte hace que el sistema **ESTÉ DISPONIBLE**; peakformance hace que sea **RÁPIDO**. Los SLOs de **disponibilidad, tasa de error y correctitud operacional** son de baluarte. Los SLOs/budgets de **latencia y rendimiento**, y su *optimización de raíz*, son de peakformance. Ambos existen y se miden. **Cuando un SLO de disponibilidad sufre por lentitud** (p. ej. la lentitud agota hilos y provoca timeouts/errores), baluarte actúa **ahora** para proteger la disponibilidad —escala, aísla, aplica load shedding o abre el circuit breaker— y **entrega la optimización de la causa raíz a peakformance**. baluarte estabiliza; peakformance acelera.
- **baluarte ↔ `certero`.** La **correctitud del código** (bugs de lógica, invariantes rotas) es de certero. La **resiliencia** (tolerar fallos de dependencias) es patrón de plataforma de baluarte. Un patrón de resiliencia nunca sustituye la corrección de un bug.
- **baluarte ↔ `andulfo`.** La **física de datos** —durabilidad, replicación de datos, integridad del almacenamiento, RPO a nivel de datos— es de andulfo. baluarte consume esas garantías como dependencia y las incorpora a los SLOs de servicio.
- **baluarte ↔ `motor`.** Los patrones de resiliencia **en la plataforma** (malla, gateway, sidecar, infra) son de baluarte; su **implementación dentro del código** de un servicio se **co-implementa con motor** (ver modelo tiered abajo).

## 13. Cultura y production readiness

La confiabilidad es una **feature de primera clase**, decidida y presupuestada al inicio, no un *afterthought* que se parchea tras la primera caída. El mecanismo cultural concreto es la **Production Readiness Review (PRR)**: una revisión —con checklist— que un servicio debe pasar *antes* de recibir tráfico real de usuarios, cubriendo SLOs definidos, alertas configuradas, runbooks escritos, capacidad dimensionada, patrones de resiliencia aplicados y plan de rollback. El **checklist de PRR** se detalla en [checklists.md](checklists.md) (§2) y su plantilla en [plantillas.md](plantillas.md) (§5); la cultura y el modelo operativo, en [metodologia-y-cultura.md](metodologia-y-cultura.md).

## 14. Antipatrones

- **SLO de 100%:** meta imposible que prohíbe todo cambio y consume presupuesto infinito sin beneficio percibido.
- **SLIs que no reflejan al usuario:** medir CPU/memoria en vez de éxito de peticiones; alertas verdes mientras los usuarios sufren.
- **Error budget que nadie respeta:** definir la política y luego seguir lanzando con el budget agotado. Un budget sin consecuencias es teatro.
- **Retries sin jitter ni límite:** garantía matemática de retry storms; convierten un blip transitorio en una caída total.
- **Timeouts infinitos (o ausentes):** un solo dependiente lento agota los recursos de todos sus llamantes en cascada.
- **"Confiabilidad = más servidores":** añadir capacidad no arregla un diseño frágil, una dependencia acoplada ni un bug; solo retrasa y encarece el colapso.
- **Toil normalizado como heroísmo:** premiar el trabajo manual repetido oculta el problema de diseño que lo causa y garantiza que reaparezca.

## 15. Cómo actúa baluarte aquí (modelo tiered)

- **T1 (baluarte, dueño directo):** definir los **SLIs y SLOs** por journey, redactar la **política de error budget**, diseñar el esquema de **burn-rate alerting** multi-ventana, establecer el **presupuesto de toil**, y definir los **patrones de resiliencia de plataforma** (malla, gateways, límites, breakers, bulkheads) y los checklists de PRR. Es el marco de fiabilidad del ecosistema.
- **T2 (co-implementación con `motor`):** llevar esos patrones al **código de un servicio concreto** —instrumentar los SLIs, cablear timeouts/retries idempotentes/circuit breakers en el cliente, implementar el modo degradado y sus feature flags. baluarte especifica y revisa; motor construye; se hace en conjunto.
- **T3 (potestad, `motor` saturado o ausente):** baluarte cablea directo los patrones de resiliencia **a nivel de plataforma** (malla, gateway, límites, breakers de infra) —que ya son suyos— para sostener el SLO; si el fix mínimo que falta toca el código del servicio y el dueño está saturado o no existe, lo aplica **reversible y marcado "pendiente de revisión del dueño"**, sin rediseñar la lógica del servicio.

Handoffs asociados: latencia/rendimiento → [capacidad-y-costos.md](capacidad-y-costos.md) y peakformance; instrumentación → [observabilidad-operacional.md](observabilidad-operacional.md); gate de release → [cicd-y-release-engineering.md](cicd-y-release-engineering.md); respuesta a incidentes → [incidentes-y-respuesta.md](incidentes-y-respuesta.md); DR y pérdida de región → [continuidad-y-dr.md](continuidad-y-dr.md); SLOs de aliados y dependencias externas → [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).
