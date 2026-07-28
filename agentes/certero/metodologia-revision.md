# Metodología de code review

El code review es la disciplina cross-cutting central de `certero`. No es un trámite de aprobación ni un filtro de estilo: es el mecanismo humano-técnico por el cual un cambio entra al sistema **mejorando la salud global del código**, no solo resolviendo un ticket. Este documento define qué es un review excelente, qué buscar y en qué orden, cómo leer un diff, cuándo bloquear y cuándo sugerir, y cómo comentar de forma que enseñe. Es neutral: aplica a cualquier lenguaje, framework, dominio o industria, en greenfield y brownfield.

## El estándar: ¿mejora este cambio la salud del código?

La pregunta rectora de todo review es una sola:

> **¿El CL/PR, tomado en conjunto, mejora la salud general del código base del sistema — aunque no sea perfecto?**

De aquí se derivan tres principios operativos:

1. **No existe el cambio perfecto; existe el cambio que mejora.** Si un PR mejora de forma neta la salud del código, no debe bloquearse porque no sea idealmente completo. Lo perfecto retrasa lo bueno y desmotiva.
2. **La mejora, no la preferencia personal, es el criterio.** Un revisor puede pedir un cambio solo si hay una razón fundamentada (correctitud, robustez, mantenibilidad demostrable), no porque "yo lo habría escrito distinto". Ver `gobernanza-y-etica.md` para la frontera entre hecho, principio y opinión.
3. **La salud del código es de largo plazo.** Un PR que resuelve el problema de hoy pero degrada la base (acopla, oculta un bug latente, rompe una invariante) no mejora la salud aunque "funcione".

`certero` no es un portero que colecciona rechazos: es un socio que hace entrar el cambio bien. La métrica de éxito no es cuántos defectos se rechazan, sino cuánta correctitud entra sostenidamente.

## Jerarquía de qué buscar (de mayor a menor prioridad)

El review recorre dimensiones en un orden deliberado. Un defecto de una capa superior domina a cualquier observación de una capa inferior: **no se pule el naming de una función que devuelve un resultado incorrecto**.

| # | Dimensión | Pregunta clave | Severidad típica |
|---|-----------|----------------|------------------|
| 1 | **Correctitud** | ¿Hace lo que dice? ¿La lógica es correcta para todos los caminos? ¿Preserva las invariantes? | Bloqueante |
| 2 | **Robustez / edge cases** | ¿Vacío, nulo, cero, negativo, límite, overflow, unicode, concurrencia, orden de eventos, entradas maliciosas? | Bloqueante / Importante |
| 3 | **Manejo de errores** | ¿Se detectan, propagan y traducen fallos? ¿Hay swallow silencioso? ¿Estado consistente ante fallo parcial? | Importante |
| 4 | **Tests que acompañan** | ¿Viene con evidencia de correctitud del cambio (falla→pasa)? ¿Cubren el camino nuevo y sus bordes? | Importante |
| 5 | **Mantenibilidad / legibilidad** | ¿Se entiende sin el autor al lado? ¿Un futuro lector lo modificará sin miedo? | Importante |
| 6 | **Complejidad** | ¿Es más complejo de lo necesario? ¿Sobre-ingeniería, abstracción prematura, generalidad no usada (YAGNI)? | Importante |
| 7 | **Naming / comentarios** | ¿Los nombres revelan intención? ¿Los comentarios explican el *por qué*, no el *qué*? | Menor / nit |
| 8 | **Consistencia con el idioma del ecosistema** | ¿Sigue las convenciones idiomáticas del lenguaje/framework y del código circundante? | Menor / nit |

Reglas de la jerarquía:

- **Se revisa de arriba hacia abajo, se comenta con esa prioridad.** Encabeza los hallazgos de correctitud; marca lo cosmético como opcional.
- **La correctitud es innegociable y es el dominio propio de `certero`.** Cuando la causa raíz cae en otra disciplina —rendimiento (`peakformance`), vulnerabilidad de seguridad (`destroyer`), diseño arquitectónico (`eneida`), esquema o consultas de datos (`andulfo`)— `certero` la **evidencia y la entrega** al dueño, no la absorbe ni la corrige por su cuenta. Ver `interoperabilidad-y-aliados.md`.
- Taxonomía detallada de defectos por capa en `taxonomia-defectos.md`; escala de severidad formal en `gobernanza-y-etica.md`.

