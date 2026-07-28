# Fundamentos y Arquitectura Frontend

Conocimiento profundo de farola en fundamentos web y arquitectura de aplicaciones
frontend. Consultar cuando el problema sea estructural, de base tecnológica o de
organización del sistema.

---

## 1. Fundamentos web

### 1.1 HTML semántico

- Usa elementos por **significado**, no por apariencia: `button` vs `div onclick`,
  `nav`, `main`, `article`, `section`, `aside`, `header`, `footer`.
- **Heading hierarchy:** un `h1` por vista; no saltar niveles (h1→h3).
- **Landmarks:** facilitan navegación por screen reader; no duplicar `main`.
- **Formularios:** `label` asociado (`for`/`id` o wrap); `fieldset`/`legend` para
  grupos; tipos de input correctos (`email`, `tel`, `url`, `number`).
- **Tablas:** `th` + `scope`; datos tabulares reales, no layout tables.
- **Imágenes:** `alt` descriptivo o vacío (`alt=""`) si decorativa.
- **Links vs buttons:** navegación → `a href`; acciones in-page → `button`.

### 1.2 CSS avanzado

**Cascade y especificidad:** entiende origen, importancia, especificidad, orden.
Prefiere baja especificidad + `@layer` para control predecible.

**Layout moderno:**
- Flexbox: alineación 1D, gaps, `flex-shrink/grow`, `min-width: 0` en hijos.
- Grid: layouts 2D, `subgrid`, áreas nombradas, `auto-fit/minmax`.
- Container Queries: responsive por contenedor, no solo viewport.

**Custom properties (tokens):**
```css
:root {
  --color-primary: oklch(55% 0.2 250);
  --space-4: 1rem;
  --radius-md: 0.375rem;
}
```

**Logical properties:** `margin-inline`, `padding-block`, `inset-inline-start`
para i18n/RTL.

**Performance CSS:** anima `transform`/`opacity`; evita `width/height/top/left`
en animaciones frecuentes. `content-visibility: auto` en listas largas.

### 1.3 JavaScript / TypeScript

**Event loop:** call stack, task queue, microtasks (Promises), macrotasks
(setTimeout). Entiende por qué `await` cede control.

**Closures y scope:** módulos ESM, no polluting global.

**Patrones frontend:**
- Module pattern, factory functions, composition.
- Inmutabilidad preferida para state updates (React, signals).
- Discriminated unions para estados finitos de UI.

**TypeScript estricto:**
```json
{
  "strict": true,
  "noUncheckedIndexedAccess": true,
  "exactOptionalPropertyTypes": true
}
```

Evita `any`; usa `unknown` + narrowing. Tipos para props de componentes,
API responses (generados o Zod infer).

### 1.4 DOM y renderizado del navegador

**Pipeline:** HTML parse → DOM → CSSOM → Render Tree → Layout → Paint → Composite.

**Reflow triggers:** cambios geométricos (width, font-size, DOM insert). Batch reads
then writes; usa `requestAnimationFrame` para animaciones.

**Event model:** capturing → target → bubbling. `stopPropagation` con criterio.
Event delegation para listas dinámicas.

**Shadow DOM / Web Components:** encapsulación CSS; interoperabilidad con
frameworks vía wrappers o `@lit/react`.

### 1.5 HTTP aplicado al frontend

- **Caching:** `Cache-Control`, `ETag`, stale-while-revalidate en service workers.
- **CORS:** preflight; el frontend consume, no configura servidor (awareness).
- **Cookies:** `SameSite`, `Secure`, `HttpOnly` (HttpOnly no accesible desde JS).
- **Compression:** Brotli/gzip awareness en assets estáticos.

### 1.6 Asincronía y consumo de APIs

```typescript
// Patrón robusto con abort
const controller = new AbortController();
const data = await fetch(url, { signal: controller.signal });
// cleanup: controller.abort() en unmount
```

- Retry con exponential backoff + jitter.
- Timeout explícito.
- Error taxonomy: network, 4xx, 5xx, parse, abort.
- Normalización de respuestas en capa de API (no en componentes).

---

## 2. Arquitectura de aplicaciones frontend

### 2.1 Patrones organizacionales

**Feature-Sliced Design (FSD):**
```
src/
  app/          # providers, router, global styles
  pages/        # composición por ruta
  widgets/      # bloques UI compuestos
  features/     # acciones de usuario (auth, add-to-cart)
  entities/     # modelos de negocio UI (user, product)
  shared/       # ui kit, api, lib, config
```

**Layered (alternativa válida):**
```
src/
  components/   # ui + composite
  hooks/
  services/     # api clients
  stores/
  pages/
  utils/
```

Elige uno; **consistencia > dogma**.

### 2.2 Separación de responsabilidades

| Capa | Responsabilidad | No debe |
|------|-----------------|---------|
| Presentational | Render, estilos, a11y | Fetch API directo |
| Container/Smart | Orquestar data + handlers | Estilos complejos inline |
| Hooks | Lógica reutilizable stateful | JSX extenso |
| Services/API | HTTP, transformación | Conocer React |
| Stores | Estado global UI | Lógica de servidor duplicada |

