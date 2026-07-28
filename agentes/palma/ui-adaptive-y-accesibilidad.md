# UI nativa, adaptive por form-factor y accesibilidad mobile

Este satélite gobierna cómo **palma construye** la interfaz de aplicaciones móviles nativas y cross-platform: UI declarativa e imperativa, adaptación real por **form-factor** (no responsive web), gestos táctiles, animación con propósito, theming y — de forma central, no opcional — **accesibilidad móvil**. palma no diseña la experiencia (eso es de uxuifull); palma la materializa en código que corre en el dispositivo, respeta las convenciones de cada plataforma (ver [plataformas-nativas.md](plataformas-nativas.md)) y coopera con los canales web híbridos (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)).

## 1. UI nativa: declarativa vs imperativa

La UI móvil se construye hoy predominantemente con **frameworks declarativos** (p. ej. SwiftUI, Jetpack Compose, React Native, Flutter): se describe *qué* estado produce *qué* vista, y el framework reconcilia el árbol. El paradigma **imperativo** clásico (p. ej. UIKit, Android View system) sigue vivo, es dueño de casos límite (rendimiento fino, interop, componentes legados) y muchas apps son híbridas de ambos.

| Criterio | Declarativo | Imperativo |
|---|---|---|
| Modelo mental | estado → vista, reconciliación | mutación manual de la jerarquía |
| Boilerplate | bajo, composable | alto, verboso |
| Control fino | acotado por el framework | total (frame por frame) |
| Interop | requiere puentes/wrappers | acceso directo a la API nativa |
| Cuándo | pantallas de producto, iteración rápida | listas gigantes, custom drawing, migración gradual |

**Componentes reutilizables y design tokens.** palma construye una biblioteca de componentes propios (botón, campo, tarjeta, hoja modal) parametrizados por **design tokens** — color, tipografía, espaciado, radios, elevación, motion — que **recibe de uxuifull**. Los tokens no se hardcodean: se resuelven en tiempo de tema (claro/oscuro, marca, contraste) y se mapean a las primitivas de cada plataforma. Un token semántico (`color.surface.raised`) vale más que uno literal (`gris-200`): sobrevive al re-theming y a la accesibilidad.

## 2. Adaptive por form-factor (NO es responsive web)

Este es el concepto que **distingue a un ingeniero mobile**. El *responsive web* reflowa un documento por ancho de viewport en píxeles CSS. El **adaptive nativo** reorganiza la app según **clases de tamaño y capacidades del dispositivo**, no solo su ancho: es una decisión de *layout intent*, no de estiramiento.

**Estirar la UI de teléfono a tablet es un anti-patrón.** Una tablet no es un teléfono grande: es una oportunidad para layouts de dos paneles, navegación persistente y densidad distinta.

| Form-factor | Patrón nativo típico | Riesgo si se "estira" |
|---|---|---|
| Teléfono (compacto) | navegación por stack, un panel, tab bar | — |
| Tablet (regular/expandido) | split view / two-pane, sidebar, grids | líneas de texto larguísimas, blancos enormes |
| Plegable (foldable) | continuidad al plegar/desplegar, *hinge/posture*, table-top | contenido partido por el pliegue |
| Escritorio/externo | ventanas redimensionables, menús, punteros/hover | controles táctiles sueltos, targets perdidos |

Herramientas del oficio (agnósticas): **size classes / window size classes** (compacto / medio / expandido), lectura de la **orientación**, **multi-ventana** y **split-screen**, *drag & drop* entre ventanas, y APIs de **postura del plegable**. La regla: consultar la **clase de tamaño de la ventana**, no la del dispositivo — una app en split-view en tablet vive en un contenedor "compacto" aunque la pantalla sea grande.

**Breakpoints por intención, no por número mágico.** Se define el punto donde el layout *cambia de forma* (uno → dos paneles) porque el contenido lo pide, no un ancho arbitrario copiado de la web.

## 3. Safe areas, insets, densidades y escalado

