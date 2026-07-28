# calidad.md — Calidad, fiabilidad y observabilidad del dato

Cómo Caudal garantiza que el dato que entrega sea **correcto, completo, a
tiempo y trazable**. La regla rectora: **"el pipeline corrió en verde" ≠ "el dato
es correcto"**. Se valida el **dato**, no solo el job.

Ver [pipelines.md](pipelines.md) §6 (errores/cuarentena) y [SKILL.md](SKILL.md) §13.

---

## 1. Dimensiones de calidad de datos (DQ)

| Dimensión | Pregunta | Ejemplo de test |
|---|---|---|
| **Completitud** | ¿Faltan registros/campos? | `not_null`, *row count* esperado vs origen |
| **Unicidad** | ¿Hay duplicados? | `unique` en clave de negocio |
| **Validez** | ¿Cumple formato/rango/dominio? | regex, *accepted values*, rangos |
| **Consistencia** | ¿Coincide entre sistemas/capas? | reconciliación origen↔destino |
| **Exactitud** | ¿Refleja la realidad? | cruce con fuente autoritativa |
| **Oportunidad** (*timeliness*) | ¿Llegó dentro del SLA? | *freshness* < umbral |
| **Integridad referencial** | ¿FKs lógicas válidas? | *relationships* entre tablas |

## 2. Tests automáticos de datos

- **Herramientas:** dbt tests, Great Expectations, Soda, *custom asserts* en el
  orquestador (elige por stack, sin sesgo).
- **Ubicación:** en CI (sobre muestras/datos sintéticos) y en runtime (sobre la
  carga real, como *gate*).
- **Severidad:** test crítico **falla el pipeline** o envía a **cuarentena**; test
  no crítico genera *warning* y alerta.
- **Cobertura objetivo:** 100% de datasets críticos con tests de completitud,
  unicidad y *freshness* como mínimo.

## 3. Reconciliación origen↔destino

- **Conteos:** filas por partición/rango origen vs destino tras cada carga.
- **Checksums / sumas de control:** sobre columnas clave (especialmente importes
  en dominios financieros — cuadre exacto).
- **Muestreo:** comparación de registros muestreados para exactitud.
- **Tolerancias:** define umbrales aceptables y alerta al excederlos.

## 4. Cuarentena de rechazos

- Filas inválidas → **tabla/zona de rechazos** con: motivo, regla violada,
  *timestamp*, *batch id*. **Nunca** se descartan en silencio.
- Proceso de **remediación**: corregir en origen o regla, reprocesar el rango.
- Métrica: tasa de rechazo por dataset (tendencia y alerta ante picos).

## 5. Observabilidad del dato (data observability)

Más allá de la infra: vigila el **dato mismo**. Pilares:

| Pilar | Señal | Alerta cuando… |
|---|---|---|
| **Freshness** | ¿Llegó a tiempo? | supera el SLA de actualización |
| **Volumen** | ¿El conteo es el esperado? | cae/sube fuera de banda |
| **Distribución** | ¿Nulos/rangos/cardinalidad normales? | *drift* estadístico |
| **Esquema** | ¿Cambió la estructura? | *schema drift* no anunciado |
| **Linaje** | ¿De dónde viene y a qué afecta? | análisis de impacto |

- **MTTD/MTTR de datos:** mide tiempo de **detección** y **resolución** de
  incidentes de datos (*data downtime*), no solo de servidores.
- **Herramientas:** dbt *exposures*, Great Expectations/Soda, Monte Carlo,
  OpenLineage/Marquez para linaje.

## 6. Catálogo y linaje

- **Catálogo:** inventario de datasets con esquema, *owner*, clasificación
  (PII/PCI/PHI), descripción y nivel de calidad/SLA.
- **Linaje columna-a-columna:** trazabilidad de origen a consumo; clave para
  análisis de impacto y cumplimiento (OpenLineage/Marquez, catálogos cloud).
- **Metadatos activos:** el catálogo alimenta gobierno, búsqueda y políticas (no
  es documentación muerta).

## 7. SLAs / SLOs de datos

| Indicador | Tipo | Objetivo de referencia |
|---|---|---|
| *Freshness* dentro de SLA | SLO | ≥ objetivo por dataset |
| Tasa de éxito de cargas | KPI | ≥ 99% |
| Cobertura de tests de datos | KPI | 100% en datasets críticos |
| *Data downtime* (MTTD/MTTR) | KPI | Tendencia a la baja |
| Tasa de rechazo (cuarentena) | SLI | < umbral por dataset |
| Incidentes de dato incorrecto en consumo crítico | KPI | 0 |

## 8. Reglas de oro de calidad

1. **Calidad como *gate*:** datos que fallan DQ crítico no avanzan a *gold*/consumo.
2. **Falla ruidosa, no silenciosa:** mejor frenar y alertar que entregar dato malo.
3. **Reconcilia siempre** en dominios con cuadre obligatorio (finanzas, regulado).
4. **Observa el dato y el job:** verde operativo no garantiza dato correcto.
5. **Cada incidente de datos** genera postmortem y un test que lo prevenga a futuro
   (ver [runbooks.md](runbooks.md)).
