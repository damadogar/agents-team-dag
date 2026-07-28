# Governance, Liderazgo Técnico Frontend e IA

Conocimiento profundo de farola en gobernanza, liderazgo del área frontend,
IA aplicada al desarrollo frontend e interoperabilidad con agentes aliados.

---

## 1. Liderazgo técnico frontend

### 1.1 Definición de estándares

Documenta y socializa:
- **Architecture Decision Records (ADR)** para decisiones frontend.
- **Coding standards:** naming, file structure, import order.
- **Component guidelines:** when to create, API design, a11y requirements.
- **PR template** con checklist frontend.

### 1.2 Decisiones arquitectónicas

Proceso:
1. Problem statement + constraints.
2. 2-3 options with trade-offs matrix.
3. Recommendation + reversibility assessment.
4. ADR merged → communicate to team.

### 1.3 Mentoring técnico

- Pair on complex features.
- Review PRs with educational comments (why, not just what).
- Office hours for frontend questions.
- Internal talks: "how we do X".

### 1.4 Coordinación cross-funcional

| Área | Frontend lead aporta | Recibe |
|------|---------------------|--------|
| **uxuifull (UX/UI)** | Viabilidad técnica, constraints | Specs, tokens, flows, a11y criteria |
| **motor (backend)** | API contract needs, client errors | OpenAPI, auth flows, pagination |
| **amado (QA)** | Test IDs, critical paths, component states | E2E scenarios, bug reports |
| **certero (correctitud/review)** | Diff frontend con causa raíz + test (bug de estado/render/evento/borde de UI) | Review de correctitud, defectos de lógica/estado, gates de calidad de código |
| **baluarte (plataforma/entrega)** | Build config, env vars, necesidades de CDN | Pipeline CI/CD, targets de despliegue, infra/edge |
| **destroyer (seguridad)** | Client attack surface review | CSP headers, auth architecture |

### 1.5 Priorización deuda técnica frontend

Matriz: **Impacto usuario** × **Costo cambio** × **Frecuencia touch**.

Quick wins first; platform investments scheduled quarterly.

### 1.6 Evolución ecosistema frontend

Roadmap trimestral:
- Framework/tool upgrades.
- Design system milestones.
- Performance initiatives.
- Testing infrastructure.
- Developer experience improvements.

---

## 2. Frontend governance

### 2.1 Design system governance

- **Contribution model:** RFC → review → Storybook → release.
- **Breaking change policy:** semver + migration guide + codemod.
- **Deprecation:** warn 1 release, remove next major.

### 2.2 Dependency governance

- Approved library list (optional en enterprise).
- New dep requires: bundle size check, license, maintenance status.
- Regular dependency update cadence (weekly/monthly).

### 2.3 Quality gates

CI must pass:
- typecheck
- lint (incl. a11y plugin)
- unit tests
- build
- optional: Lighthouse budget, visual diff

### 2.4 Onboarding técnico

Day 1 productive target:
- README setup <30 min.
- Hello world PR (fix typo/docs) day 1.
- Architecture walkthrough recorded.
- Storybook tour.

---

## 3. IA aplicada a frontend

### 3.1 Uso productivo de LLMs

**Buenos usos:**
- Scaffolding component boilerplate.
- Generating test cases from component spec.
- Explaining legacy code.
- Regex/transform snippets.
- Accessibility audit suggestions (verify manually).
- CSS layout troubleshooting.

**Malos usos:**
- Copy-paste production code sin review.
- Security-sensitive logic (auth, crypto).
- Architecture decisions sin humano senior.
- Trusting a11y claims sin testing.

### 3.2 Revisión crítica de código generado por IA

Checklist obligatorio post-IA:

```
- [ ] ¿Sigue convenciones del repo?
- [ ] ¿TypeScript strict compatible?
- [ ] ¿4 estados UI?
- [ ] ¿Semántica HTML correcta?
- [ ] ¿ARIA solo donde necesario?
- [ ] ¿Keyboard navigable?
- [ ] ¿No secrets hardcoded?
- [ ] ¿No dangerouslySetInnerHTML sin sanitize?
- [ ] ¿Performance OK (no unnecessary effects/memos)?
- [ ] ¿Tests incluidos o plan de tests?
- [ ] ¿Deps nuevas justificadas?
- [ ] ¿Matches uxuifull spec si aplica?
```

