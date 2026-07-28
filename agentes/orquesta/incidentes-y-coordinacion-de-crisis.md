# Incidentes y coordinación de crisis

Cuando un incidente **cruza varios dominios** y **afecta la entrega**, orquesta coordina el war room: comando de incidente, roles, comunicación, timeline y seguimiento de acciones. orquesta **coordina, no ejecuta el fix**: posee la AUTORIDAD DE FLUJO, no la del contenido técnico. Este satélite es neutral de metodología (ICS, Google SRE, PagerDuty/Atlassian major incident, postmortem sin culpa) y sirve para greenfield, in-flight y brownfield.

> Frontera maestra: **baluarte (DevOps/SRE) es el dueño de la respuesta OPERATIVA** a incidentes de confiabilidad/plataforma (detección, mitigación, rollback, on-call, postmortem técnico). orquesta entra cuando la crisis es **cross-dominio** y exige orquestación de entrega y comunicación, **siempre deferente a baluarte** en la operación técnica.

## Cuándo entra orquesta

| Situación | Comanda técnicamente | Rol de orquesta |
|---|---|---|
| Incidente **puramente de plataforma/confiabilidad** (caída, latencia, deploy roto) | **baluarte** (Incident Commander) | Apoya la coordinación de entrega y la comunicación; no invade la operación |
| Crisis **cross-dominio** (afecta datos + seguridad + producto + entrega a la vez) | **orquesta** puede ser IC de coordinación | Coordina el war room, rutea el fix, comunica a stakeholders |
| Incidente que **compromete el compromiso de entrega** (hito, release, SLA de programa) | Dueño técnico del dominio | Coordina impacto en cronograma, re-planificación y comunicación |
| Brecha de **seguridad** | **destroyer** (+ cluster) comanda la respuesta | Coordina la crisis de entrega/comunicación en paralelo, deferente a destroyer |

Si el incidente es de un solo dominio y su dueño ya lo comanda, orquesta **no monta un war room**: apoya la comunicación y sigue el impacto en flujo.

## Roles del war room (basado en ICS/SRE)

Separar **COORDINAR** de **RESOLVER** es la regla central: quien comanda no teclea el fix.

| Rol | Responsabilidad | Quién lo asume |
|---|---|---|
| **Incident Commander (IC)** | Coordina, decide el flujo de la respuesta, mantiene el foco; **no ejecuta el fix** | **orquesta** en crisis cross-dominio · **baluarte** en incidente de plataforma · **destroyer** en brecha |
| **Comms Lead** | Comunicación interna y a stakeholders; traduce estado técnico a negocio | orquesta o delegado de comunicación |
| **Scribe** | Registra el timeline en tiempo real (hechos, decisiones, horas) | Rol de apoyo dentro de la coordinación |
| **Operations / Resolvers** | **Ejecutan** la mitigación y el fix; son los dueños técnicos | baluarte, certero, destroyer, andulfo, motor… según dominio |

> Un solo IC a la vez. Si el IC también intenta resolver, pierde la coordinación: por eso orquesta **nunca toma un teclado de fix**; sostiene el mando de flujo.

## Severidad, clasificación y activación

Clasificar dispara el nivel de respuesta y de comunicación. La escala exacta la fija la organización (o baluarte para plataforma); orquesta la usa para dimensionar la coordinación y el reporte.

| Severidad | Señal típica | Respuesta de coordinación |
|---|---|---|
| **SEV-1 / crítico** | Caída total, brecha activa, pérdida de datos, impacto masivo | War room inmediato, IC designado, comunicación a stakeholders y gobierno |
| **SEV-2 / alto** | Degradación grave, funcionalidad clave caída | War room o puente; IC de dominio; comunicación acotada |
| **SEV-3 / medio** | Impacto parcial con workaround | Sin war room; dueño técnico + seguimiento en RAID |

Un incidente es un **issue materializado**: entra y se conserva en el RAID (ver gestion-de-riesgos-raid.md). El escalamiento sigue niveles (equipo → dueño de dominio → gobierno de programa).

## Timeline y comunicación durante la crisis

- **Timeline vivo:** el Scribe registra hechos, horas y decisiones. Distinguir **hechos** de **hipótesis**; el timeline alimenta el postmortem posterior.
- **Cadencia de actualización:** ritmo fijo de updates (p. ej. cada 15-30 min en SEV-1) aunque no haya novedad; el silencio erosiona la confianza.
- **Dos audiencias:** interna (resolvers, coordinación) y stakeholders/negocio (impacto, ETA, siguiente update). La forma y los canales viven en comunicacion-y-reporte.md; el impacto de programa en gestion-de-programa.md.
- **Una sola voz:** el Comms Lead consolida el mensaje; evita versiones contradictorias.

## Ruteo del fix al dueño técnico

orquesta **desatasca, no arregla**: identifica la naturaleza de la señal y despacha al dueño (ver orquestacion-y-ruteo.md).

