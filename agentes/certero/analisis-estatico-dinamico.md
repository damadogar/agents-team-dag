# Análisis estático y dinámico como amplificadores del review

Las herramientas no reemplazan el juicio de `certero`: lo **amplifican**. El análisis estático razona sobre el código sin ejecutarlo; el dinámico observa el comportamiento real bajo estímulo. Ambos convierten defectos latentes en señales visibles y accionables, pero ninguno decide por sí solo si algo es un defecto de **correctitud** — esa lectura es del revisor. Este documento cubre cómo usar estas técnicas para atrapar más defectos con menos ruido, cómo integrarlas como puertas de CI sin erosionar la confianza, y dónde termina la frontera de `certero`.

> Fronteras explícitas: el análisis estático de **seguridad** (SAST, taint de vulnerabilidades explotables, detección de sinks peligrosos) se **nombra** aquí porque comparte maquinaria con el dataflow de correctitud, pero su **ownership es de `destroyer`**. El **profiling de rendimiento** (flame graphs, hotspots, asignaciones) es de `peakformance`. La **estrategia de la suite de pruebas y la propiedad de la cobertura como proceso** son de `amado`; aquí la cobertura se usa **solo como señal de review**, nunca como meta ni como entregable.

---

## A. Análisis estático — razonar sin ejecutar

### A.1 Linters y formateadores (estilo y anti-patrones)
Primera capa, barata y de alto volumen. Detectan olores locales y anti-patrones conocidos.

- **Formateadores** (p. ej. `prettier`, `gofmt`, `black`, `rustfmt`): eliminan el ruido de estilo del diff para que el review se concentre en la lógica. Regla: **el estilo se automatiza, no se debate en el review**.
- **Linters** (p. ej. `eslint`, `ruff`, `clippy`, `golangci-lint`, `pylint`, `ktlint`): reglas heurísticas que atrapan `==` vs `===`, comparaciones sospechosas, variables sombreadas, `switch` sin `default`, promesas sin `await`, recursos sin cerrar.
- Límite: una regla de lint señala **patrones**, no **intención**. Un `for` con off-by-one pasa el linter sin problema. No confundir "lint limpio" con "correcto".

### A.2 Análisis estático de correctitud (dataflow y más)
El escalón que de verdad ataca defectos de correctitud sin ejecutar:

- **Dataflow / análisis de flujo**: rastrea cómo se propagan valores. Atrapa uso-antes-de-asignar, variables que nunca se leen, y — clave — **valores nulos que fluyen a desreferencias**.
- **Unreachable / dead code**: ramas imposibles suelen ser síntoma de una condición mal escrita, no solo código muerto.
- **Null-checkers y nullability** (p. ej. checkers de `@Nullable`/`@NonNull`, modo estricto de nulabilidad, `Optional`): convierten el NPE de runtime en error de compilación.
- **Contratos y análisis de precondiciones** (p. ej. herramientas tipo contract-checking): verifican que las llamadas respeten lo que la función exige.

> El **mismo dataflow** que rastrea nulos rastrea taint de entradas no confiables hacia sinks peligrosos. Cuando la pregunta es "¿esta entrada de usuario llega a una consulta/comando/render sin sanear?", eso es **análisis de seguridad → `destroyer`**. `certero` lo nombra y colabora, pero no es dueño del veredicto de explotabilidad.

### A.3 Type systems como red de correctitud
El sistema de tipos es el análisis estático más rentable que existe: corre en cada compilación y es sonoro dentro de sus reglas.

| Palanca de tipos | Qué correctitud garantiza |
|---|---|
| Tipado estático vs gradual | El estático rechaza clases enteras de errores en compilación; el gradual (p. ej. anotaciones opcionales) exige rigor en las fronteras para no dejar huecos |
| **Exhaustividad** de uniones/enums | El compilador obliga a manejar **todos** los casos; al agregar una variante, todos los `match`/`switch` incompletos fallan la compilación |
| Nullability en el tipo | `T` distinto de `T?`: el nulo es imposible donde no se declaró |
| Genéricos / parametricidad | Contenedores y funciones seguras por construcción; menos casts inseguros |
| **Tipos que hacen imposibles los estados inválidos** | Modelar el dominio para que un estado ilegal ni siquiera sea representable (p. ej. estados como uniones etiquetadas, newtypes para unidades/IDs, "parse, don't validate") |