### 3.3 Prompting para UI engineering

Template efectivo:
```
Context: [framework, design system, file path]
Task: [component/feature]
Requirements:
- States: empty, loading, error, success
- a11y: WCAG 2.2 AA, keyboard, focus
- Props API: [variants]
- Use existing: [Button from @/ui]
Do NOT: [inline styles, any type, class components]
Output: [component + test file]
```

### 3.4 Herramientas IA frontend (awareness)

- **Cursor/Copilot:** inline completion — review all.
- **v0/Vercel:** UI generation — extract patterns, don't deploy raw.
- **Bolt.new:** rapid prototype — rewrite for production standards.
- **Figma AI:** design assist — uxuifull validates.

### 3.5 Límites del uso de IA

- IA acelera; **no garantiza** calidad, a11y, security.
- Human senior review mandatory pre-merge.
- No IA para compliance-critical without audit.
- Keep skills/prompts updated; models drift.

### 3.6 Validación técnica humana

farola es el gate final en frontend. IA output = draft, not done.

---

## 4. Interoperabilidad con uxuifull y aliados

### 4.1 Relación farola ↔ uxuifull

| Agente | Dominio | Entrega a farola |
|--------|---------|------------------|
| **uxuifull** | UX/UI strategy, design, a11y criteria, content | Handoff §2.1 (spec accionable) |
| **farola** | Frontend engineering, implementación | Código + tests + verificación técnica |

**Jerarquía de criterio en implementación:**
1. Criterios de aceptación handoff uxuifull (experiencia + WCAG).
2. Restricciones técnicas reales (performance, stack).
3. Convenciones del repositorio.
4. Optimizaciones técnicas que NO alteren UX acordada.

Si conflicto técnico impide spec UX → **escalar a uxuifull** con alternativas
técnicas; no decidir solo silenciosamente.

### 4.2 Protocolo recepción handoff uxuifull

```
Progreso farola — Handoff uxuifull:
- [ ] 1. PARSE: leer paquete completo §2.1
- [ ] 2. CLARIFY: listar ambigüedades → preguntar o [SUPUESTO]
- [ ] 3. FEASIBILITY: señalar constraints técnicos sin cambiar UX aún
- [ ] 4. PLAN: archivos a crear/modificar, orden implementación
- [ ] 5. IMPLEMENT: estados, tokens, microcopy, a11y, responsive
- [ ] 6. VERIFY: criterios aceptación + axe + keyboard
- [ ] 7. REPORT: drift log si algo difiere + pedir validación uxuifull
```

### 4.3 Protocolo retorno a uxuifull (validación)

Al completar implementación de handoff, farola produce:

```markdown
## Implementación completada — [título]
Handoff ref: [link/id]
Archivos modificados: [...]

### Criterios de aceptación
- [x] [criterio 1] — evidencia: [test/screenshot]
- [x] WCAG AA — evidencia: axe report

### Drift report (si aplica)
| Spec UX | Implementado | Razón |
|---------|--------------|-------|
| ... | ... | constraint técnico |

### Pendiente validación uxuifull
[Lista para modo E validación]
```

uxuifull ejecuta validación post-implementación (§2.1 interoperabilidad).

### 4.4 Aliados adicionales

| Agente | Cuándo escalar desde farola |
|--------|----------------------------|
| **motor** | API changes, auth server-side, data model |
| **eneida** | Decisiones arquitectura full-system, ADR cross-cutting |
| **peakformance** | Metas/budgets CWV, profiling, RUM, estrategia y optimización profunda de performance |
| **destroyer** (seguridad) | Threat model beyond client surface |
| **baluarte** (plataforma/entrega) | Pipeline CI/CD, build/deploy, CDN/edge como infra, entornos y release engineering |
| **certero** (correctitud/review) | Review de correctitud del código frontend, debugging de un defecto de lógica/estado con causa raíz |
| **palma** | App móvil nativa/cross-platform (iOS/Android, RN/Flutter/KMP), shell nativo del híbrido, capacidades de dispositivo, push nativo, release en tiendas — farola conserva responsive web, PWA y la UI web del híbrido |
| **amado** (QA) | Test plans negocio, regresión release |

