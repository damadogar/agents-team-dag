# i18n/l10n, SEO técnico, Real-time, PWA y Rendering Avanzado

Áreas que separan a un frontend competente de un **Primer Maestro**. Consultar
para productos globales (multi-idioma/región), contenido que debe rankear,
experiencias en vivo, instalables/offline y UX de última generación. Todo
agnóstico de framework salvo ejemplos puntuales.

---

## 1. Internacionalización (i18n) y localización (l10n)

### 1.1 Conceptos base
- **i18n:** diseñar el código para soportar múltiples idiomas/regiones.
- **l10n:** adaptar a un locale concreto (traducción, formatos, cultura).
- **Locale:** `lang-REGION` (`es-CO`, `pt-BR`, `ar-EG`). Separa idioma de región;
  `es-CO` ≠ `es-ES` (moneda, fechas, vocabulario).

### 1.2 Reglas de oro
1. **Nunca concatenes strings traducibles.** Usa mensajes con placeholders.
2. **Pluralización con ICU MessageFormat**, no `if (n===1)`.
3. **Género/casos** vía ICU `select` cuando el idioma lo exige.
4. **Formato con `Intl`** (nativo, sin librería) para número, fecha, moneda,
   listas, unidades, tiempo relativo.
5. **No hardcodees orden de palabras**; deja que el mensaje controle el orden.
6. **Diseña para expansión de texto** (+30–40% alemán/finés) y truncado seguro.

```ts
// Intl nativo — formato culturalmente correcto, cero dependencias
new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP' }).format(1234.5);
new Intl.DateTimeFormat('ar-EG', { dateStyle: 'long' }).format(new Date());
new Intl.RelativeTimeFormat('es', { numeric: 'auto' }).format(-1, 'day'); // "ayer"
new Intl.ListFormat('es', { type: 'conjunction' }).format(['A','B','C']);  // "A, B y C"
```

```
// ICU MessageFormat — pluralización + variables
{count, plural, =0 {Sin elementos} one {# elemento} other {# elementos}}
{gender, select, female {Ella} male {Él} other {Elle}} respondió
```

### 1.3 Librerías por framework
| Framework | Opciones |
|-----------|----------|
| React | react-i18next, FormatJS/react-intl, Lingui |
| Vue | vue-i18n |
| Svelte | svelte-i18n, Paraglide (inlang) |
| Angular | `@angular/localize` (built-in), Transloco |
| Cross/SSR | next-intl, next-i18next, Nuxt i18n, Paraglide (compile-time, type-safe) |

### 1.4 RTL y bidireccionalidad
- Usa **logical properties** (`margin-inline-start`, `inset-inline-end`,
  `text-align: start`) en vez de left/right físicos.
- `dir="rtl"` en `<html>`; `:dir(rtl)` selector CSS.
- Iconografía direccional (flechas, chevrons) se refleja; logos no.
- Números, código y LTR embebido: usa `bdi`/`<bdo>` y marcas Unicode si hace falta.

### 1.5 Arquitectura i18n
- **Catálogos por namespace/feature** (no un JSON gigante).
- **Lazy-load** del bundle de idioma activo; no envíes todos los idiomas.
- **Claves estables y semánticas** (`checkout.payment.cta`), no el texto como clave
  (salvo Paraglide/compile-time que lo gestiona).
- **Extracción automatizada** (i18next-parser, FormatJS extract, Lingui extract).
- **Fallback chain:** `es-CO → es → en` (idioma por defecto definido).
- **Detección de locale:** `Accept-Language` (SSR) > preferencia usuario > ruta.
- **Routing localizado:** `/es/...` `/en/...` o subdominio; emite `hreflang`.

### 1.6 Calidad i18n
- **Pseudo-localización** en CI (`[!!! Ţëšţ ñççç !!!]`) para detectar strings sin
  traducir y desbordes de layout antes de traducir de verdad.
- Tests: claves faltantes, placeholders huérfanos, longitud máxima por componente.
- Nunca textos en imágenes (no traducibles ni accesibles).

---

## 2. SEO técnico frontend

farola cubre el SEO **técnico/renderizado** (lo que afecta al frontend), no la
estrategia de contenido/keywords (eso es marketing/contenido).

### 2.1 Rendering y crawlability
- **Contenido indexable** debe llegar en el HTML inicial → SSR/SSG/ISR o
  prerender. SPA puro depende del render JS de Google (frágil, retardado) y otros
  buscadores/social crawlers **no** ejecutan JS.
