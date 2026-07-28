# Plantillas Operativas — farola

Plantillas reutilizables para entregables del Primer Maestro de Frontend Engineering.

---

## 1. Auditoría técnica frontend

```markdown
# Auditoría Frontend — [Producto/Repo] — [Fecha]
**Auditor:** farola · **Alcance:** [módulos/rutas] · **Estado:** brownfield|greenfield

## 1. Resumen ejecutivo
[3-5 líneas: salud general, score madurez X/5, top 3 acciones]

## 2. Contexto
| Campo | Valor |
|-------|-------|
| Stack | |
| Canal | |
| Browsers | |
| Restricciones | |

## 3. Score de madurez (1-5)
| Dimensión | Score | Evidencia |
|-----------|-------|-----------|
| Arquitectura | | |
| Performance | | |
| Accesibilidad | | |
| Seguridad | | |
| Testing | | |
| Mantenibilidad | | |
| Escalabilidad | | |
| Consistencia UI | | |
| DX | | |

## 4. Hallazgos
### 🔴 Críticos
| ID | Hallazgo | Ubicación | Impacto | Recomendación |
|----|----------|-----------|---------|---------------|

### 🟠 Altos / 🟡 Medios / 🟢 Bajos
[idem]

## 5. Matriz de riesgos
| Riesgo | Prob | Impacto | Mitigación | Owner |
|--------|------|---------|------------|-------|

## 6. Quick wins (≤1 sprint)
1. ...

## 7. Roadmap recomendado
| Fase | Objetivo | Duración est. | Dependencias |
|------|----------|---------------|--------------|

## 8. Próximos pasos
- [ ] ...

## 9. Criterios de éxito
- [Métrica medible]
```

---

## 2. Propuesta arquitectónica frontend

```markdown
# Propuesta Arquitectónica Frontend — [Título]
**Autor:** farola · **Estado:** Propuesto · **Fecha:**

## 1. Problem statement
[Qué problema resuelve, por qué ahora]

## 2. Contexto y restricciones
- Equipo: [size, skills]
- Plazo: 
- Stack actual/fijo:
- Atributos calidad top 3: 

## 3. Alternativas

### Opción A: [nombre]
**Descripción:** ...
**Pros:** ...
**Contras:** ...

### Opción B: [nombre]
...

### Opción C (opcional): [nombre]
...

## 4. Matriz de trade-offs
| Criterio | Peso | A | B | C |
|----------|------|---|---|---|
| Mantenibilidad | | | | |
| Performance | | | | |
| DX | | | | |
| Reversibilidad | | | | |
| Costo implementación | | | | |

## 5. Recomendación
**Opción elegida:** [X]
**Justificación:** ...
**Riesgos:** ...
**Plan reversión:** ...

## 6. Blueprint
```
[estructura carpetas / diagrama C4 component level]
```

## 7. ADR
### ADR-[NNN]: [título]
- **Contexto:**
- **Decisión:**
- **Consecuencias:**

## 8. Plan implementación
| Fase | Entregable | Criterio done |
|------|------------|---------------|

## 9. Criterios de éxito medibles
```

---

## 3. Análisis de performance

> **Ownership:** el análisis de performance (baseline, budgets, plan de
> optimización, gates) lo **lidera `peakformance`**; farola aporta la vista de
> implementación frontend y ejecuta las optimizaciones de su capa. Plantilla
> compartida.

```markdown
# Análisis Performance — [Ruta/App] — [Fecha]
**Analista:** farola

## 1. Baseline
| Métrica | Lab (Lighthouse) | RUM p75 | Target |
|---------|------------------|---------|--------|
| LCP | | | ≤2.5s |
| INP | | | ≤200ms |
| CLS | | | ≤0.1 |
| TBT | | | |
| JS transfer | | | |

## 2. Critical path
[Waterfall description / LCP element identification]

## 3. Bundle analysis
| Chunk | Size (gzip) | Acción |
|-------|-------------|--------|

## 4. Hallazgos
| ID | Issue | Impacto estimado | Fix |
|----|-------|------------------|-----|

## 5. Presupuesto propuesto
| Asset type | Budget |
|------------|--------|

## 6. Plan optimización
| Prioridad | Acción | Esfuerzo | Impacto esperado |
|-----------|--------|----------|------------------|

## 7. Verificación
- [ ] Lighthouse CI gate
- [ ] RUM monitoring post-deploy
```

---

## 4. Análisis de accesibilidad

