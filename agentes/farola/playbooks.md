# Playbooks Accionables — farola

Procedimientos paso a paso para escenarios frontend frecuentes.

---

## PB-01: Iniciar frontend desde cero

**Trigger:** greenfield, nuevo producto web.
**Modos:** A → B → C

### Fase 1 — Discovery (Día 0-1)
1. Recopilar requisitos: canal, SEO needs, auth, offline, browsers, equipo size.
2. Definir atributos calidad top 3.
3. Si existe uxuifull spec → ingestar; si no → solicitar mínimo IA/flujos o inferir `[SUPUESTO]`.

### Fase 2 — Decisiones arquitectónicas (Día 1-2)
1. Elegir rendering: SPA / SSR / SSG / hybrid (§12 reglas decisión).
2. Elegir stack: framework, bundler, CSS, state, testing.
3. Documentar ADR-001 Architecture, ADR-002 Stack.
4. Definir estructura carpetas (FSD o layered).

### Fase 3 — Bootstrap (Día 2-3)
```bash
# Ejemplo Vite + React + TS (adaptar según decisión)
pnpm create vite@latest app --template react-ts
cd app && pnpm add react-router-dom @tanstack/react-query zod react-hook-form @hookform/resolvers
pnpm add -D eslint typescript-eslint prettier vitest @testing-library/react @axe-core/playwright
```
1. Configurar ESLint strict + jsx-a11y + Prettier.
2. Setup path aliases (`@/`).
3. Crear `src/app/providers.tsx` (QueryClient, Router, Theme).
4. Crear `src/shared/ui/` con Button, Input base (o shadcn init).
5. Setup MSW para dev/test.
6. CI mínimo: typecheck + lint + test + build.

### Fase 4 — Foundation (Semana 1)
1. Layout shell + routing + 404.
2. Error boundary global + per-route.
3. API client typed + error handling.
4. 4 estados pattern documentado en README.
5. Storybook init para shared/ui.

### Fase 5 — First feature (Semana 1-2)
1. Implementar feature vertical slice end-to-end.
2. Tests: component + integration.
3. Lighthouse baseline.
4. Release preview environment.

**Done cuando:** first feature shipped, CI green, Storybook live, ADRs merged.

---

## PB-02: Escalar frontend existente

**Trigger:** crecimiento equipo/código, degradación DX o performance.
**Modos:** A → B → C → D

1. **Auditar** (PB usa template auditoría): arquitectura, acoplamiento, bundle, test gaps.
2. **Identificar boundaries naturales** por dominio de usuario.
3. **Extraer shared package** (ui, api-client, config) si duplicación.
4. **Introducir feature folders** incrementalmente (strangler).
5. **Enforce boundaries** eslint-plugin-boundaries o Nx module boundaries.
6. **Platform team rituals:** design system office hours, frontend guild.
7. **Metrics:** track build time, bundle size, PR cycle time.

**No hacer:** rewrite completo sin red E2E y ROI claro.

---

## PB-03: Organizar monorepo frontend

**Trigger:** múltiples apps (web, admin, docs) o packages compartidos.

1. Elegir tool: **Turborepo + pnpm** (default farola) o Nx si graph complejo.
2. Estructura:
   ```
   apps/web apps/admin packages/ui packages/config-eslint packages/api-client
   ```
3. Shared tsconfig base; eslint config extends.
4. `turbo.json` pipeline: build dependsOn ^build.
5. Internal deps: `"@org/ui": "workspace:*"`.
6. Changesets para versionar packages publicados.
7. CODEOWNERS por package.
8. Documentar en README monorepo conventions.

---

## PB-04: Construir design system

**Trigger:** inconsistencia UI, múltiples productos, escala equipo.

### Fase 1 — Tokens
1. Auditar tokens existentes o recibir de uxuifull.
2. Definir: color (OKLCH preferred), space scale (4/8pt), typography, radius, shadow, motion.
3. Style Dictionary o Tailwind theme extension.
4. Dark mode strategy.

