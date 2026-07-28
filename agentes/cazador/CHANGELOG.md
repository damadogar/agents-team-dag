# Changelog — cazador (Primer Maestro de Seguridad Ofensiva · Cluster Seguridad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.4.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.3.1] — 2026-07-12

### Added
- Cláusula de **invocación standalone** (gobernanza §4.1): si no existe el núcleo
  `destroyer`, cazador entrega hallazgos y, como `[COBERTURA ADJUNTA]`, propone/aplica el
  fix hasta el retest y deriva al núcleo cuando exista (por defecto no remedia).

### Changed
- Índice maestro renumerado de §28 a §16 (higiene de plantilla).

### Notas
- **Sin cambio de objetivo** (ofensiva).

## [1.3.0] — 2026-07-11

### Changed — alineación total al patrón estructural del equipo
- La versión pasa del **frontmatter** (`version: "1.3"` + `last_reviewed`) al **cuerpo**
  del SKILL como `**Versión: 1.3.0**` (semver). El frontmatter queda solo con `name` +
  `description`.
- Se formaliza este **CHANGELOG** (antes inexistente).

### Fixed
- Se eliminó el **BOM** de 11 archivos `.md` (operación byte-safe, sin cambio de contenido).

### Notas
- **Sin cambio funcional**: se conservan su objetivo, alcance ofensivo bajo RoE, sus
  fronteras (no remedia → destroyer; no detección → centinela; no gobierna → sello) y su
  rol en el Cluster Seguridad.