```markdown
# Análisis Accesibilidad — [Scope] — [Fecha]
**Auditor:** farola · **Estándar:** WCAG 2.2 AA

## 1. Metodología
- Automated: axe-core [routes]
- Manual: keyboard, VoiceOver/NVDA spot check
- Scope: [pages/components]

## 2. Resumen
- Violations critical: N
- Violations serious: N
- WCAG conformance: [Partial AA / AA / Fail]

## 3. Hallazgos por criterio WCAG
| Criterio | Level | Issue | Location | Fix |
|----------|-------|-------|----------|-----|

## 4. Componentes afectados
| Componente | Issues | Priority |
|------------|--------|----------|

## 5. Plan remediación
| Sprint | Items | Owner |
|--------|-------|-------|

## 6. Prevención
- [ ] jsx-a11y en CI
- [ ] axe en E2E critical paths
- [ ] Storybook addon-a11y
- [ ] PR checklist a11y
```

---

## 5. Análisis de seguridad frontend

```markdown
# Análisis Seguridad Frontend — [App] — [Fecha]
**Analista:** farola · **Scope:** client-side attack surface

## 1. Resumen
[Risk level: Low/Medium/High] — [N findings]

## 2. Attack surface inventory
- Auth mechanism:
- Token storage:
- User-generated content render:
- Third-party scripts:
- iframe/embed usage:

## 3. Hallazgos
| ID | Tipo | Severidad | Location | Remediation |
|----|------|-----------|----------|-------------|
| FE-001 | XSS | Critical | | |

## 4. Dependency audit
| Package | CVE | Severity | Action |
|---------|-----|----------|--------|

## 5. CSP alignment
| Directiva | Estado | Recomendación |
|-----------|--------|---------------|

## 6. Plan remediación priorizado
```

---

## 6. Revisión de stack

```markdown
# Revisión Stack Frontend — [Proyecto] — [Fecha]

## Stack actual
| Capa | Tecnología | Versión | Estado |
|------|------------|---------|--------|
| Framework | | | |
| Bundler | | | |
| CSS | | | |
| State | | | |
| Testing | | | |
| CI | | | |

## Fit assessment
[¿El stack sirve objetivos actuales y 12-24 meses?]

## Upgrade paths
| Component | Current | Latest | Breaking | Recomendación |
|-----------|---------|--------|----------|---------------|

## Alternativas (si replatform)
[2-3 con trade-offs]

## Recomendación farola
```

---

## 7. Plan de modernización

```markdown
# Plan Modernización Frontend — [Proyecto]

## Estado actual → Objetivo
[Descripción transformación: ej. AngularJS → React, CRA → Vite]

## Estrategia
[Strangler fig / big-bang / incremental — con justificación]

## Fases
### Fase 0 — Preparación
- [ ] Tests E2E red de seguridad
- [ ] Inventory componentes
- [ ] ADR arquitectura target

### Fase 1 — [nombre]
...

## Riesgos y mitigaciones
## Rollback plan por fase
## Métricas éxito
```

---

## 8. Informe liderazgo técnico

Ver template en [governance-ia-interop.md](governance-ia-interop.md) §5.

---

## 9. Checklist release frontend

```markdown
# Release Checklist Frontend — v[X.Y.Z]

## Pre-merge
- [ ] CI green (typecheck, lint, test, build)
- [ ] PR review frontend checklist
- [ ] No secrets in diff
- [ ] CHANGELOG updated

## Quality
- [ ] 4 estados UI en features nuevas
- [ ] axe clean critical routes
- [ ] Lighthouse no regression (or justified)
- [ ] Bundle size within budget

## Security
- [ ] npm audit no unmitigated critical
- [ ] User content sanitized

## Deploy
- [ ] Env vars set in target
- [ ] Feature flags configured
- [ ] Source maps uploaded (private)
- [ ] CDN cache strategy confirmed

## Post-deploy
- [ ] Smoke test critical paths
- [ ] RUM metrics stable (30 min)
- [ ] Sentry no new error spike
- [ ] Rollback artifact identified
```

---

## 10. Guía de componente

```markdown
# Component: [Name]

## Purpose
[Una línea]

## API
| Prop | Type | Default | Description |
|------|------|---------|-------------|

## Variants
[primary, secondary, ghost...]

## States
- [ ] Empty / Loading / Error / Success / Disabled

## Accessibility
- Role:
- Keyboard:
- ARIA:
- WCAG criteria:

## Usage
```tsx
<Component variant="primary" />
```

## Anti-patterns
- Don't use for [X]; use [Y] instead
```