Recomendación de review: cuando veas validación defensiva repetida en runtime, pregunta si un **tipo más preciso** eliminaría la necesidad de validar. Empujar la correctitud al tipo es el mejor ROI a largo plazo.

### A.4 Verificación ligera, aserciones y contratos
- **Design by contract**: precondiciones, postcondiciones e invariantes **ejecutables**. Documentan y verifican simultáneamente. Fallan cerca de la causa, no en un síntoma lejano.
- **Aserciones e invariantes** en puntos críticos: convierten supuestos tácitos en fallos ruidosos y tempranos (ver `debugging-causa-raiz.md`).
- **Métodos formales** (guiño, no default): cuando el dominio es crítico (concurrencia sutil, protocolos, consenso, aeroespacial/médico/financiero de núcleo), especificación y model checking (p. ej. TLA+, verificadores de propiedades) valen la inversión. En la inmensa mayoría de casos, tipos + contratos + tests son suficientes.

---

## B. Análisis dinámico — observar el comportamiento real

### B.1 Sanitizers
Instrumentan la ejecución para atrapar comportamiento indefinido y errores de memoria/hilos **en el acto**, con diagnóstico preciso:

| Sanitizer (p. ej.) | Clase de defecto |
|---|---|
| Address / memory error | Buffer overflow, use-after-free, doble free, out-of-bounds |
| Leak | Fugas de memoria/recursos |
| Thread / race | Data races entre hilos (ver `concurrencia-y-estado.md`) |
| Undefined behavior | Overflow de enteros con signo, desalineación, shifts inválidos |
| Memory (uninitialized) | Lecturas de memoria no inicializada |

Aplican sobre todo a lenguajes con gestión manual de memoria, pero el concepto (detectores de condiciones de carrera, checkers de runtime) existe en muchos ecosistemas.

### B.2 Fuzzing
Generar entradas para explorar caminos que ninguna prueba escrita a mano cubriría:

- **Coverage-guided**: el fuzzer muta entradas guiándose por la cobertura que descubre; excelente para parsers, decodificadores, deserializadores, límites de protocolo.
- **Property-based testing**: fuzzing **estructurado** — declaras una propiedad invariante ("codificar y decodificar devuelve el original", "el resultado siempre está ordenado") y el motor busca contraejemplos y los reduce (shrinking).
- **Diferencial**: dos implementaciones que deberían coincidir (p. ej. versión nueva vs referencia) se alimentan con la misma entrada; cualquier divergencia es un defecto candidato.

### B.3 Ejecución con aserciones activadas y análisis dinámico de estado
- Correr la suite y los entornos de prueba con **aserciones/invariantes habilitadas** captura violaciones de supuestos que en producción pasarían silenciosas.
- **Análisis dinámico de estado**: verificar invariantes de estructuras de datos y máquinas de estado en runtime (checkers de consistencia periódicos, invariantes al entrar/salir de secciones críticas).

### B.4 Inyección de fallos (fault injection)
El *happy path* casi siempre se prueba; los **caminos de error** casi nunca. La inyección de fallos los fuerza deliberadamente para verificar que el **manejo de error, la limpieza y la compensación son correctos**:

- Forzar que una dependencia **lance, agote su timeout, devuelva parcial o falle la red/disco** en el punto exacto donde el código asume éxito, y comprobar que el sistema queda en estado consistente (no a medias) — ver el reintento/compensación de la familia "Manejo de errores" en [taxonomia-defectos.md](taxonomia-defectos.md).
- Complementa a las otras técnicas sin-oráculo: **fuzzing** varía la *entrada*, el **testing metamórfico** la *relación entrada↔salida*, y la inyección de fallos el **fallo del entorno**.
- Frontera: la **ingeniería del caos** a escala de sistema (experimentos en producción, blast radius) es de `peakformance`/`eneida`; aquí el eje es la **correctitud del camino de error** en el código.

---

## C. Cobertura como SEÑAL (no como meta)

La cobertura le dice a `certero` **dónde no mirar el review con confianza** y **qué caminos nadie ejerció** — es una lente, no un objetivo.

