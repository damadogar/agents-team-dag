# Plantillas de entregables

Este archivo reúne las plantillas de entregables que baluarte utiliza para producir artefactos operativos consistentes, revisables y portables. Todas son conceptuales y agnósticas de herramienta: baluarte adapta los campos al contexto real. Cada plantilla es rellenable (campos entre corchetes) y va acompañada de una nota de cuándo usarla.

Principio transversal: un entregable de baluarte siempre deja explícito el **blast radius**, la **verificación** (contra SLO/observabilidad) y el **rollback**. Si un artefacto no puede responder esas tres preguntas, aún no está listo.

## 1. Runbook operativo

Procedimiento accionable para responder a una alerta o ejecutar una operación delicada. El lector puede estar medio dormido a las 3 a. m.: pasos concretos, sin ambigüedad, con comandos/acciones verificables.

```
# Runbook: [nombre de la alerta o procedimiento]

Servicio / componente: [servicio]
Dueño / on-call: [equipo o rol]
Última revisión: [fecha] · Probado el: [fecha]

## Disparador / síntoma
[Qué alerta lo dispara o qué síntoma observa el usuario/operador.]

## Impacto
[Qué se degrada y para quién. SLO afectado: [SLI/objetivo].]

## Diagnóstico (paso a paso)
1. [Verificar señal/observación] → esperado: [valor]; anómalo: [valor]
2. [Siguiente comprobación, con el panel/consulta a mirar]
3. [Árbol de decisión: si A → sección Mitigación X; si B → escalado]

## Mitigación
- Opción 1 (preferida): [acción reversible] · efecto esperado: [métrica]
- Opción 2 (si 1 falla): [acción]

## Verificación
[Cómo confirmar que el incidente cedió: señal a observar, valor objetivo,
ventana de estabilización antes de declarar resuelto.]

## Escalado
- Si no cede en [tiempo] → escalar a [rol/equipo].
- Criterio para declarar incidente mayor: [umbral].

## Rollback
[Cómo revertir cualquier cambio hecho durante la mitigación.]

## Enlaces
[Dashboards, SLO, arquitectura, runbooks relacionados.]
```

Cuándo usarla: al documentar la respuesta a cualquier alerta accionable o procedimiento de riesgo. Nota: el runbook es un paso intermedio, no el destino. Todo runbook que se ejecute con frecuencia y sea determinista es candidato a automatizarse; baluarte trata el runbook manual como deuda a reducir. Ver [incidentes-y-respuesta.md](incidentes-y-respuesta.md) y [confiabilidad-sre.md](confiabilidad-sre.md).

## 2. Postmortem sin culpa (blameless)

Análisis retrospectivo de un incidente. El objetivo es aprender del sistema, no juzgar a las personas: se asume que todos actuaron razonablemente con la información y las herramientas que tenían. El lenguaje se centra en condiciones, no en "quién falló".

```
# Postmortem: [título del incidente] — [fecha]

Estado: [borrador | en revisión | cerrado]
Autor / facilitador: [rol]

## Resumen
[2-4 frases: qué pasó, alcance y resolución, en lenguaje llano.]

## Impacto
- Usuarios / clientes afectados: [alcance]
- SLO / error budget consumido: [SLI, % de presupuesto]
- Duración: inicio [ts] → mitigado [ts] → resuelto [ts] ([Δ])

## Timeline
[ts] [evento / detección / acción / decisión]
[ts] ...

## Detección
[Cómo se detectó: alerta automática, reporte, casualidad. ¿Cuánto tardó (TTD)?]

## Respuesta
[Qué se hizo para mitigar y por qué. ¿Cuánto tardó (TTR)? ¿Qué frenó la respuesta?]

## Causas raíz (contribuciones múltiples)
[Análisis con 5-whys o fault-tree. Rara vez hay una sola causa: enumerar los
factores contribuyentes técnicos y organizativos que se alinearon.]
- Contribución 1: [...]
- Contribución 2: [...]

## Qué salió bien / qué salió mal
Bien: [defensas que funcionaron]
Mal: [dónde el sistema no ayudó]

## Factor suerte
[¿Qué evitó que fuera peor por casualidad? Nombrarlo revela riesgo latente.]

## Acciones correctivas
| Acción | Tipo (prevención/detección/mitigación) | Dueño | Fecha |
|--------|----------------------------------------|-------|-------|
| [...]  | [...]                                   | [rol] | [fecha] |

## Lecciones aprendidas
[Conocimiento generalizable que trasciende este incidente.]
```

Cuándo usarla: tras cualquier incidente que amerite aprendizaje (no solo los grandes). Es explícitamente blameless: si un nombre propio aparece asociado a culpa, se reescribe en términos de sistema. Ver [incidentes-y-respuesta.md](incidentes-y-respuesta.md).

## 3. Documento de SLO / SLA

Define, de forma medible, qué nivel de servicio se promete y cómo se gestiona el margen de error. Distingue SLI (lo que se mide), SLO (el objetivo interno) y SLA (el compromiso externo con consecuencias).

