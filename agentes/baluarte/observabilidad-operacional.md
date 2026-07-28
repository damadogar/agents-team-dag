# Observabilidad operacional

La observabilidad operacional es la capacidad de un sistema de exponer su estado interno a través de la telemetría que emite, de forma que un operador pueda **saber si los usuarios sufren, por qué, y qué hacer**, sin necesidad de redesplegar código para poder preguntar algo nuevo. baluarte es dueño de esta disciplina en su vertiente operacional: el stack de observabilidad de plataforma, el alerting basado en SLO, los dashboards de salud y la higiene del on-call. No busca perfilar para optimizar (eso es de peakformance) ni juzgar la corrección semántica de la instrumentación (eso es de certero): baluarte garantiza que la observabilidad **exista, esté cableada a la plataforma y sea accionable**.

Este documento es agnóstico de vendor. Los nombres propios aparecen solo como ejemplos ilustrativos ("p. ej.") junto a alternativas; el criterio se basa en conceptos y estándares abiertos por encima de cualquier producto.

## 1. Monitoring vs Observability

No son sinónimos, y confundirlos produce sistemas ciegos.

- **Monitoring** responde a *known-unknowns*: preguntas que ya sabías que ibas a hacer. Defines de antemano una métrica ("uso de CPU", "tasa de error 5xx") y la vigilas. Es indispensable y barato, pero solo ve lo que anticipaste.
- **Observability** responde a *unknown-unknowns*: preguntas que no sabías que ibas a necesitar. Ante un fallo novedoso, permite **cortar, agrupar y correlacionar** la telemetría por dimensiones arbitrarias (usuario, versión, región, endpoint, feature flag) para formular hipótesis nuevas **sin redeploy**.

En sistemas distribuidos la observabilidad deja de ser un lujo: los modos de fallo son emergentes (una interacción entre servicios sanos por separado), la causa rara vez coincide con el síntoma y el espacio de estados es demasiado grande para predecirlo con dashboards fijos. La prueba de fuego: *¿puedes responder una pregunta que nunca antes hiciste sobre producción, ahora mismo, sin tocar el código?* Si no, tienes monitoring, no observabilidad.

## 2. Los tres pilares y su unificación

| Señal | Qué es | Fortaleza | Límite | Coste |
|---|---|---|---|---|
| **Métricas** | Valores numéricos agregados en el tiempo (contadores, gauges, histogramas) | Baratas, retención larga, ideales para alertas y tendencias | Cardinalidad acotada; no explican un caso individual | Bajo por serie, explota con dimensiones |
| **Logs** | Eventos discretos con contexto | Detalle por evento, forense | Volumen y coste; texto plano no consultable | Alto |
| **Trazas** | Causalidad de una petición a través de servicios (spans + contexto propagado) | Muestran la latencia y el camino end-to-end | Requieren propagación e instrumentación | Medio-alto |

**Reglas de oro:**

- **Métricas**: agregadas y baratas, pero **sin cardinalidad infinita**. No pongas `user_id`, `request_id` ni `trace_id` como label de una métrica; multiplica series hasta reventar el backend (ver §8).
- **Logs**: **estructurados > texto plano**, siempre. Un log debe ser un evento con campos (`level`, `service`, `trace_id`, `tenant`, `latency_ms`), no una cadena a la que luego haya que aplicar regex frágiles. El log estructurado es consultable, agregable y correlacionable.
- **Trazas**: capturan la **causalidad distribuida**. Cada span mide una operación; el contexto (trace-id, span-id) se propaga entre procesos por cabeceras. Sin propagación no hay traza, solo spans huérfanos.

**Unificación**: el valor real aparece cuando los tres pilares se correlacionan. Patrones clave:

- **`trace_id` en cada log**: desde una métrica de error saltas a las trazas afectadas y de ahí a los logs exactos de esas peticiones.
- **Exemplars**: un punto de un histograma de latencia lleva adjunto el `trace_id` de una petición representativa. Ves el pico *y* saltas al ejemplo concreto que lo causó.
- **Señales adicionales**: **eventos** (deploys, cambios de config, feature flags) como marcadores temporales, y **perfiles** (profiling continuo) como cuarta señal para el "¿en qué línea se va el tiempo?" — aunque perfilar para optimizar es dominio de peakformance; baluarte lo usa como señal de correlación, no como fin.

## 3. Estándares abiertos: separar instrumentación de backend

El mayor error estratégico en observabilidad es **acoplar el código a un vendor**. La instrumentación (cómo el código emite señales) debe estar desacoplada del backend (dónde se almacenan y consultan).

