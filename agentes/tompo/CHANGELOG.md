# Changelog — tompo (Primer Maestro de Product Ownership)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.2.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.1.0] — 2026-07-12

### Changed
- **Retirado el rol fantasma "orquestador mayor"** en todos los satélites (SKILL.md,
  estrategia-vision, frameworks-marcos, gobernanza-y-colaboracion, stakeholders-liderazgo,
  ejecucion-autonoma). El dueño de la **visión de mercado, estrategia y PORTAFOLIO** es
  ahora el **negocio/sponsor (rol externo al equipo de agentes)**; tompo lo **recibe como
  INSUMO y lo traduce** a valor de producto (cuando ese rol no existe, cubre a nivel de
  producto y lo marca `[COBERTURA ADJUNTA]`).

### Added (cierre QA-3)
- Añadida cláusula de invocación standalone (portafolio = INSUMO del sponsor externo; no
  se bloquea si ese rol no existe).

### Notas
- Sin cambio de objetivo (Product Owner); resuelve el escalamiento circular de portafolio
  detectado en la auditoría (2026-07-12). Se conservan las referencias legítimas al
  "orquestador de entrega" (= `orquesta`, dueño solo del flujo).

## [1.0.0] — 2026-07-11

### Added — formalización del versionado + cross-link a `palma` (estandarización del equipo)
- Esta **1.0.0** es la **línea base** del agente ya existente: formaliza el versionado
  (antes sin línea de versión ni CHANGELOG), **sin cambio funcional** de su objetivo,
  alcance, dominios ni relaciones. tompo ya nombra a sus aliados por handle.
- Cross-link al nuevo agente **`palma`** (Ingeniería Mobile) en el dominio de producto
  **Mobile**: tompo define la estrategia de producto/negocio (retención, ASO, tienda) y
  **`palma` construye la app**.

### Fixed
- Se eliminó el **BOM** (marca de orden de bytes) de 13 archivos (todos los `.md` que lo
  tenían, incluido `SKILL.md`) para conformar el estándar de codificación del equipo
  (operación byte-safe, sin cambio de contenido).
