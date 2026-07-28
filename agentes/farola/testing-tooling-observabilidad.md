# Testing, Tooling, Observabilidad y Deployment

Conocimiento profundo de farola en calidad automatizada, ecosistema de
herramientas, monitoreo cliente y operación del frontend.

---

## 1. Testing Frontend

### 1.1 Pirámide frontend

```
        ╱ E2E (pocos, críticos) ╲
       ╱ Integration (flujos)     ╲
      ╱ Component (UI + logic)     ╲
     ╱ Unit (utils, hooks, pure)   ╲
```

**Proporción orientativa:** 70% unit/component, 20% integration, 10% E2E.

### 1.2 Unit testing

**Qué testear:**
- Pure functions (formatters, validators, selectors).
- Custom hooks (renderHook + act).
- Reducers, state machines.

**Tools:** Vitest (Vite projects), Jest (CRA/Next legacy).

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

test('increments', () => {
  const { result } = renderHook(() => useCounter());
  act(() => result.current.increment());
  expect(result.current.count).toBe(1);
});
```

### 1.3 Component testing

**Testing Library philosophy:** test behavior, not implementation.

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('submits form', async () => {
  const user = userEvent.setup();
  render(<LoginForm onSubmit={mockSubmit} />);
  await user.type(screen.getByLabelText(/email/i), 'a@b.com');
  await user.click(screen.getByRole('button', { name: /sign in/i }));
  expect(mockSubmit).toHaveBeenCalledWith({ email: 'a@b.com' });
});
```

**Evita:** test por className interno, snapshot de todo el árbol sin criterio.

### 1.4 Integration testing

- Flujos multi-componente con MSW mocking API.
- Router integration (MemoryRouter wrapper).
- Form submit → API mock → UI update.

```typescript
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

const server = setupServer(
  http.get('/api/products', () => HttpResponse.json([{ id: 1, name: 'A' }]))
);
```

### 1.5 E2E (perspectiva frontend)

**Tools:** Playwright (recomendado), Cypress.

**Qué cubrir:**
- Auth flow crítico.
- Checkout / conversión principal.
- CRUD principal happy path + 1 error path.

```typescript
test('login flow', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@test.com');
  await page.getByLabel('Password').fill('secret');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page).toHaveURL('/dashboard');
});
```

**E2E no reemplaza** unit/component — es red de seguridad cara y frágil.

### 1.6 Visual regression

- Storybook + Chromatic o Percy.
- Snapshots de componentes en variants/states.
- Catch unintended CSS changes.

### 1.7 Contract testing (UI-API)

- **MSW** handlers como contrato informal en dev/test.
- **Pact** consumer-driven: frontend define expectativas; backend verifica.
- OpenAPI types generados (`openapi-typescript`) — compile-time contract.

### 1.8 Cobertura útil

- Target: 80%+ en utils/hooks críticos; no obsesión global.
- Coverage de componentes con lógica; no de presentational puro trivial.
- Mutation testing opcional en lógica crítica (Stryker).

### 1.9 Testing strategy document

Define por proyecto:
- Qué va en cada capa.
- CI gates (lint, typecheck, unit, e2e smoke).
- Flaky test policy (quarantine, fix SLA).
- Who writes what (dev owns unit/component; QA colabora E2E).

---

## 2. Tooling y ecosistema

### 2.1 Package managers

| Tool | Notas |
|------|-------|
| pnpm | Disk efficient, strict node_modules — recomendado monorepos |
| npm | Default, workspaces OK |
| yarn berry | PnP opcional; zero-installs posible |

Lockfile siempre committed. `engines` en package.json.

### 2.2 Bundlers

| Tool | Uso |
|------|-----|
| Vite | SPA, librerías — dev speed excelente |
| Webpack | Legacy, Module Federation |
| Rollup | Library builds |
| esbuild/swc | Transpile speed en CI |
| Turbopack | Next.js dev/build evolution |

### 2.3 Linters y formatters

**ESLint flat config (ESLint 9+):**
```javascript
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y';

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.strict,
  { plugins: { 'react-hooks': reactHooks, 'jsx-a11y': jsxA11y } },
);
```

**Prettier** o Biome para format. No discutir style en PR — automate.

**eslint-plugin-jsx-a11y** en CI.

### 2.4 Pre-commit

```json
{
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{ts,tsx}": "vitest related --run"
  }
}
```

Husky + lint-staged.

### 2.5 Storybook

- Documenta design system.
- `@storybook/addon-a11y`
- Interaction tests (`@storybook/test`)
- Visual tests via Chromatic

### 2.6 Build pipelines frontend (CI)

```yaml
# Ejemplo conceptual GitHub Actions
jobs:
  frontend:
    steps:
      - run: pnpm install --frozen-lockfile
      - run: pnpm typecheck
      - run: pnpm lint
      - run: pnpm test --coverage
      - run: pnpm build
      - run: pnpm exec lhci autorun  # Lighthouse CI opcional
```

**Cache:** pnpm store, turbo remote cache.

### 2.7 Documentación técnica frontend