| Métrica | Qué revela como señal |
|---|---|
| Cobertura de **línea** | Piso mínimo; línea ejecutada no implica aserción sobre su resultado |
| Cobertura de **rama** | Si ambos lados de cada condición se ejercieron; más informativa que línea |
| Cobertura de **camino** | Combinaciones de ramas; costosa, útil en lógica crítica |
| **Mutation testing** | La señal más honesta: introduce defectos artificiales; si las pruebas no fallan, la cobertura era **teatro**. Mide la **calidad**, no la cantidad, de las pruebas |

> Un número alto de cobertura con aserciones débiles es una **falsa sensación de seguridad**. Por eso mutation testing supera a la cobertura cruda como señal de review.

> **Frontera con `amado`**: definir el objetivo de cobertura, la **estrategia** de la suite, qué se prueba y cómo se gobierna la calidad como **proceso** es de `amado`. `certero` **consume** estos números como evidencia puntual durante un review y recomienda pruebas de regresión concretas (ver `pruebas-de-regresion.md`), pero no es dueño de la política.

---

## D. Integrar todo como gates de CI sin erosionar la confianza

Una puerta que dispara falsos positivos se **desactiva mentalmente**: el equipo empieza a aprobar en rojo y la herramienta muere. Reglas de integración (detalle de operación en `revision-a-escala.md`):

1. **Bloqueante solo lo determinista y de alta confianza**: fallos de tipo, tests rojos, sanitizers, lint de reglas de correctitud sin ambigüedad. Lo heurístico o probabilístico → **advertencia**, no bloqueo.
2. **Diff-first**: exigir las reglas nuevas solo sobre el código tocado en el cambio; el legado se migra por olas, no de golpe. Evita "muros rojos" que nadie puede resolver en un PR.
3. **Baseline y supresión auditada**: congelar hallazgos preexistentes como baseline; cada supresión (`# noqa`, `// lint-ignore`, anotación) debe llevar **motivo y, si aplica, referencia**. Supresión sin justificación es deuda oculta.
4. **Determinismo y velocidad**: gates flaky o lentos entrenan a saltárselos. Aislar y arreglar la flakiness es prioridad (ver `pruebas-de-regresion.md`).
5. **Triaje de hallazgos**: clasificar cada salida de herramienta antes de actuar —

| Veredicto | Acción |
|---|---|
| Verdadero positivo | Corregir (o registrar defecto según modelo TIERED — ver `correccion-y-refactor.md`) |
| Falso positivo | Suprimir con justificación **y** afinar/reportar la regla para que no reincida |
| Verdadero negativo silencioso | Riesgo mayor: la herramienta no vio el defecto; refuerza que las puertas no bastan |

---

## E. Límites — ninguna herramienta sustituye el juicio

| Técnica | Qué clase de defecto atrapa | Limitación |
|---|---|---|
| Linter / formateador | Anti-patrones locales, olores de estilo | Ciego a la lógica y a la intención; off-by-one pasa limpio |
| Dataflow / null-checker | Nulos, uso-antes-de-asignar, dead code | Falsos positivos en flujos que no puede probar; imprecisión inter-procedural |
| Type system | Estados inválidos, casos no manejados, nulabilidad | Solo garantiza lo que el tipo **expresa**; lógica dentro de tipos válidos queda libre |
| Contratos / aserciones | Violación de invariantes y precondiciones | Solo verifica lo que alguien pensó en afirmar |
| Métodos formales | Errores de diseño/concurrencia/protocolo | Costo alto; verifica el **modelo**, no necesariamente el código desplegado |
| Sanitizers | Corrupción de memoria, races, UB | Solo en caminos **ejecutados**; overhead de runtime |
| Fuzzing / property-based | Casos límite, entradas inesperadas, crashes | No prueba ausencia de defectos; requiere buen oráculo/propiedad |
| Cobertura | Código **no** ejercido | Ejecutado ≠ verificado; alta cobertura puede ocultar aserciones vacías |
| Mutation testing | Pruebas débiles/vacías | Costoso en cómputo; mutantes equivalentes generan ruido |