- Adopta una **capa de instrumentación neutral**, p. ej. **OpenTelemetry** (OTel) como estándar abierto para métricas, logs y trazas, con su protocolo de exportación (OTLP). Alternativas y complementos existen, pero el principio es el mismo: **una API/SDK estándar, un colector intermedio, y backends intercambiables**.
- El **colector** (agente/gateway) recibe, procesa (filtra, reetiqueta, muestrea) y exporta la telemetría. Es el punto de control donde baluarte aplica políticas de coste, muestreo y enrutamiento **sin tocar los servicios**.
- Resultado: cambiar de backend de métricas o de trazas (p. ej. de un SaaS a una solución autogestionada, o viceversa) es un cambio de configuración del colector, **no una reinstrumentación de 300 servicios**. Esto es el antídoto contra el lock-in y una decisión de plataforma T1.

## 4. Metodologías de señales: RED, USE y los 4 Golden Signals

No instrumentes al azar; usa un marco según lo que observas.

| Marco | Aplica a | Señales | Cuándo usarlo |
|---|---|---|---|
| **RED** | Servicios request-driven (APIs, microservicios) | **R**ate (peticiones/s), **E**rrors (tasa de error), **D**uration (distribución de latencia) | Salud de un servicio desde la perspectiva de quien lo llama |
| **USE** | Recursos (CPU, memoria, disco, colas, pools) | **U**tilization (% ocupado), **S**aturation (trabajo en espera), **E**rrors | Diagnóstico de cuellos de botella de infraestructura |
| **4 Golden Signals** | Cualquier servicio orientado a usuario | Latencia, Tráfico, Errores, Saturación | Marco general de salud de cara al usuario |

Regla práctica: **RED para servicios, USE para recursos**, y los Golden Signals como el conjunto mínimo que todo servicio de cara al usuario debe exponer. La latencia se mide siempre por **percentiles** (p50/p90/p99), nunca por media — la media oculta la cola donde vive el sufrimiento real. Y separa la latencia de las peticiones exitosas de la de las fallidas: un 500 rápido no es "buena latencia".

## 5. Alerting basado en SLO

Esta es la columna vertebral operacional y enlaza directamente con [confiabilidad-sre.md](confiabilidad-sre.md), donde se definen SLI, SLO y error budget. Aquí baluarte los convierte en alertas.

**Principio central: alerta por SÍNTOMA, no por CAUSA.** Una CPU al 95% no es un problema si el usuario no lo nota; una tasa de error del 5% sí lo es aunque la CPU esté tranquila. Alertar por causas produce ruido crónico y páginas que no significan nada. Alertar por síntomas (¿se está agotando el error budget? ¿sufre el usuario?) produce páginas que **siempre importan**.

**Burn-rate multi-ventana**: en vez de "alerta si el error supera X%", alerta según la **velocidad a la que se consume el error budget**. Combina una ventana larga (detecta agotamiento sostenido) con una corta (confirma que el problema sigue *ahora*), en dos niveles:

- **Burn-rate alto** (p. ej. consumir en horas un budget mensual) → **página urgente**, ventanas cortas para reaccionar rápido.
- **Burn-rate lento** (fuga gradual) → **ticket**, no página; se atiende en horario laboral.

**El objetivo no negociable: toda página es accionable y urgente.** Si al recibirla el operador no puede o no debe hacer nada ya, no debió ser una página. Todo lo demás es un ticket, un dashboard o un log. Reducir falsos positivos no es cosmética: es la diferencia entre un on-call sano y uno quemado.

**Alertas preventivas sobre fallos programados y evitables.** No todo se detecta por síntoma: hay outages **con fecha conocida** que se previenen vigilando el tiempo restante. El caso arquetípico es la **expiración de certificados TLS/mTLS y de secretos/tokens** —una de las causas más recurrentes de caídas mayores en la industria, y **totalmente evitable**—. baluarte instrumenta el **tiempo hasta el vencimiento** como una señal de primer nivel y alerta **con margen** (p. ej. avisar semanas antes, no cuando ya expiró), idealmente con **rotación automatizada** que elimine el evento manual (enlaza toil en [confiabilidad-sre.md](confiabilidad-sre.md); la política de rotación la fija `destroyer` y baluarte la **opera** —ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md) §3). La misma lógica aplica a dominios, cuotas que se agotan (enlaza [capacidad-y-costos.md](capacidad-y-costos.md) §9) y licencias.

## 6. Salud del on-call

Enlaza con [incidentes-y-respuesta.md](incidentes-y-respuesta.md). El on-call es un recurso humano finito y baluarte lo protege con métricas y disciplina.