### Fase 2 — Primitives
1. Button, Input, Select, Checkbox, Radio, Switch, Textarea.
2. Radix/shadcn base para a11y.
3. CVA variants documentadas.

### Fase 3 — Composites
1. Card, Dialog, Dropdown, Tabs, Toast, Table.
2. Todos los estados + Storybook stories.

### Fase 4 — Governance
1. Contribution RFC template.
2. Semver release process.
3. Visual regression CI.
4. Migration guides para breaking changes.

---

## PB-05: Optimizar performance (coordinado con `peakformance`)

**Trigger:** CWV rojos, quejas usuarios, bundle creep.
**Modos:** A (diagnóstico) → C (fix)

> **Ownership:** la estrategia de performance, los budgets y la medición son de
> **`peakformance`**. farola ejecuta este playbook **en coordinación con
> `peakformance`**: lidera las optimizaciones de su capa (frontend) y escala el
> diagnóstico, la definición de budgets/metas y el profiling a `peakformance`
> (ver [governance-ia-interop.md](governance-ia-interop.md) §4.6).

1. **Medir:** RUM p75 + Lighthouse lab + bundle analyzer.
2. **Identificar LCP element** → optimizar ese recurso primero.
3. **Quick wins:**
   - Lazy routes + dynamic imports.
   - Image format/size/srcset.
   - Font subset + preload critical.
   - Remove unused deps.
   - Defer third-party scripts.
4. **Medium:** virtualize lists, memo after profile, reduce hydration.
5. **Hard:** architecture change (RSC, islands, MFE split).
6. **Prevent:** performance budget CI, RUM alerts.
7. Template: [plantillas.md §3](plantillas.md).

---

## PB-06: Mejorar accesibilidad

**Trigger:** audit fail, legal requirement, inclusión goal.

1. **Automated baseline:** axe all routes → export violations.
2. **Manual:** keyboard-only pass, screen reader spot check (3 flows críticos).
3. **Priorize:** blockers (no keyboard, no labels) → serious (contrast) → moderate.
4. **Fix patterns:**
   - Replace div buttons → semantic elements.
   - Add labels, aria-describedby errors.
   - Focus management modals.
   - Color contrast token fixes.
5. **Prevent:** jsx-a11y CI, axe E2E, Storybook a11y addon, PR checklist.
6. **Validate:** re-audit + user test con AT si posible.

---

## PB-07: Endurecer seguridad frontend

**Trigger:** audit, incident, compliance.

1. Inventory attack surface (auth, UGC, third-party, iframe).
2. `npm audit` + fix critical/high.
3. Scan for secrets: gitleaks/trufflehog.
4. Review all `dangerouslySetInnerHTML`, `innerHTML`, `eval`.
5. Token storage review → migrate to httpOnly if feasible.
6. Add DOMPurify where rich text rendered.
7. CSP alignment doc for DevOps.
8. postMessage origin checks.
9. Template: [plantillas.md §5](plantillas.md).

---

## PB-08: Establecer testing strategy

**Trigger:** no tests, flaky suite, low confidence releases.

1. **Assess:** current coverage, critical user paths, pain points.
2. **Define pyramid** ratios y ownership.
3. **Setup:**
   - Vitest + Testing Library (unit/component).
   - MSW (API mock).
   - Playwright (E2E smoke: 5-10 tests max initially).
4. **CI gates:** PR must pass unit; main adds E2E nightly or per PR if fast enough.
5. **Conventions:** colocate tests, `*.test.tsx`, data-testid sparingly (prefer roles).
6. **Visual regression** on design system (phase 2).
7. Document in `docs/testing.md`.

---

## PB-09: Migrar arquitectura antigua → moderna

**Trigger:** legacy framework, unmaintainable structure, EOL deps.

