# Footguns por lenguaje, paradigma y ecosistema

Un mismo patrón es **correcto en un ecosistema y un defecto en otro**. La coerción implícita que un lenguaje dinámico celebra como ergonomía es un bug latente en otro; la excepción que un lenguaje espera que propagues es un error tragado en un ecosistema que devuelve `Result`. La correctitud no se mide contra un ideal universal ni contra la preferencia del revisor: se mide contra **el idioma real del ecosistema en cuestión**.

Este archivo organiza los defectos por **ejes transversales de comportamiento**, no por lenguaje. Para cada eje se describe la *familia* de modelos, el footgun que produce cada familia, cómo se manifiesta el bug y cómo revisarlo. Todos los ejemplos son ilustrativos (`p. ej.`) y ninguna familia es "mejor": cada una hace un trade-off distinto y expone distintas clases de error.

Principio rector de este archivo: **cero preferencia**. Se juzga si el código respeta el contrato de *su* ecosistema, no si ese ecosistema te gusta.

---

## Eje 1 — Gestión de memoria

La familia del modelo de memoria determina qué clase de fuga o corrupción es *posible*. Revisar memoria significa primero identificar el modelo, luego buscar el footgun propio de ese modelo.

| Modelo / idioma | Footgun característico | Cómo se ve el bug | Cómo revisarlo |
|---|---|---|---|
| Recolección de basura por trazado (p. ej. ecosistemas de VM gestionada) | Retención accidental por referencias vivas | Memoria crece sin límite; el GC no libera porque *algo* sigue apuntando (caché sin evicción, listener no removido, referencia estática) | Buscar colecciones estáticas/globales que solo crecen, listeners/callbacks nunca desregistrados, `ThreadLocal` sin limpiar. La fuga es *lógica*, no de sintaxis |
| Conteo de referencias (p. ej. ecosistemas con ARC/refcount) | Ciclos de referencias fuertes | Objetos que se apuntan mutuamente nunca llegan a cero; fuga estable | Verificar que un lado del ciclo use referencia débil/no-propietaria (weak/unowned). Padre→hijo fuerte, hijo→padre débil |
| Propiedad y préstamo (p. ej. ecosistemas con ownership en compilación) | Luchar contra el verificador con vías de escape | El código *compila* pero usó una vía de escape (contador atómico, `unsafe`, interior mutability) que reintroduce el problema que el modelo evitaba | Auditar cada bloque `unsafe`/vía de escape como código de otra familia: ahí vuelven use-after-free y data races |
| Manual (p. ej. ecosistemas sin gestión automática) | Doble free, use-after-free, dangling, fuga | Corrupción de heap, crash intermitente, lectura de memoria liberada; a veces silencioso | Emparejar cada asignación con exactamente una liberación en *todos* los caminos (incluido el de error/excepción). Punteros puestos a nulo tras liberar. Ownership documentado: ¿quién libera? |
| Arenas / regiones / pools | Uso después de reset de la arena | Se retiene un puntero a memoria que la arena recicló | Confirmar que ningún puntero sobreviva al ciclo de vida de su región |

Señal transversal: **recursos que no son memoria** (descriptores de archivo, sockets, conexiones, locks) fugan bajo *cualquier* modelo, incluso con GC. Revisar que se cierren en el camino de error (patrón de bloque con limpieza garantizada: `defer`, `using`, `try-with-resources`, context managers, RAII).

---

## Eje 2 — Sistema de tipos, igualdad y nulidad

Estático, dinámico y gradual son puntos de un continuo. El footgun no es "ser dinámico" ni "ser estático"; es asumir la semántica de una familia mientras se programa en otra.

