# transformaciones.md — Materializaciones, tests y performance de consumo

Cómo Brujula implementa la capa semántica como **código** sobre
staging/core: estrategias de materialización, snapshots (SCD2), tests de calidad y
optimización de las queries de consumo, con **neutralidad de herramienta** (dbt u
otra). Toda transformación es **reproducible desde core**.

Ver [SKILL.md](SKILL.md) §13. Ejecución segura de cambios en
[ejecucion.md](ejecucion.md).

---

## 1. Estrategias de materialización

| Materialización | Qué hace | Cuándo | Riesgos |
|---|---|---|---|
| **view** | Vista (cómputo en cada consulta) | Lógica ligera, datos frescos, bajo tráfico | Costo recurrente, lento en dashboards pesados |
| **table** | Materializa toda la tabla en cada corrida | Lectura frecuente, lógica costosa | Recalcula todo; costo si es grande |
| **incremental** | Solo procesa filas nuevas/cambiadas | Hechos grandes que crecen | Clave única, *late-arriving data*, *full-refresh* ocasional |
| **ephemeral** | CTE inyectada en modelos hijos (no persiste) | Lógica intermedia reutilizable y ligera | No consultable directamente |
| **materialized view** | MV del motor (si lo soporta) | Agregados refrescados por el motor | Soporte/coste según motor (coordinar con andulfo) |

> Regla: **lo más simple que cumpla freshness y performance.** Empieza en `view`;
> sube a `table`/`incremental` cuando el costo/latencia lo justifique.

## 2. Modelos incrementales (buenas prácticas)

- **Clave única** declarada para *merge*/*upsert* idempotente.
- **Filtro incremental** por columna de evento (`event_time > max(...)`), con
  margen para *late-arriving data*.
- **Estrategia:** `merge` (upsert) vs `insert+overwrite` por partición; elige
  según motor y patrón.
- **Full-refresh** periódico o ante cambios de lógica (la corrida incremental no
  recalcula el pasado).
- **Idempotencia:** reejecutar no duplica (clave única + partición reemplazable).

## 3. Snapshots (SCD2)

- Captura el estado de una dimensión en el tiempo con `valid_from` / `valid_to` /
  *flag* de vigente.
- **Estrategia de cambio:** por `updated_at` (timestamp) o por *check* de columnas.
- **Cuidado con:** *deletes* en la fuente, cambios masivos retroactivos, tamaño
  creciente.
- Base del **SCD Tipo 2** del modelado (ver
  [modelado-semantico.md](modelado-semantico.md) §2.3).

## 4. Tests de calidad de la capa

| Test | Qué valida |
|---|---|
| `not_null` | Columnas obligatorias presentes |
| `unique` | Clave del modelo sin duplicados (protege el *grain*) |
| `relationships` | Integridad referencial hacia dimensiones |
| `accepted_values` | Dominios cerrados (estados, categorías) |
| *singular tests* | Reglas de negocio específicas (SQL que no debe devolver filas) |
| reconciliación | Totales del mart = totales del detalle/core |

- **Severidad:** crítico → falla el *build* y bloquea el *deploy*; no crítico →
  *warn* + alerta.
- **Cobertura objetivo:** 100% en modelos de consumo críticos (al menos `unique`,
  `not_null`, `relationships`).
- **CI:** corre tests sobre el grafo de modelos antes de *merge*.

## 5. Performance de queries de consumo

- **Materializa lo caliente:** dashboards de alto tráfico sobre `table`/agregados,
  no sobre vistas que recalculan.
- **Agregados / rollups:** pre-calcula granularidades comunes (diario por región);
  mantén consistencia con el detalle.
- **Particiones y *clustering*** de las tablas de consumo por la columna de filtro
  más común (fecha) — coordinar disposición física con **andulfo**.
- **Evita** `SELECT *`, joins innecesarios y *full scans* en dashboards.
- **Mide:** p95 de las queries de los dashboards clave; optimiza las peores.

## 6. Estructura del proyecto (transformación como código)

```
models/
  staging/      stg_<fuente>__<entidad>      (1:1 con la fuente, sin lógica)
  intermediate/ int_<dominio>__<paso>        (lógica reutilizable)
  marts/        dim_*, fct_*, obt_*, agg_*   (consumo por dominio)
  metrics/      definiciones de métricas (semantic layer)
snapshots/      SCD2
tests/          singular tests
docs/           descripciones, exposures
```

- **DRY:** lógica común en `intermediate`/macros, no copiada.
- **Versionado** en repo; revisión por PR; *lineage* del grafo.

## 7. Reglas de oro de transformación

1. **Reproducible desde core:** nunca dependas de estado manual.
2. **Idempotente:** reejecutar no duplica ni corrompe.
3. **Tests como *gate*:** sin tests verdes no se publica.
4. **La más simple que cumpla** freshness y performance.
5. **Coordina disposición física** (particiones/índices/MV) con andulfo.
6. **No reingieras fuentes crudas:** consumes staging/core de caudal.