---

## 11. i18n readiness (template)

```markdown
# i18n Readiness — [App] — [Fecha]
**Auditor:** farola · Ref: i18n-seo-realtime.md §1

## 1. Locales
| Locale | Estado | Default | Fallback |
|--------|--------|---------|----------|
| es-CO | | sí | es → en |

## 2. Hallazgos
| ID | Issue | Tipo | Ubicación | Fix |
|----|-------|------|-----------|-----|
| I18N-001 | Texto hardcodeado | strings | | Extraer a catálogo |
| I18N-002 | Fecha con formato manual | formato | | Intl.DateTimeFormat |
| I18N-003 | Plural con if | plural | | ICU MessageFormat |

## 3. Cobertura
- Strings externalizados: N%
- Formatos vía Intl: sí/no
- RTL ready (logical props): sí/no
- Lazy-load de locale: sí/no

## 4. Plan
| Fase | Acción | Esfuerzo |
|------|--------|----------|

## 5. QA
- [ ] Pseudo-localización en CI
- [ ] Test claves faltantes / placeholders
- [ ] Layout no rompe en idioma más largo + RTL
```

---

## 12. Auditoría SEO técnico (template)

```markdown
# SEO Técnico Frontend — [Sitio] — [Fecha]
**Auditor:** farola · Estándar: SSR/markup + CWV · Ref: i18n-seo-realtime.md §2

## 1. Rendering
| Ruta | Estrategia | Contenido en HTML inicial | OG en server |
|------|------------|---------------------------|--------------|

## 2. Metadatos
| Ruta | title único | description | canonical | OG/Twitter | JSON-LD |
|------|-------------|-------------|-----------|-----------|---------|

## 3. Infraestructura
- [ ] sitemap.xml  - [ ] robots.txt  - [ ] hreflang + x-default
- [ ] 404 real (no soft-404)  - [ ] 301 en rutas migradas

## 4. Core Web Vitals (ranking)
| Métrica | p75 | Target |
|---------|-----|--------|
| LCP | | ≤2.5s |
| INP | | ≤200ms |
| CLS | | ≤0.1 |

## 5. Hallazgos priorizados
| ID | Issue | Impacto SEO | Fix |
|----|-------|-------------|-----|
```

---

## 13. Especificación de visualización / dashboard (template)

```markdown
# Spec Visualización — [Dashboard/Chart] — [Fecha]
**Autor:** farola · Ref: data-viz.md

## 1. Intención
| Gráfico | Decisión que habilita | Tipo (encoding) | Fuente de datos |
|---------|-----------------------|-----------------|-----------------|

## 2. Datos y frontera
- Volumen esperado (filas/puntos):
- Agregación: [cliente | servidor ← preferido]  · Owner si servidor: motor/data
- Frecuencia de actualización: [estática | polling | tiempo real]

## 3. Render y librería
| Decisión | Elección | Justificación |
|----------|----------|---------------|
| Técnica (HTML/SVG/Canvas/WebGL) | | volumen medido |
| Librería | | necesidad + bundle |
| Lazy-load | sí/no | |

## 4. Performance
- [ ] Downsampling/agregación  - [ ] Virtualización (tablas)
- [ ] Workers si parseo pesado  - [ ] Render incremental/streaming

## 5. Accesibilidad
- [ ] No-solo-color + paleta colorblind-safe
- [ ] Alt textual con conclusión  - [ ] Tabla de datos equivalente
- [ ] Teclado + fallback DOM (Canvas/WebGL)  - [ ] prefers-reduced-motion

## 6. Interacción y estados
- Estados: vacío / cargando / error / lleno
- Interacción: [tooltip | zoom | brush | crossfilter | leyenda toggle]
- Responsive: ResizeObserver / breakpoints

## 7. Theming
- Tokens de datos (categórica/secuencial/divergente) + dark mode

## 8. Testing
- [ ] Visual regression  - [ ] Datasets borde  - [ ] axe
```

---

## 14. Estrategia de estado (template)

```markdown
# Estrategia de Estado — [App]

## Clasificación datos
| Dato | Tipo | Solución | TTL/Invalidation |
|------|------|----------|------------------|

## Local state rules
[Cuándo useState vs useReducer]

## Global state
[Qué va global + librería]

## Server state
[Query keys convention, staleTime defaults]

## Forms
[Library + validation schema location]

## URL state
[Qué vive en search params]

## Diagram
[mermaid state flow]
```
