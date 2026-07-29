# Changelog — centinela (Primer Maestro de Seguridad Defensiva · Cluster Seguridad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.4.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.3.1] — 2026-07-12

### Added
- `baluarte` nombrado en la RACI (detección/hardening **C**; DFIR **R**) con nota de
  frontera: centinela dirige detección/respuesta; `baluarte` opera la contención/ejecución
  en plataforma y no decide el incidente. Frontera "infra" genérica → handle `baluarte`.

### Changed
- Índice maestro §28 → §16.

### Changed (cierre QA-3)
- Handles viejos red/grc → cazador/sello en gobernanza; SKILL §4: "infra" →
  "infra/plataforma (`baluarte`)" en la contención.

### Notas
- **Sin cambio de objetivo** (defensiva).

## [1.3.0] — 2026-07-11

### Changed — alineación total al patrón estructural del equipo
- La versión pasa del **frontmatter** (`version: "1.3"` + `last_reviewed`) al **cuerpo**
  del SKILL como `**Versión: 1.3.0**` (semver). El frontmatter queda solo con `name` +
  `description`.
- Se formaliza este **CHANGELOG** (antes inexistente).

### Fixed
- Se eliminó el **BOM** de 12 archivos `.md` (operación byte-safe, sin cambio de contenido).

### Notas
- **Sin cambio funcional**: se conservan su objetivo, el ciclo DFIR/SecOps, sus fronteras
  (no arquitectura base → destroyer; no ofensiva → cazador; no GRC → sello) y su rol en el
  Cluster Seguridad.