- **Social crawlers** (WhatsApp, X, LinkedIn, Slack) leen solo HTML estático →
  Open Graph debe estar en el SSR/markup, no inyectado por JS.
- **Dynamic rendering** (servir HTML pre-renderizado a bots) es parche legacy;
  prefiere SSR/SSG real.

### 2.2 Metadatos esenciales
```html
<title>Título único 50-60 chars</title>
<meta name="description" content="155-160 chars, único por página">
<link rel="canonical" href="https://site.com/ruta">
<meta name="robots" content="index,follow">
<!-- Open Graph -->
<meta property="og:title" content="..."><meta property="og:description" content="...">
<meta property="og:image" content="https://site.com/og.png"><meta property="og:type" content="website">
<!-- Twitter/X -->
<meta name="twitter:card" content="summary_large_image">
<!-- i18n -->
<link rel="alternate" hreflang="es-co" href="https://site.com/co/">
<link rel="alternate" hreflang="x-default" href="https://site.com/">
```

| Framework | Gestión de `<head>` |
|-----------|---------------------|
| Next.js | Metadata API (`generateMetadata`) |
| Nuxt | `useHead` / `useSeoMeta` |
| SvelteKit | `<svelte:head>` |
| React SPA | React 19 native `<title>`/`<meta>` o react-helmet-async |
| Angular | `Title`/`Meta` services, SSR con Angular Universal |

### 2.3 Datos estructurados (JSON-LD)
```html
<script type="application/ld+json">
{ "@context":"https://schema.org","@type":"Product","name":"...","offers":{"@type":"Offer","price":"...","priceCurrency":"COP"} }
</script>
```
Tipos comunes: `Product`, `Article`, `BreadcrumbList`, `FAQPage`, `Organization`.
Valida con Rich Results Test. JSON-LD > microdata (más limpio, no acopla markup).

### 2.4 Infraestructura SEO
- `sitemap.xml` (dinámico si catálogo cambia) + `robots.txt`.
- Canonical correcto para evitar contenido duplicado (filtros, paginación, params).
- URLs limpias y estables; redirecciones 301 al cambiar rutas.
- Paginación: `rel=next/prev` deprecado por Google; usa enlaces crawleables + canonical.
- **Core Web Vitals son factor de ranking** → el trabajo de performance (perf doc)
  es también SEO.

### 2.5 Checklist SEO técnico
```
- [ ] Contenido crítico en HTML inicial (SSR/SSG)
- [ ] title + meta description únicos por ruta
- [ ] canonical correcto (sin duplicados por params)
- [ ] Open Graph + Twitter card en markup server
- [ ] JSON-LD válido en tipos aplicables
- [ ] hreflang si multi-idioma + x-default
- [ ] sitemap.xml + robots.txt servidos
- [ ] CWV en verde (LCP/INP/CLS)
- [ ] Imágenes con alt; headings jerárquicos (un h1)
- [ ] 404 real (status 404, no 200 soft-404)
```

---

## 3. Tiempo real y streaming

### 3.1 Transportes
| Transporte | Uso | Notas |
|------------|-----|-------|
| **WebSocket** | Bidireccional (chat, colaboración, juegos) | Reconexión manual; heartbeat |
| **SSE** (EventSource) | Server→cliente (feeds, notificaciones, tokens LLM) | Auto-reconnect nativo, HTTP simple |
| **Long polling** | Fallback legacy | Último recurso |
| **WebTransport** | Baja latencia moderno (HTTP/3) | Emergente, soporte parcial |

Regla farola: **SSE** si solo necesitas server→cliente (más simple, atraviesa
proxies). **WebSocket** si necesitas bidireccional real.

### 3.2 Patrones de robustez (obligatorios)
- **Reconexión con backoff exponencial + jitter** y límite de intentos.
- **Heartbeat/ping-pong** para detectar conexiones zombi.
- **Resync al reconectar:** pide estado/eventos perdidos (cursor/lastEventId).
- **Backpressure:** descarta/coalesce updates de alta frecuencia (rAF, throttle).
- **Indicador de conexión** en UI (conectado / reconectando / offline).
- **Optimistic + reconciliación:** aplica local, confirma con server, revierte si falla.

```ts
// SSE con reconexión y last-event-id
const es = new EventSource(`/stream?since=${lastId}`);
es.onmessage = (e) => { lastId = e.lastEventId; apply(JSON.parse(e.data)); };
es.onerror = () => { /* EventSource reintenta solo; muestra estado "reconectando" */ };
```

