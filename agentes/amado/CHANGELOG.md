# Changelog — amado (Primer Maestro de Calidad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.2.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `interoperabilidad-y-aliados.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.1.0] — 2026-07-12

### Added
- **Nuevo archivo `interoperabilidad-y-aliados.md`** que consolida las fronteras de amado
  con todo el equipo (handles reales, ENTREGA/RECIBE), incluida la frontera con
  **`uxuifull`** (diseño de usabilidad/accesibilidad = uxuifull; verificación/testing incl.
  WCAG = amado) y la frontera "dos cazadores que no se pisan" con `certero`. Registrado en
  §17.1 (15 → 16 documentos).
- Reconocimiento de `uxuifull` en SKILL.md (nota de aliados y fila UX/UI en §9).
- Sección **`## 0. ¿Cuándo activarte? · Navegación`** al inicio del SKILL.

### Added (refinamiento QA-2)
- Afinada la frontera con `uxuifull` en `interoperabilidad-y-aliados.md`: de "testing de
  usabilidad" a **"testing de conformidad de accesibilidad (WCAG) + verificación de
  criterios de usabilidad definidos sobre el build"**; la investigación/validación de
  usabilidad (heurística, A/B) es de `uxuifull`.

### Notas
- Sin cambio de objetivo (QA/Calidad); frontera nuclear "prueba y reporta, no corrige"
  intacta.

## [1.0.0] — 2026-07-11

### Added — formalización del versionado + cross-links a handles del equipo (estandarización)
- Se **formaliza el versionado** de amado (antes sin línea de versión ni CHANGELOG):
  esta 1.0.0 es la **línea base del agente ya existente**, **sin cambio funcional** de su
  objetivo, alcance ni principios.
- **Estandarización de interoperabilidad** (nombrar a los agentes del equipo por handle,
  respetando el objetivo "QA detecta y reporta, no arregla"):
  - Principio 13 (frontera de rol): el fix lo ejecuta su dueño — `certero` (correctitud
    del código), `motor`/`farola`/`palma` (según la capa); amado re-testea y verifica.
  - **Precisión de gobernanza:** la decisión de **corregir/diferir** deja de atribuirse
    solo al "PO/Dev" y se describe como un **triage** entre PO (`tompo`, prioridad/valor),
    **líder técnico/arquitecto** (`eneida`, severidad técnica/riesgo) y PM/Delivery Manager
    (*futuro PM*); amado aporta severidad/evidencia/recomendación y conserva su **potestad
    de bloquear** por gate de calidad.
  - Nueva nota **"Aliados del equipo"**: a quién enruta amado cada hallazgo por dominio
    (`certero`/`motor`/`farola`/`palma`/`andulfo`/`peakformance`/`destroyer`/`baluarte`/
    `eneida`/`tompo`), reafirmando la frontera con `certero` (amado prueba y reporta;
    certero revisa el código y corrige).
- **Sin cambios** en los 13 principios rectores, el alcance universal, ni ningún otro
  entregable de amado.