```
# SLO: [servicio / journey de usuario]

## SLIs
- Nombre: [p. ej. disponibilidad de la API de checkout]
  - Evento válido: [qué peticiones/eventos cuentan]
  - Evento bueno: [qué define "bueno": <300ms, 2xx/3xx, etc.]
  - SLI = buenos / válidos

## Objetivo (SLO)
- Objetivo: [p. ej. 99.9%]
- Ventana: [rolling 28 días | trimestre]

## Error budget y política de agotamiento
- Presupuesto: [100% − SLO] de eventos válidos.
- Política: si el budget se agota → [congelar cambios de riesgo /
  priorizar confiabilidad sobre features / revisión obligatoria].

## Alertas de burn-rate
- Rápida: consumo de [Nx] budget en [ventana corta] → página.
- Lenta: consumo de [Mx] en [ventana larga] → ticket.

## Dependencias
[SLOs de servicios de los que se depende; el SLO propio no puede superar el
producto de los ajenos.]

## SLA (si aplica)
[Compromiso externo, más laxo que el SLO, y sus consecuencias/créditos.]

## Revisión
[Cadencia de revisión del objetivo y responsable.]
```

Cuándo usarla: al fijar o revisar objetivos de fiabilidad de un servicio. Ver [confiabilidad-sre.md](confiabilidad-sre.md) para la teoría de SLI/SLO/error budget y multi-window burn-rate.

## 4. Plan de despliegue (change plan)

Describe cómo se introducirá un cambio en producción minimizando y acotando el riesgo. El rollback no es opcional ni teórico: debe estar probado antes de empezar.

```
# Plan de despliegue: [cambio]

Solicitante / dueño: [rol] · Fecha/ventana: [ventana con baja carga]

## Cambio y objetivo
[Qué se despliega y qué resultado se busca.]

## Blast radius
[Qué se ve afectado si sale mal: usuarios, servicios, datos, región.]

## Estrategia
[Canary | blue-green | rolling | feature flag | shadow]
Justificación: [por qué esta y no otra.]

## Pasos
1. [Preparación / verificación previa]
2. [Exposición gradual: % inicial, cohorte]
3. [Puntos de pausa]

## Criterios de avance (gates por métrica/SLO)
- Avanzar a la siguiente fase solo si: [error rate < X, latencia p99 < Y,
  sin quema anómala de error budget] durante [ventana].

## Plan de rollback (PROBADO)
[Procedimiento exacto para revertir. Cuándo se dispara (umbral). Tiempo
estimado. Confirmar que se ensayó y funciona antes del despliegue.]

## Comunicación
[A quién se avisa, antes/durante/después; canal.]

## Verificación post-deploy
[Señales a observar tras completar; ventana de vigilancia; criterio de éxito.]
```

Cuándo usarla: antes de cualquier despliegue de riesgo no trivial. Ver [cicd-y-release-engineering.md](cicd-y-release-engineering.md) para estrategias progresivas, gates automáticos y rollback.

## 5. Production Readiness Review (PRR)

Revisión estructurada que decide si un servicio está listo para operar en producción (o para que on-call lo soporte). Termina en un veredicto go/no-go con condiciones explícitas.

```
# PRR: [servicio] — [fecha]

## Arquitectura operativa
[Diagrama/resumen: componentes, flujos, puntos de estado.]

## SLOs
[Definidos y con dueño: sí/no. Referencia al documento de SLO.]

## Observabilidad
- Dashboards: [existen y cubren señales doradas: sí/no]
- Alertas: [accionables, con runbook, sin ruido: sí/no]
- Logs/traces: [suficientes para diagnóstico: sí/no]

## Runbooks
[Existen para las alertas principales y están probados: sí/no]

## Capacidad y escalado
[Headroom conocido, límites, autoscaling, prueba de carga: sí/no]

## Dependencias y modos de fallo
[Dependencias mapeadas; degradación elegante; timeouts/retries/circuit
breakers definidos: sí/no]

## DR / backup
[RPO/RTO definidos; backups probados con restore real: sí/no]

## Seguridad integrada
[Secretos gestionados, mínimo privilegio, superficie revisada: sí/no]

## On-call listo
[Rotación, escalado, contactos, formación del equipo: sí/no]

## Veredicto
[ GO | GO CON CONDICIONES | NO-GO ]
Condiciones bloqueantes: [lista con dueño y fecha]
```

Cuándo usarla: antes de lanzar un servicio nuevo a producción o de asumir su soporte. Ver [checklists.md](checklists.md) para la lista detallada de verificación.

## 6. Revisión de IaC / pipeline (handoff)

Resumen de revisión para cambios en infraestructura-como-código o en pipelines. Enfoca la atención en las propiedades que más rompen producción: reversibilidad, drift, idempotencia y secretos.

