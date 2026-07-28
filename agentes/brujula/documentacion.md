# documentacion.md — Documentación, diccionario, discoverability y linaje

**Sin documentación, no hay modelo.** Brujula trata la documentación
como **parte del entregable**, no como un extra: un modelo o métrica sin docs no se
certifica ni se publica.

Ver [SKILL.md](SKILL.md) §14.

---

## 1. Qué se documenta (mínimo por modelo)

| Elemento | Contenido |
|---|---|
| **Modelo** | Propósito, *grain*, dominio, *owner*, *freshness* |
| **Cada columna** | Descripción, tipo, dominio de valores, si es PII |
| **Métricas** | Definición de negocio, fórmula, grain, dimensiones válidas (ver [metricas.md](metricas.md)) |
| **Supuestos** | Reglas de negocio aplicadas, exclusiones, casos borde |
| **Dependencias** | De qué modelos de core/staging depende (linaje) |
| **Consumidores** | Dashboards/reportes/modelos que lo usan (*exposures*) |

## 2. Diccionario de datos

- Inventario navegable de modelos, columnas y métricas con su descripción y
  *owner*.
- **Single source of truth** de significados: el negocio busca aquí antes de
  reinventar una métrica.
- Marca **certificado** vs **experimental** para que el usuario sepa en qué
  confiar.

## 3. Discoverability

- **Catálogo navegable** (docs generadas, catálogo de datos): búsqueda por
  concepto de negocio, no solo por nombre técnico.
- **Exposures:** liga modelos/métricas a los dashboards y consumidores que los
  usan → análisis de impacto antes de cambiar.
- **Tags/dominios:** organiza por área de negocio (finanzas, ventas, producto).

## 4. Linaje

- **A nivel de modelo:** grafo de dependencias staging → intermediate → marts.
- **A nivel de columna** (cuando la herramienta lo permite): de dónde viene cada
  campo y a dónde fluye.
- **Uso:** análisis de impacto ("¿qué dashboards se rompen si cambio esta
  columna?"), cumplimiento (dónde llega la PII) y depuración de incidentes.
- Estándares/herramientas: OpenLineage, catálogo del warehouse, docs del semantic
  layer (sin sesgo de herramienta).

## 5. Documentación como código

- Las descripciones viven **junto al modelo** (YAML/metadata versionada), no en un
  wiki desconectado que envejece.
- **CI valida** que los modelos/columnas críticos tengan descripción (test de
  cobertura de docs).
- Se **regenera y publica** el catálogo en cada *deploy*.

## 6. Comunicación con consumidores

- **Changelog** de modelos/métricas: qué cambió, por qué y desde cuándo.
- **Deprecation notices:** anticipa cambios que afectan dashboards (ver
  [ejecucion.md](ejecucion.md)).
- **Onboarding:** una página de "cómo usar esta capa" para analistas nuevos.

## 7. Reglas de oro de documentación

1. **Sin docs, no hay modelo certificado.**
2. **Documenta el porqué y el grain,** no solo el qué.
3. **Linaje + exposures** antes de cambiar algo (análisis de impacto).
4. **Diccionario único:** el negocio consulta ahí; no se inventan métricas.
5. **Docs como código:** versionadas, validadas en CI, regeneradas al desplegar.
