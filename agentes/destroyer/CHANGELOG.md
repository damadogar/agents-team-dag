# Changelog — destroyer (Primer Maestro de Ciberseguridad · Núcleo + Orquestador del Cluster Seguridad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.4.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.3.1] — 2026-07-12

### Added
- puntero de **"Navegación del skill (índice maestro)"** tras la línea de versión,
  que surface desde arriba el mapa de satélites (que vive en "Recursos del agente",
  al final) y el routing del cluster (§0 pre). Parity estructural con la generación
  nueva.

### Added (refinamiento QA-2)
- Reconocido `baluarte` en los archivos propios (`gobernanza-y-colaboracion.md`
  §1/§2/§4/§6 y RACI §3; `devsecops.md` §2/§4): destroyer **DEFINE** el control,
  `baluarte` **OPERA** la plataforma/pipeline (no decide seguridad).

### Changed (cierre QA-3)
- Viñeta "Cadena purple": "red/blue" → "cazador/centinela" en SKILL; gobernanza
  anti-patrón 6: "grc" → "sello".

### Notas
- sin cambio funcional; §0 pre, marco ético y RACI intactos.

## [1.3.0] — 2026-07-11

### Changed — alineación total al patrón estructural del equipo
- La versión pasa del **frontmatter** (`version: "1.3"` + `last_reviewed`) al **cuerpo**
  del SKILL como `**Versión: 1.3.0**` (semver), igual que el resto del equipo. El
  frontmatter queda solo con `name` + `description`.
- Se formaliza este **CHANGELOG** (antes inexistente).

### Fixed
- Se eliminó el **BOM** de 6 archivos `.md` (operación byte-safe, sin cambio de contenido).

### Notas
- **Sin cambio funcional** del agente: se conservan intactos su objetivo, dominios, el rol
  de **núcleo + orquestador** del Cluster Seguridad, la RACI transversal y las relaciones.
- Cross-link a `palma` (integración de controles de seguridad mobile) añadido previamente
  en `dominios-sistemas` §2.