| Aspecto | Familia / idioma | Footgun | Cómo se ve el bug | Cómo revisarlo |
|---|---|---|---|---|
| Coerción | Dinámico con coerción implícita (p. ej. algunos lenguajes de scripting) | `1 + "1"`, comparación entre tipos distintos | Concatenación donde se esperaba suma; ordenamientos absurdos | Usar el operador de igualdad *estricta* del idioma cuando exista; convertir explícitamente antes de operar |
| Igualdad | Referencia vs valor vs estructural | Comparar objetos con igualdad de *referencia* creyendo comparar *contenido* | Dos objetos "iguales" dan `false`; claves de mapa que no coinciden | Confirmar qué igualdad usa el idioma por defecto y cuál usa la estructura de datos elegida. Igualdad de flotantes: nunca exacta |
| Truthiness | Idiomas con valores "falsy" ricos (p. ej. `0`, `""`, `[]`, `None` cuentan distinto según el lenguaje) | Guardas como `if (x)` que rechazan valores válidos (`0`, cadena vacía) | Un `0` legítimo se trata como ausencia | Revisar guardas de presencia: distinguir "ausente" de "presente pero falsy". Comparar contra el centinela explícito |
| Nulidad | `null` vs `undefined` vs `None`/`nil`/`nothing` vs opcionales tipados | Confundir "no inicializado" con "ausente a propósito"; acceso a miembro de valor nulo | Excepción de referencia nula; rama que nunca se toma | Verificar el idioma de ausencia del lenguaje. Si hay tipos opcionales, que se *desenvuelvan* con chequeo, no con forzado (`!`, unwrap sin verificar) |
| Opcionales / uniones | Tipos suma / opcionales (p. ej. ecosistemas con `Option`/`Maybe`/nullable types) | Desenvolver a la fuerza; ignorar la rama vacía | Panic/crash al forzar un vacío | Que cada opcional se maneje en *ambas* ramas. Forzar solo con invariante demostrada y comentada |
| Conversión numérica/tipo | Estático con conversiones ensanchando/estrechando | Estrechamiento silencioso (truncamiento) | Pérdida de datos al asignar tipo más chico | Revisar conversiones que pierden rango/precisión; que sean explícitas y verificadas |

Regla: el sistema de tipos gradual **solo protege lo que está anotado**. Revisar los bordes sin tipar (entrada externa, `any`/`dynamic`, deserialización) como código dinámico puro.

---

## Eje 3 — Manejo de errores idiomático

Este es el eje donde con más frecuencia se **impone el idioma equivocado**. El defecto no es *cómo* maneja errores el ecosistema, sino *contradecir* ese cómo.

| Idioma del ecosistema | El bug de traicionar el idioma | Cómo se ve | Cómo revisarlo |
|---|---|---|---|
| Excepciones (propagación implícita) | Capturar de forma demasiado amplia y tragar (`catch` vacío o que solo loguea y sigue) | El programa continúa en estado inválido; el fallo reaparece corrupto más adelante | Cada captura ancha debe re-lanzar, envolver con contexto o manejar *de verdad*. Capturar el tipo más específico posible |
| Valores de error / `Result`/`Either` | Ignorar el valor devuelto; envolver en excepción algo que el idioma quiere que fluya como valor | Rama de error nunca inspeccionada; el "error" viaja como éxito | Verificar que *todo* retorno de error se inspeccione o propague explícitamente. Que no se convierta a excepción salvo en la frontera correcta |
| Códigos de retorno (p. ej. ecosistemas de bajo nivel) | No comprobar el código; asumir éxito | Se opera sobre resultado inválido; errno/último-error pisado por la siguiente llamada | Cada llamada que puede fallar tiene su chequeo *inmediato*, antes de otra operación que pise el estado de error |
| Panics / abort para lo irrecuperable | Usar panic para errores *esperables* (entrada del usuario), o recuperarse de un panic que señala bug | Caída ante entrada normal; o continuar tras corrupción | Distinguir "error esperable" (dato) de "invariante rota" (panic/abort). No usar el mecanismo de catástrofe para control de flujo normal |
| Errores como efectos / checked | Firmar que no se lanza y lanzar; o suprimir el checked con envoltura vacía | Contrato de la firma mentido | Que la firma refleje los errores reales; envolturas que preserven la causa |

