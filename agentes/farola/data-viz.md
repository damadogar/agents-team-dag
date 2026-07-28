# Visualización de Datos (Data Viz) en Frontend

Conocimiento profundo de farola en la **construcción** de visualizaciones de datos
en el cliente: gráficos, dashboards, mapas y tablas analíticas. Consultar cuando
el problema sea renderizar, optimizar, hacer accesible o interactiva una
visualización.

> **Frontera de dominio (importante).**
> **SÍ es de farola:** elección de técnica de render (SVG/Canvas/WebGL), selección
> de librería, performance de render con datasets grandes (craft; budgets y
> optimización profunda → `peakformance`), interactividad, accesibilidad,
> theming/tokens, charts en tiempo real, SSR/imagen estática, testing visual.
> **NO es de farola:** modelado de datos, agregación/ETL, queries, estadística y
> *qué significan* las métricas → backend/data (`motor`/data eng). farola
> **consume** datos ya calculados; si el cálculo pertenece al servidor, lo señala
> y escala, no lo resuelve. La elección de *qué* comunicar y la narrativa visual
> de alto nivel es de `uxuifull`; farola implementa con criterio de ingeniería.

---

## 1. Decisión de tecnología de render

La decisión #1 y la que más afecta performance y accesibilidad.

| Técnica | Rango útil (aprox.) | Pros | Contras |
|---------|---------------------|------|---------|
| **HTML/CSS** | Barras/sparklines simples, pocos datos | A11y y theming nativos, DOM inspeccionable | No escala a formas complejas |
| **SVG** | Hasta ~1–2k elementos | Vectorial, accesible (DOM), interactividad por nodo, nítido | Coste DOM alto a gran escala |
| **Canvas 2D** | ~1k–100k+ puntos | Mucho más rápido que SVG, control pixel | A11y manual, hit-testing manual |
| **WebGL** | 100k–millones de puntos | GPU, datasets masivos, mapas/3D | Complejo, a11y/text difícil, fallback necesario |

**Regla farola:** empieza por la técnica **más accesible que rinda** para el
volumen real. SVG por defecto; Canvas cuando el DOM se vuelve cuello de botella;
WebGL solo para volúmenes que Canvas no aguanta. Mide antes de subir de nivel.

**Patrón híbrido común:** Canvas/WebGL para la capa de datos densa + SVG/HTML
encima para ejes, leyendas, tooltips y foco accesible.

---

## 2. Selección de librería (por necesidad, agnóstico)

| Necesidad | Opciones |
|-----------|----------|
| **Charts declarativos rápidos** | Recharts, Chart.js, ECharts, Highcharts (licencia), Nivo |
| **Bajo nivel / custom total** | D3, Visx (D3+React), Observable Plot, Vega-Lite |
| **Time-series alto volumen** | uPlot, Lightweight Charts, ECharts (canvas) |
| **Tablas analíticas / data grid** | TanStack Table (headless), AG Grid (licencia), Glide Data Grid (canvas) |
| **Mapas geoespaciales** | Leaflet, MapLibre/Mapbox GL, deck.gl (WebGL, big data) |
| **Big data / millones de puntos** | deck.gl, regl, plotly.js (scattergl) |
| **Grafos/redes** | Cytoscape, Sigma.js, react-flow |

**Criterio de selección:**
1. ¿Pocos tipos de gráfico estándar? → librería declarativa (menos código).
2. ¿Diseño totalmente custom / brand fuerte? → bajo nivel (D3/Visx/Plot).
3. ¿Volumen alto o real-time? → canvas/WebGL (uPlot, ECharts, deck.gl).
4. ¿Tabla con orden/filtro/virtualización? → **headless** (TanStack Table) +
   tu design system, salvo necesidades enterprise (AG Grid).
5. **Bundle size:** muchas libs de charts son pesadas; importa por módulo, lazy-load
   la vista de dashboard, evita cargar D3 entero si usas 3 funciones.

**Agnóstico de framework:** D3/ECharts/uPlot/deck.gl son vanilla y se integran en
React/Vue/Svelte/Angular vía wrapper o ref al contenedor. Patrones equivalentes
en [frameworks-cross-stack.md](frameworks-cross-stack.md).

---

## 3. Selección de tipo de gráfico (encoding correcto)

