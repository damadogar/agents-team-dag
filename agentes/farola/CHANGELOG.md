# Changelog — farola

Formato basado en Keep a Changelog. Versionado semántico.

## [1.3.2] — 2026-07-12

### Changed
- en `governance-ia-interop.md` se retiran los **alias genéricos** "QA/DevOps/
  Security" y se cablean **handles reales**: `amado` (QA), `baluarte` (plataforma/
  entrega), `destroyer` (seguridad).

### Added
- **`certero`** añadido (review de correctitud del código frontend, debugging de
  defectos de estado/lógica) en la tabla de coordinación cross-funcional y en la de
  escalamiento.

### Added (refinamiento QA-2)
- **cláusula de invocación standalone** (LÍMITES ESTRICTOS): ante ausencia de `uxuifull`
  o `peakformance`, farola asume decisiones UX/budgets razonables con `[SUPUESTO]` y no
  se bloquea.

### Changed (refinamiento QA-2)
- Retirados los alias genéricos "DevOps/QA/security lead" en §3.2 y en LÍMITES, cableando
  handles reales (`baluarte`/`amado`/`destroyer`/`eneida`/`motor`/`orquesta`/`tompo`/
  `certero`/`palma`).

### Changed (cierre QA-3)
- §3.2 frontera de data-viz: alias "data eng" → handles reales (`motor` acceso a datos,
  `caudal` pipelines, `brujula` semántica de métricas, `prisma` estadística).

### Notas
- sin cambio de objetivo (Frontend Engineering); reciprocidad de fronteras de la
  auditoría (2026-07-12).

## [1.3.1] — 2026-07-11

### Changed — Re-acotado de canal móvil: cede mobile nativo/cross-platform a `palma`, conserva web móvil/PWA/híbrido
- Se crea el agente mobile **`palma`**, dueño de la construcción de apps móviles
  nativas y cross-platform (iOS/Android; React Native/Flutter/KMP/MAUI), del **shell
  nativo** del híbrido (Capacitor/Ionic), capacidades de dispositivo, push nativo y
  **release en tiendas** (signing, provisioning, App Store/Play Console, OTA).
- farola **cede** ese territorio (que en la práctica nunca implementó: su perímetro
  §3.1 no tenía mobile nativo) y **conserva intacto** todo lo suyo: responsive/adaptive
  web, PWA/offline y la **UI web** que corre dentro del híbrido (WebView), además de
  todas sus relaciones, responsabilidades y disparadores de activación.
- `SKILL.md`: descripción y frases de canal (§8 plantilla, §17 activación) aclaradas a
  **"móvil web (responsive)"** y **"UI web del híbrido"**; §3.2 Exclusiones (NO) gana la
  frontera **Mobile nativo/cross-platform → `palma`**. §3.1 y las tablas de capacidad
  quedan **sin cambios** (responsive/adaptive y PWA siguen siendo de farola).
- `governance-ia-interop.md`: **`palma`** añadido a la tabla de aliados (§4.4).
- Sin cambios en el resto de satélites; **nada removido** de las capacidades de farola.

## [1.3.0] — 2026-07-08

### Changed — Performance: cede ownership a `peakformance`, conserva craft
- Se crea el agente de performance **`peakformance`**, dueño del performance del
  ecosistema (frontend + backend/infra). farola **cede el ownership** de
  performance y **conserva la implementación performante (craft)**: código
  eficiente, code splitting/lazy, imágenes optimizadas, virtualización,
  percepción de velocidad y **respetar los budgets** que peakformance defina.
- `performance-accesibilidad-seguridad.md`: la §1 detallada (Core Web Vitals,
  bundle, hydration, budgets, profiling, RUM…) se reemplaza por **§1
  "Implementación performante (craft) + handoff a peakformance"**; **§2
  Accesibilidad y §3 Seguridad intactas**; §4 checklist reformulado. El detalle
  técnico se trasladó al material base de `peakformance`.