Verdades operativas:
- **Falsos positivos** erosionan la confianza; **falsos negativos** dan seguridad falsa. Ambos exigen que el review humano cierre el circuito.
- Las herramientas comprueban **propiedades**, no **corrección respecto a la intención del negocio**. Un programa puede pasar todo y hacer lo incorrecto perfectamente.
- El valor real es **compuesto**: tipos + contratos + sanitizers + fuzzing + cobertura como señal cubren clases de defectos disjuntas. Ninguno solo es suficiente; juntos, y bajo el juicio de `certero`, forman la red más fina posible.

---

## F. Cobertura de decisiones rigurosa para software crítico (MC-DC)

La tabla de C ordena las métricas por poder de discriminación, pero se detiene antes del escalón que exige el software donde un fallo cuesta vidas. Para esos dominios, la pregunta no es "¿se ejecutó esta rama?" sino "¿**demostramos** que cada condición dentro de la decisión importa?".

### F.1 Qué mide cada nivel — y qué se le escapa

| Criterio | Qué exige | Qué atrapa | Qué se le escapa | Costo |
|---|---|---|---|---|
| **Sentencia** | Cada línea ejecutada al menos una vez | Código muerto grosero, líneas nunca tocadas | Toda la lógica de bifurcación: una rama con `if` puede quedar sin probar su lado falso | Bajo |
| **Rama / decisión** | Cada decisión toma ambos valores (verdadero **y** falso) al menos una vez | Ramas no ejercidas, `else` implícitos olvidados | Cómo las condiciones **internas** de una decisión compuesta contribuyen al resultado | Bajo–medio |
| **Condición** | Cada condición atómica toma ambos valores | Condiciones individuales congeladas | Que la decisión completa tome ambos valores (puede cumplirse condición sin cubrir rama) | Medio |
| **MC-DC** | Cada condición demuestra **independientemente** que afecta el resultado de la decisión, manteniendo las demás fijas | Condiciones inertes, operadores booleanos equivocados (`&&` vs `\|\|`), términos que nunca cambian el veredicto | Errores que solo emergen con combinaciones específicas fuera del conjunto mínimo | Alto pero **lineal** (≈ N+1 casos para N condiciones) |
| **Camino** | Toda combinación de ramas del flujo | Interacciones entre decisiones a lo largo del flujo | En la práctica, nada teórico — pero es **inviable**: crece exponencialmente (2^N) y explota con los bucles | Prohibitivo |

MC-DC es el punto óptimo entre rigor y viabilidad: obtiene casi el poder discriminante del camino a costo **lineal**, no exponencial. Por eso **DO-178C** lo exige para el software de **nivel A** en aviónica (aquel cuyo fallo es catastrófico); normas hermanas de otros sectores críticos (p. ej. ferroviario, automoción, dispositivos médicos, nuclear) adoptan criterios equivalentes según el nivel de integridad.

### F.2 Qué significa "independientemente" y cómo se lee en review

La clave de MC-DC es la **independencia de cada condición**: para cada condición de la decisión debe existir un **par de casos** que difieran **solo** en esa condición y que produzcan **resultados distintos** de la decisión. Ese par prueba que la condición, por sí sola, mueve la aguja — no está enmascarada por un cortocircuito ni es decorativa.

Ejemplo de lectura. Para `if (A && (B || C))`:
- El par para `A` mantiene `(B || C)` verdadero y varía solo `A`; la decisión debe pasar de verdadera a falsa.
- El par para `B` fija `A` verdadero y `C` falso (para que `B` no quede enmascarado por el cortocircuito de `||`), y varía solo `B`.
- El par para `C` fija `A` verdadero y `B` falso, y varía solo `C`.

En review, `certero` no cuenta casos: **lee la forma booleana**. Señales de alarma que MC-DC formaliza y que un revisor detecta a ojo:
- Una condición cuyo valor **nunca cambia el veredicto** en ningún caso probado → probablemente sobra, o el operador lógico está mal (p. ej. un `||` que debía ser `&&`).
- **Enmascaramiento por cortocircuito**: un término a la derecha de `&&`/`||` que nunca se evalúa con el otro operando en el valor que lo deja "hablar" — queda sin ejercer aunque la cobertura de rama diga verde.
- Condiciones compuestas densas (muchos `&&`/`||` anidados) son, a la vez, las más propensas a error lógico y las más caras de cubrir; MC-DC vuelve visible ese costo y suele ser argumento para **descomponer** la expresión en predicados nombrados y verificables.

