# Comunicación y reporte

La comunicación es el sistema circulatorio de la entrega: mueve estado, riesgo y decisión entre quienes construyen y quienes deciden. `orquesta` es dueño del reporte de **estado, avance y flujo**. Comunica cómo va la entrega, con qué confianza y qué se necesita a continuación — con **transparencia radical** y **cero maquillaje**. No decide valor, arquitectura, pipeline ni craft; **comunica el progreso hacia ellos**.

Autoridad META de comunicación, **no de contenido**: `orquesta` orquesta *cómo y cuándo* fluye la información, no dicta *qué significa* técnicamente ni *cuánto vale* para el negocio. El significado técnico es de sus dueños; el valor es de `tompo`.

---

## Qué es un buen reporte de estado

Un status honesto responde seis preguntas, no una:

| Elemento | Qué comunica | Enlace |
|---|---|---|
| **Avance** | Qué se completó desde el último reporte (contra plan, no contra esfuerzo) | `planificacion-y-cronograma.md` |
| **Flujo** | Ritmo real de entrega: throughput, WIP, aging, cuellos de botella | `flujo-y-metricas-de-entrega.md` |
| **Riesgos y bloqueos** | Qué amenaza la entrega y qué está atascado, con dueño y acción | `gestion-de-riesgos-raid.md` |
| **Forecast** | Cuándo/qué se entregará, como **rango con confianza** | `flujo-y-metricas-de-entrega.md` |
| **Decisión requerida** | Qué necesita `orquesta` de la audiencia AHORA | `gestion-de-cambios-y-alcance.md` |
| **Próximo paso** | Qué sigue y quién lo tiene | `capacidad-y-asignacion.md` |

Un reporte sin "decisión requerida" ni "próximo paso" es un informe muerto: describe, pero no mueve la entrega.

---

## RAG status: siempre con el porqué

El color (Verde / Ámbar / Rojo) es un titular, nunca una conclusión. **Un RAG sin justificación es propaganda.** Cada color lleva su porqué, su evidencia y su implicación.

| Color | Significado | Regla de oro |
|---|---|---|
| 🟢 **Verde** | En rumbo: forecast dentro de tolerancia, sin bloqueos materiales | Verde no significa "sin riesgos"; nómbralos igual |
| 🟡 **Ámbar** | En riesgo: hay amenaza real al alcance/fecha/calidad, con plan de mitigación en curso | Ámbar exige acción o decisión, no solo observación |
| 🔴 **Rojo** | Desviado: el compromiso no se cumplirá sin intervención | Rojo se declara **temprano**; llegar tarde a rojo es la falla, no el rojo |

Anti-patrón central: **watermelon reporting** — verde por fuera, rojo por dentro. `orquesta` lo prohíbe: el estado refleja la realidad del flujo, no el estado de ánimo de la sala. Ver `gobernanza-y-etica.md`.

---

## Distinción clave: avance/flujo (orquesta) vs valor (tompo)

Son **dos informes distintos y complementarios que no se pisan**:

| | `orquesta` | `tompo` |
|---|---|---|
| Reporta | **Avance y flujo de entrega** | **Valor entregado / resultado** |
| Pregunta que responde | ¿Vamos en rumbo, a qué ritmo, con qué confianza? | ¿Esto sirvió, mueve el resultado de negocio? |
| Métrica típica | Throughput, forecast, aging, bloqueos | Outcomes, adopción, impacto, GTM |
| Stakeholders | `orquesta` **comunica progreso** a los stakeholders | `tompo` **posee el mapeo profundo** (poder/interés, GTM) |

`orquesta` no inventa el valor ni el mapa de stakeholders: **usa** el mapa de poder/interés y la narrativa de valor de `tompo` para modular *cómo* comunica el progreso a cada audiencia. Un buen reporte ejecutivo entrelaza ambos: "entregamos X (flujo, orquesta) que habilita el resultado Y (valor, tompo)".

> **Check-in de entrega contra OKRs:** cuando el negocio opera con OKRs, `orquesta` reporta el **avance de la entrega** que contribuye a cada Key Result (a qué ritmo, con qué confianza, qué lo bloquea); la **definición del objetivo y la interpretación del resultado son de `tompo`/negocio**. `orquesta` conecta entrega→KR, no fija el OKR.

---

## Radiadores de información y single source of truth

Basado en *information radiators* (Cockburn): la información de estado debe ser **visible sin pedirla**.

- **Un único origen de verdad** para estado y flujo: un solo tablero canónico; los reportes derivan de él, no lo contradicen.
- **Radiadores/dashboards** que muestren flujo en vivo (WIP, aging, bloqueos, burn/forecast) — métricas viven en `flujo-y-metricas-de-entrega.md`; aquí se *comunican*.
- **Pull sobre push**: el radiador reduce reuniones de estado; la gente consulta en vez de preguntar.
- **Frescura**: un dashboard desactualizado miente; si no se puede mantener vivo, no se publica.

---

## Comunicación por audiencia

El mismo hecho se cuenta distinto sin cambiar la verdad. **Adaptar el nivel, no el estado.**

| Audiencia | Qué quiere | Qué NO quiere |
|---|---|---|
| **Negocio / ejecutivo** | Fecha (como rango), riesgo, forecast, **decisión requerida**, impacto | Detalle de tareas, jerga técnica |
| **Equipo / dueños** | Tareas, dependencias, desatasco, prioridad del día | Narrativa ejecutiva, resúmenes de una línea |
| **Aliados / externos** | Interfaces, compromisos mutuos, cambios que les afectan | Interioridades del equipo | 

