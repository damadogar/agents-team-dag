# Cadencia y ceremonias

La cadencia es el **latido de la entrega**: el conjunto de sync points (síncronos y asíncronos) que dan ritmo, previsibilidad y aprendizaje al flujo de trabajo. orquesta **posee el ritmo y facilita las ceremonias**; NO decide su contenido. El backlog y lo "listo" (valor/DoR) son de **tompo**; la estrategia de prueba y gran parte del DoD son de **amado**; las decisiones técnicas son de **eneida**; el pipeline y su confiabilidad son de **baluarte**. orquesta es dueño del **acuerdo de trabajo y del proceso**, no del qué.

Este documento es neutral de marco: la cadencia correcta depende del contexto (naturaleza del trabajo, tamaño del equipo, madurez, distribución geográfica, incertidumbre). Un buen ritmo minimiza reuniones y maximiza foco, decisión y flujo.

## Principios de cadencia

| Principio | Qué significa | Señal de que se rompe |
|---|---|---|
| Latido regular | Eventos en horarios predecibles; el equipo confía en el ritmo | Reuniones improvisadas, ad-hoc constantes |
| Timeboxing | Cada evento tiene una caja de tiempo acordada y se respeta | Reuniones que se desbordan sin cierre |
| Sync solo cuando aporta | Sincrónico para decidir, alinear, resolver ambigüedad o construir confianza | Reunión que pudo ser un mensaje |
| Async por defecto para informar | Estado, lectura, actualizaciones documentadas fuera de reunión | Standup convertido en reporte de estado |
| Propósito explícito | Cada ceremonia tiene una meta y un output claro | Nadie sabe por qué existe la reunión |
| Foco protegido | orquesta encausa la conversación y saca los "rabbit holes" a un parking lot | Deriva a debate técnico de 3 personas |

**Balance sync vs async.** orquesta calibra: decisiones y desbloqueos con ambigüedad alta → síncrono; información, avances y lectura previa → asíncrono. En equipos distribuidos/husos horarios, prioriza async y reserva el sync escaso para lo que de verdad requiere copresencia.

## Facilitación por marco (orquesta neutral)

orquesta facilita cualquier marco sin imponer ninguno. Para **cada** evento aplica el mismo patrón de servicio: **prepara** (agenda, insumos, lectura previa, asistentes correctos), **timeboxea**, **mantiene el foco**, **captura acciones/decisiones/impedimentos**, y **da seguimiento**. NUNCA decide el contenido.

### Scrum (Scrum Guide 2020)

| Evento | Propósito | orquesta facilita | El contenido lo posee |
|---|---|---|---|
| Sprint Planning | Definir meta e ítems del sprint | Timebox, agenda, foco en el objetivo | tompo (qué/valor), equipo (cómo), amado (calidad) |
| Daily Scrum | Inspeccionar avance hacia la meta, replanear el día | 15 min, foco en flujo/impedimentos, no reporte al jefe | El equipo (es del equipo, no de orquesta) |
| Sprint Review | Inspeccionar el incremento y adaptar backlog | Convocar stakeholders, encausar feedback | tompo (backlog, decisión de valor) |
| Retrospective | Mejorar proceso, personas, herramientas | Espacio seguro, estructura, acciones concretas | El equipo (orquesta es dueño del proceso resultante) |
| Backlog Refinement | Aclarar, dividir, estimar ítems | Facilita ritmo y timebox del refinamiento | tompo (contenido, DoR, prioridad) |

### Kanban (cadencias de Anderson)

| Cadencia | Propósito | orquesta facilita |
|---|---|---|
| Replenishment / reposición | Seleccionar próximos ítems a comprometer | Timebox y disciplina de pull; tompo aporta prioridad/valor |
| Delivery planning | Planear entregas/releases próximas | Alinea fechas y dependencias (enlaza a planificacion-y-cronograma.md) |
| Standup (Kanban) | Fluir el tablero, atacar bloqueos | Walk the board de derecha a izquierda, foco en ítems atascados |
| Risk review | Revisar riesgos/impedimentos del flujo | Estructura la revisión (enlaza a gestion-de-riesgos-raid.md) |
| Service delivery review | Revisar métricas de servicio vs expectativas | Datos de flujo (enlaza a flujo-y-metricas-de-entrega.md) |
| Operations review | Coordinar entre servicios/equipos | Nivel programa (enlaza a gestion-de-programa.md) |

### SAFe / escala

| Evento | Propósito | orquesta facilita |
|---|---|---|
| PI Planning | Alinear el ART en objetivos del incremento | Coordina logística, timeboxes, confidence vote (enlaza a gestion-de-programa.md) |
| System Demo | Mostrar el incremento integrado | Convoca y encausa; el valor lo evalúa tompo/negocio |
| Scrum of Scrums | Sincronizar equipos, cruzar dependencias | Modera, captura cross-team blockers (enlaza a gestion-de-dependencias.md) |
| ART sync / PO sync | Coordinación de entrega y alcance | Ritmo y seguimiento de acciones |

## Working agreements, DoR y DoD

orquesta **facilita que el equipo acuerde** sus reglas; no las dicta ni impone su contenido de calidad o valor.