> MC-DC presupone condiciones **sin efectos colaterales** y, en su forma estricta, **acoplamiento** entre condiciones controlado (variantes como *unique-cause* frente a *masking* MC-DC difieren en cómo tratan condiciones que se repiten o se influyen). Cuando una condición aparece dos veces o un término tiene efecto lateral, la lectura de independencia se complica: eso, en review, es señal para **simplificar la expresión**, no para tolerarla.

### F.3 Sigue siendo señal, no meta

Todo lo dicho en C aplica con más fuerza aquí: **100 % de MC-DC no es "correcto"**. Confirma que la estructura de decisiones fue ejercida con independencia demostrada; no confirma que la lógica **sea la que el requisito pedía**, ni que las aserciones sean fuertes (un caso MC-DC con oráculo débil sigue siendo teatro — combínalo con mutation testing de B/C). Y **la propiedad de la suite, del criterio objetivo y de su gobierno como proceso sigue siendo de `amado`**; `certero` **lee** la cobertura de decisiones como evidencia puntual del rigor de un cambio crítico y escribe el caso que cierra su propio fix, nada más.

---

## G. Métodos formales con método

A.4 y la tabla de E mencionan los métodos formales como escalón; esta sección los trata con el método que merecen: **cuándo** valen la inversión, **qué** verifican realmente y **dónde** está su límite duro.

### G.1 Cuándo valen la inversión

Los métodos formales pesados no son gratis: exigen especificar el sistema en un lenguaje matemático y razonar sobre él. Su ROI aparece cuando **el espacio de estados es demasiado grande para probarlo a mano y el costo del fallo es enorme**:

- **Concurrencia y paralelismo críticos**: entrelazados de hilos/procesos que ninguna suite reproduce de forma fiable; interleavings raros que solo un explorador exhaustivo encuentra (complementa `concurrencia-y-estado.md`).
- **Protocolos distribuidos y consenso**: replicación, elección de líder, commit atómico, membership — donde particiones de red y reordenamientos generan escenarios que la intuición no cubre.
- **Invariantes donde el fallo es catastrófico**: pérdida o doble contabilización de **dinero**, riesgo para la **vida**, corrupción irreversible de datos, violaciones de seguridad de núcleo. Cuando una sola violación es inaceptable, verificar el diseño **antes** de construirlo es más barato que descubrirla en producción.

Fuera de esos casos, la recomendación de D se mantiene: **tipos + contratos + property-based + tests** cubren la inmensa mayoría con mucho menor costo.

### G.2 Qué verifican — el modelo, no el binario

Con precisión: los métodos formales verifican una **especificación o modelo** del sistema, no el artefacto que se despliega. Dos familias, según lo que se automatiza:

- **Model checking**: se define un modelo (estados, transiciones, propiedades de seguridad y de vivacidad) y una herramienta **explora exhaustivamente** el espacio de estados buscando una violación; si la halla, devuelve un **contraejemplo** — una traza concreta que rompe el invariante, muchas veces el mayor valor práctico de la técnica. Herramientas de especificación y verificación de diseños concurrentes/distribuidos (p. ej. TLA+, Alloy, P "p. ej.") viven aquí.
- **Prueba de teoremas / verificación deductiva**: se demuestra matemáticamente que el sistema cumple su especificación para **todos** los estados, no solo los explorables acotadamente. Mayor poder, mayor esfuerzo humano.

### G.3 El límite clave: la brecha modelo↔código

El punto que ninguna presentación honesta puede omitir: **un modelo verificado no es un binario verificado**. La prueba garantiza que el **diseño** es correcto; el código desplegado puede divergir del modelo por errores de traducción, supuestos del entorno que el modelo idealizó (relojes, fallos parciales, aritmética de máquina), o cambios que nunca volvieron a la especificación. Cerrar esa brecha es trabajo aparte:

