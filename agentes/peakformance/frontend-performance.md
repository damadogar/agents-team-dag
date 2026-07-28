# Performance Frontend / Cliente (web y móvil, agnóstico de framework)

peakformance es dueño integral del performance del ecosistema. En el cliente eso significa gobernar la experiencia **percibida y medida** de carga, respuesta e interacción, sin sesgo de framework ni de herramienta: React/Vue/Svelte/Angular/Solid/Astro/Qwik o vanilla son intercambiables; se elige por contexto y evidencia, nunca por moda. Este archivo cubre métricas de cliente, critical rendering path, JavaScript/bundle, estrategias de rendering, assets, red, runtime, performance móvil y percepción, más el reparto tiered con farola (impl. frontend) y uxuifull (percibido); el contrato de handoff vive en [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md). Aplica a **greenfield** (budgets desde el diseño) y **brownfield** (auditar y corregir lo existente).

> Contexto hermano: la estrategia global vive en [estrategia-performance.md](estrategia-performance.md); el método de diagnóstico en [metodologia-diagnostico.md](metodologia-diagnostico.md); la medición/RUM en [medicion-observabilidad.md](medicion-observabilidad.md); CDN/edge y colas en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md); backend/TTFB en [backend-performance.md](backend-performance.md).

## 1. Modelo TIERED de responsabilidad

| Tier | Qué | Dueño | Nota |
|------|-----|-------|------|
| **T1** | Perf budgets, instrumentación RUM cliente, config CDN/caché, tuning de red (compresión, HTTP/2-3, hints), presupuesto de bytes/JS, gates en CI | **peakformance** implementa | Cross-cutting; no depende del dominio de UI |
| **T2** | Fix en código de UI de dominio (re-renders, memoización, code splitting por ruta, virtualización, refactor de componentes) | se entrega/co-implementa vía **farola** | peakformance especifica el objetivo y la evidencia; farola es dueño del frontend |
| **T2-UX** | Rendimiento **percibido**: skeletons, optimistic UI, progressive disclosure, feedback <100ms | intención de UX de **uxuifull** | peakformance coordina; no impone la solución visual |
| **T3** | Fallback: implementación directa de peakformance | peakformance | Solo si no hay dueño de frontend/UX disponible |

Regla: peakformance **mide, define budgets y prueba antes/después**; la corrección en código de dominio se coordina, no se secuestra.

## 2. Métricas de cliente (percentiles, no promedios)

Siempre p75/p95 sobre red y dispositivo **representativos** del usuario real (no laptop de dev con fibra). Lab/sintético para reproducibilidad; RUM para verdad de campo → [medicion-observabilidad.md](medicion-observabilidad.md).

### 2.1 Core Web Vitals (umbral "bueno" a p75)

| Métrica | Umbral | Qué captura | Palancas típicas |
|---------|--------|-------------|------------------|
| **LCP** | ≤ 2.5 s | Render del mayor elemento visible | TTFB, preload del recurso LCP, imagen optimizada, menos JS bloqueante |
| **INP** | ≤ 200 ms | Latencia de interacción (reemplaza FID) | Romper long tasks, `yield`/scheduler, menos trabajo en main thread |
| **CLS** | ≤ 0.1 | Estabilidad visual | `width/height` o `aspect-ratio`, reservar espacio de fuentes/ads, sin inyección tardía |

### 2.2 Complementarias / diagnósticas

| Métrica | Uso |
|---------|-----|
| **TTFB** | Frontera con backend/CDN; si es alto, el problema no es de cliente → [backend-performance.md](backend-performance.md) |
| **FCP** | Primer pixel; diagnóstico de render-blocking |
| **TBT** | Proxy de lab para INP; suma de bloqueo del main thread |
| **TTI / total main-thread time** | Costo de hydration y ejecución de JS |

## 3. Critical Rendering Path

Objetivo: pintar contenido útil lo antes posible y no bloquear el hilo principal.

- **CSS crítico** inline o priorizado; el resto diferido. Evitar CSS render-blocking pesado.
- **JS**: `defer`/`async` por defecto; nada de scripts síncronos en `<head>` salvo justificado.
- Minimizar cadena de solicitudes críticas; usar resource hints (§6) con criterio (cada `preload` compite por ancho de banda).
- Eliminar recursos que bloquean el primer render pero no son visibles above-the-fold.

## 4. JavaScript / Bundle

El JS es el costo dominante en INP/TBT y en móvil de gama baja. Se gobierna con **budgets de bytes** (T1) y con refactor de dominio (T2 vía farola).