## Cómo revisar un diff/PR (no línea a línea)

Revisar línea por línea de arriba a abajo es la forma más común de dejar pasar bugs: se ve la sintaxis y se pierde el comportamiento. `certero` revisa **por objetivo, en pasadas**, siguiendo el flujo de datos.

### Pasada 0 — Contexto e intención (antes de leer una sola línea)

- Lee el título, la descripción, el ticket vinculado y la conversación. **¿Qué problema resuelve y por qué así?**
- Identifica el *contrato*: qué promete el cambio y a quién afecta (llamadores, consumidores del API, datos persistidos).
- Si la intención no se entiende, ese es ya el primer hallazgo: un cambio cuyo *por qué* no es explicable no es revisable.

### Pasada 1 — Forma global

- Mira el PR completo primero. ¿El tamaño es razonable? ¿Hace una sola cosa? Un PR que mezcla refactor + feature + fix es difícil de revisar bien y esconde bugs entre el ruido.
- Verifica que el conjunto de archivos tocados sea coherente con la intención. Archivos inesperados = señal de alcance no declarado.

### Pasada 2 — Seguir el flujo de datos

- Traza el dato desde su **entrada** (parámetro, request, mensaje, fila) hasta su **salida** (respuesta, escritura, efecto). En cada frontera pregunta: ¿validado? ¿transformado bien? ¿qué pasa si aquí falla?
- Revisa **por capas**, no por líneas: frontera de entrada → validación → lógica de dominio → efectos/persistencia → frontera de salida. En cada capa aplica la jerarquía completa.
- Construye mentalmente (o en papel) casos concretos: "si entra `x = 0`…", "si la lista viene vacía…", "si dos hilos llaman esto…". Técnica de causa raíz y trazado en `debugging-causa-raiz.md`.

### Pasada 3 — Tests y evidencia de correctitud

- ¿El cambio trae pruebas que demuestren que el comportamiento nuevo es correcto y que el viejo no se rompió?
- **Frontera clara:** la *estrategia*, la *suite*, la *cobertura* y el diseño de casos son ownership de `amado`. `certero` juzga únicamente si **este cambio viene acompañado de evidencia de correctitud** y, cuando corrige un defecto, escribe **el test puntual que prueba su fix** (rojo antes → verde después). No diseña la estrategia de pruebas del sistema. Ver `pruebas-de-regresion.md`.

### Pasada 4 — Nits y consistencia

- Solo al final: naming, comentarios, estilo idiomático, consistencia con el entorno. Todo aquí es de baja severidad y explícitamente opcional salvo que dañe la legibilidad de forma material.

> **Regla del "por qué":** en cada pasada revisa la *intención* del cambio, no solo su *forma*. Un código sintácticamente impecable que resuelve el problema equivocado es un defecto de máxima severidad; un código torpe que resuelve el problema correcto es, a lo sumo, deuda menor.

## Altitud y profundidad del review

No todo hallazgo pesa igual. Alinear la reacción del revisor con la severidad real evita dos fallas simétricas: bloquear por nimiedades y aprobar defectos reales.

| Nivel | Qué es | Acción | Ejemplo |
|-------|--------|--------|---------|
| **Bloqueante** | Correctitud, robustez ante bordes reales, corrupción de estado, pérdida de datos, contrato roto | Debe cambiarse antes de fusionar | "Este índice va fuera de rango cuando la colección está vacía." |
| **Importante (no bloqueante)** | Mantenibilidad seria, manejo de error frágil, complejidad evitable | Fuerte recomendación; se negocia | "Este `catch` traga la excepción; conviene al menos registrarla o propagarla." |
| **Nit / opcional** | Estilo, naming, comentario, preferencia idiomática | Prefijar como `nit:`; el autor decide | "nit: `n` podría llamarse `reintentosRestantes`." |
| **Pregunta / FYI** | Duda genuina o dato útil sin exigir cambio | No bloquea | "¿Confirmas que este caso nunca recibe nulos por diseño?" |

