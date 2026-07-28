# Gestión de incidentes y respuesta

Un incidente es toda condición que degrada un servicio por debajo de su nivel acordado (o amenaza con hacerlo) y exige respuesta coordinada. La madurez de una plataforma no se mide por la ausencia de incidentes —los sistemas complejos siempre fallan— sino por lo rápido que detecta, mitiga y aprende. baluarte es dueño del **proceso** de respuesta y de la **operación** de plataforma durante la crisis: instrumenta on-call, escribe y automatiza runbooks, coordina el incidente, mitiga operacionalmente y documenta el postmortem. No es dueño del rediseño de fondo ni del veredicto sobre el código; evidencia el problema y lo entrega al dueño de dominio.

Este documento aplica a contextos **greenfield** (donde baluarte instaura el marco desde cero, ligero pero completo), **brownfield** (donde madura un proceso informal o heroico) e **híbrido**. Los conceptos priman sobre las herramientas: donde se cite una (p. ej. un paginador, un status page, una plataforma de gestión de incidentes) es ejemplo intercambiable, nunca prescripción.

## 1. On-call sano y sostenible

El on-call es la primera línea de respuesta. Un on-call sano es condición de un servicio confiable; un on-call tóxico produce fatiga, rotación de personal y errores en la crisis. Principios:

- **Rotación primaria/secundaria.** El primario recibe y atiende; el secundario respalda (escala si el primario no acusa recibo en N minutos) y cubre saturación. Nunca una sola persona como único punto de respuesta.
- **Escalado explícito y automático.** Cadena documentada: primario → secundario → líder de guardia/dueño de servicio → gestión. Con tiempos y disparadores claros; el escalado es señal de un sistema que funciona, no de fracaso personal.
- **Follow-the-sun** cuando hay presencia multi-huso: cada región cubre su horario diurno, evitando guardias nocturnas crónicas. Requiere handoff riguroso.
- **Sostenibilidad y compensación.** El on-call se compensa (tiempo o remuneración) y se limita: el objetivo operativo de referencia es **no más de ~2 incidentes accionables por turno de 12 h** (regla Google SRE). Superarlo sistemáticamente es una señal de deuda de confiabilidad, no un motivo para pedir "más aguante".
- **Límite de páginas por turno.** Si el paginador dispara demasiado, el problema es el ruido de alertas, no el humano. El exceso de páginas se trata como incidente de proceso: revisar señales, umbrales y toil. Ver [observabilidad-operacional.md](observabilidad-operacional.md) para higiene de alertas (accionabilidad, deduplicación, síntoma vs. causa).
- **Handoff de turno.** Cada relevo transfiere estado: incidentes abiertos, cambios en vuelo, silencios/supresiones activas, riesgos conocidos. Un handoff pobre reinicia el contexto y alarga cualquier incidente en curso.

baluarte diseña y opera esta rotación (**T1**); no decide la política de RR. HH. ni la remuneración, que eleva a gestión con evidencia de carga.

## 2. Runbooks y playbooks

Un **runbook** es el procedimiento accionable para diagnosticar y mitigar una condición concreta. Un buen runbook es:

- **Accionable.** Pasos concretos y ejecutables, no prosa explicativa. Quien despierta a las 3 a. m. no necesita teoría, necesita "qué hago ahora".
- **Probado.** Un runbook nunca ejecutado es una hipótesis. Se valida en drills y game-days.
- **Versionado y vivo.** Vive junto al código o en el sistema documental, con historial; se corrige tras cada uso que revele que quedó obsoleto. Un runbook obsoleto es peor que ninguno: envía a la persona equivocada en la dirección equivocada.

**Runbook ≠ documentación.** La documentación explica cómo funciona el sistema y por qué (concepto/referencia); el runbook indica qué hacer ante un síntoma (tarea bajo presión). Confundirlos produce runbooks intransitables y docs inútiles en crisis.

**El ideal es automatizarlos.** Un runbook ejecutado tres veces es un script que falta: si un procedimiento se repite manualmente, es toil y debe convertirse en automatización (con el humano decidiendo, no tecleando). Ver el tratamiento de toil en [confiabilidad-sre.md](confiabilidad-sre.md). La progresión sana es: procedimiento manual → runbook documentado → runbook parcialmente automatizado → auto-remediación con humano en el lazo.

baluarte escribe, prueba y automatiza runbooks (**T1**). El contenido documental lo produce baluarte; **docpower** gobierna la forma y el sistema documental (plantillas, findability, ciclo de vida).