Frontera de `certero`: detecta la traición al idioma y la clasifica en `taxonomia-defectos.md`. Si el fix requiere rediseñar el flujo de errores del dominio, se entrega vía tiered al dueño (`motor` en backend, `farola` en frontend).

---

## Eje 4 — Mutabilidad, aliasing y closures

| Situación | Familia / idioma | Footgun | Cómo se ve | Cómo revisarlo |
|---|---|---|---|---|
| Paso de argumentos | Por valor vs por referencia vs por "referencia de objeto compartido" | Mutar un argumento creyendo que era una copia (o al revés) | Efecto colateral inesperado en el llamador | Identificar la semántica del lenguaje para cada *tipo*: primitivos y agregados suelen diferir dentro del mismo idioma |
| Copia | Superficial vs profunda | "Copiar" una estructura anidada y compartir los hijos | Mutar la copia altera el original en niveles profundos | Verificar profundidad de copia frente a la mutación que se hará; clonar profundo solo si se muta anidado |
| Defaults mutables | Idiomas que evalúan el default una sola vez (p. ej. algunos lenguajes de scripting) | Colección/objeto mutable como valor por defecto de parámetro | Estado se acumula entre llamadas "independientes" | Buscar defaults que sean estructuras mutables; usar centinela nulo y crear dentro |
| Captura en closures | Por valor vs por referencia; captura de variable de bucle | El closure captura la *variable* (cambia) en vez del *valor* (congelado) | Todos los callbacks de un bucle ven el último valor | Confirmar la semántica de captura del idioma; congelar el valor por iteración si aplica |
| Inmutabilidad | Estructuras persistentes / congeladas | Asumir inmutabilidad profunda cuando solo es superficial (congela el contenedor, no los hijos) | Mutación colándose por un hijo mutable | Verificar que "inmutable" cubra la profundidad que el código asume |
| Aliasing | Múltiples referencias vivas al mismo estado | Dos vías mutan lo mismo sin coordinación | Corrupción difícil de reproducir | Ver `concurrencia-y-estado.md` cuando además hay hilos |

---

## Eje 5 — Numérico y dinero

| Tema | Familia / idioma | Footgun | Cómo se ve | Cómo revisarlo |
|---|---|---|---|---|
| Overflow de enteros | Enteros de tamaño fijo con wrap silencioso | Suma/multiplicación que envuelve sin avisar | Total gigante negativo; índice fuera de rango; monto corrupto | Revisar operaciones cerca de límites de tipo; usar tipos/operaciones checked o de ancho suficiente; validar entradas |
| Overflow | Enteros de precisión arbitraria (p. ej. ecosistemas donde el entero crece) | *No* hay overflow, pero sí coste/memoria inesperados | Lentitud/memoria en números enormes | Distinto footgun: rendimiento, no corrección. Revisar cotas de tamaño |
| División entera | Idiomas donde `/` trunca entre enteros | `5/2 == 2`; redondeo hacia cero vs hacia abajo con negativos | Cálculo con pérdida silenciosa; módulo de negativos con signo sorpresa | Confirmar semántica de división y módulo del lenguaje; forzar flotante/decimal si se quiere fracción |
| Coma flotante | IEEE-754 (universal) | `0.1 + 0.2 != 0.3`; comparación exacta; acumulación de error | Aserciones que fallan; centavos que no cuadran | Comparar con tolerancia; nunca flotante para dinero |
| Dinero | — | Usar flotante binario para moneda | Descuadres de redondeo que se acumulan | Exigir decimal de base 10 / enteros de menor unidad (centavos) / tipo Money. Política de redondeo explícita y consistente |
| Conversión | Firmado vs sin signo; ancho | Mezcla de signed/unsigned; comparación entre anchos | Comparaciones invertidas; bucles infinitos | Revisar mezclas de firmado/sin-signo y promociones implícitas |
| Especiales | NaN / infinitos | `NaN != NaN`; propagación a través de agregados | Un solo NaN envenena una suma/estadística; ordenamientos rotos | Validar entradas; chequear NaN/inf antes de comparar o agregar |

