# metricas.md — Definición y gobierno de métricas y KPIs

El corazón del rol: **una métrica, una definición.** Brujula consolida
las definiciones de negocio en una **capa de métricas** gobernada, eliminando las
variantes ad-hoc que producen reportes contradictorios.

Ver [SKILL.md](SKILL.md) §12. El **significado de negocio** lo aprueba PO/BA; la
**implementación técnica** la posee brujula
([gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §6.4).

---

## 1. Anatomía de una métrica

Toda métrica certificada define, como mínimo:

| Atributo | Descripción |
|---|---|
| **Nombre** | Único, legible, sin ambigüedad (`ingresos_netos`) |
| **Definición de negocio** | Qué significa, en lenguaje de negocio (aprobada por PO/BA) |
| **Fórmula** | Cálculo exacto (`sum(monto) - sum(descuentos) - sum(devoluciones)`) |
| **Grain / nivel** | A qué nivel es válida (orden, cliente, día) |
| **Dimensiones válidas** | Por qué se puede desglosar (fecha, región, producto) |
| **Filtros base** | Exclusiones inherentes (ej.: excluye pedidos de prueba) |
| **Time grain** | Día/semana/mes; cómo se agrega en el tiempo |
| **Owner** | Responsable de la definición |
| **Estado** | Propuesta · Certificada · Deprecada |

## 2. Tipos de métricas

- **Simple / aditiva:** se suma en todas las dimensiones (unidades vendidas).
- **No aditiva:** no se suma en alguna dimensión (precio promedio, ratios).
- **Semi-aditiva:** aditiva en unas dimensiones pero no en el tiempo (saldos,
  inventario → usar último valor del periodo).
- **Derivada / ratio:** combinación de otras métricas (margen %, conversión).
- **Acumulada / running:** *running total*, MTD/QTD/YTD.
- **Time intelligence:** crecimiento MoM/YoY, *period over period*.

> Las **no aditivas** y los **ratios** son la fuente #1 de errores: define el
> orden de agregación (¿promedio de ratios o ratio de sumas?).

## 3. Capa de métricas / semantic layer

- **Idea:** define la métrica **una vez**; cualquier BI/herramienta la consume
  consistente, sin re-implementar el SQL.
- **Herramientas (sin sesgo):** dbt Semantic Layer / MetricFlow, Cube, LookML u
  otra. Elige por ecosistema, no por moda.
- **Beneficio:** evita que "ingresos" tenga 5 definiciones distintas en 5
  dashboards.
- **Implementación sin semantic layer dedicado:** centraliza las métricas en
  modelos `marts`/`metrics` versionados y prohíbe el cálculo ad-hoc en BI.

## 4. Gobierno de métricas (ciclo de vida)

```
Propuesta (alguien necesita una métrica)
   ▼ definición de negocio (PO/BA aprueba el significado)
   ▼ implementación técnica (brujula: fórmula, grain, tests)
   ▼ Certificada (documentada, testeada, publicada en el catálogo)
   ▼ Deprecación (anunciada, con periodo de transición y reemplazo)
```

- **Certificación:** una métrica certificada tiene definición única, *owner*,
  tests y documentación.
- **Catálogo de métricas:** inventario navegable; marca certificadas vs
  experimentales.
- **Versionado:** cambiar una fórmula es un **cambio que afecta consumidores** →
  versión + *deprecation* (ver [ejecucion.md](ejecucion.md)).

## 5. Consolidación de métricas duplicadas (remediación)

Cuando existen definiciones divergentes ("revenue" con variantes):

1. **Inventaria** todas las variantes y dónde se usan (linaje/*exposures*).
2. **Reúne a PO/BA** para decidir la **definición canónica**.
3. **Implementa** la métrica única en la capa; mapea las variantes.
4. **Deprecación** de las variantes con comunicación y periodo de transición.
5. **Verifica** que los dashboards migran a la métrica canónica.

## 6. Tests y validación de métricas

- **Reconciliación:** la métrica cuadra contra una fuente autoritativa o el
  detalle (suma del detalle = total del agregado).
- **Sanity checks:** rangos esperados, no-negatividad, continuidad temporal.
- **Tests de no-duplicación:** *grain* correcto (un OBT mal modelado infla sumas).
- **Pruebas de regresión:** al cambiar una definición, compara resultados antes/
  después y documenta el delta esperado.

## 7. Reglas de oro de métricas

1. **Una métrica, una definición** — fuente única de verdad.
2. **El significado lo aprueba el negocio (PO/BA); la fórmula la garantiza tú.**
3. **Documenta la definición** o la métrica no se certifica.
4. **Cuida agregaciones no aditivas y ratios** (orden de cálculo).
5. **Cambiar una fórmula = cambio con versionado y *deprecation*.**
6. **Prohíbe cálculos ad-hoc** de métricas críticas en el BI; viven en la capa.
