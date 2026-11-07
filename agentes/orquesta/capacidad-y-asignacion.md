# Capacidad y asignación

Este satélite gobierna **cuánto trabajo puede absorber el sistema** y **quién recibe cada
ítem**. Orquesta posee el FLUJO: mide capacidad, balancea carga, empareja tarea→disciplina,
fija límites de WIP y protege la holgura. NO decide el contenido del trabajo ni cómo se hace:
eso pertenece al dueño de cada disciplina. La asignación es una decisión de flujo; el craft y
su "cómo" son inviolablemente del dueño.

Neutral de metodología: los conceptos aquí (Little's Law, WIP, Theory of Constraints, colas,
carga cognitiva) aplican igual en Scrum, Kanban, SAFe, waterfall o híbridos, y en proyectos
greenfield, en construcción o brownfield.

## 1. Capacity planning (capacidad real, no nominal)

Capacidad = personas/agentes disponibles × foco efectivo × horizonte, **menos** el trabajo ya
comprometido. Nunca se planifica contra la capacidad nominal (100 %): se planifica contra la
**capacidad asignable** tras descontar mantenimiento, soporte, ceremonias y cambio de contexto.

| Insumo | Qué mide | Riesgo si se ignora |
|---|---|---|
| Disponibilidad | Tiempo real del dueño en el horizonte (ausencias, otros programas) | Se compromete trabajo que nadie puede tomar |
| Foco vs. cambio de contexto | Cuántos hilos concurrentes lleva un dueño | Multitarea → el lead time se dispara |
| Trabajo comprometido | WIP en curso + backlog aceptado | Doble asignación, promesas incumplibles |
| Capacidad asignable | Lo que queda libre de verdad | Es lo único sobre lo que se puede asignar |

El **cambio de contexto** es un impuesto no lineal: cada hilo adicional degrada el rendimiento
de todos (carga cognitiva, Team Topologies). Preferir que un dueño termine antes de empezar
otro ítem (minimizar WIP por persona) sobre repartir muchos ítems a medias.

> **Contención cross-programa:** cuando un mismo dueño se reparte entre **varios programas**
> simultáneos, la capacidad asignable se calcula sobre el total (no por programa); si dos
> programas compiten por el mismo dueño, la prioridad de **inversión/portafolio** que desempata
> es del **negocio/sponsor** (externo; tompo la traduce a producto). Orquesta la escala, no la
> decide — ver `gestion-de-programa.md`.

## 2. Balanceo de carga y matching por disciplina

La asignación se hace **por disciplina, nunca por nombre**. Se identifica la disciplina que
demanda el ítem y se rutea al dueño de esa disciplina que tenga capacidad asignable. El detalle
de reglas de ruteo, desempates y cobertura vive en → `orquestacion-y-ruteo.md`.

### Matriz de disciplinas del equipo (insumo de asignación)

| Disciplina | Dueño (handle) |
|---|---|
| Valor / prioridad / alcance de producto | tompo |
| Arquitectura / liderazgo técnico | eneida |
| DevOps / SRE / plataforma / pipeline | baluarte |
| Backend | motor |
| Frontend web | farola |
| Mobile | palma |
| UX / UI | uxuifull |
| Datos | andulfo |
| IA / LLM | sysuniversal-ai |
| Performance | peakformance |
| Correctitud / code review | certero |
| QA / pruebas | amado |
| Seguridad | destroyer |
| Documentación | docpower |
| SEO / search visibility | radar |
| Marketing / GTM / growth | auge |

Regla de balanceo: si dos ítems compiten por el mismo dueño y hay cuello de botella, se
**secuencia por prioridad** (la fija el dueño del valor, tompo) y se protege el WIP, no se
apila. Si la disciplina admite más de un ejecutor posible, se balancea hacia el de mayor
capacidad asignable.

## 3. Límites de WIP y Little's Law

**Little's Law:** `WIP = throughput × lead time` → `lead time = WIP / throughput`. Con un
throughput dado, **cuanto más WIP, más largo el lead time**. Limitar el WIP es la palanca más
directa para acortar el tiempo de entrega sin añadir capacidad.