- **Marca la severidad explícitamente en cada comentario.** El autor no puede leer tu mente: un `nit:` mal calibrado leído como bloqueo destruye velocidad y confianza.
- La escala de severidad completa, con criterios de desempate y política de "resolver conversaciones", vive en `gobernanza-y-etica.md`. Checklists por dimensión para no olvidar categorías: `checklists.md`.

## Review humano y respetuoso

El review es una interacción entre personas. El objetivo doble es **mejorar el código** *y* **construir un equipo que quiera seguir mejorando**. Un review técnicamente correcto pero hostil daña la salud del sistema a mediano plazo tanto como un bug.

- **Comenta el código, nunca a la persona.** "Esta función no maneja el caso vacío", no "no pensaste en el caso vacío".
- **Enseña el porqué.** Un comentario que solo ordena ("cámbialo") tiene menos valor que uno que explica ("esto revienta con lista vacía porque el índice 0 no existe; considera guardar temprano"). Enlaza a la fuente cuando aporte (guía de estilo, doc del lenguaje).
- **Reconoce lo bueno.** Señalar una solución elegante o un test bien pensado no es adorno: calibra al autor sobre qué mantener y hace el canal de feedback bidireccional y creíble.
- **Ofrece dirección, no dictado, en lo opcional.** Para nits, sugiere; deja la decisión al autor. Reserva el imperativo para lo bloqueante.
- **Haz preguntas cuando no entiendas** en lugar de asumir un error. Muchas veces el "bug" que crees ver es un contexto que te falta.

### Comentarios buenos vs. malos

| Malo | Bueno | Por qué |
|------|-------|---------|
| "Esto está mal." | "Si `items` llega vacío, `items[0]` lanza fuera de rango. ¿Un guard temprano que retorne el neutral?" | Concreto, señala el caso, propone salida |
| "¿Por qué no usaste un mapa?" | "nit: un índice por clave evitaría el recorrido O(n) en cada llamada; opcional si el N es siempre pequeño." | Marca severidad, da la razón, acota |
| "Feo." | "Esta condición anidada de 4 niveles es difícil de seguir; extraer la validación a una función con nombre ayudaría al próximo lector." | Ataca el código, explica el costo |
| "Faltan tests." | "Este cambio corrige el borde de fecha límite pero no veo un test que lo fije; ¿agregamos uno que falle sin el fix?" | Liga el test a la correctitud del cambio |
| "LGTM 👍" (en un PR con lógica no trivial) | "Revisé el flujo de `parseInvoice`; correcto para montos negativos y cero. Una duda en el manejo de moneda nula (ver abajo)." | Evidencia que hubo review real |

## Velocidad vs. profundidad

- **Los reviews deben ser rápidos en el reloj y profundos en el contenido.** La latencia de review bloquea a todo el equipo; responde pronto aunque sea para acordar un primer lote de comentarios.
- **La profundidad se compra con diffs pequeños.** El insumo número uno de un review profundo es un PR chico y enfocado. Si un PR es demasiado grande para revisarse bien, el hallazgo legítimo es: "divídelo". Técnicas para revisar cambios grandes y a escala en `revision-a-escala.md`.
- **Ante duda de correctitud, la profundidad gana.** La velocidad nunca justifica aprobar lógica que no se entendió. Si no puedes verificar un camino, dilo explícitamente en vez de aprobar por inercia.
- **Prioriza por riesgo.** Concentra el tiempo en el código que puede causar más daño (efectos irreversibles, datos, concurrencia, dinero, seguridad) y sé más ligero en lo cosmético.

## Qué NO hacer en un review

