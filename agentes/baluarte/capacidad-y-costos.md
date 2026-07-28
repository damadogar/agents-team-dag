# Capacidad y costos (capacity planning, autoscaling, FinOps)

baluarte provisiona y opera la capacidad que sostiene el SLO, y gobierna el costo de esa capacidad como una propiedad operativa de primer nivel. Su trabajo aquí es doble: que nunca falte capacidad cuando la demanda llega (planificación, headroom, autoscaling) y que esa capacidad se compre y se opere sin desperdicio (FinOps operativo). Ambos lados son la misma balanza: capacidad de más cuesta dinero, capacidad de menos cuesta confiabilidad. baluarte no elige entre las dos: dimensiona para el SLO al menor costo que lo respete.

Neutralidad: este documento habla de conceptos, no de productos. Donde se cita "p. ej." se ofrecen equivalentes entre nubes mayores, plataformas de orquestación y on-prem sin favorecer ninguno.

## 1. Frontera con `peakformance` (léela primero)

Es la frontera más confundida de todo el dominio. Se enuncia en una línea:

> **baluarte provisiona para sostener el SLO; `peakformance` optimiza para necesitar menos.**

| Eje | baluarte (aprovisionamiento / operación) | `peakformance` (eficiencia / techo) |
|---|---|---|
| Pregunta | ¿Cuánta infra pongo AHORA para sostener el SLO? | ¿Por qué el código necesita tanta infra? |
| Palanca | Réplicas, nodos, límites, tipos de instancia, compra | Algoritmo, consultas, cache, concurrencia, hot path |
| Métrica dueña | Utilización, headroom, coste unitario, waste % | Latencia por operación, throughput máximo, coste POR eficiencia |
| Horizonte | Reactivo/predictivo, minutos–semanas | Estructural, por release |
| FinOps | FinOps **operativo** (comprar bien, apagar lo ocioso) | FinOps **de eficiencia** (que la unidad cueste menos de raíz) |

**Cómo colaboran cuando el costo se dispara.** Si un servicio consume el doble de infra por una regresión de rendimiento o un algoritmo O(n²), baluarte **escala AHORA** para no romper el SLO (respuesta operativa inmediata) y **entrega el hallazgo a `peakformance`** para la optimización de fondo (respuesta estructural). baluarte no reescribe el código: paga la capacidad que hoy hace falta y abre el ticket de eficiencia. Cuando `peakformance` entrega la mejora, baluarte reduce la capacidad provisionada y captura el ahorro. La secuencia es SIEMPRE: sostener primero, optimizar después.

Otras fronteras: **dimensionar el motor de datos** (sizing de BD, pool de conexiones, réplicas de lectura del engine) es de `andulfo`; baluarte provee la infra donde ese motor corre. La **decisión de arquitectura que cambia el modelo de costo** (serverless vs contenedores, monolito vs microservicios, qué región) es de `eneida`; baluarte aporta las cifras operativas que la informan y luego la opera.

## 2. Capacity planning: demanda contra capacidad

Planificar capacidad es responder, con margen y con antelación: *¿la infra aguanta la demanda que viene, incluso cuando algo se caiga?*

- **Demanda**: proyección de carga (RPS, usuarios concurrentes, jobs, GB) por horizonte. Se descompone en **crecimiento orgánico** (tendencia suave, modelable por regresión/serie temporal sobre histórico) y **eventos** (lanzamientos, campañas, cierres de mes, estacionalidad, efecto de marketing) que no se ven en la tendencia y se planifican por calendario y coordinación con negocio.
- **Capacidad**: lo que la infra actual puede servir dentro del SLO — no su máximo teórico, sino el punto antes de que la latencia se degrade (ver §3).
- **Headroom (margen)**: capacidad reservada por encima del pico esperado. No es desperdicio: es el colchón que absorbe picos no previstos, el tiempo de reacción del autoscaling y —crítico— **la pérdida de una zona o región**.
- **Planificar para el pico Y para la pérdida de dominio de fallo**: la capacidad no se dimensiona al pico con todo sano, sino al pico **con N+1 o N+2**: si el sistema vive en 3 zonas y una cae, las 2 restantes deben absorber el 100% del pico. Diseñar al 33% por zona "porque hay 3 zonas" garantiza caída en cuanto una falle. Enlaza con [confiabilidad-sre.md](confiabilidad-sre.md) y [continuidad-y-dr.md](continuidad-y-dr.md).
- **Lead time de aprovisionamiento**: el tiempo entre "necesito más" y "está disponible". En nube elástica puede ser segundos; para instancias grandes, cuotas nuevas, hardware on-prem o interconexión dedicada, días o semanas. El plan debe adelantarse a ese lead time — enlaza [cloud-redes-y-edge.md](cloud-redes-y-edge.md).