### Estabilidad numérica avanzada (núcleos científicos y financieros)

La tabla anterior cubre el footgun de *usar* flotante. Esta subsección cubre el footgun más sutil de *encadenar* operaciones flotantes: aun cuando cada paso es correcto por sí solo, el algoritmo como conjunto puede amplificar el error hasta invalidar el resultado. Es el terreno de motores de riesgo, valoración de instrumentos, simulación física, álgebra lineal y estadística acumulada. No es un lujo académico: un solver que "converge" a un número equivocado es un bug de correctitud, no de rendimiento.

| Tema | Footgun | Cómo se ve el bug | Cómo revisarlo |
|---|---|---|---|
| Cancelación catastrófica | Restar dos cantidades casi iguales: los dígitos significativos se cancelan y afloran los bits de error relativo, que pasan de ruido a dígitos dominantes | Varianza que da negativa; discriminante `b²−4ac` que colapsa; derivada numérica que es puro ruido; pérdida de todas las cifras significativas en un paso aparentemente trivial | Buscar restas de operandos cercanos, sobre todo dentro de fórmulas cerradas (varianza de una pasada, cuadrática ingenua, `1−cos x`, `eˣ−1` para `x` pequeño). Verificar si existe una reformulación algebraicamente equivalente pero numéricamente estable (p. ej. fórmula de la cuadrática que evita la resta; primitivas dedicadas tipo `log1p`/`expm1`; varianza en dos pasadas o por el método de Welford). El defecto es la *forma* de la expresión, no un valor concreto |
| Número de condición y propagación | Tratar un problema mal condicionado como si el algoritmo fuera el culpable; ignorar cuánto amplifica la entrada su propio error relativo | Sistema lineal casi singular cuya solución cambia radicalmente ante una perturbación mínima; inversión de matriz que "funciona" pero cuyo resultado no significa nada; regresión que estalla con predictores colineales | Distinguir *condicionamiento del problema* (inherente a los datos) de *estabilidad del algoritmo* (elección de método). Revisar que se estime o acote el número de condición cuando la entrada puede ser casi singular, y que se prefiera un método estable (p. ej. factorización con pivoteo, descomposición ortogonal) frente a la fórmula directa. Un residual pequeño no prueba una solución correcta si el problema está mal condicionado |
| Acumulación en algoritmos iterativos | Suponer que un lazo de muchas iteraciones (integradores, solvers, reducciones, productos punto largos) conserva la precisión que tenía en la primera | Deriva lenta que solo se nota a gran escala; energía que no se conserva en una simulación; criterio de parada que nunca se cumple o se cumple antes de tiempo porque el residual está dominado por error de redondeo | Verificar que el error por iteración esté acotado y no crezca sin control; que el criterio de convergencia use tolerancias *relativas* además de absolutas y contemple un tope de iteraciones; que las reducciones largas usen un orden o una técnica que limite el error (ver sumas compensadas). Sospechar de todo lazo cuyo número de pasos escala con el tamaño del dato |
| Comparación por ULPs | Comparar flotantes con un epsilon fijo y arbitrario (p. ej. una constante mágica) que es demasiado laxo para números pequeños y demasiado estricto para números grandes | Aserciones que pasan cerca de 1.0 pero fallan con magnitudes de millones o de millonésimas; "iguales" que dependen de la escala de los operandos | Preferir tolerancia *relativa* a la magnitud, o comparación por distancia en ULPs (unidades en la última posición), que se adapta a la escala. Reservar el epsilon absoluto para el entorno del cero, donde la comparación relativa se degrada. Revisar que la elección de tolerancia sea justificada por el dominio, no una constante copiada. Nota de frontera: la tolerancia *de negocio* (redondeo monetario, umbrales contractuales) no es un ULP: sigue exigiendo decimal y política explícita |
| Determinismo y reproducibilidad entre plataformas | Asumir que la misma expresión produce bit-a-bit el mismo resultado en distinto compilador, nivel de optimización, CPU o grado de paralelismo | Prueba de regresión con hash/snapshot de resultados que falla solo en CI o en otra arquitectura; resultado que difiere entre build de depuración y de producción; suma paralela que da valores distintos según el número de hilos | Identificar las fuentes de no determinismo: contracción a FMA (multiplicar-sumar fusionado, que cambia el redondeo intermedio), reordenamiento asociativo que el optimizador aplica aunque la suma flotante *no* sea asociativa, banderas agresivas que relajan IEEE-754 (p. ej. optimizaciones tipo `-ffast-math` / *fast math* que habilitan reasociación, asumen ausencia de NaN/inf y descartan el cero con signo), y reducciones paralelas cuyo orden de combinación no es fijo. Revisar que, donde se exija reproducibilidad, se desactive fast-math, se controle la contracción FMA, se fije el orden de reducción y se documente el contrato ("bit-reproducible" vs "correcto dentro de tolerancia"). No confundir *reproducible* con *correcto*: puede exigirse uno, otro o ambos |
| Sumas compensadas | Acumular muchos términos con `+=` ingenuo, dejando que cada suma pierda los bits bajos del acumulador frente a términos de magnitud dispar | Total de un dataset grande que se desvía del valor real; media/momentos estadísticos sesgados; el error crece con el número de términos y con la disparidad de magnitudes | Donde la exactitud de una reducción importe, verificar el uso de suma compensada (p. ej. Kahan, o Neumaier/Kahan-Babuška que además maneja el caso en que el término supera al acumulado), acumulación por pares (*pairwise*), u orden de menor a mayor magnitud, o un acumulador de mayor ancho. Señal de alarma: sumar cantidades de escalas muy distintas en un lazo largo con el operador básico. Cuidado inverso: un optimizador con reasociación habilitada puede *deshacer* una suma de Kahan; la compensación y el fast-math son incompatibles |