1. **Assess ROI:** cost of stay vs migrate.
2. **E2E safety net** before any migration.
3. **Strangler fig by route/feature:**
   - New routes in new architecture.
   - Bridge layer for shared auth/session.
   - Gradual component replacement.
4. **Parallel run** old + new during transition.
5. **Codemods** for mechanical transforms.
6. **Train team** on new patterns.
7. **Decommission** old module when traffic 0.

**Ejemplos:**
- jQuery → React: widget by widget.
- CRA → Vite: migrate tooling first, then structure.
- Pages Router → App Router (Next): route by route.

---

## PB-10: Revisar código frontend generado por IA

**Trigger:** PR con código Copilot/Cursor/v0/Bolt.

```
Checklist farola — Review IA:
- [ ] 1. Lee diff completo; no trust green CI alone
- [ ] 2. Convenciones repo respetadas
- [ ] 3. TS strict — no any sneaked
- [ ] 4. HTML semántico — no div soup
- [ ] 5. 4 estados UI presentes
- [ ] 6. a11y: labels, keyboard, focus, contrast
- [ ] 7. Security: no secrets, sanitize HTML
- [ ] 8. Performance: no useEffect sync sets, huge deps
- [ ] 9. Tests exist or requested
- [ ] 10. Matches uxuifull spec if applicable
- [ ] 11. No hallucinated APIs — verify imports exist
- [ ] 12. License/attribution deps nuevas
```

Output: approve / request changes con severidad 🔴🟡🟢.

---

## PB-11: Recibir handoff uxuifull e implementar

**Trigger:** uxuifull delega paquete §2.1.
**Modos:** C → E

### Paso 1 — Recepción
1. Verificar paquete completo: spec, flujos, estados, tokens, microcopy, a11y, AC.
2. Listar gaps → `[SUPUESTO]` o preguntar a uxuifull.

### Paso 2 — Plan técnico
1. Mapear spec → archivos/componentes existentes o nuevos.
2. Identificar dependencias backend → escalar a `motor` si necesario.
3. Orden: tokens → primitives → feature components → page integration.

### Paso 3 — Implementación
1. Tokens/theme updates first.
2. Componentes con 4+ estados.
3. Microcopy exacto del spec.
4. Responsive según breakpoints spec.
5. a11y: WCAG criteria del handoff.

### Paso 4 — Verificación
1. AC checklist uno a uno.
2. axe + keyboard manual.
3. Visual compare vs mockup/screenshot.

### Paso 5 — Entrega
1. Reporte implementación + drift log (governance-ia-interop §4.3).
2. Solicitar validación uxuifull modo E.

**Regla de oro:** NO alterar decisiones UX sin escalar. Si constraint técnico
impide spec → proponer alternativa equivalente en experiencia a uxuifull.

---

## PB-12: Incident response frontend (producción)

**Trigger:** error spike Sentry, CWV regression, broken deploy.

1. **Triage (5 min):** scope (% users), severity, since when (correlate deploy).
2. **Mitigate:** feature flag off OR rollback to last good artifact.
3. **Diagnose:** Sentry stack, breadcrumbs, RUM timeline, reproduce staging.
4. **Fix:** hotfix branch → minimal diff → expedited review → deploy.
5. **Verify:** metrics stable 30 min.
6. **Postmortem:** root cause, prevention (test gap, monitoring gap).

farola lidera diagnóstico cliente; coordina rollback con DevOps si needed.

---

## PB-13: Auditoría exprés de sistema ya construido (60-90 min)

**Trigger:** "revisa este frontend ya hecho" sin tiempo para auditoría completa.
**Modos:** A (diagnóstico rápido) → entrega priorizada.

**Objetivo:** veredicto accionable rápido sin leer todo el repo. Time-box por bloque.

