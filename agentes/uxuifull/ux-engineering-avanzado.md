# UX Engineering y Experiencias Avanzadas

Comprende la implementación de interfaces **desde la perspectiva de la
experiencia**, sin convertirte en ingeniero generalista. Tu foco: que lo
diseñado sea viable, fiel y de calidad percibida alta.

## 1. Fidelidad diseño↔código (design-to-code)

- Lo diseñado debe ser **implementable**: usa restricciones reales (grid,
  tokens, componentes existentes) y evita specs imposibles o inconsistentes.
- **Handoff** claro: tokens, estados, breakpoints, comportamiento, anotaciones
  de interacción y accesibilidad. El diseño define el "qué" y el "cómo se
  comporta", no solo el "cómo se ve".
- **Paridad de componentes**: el componente en código replica variantes,
  estados y comportamiento del diseño (ver [design-systems.md](design-systems.md)).
- Verifica el resultado real contra el diseño (drift visual y de comportamiento).

## 2. Estados reales y comportamiento

- Implementa **todos** los estados (vacío/carga/error/parcial/lleno/éxito/
  disabled/focus) — no solo el happy path (ver
  [interaccion-disenio.md](interaccion-disenio.md)).
- Comportamiento responsive real: reflow, truncamiento, contenido dinámico,
  textos largos, datos extremos (0, 1, muchos, demasiados).
- Estados de red: offline, lento, timeout, reintento.

## 3. Rendimiento percibido (lo que el usuario siente)

- **Feedback inmediato** (<100 ms) a cada input; progreso si tarda más
  (Doherty threshold ~400 ms).
- **Skeleton screens / shimmer** para esperas >1 s en vez de spinners largos;
  **optimistic UI** cuando el éxito es probable.
- **Percepción > medición**: la experiencia puede sentirse rápida aunque el
  backend no lo sea, con buen manejo de carga progresiva y prioridad de
  contenido visible primero.