farola implementa con criterio de ingeniería de la percepción; la estrategia
narrativa profunda es de `uxuifull`.

| Intención | Gráfico adecuado | Evitar |
|-----------|------------------|--------|
| Comparar categorías | Barras | Pie con muchas categorías |
| Tendencia en el tiempo | Línea / área | Barras 3D |
| Parte de un todo (pocas) | Pie/donut (≤5), barras apiladas | Pie con 12 slices |
| Correlación | Scatter | — |
| Distribución | Histograma, box plot, violin | — |
| Densidad geográfica | Choropleth, heatmap | Burbujas ilegibles |
| Jerarquía/proporción | Treemap, sunburst | — |
| Muchas series densas | Small multiples | "Spaghetti chart" |

**Principios:** eje Y desde 0 en barras; no distorsionar escalas; densidad de
datos > decoración (anti chartjunk); etiqueta directa > leyenda cuando aporta.

---

## 4. Performance con datasets grandes

| Técnica | Cuándo |
|---------|--------|
| **Downsampling (LTTB)** | Time-series con miles de puntos por pixel → reduce sin perder forma |
| **Agregación/binning** | Agregar en buckets (servidor preferido) antes de pintar |
| **Virtualización** | Tablas y listas largas (TanStack Virtual) |
| **Canvas/WebGL** | Cuando SVG/DOM no rinde (ver §1) |
| **Web Workers** | Parseo/transformación pesada fuera del main thread |
| **Streaming/incremental** | Pintar a medida que llega; no esperar todo el dataset |
| **`requestAnimationFrame` + coalesce** | Updates de alta frecuencia (real-time) |
| **Decimation por viewport** | Renderiza solo lo visible (zoom/pan) |
| **Memoización de escalas/paths** | No recalcular en cada render si los datos no cambian |

**Regla farola:** "no pintes más puntos que pixels". Si hay más datos que
resolución horizontal, downsamplea o agrega. Idealmente agrega en el servidor y
trae lo justo (coordina con backend).

---

## 5. Accesibilidad de visualizaciones (diferenciador clave)

Lo que más se omite y donde un Primer Maestro destaca. Un gráfico no accesible es
un gráfico incompleto.

- **No solo color:** usa también forma, patrón, etiqueta directa o textura.
  Paletas **colorblind-safe** (ColorBrewer, Viridis); verifica contraste 3:1 en
  elementos gráficos significativos (WCAG 1.4.11).
- **Alternativa textual:** todo gráfico necesita un resumen accesible (`aria-label`
  o texto cercano) que comunique la conclusión, no solo "gráfico de barras".
- **Tabla de datos equivalente:** ofrece "Ver datos" como `<table>` accesible;
  es el fallback universal para lectores de pantalla y exportación.
- **Teclado e interacción:** si el gráfico es interactivo (puntos focusables,
  tooltips), debe operarse por teclado y anunciar valores (`aria-live`).
- **SVG accesible:** `role="img"` + `<title>`/`<desc>`; o estructura semántica si
  cada serie/punto es navegable.
- **Canvas/WebGL:** no son accesibles por sí mismos → **obligatorio** fallback
  (tabla de datos o capa DOM con la información clave).
- **`prefers-reduced-motion`:** desactiva animaciones de entrada/transición.
- **Sonificación (awareness):** alternativa de audio para tendencias en contextos
  que lo requieran.

```html
<!-- Patrón mínimo: figure + alt textual + tabla equivalente -->
<figure role="group" aria-labelledby="c1">
  <figcaption id="c1">Ventas 2026: crecimiento sostenido, pico en marzo (+18%).</figcaption>
  <svg role="img" aria-label="Ventas mensuales 2026, tendencia ascendente">…</svg>
  <details><summary>Ver datos</summary>
    <table><caption>Ventas por mes</caption>…</table>
  </details>
</figure>
```

---

## 6. Interactividad y UX del gráfico

- **Estados (4+):** vacío ("sin datos para este filtro"), cargando (skeleton del
  chart, no spinner suelto), error (con retry), lleno. Nunca un canvas en blanco.