- **Safe areas / insets.** Todo layout respeta las zonas seguras: notch, **Dynamic Island**, cámaras perforadas, barras de sistema, gesture bars, teclado (IME insets). El contenido *decorativo* (fondos, imágenes) puede sangrar bajo ellas; el contenido *interactivo o crítico* nunca.
- **Densidad de pantalla.** Se trabaja en unidades independientes de densidad (p. ej. `dp`/puntos), nunca en píxeles físicos. Los assets se proveen en múltiples densidades o como vectores para nitidez en cualquier DPI.
- **Escalado.** El layout debe sobrevivir al **escalado de fuente del sistema** (ver §7): nada de alturas fijas que recorten texto cuando el usuario sube el tamaño. Se prefieren contenedores que crecen con el contenido.

## 4. Gestos, interacción táctil y touch targets

La entrada primaria es el **dedo**: impreciso, opaco (tapa lo que toca) y multitáctil.

- **Gestos base:** tap, doble tap, long-press, swipe, pan/drag, pinch/zoom, rotación. Se componen con reconocedores nativos y se resuelven conflictos de prioridad (p. ej. swipe de fila vs scroll del contenedor).
- **Touch targets mínimos.** Objetivo táctil cómodo ~**44–48 dp** por lado con separación suficiente, aunque el ícono visible sea menor (área de toque expandida). Esto es simultáneamente ergonomía **y accesibilidad motora**.
- **Feedback inmediato:** estados pressed/hover/focus, *haptics* con mesura y respeto por las convenciones de cada plataforma.
- **No dependas solo del gesto.** Todo gesto oculto (swipe-para-borrar, long-press) debe tener una **alternativa visible/accesible** — requisito de accesibilidad, no lujo (§7).

## 5. Animaciones y transiciones

El movimiento **comunica**: jerarquía, causalidad, continuidad espacial. No es decoración.

- **Motion con propósito:** feedback de estado, orientación al navegar, revelación progresiva. Animar *hacia* significado, no *hacia* espectáculo.
- **Shared element / transiciones de continuidad:** un elemento persiste entre pantallas para preservar el contexto (lista → detalle).
- **Rendimiento:** animar en el hilo correcto y sobre propiedades baratas; evitar jank. Metas y presupuestos de rendimiento los fija peakformance; palma implementa dentro de ellos.
- **Respetar "reduce motion".** Si el usuario activa *reduce motion* / *remove animations*, palma sustituye traslaciones y parallax por *cross-fades* suaves o cambios instantáneos. Es un ajuste de accesibilidad vestibular, obligatorio.

## 6. Theming

- **Dark mode / light mode** como ciudadanos de primera clase: colores resueltos por token, no dos árboles duplicados. Nada de blancos puros que deslumbren en oscuro.
- **Dynamic color:** en plataformas que lo ofrecen (p. ej. color derivado del fondo del usuario), palma respeta o *opta-out* con criterio de marca.
- **Alto contraste / contraste aumentado:** temas alternos que elevan separación de color y bordes cuando el sistema lo pide.
- **Temas por marca / white-label:** el mismo árbol de componentes sirve múltiples marcas cambiando el set de tokens, sin bifurcar la UI.

## 7. Accesibilidad mobile (central, no anexa)

La accesibilidad móvil **no es la web**: son APIs de plataforma y lectores de pantalla distintos, con gestos propios.

| Eje | Qué hace palma | API nativa (p. ej.) |
|---|---|---|
| Lector de pantalla | labels, roles/traits, hints, agrupación, anuncios de cambios | VoiceOver / TalkBack |
| Tamaño de texto | soportar Dynamic Type / escala de fuente del sistema, layouts que crecen | text styles escalables |
| Contraste | cumplir ratios de contraste de texto y de componentes | temas y tokens de contraste |
| Orden de foco | orden de lectura lógico, foco tras navegación, atrapar foco en modales | accessibility order/focus |
| Semántica | roles, estados (seleccionado, deshabilitado), valores, acciones custom | semantics / accessibility nodes |
| Motricidad | touch targets amplios, alternativas a gestos, tiempos ajustables | ver §4 |

