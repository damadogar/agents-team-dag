# Ejemplos resueltos (few-shot)

Muestran el estándar de profundidad y el formato. Son ilustrativos; adapta al
caso real y apóyate en evidencia/supuestos explícitos.

## Ejemplo 1 — Brownfield: e-commerce con caída de conversión en checkout

**Petición original:** "Hagan el botón de pagar más llamativo, no convierte."

**1. Reformulación estratégica.** El síntoma (botón) no es la causa probable. El
problema real: fricción y falta de confianza en el flujo de checkout que provoca
abandono. [SUPUESTO] checkout multipaso sin invitado; sin analítica de embudo
compartida.

**2. Diagnóstico UX/UI.** (hipótesis a validar con embudo + 5 tests)
- IxD/Flujo: checkout obligatorio con cuenta → barrera #1 conocida (severidad 4).
- Contenido: errores genéricos ("datos inválidos"), sin indicar campo (sev 3).
- UI: costos de envío revelados al final → sorpresa, abandono (sev 4).
- A11y: campos sin label asociado; foco no va al primer error (sev 3).
- Confianza: sin señales de seguridad/metodos de pago visibles (sev 2).

**3. Estructura de experiencia.** Checkout como invitado por defecto; mostrar
costos totales temprano; reducir pasos; un objetivo por paso.

**4. IA.** Resumen de pedido persistente; orden lógico: contacto → envío → pago
→ revisión. Indicador de progreso.

**5. Interacción e interfaz.** Validación inline en blur con mensajes que dicen
causa+solución; CTA primario único por paso; estados de carga/optimistic en
"pagar"; autocompletado y teclados semánticos en móvil.

**6. Accesibilidad.** Labels asociados, errores con `aria-describedby` y foco al
primer inválido, contraste AA, objetivos ≥44pt.

**7. Validación.** A/B: checkout invitado vs actual; métrica primaria = tasa de
conversión de checkout; secundaria = abandono por paso; SEQ post-compra. Test de
usabilidad con 5 usuarios móviles.

**8. Entregables.** Flujo to-be (Mermaid), specs de estados, copy de errores,
backlog priorizado. **Próximos pasos:** instrumentar embudo, P0 = checkout
invitado + costos tempranos. **Éxito:** +X% conversión, −Y% abandono en paso de
envío, SEQ ≥6/7.

---

## Ejemplo 2 — Greenfield: app móvil de salud (onboarding)

**Petición:** "Diseña el onboarding de la app."

**1. Reformulación.** Objetivo: que el usuario llegue al **primer valor** rápido
y con confianza, no recolectar datos primero. JTBD: "cuando empiezo a cuidar mi
condición, quiero entender qué hacer hoy para sentir control".

**2. Diagnóstico (preventivo).** Riesgos típicos: formularios largos antes de
valor; permisos pedidos sin contexto; jerga médica; carga cognitiva alta.

**3. Estructura.** Valor antes que registro; permisos *just-in-time* con
explicación; personalización progresiva.

**4. IA.** 3 momentos: bienvenida con propuesta de valor → configuración mínima
→ primer "hoy" accionable. Datos opcionales diferidos.

**5. Interacción/UI.** Pasos cortos con progreso; defaults sensatos; lenguaje
claro y cálido; un CTA por pantalla; estados vacíos que enseñan.

**6. Accesibilidad.** Dynamic Type, contraste AA, lector de pantalla, objetivos
amplios; nada solo por color (datos de salud).

**7. Validación.** Métrica = tasa de activación (llegar al primer valor) D1;
SEQ; test moderado con población objetivo (incl. baja visión/adultos mayores).

**8. Entregables.** Flujo, wireframes anotados, copy, criterios A11y AA (salud →
considerar AAA en contraste). **Éxito:** activación D1 ≥ meta, drop-off de
permisos ≤ umbral.

---

## Ejemplo 3 — Auditoría de design system inconsistente (en construcción)

**Petición:** "Tenemos botones distintos en cada pantalla, ordénalo."

**1. Reformulación.** El problema no son los botones: falta sistema (tokens +
gobernanza). Síntoma = divergencia visual; causa = ausencia de fuente de verdad.

**2. Diagnóstico.** Hex crudos en componentes; sin tokens semánticos; estados
incompletos (sin focus/disabled); accesibilidad no incorporada; sin proceso de
contribución.

**3–5. Solución.** Definir tokens (primitivos→semánticos→componente);
componente Button con variantes/estados/A11y por defecto; documentación con
do/don't; theming claro/oscuro vía tokens.

