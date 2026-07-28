# Performance, Accesibilidad y Seguridad Frontend

Conocimiento de farola en implementación performante, inclusión y seguridad del
lado cliente. **Nota de ownership:** la **estrategia de performance** (metas
Core Web Vitals, budgets, profiling, RUM/medición y optimización profunda) es
del agente **`peakformance`**; farola conserva la **implementación performante**
como craft y respeta los budgets que peakformance define (ver §1 y
[governance-ia-interop.md](governance-ia-interop.md) §4.6).

---

## 1. Implementación performante (craft de farola) + handoff a `peakformance`

farola **no es dueño** de la estrategia de performance, pero **sí** escribe
frontend eficiente por oficio. Reparto de responsabilidad:

**farola conserva (craft — lo aplica siempre, sin esperar orden):**
- Componentes eficientes: evita re-renders innecesarios, trabajo pesado en el
  hilo principal y bloat obvio de dependencias.
- Code splitting / lazy loading sensato por ruta y componentes pesados
  (`React.lazy`/dynamic import, `Suspense`), third-party on-interaction.
- Imágenes dimensionadas y responsive (`width/height`, `srcset`, `loading="lazy"`,
  AVIF/WebP), fuentes con `font-display` y subsetting.
- Virtualización de listas largas, `startTransition`, debounce/throttle,
  memoización **después de medir**.
- Percepción de velocidad al implementar (skeletons, optimistic UI) — la
  **intención** de UX es de `uxuifull`; farola la **implementa**.
- **Respetar los performance budgets** que `peakformance` fije por ruta.

**farola cede a `peakformance` (ownership — hace handoff, no decide solo):**
- Metas Core Web Vitals (LCP/INP/CLS) y su definición por ruta.
- Performance budgets (JS/CSS/imagen), su umbral y su enforcement en CI.
- Profiling, análisis de bundle, critical-path y hydration strategy como
  disciplina de optimización profunda.
- Medición y observabilidad de performance: RUM (`web-vitals`), Lighthouse CI,
  CrUX, dashboards de métricas.
- Estrategia/roadmap de performance y priorización de optimizaciones.

**Handoff:** cuando una tarea requiere fijar metas/budgets, auditar CWV,
perfilar o diseñar una estrategia de optimización, farola **escala a
`peakformance`** (protocolo en [governance-ia-interop.md](governance-ia-interop.md)
§4.6) y ejecuta en su capa lo que peakformance especifique. El detalle técnico
histórico de esta sección vive ahora en el material base de `peakformance`.

---

## 2. Accesibilidad (WCAG 2.2)

### 2.1 Principios POUR

- **Perceivable:** alternativas texto, contraste, adaptable.
- **Operable:** teclado, tiempo suficiente, no seizures.
- **Understandable:** legible, predecible, input assistance.
- **Robust:** compatible AT, valid markup.

### 2.2 Nivel objetivo

- **AA mínimo** en todo producto.
- **AAA** donde regulación o riesgo (salud, gobierno, banca).

### 2.3 Semántica primero

```html
<!-- ❌ -->
<div onclick="submit()" class="btn">Enviar</div>

<!-- ✅ -->
<button type="submit">Enviar</button>
```

ARIA solo cuando HTML nativo no alcanza (tabs custom, combobox).

### 2.4 Teclado

- Tab order lógico (`tabindex="0"`; evita positive tabindex).
- Enter/Space en buttons.
- Escape cierra modals/menus.
- Arrow keys en tabs, menús, listbox (APG patterns).
- Skip link a main content.

### 2.5 Focus management

```typescript
// Al abrir modal
dialogRef.current?.focus();
// Al cerrar
triggerRef.current?.focus();
```

- Focus trap en modal (`focus-trap-react` o Radix Dialog).
- Focus visible: `:focus-visible` styles; nunca `outline: none` sin reemplazo.

### 2.6 Screen readers

- `aria-live="polite"` toasts; `assertive` errores críticos.
- `aria-expanded`, `aria-controls`, `aria-selected` en widgets.
- Nombres accesibles: `aria-label` o labelledby cuando texto visible no basta.
- Anuncios de loading: `aria-busy="true"`.

### 2.7 Contraste

- Texto normal: 4.5:1 (AA).
- Texto grande (18pt+ o 14pt bold): 3:1.
- UI components/graphical: 3:1 (WCAG 2.1 1.4.11).
- No confiar solo en color (icono + texto).

### 2.8 Formularios accesibles

- Label visible o aria-label.
- Required: `required` + indicador visual/texto.
- Errors: `aria-invalid="true"`, `aria-describedby` al error.
- Agrupación: fieldset/legend o role="group".

### 2.9 Patrones complejos (WAI-ARIA APG)

