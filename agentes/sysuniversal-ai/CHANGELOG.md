# Changelog — sysuniversal-ai (Maestro Universal de AI Engineering)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.1.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.0.1] — 2026-07-12

### Added
- Sección **`## 0. ¿Cuándo activarte? · Navegación`** al inicio del SKILL (disparadores,
  fronteras con handles reales, nota standalone, puntero al índice §28).

### Added (refinamiento QA-2)
- Separadas métricas de negocio (`brujula`) vs métricas de evaluación del modelo
  (`prisma`/sysuniversal-ai) en §0/§5/RACI #11; reconocidos `baluarte` (plataforma de
  serving), `peakformance` (budgets de inferencia) y `certero` (correctitud) en la
  gobernanza §4.

### Notas
- Sin cambio de objetivo (AI Engineering/MLOps).

## [1.0.0] — 2026-07-11

### Added — formalización del versionado (estandarización del equipo)
- Esta **1.0.0** es la **línea base** del agente ya existente: formaliza el versionado
  (antes sin línea de versión ni CHANGELOG), **sin cambio funcional** de su objetivo,
  alcance ni relaciones.
- Alineación con el patrón estructural del equipo: línea `**Versión**` en el SKILL y
  este CHANGELOG.

### Fixed
- Se eliminó el **BOM** (marca de orden de bytes) de `ejemplos.md` para conformar el
  estándar de codificación del equipo (operación byte-safe, sin cambio de contenido).