- **Fatiga de alertas**: cuando llegan demasiadas páginas, el operador deja de confiar en ellas y empieza a ignorar incluso las reales. El ruido *degrada la seguridad del sistema*.
- **Páginas por turno como métrica**: mídelo. Un turno saludable tiene un número bajo y accionable de páginas (la referencia canónica del equipo, alineada con [incidentes-y-respuesta.md](incidentes-y-respuesta.md) §1: del orden de **~2 incidentes accionables por turno de 12 h** —regla Google SRE—; cero páginas de madrugada evitables). Si sube, es un defecto de plataforma a corregir, no un heroísmo a tolerar.
- **Alertas que se auto-resuelven = eliminar**: si una alerta se dispara y se apaga sola antes de que nadie actúe, no era accionable. Bórrala o reconvíertela en un umbral con sentido.
- **Revisión periódica de alertas**: cada alerta debe tener dueño, runbook y una revisión regular (p. ej. en la retro de on-call). Alertas sin runbook o sin acción clara se depuran. La regla: *cada página que despierta a alguien debe justificar por qué valía la pena despertarlo*.

## 7. Dashboards operativos

- **Por servicio y por journey de usuario**: un dashboard por servicio (RED + recursos) y otro por recorrido crítico de negocio (el estado de un flujo end-to-end de cara al usuario).
- **Jerarquía visión → drill-down**: arriba, un puñado de señales de salud de un vistazo; debajo, capas para profundizar. El operador entra por la vista global y baja al detalle solo cuando algo está rojo.
- **Dashboards para incidentes vs para capacidad**: son audiencias y horizontes distintos. El de incidentes prioriza *ahora* (¿qué se rompió, dónde, desde cuándo?); el de capacidad prioriza *tendencias* (semanas/meses, ver [capacidad-y-costos.md](capacidad-y-costos.md)). No los mezcles.
- **Evita los "muros de gráficos"**: 60 paneles que nadie mira son ruido, no observabilidad. Cada panel debe responder una pregunta operativa concreta. Si nadie sabría qué hacer al verlo rojo, sobra.

## 8. Cardinalidad y coste de la telemetría

La observabilidad es una **partida de coste real**, a menudo comparable al gasto de cómputo del propio sistema. baluarte la gobierna. Enlaza con [capacidad-y-costos.md](capacidad-y-costos.md).

- **Explosión de cardinalidad**: cada combinación única de labels de una métrica es una serie temporal que se almacena e indexa. Añadir un label de alta cardinalidad (`user_id`, `url` con IDs, `request_id`) multiplica las series por millones y puede tumbar el backend o disparar la factura. La cardinalidad va en logs y trazas, **no en métricas**.
- **Muestreo de trazas**: no siempre se guardan el 100% de las trazas.
  - **Head sampling**: decides muestrear al inicio de la petición (p. ej. 10%). Simple y barato, pero puedes tirar justo las trazas de los errores raros.
  - **Tail sampling**: decides al final, cuando ya sabes si la traza fue lenta o falló, y **conservas las interesantes** (errores, colas altas) descartando las aburridas. Más caro de operar pero mucho más útil; se implementa en el colector.
- **Retención por tier**: no todo se guarda igual de tiempo. Métricas agregadas, retención larga y barata; logs de debug, retención corta; trazas muestreadas, media. Define tiers explícitos.
- **El coste de observar**: mídelo y presupuéstalo. La observabilidad sin presupuesto termina recortada de golpe en una crisis de facturación, dejando el sistema ciego justo cuando más se necesita ver.

## 9. Instrumentación en el paved road

La observabilidad no puede depender de que cada equipo se acuerde de instrumentar. Se hornea en el **paved road** de la plataforma (ver plataforma-e-idp).

- **SDK y auto-instrumentación en las plantillas de servicio**: cada servicio nuevo nace ya emitiendo RED, trazas y logs estructurados, con el SDK estándar preconfigurado y apuntando al colector.
- **Logs estructurados por defecto**: la plantilla configura el logger para emitir JSON con campos estándar (`trace_id`, `service`, `version`, `tenant`) desde el minuto cero.
- **Propagación de contexto por defecto**: los clientes HTTP/mensajería de la plantilla propagan el contexto de traza automáticamente, para que las trazas crucen fronteras de servicio sin trabajo manual.
- En **greenfield** esto se diseña desde el inicio; en **brownfield** se introduce por auto-instrumentación (sin tocar código) y se migra progresivamente; en **híbrido**, el colector normaliza señales de mundos con y sin OTel hacia un formato común.

## 10. SLO tooling: medir SLIs desde la telemetría