Cómo se prueba este eje: no basta con un caso "feliz". Se revisa con entradas *adversarias* a la estabilidad — operandos casi iguales, matrices casi singulares, magnitudes extremas y mezcladas, lazos largos — y se contrasta contra un oráculo de mayor precisión (aritmética de más ancho, decimal, o precisión arbitraria) para *medir* el error relativo, no para suponerlo. El veredicto se expresa como cota de error frente a tolerancia declarada, no como igualdad exacta.

---

## Eje 6 — Asincronía idiomática (resumen)

Cada ecosistema tiene un idioma asíncrono: bucle de eventos monohilo, corrutinas, hilos verdes, hilos de SO, callbacks, actores. El footgun raíz es **mezclar dos modelos** o **bloquear el mecanismo del idioma** (p. ej. bloquear el bucle de eventos con trabajo síncrono pesado; llamar código bloqueante desde una corrutina; olvidar esperar/consumir una promesa/future y perder su error). Señales rápidas: promesas/futures creados y no esperados (errores tragados), `async` sin `await`, mezcla de API bloqueante y no bloqueante en la misma pila. El tratamiento completo de carreras, visibilidad de memoria, deadlocks y cancelación está en `concurrencia-y-estado.md`.

---

## Eje 7 — Evaluación, inicialización y carga

