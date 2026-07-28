# Changelog — uxuifull (Primer Maestro de UX/UI Integral)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.3.2] — 2026-07-12

### Added — cláusula de invocación standalone (paridad textual: uxuifull es plenamente utilizable por sí solo, origen del handoff de UX, sin depender de un orquestador).

Notas: sin cambio de objetivo.

## [1.3.1] — 2026-07-12

### Fixed / Added — 2ª ronda de QA (4 revisores solo lectura), lotes A+B
Auditoría de v1.3.0 en 4 dimensiones. Veredicto: **ni la instalación de motion ni
las correcciones de v1.3.0 dañaron nada** (coherencia, índice, enlaces, encoding,
fronteras, versión y operatividad en los 4 roots: intactos). Sin bloqueantes ni
ALTA. Se aplicaron precisión + enriquecimiento.

- **Precisión y consistencia (Lote A):**
  - `ux-engineering-avanzado.md` §6 bis: nueva **frontera con `sysuniversal-ai`**
    (modelo/ML/serving/MLOps) y **`vector`** (seguridad de IA/LLM) — cierra la única
    omisión de frontera (uxuifull diseña la capa de experiencia de la IA, no el modelo).
  - `etica-y-patrones-enganosos.md` §2: nota **plurirregional** (LGPD/DPDP/Ley 1581),
    coherente con el patrón de `accesibilidad`; §1: crédito de las meta-categorías a
    **Gray et al. (2018)** junto a Brignull; §3: puntero de craft emocional corregido
    a `interaccion-disenio` §6 bis.
  - `estrategia-ux.md` §6 bis: redacción precisada — entrega = `orquesta`, valor =
    `tompo` (no agrupados); §6: puntero "(ver §6 bis)".
  - SKILL.md: gatillo de **ética/dark patterns** añadido a §2 "Cuándo activarte" y al
    ítem 6 del checklist de progreso §4 (antes solo en el checklist de cierre §14).