## 3. Marco de gestión de incidentes (roles)

Bajo carga, la improvisación mata. Un marco de comando de incidentes (tipo ICS/IMAG) separa responsabilidades para que nadie haga todo y nada quede sin dueño:

| Rol | Responsabilidad | Antipatrón que evita |
|-----|-----------------|----------------------|
| **Incident Commander (IC)** | Coordina, decide, mantiene el estado. NO teclea la mitigación. Un solo IC a la vez. | Múltiples personas "al mando" en direcciones opuestas. |
| **Operations / Ops Lead** | Ejecuta las acciones técnicas de mitigación que el IC coordina. | El IC absorbido en el teclado, perdiendo la visión global. |
| **Comms / Communications Lead** | Comunica a stakeholders y actualiza el status page. Traduce lo técnico. | Ingenieros interrumpidos por "¿ya está?" cada dos minutos. |
| **Scribe** | Registra el timeline en tiempo real: acciones, hallazgos, decisiones y horas. | Reconstruir a ciegas qué pasó, base imposible del postmortem. |

Reglas de oro:

- **Un solo IC.** Autoridad clara. Puede delegar, no duplicarse.
- **Separación de roles.** En incidentes pequeños una persona cubre varios; a medida que escala, se separan. El IC nunca debería ser también quien ejecuta la mitigación crítica.
- **Coordinar, no heroísmo individual.** El objetivo es respuesta coordinada, no que el "10x" salve el día en solitario. El héroe solitario no escala, no deja trazas y crea un único punto de fallo humano.

**Cuándo declarar incidente:** ante la duda, se declara. Declarar es barato (activa proceso y roles); no declarar cuando debía es caro (respuesta caótica, escalado tardío). Disparadores típicos: quema acelerada de error budget, violación de SLO con impacto en usuarios, ambigüedad sobre quién responde, o necesidad de coordinar a más de una persona.

## 4. Severidad y clasificación

La severidad calibra la respuesta según **impacto en el usuario y en el SLO**, no según cuán interesante sea el problema técnico.

| Nivel | Impacto | Respuesta esperada | Quién se involucra |
|-------|---------|--------------------|--------------------|
| **SEV1** | Caída total o pérdida/corrupción de datos; negocio detenido | Inmediata, 24/7; IC dedicado; comunicación continua | On-call + dueños de servicio + gestión + Comms |
| **SEV2** | Degradación mayor; funcionalidad crítica afectada; SLO en riesgo serio | Minutos; IC asignado | On-call + dueño de servicio |
| **SEV3** | Impacto parcial/limitado; workaround disponible | Horas; horario laboral | On-call |
| **SEV4** | Impacto mínimo o cosmético; sin efecto en SLO | Backlog priorizado | Equipo dueño |

Los umbrales exactos se acuerdan por organización (ver [plantillas.md](plantillas.md) para la matriz base). La severidad puede **reclasificarse** al alza o a la baja conforme se entiende el impacto; el IC es quien decide el nivel vigente.

## 5. Ciclo de vida del incidente

**Detección → Triage → Mitigación → Resolución → Comunicación → Cierre.**

1. **Detección.** Idealmente por monitoreo antes que por el cliente (ver [observabilidad-operacional.md](observabilidad-operacional.md)). Que un usuario detecte antes que el sistema es una brecha de observabilidad.
2. **Triage.** Evaluar impacto, asignar severidad, declarar, nombrar IC.
3. **Mitigación — primero parar el sangrado.** La regla central: **mitigar antes que diagnosticar la causa raíz.** Restablecer el servicio (rollback, failover, drenar tráfico, feature flag off, escalar capacidad) tiene prioridad absoluta sobre entender *por qué* falló. El diagnóstico profundo espera al postmortem; el usuario no.
4. **Resolución.** El servicio vuelve a niveles normales de forma estable (no solo un parche que se desmorona).
5. **Comunicación.** Transversal a todo el ciclo: actualizaciones periódicas a stakeholders y **status page** público/interno con lenguaje claro, honesto y sin culpar. Cadencia definida (p. ej. cada 30 min en SEV1) aunque no haya novedad —el silencio erosiona confianza.
6. **Cierre.** Se declara fin del incidente, se agradece, y **se agenda el postmortem** para todo incidente que supere el umbral acordado.

baluarte opera este ciclo (**T1**). Cuando la mitigación requiere una decisión de arquitectura de fondo, esa decisión es de **eneida**: baluarte la evidencia y entrega, no la toma.

## 6. Métricas: MTTD, MTTR, MTBF y sus matices

