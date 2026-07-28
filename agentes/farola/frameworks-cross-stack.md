# Patrones Cross-Stack — Frontend Agnóstico

Conocimiento de farola para operar al máximo nivel en **cualquier framework**, no
solo React. Demuestra que los principios de farola son **agnósticos**: el mismo
patrón se expresa en React, Vue, Svelte, Angular y Solid. Consultar cuando el
proyecto NO sea React, cuando haya que migrar entre frameworks, o para evaluar
equivalencias técnicas con criterio.

> **Regla farola:** los conceptos (composición, estado colocado, estado derivado
> sin efectos, server cache separado de UI state, 4 estados) son **universales**.
> La sintaxis es un detalle de implementación. Nunca impongas un framework por
> preferencia; elige por contexto (ver §12.6 y §4 de fundamentos).

---

## 0. Tabla de traducción de conceptos

| Concepto | React | Vue 3 | Svelte 5 | Angular | Solid |
|----------|-------|-------|----------|---------|-------|
| Estado reactivo local | `useState` | `ref`/`reactive` | `$state` (rune) | `signal()` | `createSignal` |
| Estado derivado | variable en render / `useMemo` | `computed` | `$derived` | `computed()` | `createMemo` |
| Efecto secundario | `useEffect` | `watchEffect`/`watch` | `$effect` | `effect()` | `createEffect` |
| Props | función args + `props` | `defineProps` | `$props()` | `@Input()`/`input()` | función args |
| Eventos hacia arriba | callbacks en props | `defineEmits` | callback props | `@Output()`/`output()` | callbacks |
| Slot / children | `children` | `<slot>` | `{@render}`/snippets | `<ng-content>` | `children` |
| Contexto / DI | `createContext` | `provide`/`inject` | context API | DI (`providedIn`) | `createContext` |
| Lista keyed | `key` prop | `:key` | `{#each ... (key)}` | `trackBy`/`@for track` | `<For>` |
| Render condicional | `{cond && ...}` | `v-if` | `{#if}` | `@if`/`*ngIf` | `<Show>` |
| Lifecycle mount | `useEffect(...,[])` | `onMounted` | `$effect` / `onMount` | `ngOnInit` | `onMount` |
| Lifecycle cleanup | return en `useEffect` | `onUnmounted` | return en `$effect` | `ngOnDestroy` | `onCleanup` |
| Two-way binding | controlled + onChange | `v-model` | `bind:value` | `[(ngModel)]` | signal + onInput |

**Lectura clave:** si dominas el concepto, lo implementas en cualquier columna.
farola razona por concepto, luego aterriza en la sintaxis del repo.

---

## 1. Componente con props y variantes

**React**
```tsx
type Props = { variant?: 'primary' | 'ghost'; onClick?: () => void; children: React.ReactNode };
export function Button({ variant = 'primary', onClick, children }: Props) {
  return <button className={buttonVariants({ variant })} onClick={onClick}>{children}</button>;
}
```

**Vue 3 (SFC, `<script setup>`)**
```vue
<script setup lang="ts">
const props = withDefaults(defineProps<{ variant?: 'primary' | 'ghost' }>(), { variant: 'primary' });
const emit = defineEmits<{ click: [] }>();
</script>
<template>
  <button :class="buttonVariants({ variant: props.variant })" @click="emit('click')"><slot /></button>
</template>
```

**Svelte 5 (runes)**
```svelte
<script lang="ts">
  let { variant = 'primary', onclick, children } = $props();
</script>
<button class={buttonVariants({ variant })} {onclick}>{@render children()}</button>
```

**Angular (standalone, signals)**
```ts
@Component({
  selector: 'app-button', standalone: true,
  template: `<button [class]="cls()" (click)="clicked.emit()"><ng-content /></button>`,
})
export class ButtonComponent {
  variant = input<'primary' | 'ghost'>('primary');
  clicked = output<void>();
  cls = computed(() => buttonVariants({ variant: this.variant() }));
}
```

**Solid**
```tsx
export function Button(props: { variant?: 'primary' | 'ghost'; onClick?: () => void; children: JSX.Element }) {
  return <button class={buttonVariants({ variant: props.variant ?? 'primary' })} onClick={props.onClick}>{props.children}</button>;
}
```

---

## 2. Estado derivado sin efectos (anti-patrón universal)

El error de "sincronizar estado derivado en un efecto" existe en **todos** los
frameworks. La solución siempre es computar en render/derivación, no en efecto.

```tsx
// React ❌                                 // React ✅
useEffect(() => setFull(a + b), [a, b]);    const full = `${a} ${b}`;
```
```ts
// Vue ✅            // Svelte ✅           // Angular ✅          // Solid ✅
computed(()=>a.value+b.value)  $derived(a+' '+b)  computed(()=>a()+b())  createMemo(()=>a()+b())
```

**Principio farola:** si se calcula a partir de otros valores reactivos, es
*derivado*, no *estado*. No lo dupliques ni lo "sincronices" con efectos.

---

## 3. Server state (datos remotos) separado del UI state

farola insiste: el cache de servidor **no** vive en el store global de UI.

| Framework | Librería server-state recomendada |
|-----------|-----------------------------------|
| React | TanStack Query, SWR, RTK Query |
| Vue | TanStack Query (Vue), Pinia Colada, `useFetch` (Nuxt) |
| Svelte | TanStack Query (Svelte), SvelteKit `load` + `invalidate` |
| Angular | TanStack Query (Angular), `httpResource()` (v19+), NgRx Signal Store |
| Solid | `createResource`, TanStack Query (Solid) |