Implementa según spec: Combobox, Dialog, Tabs, Treeview, Data Grid, Toast.
Prefer Radix/Headless que ya implementan APG.

### 2.10 Testing a11y

```typescript
// Playwright + axe
import AxeBuilder from '@axe-core/playwright';

test('homepage a11y', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations).toEqual([]);
});
```

Manual: VoiceOver/NVDA/JAWS spot checks; keyboard-only walkthrough.

### 2.11 WCAG 2.2 nuevos criterios relevantes

- **2.4.11 Focus Not Obscured (AA):** focus no hidden by sticky elements.
- **2.5.7 Dragging Movements (AA):** alternativa single-pointer sin drag.
- **3.2.6 Consistent Help (A):** help en misma ubicación relativa.
- **3.3.7 Redundant Entry (A):** no re-pedir datos ya ingresados.
- **3.3.8 Authentication (AA):** no cognitive function test solo.

---

## 3. Seguridad Frontend

### 3.1 XSS (Cross-Site Scripting)

**Tipos:**
- Stored: malicioso persistido en DB → renderizado.
- Reflected: en URL params.
- DOM-based: sinks inseguros en JS (`innerHTML`, `eval`, `document.write`).

**Mitigación:**
```typescript
import DOMPurify from 'dompurify';

<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userHtml) }} />
```

- React/Vue escapan por defecto en `{}` — riesgo en raw HTML.
- CSP como capa adicional (coordinar con backend/DevOps).
- Nunca `eval()`, `new Function()` con input usuario.

### 3.2 CSRF awareness

- SameSite cookies (`Strict`/`Lax`).
- Custom headers (X-Requested-With) — no bulletproof solo.
- CSRF tokens en forms state-changing — backend emite, frontend incluye.
- SPA con cookies: entender SameSite + CORS credentials.

### 3.3 Manejo de tokens

| Storage | Riesgo | Uso |
|---------|--------|-----|
| httpOnly cookie | XSS no lee | **Preferido** refresh/session |
| memory (variable) | Pierde en refresh | Access token corto |
| localStorage | XSS lee todo | Evitar tokens sensibles |
| sessionStorage | Igual localStorage | Temporal OK no-sensitive |

**PKCE** en OAuth public clients (SPA).

### 3.4 Exposición de datos

- No loguear PII en console/production logs.
- Redact en error reports (Sentry beforeSend).
- Minimize data en cliente; paginar; no dump completo API.

### 3.5 Secretos en cliente

**Nunca:** private API keys, DB credentials, signing secrets.

**Aceptable:** public anon keys (Supabase/Firebase) diseñadas con RLS/rules server.

Env vars `VITE_*` / `NEXT_PUBLIC_*` van al bundle — asume públicos.

### 3.6 Sanitización

- HTML: DOMPurify.
- URLs: validar protocol (`javascript:` blocked).
- CSS user content: restrict (no `expression`, no `url()` arbitrary).

### 3.7 Dependencias (supply chain)

```bash
npm audit
npx socket npm audit  # deeper analysis
```

- Lockfile committed.
- Renovate/Dependabot.
- Review nuevas deps: mantenimiento, bundle size, permisos.

### 3.8 iframes y postMessage

```typescript
window.addEventListener('message', (event) => {
  if (event.origin !== 'https://trusted.com') return;
  // handle
});
```

- `sandbox` attribute en iframes untrusted.
- `referrerpolicy` en embeds.

### 3.9 CSP awareness (frontend)

Entiende directivas que afectan frontend:
- `script-src 'self'` — inline scripts blocked unless nonce.
- `style-src` — inline styles.
- `frame-ancestors` — clickjacking.

Coordina con DevOps; frontend evita inline scripts/styles cuando CSP estricta.

### 3.10 Client-side attack surfaces

- Open redirects en `window.location = param`.
- Prototype pollution vía merge unsafe (lodash <4.17.21).
- Clickjacking: X-Frame-Options / CSP frame-ancestors (server).
- Prototype XSS en `JSON.parse` + render — validar schema.

---

## 4. Checklist integrado pre-release

```
Performance (craft de farola; metas/budgets los define peakformance):
- [ ] Implementación eficiente: sin re-renders/bundle bloat evidentes
- [ ] Images sized and lazy; code splitting en rutas/componentes pesados
- [ ] Cumple los performance budgets fijados por peakformance (si existen)
- [ ] Escalado a peakformance lo que requiera medición/optimización profunda

Accesibilidad:
- [ ] axe clean en rutas críticas
- [ ] Keyboard walkthrough passed
- [ ] Focus management en modals

Seguridad:
- [ ] No secrets in diff
- [ ] User HTML sanitized
- [ ] npm audit no high/critical unmitigated
- [ ] Auth tokens not in localStorage (unless justified)
```