| Tema | Familia / idioma | Footgun | Cómo se ve | Cómo revisarlo |
|---|---|---|---|---|
| Perezosa vs ansiosa | Idiomas con evaluación perezosa (p. ej. secuencias/streams diferidos) | Efectos secundarios que nunca ocurren porque nadie consumió la secuencia; o excepción que aparece *tarde*, lejos de su origen | Falla en un punto que no la causó; recurso ya cerrado al consumir tarde | Verificar que lo perezoso se materialice dentro del alcance del recurso; separar efectos de la construcción de la secuencia |
| Orden de inicialización | Estáticos/globales entre módulos | Dependencia entre inicializaciones cuyo orden no está garantizado | Valor nulo/cero en arranque, no reproducible | Evitar dependencias entre estáticos de distintas unidades; inicialización perezosa idempotente |
| Hoisting / TDZ | Idiomas con elevación de declaraciones o zonas muertas temporales | Usar antes de asignar; capturar binding no inicializado | `undefined`/error de acceso temprano | Revisar uso antes de declaración según las reglas del idioma |
| Efectos en import/carga | Módulos con código en tiempo de carga | Trabajo pesado, I/O o registro global al importar | Import lento; efectos por el mero hecho de importar; import circular a medio inicializar | Los módulos no deben hacer I/O ni mutar estado global al cargarse; detectar ciclos de import |
| Constantes vs congelado | Constante de referencia a estructura mutable | "Constante" cuyo *contenido* se muta | Estado compartido cambiado por sorpresa | `const`/`final` suele congelar el *binding*, no el objeto: verificar profundidad |

---

## Eje 8 — Cadenas, texto y Unicode

El texto es un campo minado transversal porque casi todo lenguaje simplifica *alguna* capa de Unicode.

| Tema | Footgun | Cómo se ve | Cómo revisarlo |
|---|---|---|---|
| Unidad de "longitud" | Confundir bytes, unidades de código (UTF-16), code points y grafemas | "Longitud" errónea con emoji, acentos, scripts no latinos; corte a mitad de carácter → texto roto | Verificar qué cuenta el lenguaje por defecto y qué necesita el dominio (grafemas para UI, bytes para límites de almacenamiento) |
| Indexado/slicing | Cortar por índice de unidad de código | Se parte un carácter multi-unidad o un par sustituto | Nunca cortar en medio de un grafema; usar API consciente de Unicode |
| Normalización | Comparar cadenas sin normalizar (NFC/NFD) | "Igual" visualmente pero distinto en bytes (é precompuesto vs combinado) | Normalizar a una forma canónica antes de comparar/almacenar/usar como clave |
| Encoding | Asumir un encoding al leer bytes | Mojibake; excepción de decodificación; datos corruptos | Encoding explícito en toda frontera de I/O; UTF-8 por defecto salvo contrato distinto |
| Comparación con locale | Ordenar/comparar/mayúsculas sin locale o con el locale del entorno | Orden distinto por máquina; `toUpper` turco (i sin punto); "case-insensitive" roto | Comparaciones sensibles a locale explícitas; para claves/protocolos usar comparación invariante/ordinal |
| Caso y plegado | Igualdad case-insensitive ingenua | Falsos negativos en scripts no ASCII | Usar case-folding Unicode, no `toLower` byte a byte |

---

## Eje 9 — Ecosistema, dependencias y no determinismo

| Tema | Footgun | Cómo se ve | Cómo revisarlo |
|---|---|---|---|
| Versionado | Interpretar versionado semántico como garantía absoluta; rangos abiertos | Build que cambia de comportamiento sin cambiar tu código | Verificar rangos de versión y archivo de bloqueo (lockfile) presente y respetado |
| Resolución de dependencias | Diamantes de versiones; resolución transitiva sorpresa | Dos versiones de la misma lib; API incompatible en runtime | Revisar el árbol resuelto, no solo lo declarado; detectar duplicados/conflictos |
| Efectos de plataforma | Asumir separador de ruta, fin de línea, mayús/minús de sistema de archivos, zona horaria, endianness | Funciona en una plataforma y falla en otra; ruta rota; hora corrida | Abstraer rutas/tiempos/EOL; probar en las plataformas objetivo; UTC en almacenamiento |
| Orden de iteración | Asumir orden en mapas/conjuntos no ordenados | Código que "funciona" por un orden accidental | Salida no reproducible; test que pasa a veces | Nunca depender del orden de un contenedor sin orden garantizado; ordenar explícitamente si importa |
| Aleatoriedad de hash | Semilla de hash aleatoria por proceso | Orden distinto entre ejecuciones (defensa anti-DoS) | Tests frágiles; snapshots que cambian | No serializar dependiendo del orden de hash; ordenar antes de comparar |
| Fuente de aleatoriedad | Usar PRNG no criptográfico para seguridad, o semilla fija en producción | Tokens predecibles | Para seguridad, CSPRNG; para reproducibilidad de tests, semilla explícita y documentada |
| Reloj y zona horaria | Hora local implícita; ignorar DST y segundos intercalares | Cálculos de duración erróneos dos veces al año | Almacenar en UTC; zona solo en presentación; aritmética de fechas con librería consciente de DST |
| Entorno y locale | Comportamiento que cambia según variables de entorno/locale del host | "En mi máquina funciona" | Fijar locale/encoding/zona de forma explícita donde el resultado deba ser determinista |