## 3. Teoría útil: por qué ~100% de utilización mata la confiabilidad

Dos conceptos que se confunden y no son lo mismo:

- **Utilización**: qué fracción del tiempo un recurso está ocupado (p. ej. CPU al 70%).
- **Saturación**: cuánto trabajo está **esperando en cola** porque el recurso no da abasto. La saturación —no la utilización— es la que se siente como lentitud y errores.

La relación entre utilización y latencia **no es lineal**: es una curva de cola (teoría de colas). Mientras la utilización es baja-media, la latencia sube poco; al acercarse al 100%, el tiempo de espera tiende a infinito. Una aproximación M/M/1: el tiempo en el sistema escala con **1 / (1 − ρ)**, donde ρ es la utilización.

| Utilización ρ | Factor de latencia ≈ 1/(1−ρ) | Lectura |
|---|---|---|
| 50% | 2× | cómodo |
| 70% | 3.3× | sano para muchos servicios |
| 80% | 5× | empieza a doler |
| 90% | 10× | zona de riesgo |
| 95% | 20× | frágil ante cualquier pico |
| 99% | 100× | colapso latente |

Por eso apuntar a "~100% de utilización para no desperdiciar" es un error de novato: se optimiza el coste de la factura y se destruye el SLO. El objetivo de utilización se fija DEBAJO del codo de la curva (típicamente 60–80% según la varianza de la carga y la tolerancia de latencia), reservando el resto como headroom. Ese headroom es lo que llamamos **N+1 / N+2 redundancy**: capacidad extra suficiente para perder 1 (N+1) o 2 (N+2) unidades de servicio y seguir dentro del SLO.

## 4. Autoscaling: escalar con la demanda

Autoscaling ajusta capacidad automáticamente. Dimensiones:

- **Horizontal (scale out/in)**: añadir/quitar réplicas por una métrica. Señales sanas: **RED** (Rate, Errors, Duration), uso de CPU/memoria, o **longitud de cola / trabajos pendientes** (la mejor señal para cargas asíncronas — enlaza [observabilidad-operacional.md](observabilidad-operacional.md)). Es la forma preferida para servicios sin estado.
- **Vertical (scale up/down, rightsizing)**: cambiar los recursos (CPU/RAM) de cada instancia/pod. Útil cuando escalar en horizontal no ayuda (procesos que no paralelizan) o para afinar requests/limits (§5). Suele requerir reinicio.
- **De cluster / de nodos**: cuando los pods no caben, el autoscaler de cluster añade nodos; cuando sobran, los retira. El autoscaling de aplicación (réplicas) y el de infraestructura (nodos) deben coordinarse: réplicas que no tienen dónde aterrizar no sirven.
- **Reactivo vs predictivo**: el reactivo responde a la métrica actual (simple, pero siempre va por detrás del pico y sufre el lead time de arranque). El **predictivo** adelanta capacidad según patrón histórico o calendario (p. ej. pre-escalar antes del pico diario conocido o de un evento). Lo ideal combina ambos: predictivo para lo conocido, reactivo como red de seguridad.
- **Escalado a cero (serverless)**: escalar hasta 0 réplicas cuando no hay tráfico — coste casi nulo en reposo. El precio es el **cold start**: la primera petición tras el reposo paga el arranque (latencia). Trade-off: excelente para cargas intermitentes o de fondo; peligroso para latencia sensible sin un mínimo caliente (min replicas > 0 o pre-warming).

**Peligros del autoscaling (baluarte los diseña fuera):**

| Peligro | Qué es | Mitigación |
|---|---|---|
| Flapping | Escala arriba/abajo sin cesar por métrica ruidosa | Ventanas de estabilización, histéresis, cooldowns |
| Thundering herd | Mil réplicas nuevas golpean a la vez una dependencia | Arranque escalonado, warm-up, backoff |
| Escalar sobre algo que no escala | Más réplicas, pero la BD/API/lock no escala → se traslada el cuello | Escalar el sistema completo, no una capa; ver §1 y `andulfo` |
| Límites y cuotas | El autoscaling choca un techo del proveedor a mitad de pico | Descubrir cuotas antes; enlaza [cloud-redes-y-edge.md](cloud-redes-y-edge.md) |
| Sin límite superior | Un bug o ataque dispara escalado infinito → factura o agotamiento | `maxReplicas` y presupuesto SIEMPRE definidos |

