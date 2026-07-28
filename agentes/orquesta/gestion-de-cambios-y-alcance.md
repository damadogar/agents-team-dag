# Gestión de cambios y alcance

> Este archivo trata la **gestión de cambios de ALCANCE** (change control / scope management): cómo un cambio en lo que se va a construir impacta el **flujo de entrega** y cómo se re-planifica. NO trata la gestión del cambio organizacional (adopción, personas, cultura).

Orquesta posee el **impacto de flujo** de todo cambio de alcance: cronograma, dependencias, capacidad, riesgo de entrega y forecast, y la **re-planificación** que se deriva. Tiene **autoridad de flujo, no de contenido**: nunca decide el valor del cambio (eso es **tompo**), ni su factibilidad/impacto arquitectónico (eso es **eneida**), ni la estimación del craft (cada especialista). Orquesta **consolida** el análisis y lo lleva al dueño de la decisión; no aprueba el valor.

Neutralidad total de metodología: sirve para contextos predictivos con líneas base formales y para contextos ágiles donde el cambio se abraza vía re-priorización del backlog. Universal para greenfield, in-flight y brownfield.

---

## Dos formas de tratar el alcance (neutral)

| Enfoque | Cómo vive el alcance | Cómo entra el cambio | Rol de orquesta |
|---|---|---|---|
| **Predictivo / plan-driven** | Scope baseline + WBS; alcance acordado y línea base | Change request formal → análisis → decisión (CCB) → re-baseline | Analiza impacto de flujo, consolida, agenda re-planificación |
| **Ágil / adaptativo** | Backlog vivo priorizado; alcance emergente | El cambio se **abraza**: se re-prioriza el backlog (tompo) | Hace visible el impacto en capacidad/forecast; protege el ritmo |
| **Híbrido** | Baseline a alto nivel + backlog en el detalle | Formal en lo contractual, adaptativo en el "cómo" | Traduce entre ambos lenguajes sin sesgo |

Ninguno es "mejor". El backlog ágil no es ausencia de control: es control por **re-priorización explícita** en vez de por baseline. En ambos casos el cambio se hace **visible** antes de ejecutarse.

---

## Flujo de una solicitud de cambio (change request)

1. **Capturar** — registrar la solicitud (qué, por qué, quién la pide, urgencia). Todo cambio de alcance material se registra, aunque el contexto sea ágil.
2. **Analizar impacto** — reparto de responsabilidad (ver tabla siguiente). Orquesta orquesta el análisis, no lo monopoliza.
3. **Decidir** — el **dueño de la decisión** aprueba/rechaza/difiere. Orquesta presenta el paquete consolidado; no decide el valor.
4. **Actualizar** — re-baseline (predictivo) o re-priorización del backlog (ágil); ajustar cronograma, dependencias y capacidad.
5. **Comunicar** — a afectados y stakeholders; cerrar el lazo con quien lo pidió. Trazabilidad del cambio conservada.

> Cambio rechazado o diferido también se registra y se comunica: el "no" y el "todavía no" son decisiones de gestión.

---

## Análisis de impacto — reparto de responsabilidad

| Dimensión | Dueño | Qué aporta |
|---|---|---|
| **Impacto de flujo** (cronograma, dependencias, capacidad, riesgo de entrega, forecast) | **orquesta** | Cuánto mueve la fecha, qué dependencias altera, si hay capacidad, qué riesgo introduce |
| **Valor y prioridad** del cambio | **tompo** | Si vale la pena, cómo se re-prioriza frente a lo demás |
| **Factibilidad e impacto arquitectónico** | **eneida** | Si es viable, qué toca en el diseño, deuda que genera |
| **Estimación del craft** | especialista (motor, farola, palma, andulfo, uxuifull, baluarte, certero, amado, docpower, sysuniversal-ai, destroyer…) | Esfuerzo y complejidad reales de ejecutar el cambio |

Orquesta **consolida** estas piezas en un paquete de decisión (opciones, trade-offs, costo de flujo, riesgo) y lo entrega al dueño de la decisión. Regla: **orquesta no rellena los huecos de otros dueños con su propio juicio**; los solicita y espera.

**Tiered META de orquesta:**
- **T1** — coordina el flujo del change request directamente (registro, agenda de análisis, actualización de plan).
- **T2** — **co-facilita** con el dueño (p. ej. la sesión de impacto con tompo/eneida).
- **T3** — si el dueño está ausente/saturado, ejerce **potestad de flujo** para no bloquear la entrega (reordena, agenda, comunica un impacto de cronograma), marcándolo **"pendiente de ratificación"**. Nunca ratifica el **valor** por su cuenta.

---

## Control de scope creep

El *scope creep* es el crecimiento **silencioso** del alcance sin decisión explícita. El objetivo no es congelar el alcance, es hacerlo **visible**.

| Situación | Naturaleza | Acción de orquesta |
|---|---|---|
| Cambio solicitado y evaluado | Legítimo | Al flujo de change request; decide el dueño |
| Aprendizaje del producto (ágil) | Legítimo y deseable | Visible en backlog; re-prioriza tompo; no se penaliza |
| "Ya que estamos…" agregado en ejecución | Deslizamiento | Nombrarlo, sacarlo a la luz, devolverlo a decisión |
| Gold-plating (más de lo pedido) | Deslizamiento | Hacer visible el costo de flujo; que el dueño decida |

Principio: **distinguir cambio legítimo de deslizamiento silencioso, sin bloquear el aprendizaje.** Orquesta ilumina; no juzga el mérito del cambio.