- **No hagas gate-keeping por gusto personal.** Sin una razón de correctitud o mantenibilidad, la preferencia no bloquea.
- **No pidas perfección.** No conviertas un PR de mejora neta en un rediseño; los sub-problemas que descubras y no bloquean van a follow-ups, no a este PR.
- **No apruebes sin entender.** "LGTM" sobre lógica que no leíste es una firma en falso; si aprobaste, eres corresponsable del defecto.
- **No absorbas dominios ajenos.** No reescribas por performance (`peakformance`), no parchees vulnerabilidades tú mismo (`destroyer`), no rediseñes la arquitectura (`eneida`) ni el modelo de datos (`andulfo`): **evidencia, delega, y verifica el fix del dueño.**
- **No amontones defectos en un solo comentario ilegible** ni entierres el hallazgo bloqueante entre diez nits.
- **No hagas review de estilo lo que debería hacer un linter.** El formato mecánico se automatiza; ver `analisis-estatico-dinamico.md`. El humano se reserva para el juicio que la máquina no tiene.
- **No conviertas el review en una discusión de ego.** Si hay desacuerdo, escala al criterio, a los datos o a la guía del proyecto, no a quién manda.

## Pseudocódigo neutral del flujo de review

```text
funcion revisar(pr):
    contexto  = leer_intencion(pr.titulo, pr.descripcion, pr.ticket, pr.discusion)
    si contexto es ambiguo:
        comentar(bloqueante, "No se entiende el porqué del cambio; explícalo")
        retornar

    si pr.tamano es demasiado_grande o pr.hace_muchas_cosas:
        comentar(importante, "Divide este PR para poder revisarlo bien")

    para cada capa en [entrada, validacion, dominio, efectos, salida]:
        para cada camino en caminos_de_datos(capa):
            verificar(correctitud, camino)          # dominio propio de certero
            verificar(robustez, bordes(camino))     # vacío, límite, concurrencia…
            verificar(manejo_de_error, camino)
            si causa_raiz(hallazgo) pertenece a otro_dominio:
                evidenciar_y_delegar(hallazgo, dueño)   # NO corregir aquí

    si no pr.trae_evidencia_de_correctitud():
        comentar(importante, "Acompaña el cambio con un test que lo fije")

    revisar(mantenibilidad, complejidad)             # medio
    revisar(naming, comentarios, consistencia)       # nit / opcional

    para cada comentario:
        etiquetar_severidad(comentario)              # bloqueante | importante | nit | pregunta
        explicar_porque(comentario)
    reconocer_lo_bueno(pr)

    si salud_global_mejora(pr) y sin_bloqueantes_abiertos:
        aprobar()
    sino:
        solicitar_cambios(solo_lo_fundamentado)
```

## Revisión de código generado por IA

Hoy una fracción alta de los diffs que llegan a review viene asistida por IA (autocompletado, agentes, generación de bloques completos). Esto no cambia la pregunta rectora —¿mejora la salud del código?— pero sí introduce una **clase de defecto con firma propia**: código fluido, idiomático y confiado en su forma, que falla en su sustancia. El revisor debe reconocer esa firma y ajustar la pasada en consecuencia. La frontera es nítida: **revisar el código —lo escriba una persona o una IA— es dominio de `certero`; evaluar la calidad del modelo que lo generó no lo es** (eso vive en `prisma`/`sysuniversal-ai`). Aquí se revisa el artefacto, no al autor ni a su herramienta.

### Patrones a cazar

- **APIs, funciones o parámetros alucinados.** Nombres que *parecen* existir por analogía con ecosistemas vecinos pero no existen en la versión/biblioteca real, o firmas con un parámetro inventado que "encaja". No basta con que el nombre suene correcto: hay que **verificar la existencia real** contra la documentación o la definición efectiva.
- **Código plausible-pero-incorrecto.** Compila, pasa el ojo rápido y no cumple el contrato: condición de borde invertida, unidad equivocada, off-by-one, semántica del API mal supuesta (p. ej. un método que ordena in-place versus uno que devuelve copia; un flag cuyo default es el opuesto al asumido). Es el defecto más peligroso porque *se ve terminado*.
- **Confianza espuria del autor.** Comentarios afirmativos, mensajes de commit rotundos y ausencia de dudas señaladas no son evidencia de correctitud; a menudo son un artefacto del tono generativo. La seguridad con que algo está escrito no correlaciona con que esté bien.
- **Duplicación silenciosa.** En vez de reutilizar una utilidad, un validador o un tipo ya existente en el repositorio, se regenera una variante local casi equivalente. Divergirá con el tiempo. Pregunta siempre: ¿esto ya existe en el código base?
- **Tests autogenerados tautológicos o que prueban el mock.** Pruebas que reafirman la implementación línea por línea, que asertan sobre el valor que el propio mock devolvió, o que nunca podrían fallar. Dan cobertura nominal y **cero evidencia de correctitud**. (El diseño de la suite es de `amado`; aquí solo se juzga si *este* cambio trae evidencia real de su fix.)
- **Complejidad y dependencias innecesarias.** Abstracciones, capas de configuración, generalidad no pedida o una dependencia externa nueva para algo que el estándar del lenguaje ya resuelve. La generación tiende a "más código", no a menos (choca con YAGNI).
- **Comentarios que describen intención no implementada.** El comentario o docstring promete un manejo (p. ej. "reintenta ante fallo transitorio", "valida el rango") que el cuerpo no ejecuta. El comentario describe lo deseado, no lo escrito.
- **Atribución y licencia.** Fragmentos extensos reproducidos de fuentes con licencia incompatible o sin atribución debida. Es un riesgo real cuando el volumen o la literalidad lo ameritan; márcalo como hallazgo y escálalo por la vía de gobernanza del proyecto.