**Señales correctas para escalar**: la métrica debe ser causa, no síntoma tardío. Escalar por latencia p99 ya degradada es tarde; escalar por utilización o profundidad de cola se adelanta. La calidad de la señal es asunto de [observabilidad-operacional.md](observabilidad-operacional.md).

## 5. Requests/limits y rightsizing

En plataformas orquestadas cada carga declara **requests** (lo que se le reserva/garantiza) y **limits** (su techo). baluarte los afina — enlaza [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md):

- **Sobre-aprovisionar** (requests altos): la carga arranca segura pero se paga capacidad ociosa; el scheduler empaqueta menos por nodo. Es coste puro.
- **Sub-aprovisionar** (requests/limits bajos): más densidad, pero riesgo de **OOMKill** (memoria) y **CPU throttling** (cómputo) bajo presión — se cambia factura por incidentes.
- **Bin-packing vs resiliencia**: empaquetar apretado maximiza el uso del nodo (menos coste) pero concentra el radio de explosión y deja poco margen ante un pico o la caída de un nodo. baluarte busca el punto entre densidad y holgura, no el extremo.

Rightsizing es un ciclo continuo: medir el uso real (percentiles, no promedios), ajustar requests al uso p95–p99 + margen, y repetir. Recursos que nunca se revisan derivan siempre hacia el desperdicio.

## 6. FinOps operativo: el ciclo Inform → Optimize → Operate

FinOps es la disciplina de gestionar el costo de la nube como decisión de ingeniería, no como sorpresa de fin de mes. Tres fases en bucle:

1. **Inform (visibilidad)**: no se puede optimizar lo que no se ve. Requiere **allocation** del coste: **tagging/labeling** consistente por equipo/servicio/entorno, y **showback** (mostrar a cada equipo lo que gasta) o **chargeback** (cobrárselo). Sin tags disciplinados el gasto es un agregado opaco imposible de atribuir.
2. **Optimize**: aplicar las palancas (§7) donde el dato de la fase 1 muestra desperdicio o sobre-capacidad.
3. **Operate**: convertir lo anterior en práctica continua — presupuestos, alertas, revisión periódica, coste como criterio en cada cambio.

**Unit economics — el coste como SLI de negocio.** El número que importa no es la factura total (que sube con el negocio) sino el **coste unitario**: coste por petición, por tenant, por transacción, por usuario activo, por GB procesado. Si el negocio crece 2× y el coste unitario se mantiene o baja, la plataforma escala con salud; si el coste unitario sube, hay un problema estructural (a menudo de eficiencia → `peakformance`). baluarte trata el coste unitario como un **SLI**: se mide, se le pone objetivo y se alerta cuando se desvía.

**Presupuestos y alertas de coste**: cada cuenta/servicio nace con presupuesto y alertas (p. ej. al 50/80/100% del previsto, y sobre la tasa de gasto para detectar fugas rápido), no con la factura como único aviso — el mismo principio de "cablearlo desde el nacimiento de la cuenta" de la landing zone ([cloud-redes-y-edge.md](cloud-redes-y-edge.md)).

## 7. Palancas de optimización de coste

| Palanca | Qué hace | Riesgo / condición |
|---|---|---|
| Rightsizing | Ajustar recursos al uso real (§5) | Dejar margen; no apretar al p50 |
| Apagar lo ocioso | Parar dev/staging fuera de horario, matar recursos huérfanos | Automatizar; nada crítico apagado |
| Modelo de compra | On-demand vs comprometido vs spot/preemptible | Ver abajo |
| Storage tiering | Mover datos fríos a niveles baratos (frecuente→infrecuente→archivo) | Coste/latencia de recuperación del archivo |
| Reducir egress | Cachear, comprimir, colocar cerca lo que se habla | Enlaza [cloud-redes-y-edge.md](cloud-redes-y-edge.md) |
| Eliminar waste | Discos sin adjuntar, IPs reservadas sin uso, snapshots viejos, entornos zombie | Barrido continuo |

**Modelos de compra** (el trade-off central del coste de cómputo):

- **On-demand**: máxima flexibilidad, precio lista. Para carga impredecible o de corta vida.
- **Comprometido** (p. ej. *reserved / savings plans / committed use*): descuento fuerte a cambio de comprometer uso 1–3 años. Para la **base estable** de la carga (lo que siempre está encendido). baluarte cubre con compromiso el suelo de demanda y deja on-demand/autoscaling para el pico variable.
- **Spot / preemptible**: capacidad sobrante con gran descuento que **el proveedor puede retirar con poco aviso**. Solo para cargas **tolerantes a interrupción**: batch, procesamiento reintentar-able, CI, workers sin estado con drenaje elegante. **Nunca** para estado no replicado ni para la ruta crítica sin fallback. Poner spot bajo una carga no tolerante es un antipatrón que rompe el SLO por ahorrar.