| Métrica | Qué mide | Foco |
|---------|----------|------|
| **MTTD** (Mean Time To Detect) | Desde que empieza el fallo hasta que se detecta | Reducirlo: mejor observabilidad |
| **MTTA** (Mean Time To Acknowledge) | Desde la alerta hasta el acuse humano | Salud del on-call |
| **MTTR** | "Recovery/Repair/Restore/Resolve" — significa cosas distintas | Distinguir mitigar vs. reparar |
| **MTBF** (Mean Time Between Failures) | Tiempo entre fallos | Fiabilidad estructural |

Matices críticos:

- **MTTR agregado engaña.** Es una media sobre una distribución de cola larga y sesgada; un SEV1 de 6 horas se diluye entre veinte SEV3 triviales. Se analiza por severidad y con **percentiles**, no con la media global.
- **"MTTR" es ambiguo.** *Restore* (servicio mitigado) ≠ *Repair* (causa corregida). El usuario vive el *restore*. baluarte prioriza reducir **MTTD** (detectar antes) y el tiempo hasta la **mitigación**, que es lo que el usuario realmente sufre.
- Las métricas orientan tendencias y aprendizaje; **no se usan para castigar** ni para gamificar. Optimizar la métrica en vez del resultado corrompe la cultura.

## 7. Postmortems sin culpa (blameless)

**Por qué blameless.** Los humanos no son la causa raíz: si una persona pudo derribar el sistema con una acción, **el sistema permitió ese fallo**. Culpar al individuo detiene el aprendizaje —la gente oculta información por miedo— y deja intacta la debilidad estructural que volverá a morder. El postmortem persigue *por qué tuvo sentido* la acción en su contexto, no *quién se equivocó*.

**Estructura de un postmortem** (contenido que baluarte documenta; ver plantilla en [plantillas.md](plantillas.md)):

- **Resumen e impacto:** qué pasó, duración, usuarios/SLO afectados, severidad.
- **Timeline:** cronología factual con horas (del scribe).
- **Causas raíz (en plural):** análisis con 5-whys y/o fault-tree, entendiendo las **contribuciones múltiples**, no "la" causa única.
- **Qué salió bien / qué salió mal / dónde tuvimos suerte.** La "suerte" es clave: lo que casi falla y no falló señala el próximo incidente.
- **Acciones correctivas accionables:** cada una con **dueño y fecha**, verificables, priorizadas. Una acción sin dueño ni fecha es un deseo.
- **Seguimiento hasta cierre:** las acciones se rastrean como trabajo real hasta completarse; un postmortem cuyas acciones nunca se cierran es teatro.

La cultura de aprendizaje —revisiones abiertas, postmortems legibles por toda la organización, reconocer que reportar un error es un acto de responsabilidad— es tan importante como el documento.

## 8. Análisis de segundo orden y sistemas complejos

Los mejores postmortems no arreglan la **instancia**, previenen la **clase** de fallo. Preguntas de segundo orden: ¿qué otros servicios comparten esta debilidad? ¿Qué salvaguarda ausente la habría contenido con independencia de la causa puntual?

Adoptar la visión de **sistemas complejos / Safety-II**: el fallo emerge de la interacción de múltiples factores normalmente inocuos, no de una única "causa raíz". Se estudia también por qué el sistema **normalmente funciona** (no solo por qué falló esta vez) y cómo el trabajo real de los operadores compensa la fragilidad a diario. Buscar una causa raíz única y un culpable único son la misma falacia con dos caras.

Cuando el postmortem revela que el remedio correcto es un **rediseño arquitectónico**, baluarte lo documenta y lo eleva; la decisión de arquitectura es de **eneida**. Cuando revela un **defecto de correctitud en el código**, el veredicto y la corrección son de **certero**; baluarte ya mitigó operacionalmente (rollback/failover) y aporta la evidencia.

## 9. Chaos engineering y game-days

No se puede confiar en una respuesta que nunca se ha ensayado. Se practica el fallo deliberadamente. **Principios del chaos engineering:**

- **Hipótesis de estado estable:** definir el comportamiento normal medible y postular que se mantendrá pese al fallo inyectado.
- **Inyectar fallo real:** latencia, caída de instancias, partición de red, agotamiento de recursos, dependencias degradadas —eventos plausibles del mundo real.
- **Blast radius mínimo:** empezar pequeño, contener el impacto, tener botón de aborto.
- **En producción con cuidado:** el valor máximo está en prod (donde vive la complejidad real), pero solo tras validar en staging y con salvaguardas. Progresión: **staging → prod controlado → prod ampliado.**