farola **implementa** frontend; escala dependencias, no las resuelve fuera de dominio.

### 4.5 Skill aliada ui-ux-pro-max

farola puede consultar `ui-ux-pro-max` para **implementar** tokens visuales
recibidos de uxuifull, pero **no** redefine estrategia UX. Jerarquía:
uxuifull spec > repo design tokens > ui-ux-pro-max suggestions.

### 4.5b Skill aliada r3f-webgl (3D/WebGL scroll-driven)

farola puede consultar `r3f-webgl` como insumo técnico para **implementar**
escenas WebGL 3D reales orquestadas por scroll (ej. producto que se
ensambla/desensambla con el scroll) una vez que `eneida` decidió WebGL real
frente a pseudo-3D con CSS transforms. No decide esa arquitectura ni la
experiencia (`uxuifull`) — cubre el patrón scroll→progreso, presupuesto de
rendimiento, pipeline de assets GLTF y fallback de accesibilidad. Jerarquía:
ADR de `eneida` > spec de experiencia de `uxuifull` > r3f-webgl (craft).

### 4.6 Relación farola ↔ peakformance (performance)

`peakformance` es el **dueño** del performance del ecosistema (frontend +
backend/infra): define metas Core Web Vitals y performance budgets, hace
profiling, mide (RUM / Lighthouse CI / CrUX) y lidera la optimización profunda y
la estrategia. farola conserva la **implementación performante** como craft y
**respeta** esos budgets.

| Agente | Dominio de performance | Entrega |
|--------|------------------------|---------|
| **peakformance** | Metas/budgets CWV, profiling, RUM, estrategia, optimización profunda | Budgets por ruta, hallazgos de auditoría, roadmap de optimización |
| **farola** | Implementación performante en frontend (craft) | Código eficiente que cumple los budgets; instrumenta lo que peakformance especifique |

**Handoff farola → peakformance** (cuando hay que fijar metas/budgets, auditar
CWV, perfilar o diseñar estrategia): farola escala con contexto (rutas, stack,
constraints) y ejecuta en su capa lo que peakformance defina; no decide la
estrategia de performance en solitario.

**Handoff peakformance → farola:** peakformance entrega budgets/metas y
hallazgos; farola implementa las optimizaciones de su capa y reporta
cumplimiento.

Si un budget de performance choca con una decisión de UX de `uxuifull`, se
reconcilia entre los tres: `uxuifull` (experiencia) · `peakformance` (límite de
performance) · farola (implementación viable).

---

## 5. Informes para liderazgo

### 5.1 Informe ejecutivo (template breve)

```markdown
# Frontend Status — [Producto] — [Fecha]

## Resumen
[2-3 oraciones: salud general, riesgo principal, win principal]

## Métricas clave
| Métrica | Actual | Target | Trend |
|---------|--------|--------|-------|
| LCP p75 | 2.1s | ≤2.5s | ↓ |
| Error rate | 0.3% | <0.5% | → |

## Riesgos top 3
1. [Riesgo] — impacto — mitigación

## Iniciativas en curso
- [Initiative] — ETA — status

## Decisiones requeridas
- [Decision needed from leadership]
```

### 5.2 Informe técnico

Profundidad completa: arquitectura, deuda, ADRs pendientes, upgrade paths,
benchmarks, security findings, test coverage gaps.

---

## 6. Madurez y mejora continua

- Quarterly frontend health assessment (§14 SKILL.md scoring).
- Post-incident reviews frontend (client errors, perf regressions).
- Benchmark against industry (Web Almanac, State of JS).
- Update skill knowledge via CHANGELOG when major ecosystem shifts.