- `SKILL.md`: descripción, matriz de cobertura (#6), tablas de capacidad, §4.3,
  §7.6 y checklists reformulados a craft + handoff; **retirado el rol
  "Performance Specialist"**.
- `governance-ia-interop.md`: nueva **§4.6 Relación farola ↔ peakformance** y
  `peakformance` añadido a la tabla de aliados (§4.4); reconciliación a tres
  bandas uxuifull · peakformance · farola.
- `testing-tooling-observabilidad.md` (RUM), `data-viz.md`, `playbooks.md`
  (PB-05) y `plantillas.md` (§3): notas de ownership a `peakformance`,
  conservando el craft de farola.

## [1.2.0] — 2026-06-29

### Added
- **Visualización de datos** como área de dominio completa: nuevo `data-viz.md`
  cubriendo decisión de render (HTML/SVG/Canvas/WebGL por volumen), selección de
  librería (declarativa/bajo nivel/data grid/mapas/big data), encoding por tipo de
  gráfico, performance con datasets grandes (downsampling LTTB, agregación,
  virtualización, workers, streaming), **accesibilidad de gráficos** (no-solo-color,
  alt textual, tabla equivalente, teclado, fallback Canvas/WebGL), theming con
  tokens de datos + dark mode, charts en tiempo real, SSR/imagen estática, testing
  y anti-patrones.
- **Frontera de dominio explícita:** render/interacción/performance/a11y de
  visualizaciones = frontend (farola); modelado/agregación/ETL/semántica de
  métricas = backend/data (`motor`); narrativa visual de alto nivel = `uxuifull`.
- **Playbook PB-17** (implementar/optimizar visualización de datos o dashboard) y
  **plantilla §14** (especificación de visualización/dashboard).
- Matriz de cobertura ampliada a **21 áreas**; nueva sub-área §7.21; perímetro
  §3.1 y exclusión §3.2 actualizados.

### Changed
- Archivos de referencia: 9 → 10 (12 archivos `.md` en total con SKILL.md y
  CHANGELOG.md). SKILL.md actualizado (índice, áreas, plantillas, playbooks,
  triggers, descripción frontmatter).

## [1.1.0] — 2026-06-29

### Added
- **Agnosticismo multi-framework real:** nuevo `frameworks-cross-stack.md` con
  tabla de traducción de conceptos y ejemplos paralelos (componente, estado,
  derivado, server state, forms, 4 estados) en React/Vue/Svelte/Angular/Solid +
  Web Components (Lit) y heurística de elección/migración.
- **Nuevas áreas de dominio:** nuevo `i18n-seo-realtime.md` cubriendo
  internacionalización (ICU, Intl, RTL, locales, pseudo-localización), SEO técnico
  (SSR/markup, meta, Open Graph, JSON-LD, hreflang, sitemap, CWV), tiempo real
  (WebSocket/SSE, reconexión, reconciliación, presencia, CRDT, streaming UI),
  PWA/offline-first y rendering UX avanzado (View Transitions, scroll-driven,
  prefetch) + canales no estándar (email, embeds, extensiones, desktop, 3D).
- **Playbooks:** PB-13 auditoría exprés de sistema ya construido (60-90 min),
  PB-14 internacionalizar un frontend, PB-15 auditoría SEO técnico, PB-16
  implementar tiempo real.
- **Plantillas:** i18n readiness y auditoría SEO técnico.
- Matriz de cobertura ampliada a 20 áreas; perímetro §3.1 y secciones §7.16–7.20
  actualizadas; refuerzo explícito de que los ejemplos React son ilustrativos.

### Changed
- Archivos de referencia: 7 → 9 (11 archivos `.md` en total con SKILL.md y
  CHANGELOG.md). SKILL.md actualizado (índice, áreas, plantillas, playbooks,
  triggers, descripción frontmatter).

## [1.0.1] — 2026-06-26

### Added
- Esquema de globalización: carpeta maestra `~/.farola` + junctions a
  `.cursor/skills`, `.claude/skills`, `.claude-trabajo/skills`, `.agents/skills`.
- Script `sincronizar.ps1` (mismo patrón que eneida, uxuifull, andulfo, amado, destroyer).

## [1.0.0] — 2026-06-26

### Added
- Skill inicial del Primer Maestro de Frontend Engineering.
- Cobertura integral 15 áreas frontend + IA aplicada.
- Integración con uxuifull (handoff §2.1, validación post-implementación).
- Base de conocimiento: fundamentos, UI/estado, perf/a11y/seg, testing/tooling,
  governance/IA/interop.
- Plantillas operativas y 12 playbooks accionables.
- Sistema evaluación madurez frontend (9 dimensiones).
- Checklists maestras arquitectura, calidad, perf, a11y, seguridad, testing,
  release, design system, governance.
- Prompt maestro y prompt de activación.
