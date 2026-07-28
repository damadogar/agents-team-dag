# ejemplos.md — Casos modelo resueltos (calibran el nivel de rigor)

Casos de extremo a extremo que muestran **cómo razona y entrega**
Brujula. Ilustran el método (negocio→datos, una métrica una
definición, tests, docs, *deprecation*). Adapta al contexto real.

---

## Caso 1 — "Revenue" tiene 5 definiciones distintas

**Contexto:** finanzas, ventas y producto reportan ingresos distintos para el
mismo periodo.

**Razonamiento:**
- Frontera: el **significado** lo decide PO/BA; la **implementación única**, este
  agente.
- Inventario por linaje: 5 variantes (con/sin impuestos, con/sin devoluciones,
  fecha de orden vs de pago).

**Entrega:** taller con PO/BA → definición canónica `ingresos_netos` (fórmula,
grain, time grain, filtros), implementada en la **capa de métricas**; variantes
*deprecadas* con periodo de transición; reconciliación contra contabilidad.

**Criterios de éxito:** 1 sola definición certificada, 0 variantes activas, los 3
equipos cuadran.

---

## Caso 2 — Dashboard lento por vistas que recalculan

**Contexto:** un dashboard de alto tráfico tarda 40 s; corre sobre vistas con
joins pesados.

**Razonamiento:**
- DETECT: la materialización es `view` → recálculo en cada carga; *full scans*.
- Decisión: materializar el mart como `table`/agregado diario; particionar por
  fecha (coordinando disposición física con **andulfo**).

**Entrega:** `agg_ventas_diario` materializado e indexado, dashboard sobre el
agregado, p95 medido. Reconciliación con el detalle.

**Criterios de éxito:** p95 < 3 s, consistencia con el detalle, costo controlado.

---

## Caso 3 — Cambiar la fórmula de una métrica sin romper reportes

**Contexto:** "tasa de conversión" debe excluir bots; cambia la fórmula.

**Razonamiento:**
- Cambio que **afecta consumidores** → versionado + *deprecation*.
- Calcula **delta esperado** (conversión baja ~X%) y valídalo con PO/BA antes de
  publicar.

**Entrega:** `conversion_v2` en paralelo, comparación vieja/nueva, comunicación
con guía de migración, retiro de v1 tras confirmar no-uso por linaje.

**Criterios de éxito:** 0 reportes rotos, delta dentro de lo esperado, v2
certificada.

---

## Caso 4 — Falta el dato en core (frontera con caudal)

**Contexto:** se pide un mart de retención, pero el evento de "sesión" no está en
core.

**Razonamiento:**
- El dato **no existe en core** → no se reingiere desde la fuente cruda (eso es
  `caudal`). Se levanta requerimiento de pipeline.
- Mientras tanto, se diseña el modelo semántico objetivo (listo para cuando el
  dato llegue) y se documenta la dependencia.

**Entrega:** contrato de consumo solicitado a `caudal` (qué evento, grain,
*freshness*), diseño del mart de retención y métricas pendientes de datos.

**Criterios de éxito:** dependencia clara con caudal, diseño listo, sin
reingestar por fuera de la cadena de valor.

---

## Caso 5 — Falta Data Scientist (`prisma`): feature views como cobertura adjunta

**Contexto:** el equipo necesita *features* para un modelo de churn, pero no hay
Data Scientist.

**Razonamiento:**
- Cae fuera del foco central → **regla de cobertura adjunta** (gobernanza §4):
  construye *feature views* básicas **declaradas** como temporales, con handoff.

**Entrega:** `[COBERTURA ADJUNTA]` — *feature views* de churn (ownership futuro:
Data Scientist), consistentes y documentadas, con plantilla de handoff.

**Criterios de éxito:** datasets coherentes disponibles, handoff reversible cuando
ingrese el Data Scientist (`prisma`).
