# Accesibilidad e Inclusive Design

La accesibilidad es **parte nativa del diseño**, no una validación tardía. El
objetivo: que la mayor diversidad de personas pueda percibir, entender, navegar
e interactuar. Diseñar accesible mejora la experiencia para todos.

## 1. Marco: WCAG 2.2 y POUR

Las WCAG se organizan en 4 principios (**POUR**):

- **Perceptible**: la información debe poder percibirse (texto alternativo,
  contraste, subtítulos, no depender solo del color/sonido).
- **Operable**: usable con cualquier método de entrada (teclado, switch, voz);
  foco visible; sin trampas de teclado; tiempo suficiente; sin contenido que
  cause convulsiones (flashes).
- **Understandable**: legible y predecible; comportamiento consistente; ayuda y
  prevención de errores.
- **Robust**: compatible con tecnologías de asistencia (HTML semántico, ARIA
  correcto, nombre/rol/valor expuestos).

Niveles: **A** (mínimo), **AA** (estándar objetivo y legal habitual), **AAA**
(máximo, exigible en salud/gobierno/finanzas según contexto).

Novedades clave de WCAG 2.2 a vigilar: foco no oculto (Focus Not Obscured),
tamaño de objetivo mínimo (Target Size 24×24 CSS px, AA), ayuda consistente
(Consistent Help), entrada redundante (Redundant Entry), autenticación accesible
(Accessible Authentication, sin pruebas cognitivas tipo captcha sin alternativa),
y arrastre con alternativa (Dragging Movements).

## 2. Contraste y baja visión

- Texto normal ≥**4.5:1**, texto grande (≥24px o ≥18.66px bold) ≥**3:1**.
- Componentes de UI y gráficos significativos ≥**3:1** contra el fondo.
- Soporta zoom hasta 200% sin pérdida de contenido/función; reflow a 320px CSS.
- Respeta el escalado de texto del sistema (Dynamic Type); evita truncamiento al
  crecer el texto.
- No transmitas información solo por color (añade icono, texto o patrón).

## 3. Teclado y foco

- Toda función disponible por teclado; **orden de foco** lógico = orden visual.
- **Foco visible** y claro (no remuevas el outline sin reemplazo equivalente).
- Sin **keyboard traps**; modales atrapan foco *intencionalmente* y lo liberan
  al cerrar, devolviéndolo al disparador.
- **Skip links** ("saltar al contenido") para usuarios de teclado/lector.
- Atajos que no interfieran con los de la tecnología de asistencia.

## 4. Lectores de pantalla y semántica

- **HTML semántico primero** (`button`, `nav`, `main`, `h1–h6`, `label`,
  `table`); ARIA solo cuando el HTML nativo no basta ("primera regla de ARIA:
  no uses ARIA si hay un elemento nativo").
- Expón **nombre, rol y valor** de cada control; estados (expanded, selected,
  checked, disabled, current) anunciados.
- **Jerarquía de encabezados** secuencial sin saltos; landmarks para navegar.
- **Texto alternativo** descriptivo en imágenes con significado; `alt=""` en
  decorativas.
- **Live regions** (`aria-live="polite"` / `role="alert"`) para cambios
  dinámicos (errores, toasts) sin robar el foco.
- Formularios: `label` asociado, instrucciones y errores vinculados
  (`aria-describedby`), foco al primer campo inválido, resumen de errores.

## 5. Motor, cognición y otras dimensiones

- **Motor**: objetivos de toque amplios (≥44pt/24px), espaciado suficiente,
  alternativas a gestos complejos y drag&drop, tolerancia a errores de
  precisión, sin acciones por tiempo límite estricto.
- **Cognición**: lenguaje claro y simple, pasos cortos, reduce carga (Hick/
  Miller), consistencia, ayuda contextual, evita jerga, divulgación progresiva,
  permite deshacer.
- **Auditiva**: subtítulos y transcripciones en audio/video; no dependas del
  sonido como único canal.
- **Vestibular**: respeta `prefers-reduced-motion`; evita parallax/animaciones
  que mareen; ofrece alternativa estática.
- **Fotosensibilidad**: nada que destelle >3 veces/segundo.

## 6. Discapacidades permanentes, temporales y situacionales

Diseña para el espectro (Microsoft Inclusive Design): brazo roto (temporal),
cargar a un bebé (situacional), sol directo, ruido, conexión lenta. La
accesibilidad permanente beneficia a todos en algún momento ("curb-cut effect").

## 7. Marco legal y normativo

- **EAA** (European Accessibility Act) — obligatorio en la UE.
- **EN 301 549** (estándar europeo, referencia WCAG).
- **Section 508** y **ADA** (EE. UU.).
- Normativas locales (p. ej. Colombia: Resolución/normas de accesibilidad
  digital del Estado; muchos países exigen WCAG AA en lo público).
- En salud, finanzas y gobierno, trata AA como piso y evalúa AAA.

## 8. Proceso e integración

- Accesibilidad desde research (incluye usuarios con discapacidad), diseño
  (contraste, foco, estados en specs), sistema (componentes accesibles por
  defecto) y validación.
- **Auditoría**: combina automático (axe, Lighthouse, WAVE) — detecta ~30–40% —
  con **pruebas manuales** (teclado, lector de pantalla NVDA/VoiceOver/TalkBack)
  y, cuando se pueda, con usuarios reales.
- Documenta hallazgos con criterio WCAG, severidad y remediación (ver
  [metricas-validacion.md](metricas-validacion.md)).

## 9. Checklist rápido de accesibilidad

```
- [ ] Contraste AA en texto y componentes
- [ ] Operable 100% por teclado, foco visible, sin traps
- [ ] Orden de foco = orden visual; skip link presente
- [ ] HTML semántico; ARIA solo cuando es necesario y correcto
- [ ] Nombre/rol/valor y estados expuestos a lectores
- [ ] Texto alternativo correcto; decorativas con alt vacío
- [ ] Formularios con labels, errores vinculados y foco al error
- [ ] Color no es el único indicador
- [ ] prefers-reduced-motion respetado
- [ ] Objetivos de toque ≥24px (AA) / 44pt; zoom 200% sin romper
- [ ] Subtítulos/transcripción en multimedia
- [ ] Probado con lector de pantalla real, no solo automático
```

> Una experiencia que excluye no es excelente. La accesibilidad es calidad, no
> caridad.