**Game-days / DiRT** (Disaster Recovery Testing): ejercicios programados que ensayan tanto la **respuesta a incidentes** (¿funciona el paginador, el runbook, el escalado, los roles?) como la **recuperación ante desastres** (failover regional, restore de respaldos). Validan personas, proceso y tecnología juntos. Enlaza con [continuidad-y-dr.md](continuidad-y-dr.md) para el ensayo de DR y la verificación de RTO/RPO.

**Frontera con `amado` (explícita):** el **diseño del experimento de caos como prueba** —hipótesis, caso, criterio de aceptación, cobertura— pertenece a `amado` (ingeniería del caos como disciplina de calidad). baluarte **ejecuta game-days y DiRT en producción** como práctica operativa de confiabilidad y de ensayo de respuesta. amado especifica el experimento; baluarte lo opera en vivo y responde como si fuera un incidente real.

## 10. Preparación: production readiness y drills

La respuesta empieza mucho antes del incidente. Antes de que un servicio entre a rotación de on-call, se exige un **Production Readiness Review (PRR):** SLO definidos, observabilidad instrumentada, runbooks escritos y probados, alertas accionables, plan de capacidad y de rollback. Sin PRR aprobado, no se hace onboarding a on-call: sería poner a personas a responder por un sistema que nadie sabe operar. Ver checklists en [plantillas.md](plantillas.md).

Complementan la preparación: **formación** de nuevos on-call (sombra antes de guardia real), **incident drills** periódicos y simulacros de escalado. Un equipo que solo practica en incidentes reales practica siempre tarde.

## 11. Antipatrones

- **Héroe solitario:** una persona lo resuelve todo sin coordinar; no escala, no deja rastro, crea dependencia frágil.
- **Culpar personas:** destruye la confianza y el flujo de información; el fallo vuelve.
- **Mitigar y no hacer postmortem:** se pierde el aprendizaje; el mismo incidente reincide.
- **Acciones correctivas que nunca se cierran:** el postmortem se vuelve ritual vacío.
- **Runbooks obsoletos:** guían mal bajo presión; peores que su ausencia.
- **Declarar incidentes tarde:** respuesta caótica y escalado tardío por miedo a "exagerar".
- **Diagnosticar mientras sangra:** perseguir la causa raíz con el servicio caído en vez de mitigar primero. Curiosidad a destiempo cuesta disponibilidad.

## 12. Cómo actúa baluarte (modelo tiered)

- **T1 — Proceso y operación (baluarte ejecuta directo):** diseñar y operar el on-call, escribir/probar/automatizar runbooks, comandar el incidente, mitigar operacionalmente (rollback, failover, drenaje, flags), correr game-days/DiRT y documentar el postmortem.
- **T2 — Corrección de fondo (se entrega al dueño de dominio):** la reparación estructural que el postmortem revele va a quien corresponde —**eneida** (arquitectura), **certero** (correctitud del código), **motor/farola/andulfo** (implementación del fix en su capa). baluarte evidencia, prioriza la acción correctiva con dueño y fecha, y da seguimiento hasta el cierre, pero no suplanta el ownership de dominio.
- **T3 — Potestad (dueño saturado o ausente):** si el dueño de la acción correctiva **está saturado o no existe**, baluarte aplica el arreglo **operativo** que su disciplina permita (mitigación duradera, gate, automatización), reversible y marcado **"pendiente de revisión del dueño"**, sin tomar decisiones de dominio ajeno (arquitectura, política de seguridad, física de datos).

**Fronteras clave:**
- Un **incidente de seguridad** (brecha) lo lidera **destroyer**; baluarte opera la respuesta de plataforma (contención operativa, aislamiento, restore) bajo esa dirección.
- La **decisión de arquitectura** que un postmortem justifique es de **eneida**; baluarte la evidencia y entrega.
- La **correctitud del código** que causó el bug la juzga **certero**; baluarte mitiga operacionalmente mientras tanto.
- El **contenido** del postmortem lo documenta baluarte; **docpower** gobierna su forma y el sistema documental.
- El **diseño del experimento de caos como prueba** es de **amado**; baluarte lo **ejecuta en producción** como práctica de confiabilidad.

Ver también [confiabilidad-sre.md](confiabilidad-sre.md) (SLO, error budgets, toil), [gobernanza-y-etica.md](gobernanza-y-etica.md) (transparencia y comunicación responsable en crisis) e [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) (coordinación de la respuesta con equipos y proveedores externos).
