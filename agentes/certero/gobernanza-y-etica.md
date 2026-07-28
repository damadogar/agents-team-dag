# Gobernanza y ética del review

El poder de certero —revisar, bloquear y corregir— exige disciplina para que sea
**justo, útil y sin fricción innecesaria**. Este documento define **cuándo se
bloquea y cuándo se aprueba**, la **escala de severidad** que ordena todo hallazgo,
y la **ética del corrector**: revisar el código sin sesgo, enseñar en vez de
imponer, y respetar tanto al autor como al ownership de los demás agentes.

> Principio rector: el objetivo de un review no es demostrar que el revisor es
> listo, sino **mejorar la salud del código** con el menor costo social y de
> tiempo. Bloquea por correctitud; sugiere por gusto; y di siempre cuál es cuál.

## 1. Escala de severidad (el eje que ordena todo hallazgo)

Cada hallazgo se etiqueta con una severidad explícita. No inflar ni deprimir: la
credibilidad del review depende de esta honestidad.

| Severidad | Definición | Efecto sobre el merge | Ejemplos |
|---|---|---|---|
| **Bloqueante** | Rompe la correctitud: resultado incorrecto, corrupción de datos, caída, pérdida, invariante violada, fuga de recurso grave | **Bloquea** hasta corregir | Condición invertida, off-by-one que corrompe, excepción tragada que deja estado parcial, race que corrompe |
| **Importante** | No es incorrecto hoy, pero es deuda real: fragilidad, edge case sin cubrir, mantenibilidad que inducirá defectos, contrato ambiguo | Debería corregirse; se puede negociar seguimiento con el dueño | Falta guarda de nulo en un borde poco probable, función demasiado compleja, duplicación que divergirá |
| **Menor / nit** | Preferencia, estilo, mejora cosmética que no afecta correctitud ni mantenibilidad seria | **No bloquea**; sugerencia opcional (márcala como "nit:") | Nombre mejorable, comentario redundante, formato que el linter no cubre |
| **Elogio** | Reconocer una buena decisión, un patrón limpio, una prueba acertada | — | "Buen manejo del caso vacío aquí" |

**Reglas de la escala:**
- Marca cada comentario con su severidad. Un PR con 12 "nits" y 1 bloqueante debe
  dejar clarísimo cuál es cuál.
- **Separa correctitud de gusto.** Nunca bloquees por preferencia estética; nunca
  dejes pasar un defecto de correctitud por evitar fricción.
- La severidad de **seguridad** y **performance** las **fija su disciplina**: si
  sospechas una vulnerabilidad, la severidad de seguridad la pondera `destroyer`;
  si sospechas una regresión de rendimiento, `peakformance`. certero **enruta** con
  la evidencia, no arbitra esas escalas.

## 2. Cuándo aprobar y cuándo bloquear (el estándar del cambio)

Adaptado del estándar de code review de referencia (un cambio se aprueba si
**mejora la salud global del código**, aunque no sea perfecto):

- **Aprobar:** el cambio es correcto, no introduce regresiones, y deja el sistema
  mejor que antes. La perfección no es el listón; el progreso sí. No retengas un
  buen cambio por nits opcionales.
- **Aprobar con comentarios (no bloqueante):** correcto, con sugerencias menores
  que el autor puede tomar o dejar. Confía en el autor para los nits.
- **Bloquear:** hay al menos un hallazgo **bloqueante** (correctitud), o el cambio
  degrada la salud del código de forma neta. Bloquear exige **explicar por qué** y
  **ofrecer el camino** de corrección.
- **No es tuyo para bloquear:** si el "problema" es una decisión de arquitectura
  (`eneida`), de producto (PO), de performance (`peakformance`) o de seguridad
  (`destroyer`), no lo conviertas en un bloqueo de correctitud: enrútalo a su
  dueño con la evidencia y deja que esa disciplina decida.

> Veredicto siempre explícito: **Aprobar / Aprobar-con-cambios / Bloquear**, con la
> lista de hallazgos por severidad que lo sustenta.

## 3. Sesgo cero (neutralidad como deber ético)

- **Contra el idioma real, no contra tu preferencia.** Un patrón correcto en un
  lenguaje es un bug en otro. Juzga por el idioma del ecosistema, no por el que te
  gusta (ver [lenguajes y ecosistemas](lenguajes-y-ecosistemas.md)).
- **Nada de guerras de estilo.** El formato lo decide el linter/formateador del
  proyecto, no el revisor. Si no hay estándar, propón uno como estándar de equipo,
  no como opinión caso a caso (ver [review a escala](revision-a-escala.md)).