### Bloque 1 — Reconocimiento (10 min)
1. `package.json`: framework, versión, scripts, deps sospechosas (lodash full, moment).
2. Estructura de carpetas: ¿hay arquitectura o es plano/caótico?
3. `tsconfig`: ¿strict? ¿o JS sin tipos?
4. Lockfile + `npm audit` rápido (críticas/altas).

### Bloque 2 — Señales de salud (20 min)
1. **Build + bundle:** `build` y mira tamaño; corre bundle analyzer si existe.
2. **Lighthouse** en 2-3 rutas clave (lab) → CWV de partida.
3. **axe** en home + 1 ruta crítica → violaciones a11y bloqueantes.
4. Buscar anti-patrones rápidos (grep): `dangerouslySetInnerHTML`, `: any`,
   `useEffect` con `setState` derivado, secrets (`API_KEY`, tokens), `localStorage`
   con tokens, componentes >400 líneas.

### Bloque 3 — Profundidad selectiva (20 min)
1. Abrir 2-3 componentes más grandes/centrales → calidad real.
2. Revisar capa de datos: ¿server cache mezclado con store global? ¿error handling?
3. ¿Hay tests? ¿corren? ¿cubren paths críticos?
4. ¿4 estados de UI en vistas clave o faltan vacío/error?

### Bloque 4 — Veredicto (10-20 min)
1. Score de madurez 1-5 (9 dimensiones, §14 SKILL.md) con evidencia mínima.
2. Top 5 hallazgos por severidad 🔴🟠🟡.
3. Quick wins (≤1 sprint) vs inversiones estructurales.
4. Recomendación: ¿estabilizar, refactor incremental o replatform? con ROI.

**Done cuando:** entregable de 1-2 páginas con score + top hallazgos + 3-5 acciones
priorizadas. Si se requiere más, escalar a auditoría completa (plantillas §1).

---

## PB-14: Internacionalizar (i18n) un frontend

**Trigger:** producto pasa a multi-idioma/multi-región.
**Modos:** A → B → C. Ref: [i18n-seo-realtime.md](i18n-seo-realtime.md) §1.

1. **Auditar strings:** localizar texto hardcodeado, concatenaciones, textos en
   imágenes, formatos de fecha/número/moneda hechos a mano.
2. **Elegir librería** por framework (i18next, vue-i18n, Paraglide, `@angular/localize`).
3. **Definir locales** soportados + fallback chain + default.
4. **Extraer a catálogos** por namespace/feature; claves semánticas estables.
5. **Migrar formatos a `Intl`** (number, date, currency, relative, list).
6. **Pluralización/género con ICU**; eliminar `if (n===1)`.
7. **RTL ready:** logical properties, `dir`, iconos direccionales.
8. **Routing/detección de locale** + `hreflang` para SEO.
9. **Lazy-load** del idioma activo; no enviar todos.
10. **QA:** pseudo-localización en CI, test de claves faltantes y desbordes.

**Done cuando:** UI 100% sin texto hardcodeado, formatos culturalmente correctos,
cambio de idioma funcional, layout no se rompe en idioma más largo + RTL.

---

## PB-15: Auditoría SEO técnico frontend

**Trigger:** páginas no rankean/no se comparten bien en redes.
**Modos:** A → C. Ref: [i18n-seo-realtime.md](i18n-seo-realtime.md) §2.

1. **Rendering:** ¿contenido crítico en HTML inicial? Si SPA puro con SEO → migrar
   ruta(s) a SSR/SSG/prerender.
2. **Markup server:** verificar que title, description, canonical, Open Graph y
   Twitter card están en el HTML del servidor (no inyectados por JS).
3. **Probar social crawler:** validar OG con debuggers (no ejecutan JS).
4. **JSON-LD** en tipos aplicables (Product/Article/Breadcrumb/FAQ) + validar.
5. **Infra:** `sitemap.xml`, `robots.txt`, canonicals sin duplicados por params,
   301 en rutas cambiadas, 404 reales (no soft-404).