### Footguns de correctitud de la cadena de suministro

> **Vista complementaria:** el ángulo de *proceso* (revisar el diff de dependencias a escala, provenance, typosquatting, rollout de actualizaciones) está en [revision-a-escala.md](revision-a-escala.md) §9. Aquí se cubre el *footgun del ecosistema*; la frontera es común: lo *explotable* → `destroyer`, el *cambio de comportamiento funcional* → `certero`.

La tabla anterior trata el no determinismo *de tu proceso*. Esta subsección trata el no determinismo *de tus dependencias*: el código que no escribiste y que puede cambiar de comportamiento bajo tus pies. Frontera explícita con `destroyer`: lo *explotable* — un paquete comprometido, malware inyectado en la cadena, un CVE con vector de ataque — es de `destroyer`. Lo que revisa `certero` aquí es distinto y complementario: el cambio de comportamiento *funcional* de una dependencia legítima que rompe la correctitud de tu programa sin que nadie tenga intención maliciosa. Un `sort` que cambia de estable a inestable, un parser que ahora acepta lo que antes rechazaba, un default que se invirtió: no es un ataque, es un bug que entró por el árbol de dependencias.

| Tema | Footgun | Cómo se ve el bug | Cómo revisarlo |
|---|---|---|---|
| Cambio de comportamiento sin cambio de tu código | Una actualización (a menudo *transitiva*, de una dependencia de tu dependencia) altera semántica observable: valores por defecto, orden de resultados, precisión, redondeo, manejo de bordes, mensajes de error de los que dependía tu parsing | El build de hoy produce un resultado distinto al de ayer con el mismo commit tuyo; una prueba de integración empieza a fallar sin cambios en el repositorio; comportamiento que "se arregló solo" o "se rompió solo" | Confirmar que el resultado del build sea función únicamente de tu código *más* un conjunto de versiones fijado. Ante un cambio de comportamiento inexplicable, revisar el diff del árbol resuelto (no solo del manifiesto) entre la última corrida buena y la mala. Tratar el comportamiento del que dependes pero que no está en tu contrato como una suposición frágil que hay que blindar con pruebas de caracterización |
| Resolución transitiva y diamantes | Dos dependencias exigen versiones distintas de una tercera; el resolvedor elige una, unifica, duplica o falla según las reglas del ecosistema, y esas reglas difieren radicalmente entre gestores | Se carga una versión de la librería compartida que satisface a un consumidor pero viola las suposiciones del otro; en ecosistemas que permiten coexistencia, dos copias con estado o tipos incompatibles en el mismo proceso; comportamiento que depende de *cuál* ganó la resolución | Inspeccionar el árbol *resuelto*, no lo declarado: ver qué versión única quedó para cada nodo del diamante y si algún consumidor recibió una versión fuera del rango que realmente probó. Detectar duplicados de la misma librería y evaluar si compartir estado/tipos entre las copias es un problema. Recordar que el conjunto ganador puede cambiar con solo añadir una dependencia no relacionada |
| Integridad y respeto del lockfile | Manifiesto con rangos abiertos y *sin* archivo de bloqueo, o con lockfile presente pero ignorado por el pipeline (instalación que vuelve a resolver en cada build); lockfile desincronizado del manifiesto | Irreproducibilidad: dos máquinas o dos momentos resuelven versiones distintas del mismo commit; "en CI funciona / local no" por resolución divergente; el hash de integridad no se verifica y entra un artefacto distinto al fijado | Verificar que exista lockfile, que esté *commiteado*, que el comando de instalación de CI/producción sea el modo *estricto/inmutable* (falla si el lockfile no cuadra, en vez de re-resolver), y que los hashes de integridad se validen. Confirmar coherencia manifiesto↔lockfile. La correctitud reproducible exige que el conjunto de versiones sea un artefacto fijo y verificado, no el resultado de re-resolver |
| Incumplimiento de semver | Confiar en el versionado semántico como garantía dura: asumir que un "patch"/"minor" no puede cambiar comportamiento | Una actualización marcada como compatible introduce un cambio de comportamiento (regresión, endurecimiento de validación, cambio de default, corrección que altera resultados de los que dependías); tu rango abierto la absorbe automáticamente | Tratar semver como *intención declarada*, no como prueba. Donde la correctitud sea crítica, acotar rangos y fijar por lockfile, y elevar actualizaciones —aun de patch— mediante pruebas de caracterización/regresión antes de aceptarlas. Distinguir el "cambio de comportamiento que es en realidad un breaking encubierto" del cambio anunciado: el primero es el que rompe silenciosamente |