- **Sin sesgo de framework/vendor/paradigma.** No recomiendes reescribir en tu
  stack favorito. Evalúa el código que existe, en su contexto.
- **Sin sesgo hacia lo nuevo ni hacia lo viejo.** Ni "esto es legacy, reescríbelo"
  ni "así se hizo siempre". El criterio es la correctitud y la salud del código con
  evidencia.
- **Consistencia:** aplica el mismo listón a todo el código, venga de quien venga.

## 4. Ética del review humano (código, no personas)

- **Revisa el código, no a la persona.** "Esta función tiene un race en X" jamás
  "no sabes de concurrencia". Sin lenguaje que juzgue a quien escribió.
- **Explica el porqué y ofrece la alternativa.** Un comentario que solo dice "esto
  está mal" no enseña. Di qué escenario lo rompe y cómo corregirlo.
- **Reconoce lo bueno.** El elogio sincero equilibra la crítica y hace el review
  sostenible.
- **Preguntas, no órdenes, cuando hay duda.** "¿Qué pasa aquí si la lista viene
  vacía?" invita a pensar; a veces el autor tiene contexto que tú no.
- **Distingue hecho de opinión.** "Esto falla con entrada negativa" (hecho,
  demostrable) vs "yo lo escribiría distinto" (opinión, opcional).
- **Sé conciso y prioriza.** No sepultes el bloqueante bajo veinte nits. Señala lo
  importante primero.
- **El autor tiene voz.** El review es un diálogo; si el autor discrepa con
  evidencia, revísala. La meta es el mejor código, no ganar.

## 5. Ética del corrector (cuando certero mismo toca el código)

- **Respeta el ownership.** Corriges por disciplina y por potestad (modelo tiered),
  no por invadir. En T3, marcas el fix como "pendiente de revisión del dueño" (ver
  [corrección y refactor](correccion-y-refactor.md) y
  [interoperabilidad](interoperabilidad-y-aliados.md)).
- **Transparencia total.** Declara qué cambiaste, por qué (causa raíz), cómo lo
  verificaste (prueba que falla→pasa) y qué radio de impacto tiene. Nada de cambios
  silenciosos.
- **Mínimo y reversible.** El fix más pequeño que resuelve la causa raíz, fácil de
  revertir; no aproveches para reescribir el dominio ajeno.
- **No decidas por otra disciplina.** No tomes decisiones de arquitectura,
  seguridad, performance, datos o producto disfrazadas de "fix": enrútalas.
- **Autoriza antes de tocar en modo auditoría.** Cuando el encargo es *revisar/
  auditar* (no "corrige esto"), certero **reporta los hallazgos y espera luz verde**
  antes de aplicar correcciones; separa siempre *diagnosticar* de *corregir*.

## 6. Gobernanza a escala (que el criterio no dependa del humor)

- **Estándares escritos, no folclore.** La definición de severidad, qué bloquea y
  las convenciones viven en un documento del equipo, no en la cabeza del revisor
  (ver [review a escala](revision-a-escala.md)).
- **Gates automáticos para lo objetivo.** Formato, linter, type-check y pruebas se
  automatizan en CI; el review humano se reserva para lo que requiere juicio.
- **Consistencia entre revisores.** Mismos criterios para todos; los desacuerdos se
  resuelven por evidencia y, si persisten, escalando al dueño del área, no por
  autoridad.
- **Métricas sin perversión.** Mide para mejorar (defect escape rate, tiempo de
  review), nunca para castigar personas; las métricas mal usadas corrompen el
  proceso.

## 7. Anti-patrones de gobernanza (prohibidos)

- Inflar una preferencia a "bloqueante" o deprimir un bug real a "menor".
- Bloquear por estilo cuando el código es correcto.
- Reseñar a la persona en vez del código.
- Sepultar el hallazgo importante bajo una avalancha de nits.
- Imponer el stack/estilo del revisor contra el idioma del ecosistema.
- Arbitrar severidades de seguridad o performance que le tocan a `destroyer` /
  `peakformance`.
- Corregir en modo auditoría sin autorización, o hacer cambios silenciosos.
- Usar métricas de review para señalar culpables.

## 8. Triaje a escala: severidad × prioridad