### 2.3 Composición y component API

**Compound components:** `Tabs`, `Tabs.List`, `Tabs.Panel` — context interno.

**Variants (CVA):**
```typescript
const buttonVariants = cva("inline-flex items-center", {
  variants: {
    variant: { primary: "bg-primary", ghost: "bg-transparent" },
    size: { sm: "h-8 px-3", md: "h-10 px-4" },
  },
  defaultVariants: { variant: "primary", size: "md" },
});
```

**Polymorphic `as` prop:** extiende semántica (`Button as="a"`).

### 2.4 Microfrontends

| Enfoque | Pros | Contras |
|---------|------|---------|
| Module Federation | Compartir deps, runtime integration | Complejidad build |
| iframe | Aislamiento total | UX, performance, a11y |
| Web Components | Framework agnostic | DX, SSR complejo |
| Monorepo + apps | Simplicidad relativa | Deploy acoplado si no CI separado |

**Cuándo:** equipos autónomos, dominios claros, release independiente **real**.

### 2.5 Monorepos frontend

**Turborepo/Nx + pnpm workspaces:**
```
apps/
  web/
  admin/
  docs/
packages/
  ui/           # design system
  config-eslint/
  config-typescript/
  api-client/
```

- Shared `tsconfig`, eslint, prettier en packages/config-*.
- Build graph: `turbo run build --filter=web`.
- Versionado: changesets para packages publicados.

### 2.6 Frontend platform thinking

Trata infra frontend como producto:
- **Design system package** con semver.
- **CLI de scaffolding** (`pnpm gen:feature`).
- **Shared telemetry wrapper.**
- **Auth client SDK** unificado.
- **Documentación** en Storybook + portal interno.

---

## 3. Rendering strategies

### 3.1 SPA (Single Page Application)

- Client routing (React Router, TanStack Router, Vue Router).
- Pros: interactividad, transiciones, offline posible.
- Contras: SEO, TTFB/LCP inicial si bundle grande.
- Mitiga: code splitting, pre-render shell, meta dinámico.

### 3.2 MPA (Multi Page Application)

- Server round-trip por navegación.
- Pros: SEO simple, JS mínimo.
- Contras: UX menos fluida.
- Híbrido: MPA + islands (Astro).

### 3.3 SSR (Server-Side Rendering)

- HTML generado por request.
- Pros: SEO, LCP rápido con streaming.
- Contras: costo servidor, hydration, complejidad cache.
- Frameworks: Next.js, Remix, Nuxt, SvelteKit.

### 3.4 SSG (Static Site Generation)

- HTML en build time.
- Pros: CDN barato, performance excelente.
- Contras: rebuild para cambios, no personalización por request.

### 3.5 ISR (Incremental Static Regeneration)

- SSG + revalidación por tiempo o on-demand.
- Balance SEO/performance/contenido dinámico.

### 3.6 Híbrido y server-aware

**React Server Components (RSC):** componentes server por defecto; `"use client"`
solo donde hay interactividad. Reduce JS al cliente.

**Streaming SSR:** envía HTML incremental; Suspense boundaries.

**Partial hydration / Islands (Astro):** JS solo en islas interactivas.

### 3.7 Decision matrix

| Requisito | Recomendación |
|-----------|---------------|
| SEO crítico + contenido dinámico | SSR/ISR |
| App autenticada compleja | SPA o RSC hybrid |
| Marketing estático | SSG/Astro |
| Mínimo JS | Astro/Qwik |
| Personalización + cache | ISR + edge |

---

## 4. Frameworks — criterio de uso (agnóstico)

| Framework | Fortaleza | Considerar |
|-----------|-----------|------------|
| React | Ecosistema, hiring, RSC | Bundle, boilerplate sin convenciones |
| Vue | DX, SFC, progresivo | Ecosistema enterprise variable |
| Angular | Enterprise, opinionated | Curva, verbosity |
| Svelte | Compilado, performance | Ecosistema más pequeño |
| Solid | Performance reactivo | Nicho |
| Qwik | Resumability, mínimo JS | Madurez |
| Astro | Content, islands | Apps muy interactivas limitadas |

**Regla farola:** el framework es implementación; arquitectura y fundamentos
perduran. No reescribas por moda sin ROI medible.

---

## 5. Routing, datos e integración

- **Data loaders** colocados en route (Remix, TanStack Router, Next).
- **Layouts anidados** para shell persistente.
- **Error boundaries** por ruta.
- **Loading UI** por segmento (Suspense, `loading.tsx`).
- **Parallel routes / intercepting** (Next) para modals con URL.

---

## 6. Evolución de sistemas complejos

**Strangler Fig (frontend):**
1. Identifica bounded context UI.
2. Extrae feature a módulo/package aislado.
3. Routing progresivo al nuevo módulo.
4. Elimina legacy cuando cobertura 100%.

**Migración framework (ej. AngularJS → React):**
- Por ruta/feature, no big-bang.
- iframe o web components como bridge temporal si necesario.
- Tests E2E como red de seguridad.

**Versionado design system:** semver estricto; codemods para breaking changes.