```
# Revisión IaC/pipeline: [cambio]

## Qué cambia
[Recursos/etapas que se crean, modifican o destruyen.]

## Blast radius
[Alcance del cambio; ¿toca recursos con estado o compartidos?]

## Reversibilidad
[¿Se puede revertir sin pérdida? ¿Recreación destruye datos?]

## Drift
[¿El estado real coincide con el declarado? ¿El cambio corrige o introduce drift?]

## Secretos
[¿Hay secretos en texto plano, logs o estado? ¿Gestión adecuada?]

## Idempotencia
[¿Aplicar dos veces produce el mismo resultado?]

## Coste
[Impacto en coste recurrente y de picos.]

## Verificación
[Cómo se valida: plan/diff revisado, entorno de prueba, prueba de destrucción/recreación.]

## Destinatario
[A quién se entrega para aplicar/aprobar.]
```

Cuándo usarla: al revisar o entregar cambios de infraestructura y pipelines antes de aplicarlos. Ver [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

## 7. Handoff tiered de baluarte (contrato de interoperabilidad)

Es el contrato estándar con el que baluarte propone o entrega un cambio de plataforma/entrega/confiabilidad a otra disciplina o al orquestador. Ningún handoff sale sin sus ocho campos completos.

```
# Handoff baluarte → [destinatario]

## Objetivo
[Qué se busca lograr, en términos de negocio o de fiabilidad.]

## Estado actual (con evidencia)
[Situación medida hoy: métricas, SLI actual, síntomas. Con datos, no impresiones.]

## Cambio propuesto
[Qué se propone hacer, concreto.]

## Blast radius
[Qué queda expuesto si el cambio sale mal: alcance y peor caso.]

## Plan de rollback
[Cómo se revierte, en cuánto tiempo, probado sí/no.]

## Verificación (SLO / observabilidad)
[Cómo se comprobará el éxito: SLI/SLO objetivo, panel/señal, ventana.]

## Costo / capacidad
[Impacto en coste recurrente, headroom y límites.]

## Destinatario
[Quién recibe, qué decisión o acción se le pide.]
```

Cuándo usarla: en toda interacción cross-disciplina donde baluarte propone o entrega un cambio. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) (sección 4), de donde este contrato es réplica fiel.

## 8. Informe de evaluación / auditoría de plataforma (modo A)

Entregable de baluarte cuando evalúa el estado de una plataforma sin ejecutar cambios: encuadra, diagnostica por severidad y por lente, enruta a las disciplinas dueñas y prioriza recomendaciones con criterios de éxito medibles.

```
# Auditoría de plataforma: [alcance] — [fecha]

## Encuadre
- Objetivo del sistema: [qué debe lograr]
- SLOs / expectativas: [objetivos vigentes o ausentes]
- Restricciones: [coste, plazos, regulatorio, equipo]

## Hallazgos
Clasificados por severidad [Bloqueante | Importante | Menor] y por lente:
- Entrega (CI/CD, release): [hallazgo — severidad — evidencia]
- Plataforma (infra, IaC, capacidad, coste): [...]
- Confiabilidad (SLO, observabilidad, DR, on-call): [...]

## Enrutado por disciplina
[Qué hallazgo corresponde a qué dueño: seguridad, datos, backend, arquitectura,
performance, o a baluarte mismo.]

## Recomendaciones priorizadas
| # | Recomendación | Impacto | Esfuerzo | Prioridad |
|---|---------------|---------|----------|-----------|

## Veredicto
[Estado general y riesgos principales.]

## Criterios de éxito medibles
[Cómo se sabrá que las recomendaciones surtieron efecto: métricas objetivo.]
```

Cuándo usarla: en evaluaciones/auditorías donde baluarte diagnostica y recomienda sin tocar el sistema. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para el enrutado por disciplina.

## 9. Análisis de capacidad (breve)

Determina si la plataforma soporta la demanda esperada, incluidos picos y la pérdida de una zona/región, y qué escalado/coste implica. Breve por diseño: demanda, capacidad, headroom, escenarios adversos y plan.

```
# Análisis de capacidad: [servicio / recurso]

## Demanda proyectada
[Carga esperada: base y crecimiento; horizonte temporal.]

## Capacidad actual
[Recurso limitante: CPU, memoria, IOPS, conexiones, cuota. Valor y límite.]

## Headroom
[Margen actual = (capacidad − demanda) / capacidad. Umbral objetivo: [%].]

## Escenario de pico
[Demanda en el peor pico esperado; ¿el headroom lo absorbe?]

## Escenario de pérdida de zona
[Si cae una zona/región, ¿la capacidad restante sostiene la carga (N-1)?]

## Plan de escalado / coste
[Cómo se añade capacidad (horizontal/vertical/autoscaling), tiempo de
aprovisionamiento y coste incremental.]
```

Cuándo usarla: al planear capacidad ante crecimiento, campañas o revisiones periódicas de fiabilidad. Ver [confiabilidad-sre.md](confiabilidad-sre.md) para cómo la capacidad se enlaza con SLO y modos de fallo.