- **Tooltips** accesibles, posicionados sin salirse del viewport, con dato exacto.
- **Zoom/pan/brush** con reset visible; en táctil, gestos + alternativa por botones.
- **Crossfilter:** seleccionar en un gráfico filtra los demás (coordina estado).
- **Leyenda interactiva:** toggle de series; refleja estado y es operable por teclado.
- **Responsive:** `ResizeObserver` / container queries para redibujar al cambiar el
  contenedor; define breakpoints (oculta ejes/etiquetas en móvil, no encojas hasta
  ilegibilidad). Considera orientación y densidad táctil (targets ≥44px).
- **Exportación:** PNG/SVG/CSV cuando aporte valor analítico.

---

## 7. Theming e integración con el design system

- **Tokens de color para datos** (distintos de los tokens de UI):
  - *Categórica* (series sin orden) — paleta cualitativa colorblind-safe.
  - *Secuencial* (magnitud) — un solo hue por intensidad.
  - *Divergente* (desviación respecto a un centro) — dos hues + neutro.
- **Dark mode:** define la paleta de datos en ambos temas; nunca dependas de un
  fondo claro. Ejes/grids con contraste suficiente en los dos.
- **Tipografía y espaciado** consistentes con el design system (no fuentes ad hoc).
- Documenta los componentes de chart en Storybook como parte del design system.

---

## 8. Gráficos en tiempo real / streaming

- **Ring buffer / ventana deslizante:** mantén N puntos; descarta los viejos.
- **Append incremental**, no re-render completo del dataset.
- **Throttle/coalesce** con `requestAnimationFrame`; no pintes por cada mensaje.
- **Pausa en background tab** (`visibilitychange`) para ahorrar CPU/GPU.
- Transporte y reconexión: ver [i18n-seo-realtime.md](i18n-seo-realtime.md) §3.
- uPlot/Lightweight Charts/ECharts están optimizados para series en vivo.

---

## 9. SSR, hidratación e imagen estática

- Charts interactivos suelen ser **client-only**; usa carga diferida / `"use client"`
  para no romper SSR ni inflar el bundle inicial.
- **Imagen estática para SSR/email/SEO/Open Graph:** render server-side a SVG/PNG
  (satori, node-canvas, QuickChart) cuando se necesita sin JS o para compartir.
- Evita **hydration mismatch** por valores aleatorios/fechas: fija seeds/datos en
  servidor o difiere a cliente.

---

## 10. Testing de visualizaciones

- **Visual regression** (Storybook + Chromatic/Percy): el medio natural para
  detectar regresiones de charts; snapshots por tipo/variante/estado.
- **Data-driven:** test con datasets borde — vacío, un punto, valores negativos,
  outliers, nulos, fechas con huecos.
- **A11y:** axe sobre el contenedor + verificación manual de fallback de tabla.
- **Unit:** funciones puras de escala/formato/downsampling se testean aisladas.

---

## 11. Anti-patrones de data viz

- Canvas/WebGL **sin** fallback accesible (tabla/resumen).
- Codificar información **solo con color** (excluye daltónicos).
- Pintar más puntos que pixels sin downsampling.
- Pie chart con muchas categorías; ejes truncados que engañan.
- Cargar la librería de charts completa en el bundle inicial (no lazy).
- Re-render del dataset entero en cada tick de tiempo real.
- "Chartjunk": 3D, sombras y decoración que reducen legibilidad.
- Tooltips que no funcionan por teclado ni anuncian valor.
- Recalcular escalas/paths en cada render sin memoizar.
- Hardcodear colores de datos fuera del sistema de tokens (rompe dark mode).

---

## 12. Checklist data viz (pre-entrega)
```
- [ ] Técnica de render adecuada al volumen real (medido)
- [ ] Librería justificada (necesidad + bundle impact + lazy-load)
- [ ] Tipo de gráfico correcto para la intención (encoding)
- [ ] Performance OK con dataset real/grande (downsampling/virtualización)
- [ ] 4 estados del gráfico (vacío/cargando/error/lleno)
- [ ] Accesible: no-solo-color, alt textual, tabla equivalente, teclado, reduced-motion
- [ ] Paletas colorblind-safe + dark mode + tokens de datos
- [ ] Responsive (ResizeObserver/container queries) + táctil
- [ ] Real-time: append incremental + throttle (si aplica)
- [ ] Tests: visual regression + datasets borde + axe
- [ ] Frontera respetada: agregación/semántica de métricas escalada a backend/data
```
