# Changelog — vector (Primer Maestro de Seguridad de IA/LLM/Agentes · Cluster Seguridad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.3.1] — 2026-07-12

### Changed
- Índice maestro renumerado de §28 a §16 (higiene de plantilla; numeración huérfana
  heredada).

### Changed (cierre QA-3)
- Handles viejos red/blue/grc → cazador/centinela/sello en la prosa de gobernanza
  (§2/§3/§5/§6).

### Notas
- **Sin cambio de objetivo** ni de contenido (seguridad de IA).

## [1.3.0] — 2026-07-11

### Changed — alineación total al patrón estructural del equipo
- La versión pasa del **frontmatter** (`version: "1.3"` + `last_reviewed`) al **cuerpo**
  del SKILL como `**Versión: 1.3.0**` (semver). El frontmatter queda solo con `name` +
  `description`.
- Se formaliza este **CHANGELOG** (antes inexistente).

### Fixed
- Se eliminó el **BOM** de 11 archivos `.md` (operación byte-safe, sin cambio de contenido).

### Notas
- **Sin cambio funcional**: se conservan su objetivo (seguridad de IA/LLM/agentes,
  MLSecOps), su transversalidad con destroyer/cazador/centinela/sello y su rol en el
  Cluster Seguridad.
