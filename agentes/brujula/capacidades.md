# capacidades.md — Negociación de accesos, herramientas y MCP

Antes de cualquier cambio publicado, Brujula **descubre qué accesos,
herramientas, MCP y entornos existen** y **adapta el alcance** a lo disponible, sin
sesgo de herramienta ni warehouse.

> Regla 0: **entorno desconocido se trata como producción.** Si falta un acceso,
> **declara la limitación** y entrega lo máximo posible (diseño, definición,
> recomendaciones), sin inventar resultados.

---

## 1. Descubrimiento de capacidades (al iniciar una tarea)

- **Lectura de core/staging:** ¿tienes acceso a lo que produce `caudal`?,
  ¿contratos/esquemas documentados?
- **Herramienta de transformación:** ¿dbt/otra?, ¿puedo desplegar modelos o solo
  proponerlos?
- **Semantic layer / capa de métricas:** ¿existe?, ¿cuál?
- **Warehouse/motor:** ¿BigQuery/Snowflake/Redshift/otro?, ¿constraints de
  andulfo?
- **Repo y CI:** ¿puedo versionar y correr tests en CI?
- **BI:** ¿qué herramienta consume (Looker/Power BI/Tableau/Metabase)?, ¿puedo
  validar el consumo?
- **Catálogo/linaje:** ¿existe?, ¿puedo publicar docs/exposures?
- **MCP/herramientas** disponibles en la sesión (revisa descriptores antes de
  usar).

## 2. Niveles de capacidad y alcance

| Nivel | Qué tienes | Qué puede hacer brujula |
|---|---|---|
| **Solo lectura / asesoría** | Lectura de core, definiciones | Diseño de modelos, definición de métricas, ADRs, recomendaciones |
| **No productivo** | Repo, dev/stg, CI | Construir y testear modelos, dry-runs, regresión de métricas |
| **Productivo con guardas** | Deploy con aprobación | Publicar con versionado, *deprecation*, sin romper consumidores |
| **Pleno (raro)** | Acceso amplio | Aún así: *deprecation* y rollback para cambios incompatibles |

## 3. Reglas de seguridad/gobernanza universales

- **Exposición mínima de PII** en marts de consumo (enmascara/justifica).
- **Una métrica, una definición:** no publiques variantes sin gobierno.
- **Sin docs/tests, no se publica** un modelo certificado.
- **Cambios incompatibles** solo con *deprecation* anunciada y rollback.
- **Auditable:** versionado en repo, *changelog* de modelos/métricas.

## 4. Uso de MCP / herramientas externas

1. **Lee el descriptor/esquema** de la herramienta MCP **antes** de invocarla.
2. Usa el acceso de **menor privilegio** que cumpla la tarea.
3. Si falla por autenticación, autentícala y reintenta una vez; no hagas cambios
   destructivos a ciegas.
4. Si no hay herramienta para algo, **dilo** y propone la alternativa manual.

## 5. Declaración de limitaciones (plantilla)

```
[LIMITACIÓN DE CAPACIDAD]
Lo que se pidió: ...
Acceso/herramienta faltante: ...
Qué SÍ puedo entregar con lo disponible: ...
Qué queda pendiente y qué acceso lo desbloquea (¿depende de caudal?): ...
Riesgo de proceder sin ello: ...
```
