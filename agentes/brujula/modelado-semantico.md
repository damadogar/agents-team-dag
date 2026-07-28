# modelado-semantico.md — Modelado dimensional y de consumo

Guía de **modelado semántico** de Brujula: cómo convertir conceptos de
negocio en estructuras de datos legibles y reutilizables para consumo, con
**neutralidad tecnológica total**. El modelo de datos **sigue al modelo de
negocio**, no al revés.

Ver [SKILL.md](SKILL.md) §3, §10, §11. Consume staging/core de `caudal`
(ver [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md) §6.1).

---

## 1. Capas de la transformación analítica

```
core / conformed (de caudal)
   ▼ staging (renombrado, casteo, limpieza ligera; 1:1 con la fuente)
   ▼ intermediate (lógica reutilizable, joins, cálculos intermedios)
   ▼ marts (consumo por dominio: finanzas, ventas, producto…)
        ├─ hechos (fact_*)
        ├─ dimensiones (dim_*)
        └─ wide tables / agregados (obt_*, agg_*)
```

- **staging** no contiene lógica de negocio; normaliza nombres/tipos.
- **intermediate** evita repetir lógica (DRY).
- **marts** es la cara visible para BI/analistas/DS.

## 2. Modelado dimensional (Kimball)

### 2.1 Conceptos

- **Tabla de hechos (fact):** eventos/medidas de negocio (ventas, sesiones,
  pagos). Tiene **grain** explícito (el nivel de detalle de una fila).
- **Dimensión (dim):** contexto descriptivo (cliente, producto, fecha,
  geografía). Atributos por los que se filtra/agrupa.
- **Grain:** decláralo **antes** de modelar ("una fila por línea de orden"). Es la
  decisión más importante del hecho.
- **Bus matrix:** matriz procesos de negocio × dimensiones conformadas; guía la
  reutilización.

### 2.2 Tipos de hechos

| Tipo | Descripción | Ejemplo |
|---|---|---|
| **Transaccional** | Una fila por evento | una venta |
| **Periodic snapshot** | Estado a intervalos regulares | saldo diario |
| **Accumulating snapshot** | Ciclo de vida de un proceso | orden: creada→enviada→entregada |
| **Factless** | Evento sin medida (registro de ocurrencia) | asistencia, elegibilidad |

### 2.3 Dimensiones lentas (SCD)

| SCD | Comportamiento | Cuándo |
|---|---|---|
| **Tipo 1** | Sobrescribe (sin historia) | Corrección de datos, no importa el pasado |
| **Tipo 2** | Nueva fila con `valid_from/valid_to` | Historizar cambios (precio, segmento) |
| **Tipo 3** | Columna "valor anterior" | Pocos cambios, comparación puntual |

> SCD2 se implementa con **snapshots** (ver
> [transformaciones.md](transformaciones.md)).

## 3. Wide tables / OBT (One Big Table)

- **Qué es:** una tabla desnormalizada que junta hechos + atributos de dimensión
  para *self-service* y performance de lectura.
- **Cuándo:** dashboards de alto tráfico, usuarios no técnicos, motores columnar
  (BigQuery/Snowflake) donde los joins son caros o el *self-service* lo pide.
- **Riesgos:** duplicación, *grain* implícito, mantenimiento; documenta el grain y
  evita mezclar granularidades.

## 4. Estrella vs copo de nieve vs OBT — decisión

| Criterio | Estrella | Copo de nieve | OBT / wide |
|---|---|---|---|
| Legibilidad para usuario | Alta | Media | Muy alta |
| Reutilización (dims conformadas) | Alta | Alta | Baja |
| Performance de lectura | Buena | Media (más joins) | Muy buena |
| Mantenimiento | Medio | Alto | Medio/Alto (duplicación) |
| Riesgo de inconsistencia | Bajo | Bajo | Medio (grain implícito) |

> Regla: **estrella por defecto** para gobierno y reutilización; **OBT** para
> *self-service*/performance cuando el caso lo justifica.

## 5. Convenciones de modelado

- **Naming:** `stg_<fuente>__<entidad>`, `int_<dominio>__<paso>`,
  `dim_<entidad>`, `fct_<proceso>`, `obt_<dominio>`, `agg_<dominio>_<grano>`.
- **Claves:** *surrogate keys* en dimensiones; claves de negocio documentadas.
- **Tipos y nulos:** explícitos; sin "magic strings".
- **Una responsabilidad por modelo:** modelos pequeños y componibles > monolitos.
- **Idempotencia y reconstrucción:** todo modelo se reconstruye desde core.

## 6. Mapeo negocio → datos (método)

1. **Entiende el proceso de negocio** (ej.: "ciclo de una orden").
2. **Identifica eventos medibles** → hechos; y el **grain** de cada uno.
3. **Identifica el contexto** (quién/qué/cuándo/dónde) → dimensiones.
4. **Define métricas** sobre los hechos (ver [metricas.md](metricas.md)).
5. **Reutiliza** dimensiones conformadas (bus matrix); no dupliques.
6. **Documenta** grain, supuestos y *owner* (ver
   [documentacion.md](documentacion.md)).

## 7. Diagrama de ejemplo (esquema estrella)

```mermaid
flowchart TD
  FCT[fct_ventas\n(grain: línea de orden)]
  DIMC[dim_cliente]
  DIMP[dim_producto]
  DIMF[dim_fecha]
  DIMT[dim_tienda]
  DIMC --> FCT
  DIMP --> FCT
  DIMF --> FCT
  DIMT --> FCT
```

## 8. Anti-patrones que brujula bloquea

- **Grain ambiguo o mixto** en una tabla de hechos.
- **Dimensiones no conformadas** (cada mart con su propia "dim_cliente").
- **Lógica de negocio duplicada** en vez de modelos *intermediate* reutilizables.
- **Modelar contra fuentes crudas** saltándose staging/core (frontera con
  caudal).
- **OBT sin documentar el grain** → métricas infladas por duplicación.
- **Métricas calculadas ad-hoc** en cada dashboard en vez de en la capa (ver
  [metricas.md](metricas.md)).
