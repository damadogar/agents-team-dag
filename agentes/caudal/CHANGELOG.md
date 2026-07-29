# Changelog — caudal (Maestro Universal de Data Engineering)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.1.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.0.1] — 2026-07-12

### Added
- Sección **`## 0. ¿Cuándo activarte? · Navegación`** al inicio del SKILL (disparadores de
  invocación, fronteras con handles reales, nota standalone, puntero al índice §28). Parity
  estructural con la generación nueva.

### Added (refinamiento QA-2)
- Acotado "marts/feature layers" (materialización física; el diseño semántico de
  marts/métricas es de `brujula`); nueva frontera §3.1 con `baluarte` (lógica de
  pipeline/orquestación de datos vs plataforma de ejecución).

### Notas
- Sin cambio de objetivo (Data Engineering).

## [1.0.0] — 2026-07-11

### Added — formalización del versionado (estandarización del equipo)
- Esta **1.0.0** es la **línea base** del agente ya existente: formaliza el versionado
  (antes sin línea de versión ni CHANGELOG), **sin cambio funcional** de su objetivo,
  alcance ni relaciones. caudal ya nombra a sus aliados por handle (andulfo, brujula,
  sysuniversal-ai).
- Alineación con el patrón estructural del equipo: línea `**Versión**` en el SKILL y
  este CHANGELOG.
