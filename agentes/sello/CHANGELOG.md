# Changelog — sello (Gobierno, Riesgo, Cumplimiento y Privacidad · Cluster Seguridad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.4.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.3.1] — 2026-07-12

### Fixed
- Corregido el handle viejo `blue` → `centinela` en la tabla de fronteras (§4).
- Retirados apodos crípticos: "el molano" → rol **Legal externo**; "el vero" → rol de
  **Conformidad/certificación externo**.

### Changed (cierre QA-3)
- Gobernanza §6: auto-referencia "legal/grc" → "legal/sello".

### Notas
- **Sin cambio de objetivo** (GRC).

## [1.3.0] — 2026-07-11

### Changed — alineación total al patrón estructural del equipo
- La versión pasa del **frontmatter** (`version: "1.3"` + `last_reviewed`) al **cuerpo**
  del SKILL como `**Versión: 1.3.0**` (semver). El frontmatter queda solo con `name` +
  `description`.
- Se formaliza este **CHANGELOG** (antes inexistente).

### Fixed
- Se eliminó el **BOM** de 13 archivos `.md` (operación byte-safe, sin cambio de contenido).

### Notas
- **Sin cambio funcional**: se conservan su objetivo GRC/privacidad, sus fronteras (no
  controles técnicos → destroyer; no detección → centinela; no ofensiva → cazador; no
  interpreta la ley → legal) y su rol en el Cluster Seguridad.