- **Code splitting** por ruta y por interacción; cargar el componente cuando se necesita.
- **Tree shaking** efectivo: imports nombrados, evitar side-effects, `sideEffects:false` cuando aplique (p. ej. bundlers tipo esbuild/Rollup/webpack/Vite — elegir por proyecto).
- **Lazy loading** de rutas, modales, vistas pesadas, dependencias grandes (fechas, charts, editores).
- **Presupuesto de bytes** (ejemplo de partida, ajustar por contexto y audiencia):

```
# perf-budget (T1, gate en CI) — valores ilustrativos, no dogma
initial_js_gzip:    <= 170 KB   # ruta crítica, móvil representativo
initial_css_gzip:   <=  60 KB
lcp_image_bytes:    <= 150 KB
route_js_gzip:      <= 100 KB   # por chunk de ruta perezosa
third_party_js:     presupuesto explícito y monitorizado
```

- Auditar terceros (analytics, tags, widgets): suelen dominar el bloqueo. Facade pattern / carga diferida / self-hosting cuando aporte.
- Polyfills solo por targets reales (differential serving); no enviar transpilación innecesaria a navegadores modernos.

## 5. Estrategias de rendering y costo de hydration

No hay "mejor" universal; se decide por interactividad, SEO, TTFB y presupuesto de JS. La **hydration** es el costo oculto: enviar HTML y luego re-ejecutar JS para "revivirlo" puede arruinar INP.

| Estrategia | Fuerte en | Costo | Cuándo (p. ej.) |
|-----------|-----------|-------|------------------|
| **CSR** | Apps muy interactivas, tras login | LCP/SEO peores; todo el JS al cliente | Dashboards internos |
| **SSR** | Contenido dinámico + SEO | TTFB servidor + hydration | E-commerce con datos por usuario |
| **SSG** | Contenido estable | Rebuild en cambios | Docs, marketing |
| **ISR / regeneración incremental** | Catálogos grandes | Complejidad de invalidación | Listados con cambio moderado |
| **Streaming SSR** | TTFB percibido | Requiere soporte del framework | Páginas con partes lentas |
| **Islands / partial hydration** | Minimizar JS | Modelo mental distinto | Sitios mayormente estáticos con islas interactivas (p. ej. Astro/Qwik/Marko) |

Principio: **hidratar solo lo interactivo**; preferir HTML que funcione sin JS y añadir interactividad progresiva. Medir el tiempo de hydration como métrica de primera clase.

## 6. Assets

### 6.1 Imágenes (suelen ser el LCP)
- Formatos modernos con fallback, por ratio de compresión medido (típicamente **AVIF > WebP > JPEG/PNG**); validar en los assets reales.
- **Responsive**: `srcset` + `sizes` para servir la resolución justa; no reescalar en cliente.
- `loading="lazy"` bajo el fold; **eager** + `fetchpriority="high"` para el recurso LCP.
- Siempre dimensiones o `aspect-ratio` para no generar CLS.

### 6.2 Fuentes
- **Subset** (solo glyphs usados) + `font-display: swap` (o `optional` si CLS es crítico).
- `preload` de la fuente crítica; limitar variantes/pesos; preferir variables fonts si reducen bytes.
- `size-adjust`/métricas de fallback para minimizar reflow al intercambiar.

### 6.3 SVG / otros
- SVG inline para íconos críticos; sprite/símbolo para reuso; optimizar (SVGO-like). Evitar SVG gigantes sin optimizar.

## 7. Red

Tuning de red = **T1 (peakformance)**. Ver edge/CDN en [distribuidos-escalabilidad.md](distribuidos-escalabilidad.md); la **mecánica de transporte** (TCP slow-start/BDP/Nagle, handshake TLS/AES-NI, HOL blocking, QUIC, suelo físico de latencia) es canónica en [sistemas-hardware.md](sistemas-hardware.md) §7.

- **HTTP/2 / HTTP/3 (QUIC)**: multiplexado; reduce el peso del sharding y del inlining agresivo.
- **Resource hints** con presupuesto: `preconnect` (orígenes críticos de terceros), `preload` (recurso crítico conocido), `prefetch` (probable navegación siguiente), `dns-prefetch`. Cada hint mal usado roba ancho de banda.
- **Compresión**: **Brotli** (texto) con gzip fallback; verificar que assets estáticos salgan comprimidos desde CDN.
- **Cache headers**: `immutable` + hash en el nombre para estáticos (`max-age` largo); `stale-while-revalidate` para HTML/datos; `Vary` correcto.
- **Service Workers / PWA**: precache del app shell, estrategias cache-first/network-first por tipo de recurso, offline. No introducir SW sin plan de actualización (evitar servir versiones viejas).
- **CDN/edge**: acercar assets y HTML al usuario; medir por región (percentiles por geo).

## 8. Runtime (main thread, re-renders, listas)

Costo que domina INP y jank. Refactor de dominio = **T2 vía farola**; peakformance aporta perfiles y objetivos.

