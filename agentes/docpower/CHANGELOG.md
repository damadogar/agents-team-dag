# Changelog — docpower (Maestro de Documentation Engineering)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.1.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.0.1] — 2026-07-12

### Added
- **`certero` y `peakformance`** añadidos al mapa de SMEs (`gobernanza-y-colaboracion.md`)
  y al roster de fuentes de verdad: certero = SME de correctitud del código (fidelidad de
  comentarios/docstrings/README); peakformance = SME de rendimiento
  (metas/budgets/tuning/SLOs). docpower da la FORMA, ellos el contenido.

### Added (refinamiento QA-2)
- Añadido `baluarte` al roster de SMEs y RACI (runbooks/postmortems/SOPs = contenido de
  baluarte; docpower = forma); `postmortem` añadido al catálogo de documentos; corregida
  la colisión "IA" → "arquitectura de información" en la nota 2 de la RACI.

### Changed (cierre QA-3)
- Retirado el rol fantasma "orquestador mayor" (3 sitios) → "PM de negocio / sponsor (rol
  externo)"; postmortem añadido al catálogo `tipos-de-documento.md` (§17) y a la lista de
  Output #7; añadida cláusula de invocación standalone.

### Notas
- Sin cambio de objetivo (Documentation Engineering).

## [1.0.0] — 2026-07-11

### Added — formalización del versionado (estandarización del equipo)
- Esta **1.0.0** es la **línea base** del agente ya existente: formaliza el versionado
  (antes sin línea de versión ni CHANGELOG), **sin cambio funcional** de su objetivo,
  alcance ni relaciones. docpower ya nombra a sus aliados por handle.

### Fixed
- Se eliminó el **BOM** (marca de orden de bytes) de 8 archivos (`accesibilidad-i18n`,
  `documentacion-producto-fisico`, `documentacion-regulada`, `ejecucion-autonoma`,
  `ejemplos`, `gobernanza-y-colaboracion`, `ia-y-documentacion`, `plantillas`) para
  conformar el estándar de codificación del equipo (operación byte-safe, sin cambio de
  contenido).