**El trade-off coste↔confiabilidad es SIEMPRE explícito.** Cada palanca de ahorro se evalúa contra su efecto en el SLO. Regla dura de baluarte: **nunca se optimiza coste rompiendo el SLO.** Si un ahorro pone en riesgo el objetivo de disponibilidad/latencia, no es un ahorro: es deuda de confiabilidad con intereses (un incidente cuesta más que lo ahorrado). El ahorro legítimo elimina desperdicio; el ilegítimo consume headroom.

## 8. Sostenibilidad / green ops

La eficiencia de coste y la de carbono suelen **alinearse**: lo que reduce recursos ociosos reduce energía y emisiones. baluarte lo aprovecha:

- **Eficiencia energética y densidad**: consolidar cargas, apagar lo ocioso y empaquetar mejor reduce factura Y consumo — la misma palanca sirve a ambos.
- **Carbono**: preferir regiones con matriz energética más limpia, y donde aplique, desplazar cargas diferibles (batch) a ventanas/regiones de menor intensidad de carbono (*carbon-aware*).
- **Eficiencia del trabajo**: la mayor palanca verde es no ejecutar cómputo inútil — código eficiente hace menos trabajo por resultado; ahí la eficiencia estructural es de `peakformance` y baluarte captura el ahorro de infra que produce.

No siempre coinciden coste y carbono (una región limpia puede ser más cara); cuando divergen, baluarte lo hace explícito como un trade-off consciente, no oculto.

## 9. Gestión de cuotas y límites

Todo proveedor y plataforma impone techos: número de instancias, IPs, cuentas, API rate limits, límites de servicio. El autoscaling y el crecimiento chocan contra ellos si no se gestionan — enlaza [cloud-redes-y-edge.md](cloud-redes-y-edge.md):

- **Inventariar** las cuotas relevantes por región/cuenta como parte del capacity plan, no como sorpresa.
- **Alertar** al acercarse (p. ej. 80%), no al chocar.
- **Solicitar aumentos con lead time** (algunos tardan días) antes del pico previsto.
- Un límite descubierto durante un incidente es un fallo de planificación, no del proveedor.

## 10. Capacidad de aceleradores (GPU/TPU) para inferencia IA

Cuando la plataforma sirve inferencia de IA/ML, la capacidad de **aceleradores** (GPU/TPU/NPU) no se modela como CPU/memoria: tiene propiedades propias que baluarte debe planificar explícitamente. La **decisión y calidad del modelo** son de `sysuniversal-ai`; baluarte opera la **plataforma de serving** y su capacidad.

- **Escasez y coste extremo.** Los aceleradores son caros y a menudo de disponibilidad limitada por región/cuota. El **coste unitario relevante** es el **coste por inferencia** (o por 1K tokens), no por hora de instancia — se mide y se le pone objetivo como cualquier unit economic (§6).
- **Cold start por carga de pesos.** Arrancar una réplica implica cargar pesos de modelo (de MB a decenas de GB) en memoria del acelerador: el arranque es de **segundos a minutos**, no milisegundos. Esto rompe el autoscaling reactivo ingenuo — hay que **pre-provisionar headroom**, mantener réplicas calientes (warm pool) o escalar predictivamente contra la curva de demanda (§4), no reaccionar al pico.
- **Autoscaling difícil y granularidad.** El escalado fraccional es limitado: no siempre puedes "medio acelerador". Las señales de escalado útiles son **profundidad de cola de inferencia, utilización del acelerador y latencia de batch**, no la CPU. El **batching** (agrupar peticiones) sube el throughput por acelerador pero añade latencia — un trade-off que baluarte instrumenta (el objetivo de latencia lo fija `peakformance`/producto).
- **Compartición: time-slicing y particionado (p. ej. MIG).** Un acelerador puede compartirse entre cargas por tiempo (time-slicing) o partición física (multi-instancia), subiendo densidad en cargas pequeñas a costa de aislamiento — útil para dev/modelos chicos, riesgoso para cargas críticas con SLO estricto.
- **Cuotas y compra específicas.** Los aceleradores tienen cuotas propias (a menudo escasas) que se solicitan con **mucho lead time** (§9); los modelos de compra (comprometido vs on-demand vs spot) aplican, pero el spot es aún más arriesgado por el cold start (perder una réplica cuesta minutos de recarga). Planificar N+1 en aceleradores es caro: se decide contra el SLO de disponibilidad de la inferencia.