- README: setup, scripts, env vars.
- CONTRIBUTING: conventions, PR checklist.
- Architecture doc: folder structure, patterns.
- ADRs en `docs/decisions/` para decisiones frontend.
- Storybook como docs vivas de componentes.

---

## 3. Observabilidad frontend

### 3.1 Real User Monitoring (RUM)

```typescript
import { onCLS, onINP, onLCP } from 'web-vitals';

function sendToAnalytics(metric) {
  // Datadog, GA4, custom endpoint
}

onCLS(sendToAnalytics);
onINP(sendToAnalytics);
onLCP(sendToAnalytics);
```

> **Ownership:** la observabilidad de performance (RUM de web-vitals, budgets,
> dashboards de CWV, umbrales y alertas) es de **`peakformance`**; farola
> **instrumenta** en el cliente lo que peakformance especifique y le entrega la
> señal. El error tracking y demás observabilidad de cliente (§3.2+) sí es de farola.

### 3.2 Error tracking

**Sentry (ejemplo):**
```typescript
Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN,
  integrations: [Sentry.browserTracingIntegration()],
  tracesSampleRate: 0.1,
  beforeSend(event) {
    // redact PII
    return event;
  },
});
```

- Source maps upload en CI (privados).
- Breadcrumbs: navigation, clicks, API failures.
- Release tracking: `release: git-sha`.

### 3.3 Telemetría y analytics

- Eventos producto: schema tipado, no stringly-typed chaos.
- Privacy: consent (GDPR), anonymize IP, no PII en events.
- Performance marks: `performance.mark/measure` para operaciones críticas.

### 3.4 Session awareness

- Session replay (LogRocket, FullStory) — privacy masking inputs.
- Correlation ID: header `X-Request-ID` en API + log cliente.

### 3.5 Logging útil cliente

```typescript
const logger = {
  debug: (...args) => { if (import.meta.env.DEV) console.debug(...args); },
  error: (err, context) => { Sentry.captureException(err, { extra: context }); },
};
```

**No** `console.log` PII en producción.

### 3.6 Diagnóstico producción

Playbook:
1. Sentry issue → stack trace + breadcrumbs.
2. Repro en staging con same release.
3. Check RUM metrics regression timeline.
4. Feature flag kill switch si crítico.
5. Hotfix branch → deploy → verify metrics.

---

## 4. Despliegue y operación frontend

### 4.1 Estrategias de build y release

| Estrategia | Uso |
|------------|-----|
| Static deploy | SSG → S3/GCS/Vercel/Netlify |
| SSR deploy | Node server, serverless (Vercel/Cloud Run) |
| Container | Docker + CDN para assets |
| Edge | Workers/Pages con SSR en edge |

### 4.2 Versionado

- Semver app si expone API pública o app stores.
- Design system packages: semver estricto.
- Git tags ↔ releases ↔ Sentry release.

### 4.3 CDN awareness

- Assets estáticos en CDN con cache largo + hash en filename.
- HTML: cache corto o stale-while-revalidate.
- Purge CDN en deploy si no hash-based.

### 4.4 Cache busting

```
app.[contenthash].js
main.[contenthash].css
```

`index.html` no cacheable o max-age bajo.

### 4.5 Ambientes

- dev / preview (per PR) / staging / production.
- Env vars por ambiente; nunca prod secrets en preview público.
- Preview URLs para QA + design review.

### 4.6 Feature flags

```typescript
if (flags.newDashboard) return <DashboardV2 />;
return <DashboardV1 />;
```

Tools: LaunchDarkly, Unleash, Flagsmith, PostHog.

- Kill switch para features riesgosas.
- Gradual rollout % users.

### 4.7 Rollback awareness

- Static: redeploy previous artifact (instant).
- SSR: rollback container/image; DB migrations may block — coordina backend.
- Feature flag off faster than redeploy.

### 4.8 Impacto despliegues en UX

- Deploy during low traffic si posible.
- Skeleton/stale content during deploy OK; hard errors not.
- Communicate maintenance if downtime unavoidable (rare en static/SSR bien hecho).

---

## 5. Calidad de código y mantenibilidad

### 5.1 Code review frontend (checklist)

- [ ] Correctness + edge cases
- [ ] 4 UI states
- [ ] a11y (semantic, keyboard, labels)
- [ ] Performance (unnecessary re-renders, bundle impact)
- [ ] Security (XSS, secrets)
- [ ] Tests adequate
- [ ] Matches conventions

### 5.2 Refactorización

- Extract component cuando >150 líneas o reused 2+.
- Extract hook cuando lógica stateful reused.
- Codemods para renames masivos (jscodeshift).

### 5.3 Deuda técnica frontend

Track en backlog:
- Framework version lag >2 major.
- No TypeScript / loose mode.
- Missing tests en critical paths.
- Design system drift.
- Bundle size creep.

Prioriza por impacto usuario + frecuencia cambio código.

### 5.4 Gobernanza repositorio

- Branch protection: require CI, 1+ review.
- CODEOWNERS para `/packages/ui`, `/src/features/auth`.
- Conventional commits optional but useful for changelogs.