---

## Control integrado de cambios y gestión por excepción

- **Control integrado de cambios / CCB** (contextos formales): un cambio se evalúa contra TODAS las dimensiones (alcance, cronograma, costo, calidad, riesgo) antes de decidir, porque tocar una mueve las otras. El CCB (comité) es el foro de decisión; orquesta prepara el paquete y ejecuta la actualización.
- **Gestión por excepción y tolerancias** (estilo PRINCE2): se definen **tolerancias** (de cronograma, alcance, capacidad). Mientras el cambio cabe dentro de la tolerancia, el equipo procede sin escalar. Solo cuando se **pronostica** rebasar la tolerancia se escala al nivel superior. Esto evita reuniones de comité para cada micro-ajuste y reserva la decisión formal para lo material.
- Elegir el peso del proceso por **contexto y riesgo**: pesado para lo contractual/regulado/mission-critical; ligero para lo exploratorio.

---

## Líneas base, re-baselining y trazabilidad

- **Línea base (baseline)** — foto acordada del alcance/cronograma contra la cual se mide la desviación. Sin baseline, "cambio" no tiene referente.
- **Re-baselining** — rehacer la línea base cuando un cambio aprobado la vuelve obsoleta. Se hace de forma **explícita y comunicada**, no silenciosa; se conserva la anterior para trazabilidad.
- **Configuration / baseline management** — versionar el alcance y sus artefactos (backlog, WBS, contratos de interfaz) para saber qué versión está vigente y por qué.
- **Trazabilidad del cambio** — de la solicitud → decisión → ítems afectados → nueva línea base/backlog. Permite responder "¿por qué cambió la fecha?" con evidencia.

---

## Enlaces (un cambio grande se propaga)

Un cambio de alcance material casi nunca es local. Orquesta encadena:

- Genera o altera **riesgos** → [gestion-de-riesgos-raid.md](gestion-de-riesgos-raid.md).
- Reconfigura **dependencias** entre agentes/equipos → [gestion-de-dependencias.md](gestion-de-dependencias.md).
- Re-planifica el **cronograma** y el camino crítico → [planificacion-y-cronograma.md](planificacion-y-cronograma.md).
- Consume **capacidad** que hay que reasignar → [capacidad-y-asignacion.md](capacidad-y-asignacion.md).
- Impacta el **forecast y las métricas** de entrega → [flujo-y-metricas-de-entrega.md](flujo-y-metricas-de-entrega.md).
- Se **comunica** a stakeholders → [comunicacion-y-reporte.md](comunicacion-y-reporte.md).

Ver también [orquestacion-y-ruteo.md](orquestacion-y-ruteo.md), [metodologias-y-marcos.md](metodologias-y-marcos.md), [cadencia-y-ceremonias.md](cadencia-y-ceremonias.md), [plantillas.md](plantillas.md) y [ejemplos.md](ejemplos.md). Anclas de identidad: [SKILL.md](SKILL.md), [gobernanza-y-etica.md](gobernanza-y-etica.md).

---

## Cómo cambia por contexto

| Contexto | Naturaleza del cambio | Postura de orquesta |
|---|---|---|
| **Greenfield** | Alcance muy fluido; el cambio es la norma | Control ligero, backlog vivo; hacer visible el costo de flujo sin frenar el descubrimiento |
| **In-flight** | Cambios frecuentes con trabajo en curso | Proteger el WIP; evaluar impacto en camino crítico; tolerancias claras; re-priorizar con tompo |
| **Brownfield / legacy** | Cambios acotados por restricciones heredadas | Control más estricto; el impacto de compatibilidad y regresión pesa; eneida evalúa factibilidad; más análisis antes de decidir |

---

## Checklist rápido

```
[ ] ¿El cambio está REGISTRADO (qué, por qué, quién, urgencia)?
[ ] Impacto de FLUJO analizado por orquesta (cronograma, dependencias, capacidad, riesgo, forecast)
[ ] VALOR y re-priorización → definidos por tompo (no por orquesta)
[ ] Factibilidad / impacto ARQUITECTÓNICO → evaluado por eneida
[ ] Estimación del CRAFT → aportada por el/los especialista(s)
[ ] Paquete de decisión CONSOLIDADO y llevado al dueño de la decisión
[ ] Decisión tomada (aprobado / rechazado / diferido) y REGISTRADA
[ ] Línea base re-baselined o backlog re-priorizado — de forma explícita
[ ] ¿Es scope creep silencioso? → hacerlo visible y devolver a decisión
[ ] ¿Dentro de tolerancias? Si se pronostica rebasar → escalar
[ ] Riesgos / dependencias / cronograma actualizados (enlaces)
[ ] Cambio COMUNICADO a afectados y stakeholders; lazo cerrado con el solicitante
[ ] Trazabilidad conservada (solicitud → decisión → ítems → nueva base)
[ ] Si T3 por dueño ausente: marcado "pendiente de ratificación"
```

---

## Referencias

- PMI, *PMBOK® Guide* — Perform Integrated Change Control; Scope Baseline y WBS; Change Control Board (CCB).
- AXELOS, *Managing Successful Projects with PRINCE2®* — tema de Cambios, gestión por excepción y tolerancias.
- *Manifiesto Ágil* y guías de Scrum/Kanban — abrazar el cambio; backlog priorizado como mecanismo de control adaptativo.
- Disciplina de Configuration/Baseline Management (ISO/IEC/IEEE 24765; prácticas de gestión de configuración) — líneas base y trazabilidad del cambio.
