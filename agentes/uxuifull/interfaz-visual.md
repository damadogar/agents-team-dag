# UI / Visual Design

La UI responde a objetivos de experiencia, no a decoración. Cada decisión visual
existe para crear jerarquía, guiar la atención y comunicar significado.

## 1. Jerarquía visual

- Guía el ojo en orden de importancia mediante **tamaño, peso, color, contraste,
  espacio y posición**. No uses solo color (accesibilidad).
- Establece **una sola acción primaria por vista**; las secundarias se
  subordinan visualmente.
- Patrones de escaneo: F (texto), Z (landings), capas (apps densas). Coloca lo
  crítico donde cae la mirada.
- **Leyes de Gestalt**: proximidad, similitud, cierre, continuidad, figura-fondo,
  región común → agrupan y separan sin necesidad de bordes ni líneas.

## 2. Layout y grids

- **Grid**: columnas (responsive: 4/8/12), márgenes y gutters consistentes.
- **Spacing system**: escala basada en 4/8 pt (4, 8, 12, 16, 24, 32, 48, 64).
  Coherencia de ritmo vertical y horizontal.
- **Densidad**: ajústala al contexto (un dashboard financiero tolera más
  densidad que una landing). Equilibra densidad con escaneabilidad.
- **Whitespace** intencional: agrupa lo relacionado, separa secciones, da
  respiro; no es espacio "desperdiciado".
- **Container width**: ancho de línea legible (~60–75 car. en desktop, 35–60 en
  móvil); evita párrafos de borde a borde.

## 3. Tipografía

- **Escala tipográfica** consistente (p. ej. 12/14/16/18/24/32/48) con roles
  (display, headline, title, body, label) — alineado a Material/HIG.
- **Cuerpo ≥16 px** en móvil (evita zoom automático en iOS).
- **Line-height** 1.4–1.6 en cuerpo; **tracking** moderado; jerarquía por peso
  (700 títulos, 400 cuerpo, 500 labels).
- **Pairing**: combina personalidades complementarias (una para títulos, otra
  para cuerpo) o una sola superfamilia bien usada.
- **Tabular figures** para datos, precios y timers (evita saltos de layout).

## 4. Color

- **Sistema semántico** con tokens (primary, secondary, surface, on-surface,
  success, warning, error, info) — nunca hex crudos en componentes (ver
  [design-systems.md](design-systems.md)).
- **Contraste**: AA ≥4.5:1 texto normal, ≥3:1 texto grande y elementos UI;
  verifica siempre (ver [accesibilidad.md](accesibilidad.md)).
- **El color no es el único portador de significado**: acompaña con icono/texto
  (daltonismo).
- **Modo oscuro**: variantes tonales desaturadas/elevadas, no inversión literal;
  testea contraste por separado. Diseña claro y oscuro juntos.
- **Espacios de color modernos** (OKLCH/HSL) para escalas perceptualmente
  uniformes; define escalas de 50–900 por matiz.

## 5. Componentes e iconografía

- **Composición**: construye con componentes reutilizables y variantes
  consistentes; pensar en sistema (Atomic Design: átomos→moléculas→organismos).
- **Iconos**: una sola familia, grosor de trazo y estilo (filled vs outline)
  coherentes; SVG/vector, nunca emojis como iconos estructurales; tamaños como
  tokens (16/20/24).
- **Elevación/sombras**: escala consistente para cards, sheets, modales; evita
  valores arbitrarios.
- **Radios, bordes y efectos** alineados al estilo elegido (flat, glass, etc.)
  y aplicados de forma sistemática.

## 6. Responsive y multi-plataforma

- **Mobile-first**, breakpoints sistemáticos (p. ej. 375/768/1024/1440); sin
  scroll horizontal; viewport meta correcto (nunca deshabilites zoom).
- **Adapta, no encojas**: navegación, densidad y layout cambian por tamaño
  (bottom nav en móvil, sidebar en desktop).
- **Idioms de plataforma**: Apple HIG (iOS/macOS), Material 3 (Android/web),
  Fluent 2 (Microsoft). Respeta convenciones nativas de navegación, controles,
  tipografía y movimiento; no impongas el idiom de una plataforma a otra.
- **Safe areas** (notch, isla dinámica, barra de gestos) y elementos fijos con
  padding seguro.

## 7. Estilo según producto (sin sesgo de moda)

- Elige el estilo por **tipo de producto, marca y contexto**, no por tendencia.
  Minimalismo, bento, glassmorphism, brutalismo, neumorfismo, flat, etc., son
  herramientas: úsalas solo si mejoran claridad y encajan con la marca.
- **Consistencia** del estilo en todo el producto; no mezcles lenguajes
  visuales al azar.
- El **aesthetic-usability effect** es real (lo bello se percibe más usable)
  pero **no sustituye** usabilidad: primero funciona, luego encanta.

## 8. Calidad visual percibida (detalles que delatan amateur)

Alineación pixel-perfect, espaciado rítmico (4/8), contraste suficiente, estados
completos, sombras consistentes, iconos homogéneos, texto sin viudas/huérfanas
problemáticas, imágenes con dimensiones reservadas (evita saltos de layout),
microcopy cuidado. La excelencia está en la suma de detalles coherentes.

## 9. Entregables de UI

- Sistema visual (tokens de color/tipografía/espaciado/elevación).
- Biblioteca de componentes con variantes y estados.
- Especificaciones de layout y grid por breakpoint.
- Guía de iconografía e imágenes.
- Mockups/specs listos para implementación con anotaciones.

> Toda decisión visual responde a una necesidad de experiencia. Si un elemento no
> aporta jerarquía, significado o acción, elimínalo.