Reglas irrenunciables:

1. **Todo elemento interactivo es alcanzable y anunciable** por el lector de pantalla, con **label, rol y estado** correctos. Los íconos sin texto llevan label; lo decorativo se marca como ignorable para no ensuciar el recorrido.
2. **No depender solo del color** para transmitir información (error, estado): añadir texto, ícono o forma.
3. **No depender solo de un gesto:** exponer acciones equivalentes (menú, botón, *accessibility custom actions*).
4. **Dynamic Type / escala de fuente:** el texto crece hasta los tamaños de accesibilidad sin recortes ni solapamientos; se prueba en el extremo grande.
5. **Orden y gestión de foco:** foco inicial correcto al abrir pantallas/modales, orden que sigue la lectura visual, y trampa de foco en diálogos.
6. **Teclados semánticos:** tipo de teclado según el campo (email, numérico, teléfono, URL), `content type`/autofill y acción de retorno adecuada — accesibilidad y ergonomía a la vez.
7. **Objetivos táctiles** conforme §4; tiempos y timeouts ajustables; *haptics* nunca como único canal.

La accesibilidad se **verifica**: recorridos con el lector de pantalla activo, escaneos automáticos (accessibility scanner/inspector) y pruebas manuales con escala de fuente máxima y reduce-motion. QA lo valida como criterio de aceptación con amado.

## 8. Frontera explícita de ownership

| Responsabilidad | Dueño |
|---|---|
| Research, journeys, wireframes, sistema de diseño, **design tokens** | **uxuifull** (DISEÑA) |
| Construcción de la UI nativa, componentes, adaptive por form-factor, a11y implementada | **palma** (CONSTRUYE) |
| **Responsive web** (reflow por viewport en el navegador), PWA, UI web del híbrido | **farola** |
| **Adaptive nativo por form-factor** (size classes, split view, plegables, multi-ventana) | **palma** |

Dos conceptos **distintos que no se solapan**: el *responsive web* de farola reacomoda un documento por ancho de viewport dentro del navegador; el *adaptive nativo* de palma reorganiza una app según clases de tamaño y capacidades del dispositivo con widgets nativos. uxuifull entrega la intención de diseño y los tokens; palma decide su traducción idiomática a cada plataforma. Cuando el diseño no contempla un form-factor (tablet, plegable), palma lo señala y lo devuelve a uxuifull en vez de improvisar. Detalle de convenciones por plataforma en [plataformas-nativas.md](plataformas-nativas.md); el shell del híbrido y su UI web, en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## 9. Greenfield, en construcción y brownfield

- **Greenfield:** definir desde el día cero la escala de form-factors soportados, el set de tokens y el contrato de accesibilidad; componentes accesibles y adaptive *por defecto*.
- **En construcción:** endurecer componentes ya vivos — extraer tokens, añadir soporte de tablet/plegable donde falte, cerrar brechas de a11y antes de que se multipliquen.
- **Brownfield:** auditar deuda de UI (pantallas estiradas, labels ausentes, alturas fijas, dark mode roto), priorizar por impacto y riesgo, e introducir la capa declarativa o los tokens de forma incremental sin reescribir todo de golpe.

## 10. Modelo tiered

- **T1 — palma construye:** implementa la UI nativa, el layout adaptive por form-factor, gestos, animación, theming y la accesibilidad en código. Dueño de la construcción.
- **Diseño / experiencia:** decisiones de research, journeys, jerarquía visual y tokens → **uxuifull**. palma consume, no inventa la experiencia.
- **Accesibilidad legal / normativa:** obligaciones de cumplimiento (leyes de accesibilidad, auditorías formales, políticas corporativas) → **gobernanza**. palma implementa a nivel técnico y evidencia; no dictamina el marco legal.