```ts
// Vue — TanStack Query
const { data, isLoading, isError, refetch } = useQuery({
  queryKey: ['products', filters], queryFn: () => api.products.list(filters), staleTime: 60_000,
});
```
```ts
// Angular — httpResource (v19+)
products = httpResource(() => `/api/products?f=${this.filters()}`); // .value() .isLoading() .error()
```
```ts
// Solid — createResource
const [products] = createResource(filters, (f) => api.products.list(f));
```

Patrón común: `data · isLoading · isError · refetch/invalidate`. Mismo modelo
mental, distinta API.

---

## 4. Formularios con validación de esquema

Esquema único (Zod/Valibot) reutilizable en cualquier framework + en backend.

```ts
import { z } from 'zod';
export const loginSchema = z.object({ email: z.string().email(), password: z.string().min(8) });
```

| Framework | Binding de formularios |
|-----------|------------------------|
| React | React Hook Form + `zodResolver` |
| Vue | VeeValidate + `toTypedSchema(zodSchema)`, o FormKit |
| Svelte | sveltekit-superforms + Zod adapter |
| Angular | Reactive Forms + validador Zod custom, o `ngx-formly` |
| Solid | Modular Forms + Zod, o TanStack Form |

**Constante farola:** valida en cliente para UX, **nunca** confíes solo en
cliente; el mismo esquema debe validarse en servidor.

---

## 5. Estado global de UI (no server cache)

| Framework | Opciones |
|-----------|----------|
| React | Zustand, Jotai, Redux Toolkit (justificado), Context |
| Vue | Pinia (default), `provide/inject` |
| Svelte | Runes en módulo `.svelte.ts` (`$state` exportado), stores clásicos |
| Angular | NgRx Signal Store, servicios con `signal()`, NgRx (complejo) |
| Solid | stores (`createStore`), context |

```ts
// Svelte 5 — store con runes en counter.svelte.ts
export const counter = $state({ value: 0 });
export const increment = () => counter.value++;
```
```ts
// Pinia (Vue)
export const useUi = defineStore('ui', () => { const sidebar = ref(false); return { sidebar }; });
```

---

## 6. Los 4 estados de UI en cada framework

vacío · cargando · error · lleno — obligatorio siempre (principio §4.2.11).

```vue
<!-- Vue -->
<template>
  <Spinner v-if="isLoading" />
  <ErrorState v-else-if="isError" :onRetry="refetch" />
  <EmptyState v-else-if="!data?.length" />
  <DataList v-else :items="data" />
</template>
```
```svelte
<!-- Svelte 5 -->
{#if isLoading}<Spinner />{:else if isError}<ErrorState {onRetry} />
{:else if !data?.length}<EmptyState />{:else}<DataList items={data} />{/if}
```
```html
<!-- Angular control flow -->
@if (q.isLoading()) { <app-spinner /> }
@else if (q.error()) { <app-error (retry)="q.refetch()" /> }
@else if (!q.value()?.length) { <app-empty /> }
@else { <app-list [items]="q.value()" /> }
```

---

## 7. Meta-frameworks y rendering (equivalencias)

| Capacidad | React | Vue | Svelte |
|-----------|-------|-----|--------|
| SSR/SSG/ISR | Next.js | Nuxt | SvelteKit |
| File routing + loaders | Next App Router / TanStack Router | Nuxt pages / `useAsyncData` | SvelteKit `+page.ts load` |
| Server Components | RSC (`"use client"`) | — (Nuxt islands/server comp. experimental) | — (server load + islands) |
| Islands / mínimo JS | Astro + React | Astro + Vue / Nuxt islands | Astro + Svelte |
| Resumability | — | — | — (Qwik aparte) |

**Astro** es el denominador común multi-framework: permite islas de React, Vue,
Svelte y Solid en la misma página. Útil cuando el equipo es heterogéneo.

---

## 8. Web Components (verdaderamente agnóstico)

Cuando se necesita un componente reutilizable **entre** frameworks (design system
corporativo multi-stack), los Web Components / Custom Elements son la vía neutral.

```ts
// Lit — un botón usable desde React, Vue, Angular, vanilla
import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('ds-button')
export class DsButton extends LitElement {
  static styles = css`button{font:inherit}`;
  @property() variant: 'primary' | 'ghost' = 'primary';
  render() { return html`<button part="btn" class=${this.variant}><slot></slot></button>`; }
}
```

- Interop: la mayoría de frameworks consumen custom elements; React 19+ ya
  maneja props/eventos de custom elements nativamente.
- Tematización: `::part()` y custom properties cruzan el Shadow DOM.
- Trade-off: DX y SSR de Web Components es más áspero; úsalos cuando la
  neutralidad entre stacks pesa más que la ergonomía.

---

## 9. Heurística de elección y migración (recordatorio)

1. ¿Restricción del equipo/org? → respeta el stack existente.
2. ¿SEO/SSR crítico? → meta-framework (Next/Nuxt/SvelteKit/Astro).
3. ¿Máxima interactividad? → React/Vue/Svelte/Solid.
4. ¿Mínimo JS / contenido? → Astro/Qwik.
5. ¿Design system multi-stack? → Web Components (Lit) para primitives.
6. **Nunca** migres de framework sin: red E2E previa, ROI medible y plan
   strangler por ruta/feature (ver PB-09).

**Cierre farola:** un Primer Maestro de Frontend no es "experto en React"; es
experto en **frontend** y usa el framework correcto para el problema correcto.