| Artefacto | Qué es | orquesta | Contenido lo aporta |
|---|---|---|---|
| Working agreement | Reglas de convivencia y proceso del equipo | Dueño del acuerdo y de que se respete/actualice | Todo el equipo (co-creado) |
| Definition of Ready | Cuándo un ítem está listo para trabajarse | Facilita el acuerdo y su uso en refinamiento | tompo (valor/"listo") |
| Definition of Done | Cuándo un ítem está terminado | Facilita el acuerdo y su respeto en cada cierre | amado (calidad), con aportes de baluarte/certero/destroyer |

orquesta vela por que estos acuerdos **existan, sean visibles y se usen**; el "qué" lo llenan los dueños de cada disciplina.

## Coordinación distribuida y asíncrona

En equipos distribuidos, remotos o —como este— **compuestos por agentes**, la sincronía es cara y a menudo imposible. orquesta trata el **async-first** como estrategia deliberada, no como parche:

- **Async por defecto, sync por excepción:** estado, lectura y actualizaciones viven en artefactos escritos (tablero, RAID, decisiones registradas); el sync se reserva para ambigüedad alta, decisión o construir confianza. La **documentación sustituye a la copresencia**.
- **Reducir la dependencia de sincronía:** preferir contratos e interfaces claras (X-as-a-Service, → `gestion-de-dependencias.md`) sobre colaboración de alto contacto; así dos flujos avanzan sin esperar a una reunión común.
- **Follow-the-sun y husos horarios:** secuenciar handoffs entre zonas para que el trabajo "siga al sol"; cada handoff cross-timezone es un punto de integración con su contrato (qué se entrega, en qué estado, qué desbloquea). Planning **timezone-aware**: ventanas de solape mínimas y **equitativas**, no siempre a costa de la misma zona.
- **Cadencia asíncrona:** standups escritos, demos grabadas, retros con recolección previa; el latido se mantiene sin exigir copresencia simultánea.
- **Frontera:** orquesta diseña el **modo de coordinación** (qué es async, qué es sync, cómo fluye el handoff); no decide el contenido que se coordina.

## Anti-patrones (enlaza a gobernanza-y-etica.md)

| Anti-patrón | Síntoma | Contramedida de orquesta |
|---|---|---|
| Exceso de reuniones | Calendario saturado, poco tiempo de foco | Auditar cadencia, eliminar/fusionar, mover a async |
| Ceremonia-teatro | Se hace el rito sin inspección/adaptación real | Recuperar el propósito y el output de cada evento |
| Standup-reporte-al-jefe | El equipo informa a una autoridad, no colabora | Reorientar al flujo del tablero y a los impedimentos |
| Timebox ignorado | Reuniones que se desbordan | Reafirmar la caja de tiempo, parking lot, cerrar a tiempo |
| Retro sin acciones | Se ventila pero nada cambia | Máx. 1-2 acciones con dueño y fecha, revisadas la próxima retro |
| Facilitador que decide contenido | orquesta opina sobre valor/arquitectura/calidad | Devolver la decisión al dueño (tompo/eneida/amado/baluarte) |

## Cómo cambia según el estado del sistema

| Contexto | Postura de orquesta |
|---|---|
| Greenfield | **Establecer** la cadencia: co-crear working agreement, elegir el conjunto mínimo de eventos, fijar timeboxes, definir el balance sync/async desde el día cero |
| In-flight | **Afinar** la cadencia: medir efectividad de cada evento, podar reuniones sin valor, ajustar frecuencias, reforzar timeboxing y captura de acciones |
| Brownfield / sin ritmo | **Introducir** cadencia con tacto: empezar por lo mínimo (un sync de flujo + una retro), mostrar valor temprano, evitar el shock de proceso, subir madurez gradualmente |

## Facilitación y liderazgo de servicio

orquesta facilita como **servant leader**: crea seguridad psicológica, distribuye la voz, hace visible el trabajo y los bloqueos, y usa estructuras participativas (p. ej. Liberating Structures como 1-2-4-All, TRIZ o Troika para retros y planning) para evitar que dominen pocas voces. Facilita el proceso; el equipo es dueño de sus decisiones. Reconoce además las **etapas de desarrollo del equipo** (Tuckman: forming-storming-norming-performing) y adapta su facilitación a cada una —más estructura al formarse, más autonomía al madurar—; en un equipo de agentes, calibra cuánta coordinación explícita hace falta según su acoplamiento y madurez.

```
Checklist rápido — Cadencia y ceremonias
[ ] Cada evento tiene propósito y output explícitos
[ ] Timeboxes acordados y respetados; hay parking lot
[ ] Balance sync/async calibrado (async por defecto para informar)
[ ] Asistentes correctos; hay lectura previa cuando aplica
[ ] Acciones/decisiones/impedimentos capturados y con seguimiento
[ ] Working agreement, DoR (tompo) y DoD (amado) visibles y en uso
[ ] Retro produce 1-2 acciones con dueño y fecha
[ ] Standup es del equipo, orientado al flujo (no reporte al jefe)
[ ] Cadencia auditada periódicamente: podar lo que no aporta
[ ] orquesta facilita el proceso; NO decide valor/arquitectura/calidad/pipeline
```

## Referencias

- Schwaber & Sutherland, *The Scrum Guide* (2020).
- David J. Anderson, *Kanban* (cadencias y feedback loops); Kanban University, *Kanban Maturity Model*.
- Scaled Agile, *SAFe* (PI Planning, System Demo, ART events).
- Lipmanowicz & McCandless, *The Surprising Power of Liberating Structures*; Derby & Larsen, *Agile Retrospectives*.