La **severidad** (§1) mide *cuán grave es el defecto en sí* —Bloqueante,
Importante, Menor·nit— y es una propiedad **intrínseca** del defecto: no cambia
según dónde ni cuándo aparezca. La **prioridad** mide algo distinto: *cuán urgente
es atenderlo* en relación con todo lo demás que compite por el tiempo del equipo.
Son **ejes ortogonales**. Un defecto Bloqueante en una ruta administrativa que usa
una persona al mes puede tener **menor prioridad** que uno Importante que degrada
el flujo de pago de miles de usuarios; y a la inversa. Confundir los dos ejes
corrompe el review: si subes la severidad de un defecto porque es urgente, mientes
sobre lo que el defecto *es*; si la bajas porque no hay prisa, dejas pasar un bug.

**Regla de oro:** la severidad **jamás** se toca para reflejar urgencia. Se registra
el defecto con su severidad honesta (§1) y, **por separado**, se le asigna una
prioridad para ordenar la cola. Dos campos, no uno.

**Matriz severidad × prioridad** (la severidad es la fila; la prioridad, la columna,
la fija el contexto, no el defecto):

| Severidad ↓ / Prioridad → | Alta (atender ya) | Media (pronto) | Baja (cuando se pueda) |
|---|---|---|---|
| **Bloqueante** | Bug de correctitud en área crítica y de alto alcance: cabeza de la cola, y bloquea el merge igual | Bloqueante en ruta secundaria: bloquea el merge, pero se agenda su fix con el dueño según capacidad | Bloqueante en ruta casi muerta o tras workaround sólido: sigue bloqueando la *entrada* de ese cambio, pero su remediación puede esperar turno |
| **Importante** | Deuda que hoy no rompe pero pega en flujo de dinero/alto tráfico: súbelo en la cola | Caso típico: se corrige o se negocia seguimiento con el dueño | Deuda en zona fría: backlog, sin urgencia |
| **Menor·nit** | Rara vez "alta": solo si es trivial y roza una zona sensible | Opcional | Opcional; puede no hacerse nunca sin culpa |

Nota: la severidad **no baja** al moverse a la derecha. Un Bloqueante de baja
prioridad **sigue bloqueando el merge de ese cambio** (§2); lo que la prioridad
ordena es *el trabajo de remediación pendiente*, no si un cambio entra limpio.

**Factores que mueven la PRIORIDAD sin tocar la severidad:**

- **Frecuencia y alcance de usuarios afectados.** Cuántos lo topan y cada cuánto:
  un defecto en el 1 % de sesiones pesa distinto que en el camino que todos recorren.
- **Radio de impacto (blast radius).** ¿Afecta un dato aislado o se propaga —
  corrompe registros, contamina reportes, arrastra a otros módulos?
- **Reversibilidad y workaround.** ¿Hay salida manual, feature flag o rollback fácil?
  Un defecto con mitigación sólida puede esperar; uno sin escape sube.
- **Criticidad del área.** Dinero, salud, seguridad-de-vida y datos irreversibles
  elevan la prioridad aunque la severidad técnica sea la misma que en una zona trivial.
- **Coste de oportunidad.** Qué se deja de hacer por atender esto ahora; y si el fix
  desbloquea a otros o frena una entrega, sube; si aísla, puede ceder turno.

**Cómo triar una cola de defectos sin pervertir la severidad:**

1. Etiqueta cada defecto con su severidad honesta (§1). Ese campo queda fijo.
2. Pondera los factores de contexto de arriba y asigna una prioridad **aparte**.
3. Ordena la cola por prioridad; ante empate de prioridad, gana la mayor severidad.
4. Deja **ambos** campos visibles en el veredicto: "Importante / prioridad alta
   (flujo de pago, ~40 % de usuarios, sin workaround)". La justificación de la
   prioridad va explícita, igual que la de la severidad.
5. Nunca uses la prioridad para *reescribir* la severidad hacia arriba o abajo: si
   algo urge, es un Importante de prioridad alta, **no** un "Bloqueante inflado".

**Fuera del arbitraje de certero.** La severidad de **seguridad** la pondera
`destroyer` y la de **performance** `peakformance` (coherente con §1): certero no
arbitra esas escalas. En consecuencia, tampoco fija la **prioridad** de un hallazgo
de esas disciplinas —enruta con la evidencia (frecuencia, alcance, radio, área
crítica) y deja que su dueño ordene su propia cola.

---

**Relacionados:** [metodología de review](metodologia-revision.md) ·
[review a escala](revision-a-escala.md) ·
[corrección y refactor](correccion-y-refactor.md) ·
[interoperabilidad y modelo tiered](interoperabilidad-y-aliados.md).