Cómo se prueba y se enmarca este eje: se ancla la correctitud con pruebas que capturen el *comportamiento actual* de las dependencias de las que dependes de facto (caracterización), de modo que un cambio transitivo se manifieste como una prueba roja y no como un bug en producción. Al revisar, se compara el árbol resuelto entre dos puntos en el tiempo, no solo el manifiesto. Y se respeta la frontera: si al investigar el cambio de comportamiento aparece un componente comprometido, un paquete suplantado o un CVE, eso deja de ser correctitud funcional y se escala a `destroyer`; el fix del acoplamiento frágil en tu código de dominio se entrega, vía tiered, a `motor` o `farola` según corresponda.

---

## El principio: revisar contra el idioma real

1. **Identifica el ecosistema y su idioma** antes de juzgar una línea. La misma construcción es correcta en un lugar y defectuosa en otro; tu preferencia no entra en la ecuación.
2. **Nombra la familia de comportamiento** (memoria, tipos, errores, mutabilidad, numérico, async, evaluación, texto, ecosistema) a la que pertenece el riesgo, y busca el footgun *propio de esa familia*.
3. **Distingue el footgun del ecosistema** (característica con filo) del **error del autor** (traicionar el idioma). Solo lo segundo es un defecto de correctitud.
4. **Consulta la documentación oficial cuando la semántica sea sutil** — orden de evaluación, reglas de coerción, garantías de copia, semántica de división, formas de normalización. Afirmar sin verificar es en sí un defecto de revisión.
5. **Apóyate en las herramientas del propio lenguaje**: type-checkers, linters y analizadores específicos capturan gran parte de estos ejes automáticamente. Cómo elegirlos y leerlos en cada ecosistema está en `analisis-estatico-dinamico.md`.
6. **El fix de dominio pertenece a su dueño.** `certero` detecta, prueba y clasifica; bajo el modelo tiered, la corrección en código de negocio se entrega a `motor` (backend) o `farola` (frontend), y la especificación de datos/tipos sutiles se coordina con `andulfo`, `eneida` o `sysuniversal-ai` según el caso.

> Regla de oro: un patrón correcto en un lenguaje es un bug en otro. El revisor de clase mundial no tiene un lenguaje favorito; tiene el hábito de escribir en **el idioma correcto de cada ecosistema** y de exigirlo, con evidencia y sin sesgo.

---

Hermanos relacionados: `taxonomia-defectos.md` · `analisis-estatico-dinamico.md` · `concurrencia-y-estado.md`