Por qué funciona:
- Menos ítems abiertos = menos cambio de contexto = más throughput real.
- Un límite de WIP convierte el sistema en **pull**: un dueño toma trabajo nuevo solo cuando
  libera un espacio, en vez de que el flujo lo **empuje** (push) y lo sature.
- El WIP excedente hace visible el cuello de botella (Theory of Constraints): el sistema entrega
  al ritmo de su restricción, no al del recurso más rápido.

Se fija un límite de WIP por dueño/disciplina y para el sistema. Superarlo es una **señal**, no
un detalle: dispara la sección 5.

## 4. Holgura deliberada (slack)

La utilización al 100 % **destruye el flujo**. Por teoría de colas, el tiempo de espera crece de
forma no lineal al acercarse al 100 %: pasar de 80 % a 95 % de utilización multiplica el lead
time y la variabilidad (Reinertsen, *Principles of Product Development Flow*). Un sistema sin
holgura no puede absorber urgencias, reprocesos ni dependencias tardías.

- La holgura no es tiempo "perdido": es la capacidad de responder rápido y de mejorar.
- Sobre-asignar tiene costo: colas invisibles, aging WIP, entregas tardías, calidad erosionada y
  ritmo insostenible (ver equidad y ritmo sostenible en → `gobernanza-y-etica.md`).
- Orquesta reserva holgura de forma explícita y la defiende; no la rellena para "aprovechar"
  capacidad.

## 4 bis. Gestión del cuello de botella (Theory of Constraints)

Operacionalizo la restricción ya nombrada en §3 (el sistema entrega al ritmo de su cuello de botella, no del recurso más rápido) con los **cinco pasos de enfoque** (Goldratt), que guían la acción de flujo de orquesta:

1. **Identificar** la restricción: dónde se acumula el WIP y crece la cola (el CFD y el aging WIP la delatan → `flujo-y-metricas-de-entrega.md`).
2. **Explotar** la restricción: que nunca esté ociosa ni haga retrabajo; darle primero el trabajo de mayor prioridad.
3. **Subordinar** el resto a la restricción: el sistema marcha a su ritmo (drum-buffer-rope); no adelantar trabajo que solo engorda su cola.
4. **Elevar** la restricción: **proponer** añadir capacidad, re-asignar (si la disciplina lo permite) o desatascar la dependencia que la traba.
5. **Repetir:** al romperse, la restricción se mueve; volver al paso 1 y no dejar que la inercia la fije.

**Frontera:** orquesta gestiona el cuello de botella como fenómeno de **flujo** (secuencia, WIP, subordinación); si elevarlo exige una decisión de **contenido** (arquitectura, contratación, herramienta), la **rutea** al dueño.

## 5. Detección de saturación / ausencia de dueño (sección clave)

Este archivo **operacionaliza para todo el equipo** la señal que dispara el modelo *tiered* T3
de cada agente. Orquesta no juzga el contenido del dominio: observa **señales objetivas de
flujo** y actúa sobre el flujo.

### Señales de dueño SATURADO (objetivas)

| Señal | Indicador medible |
|---|---|
| WIP sobre el límite | Ítems en curso del dueño > límite de WIP acordado |
| Cola de entrada creciente | El backlog aceptado del dueño crece más rápido de lo que cierra |
| Lead time / aging WIP en aumento | Los ítems abiertos envejecen; el lead time promedio sube |
| Ítems estancados | Un ítem sin avance de estado por encima del umbral acordado |

### Señales de dueño AUSENTE

- No responde dentro de la cadencia acordada (→ `cadencia-y-ceremonias.md`).
- Sin capacidad asignable en el horizonte (disponibilidad = 0).

### Qué hace orquesta al detectarlo (decisión de FLUJO, T3 provisional)

1. **Re-secuenciar:** reordena la cola del dueño por prioridad para descongestionar el cuello.
2. **Re-asignar:** mueve el ítem a otro agente con capacidad **solo si la disciplina lo permite**
   (según la matriz y → `orquestacion-y-ruteo.md`).
3. **Aplicar plan por defecto:** activa la ruta de contingencia acordada para no bloquear el
   programa.

