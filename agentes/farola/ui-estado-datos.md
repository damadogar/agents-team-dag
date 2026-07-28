# UI Engineering, Estado y Datos

Conocimiento profundo de farola en construcción de interfaces, design systems,
manejo de estado y datos en el cliente.

---

## 1. UI Engineering

### 1.1 Arquitectura de componentes

**Atomic Design (adaptado):**
- **Atoms:** Button, Input, Label, Icon — sin lógica de negocio.
- **Molecules:** SearchField, FormField — composición simple.
- **Organisms:** Header, ProductCard, DataTable — bloques funcionales.
- **Templates/Pages:** layout + datos.

**Reglas:**
- Un componente = una responsabilidad clara.
- Props API mínima y tipada; evita prop explosion (>10 props → composición).
- `children` para extensibilidad.
- Controlled vs uncontrolled: documenta cuál soporta.

### 1.2 Design Systems en código

**Tokens (W3C Design Tokens Community Group):**
```json
{
  "color.primary": { "$value": "oklch(55% 0.2 250)", "$type": "color" },
  "space.4": { "$value": "1rem", "$type": "dimension" }
}
```

**Pipeline:** Figma Tokens → Style Dictionary → CSS variables + Tailwind theme.

**Theming:**
- CSS variables en `:root` y `[data-theme="dark"]`.
- Evita flash: script inline mínimo o `color-scheme`.
- Contraste verificado en ambos temas.

**Component library stack típico (moderno):**
- Radix/shadcn (primitives accesibles) + Tailwind + CVA.
- Headless UI / Ark UI como alternativas.

### 1.3 Layouts complejos

- **Dashboard:** sidebar collapsible, responsive drawer en móvil.
- **Split pane:** resizable con a11y (keyboard).
- **Sticky headers** en tablas: `position: sticky` + shadow en scroll.
- **Overflow:** `min-h-0` en flex children para scroll interno.

### 1.4 Responsive y adaptive

**Mobile-first breakpoints** (ejemplo Tailwind):
`sm:640 md:768 lg:1024 xl:1280 2xl:1536`

**Patrones:**
- Navigation: hamburger/drawer → horizontal nav.
- Tables: card list en móvil o scroll horizontal con indicador.
- Touch targets ≥44×44px (WCAG 2.5.5 AAA target size).

**Container queries** para componentes reutilizables en contextos distintos.

### 1.5 Interacción y feedback

- Feedback <100ms (estado pressed, focus ring).
- Loading >400ms: spinner/skeleton.
- Optimistic UI con rollback en error.
- Disabled states durante submit (prevent double-click).
- Undo para acciones destructivas cuando posible.

### 1.6 Motion UI

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

- Duración 150–300ms micro, ≤400ms transiciones.
- Solo `transform`/`opacity`.
- `aria-live` para cambios dinámicos sin movimiento exclusivo.

---

## 2. Estados de UI (obligatorio)

Toda vista/componente crítico implementa:

| Estado | Implementación | UX |
|--------|----------------|-----|
| **Vacío** | EmptyState con CTA | Guía siguiente acción |
| **Cargando** | Skeleton > spinner largo | Preserva layout (CLS) |
| **Error** | Mensaje claro + retry | Recuperable |
| **Parcial** | Stale-while-revalidate | Muestra cache + refresh |
| **Lleno** | Datos renderizados | Happy path |
| **Sin permiso** | 403 UI inline | No redirect silencioso |
| **Disabled** | `aria-disabled` o disabled | Explica por qué si no obvio |
| **Success** | Toast/inline confirmation | Temporal, dismissible |

**Skeleton guidelines:** dimensiones iguales al contenido final; shimmer sutil.

---

## 3. Estado local

### 3.1 React

- `useState`: valor simple.
- `useReducer`: lógica de transición compleja, state machine ligera.
- **No derives en effect lo calculable:**
  ```typescript
  // ❌
  useEffect(() => setFullName(first + last), [first, last]);
  // ✅
  const fullName = `${first} ${last}`;
  ```

### 3.2 Colocation