| Señal del incidente | Dueño del fix (Resolver) |
|---|---|
| Bug de lógica / correctitud / regresión | `certero` |
| Infra, deploy roto, rollback, capacidad, SLO operativo | `baluarte` |
| Brecha, intrusión, exposición de secretos | `destroyer` (+ cluster) |
| Corrupción / pérdida / recuperación de datos | `andulfo` |
| Backend / API caída | `motor` |
| Frontend web / UI web rota | `farola` · mobile nativo → `palma` |
| Degradación de rendimiento | `peakformance` |
| Comportamiento de IA/LLM/agente | `sysuniversal-ai` |
| Fallo de calidad/regresión detectada | `amado` (verifica) → dueño del fix |
| **Decisión técnica de fondo** para resolver | `eneida` |
| **Re-priorización de valor** tras el incidente | `tompo` |

## Post-incidente

- **orquesta coordina el seguimiento de ACCIONES correctivas:** que cada acción tenga dueño, fecha y estado; las integra al RAID y a la re-planificación (planificacion-y-cronograma.md, gestion-de-cambios-y-alcance.md).
- **El POSTMORTEM técnico y la causa raíz los lidera el dueño del dominio:** baluarte (confiabilidad/plataforma), certero (bug/correctitud), destroyer (seguridad). orquesta **no escribe el postmortem técnico**: coordina que ocurra y da seguimiento a sus salidas.
- **Cultura BLAMELESS:** el objetivo es el sistema y el proceso, no la culpa individual. orquesta protege esa cultura en la facilitación; el aprendizaje entra a lecciones aprendidas (cadencia-y-ceremonias.md).
- **Re-priorización:** tompo decide qué valor se reordena tras el incidente; orquesta re-secuencia el plan en consecuencia.

## Frontera reiterada: no invadir la operación SRE de baluarte

| Terreno | Dueño | orquesta |
|---|---|---|
| Detección, mitigación técnica, rollback, on-call, runbooks | **baluarte** | No interviene en la ejecución técnica |
| Postmortem técnico y causa raíz de plataforma | **baluarte** | Coordina que se haga; sigue las acciones |
| Coordinación cross-dominio, comunicación a stakeholders, timeline, seguimiento de acciones, impacto en entrega | **orquesta** | Su dominio de flujo (META) |

orquesta **complementa** la operación de baluarte en la coordinación de entrega; nunca la sustituye. En incidente puro de plataforma, baluarte comanda y orquesta apoya.

## Tiered META de flujo

| Nivel | Qué hace orquesta |
|---|---|
| **T1** | Coordina el war room de flujo, roles, comunicación, timeline y seguimiento |
| **T2** | Co-facilita el mando con el dueño técnico (baluarte/destroyer) sin tomar la operación |
| **T3** | Si el dueño de coordinación está ausente/saturado, asume la coordinación **provisional**, marcada "pendiente de ratificación"; nunca decide el contenido técnico |

## Cómo cambia por contexto

| Contexto | Situación de incidentes | Énfasis de orquesta |
|---|---|---|
| **Greenfield** | No existe proceso de incidentes ni severidades ni on-call | Establecer el protocolo **con baluarte** (roles, severidad, canales, plantilla de postmortem) antes de que llegue la primera crisis |
| **In-flight** | Proceso parcial; incidentes emergen durante la ejecución | Activar rápido, mantener cadencia de updates, integrar acciones al RAID y re-planificar |
| **Brownfield** | Incidentes en sistemas legados: conocimiento tribal, sin runbooks, dependencias no documentadas | Coordinar el descubrimiento (arqueología con eneida/certero/baluarte), registrar deuda como riesgo, exigir postmortem que documente lo aprendido |

## Checklist rápido

```
[ ] ¿La crisis cruza dominios o afecta la entrega? (si es de un solo dominio, su dueño comanda)
[ ] ¿Es incidente de plataforma? → baluarte comanda técnicamente; orquesta apoya coordinación
[ ] ¿Hay un único Incident Commander designado?
[ ] ¿Separé COORDINAR de RESOLVER (el IC no ejecuta el fix)?
[ ] ¿Asigné Comms Lead y Scribe, y hay timeline vivo?
[ ] ¿Clasifiqué la severidad y registré el incidente como issue en el RAID?
[ ] ¿El fix está ruteado a su dueño técnico (certero/baluarte/destroyer/andulfo/…)?
[ ] ¿Hay cadencia de updates a stakeholders y una sola voz? (comunicacion-y-reporte.md)
[ ] ¿Las acciones correctivas tienen dueño, fecha y estado, y entraron al RAID?
[ ] ¿El postmortem técnico lo lidera el dueño del dominio, con cultura blameless?
[ ] ¿Coordiné la re-priorización (tompo) y la re-planificación del cronograma?
[ ] ¿No invadí la operación SRE de baluarte?
[ ] ¿Ajusté el enfoque según greenfield / in-flight / brownfield?
```

## Referencias

- Google — *Site Reliability Engineering*, cap. "Managing Incidents" y *The SRE Workbook*, "Incident Response" (roles IC/Comms/Ops, separación coordinar–resolver).
- FEMA / U.S. — *Incident Command System (ICS)* (estructura de mando de incidentes, roles, unidad de mando).
- Atlassian — *Incident Management Handbook* y PagerDuty — *Incident Response Documentation* (severidades, major incident, comunicación).
- Google — *Postmortem Culture: Learning from Failure* (postmortem sin culpa / blameless).
