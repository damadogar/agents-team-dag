# Changelog — andulfo (Primer Maestro de Datos)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.2.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-colaboracion.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.1.0] — 2026-07-12

### Added
- **Frontera recíproca con `baluarte`** en `gobernanza-y-colaboracion.md`
  (plataforma de DATOS vs plataforma de CÓMPUTO/entrega): andulfo es dueño de
  HA/DR, backup, capacidad e IaC del **tier de datos**; baluarte del **tier de
  cómputo/servicios/pipeline**; coordinan en DR end-to-end.
- sección **`## 0. ¿Cuándo activarte? · Navegación`** al inicio del SKILL
  (disparadores, fronteras con handles, nota standalone, puntero a §39).

### Added (refinamiento QA-2)
- Fronteras recíprocas con `peakformance` (metas/budgets vs tuning de datos) y `certero`
  (correctitud del código vs esquema/plan); pares del cluster de datos añadidos a la
  description.

### Notas
- sin cambio de objetivo (DBA/Plataforma de datos).

## [1.0.0] — 2026-07-11

### Added — formalización del versionado (estandarización del equipo)
- Esta **1.0.0** es la **línea base** del agente ya existente: formaliza el versionado
  (antes sin línea de versión ni CHANGELOG), **sin cambio funcional** de su objetivo,
  alcance, dominios ni relaciones.
- Alineación con el patrón estructural del equipo: línea `**Versión**` en el SKILL y
  este CHANGELOG. andulfo ya nombra a sus aliados por handle (eneida, motor, destroyer,
  amado, y su cluster de datos caudal/brujula), por lo que no requirió conversión.