### 3.3 Servicios y colaboración
- Manejados: Pusher, Ably, Supabase Realtime, Convex, PartyKit, Liveblocks.
- **Presencia** (quién está online/escribiendo): canales de presence.
- **Colaboración concurrente / offline-merge:** CRDTs (**Yjs**, Automerge) para
  edición simultánea sin conflictos; evita "last write wins" en texto compartido.

### 3.4 Streaming UI
- **Streaming SSR + Suspense** (React/RSC): envía shell, luego rellena.
- **Token streaming** (chat IA): SSE → render incremental; cancela con AbortController.
- Skeleton por segmento mientras llega el stream.

---

## 4. PWA y offline-first

### 4.1 Componentes
- **Web App Manifest** (`name`, `icons`, `display: standalone`, `theme_color`).
- **Service Worker** (preferible vía **Workbox** o `vite-plugin-pwa`/Nuxt PWA).
- **Estrategias de cache:** cache-first (estáticos con hash), network-first (APIs),
  stale-while-revalidate (contenido semi-dinámico).
- **App shell** cacheado para arranque offline instantáneo.

### 4.2 Capacidades avanzadas
- **Background Sync:** cola de mutaciones offline → reenvía al recuperar red.
- **Push Notifications:** Push API + permiso explícito + valor real (no spam).
- **Offline queue** en IndexedDB (idb, Dexie) para acciones críticas.
- **Update flow:** detecta nuevo SW → prompt "Nueva versión disponible · Recargar"
  (evita versiones zombie en pestañas abiertas).

### 4.3 Reglas
- Pide permisos (push, notif) **en contexto**, tras valor demostrado, nunca al cargar.
- Estados offline explícitos en UI; nunca fallo silencioso.
- HTTPS obligatorio (SW solo en contextos seguros).
- Mide: ¿el SW mejora o entorpece? Un SW mal configurado sirve contenido viejo.

---

## 5. Rendering y UX de nueva generación

### 5.1 View Transitions API
Transiciones suaves entre estados/rutas con código mínimo.
```ts
if (document.startViewTransition) document.startViewTransition(() => updateDOM());
else updateDOM();
```
- SPA y MPA (cross-document) soportados en navegadores modernos.
- `view-transition-name` para elementos que se mueven entre vistas.
- Respeta `prefers-reduced-motion`.

### 5.2 Animaciones de scroll nativas
- `animation-timeline: scroll()/view()` (CSS, sin JS) para reveal/parallax.
- `IntersectionObserver` para lazy reveal y carga al entrar en viewport.

### 5.3 Prefetch / Speculation Rules
- `<link rel="prefetch">` y Speculation Rules API (`prerender`/`prefetch`) para
  navegación casi instantánea de rutas probables.
- Prefetch en hover/intent o en idle (`requestIdleCallback`).

### 5.4 Canales y superficies menos comunes (awareness)
| Superficie | Restricción clave |
|------------|-------------------|
| **Email HTML** | Tablas + CSS inline; sin JS; soporte CSS limitado (usa MJML) |
| **Embeds/widgets** | Aislamiento (iframe/Shadow DOM), tamaño, CSP del host |
| **Extensiones navegador** | Manifest V3, service worker, permisos mínimos, CSP estricta |
| **Desktop** | Electron/**Tauri** (Tauri = menor footprint); IPC seguro |
| **WebGL/Canvas/3D** | Three.js/R3F/PixiJS; presupuesto GPU, fallback 2D, a11y alterna |
| **TV / kioskos** | Navegación por D-pad/foco, distancias de lectura |

farola opera o asesora en todas: el principio (semántica, performance, a11y,
estados, seguridad) se mantiene; cambian las restricciones del medio.

---

## 6. Checklist de globalización y alcance (cierre)
```
- [ ] ¿El producto necesita i18n? Si sí: ICU + Intl + lazy locales + RTL ready
- [ ] ¿Necesita rankear/compartirse? SSR/SSG + meta + OG + JSON-LD + CWV
- [ ] ¿Hay datos en vivo? Transporte correcto + reconexión + reconciliación + indicador
- [ ] ¿Debe funcionar offline/instalable? Manifest + SW + cache strategy + update flow
- [ ] ¿UX premium? View Transitions + prefetch + reduced-motion respetado
- [ ] ¿Canal no estándar (email/extensión/desktop/3D)? Restricciones del medio aplicadas
```