**6. Accesibilidad.** Foco visible, contraste AA por variante, roles correctos.

**7. Validación.** Métrica de adopción (% UI usando el componente), reducción de
divergencias, auditoría de consistencia recurrente.

**8. Entregables.** Inventario de tokens, spec de Button, modelo de gobernanza y
versionado. **Éxito:** adopción ≥80% en N sprints, 0 hex crudos nuevos en PRs.

---

## Ejemplo 4 — Interfaz con IA (asistente)

**Petición:** "Pongamos un chat con IA en el producto."

**1. Reformulación.** ¿Qué job resuelve mejor un asistente que la UI actual?
Riesgo de añadir IA por moda. [SUPUESTO] soporte de dudas y acciones guiadas.

**2–5. Solución.** Expectativas claras de capacidad y transparencia (es IA);
prompts sugeridos; streaming con estado "pensando"; citaciones/fuentes cuando
aplique; control del usuario (detener, editar, regenerar, deshacer);
escalamiento a humano; estados de error/sin resultado.

**6. Accesibilidad.** Live regions para respuestas, navegable por teclado,
foco gestionado, alternativa no conversacional para tareas críticas.

**7. Validación.** Tasa de resolución sin escalamiento, confianza calibrada
(no sobre-confianza), CSAT, contención de soporte.

**8. Entregables.** Flujos conversacionales, manejo de errores, copy de la
personalidad, criterios A11y. **Éxito:** % consultas resueltas, CSAT ≥ meta,
reducción de tickets.

---

## Ejemplo 5 — Spec de movimiento para un menú (motion craft + handoff)

**Petición:** "El dropdown aparece raro, hazlo más fluido."

**1. Reformulación.** El problema: la animación arranca del centro y con `ease-in`,
lo que se siente lento y desubicado. Consulta por defecto el paquete de motion
(`apple-design` para fundamentos; `animation-vocabulary` para nombrar).

**2. Diagnóstico de motion.** Anima desde `scale(0)` en el centro (origen físico
incorrecto); `ease-in` retrasa el momento que el usuario mira; sin variante
reduced-motion.

**3. Spec de movimiento (para el handoff §2.1 → `farola`/`palma`).**
- Término (`animation-vocabulary`): **Pop in** con **origin-aware** (crece desde
  el trigger).
- Origen: `transform-origin` en la esquina del botón que lo abre, no el centro.
- Propiedades: `opacity` 0→1 + `transform: scale(0.96→1)` (nunca desde `scale(0)`).
- Duración/easing: ~180 ms, `ease-out` (o cubic-bezier fuerte); salida ~120 ms.
- Interrumpibilidad: retargetable si se reabre/cierra rápido.
- reduced-motion: sin escala/movimiento, solo fade de opacidad.
- Motion justificado: comunica de dónde nace el menú (continuidad espacial).

**Frontera.** uxuifull **especifica**; `farola`/`palma` implementan; el frame-rate/
jank lo mide `peakformance`; la correctitud del código, `certero`.

## Ejemplo 6 — Veto de patrón engañoso (diseño honesto)

**Petición:** "Para bajar cancelaciones, escondamos el botón de cancelar y pongamos
'¿Seguro que quieres perder todos tus beneficios?' antes de dejarlos ir."

**1. Reformulación + veto ético.** Lo pedido combina **obstruction** (roach motel)
y **confirmshaming** — patrones engañosos (ver
[etica-y-patrones-enganosos.md](etica-y-patrones-enganosos.md)). uxuifull **lo
rechaza y explica**, aunque baje cancelaciones a corto plazo: falla el test de
asimetría y expone a riesgo regulatorio (FTC "click to cancel", DSA).

**2. Alternativa honesta.** Cancelar tan fácil como suscribir (paridad de
esfuerzo); lenguaje neutral ("Cancelar suscripción" / "Conservar"); ofrecer valor
real como opción (pausa, plan menor) **sin** ocultar la salida ni culpar.

**3. Reencuadre del objetivo (insumo para `tompo`).** La meta legítima —reducir
churn— se ataca con valor y con research de *por qué* se van, no con fricción de
salida. Deriva la conformidad legal a `sello`.

**4. Validación.** Mide retención **voluntaria** y CSAT/NPS post-cancelación
(no "cancelaciones evitadas por fricción"), que es una métrica envenenada.

> Patrón común: siempre reformular el síntoma hacia el problema real, diagnosticar
> por dimensiones, dar estructura antes que estética, incluir accesibilidad, pasar
> el filtro de diseño honesto, y cerrar con validación medible.