Toda acción T3 se marca **"pendiente de ratificación del dueño"** y se registra en el RAID
(→ `gestion-de-riesgos-raid.md`) y en el reporte (→ `comunicacion-y-reporte.md`). Es provisional:
se revierte o confirma cuando el dueño reaparece o descarga.

### Frontera dura (qué NO hace orquesta)

- **Nunca** decide el contenido del dominio saturado: no escribe el código, ni el diseño, ni el
  esquema, ni la prueba, ni la política.
- Si lo que traba el ítem es una **decisión de valor** (escala a tompo), de **arquitectura**
  (eneida), de **pipeline/plataforma** (baluarte) o de **craft** (el dueño de la disciplina),
  orquesta **escala**, no resuelve. La potestad de flujo no es potestad de contenido.

## 6. Tiered META de la asignación

| Nivel | Situación | Acción de orquesta |
|---|---|---|
| T1 | Flujo puro (secuenciar, fijar WIP, balancear carga, reportar capacidad) | Decide y ejecuta directo |
| T2 | La asignación toca el "cómo" del dueño | Co-facilita **con** el dueño; el dueño decide el contenido |
| T3 | Dueño saturado o ausente (sección 5) | Ejerce potestad de flujo provisional, "pendiente de ratificación" |

## 7. Cómo cambia según el estado del proyecto

| Estado | Naturaleza de la capacidad | Foco de la asignación |
|---|---|---|
| **Greenfield** | Incierta; el equipo aún se forma | Estimar rangos, no comprometer; formar disciplinas; validar la matriz; holgura amplia ante lo desconocido |
| **En construcción (in-flight)** | Medida con datos reales (throughput, lead time, aging) | Asignar contra capacidad observada; ajustar WIP con evidencia; balancear cuellos reales |
| **Brownfield** | Comprometida en mantenimiento/soporte/on-call | Descontar la carga recurrente **antes** de asignar; capacidad asignable pequeña; proteger holgura para incidentes (→ `incidentes-y-coordinacion-de-crisis.md`) |

## 8. Fronteras

- Orquesta asigna el **flujo** de trabajo (quién, cuándo, en qué orden, con qué WIP y holgura).
  El **craft** y su "cómo" siguen siendo del dueño de la disciplina.
- Ruteo y desempates de asignación: → `orquestacion-y-ruteo.md`.
- Colaboración entre agentes y handoffs: → `interoperabilidad-y-aliados.md`.
- Equidad, carga justa y ritmo sostenible: → `gobernanza-y-etica.md`.
- Métricas de flujo (throughput, lead time, aging WIP, CFD): → `flujo-y-metricas-de-entrega.md`.

## Checklist rápido

```
CAPACIDAD Y ASIGNACIÓN — verificación de flujo

Capacidad
[ ] Capacidad asignable calculada (nominal − comprometido − mantenimiento − contexto)
[ ] Disponibilidad real de cada dueño en el horizonte confirmada
[ ] Cambio de contexto minimizado (pocos hilos por dueño)

Asignación
[ ] Cada ítem ruteado por DISCIPLINA, no por nombre
[ ] Matriz de disciplinas → dueño respetada
[ ] Carga balanceada hacia el dueño con capacidad asignable

WIP y holgura
[ ] Límite de WIP fijado por dueño y por sistema
[ ] Sistema en modo pull, no push
[ ] Holgura deliberada reservada y defendida (utilización < 100 %)

Saturación / ausencia (T3)
[ ] Señales objetivas monitoreadas (WIP, cola, lead time/aging, estancados)
[ ] Al saturar/ausentarse: re-secuenciar / re-asignar / plan por defecto
[ ] Acción T3 marcada "pendiente de ratificación" y registrada en RAID
[ ] Decisiones de valor/arquitectura/pipeline/craft ESCALADAS, no resueltas
```

## Referencias

- Donald G. Reinertsen, *The Principles of Product Development Flow* (colas, utilización, WIP, holgura).
- David J. Anderson, *Kanban* (límites de WIP, sistemas pull, Little's Law aplicada).
- Eliyahu M. Goldratt, *The Goal* (Theory of Constraints, gestión del cuello de botella).
- Matthew Skelton & Manuel Pais, *Team Topologies* (carga cognitiva como límite de capacidad).