- Los **SLI se computan desde las señales ya existentes**: la tasa de peticiones buenas/totales sale de las métricas RED; la latencia por debajo de un umbral, de los histogramas; la disponibilidad de un journey, de trazas o probes sintéticos.
- **Error budget dashboards**: un panel de primera clase que muestra el budget consumido y el restante por SLO, y la proyección de agotamiento. Es la fuente de verdad tanto para las alertas de burn-rate (§5) como para las decisiones de release (ver [confiabilidad-sre.md](confiabilidad-sre.md)).
- El tooling debe permitir definir el SLO **como código/config** versionado, no como clics en una UI que nadie audita.

## 11. Observabilidad del propio pipeline y plataforma

La plataforma también es un sistema que hay que observar. Enlaza con [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

- **Deploys marcados en dashboards**: cada despliegue emite un evento que se dibuja como línea vertical en los dashboards. Correlacionar visualmente **deploy ↔ regresión** convierte "algo empeoró a las 15:04" en "el deploy de las 15:03 lo causó" en segundos.
- **Correlación deploy↔métrica** para gates automáticos: si una métrica de salud se degrada tras un release, la observabilidad alimenta el rollback o el freeze automático.
- **Observar la plataforma misma**: el colector, las colas de telemetría, los pipelines de CI/CD y los propios sistemas de observabilidad tienen sus SLIs. *Quis custodiet* — el sistema que te avisa de fallos no puede caer en silencio; necesita su propio monitoreo (idealmente por un camino independiente).

## 12. Antipatrones

| Antipatrón | Por qué duele | Qué hacer |
|---|---|---|
| Alertar por causa (CPU, memoria) | Ruido crónico, páginas sin significado | Alertar por síntoma/SLO (§5) |
| Logs no estructurados | Ilegibles por máquina, regex frágiles | Logs estructurados por defecto (§2, §9) |
| Cardinalidad descontrolada | Tumba el backend, dispara la factura | IDs en logs/trazas, no en métricas (§8) |
| Dashboards que nadie mira | Falsa sensación de cobertura | Cada panel responde una pregunta (§7) |
| "Logueamos todo por si acaso" | Coste enorme, señal ahogada en ruido | Muestreo, retención por tier, presupuesto (§8) |
| Páginas no accionables | Quema el on-call, erosiona la confianza | Solo página lo urgente y accionable (§5, §6) |
| Observabilidad como afterthought | Se instrumenta en pánico, sin presupuesto | Paved road + partida de coste desde el diseño (§8, §9) |
| Acoplar el código al vendor | Lock-in, reinstrumentar para migrar | Instrumentación neutral + colector (§3) |

## 13. Fronteras (quién es dueño de qué)

- **baluarte** es dueño de la observabilidad **operacional**: alerting por SLO, dashboards de salud, on-call, y el cableado de plataforma del stack de observabilidad.
- **peakformance** usa telemetría para **perfilar y optimizar rendimiento**. Frontera nítida: *baluarte alerta cuando el usuario sufre (SLO); peakformance perfila para optimizar*. Misma telemetría, distinto propósito. Un flame graph para bajar la latencia es de peakformance; la página que dice "la latencia p99 rompió el SLO" es de baluarte.
- **certero** juzga la **correctitud** del logging y de la instrumentación como código (que el log diga la verdad, que el span mida lo que dice medir). baluarte es dueño de que la observabilidad **exista y esté bien cableada**; certero revisa que su implementación sea correcta.
- **andulfo** y el cluster de datos son dueños de la observabilidad de **datos y pipelines de datos** (calidad de datos, frescura, drift). baluarte no invade esa capa.

## 14. Cómo baluarte actúa tiered aquí

- **Tier 1 (baluarte lo posee y ejecuta directo)**: el stack de observabilidad de plataforma (colector, backends, estándar de instrumentación), el **alerting basado en SLO**, los **dashboards operativos** de salud, las políticas de muestreo, retención y coste, y la higiene del on-call. Son decisiones y activos transversales de plataforma.
- **Tier 2 (co-implementado con el dueño del servicio)**: la **instrumentación fina del código** de un servicio concreto — qué spans internos crear, qué campos de negocio añadir a los logs, qué métricas de dominio exponer — se define junto al equipo dueño de ese servicio. baluarte aporta el paved road, el estándar y la revisión; el equipo aporta el conocimiento del dominio. La corrección semántica de esa instrumentación se coordina con certero.
- **Tier 3 (potestad, dueño saturado o ausente)**: si un servicio crítico corre **a ciegas** (sin señales para verificar su SLO) y su dueño está saturado o no existe, baluarte añade la **observabilidad operativa mínima** por auto-instrumentación (sin tocar el código de dominio), marcada **"pendiente de revisión del dueño"**, para no operar sin visibilidad.

Interoperabilidad con aliados externos y estándares compartidos de telemetría entre organizaciones se tratan en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) cuando aplica.