- Mantener la especificación **viva** (versionada junto al código, no un PDF muerto tras el kickoff).
- Derivar de las propiedades del modelo **aserciones e invariantes ejecutables** y **pruebas property-based/metamórficas** que las ejerzan sobre el código real.
- En dominios de máxima criticidad, técnicas que **conectan** modelo y código (generación o verificación de código respecto a la especificación) — pero eso pertenece a la estrategia de aseguramiento, de `amado`, no al veredicto de correctitud puntual de `certero`.

### G.4 Verificación ligera como escalón intermedio

Entre "solo tests" y "model checking completo" hay un escalón de altísimo ROI que acerca el rigor formal sin su costo, y que `certero` **sí** recomienda de rutina en review (enlaza con A.3 y A.4):

- **Design by contract / contratos**: precondiciones, postcondiciones e invariantes ejecutables — una forma local y barata de especificación que falla cerca de la causa.
- **Aserciones ejecutables** en puntos críticos: convierten supuestos tácitos en fallos ruidosos y tempranos.
- **Tipos que hacen imposibles los estados inválidos**: la verificación "formal" más rentable que existe, porque el compilador la comprueba en cada build. Si un estado ilegal **no es representable**, no hay que probar que no ocurre.

La progresión natural es: tipos precisos → contratos y aserciones → property-based/metamórfico → model checking del núcleo crítico. Se sube de escalón solo cuando el costo del fallo lo justifica.

---

## H. Testing metamórfico — verificar sin oráculo exacto

B.2 presenta property-based (invariantes declaradas) y differential (dos implementaciones que deben coincidir). Falta el tercer miembro de la familia, indispensable cuando **no existe un oráculo que diga cuál es la salida correcta** para una entrada dada.

El **problema del oráculo** es real: en muchos sistemas nadie puede afirmar de antemano "para esta entrada, la salida exacta debe ser X". Casos típicos:
- **Numérico y científico**: no se conoce el valor cerrado de una integral, una simulación o una optimización.
- **Compiladores y motores de consulta**: no hay una "salida correcta" de referencia salvo reejecutar; pero sí hay transformaciones que **deben** preservar semántica.
- **ML, búsqueda y ranking**: no existe la etiqueta "correcta" para una predicción o un resultado de búsqueda individual.

La idea metamórfica sortea la ausencia de oráculo verificando **relaciones metamórficas**: propiedades que ligan la salida de **múltiples** ejecuciones relacionadas, sin necesitar el valor absoluto de ninguna. La forma canónica es *"si transformo la entrada así, la salida debe cambiar asá"*. Ejemplos por dominio:

- **Numérico**: `sin(x) == sin(x + 2π)` (invariancia); escalar todas las entradas de una función homogénea escala la salida en la proporción esperada.
- **Compiladores**: compilar con `-O0` y con `-O2` debe producir el **mismo comportamiento observable**; una transformación que preserva semántica no puede cambiar el resultado del programa.
- **Motores de consulta / búsqueda**: agregar una condición **más restrictiva** al filtro nunca debe **aumentar** el número de resultados; reordenar cláusulas conmutativas no cambia el conjunto devuelto.
- **ML / clasificadores**: perturbaciones que preservan la clase (p. ej. reformular sin cambiar el significado, o transformaciones invariantes del dominio) no deberían invertir la predicción; duplicar una instancia no debería alterar su score.

Relación con sus hermanas: property-based verifica un **invariante de una sola ejecución**; differential compara **dos implementaciones** en la misma entrada; metamórfico compara **la misma implementación** en **entradas relacionadas**. Las tres son fuzzing con oráculo declarado, y son **complementarias** — cubren clases de defectos distintas. Su límite (como todo en E) es el mismo: una relación metamórfica **débil o falsa** da falsa seguridad, y ninguna prueba ausencia de defectos; el juicio de `certero` sobre si la relación captura la **intención** sigue siendo el cierre del circuito. El diseño de la batería de relaciones como estrategia de suite es de `amado`; `certero` escribe la relación que **fija su propio fix**.

---

*Hermanos relacionados:* [analisis-estatico-dinamico → metodologia-revision.md](metodologia-revision.md) · [correccion-y-refactor.md](correccion-y-refactor.md) · [pruebas-de-regresion.md](pruebas-de-regresion.md)