### Cómo cambia la pasada de review

- **Verifica existencia y semántica real de cada API usada, no el nombre.** Ante cualquier símbolo desconocido o poco frecuente, confírmalo contra la fuente antes de darlo por bueno. Un nombre creíble no es un contrato.
- **Exige el *por qué*.** El "por qué así" (Pasada 0) es aún más innegociable cuando el autor no puede reconstruir el razonamiento línea a línea. Si nadie —persona— es capaz de explicar por qué el cambio es correcto, el cambio no es revisable ni fusionable.
- **Calibra el escepticismo al volumen.** Un bloque grande generado de una vez merece más trazado de flujo de datos y más casos concretos que un cambio pequeño y deliberado. A mayor superficie generada, mayor densidad de verificación.

### Usar IA para asistir el review (y sus límites)

La IA puede **asistir** la revisión: señalar candidatos a defecto, resumir un diff extenso, proponer casos de borde a considerar, detectar duplicación aparente. Es un multiplicador de atención, no un sustituto del juicio. Su límite es asimétrico y decisivo: **sus falsos negativos producen seguridad falsa** —un "no veo problemas" puede leerse como garantía cuando solo es ausencia de señal—. Por eso el veredicto, la calibración de severidad y el **ownership humano de la correctitud no se delegan**: una herramienta puede enriquecer el review, pero quien aprueba firma y es corresponsable del defecto (ver "No apruebes sin entender"). Trata la salida de la IA revisora como una entrada más a verificar, con el mismo escepticismo que aplicas al código que revisa.

### Higiene de commits y bisectabilidad

La revisión también vela por la **forma del historial**, porque de ella depende poder diagnosticar el futuro. Un cambio bien fragmentado es una propiedad de review, no un lujo estético:

- **Commits atómicos:** cada commit hace una sola cosa coherente y se explica por sí solo. Mezclar refactor + feature + fix en un commit esconde defectos y arruina la trazabilidad.
- **Construibles y testeables uno a uno:** todo commit del historial debe compilar y pasar sus pruebas por separado, no solo la punta de la rama. Un commit intermedio roto envenena cualquier búsqueda posterior.
- **Bisectabilidad:** esas dos propiedades juntas habilitan la bisección —recorrer el historial por mitades para aislar el commit que introdujo un fallo—. Un historial atómico y siempre-verde convierte la búsqueda de la causa raíz de "leer todo" en "unos pocos pasos". Cuando el defecto ya está en producción, esta higiene es la diferencia entre horas y minutos; ver `debugging-causa-raiz.md`.

Como hallazgo de review, un historial no atómico o con commits que no construyen es **importante** (afecta mantenibilidad y capacidad de diagnóstico), y la salida natural suele ser pedir que se reordene o divida antes de fusionar.

---

**Ver también:** `taxonomia-defectos.md` (qué defectos buscar por capa), `gobernanza-y-etica.md` (escala de severidad y frontera hecho/opinión), `checklists.md` (listas por dimensión para no olvidar categorías).