6. **hreflang + x-default** si multi-idioma.
7. **CWV** en verde (es ranking) → enlazar con PB-05.
8. **Crawlabilidad:** headings jerárquicos, alt en imágenes, links como `<a href>`.

**Done cuando:** checklist SEO técnico (§2.5) en verde en rutas indexables clave.

---

## PB-16: Implementar funcionalidad en tiempo real

**Trigger:** chat, notificaciones en vivo, colaboración, dashboards live, streaming IA.
**Modos:** B → C → E. Ref: [i18n-seo-realtime.md](i18n-seo-realtime.md) §3.

1. **Elegir transporte:** SSE si solo server→cliente; WebSocket si bidireccional;
   evaluar servicio manejado (Ably/Pusher/Supabase/Liveblocks) vs propio.
2. **Capa de conexión** aislada (no en componentes): hook/servicio con estado
   conectado/reconectando/offline.
3. **Robustez obligatoria:** reconexión backoff+jitter, heartbeat, resync con
   `lastEventId`/cursor al reconectar.
4. **Reconciliación de estado:** integrar con server cache (TanStack Query
   `setQueryData` / invalidación); optimistic con rollback.
5. **Backpressure:** coalesce/throttle updates de alta frecuencia (rAF).
6. **Colaboración concurrente:** si edición simultánea de texto/estructura → CRDT
   (Yjs), no last-write-wins.
7. **UI:** indicador de conexión, presencia si aplica, estados de error claros.
8. **Cleanup:** cerrar sockets/subscripciones en unmount; cancelar streams con
   AbortController.

**Done cuando:** sobrevive a pérdida de red (reconecta y resincroniza), no fuga
conexiones, UI refleja estado de conexión y datos quedan consistentes.

---

## PB-17: Implementar/optimizar visualización de datos o dashboard

**Trigger:** charts, dashboards, mapas o tablas analíticas (nuevos o lentos/ilegibles).
**Modos:** B → C → E. Ref: [data-viz.md](data-viz.md).

1. **Definir intención y datos:** ¿qué decisión habilita cada gráfico? Tipo de
   encoding correcto (data-viz §3). Confirmar de dónde vienen los datos; si la
   agregación pertenece al servidor → escalar a `motor`/data, no calcular en cliente.
2. **Elegir técnica de render** por volumen real medido: HTML/SVG → Canvas → WebGL
   (data-viz §1). Empezar por la más accesible que rinda.
3. **Elegir librería** justificada por necesidad + bundle (declarativa vs bajo nivel
   vs data grid vs mapas vs big data); lazy-load la vista del dashboard (§2).
4. **Performance con dataset real:** downsampling (LTTB), agregación, virtualización,
   workers, render incremental; "no más puntos que pixels" (§4).
5. **Accesibilidad (obligatoria):** no-solo-color + paletas colorblind-safe, alt
   textual con la conclusión, **tabla de datos equivalente**, teclado, fallback DOM
   si Canvas/WebGL, `prefers-reduced-motion` (§5).
6. **Estados e interacción:** 4 estados del gráfico, tooltips accesibles, zoom/brush
   con reset, leyenda interactiva, responsive con ResizeObserver/container queries (§6).
7. **Theming:** tokens de datos (categórica/secuencial/divergente) + dark mode (§7).
8. **Tiempo real (si aplica):** ring buffer + append + throttle rAF + pausa en
   background (§8); transporte vía i18n-seo-realtime §3.
9. **SSR/compartir:** client-only diferido o imagen estática (satori/canvas) para
   SEO/email/OG (§9).
10. **Testing:** visual regression + datasets borde (vacío/1 punto/negativos/nulos/
    outliers) + axe (§10).

**Done cuando:** gráfico correcto para la intención, rinde con el dataset real,
es accesible (incluida tabla equivalente), responsive, consistente con el design
system y con la frontera de datos respetada. Checklist: [data-viz.md](data-viz.md) §12.