Estado lo más cerca posible de donde se usa. Sube solo cuando múltiples
subárboles lo necesitan.

### 3.3 URL como estado

Filtros, paginación, tabs → search params. Shareable, bookmarkable, back button works.

---

## 4. Estado compartido (global UI)

**Cuándo global:** theme, locale, sidebar open, auth session UI, feature flags UI.

| Librería | Cuándo |
|----------|--------|
| Context | Pocos consumers, baja frecuencia update |
| Zustand | Global simple, buen DX |
| Jotai/Recoil | Átomos granulares |
| Redux Toolkit | Estado complejo + middleware + devtools + equipo familiar |

**Anti-patrón:** Redux para server cache — usa TanStack Query.

---

## 5. Server state

### 5.1 TanStack Query (patrón recomendado default)

```typescript
const { data, isLoading, isError, error, refetch } = useQuery({
  queryKey: ['products', filters],
  queryFn: () => api.products.list(filters),
  staleTime: 60_000,
});
```

**Invalidation:**
```typescript
queryClient.invalidateQueries({ queryKey: ['products'] });
```

**Mutations + optimistic:**
```typescript
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] });
    const previous = queryClient.getQueryData(['todos']);
    queryClient.setQueryData(['todos'], (old) => [...old, newTodo]);
    return { previous };
  },
  onError: (_err, _vars, context) => {
    queryClient.setQueryData(['todos'], context.previous);
  },
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
});
```

### 5.2 Cache strategy

| Patrón | Uso |
|--------|-----|
| staleTime corto | Datos que cambian frecuente |
| staleTime largo | Catálogos estables |
| prefetch on hover | Rutas probables |
| Persist (IndexedDB) | Offline-first |
| Infinite query | Scroll infinito |

### 5.3 GraphQL (Apollo/urql)

Cuando: múltiples clients con necesidades de campos distintas, schema fuerte.
Cuidado: over-fetching en cliente no es problema; bundle Apollo sí.

---

## 6. Formularios complejos

**Stack recomendado:** React Hook Form + Zod resolver.

```typescript
const schema = z.object({
  email: z.string().email(),
  age: z.coerce.number().min(18),
});

const form = useForm({ resolver: zodResolver(schema) });
```

**Patrones:**
- Validación onBlur para campos individuales; onSubmit para form.
- Errores asociados: `aria-describedby`, `aria-invalid`.
- Multi-step: state en URL o form context; persist draft.
- File upload: progress, size/type validation cliente + servidor.
- Autosave: debounce + mutation.

---

## 7. Manejo de errores en UI

**Taxonomía:**
- Network offline → banner persistente + retry.
- 401 → redirect login o modal re-auth.
- 403 → inline sin permiso.
- 404 → empty/not found contextual.
- 500 → error boundary + retry + support link.
- Validation → field-level.

**Error Boundaries (React):**
```typescript
<ErrorBoundary fallback={<ErrorFallback onRetry={reset} />}>
  <Feature />
</ErrorBoundary>
```

Por ruta/feature, no uno global único.

---

## 8. Resiliencia de UI

- **Retry** con backoff en fetch.
- **Circuit breaker** UI: deja de retry tras N fallos; muestra estado degradado.
- **Offline queue** para acciones críticas (mutations en cola).
- **Stale data indicator:** "Datos de hace 5 min · Actualizar".
- **Graceful degradation:** funcionalidad core sin JS donde viable.

---

## 9. Carga progresiva

1. Shell crítico (layout, nav).
2. LCP content (hero, above-fold).
3. Below-fold lazy.
4. Third-party scripts defer/async o tag manager controlado.
5. Prefetch rutas en idle (`requestIdleCallback`).

---

## 10. Integración design ↔ código

Cuando recibes handoff de `uxuifull`:
- Implementa tokens exactos (no aproximar colores).
- Todos los estados del spec.
- Microcopy verbatim salvo i18n keys.
- Breakpoints según spec.
- Criterios WCAG como tests manuales/automáticos.
- Reporta drift si implementación difiere por restricción técnica.

Ver [governance-ia-interop.md](governance-ia-interop.md).