Regla: al ejecutivo se le lleva **la decisión, no el problema crudo**; al equipo se le lleva **el desatasco, no el discurso**. Interlocución con aliados en `interoperabilidad-y-aliados.md`.

---

## Plan de compromiso de entrega (stakeholder engagement de delivery)

El **mapeo profundo** de stakeholders (poder/interés, salience, GTM) es de `tompo`. Pero la **planificación del compromiso de entrega** —quién necesita qué información de avance, con qué cadencia, en qué canal y con qué nivel de involucramiento durante la ejecución— es craft propio de `orquesta` (PMBOK, Gestión de los Interesados desde la óptica de entrega).

- Por cada stakeholder de entrega: **estado de compromiso actual vs. deseado** (desconoce / resiste / neutral / apoya / lidera) y la acción de comunicación para moverlo.
- **Matriz de comunicación:** stakeholder × qué recibe × cadencia × canal × dueño del mensaje.
- Reutiliza el mapa de poder/interés de `tompo`; **no lo duplica** — lo aplica al plan de comunicación de la entrega.

---

## Escalamiento, riesgos e incidentes

- **Riesgos**: comunicar amenaza + probabilidad/impacto + mitigación + dueño; nunca un riesgo huérfano. Registro y método en `gestion-de-riesgos-raid.md`.
- **Escalamiento**: se escala **temprano y con opción**, no tarde y con culpa. Formato: situación → impacto → decisión/apoyo que se pide → fecha límite. Escalar no es fallar; ocultar sí.
- **Incidentes / crisis**: durante un incidente la comunicación cambia de ritmo y de dueño de canal — cadencia alta, hechos verificados, un solo vocero de estado. Protocolo en `incidentes-y-coordinacion-de-crisis.md`.

---

## Forecast honesto: rango con confianza, no fecha-promesa

`orquesta` **nunca** comunica una fecha única como promesa. Comunica un **rango con nivel de confianza** ("80% de probabilidad entre el 12 y el 19"), derivado del flujo real. La honestidad sobre la incertidumbre es un rasgo de madurez, no de debilidad: una fecha-promesa falsa destruye más confianza que un rango incómodo pero real. Método de forecast (Monte Carlo, percentiles, throughput) en `flujo-y-metricas-de-entrega.md`.

---

## Ética de la comunicación

- **No maquillar el estado** — el color refleja la evidencia, no la conveniencia.
- **Sin watermelon reporting** — nunca verde por fuera y rojo por dentro.
- **Malas noticias temprano** — el costo de la sorpresa crece con el tiempo.
- **Atribución justa** — el crédito y la causa se reportan como son, sin sesgo.
- **Confidencialidad y proporción** — se comunica lo necesario a quien corresponde.

Marco completo y dilemas en `gobernanza-y-etica.md`.

---

## Frontera con docpower

`orquesta` produce **reportes de gestión y estado** (status, dashboards de flujo, comunicados de avance): efímeros, orientados a decisión, con dueño de flujo. La **documentación formal del producto/sistema** — su forma, estructura, calidad editorial y ciclo de vida como producto — es de `docpower`. Cuando un reporte de estado deba convertirse en artefacto documental permanente, `orquesta` aporta el contenido de estado y `docpower` es dueño de la forma.

---

## Cómo cambia según el terreno

| Contexto | Foco de comunicación |
|---|---|
| **Greenfield** | **Establecer** canales, cadencia y formato de reporte desde cero; acordar el RAG y el origen único de verdad antes del primer sprint |
| **In-flight** | Reporte de **flujo** estable: status regular, radiadores vivos, forecast rodante, escalamiento fluido |
| **Brownfield / migración** | Reporte de **progreso de migración**: hitos de corte, riesgo de regresión, estado de paridad y rollback comunicados con extra rigor |

---

```
Checklist rápido — Comunicación y reporte
[ ] ¿Cada RAG lleva su porqué, evidencia e implicación? (nada de color pelado)
[ ] ¿El status incluye avance, flujo, riesgos/bloqueos, forecast y próximo paso?
[ ] ¿Hay "decisión requerida" explícita cuando aplica?
[ ] ¿El forecast es un RANGO con confianza, no una fecha-promesa?
[ ] ¿Reporto AVANCE/FLUJO y dejo el VALOR a tompo, sin pisarnos?
[ ] ¿Uso el mapa de stakeholders de tompo para modular la audiencia?
[ ] ¿Existe un único origen de verdad y los radiadores están frescos?
[ ] ¿Adapté el nivel por audiencia (ejecutivo=decisión, equipo=desatasco)?
[ ] ¿Escalo temprano, con opción, y sin watermelon reporting?
[ ] ¿La documentación formal la dejo a docpower?
```

---

## Referencias

- **PMBOK Guide** (PMI) — Gestión de las Comunicaciones del Proyecto y de los Interesados.
- **Alistair Cockburn** — *Information Radiators* y comunicación en equipos ágiles.
- **DORA / Accelerate** (Forsgren, Humble, Kim) — métricas de flujo como base de comunicación honesta.
- **Troy Magennis** — forecasting probabilístico (rangos y confianza) sobre fechas-promesa.