Frontera: baluarte provisiona/escala/optimiza el **coste operativo** del serving (headroom de aceleradores, warm pools, batching como palanca de capacidad, cuotas); `sysuniversal-ai` decide el **modelo, su cuantización/tamaño y la calidad**; `peakformance` optimiza la **eficiencia de la inferencia** (kernels, throughput por acelerador, técnicas de servido). baluarte escala AHORA para sostener el SLO y entrega la optimización de eficiencia a `peakformance`.

## 11. Métricas del dominio

| Métrica | Qué mide | Objetivo típico |
|---|---|---|
| Utilización | % de uso del recurso | Bajo el codo de la curva (§3), ~60–80% |
| Headroom | Margen sobre el pico, incl. N+1/N+2 | Suficiente para perder 1–2 dominios de fallo |
| Coste unitario | Coste por request/tenant/transacción | Estable o decreciente con el crecimiento |
| Waste % | Capacidad pagada y no usada | Minimizar sin comerse el headroom |
| Forecast accuracy | Acierto de la proyección vs real | Alto; error se realimenta al modelo |

Headroom y waste % son dos caras de la misma moneda: el arte está en el margen que da confiabilidad sin volverse desperdicio.

## 12. Antipatrones

- **Apuntar a ~100% de utilización**: mata la confiabilidad por la curva de colas (§3).
- **Autoscaling sin límite superior y sin probar**: escalado infinito ante un bug/ataque, o política nunca ensayada que no reacciona en el pico real.
- **Optimizar coste rompiendo el SLO**: consumir headroom o poner spot en la ruta crítica para bajar la factura.
- **No tener visibilidad de coste**: gastar sin tagging/allocation; imposible atribuir ni optimizar.
- **Spot en cargas no tolerantes**: capacidad retirable bajo estado o ruta crítica sin fallback.
- **Capacity planning "a ojo"**: sin forecast ni headroom calculado; la capacidad se descubre en el incidente.
- **Cuotas descubiertas en incidente**: chocar un techo del proveedor a mitad de pico.
- **Dimensionar al pico con todo sano**: ignorar la pérdida de zona/región (sin N+1/N+2).
- **Confundir factura total con salud**: celebrar/alarmarse por el total ignorando el coste unitario.

## 13. Cómo actúa baluarte aquí (tiered)

- **T1 — dueño y ejecutor directo**: capacity planning, headroom y N+1/N+2, autoscaling (horizontal/vertical/cluster, reactivo/predictivo, a cero), rightsizing de requests/limits, FinOps operativo (visibilidad, allocation, unit economics, presupuestos, palancas de compra y de apagado), gestión de cuotas y green ops de plataforma. Lo diseña, lo codifica en IaC y lo opera.
- **Filtro de disciplina hacia `peakformance`**: cuando el coste o la capacidad no se resuelven provisionando sino que vienen de **código/consultas/algoritmos ineficientes**, baluarte escala AHORA para sostener el SLO y **entrega la optimización a `peakformance`** — que es dueño de la eficiencia y del techo de rendimiento y del FinOps de eficiencia. baluarte no reescribe el código.
- **T3 — potestad (dueño saturado o ausente)**: si un ajuste de capacidad toca dominio ajeno (p. ej. dimensionar el motor de datos) y su dueño está saturado o no existe, baluarte aplica el cambio **operativo y reversible** que evita el incidente (ampliar volumen, subir headroom, aislar), marcado **"pendiente de revisión del dueño"**, sin decidir por él (no elige índices, esquema ni arquitectura).
- **Greenfield vs brownfield**: en **greenfield** se fija headroom, presupuestos y política de autoscaling desde el diseño, con un forecast conservador por falta de historia; en **brownfield** se **mide primero** el uso y el gasto reales (baseline), se caza el waste evidente y se calibra el autoscaling contra la demanda observada antes de comprometer compra a largo plazo.
- **Fronteras vivas**: sizing del motor de datos → `andulfo` (baluarte provee la infra); decisión de arquitectura que cambia el modelo de costo → `eneida` (baluarte aporta las cifras y la opera); eficiencia del código y techo de rendimiento → `peakformance`. Señales de escalado en [observabilidad-operacional.md](observabilidad-operacional.md); márgenes por pérdida de zona/región en [confiabilidad-sre.md](confiabilidad-sre.md) y [continuidad-y-dr.md](continuidad-y-dr.md); cuotas, egress y compra por región en [cloud-redes-y-edge.md](cloud-redes-y-edge.md); requests/limits en [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md); costos entre proveedores/aliados en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).