> **Rendimiento medible (Core Web Vitals, fps, técnicas de optimización): fuera
> de alcance.** uxuifull define el *objetivo* de experiencia ("debe sentirse
> rápido", ver §3) y lo entrega como criterio; la ingeniería de rendimiento
> (LCP/INP/CLS, code splitting, optimización de imágenes/hilo) es de
> **`peakformance`** (dueño del performance; `farola` implementa en su capa).

## 4. Animación y movimiento (con criterio)

- Duración 150–300 ms en microinteracciones, ≤400 ms en transiciones;
  ease-out al entrar, ease-in al salir; salida ~60–70% de la entrada.
- Anima solo `transform`/`opacity` (evita width/height/top/left, que causan
  saltos/jank y reflow).
- El movimiento **comunica** (causa-efecto, continuidad espacial, jerarquía),
  no decora; máximo 1–2 elementos clave por vista.
- **Respeta `prefers-reduced-motion`** siempre; ofrece alternativa estática.
- Animaciones interrumpibles; nunca bloquees el input durante una animación.

## 5. Interfaces avanzadas e inmersivas

- **Páginas interactivas / scrollytelling**: narrativa guiada por scroll;
  cuida rendimiento, accesibilidad (no atrapar el scroll, alternativa lineal) y
  reduced-motion.
- **3D / WebGL / Three.js / R3F**: úsalo cuando aporta comprensión o valor (no
  por espectáculo); controla peso, carga progresiva, fallback 2D, y
  accesibilidad (descripción textual, controles alternativos).
- **AR/VR / spatial / visionOS**: ergonomía espacial, confort (evita mareo),
  affordances en 3D, escala humana, entrada por mirada/gesto/voz, descanso y
  seguridad. Sigue guías espaciales (Apple visionOS, Meta).
- **Data-heavy / dashboards**: jerarquía de información, densidad controlada,
  drill-down, estados de carga por widget, gráficos accesibles (ver
  [interfaz-visual.md](interfaz-visual.md) y métricas en
  [metricas-validacion.md](metricas-validacion.md)); para elección de encoding,
  paletas accesibles y layout de dashboards, apóyate en la skill aliada `dataviz`
  como insumo (misma jerarquía de criterio que `ui-ux-pro-max`).

## 5 bis. Sostenibilidad digital (green UX)

El diseño tiene huella de carbono: cada byte transferido y cada ciclo de cómputo
consumen energía. uxuifull integra la **sobriedad** como criterio de experiencia
(no como budget técnico — la medición/optimización de rendimiento es de
`peakformance`).

- **Referencia**: W3C **Web Sustainability Guidelines (WSG)** como marco de
  awareness; eco-diseño alineado con accesibilidad y rendimiento percibido (a
  menudo apuntan al mismo lado: menos peso = más rápido y más inclusivo).
- **Sobriedad de datos y media**: imágenes/video del tamaño justo, carga diferida,
  evitar autoplay pesado; el contenido más ligero que cumpla el objetivo.
- **Sobriedad de motion**: menos animación gratuita también es menos cómputo
  (refuerza "motion justificado" y `prefers-reduced-motion`).
- **Defaults sobrios**: calidad/resolución/refresh razonables por defecto;
  patrones que no exijan navegación ni cómputo innecesarios (findability reduce
  páginas visitadas).
- **Frontera**: uxuifull decide el *criterio de sobriedad* (qué es "suficiente");
  la medición de transferencia/energía y su optimización técnica —p. ej. estimar
  huella con **Sustainable Web Design Model (SWDM)**— son de `peakformance`/`farola`.
  uxuifull entrega el objetivo de sobriedad como criterio; ellos lo miden.

## 6. Interfaces con IA y conversacionales

- **Expectativas claras**: comunica capacidades y límites; transparencia de que
  es IA.
- **Manejo de incertidumbre**: muestra confianza/fuentes cuando aplique; permite
  verificar y corregir; nunca presentes alucinación como certeza.
- **Control del usuario**: editar, regenerar, deshacer, detener; el usuario
  mantiene el mando.
- **Estados de IA**: pensando/streaming, error, sin resultado, escalamiento a
  humano.
- **Patrones**: prompts sugeridos, citaciones, feedback (👍/👎), historial,
  manejo de latencia con streaming.
- **Conversacional (chat/voz)**: turnos claros, recuperación de errores ("no
  entendí" con salida), contexto persistente, accesibilidad multimodal.
- Ética: privacidad, sesgo, consentimiento, y diseño para la confianza calibrada
  (ni exceso ni defecto de confianza).

## 6 bis. UI generativa, adaptativa y personalización

Más allá de *diseñar para IA*, hoy se diseña **con IA como material**: interfaces
que se generan, adaptan o personalizan dinámicamente. Es potente y riesgoso; se
gobierna con guardarraíles.

- **UI adaptativa/personalizada**: la interfaz cambia según contexto, historial o
  perfil. Diseña la **lógica de adaptación** (qué cambia, con qué señal, con qué
  límites), no solo el estado por defecto.
- **UI generativa**: componentes o layouts producidos por un modelo en runtime.
  Exige **barandas de consistencia** (que respete el design system y sus tokens),
  no un lienzo libre que rompa la coherencia.
- **Riesgos a mitigar**: pérdida de **consistencia** y de modelo mental; menos
  **control** del usuario; **explicabilidad** ("¿por qué veo esto?"); **filter
  bubbles**/encierro; e inequidad si la personalización esconde opciones. Ofrece
  siempre **override, transparencia y una vista no personalizada**.
- **Personalización honesta**: personalizar para servir al usuario, no para
  manipular (enlaza [etica-y-patrones-enganosos.md](etica-y-patrones-enganosos.md)).
- **IA en el proceso de diseño**: úsala para acelerar exploración/variantes, pero
  el criterio (evidencia, accesibilidad, marca) sigue siendo humano; trata su
  salida como insumo, igual que a `ui-ux-pro-max`.
- **Frontera**: uxuifull diseña la **capa de experiencia** de la IA (transparencia,
  control, estados, override, consistencia, honestidad). El **modelo/ML,
  entrenamiento, serving y MLOps son de `sysuniversal-ai`**, y la **seguridad de
  IA/LLM (inyección de prompts, robustez del modelo) es de `vector`**; uxuifull
  señala la dependencia, no la decide (aplica también a §6).

## 7. Multiplataforma e idioms

Respeta convenciones nativas (Apple HIG, Material 3, Fluent 2) y las
capacidades del medio; comparte tokens y lógica donde tenga sentido sin imponer
un idiom ajeno (ver [interfaz-visual.md](interfaz-visual.md)).

## 8. Entregables

- Specs de implementación con tokens, estados, breakpoints y comportamiento.
- Criterios de rendimiento percibido (objetivos de rendimiento medible se
  trasladan como criterio a `peakformance`, dueño del performance; `farola`
  implementa en su capa).
- Guía de motion (duraciones, easing, reduced-motion).
- Lineamientos para experiencias avanzadas (3D/AR/IA) con fallback y
  accesibilidad.

> La mejor experiencia diseñada fracasa si la implementación se siente lenta,
> salta o rompe estados. La calidad percibida es parte del diseño.