- **Re-renders**: medir con profiler antes de optimizar; memoizar (equivalentes a `memo`/`computed`/derived stores) **solo tras evidencia**, no de forma preventiva.
- **Main-thread work**: partir long tasks (>50 ms); ceder al hilo (scheduler/`postTask`, `isInputPending`, o `startTransition`-like en el framework que aplique) para no bloquear input.
- **Web Workers**: mover parsing/cálculo pesado fuera del main thread.
- **Virtualización** de listas largas (windowing) en vez de renderizar miles de nodos.
- Evitar layout thrashing (leer/escribir DOM en lotes); usar `content-visibility` para diferir render off-screen.
- Debounce/throttle de handlers de scroll/resize/input.

## 9. Performance móvil (web-sobre-móvil y app nativa)

- **App nativa (iOS/Android)**: métricas propias que Core Web Vitals no captura — **arranque en frío/caliente** (TTID/TTFD), **ANR/hangs**, **frame drops** y footprint de memoria/energía por radio. Se miden con perfiladores de plataforma y trazas del SO, no con RUM web (ver [medicion-observabilidad.md](medicion-observabilidad.md), "sistemas no-online").
- **Jank / 60 fps**: presupuesto de 16 ms por frame; animar solo `transform`/`opacity` (compositor), no `top/left/width`.
- **Dispositivo representativo**: perfilar en gama media/baja con CPU throttling 4-6x, no en flagship.
- **Redes lentas**: probar en 3G/4G simulado; usar Save-Data y adaptación por `navigator.connection` cuando aplique.
- **Batería**: limitar timers/animaciones en background, wake locks, y trabajo especulativo excesivo.

## 10. Percepción de velocidad (coordinar con uxuifull)

La velocidad **percibida** puede pesar más que la medida. Es **intención de UX de uxuifull**; peakformance la habilita técnicamente y la mide.

- Skeletons / placeholders con espacio reservado (sin CLS).
- **Optimistic UI**: responder al usuario antes de la confirmación del servidor.
- Feedback inmediato (<100 ms) en toda interacción; transiciones que ocultan latencia.
- Priorizar contenido above-the-fold y streaming progresivo.

## 11. Cómo medir (lab + RUM)

- **Lab/sintético**: reproducible, para CI y comparación antes/después (p. ej. Lighthouse/Lighthouse-CI, WebPageTest, DevTools traces — herramientas como ejemplo, no obligación).
- **RUM**: verdad de campo con percentiles por dispositivo/red/geo (web-vitals lib o equivalente; enviar a la plataforma de observabilidad). Detalle en [medicion-observabilidad.md](medicion-observabilidad.md).
- Toda intervención se justifica con **antes/después** en p75/p95 sobre carga y red representativas. Gates de budget en pipeline → [performance-cicd.md](performance-cicd.md); carga sostenida → [pruebas-de-carga.md](pruebas-de-carga.md).

## 12. Checklist frontend

- [ ] Budgets definidos (JS/CSS/imágenes/terceros) y con gate en CI (T1).
- [ ] RUM de CWV activo, por percentiles y segmentado por dispositivo/red/geo.
- [ ] LCP p75 ≤ 2.5 s; recurso LCP identificado, preload + `fetchpriority`.
- [ ] INP p75 ≤ 200 ms; long tasks partidas; trabajo pesado en workers.
- [ ] CLS p75 ≤ 0.1; dimensiones/`aspect-ratio` en media; fuentes sin reflow.
- [ ] Estrategia de rendering elegida por evidencia; costo de hydration medido.
- [ ] Code splitting por ruta/interacción; tree shaking verificado; lazy en vistas pesadas.
- [ ] Imágenes AVIF/WebP + `srcset`/`sizes`; fuentes subset + `font-display`.
- [ ] HTTP/2-3, Brotli, cache headers `immutable`+hash, hints con presupuesto.
- [ ] Terceros auditados y presupuestados; facades/carga diferida donde aplique.
- [ ] SW/PWA (si aplica) con estrategia de actualización clara.
- [ ] Perfilado en gama media/baja + red lenta; 60 fps sin jank.
- [ ] Percepción coordinada con uxuifull (skeletons, optimistic UI).
- [ ] Fixes de dominio entregados/co-implementados con farola (T2).
- [ ] Antes/después documentado en p75/p95; sin regresiones.

Ver también: [datos-performance.md](datos-performance.md) · [infra-capacidad-costo.md](infra-capacidad-costo.md) · [ia-ml-performance.md](ia-ml-performance.md) · [interoperabilidad-y-aliadas.md](interoperabilidad-y-aliadas.md) · [sistemas-hardware.md](sistemas-hardware.md) · [tiempo-real-embebido.md](tiempo-real-embebido.md) · [plantillas.md](plantillas.md) · [ejemplos.md](ejemplos.md).