- **Enriquecimiento élite (Lote B):**
  - `etica` §3: **catálogo de sesgos** que NO se explotan (anclaje, aversión a la
    pérdida, default, framing…), **Global Privacy Control (GPC)** en privacy-UX, y
    **usuarios vulnerables/menores** (safety-by-design, age-appropriate / Children's
    Code); Referencias ampliadas (Gray et al., GPC, ICO Children's Code).
  - `ux-engineering` §5 bis: nombrado el modelo **SWDM** (medición cede a `peakformance`);
    §5 data-heavy: cross-link a la skill aliada **`dataviz`** como insumo.
  - `ejemplos.md`: **Ejemplo 5** (spec de movimiento con `animation-vocabulary` + handoff)
    y **Ejemplo 6** (veto de patrón engañoso / diseño honesto).

Sin archivos nuevos (siguen 15 satélites de contenido). Sin cambios en el objetivo ni
las fronteras (ownership respetado; se añadieron fronteras faltantes, no se movieron).

## [1.3.0] — 2026-07-12

### Added / Fixed — pasada de QA completa (4 revisores solo lectura), lotes autorizados
Auditoría de v1.2.5 en 4 dimensiones (coherencia/índice/integridad post-install;
experto integral/universalidad/nivel mundial; fronteras/no-solapamiento;
operatividad/invocación). Veredicto: **instalación de motion NO dañó nada**
(coherencia, índice, enlaces, encoding, fronteras y versión intactos). Se
autorizó aplicar todo, cuidando no dañar lo existente.

- **Instalación completada (hueco operativo):** el paquete de motion (`emilkowalski`)
  estaba en solo 2 de los 4 junction-roots; se crearon los junctions en `.cursor` y
  `.claude-trabajo` (los 5: apple-design, emil-design-eng, animation-vocabulary,
  improve-animations, review-animations) → ahora `/nombre` resuelve en los 4 roots,
  incluido el harness de este proyecto. Cumple "usarlas por defecto en cualquier proyecto".
- **Pulido del cableado:** `review-animations` marcada como **invocación explícita**
  (no auto-invocable) también dentro de la lista "por defecto" (interop §3bis.2);
  término "model-invoked" precisado en SKILL §4; `/palma` añadido a las filas de índice
  §0; paridad "cuándo puede omitirse" + ancla a checklist en la subsección de motion;
  nuevo campo **Spec de movimiento** en el contrato de handoff §2.1; nueva **§4.1
  Adyacencias sanas** en el hub declarando la frontera con `amado` (validación UX vs
  QA), `tompo` (oportunidades de experiencia vs valor) y `docpower` (doc del DS vs
  ingeniería documental).
- **Nueva disciplina — Ética de diseño / patrones engañosos** (cierra el hueco de
  completitud élite): satélite `etica-y-patrones-enganosos.md` (taxonomía Brignull/
  deceptive.design, marco regulatorio DSA/GDPR-EDPB/FTC/CPRA, persuasión ética vs
  manipulación, consentimiento/privacidad como UX honesta, checklist). Cableado:
  principio rector #12 "Diseño honesto", disciplina 13 en la matriz, fila en tabla
  y base de conocimiento §10, regla de oro §11, anti-patrón §13 y ítem de checklist §14.
- **Completitud élite (subsecciones nuevas, sin renumerar):** prototipado por fidelidad
  (`research-ux` §5 bis); diseño emocional y conductual con contrapeso ético
  (`interaccion-disenio` §6 bis, Norman/Fogg/Hook + enlace a ética); DesignOps en
  profundidad (`estrategia-ux` §6 bis, topologías/intake/deuda de diseño/rituales, sin
  invadir `orquesta`/`tompo`); sostenibilidad digital / green UX (`ux-engineering` §5 bis,
  WSG, sobriedad; rendimiento medible sigue en `peakformance`); UI generativa/adaptativa
  y personalización (`ux-engineering` §6 bis, con guardarraíles y personalización honesta).

Universalidad greenfield↔brownfield y agnosticismo confirmados por QA. Sin cambios en
el objetivo ni las fronteras (ownership de farola/palma/motor/eneida/peakformance/
certero/amado/tompo/docpower respetado). 15 satélites de contenido + SKILL + CHANGELOG
+ sincronizar.ps1 (nuevo satélite: `etica-y-patrones-enganosos.md`).

## [1.2.5] — 2026-07-12

### Added — paquete de skills aliadas de motion & craft (`emilkowalski`)
- Se cablean **5 skills aliadas model-invoked** (Skill / `/nombre`, no CLI) como
  **insumos de craft, no autoridad**, con el mismo trato que `ui-ux-pro-max`:
  `apple-design` (motion físico/fluido de Apple en web), `emil-design-eng`
  (design engineering / taste de Emil Kowalski), `animation-vocabulary` (glosario
  inverso de nomenclatura de motion), `improve-animations` (auditoría read-only →
  plan) y `review-animations` (diagnóstico de craft de un diff).
- `interoperabilidad-y-aliadas.md`: nueva **§3 bis** (qué aporta cada skill,
  cuándo invocarlas por defecto, cómo invocarlas, reconciliación con la misma
  jerarquía + anti-sesgo, y **fronteras**: implementación → `farola`/`palma`,
  rendimiento medible → `peakformance`, correctitud del código → `certero`).
- `SKILL.md`: principio rector #10, subsección "Comportamiento por defecto con el
  paquete de motion & craft", §9 (accesos), y filas de índice/matriz/base de
  conocimiento actualizadas. Consulta **por defecto** en tareas de movimiento,
  micro-interacción, gestos o pulido fino.
- **Sin cambios en el objetivo, el dominio, el flujo ni las demás relaciones de
  uxuifull.** Anti-sesgo blindado: se adopta el *criterio de craft* pero se
  rechaza toda estética impuesta que no encaje con marca/contexto/accesibilidad
  ("estilo Apple" no es un default universal). Global vía los 4 junctions.

## [1.2.4] — 2026-07-11

### Added — cross-link al nuevo agente mobile `palma`
- Se crea **`palma`** (Ingeniería Mobile): constructor de apps nativas y
  cross-platform. Añadido como **agente ejecutor de UI móvil** en la tabla de
  invocación cruzada (§2.3 de `interoperabilidad-y-aliadas`): uxuifull **diseña** la
  experiencia mobile y entrega el handoff §2.1 a `palma` para **construir** la app
  nativa/cross-platform (la UI web sigue yendo a `farola`). Sin cambios en el
  dominio, las responsabilidades ni las demás relaciones de uxuifull.

## [1.2.3] — 2026-07-08

### Removed — Performance técnico/medible fuera de alcance
- Retirado el **rendimiento medible** de uxuifull para dejarlo como agente
  netamente UX/UI; se traslada a un futuro **agente de performance** (material
  base en `performance-agent-seed.md`, fuera de este skill).
- `ux-engineering-avanzado.md`: eliminada la §4 "Core Web Vitals (web) y
  rendimiento medible" (LCP/INP/CLS, técnicas de optimización, 60 fps);
  sustituida por nota de handoff. Secciones §5–§9 renumeradas a §4–§8. §5 (motion)
  reformula "reflow/CLS" a "saltos/jank". Entregable de "Core Web Vitals objetivo"
  ahora se entrega como criterio al agente de performance.
- `SKILL.md`: retiradas menciones a "Core Web Vitals" (descripción, índice
  maestro, matriz de cobertura, §9 guías, §10) y a "performante" (§11). El
  rendimiento **percibido** se conserva.
- `metricas-validacion.md` §7, `interoperabilidad-y-aliadas.md` (handoff):
  retirado "Core Web Vitals objetivo".
- `interfaz-visual.md` §8: "evita CLS" → "evita saltos de layout" (se mantiene la
  práctica de reservar dimensiones).

### Se conserva (es UX, no ingeniería de performance)
- Rendimiento **percibido**: feedback <100 ms, Doherty threshold, skeleton
  screens, optimistic UI, "percepción > medición".
- Guía de **motion** (duraciones, easing, `prefers-reduced-motion`).

## [1.2.2] — 2026-06-26

### QA / Changed
- Pasada final de QA al skill completo (16 archivos): coherencia entre archivos
  y referencias cruzadas verificadas (todas resuelven), sin contradicciones.
- `SKILL.md` §0: añadida **Matriz de cobertura integral** (12 disciplinas →
  archivo) como índice maestro de completitud, y nota de fuente canónica de
  "estados completos" (`interaccion-disenio.md` §4) para evitar ambigüedad ante
  el solapamiento intencional entre archivos.
- Fix menor: "elementos Ui" → "elementos UI" en `interfaz-visual.md`.

### Notas de QA
- Solapamientos detectados (intencionales, no contradictorios): "estados
  completos", tamaños de objetivo táctil (WCAG 24px AA / 44-48 plataforma) y
  rendimiento percibido (<100 ms) se mencionan en varios archivos desde ángulos
  distintos y consistentes.

## [1.2.1] — 2026-06-26

### Changed
- Convención de invocación cruzada actualizada con los agentes oficiales:
  frontend **`farola`** (masculino) y backend **`motor`** (reemplazan los
  nombres genéricos provisionales). Fallback y mensajes "LISTO PARA EJECUCIÓN"
  ahora nombran a `farola`/`motor`.

## [1.2.0] — 2026-06-26

### Added
- Protocolo de **invocación cruzada** (`interoperabilidad-y-aliadas.md` §2.3): al
  terminar un handoff, uxuifull detecta el agente de frontend/programación
  disponible (por convención de nombre), aplica gate humano por defecto
  (modo automático opcional), delega el paquete §2.1 vía subagentes, hace
  fallback "LISTO PARA EJECUCIÓN" si no existe el agente, y valida el resultado
  (criterios de aceptación + WCAG + estados) reportando drift.
- `ui-ux-pro-max` ahora se consulta **por defecto** en tareas con decisión
  visual (nueva subsección en §4 del SKILL.md y §3.1 de la guía de
  interoperabilidad), sin necesidad de pedirlo; sigue siendo insumo, no
  autoridad final.

## [1.1.0] — 2026-06-26

### Changed
- Renombrado de la skill: `mira` → `uxuifull` (frontmatter, identidad,
  encabezados de `CHANGELOG.md` y `plantillas.md`, y checklist de progreso).
- Globalización: carpeta maestra `~/.uxuifull` + junctions a `.cursor/skills`,
  `.claude/skills`, `.claude-trabajo/skills`, `.agents/skills` (mismo esquema
  que eneida/amado/andulfo/destroyer) vía `sincronizar.ps1`.

### Added
- `interoperabilidad-y-aliadas.md`: operar sobre CUALQUIER sistema (construido o
  en construcción), contrato de handoff accionable y agnóstico de stack para
  agentes de frontend/programación, e integración con la skill aliada
  `ui-ux-pro-max` (cuándo/cómo invocar su CLI y jerarquía de criterio para
  reconciliar sus recomendaciones).
- Principio rector #10 reforzado (sin sesgo + tecnología-agnóstico); §9
  ampliada con `ui-ux-pro-max` y handoff; nueva fila en la base de conocimiento.

## [1.0.0] — 2026-06-26

### Added
- `SKILL.md` maestro: identidad, principios rectores, cuándo activarte, modos
  A–E, protocolo de 6 fases + checklist, entradas, disciplina de decisión,
  salidas obligatorias, formato de respuesta de 8 secciones, accesos y
  herramientas, reglas de oro, estilo, anti-patrones y checklist de cierre.
- Base de conocimiento (progressive disclosure), cobertura integral end-to-end:
  - `estrategia-ux.md` — UX strategy, framing, JTBD, priorización, madurez,
    gobierno.
  - `research-ux.md` — métodos cualitativos/cuantitativos, síntesis, ResearchOps,
    sesgos.
  - `arquitectura-informacion.md` — taxonomía, navegación, búsqueda, wayfinding,
    validación (card sort / tree test).
  - `interaccion-disenio.md` — flujos, estados, feedback, microinteracciones,
    errores, focus, gestos, responsive.
  - `interfaz-visual.md` — jerarquía, layout/grids, tipografía, color, densidad,
    componentes, multi-plataforma (HIG/Material/Fluent).
  - `design-systems.md` — tokens (3 niveles), componentes, patrones, gobernanza,
    theming, métricas de salud.
  - `accesibilidad.md` — WCAG 2.2 / POUR, teclado, lectores, cognición, motor,
    inclusive design, marco legal (EAA/EN 301 549/ADA/508).
  - `ux-writing-contenido.md` — microcopy, voz y tono, content design,
    legibilidad, i18n/l10n, contenido para IA.
  - `service-design-mapping.md` — journey/experience maps, service blueprints,
    omnicanal, ecosistema.
  - `ux-engineering-avanzado.md` — design-to-code, rendimiento percibido, Core
    Web Vitals, motion, 3D/WebGL, AR/VR, interfaces con IA y conversacionales.
  - `metricas-validacion.md` — heurísticas + severidad, métricas de tarea,
    SUS/UMUX/SEQ, HEART, A/B, auditorías, hipótesis.
  - `plantillas.md` — 12 plantillas de entregables.
  - `ejemplos.md` — 4 ejemplos resueltos end-to-end (brownfield, greenfield,
    design system, IA).

### Notes
- Cobertura sin sesgo de plataforma, industria, estilo ni metodología.
- Aplicable a sistemas greenfield, en construcción y brownfield/auditoría.
- Alcance estricto UX/UI; no invade arquitectura de software, liderazgo técnico,
  PM ni PO.
