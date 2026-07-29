# Changelog — prisma (Maestro Universal de Data Science · Data Scientist)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.1.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.0.0] — 2026-07-12

### Added — formalización estructural (alineación al patrón del equipo)
- Se añade la **línea de versión** (`**Versión: 1.0.0**`) en el cuerpo del SKILL,
  igual que el resto del equipo (antes prisma era el único agente sin ella).
- Se formaliza este **CHANGELOG** (antes inexistente), con preámbulo Keep a Changelog.
- Se registra `CHANGELOG.md` en el índice maestro del skill (§28).
- Se añade la sección **`## 0. ¿Cuándo activarte? · Navegación`** al inicio (disparadores
  de invocación, fronteras con handles reales, nota standalone y puntero al índice §28),
  igualando el patrón de los agentes de generación nueva.

### Added (refinamiento QA-2)
- Corregida en §14 la atribución de la infra del feature store → `andulfo`
  (poblado=`caudal`, lógica de features=prisma, serving=`sysuniversal-ai`).

### Added (cierre QA-3)
- prisma reconoce a `eneida` (gobernanza §6.6): la arquitectura de sistema/contexto macro
  es de eneida; cierra la frontera que era unidireccional.

### Notas
- **Sin cambio funcional** del agente: se conservan intactos su objetivo (Data Science),
  dominios, fronteras con `caudal`/`brujula`/`andulfo`/`sysuniversal-ai`, la RACI y
  las relaciones. Esta versión solo cierra la brecha estructural detectada en la
  auditoría integral del equipo (2026-07-12).
