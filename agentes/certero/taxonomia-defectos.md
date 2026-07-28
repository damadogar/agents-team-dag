# Taxonomía de defectos de correctitud — el catálogo del cazador de bugs

Este documento es el **atlas de fallas** que `certero` usa para nombrar, clasificar y cazar defectos de **correctitud**. No basta con "oler" que algo está mal: un maestro del *code review* reconoce el defecto por su **familia**, anticipa su **escenario disparador**, sabe **dónde mirar** en el diff y conoce la **corrección de raíz** (no el parche que solo silencia el síntoma).

La taxonomía es **universal**: aplica a cualquier lenguaje, paradigma o dominio. Los ejemplos son deliberadamente multi-ecosistema (p. ej. lenguajes con recolección de basura y lenguajes con propiedad/RAII; sistemas de tipos con `Optional`/`Maybe` y sistemas con nulos ambientales) para no anclar el catálogo a una tecnología concreta.

**Frontera de ownership.** `certero` es dueño de la **correctitud**. Cataloga TODO lo que huele a defecto, pero **enruta**: los defectos con implicación de seguridad se documentan y se pasan a `destroyer`; los de lentitud/escalabilidad, a `peakformance`. Un mismo hallazgo (p. ej. un desbordamiento de entero) puede ser bug de correctitud **y** vector de seguridad: `certero` corrige la lógica y **notifica** a `destroyer` para la valoración del riesgo.

---

## Tabla maestra: familia → síntoma → causa raíz → señal en review

| Familia | Síntoma típico | Causa raíz frecuente | Señal en review (dónde mirar) |
|---|---|---|---|
| Lógica / control de flujo | Rama incorrecta se ejecuta; caso "imposible" ocurre | Condición invertida, operador booleano equivocado, guarda mal ordenada | `if`/`switch` con negaciones anidadas, `!`/`&&`/`||` mezclados, `switch` sin `default`/sin `break` |
| Bordes numéricos | Resultado 1 de más/menos; crash en el límite | Off-by-one, límite `<` vs `<=`, overflow silencioso | Índices, bucles `for`, aritmética cerca de `MAX`/`0`, comparación de flotantes con `==` |
| Nulos / ausencia | Excepción de referencia nula; valor por defecto tóxico | Ausencia no modelada, `Optional` desempacado sin verificar | Accesos encadenados `a.b.c`, `get()`/`unwrap()`, retornos que pueden ser nulos |
| Manejo de errores | Fallo desaparece sin rastro; estado a medias | `catch` vacío/demasiado amplio, limpieza no garantizada | Bloques `catch`/`except`/`rescue` sin re-lanzar ni loguear; ausencia de `finally`/`defer` |
| Mal uso de API / contratos | Comportamiento "raro" pese a código "correcto" | Precondición violada, unidades confundidas, semántica malentendida | Llamadas fuera de orden, argumentos mutados, banderas por defecto, API deprecada |
| Gestión de recursos | Fuga que crece con el tiempo; pool agotado | Cierre faltante, doble liberación, uso-después-de-liberar | `open`/`connect`/`acquire` sin cierre pareado en todos los caminos |
| Estado e invariantes | Objeto en estado imposible; corrupción intermitente | Invariante rota, mutabilidad/aliasing inesperado, orden de init | Setters que rompen consistencia, estructuras compartidas mutadas, estado global |
| Datos / (de)serialización | Falla con ciertas entradas, locales o fechas | Parsing frágil, encoding/zona horaria, coerción de tipos | `parse`/`split` a mano, formato de fecha sin zona, comparación de strings sensible a locale |
| Concurrencia | Fallo no reproducible bajo carga | Carrera, publicación insegura, bloqueo/orden de locks | Estado mutable compartido sin sincronización (ver `concurrencia-y-estado.md`) |
| Por tipo de sistema | Falla propia del dominio (idempotencia, precisión, etc.) | Supuesto inválido para ese tipo de sistema | Reglas del dominio (ver `dominios-especializados.md`) |

Las secciones siguientes desarrollan cada familia con el patrón **qué es → disparador → detección → corrección de raíz**.

---

## 1. Lógica y control de flujo

**Qué es.** El código *hace* lo que dice, pero *dice* lo incorrecto: la estructura de decisión no corresponde a la intención.

**Disparadores típicos.** Condición invertida (`if (activo)` cuando debía ser `if (!activo)`); confusión `&&`/`||` o precedencia; cortocircuito que **omite** un efecto secundario esperado; rama faltante (un caso del dominio sin manejar); *fall-through* accidental en un `switch`/`match` sin terminador; **guardas mal ordenadas** (se valida después de usar, o el caso general captura antes que el específico).

**Detección en review.**
- Reescribe mentalmente cada condición en lenguaje natural y contrástala con el requisito. Las dobles negaciones son foco rojo.
- Enumera los casos del dominio y verifica **cobertura exhaustiva**: ¿hay `default`/`else`? ¿qué pasa con el valor inesperado?
- Marca cualquier `switch`/`case` donde un caso "cae" al siguiente sin intención explícita.
- Revisa el **orden**: las guardas de rechazo (validación, permisos, límites) deben ir **antes** de la lógica principal.

**Corrección de raíz.** No parchees invirtiendo un signo a ciegas; **modela la tabla de verdad completa**. Prefiere estructuras que el compilador/linter pueda verificar como exhaustivas (p. ej. `match` sobre tipos suma/enumeraciones cerradas). Extrae condiciones complejas a predicados con nombre (`esElegible(x)`). Si el lenguaje lo permite, activa el aviso de exhaustividad. Sella con una prueba de regresión por rama (ver `pruebas-de-regresion.md`).

**Caso de alto riesgo — lógica de autorización / control de acceso.** Un predicado de autorización es **lógica pura**: un `&&` que debía ser `||` (o al revés), una guarda mal ordenada o una condición negada puede **conceder acceso indebido** o **negárselo a un usuario legítimo**. Su **correctitud lógica es de `certero`** (cae de lleno en esta familia), igual que el split que se aplica en seguridad de memoria y en TOCTOU; solo la **explotabilidad como vulnerabilidad** (superficie de ataque, severidad de seguridad) es de `destroyer`. Revísalo con una **tabla de verdad de la regla** (quién debe y quién no debe acceder) y séllalo con pruebas por caso, incluidos los de denegación correcta.

```
// Anti-patrón: guarda tardía y rama faltante
resultado = calcular(pedido)          // usa pedido...
if (pedido == AUSENTE) return ERROR   // ...y valida después

// Raíz: guarda temprana + exhaustividad
if (pedido == AUSENTE) return ERROR
switch (pedido.estado) {
  NUEVO, PAGADO, ENVIADO -> ...
  default -> error("estado no contemplado: " + pedido.estado)
}
```

---

## 2. Bordes numéricos

**Qué es.** El defecto vive en el **límite** del rango, no en el caso medio. El código funciona con 5 elementos y explota con 0 o con el último índice.

**Disparadores típicos.** Off-by-one (`<` vs `<=`, `length` vs `length-1`); acceso fuera de límites de índice; **overflow/underflow** de enteros (silencioso en muchos lenguajes, con envoltura o con excepción según el tipo); división por cero (o módulo por cero); **precisión de coma flotante** (comparar con `==`, acumular errores, dinero en `float`); **redondeo** con modo/half-even mal elegido; errores de **signo** (restar sin ordenar, valor sin signo tratado como con signo).

**Detección en review.**
- Para cada bucle e índice, pregunta explícitamente por **0, 1 y N** elementos, y por el **primer y último** índice.
- Ante aritmética, pregunta: ¿puede acercarse a `MAX`/`MIN`? ¿el divisor puede ser cero? ¿el tipo es con o sin signo, y de qué ancho?
- Cualquier `==`/`!=` entre flotantes es sospechoso; el dinero o cantidades exactas en tipo de punto flotante es defecto de diseño.

**Corrección de raíz.** Usa **límites semánticos** (iteradores/`for-each`, *slices*, rangos) en lugar de aritmética manual de índices cuando sea posible. Para dinero y exactitud, usa **enteros escalados o decimales de precisión fija**, no binario flotante. Para overflow, elige aritmética **checked**/saturante o valida el rango antes de operar. Compara flotantes con **tolerancia (epsilon)** apropiada al dominio. Nota: si el overflow es explotable, catalógalo y enruta a `destroyer`; si la lentitud proviene de aritmética de precisión, es tema de `peakformance`.

---

## 3. Nulos y ausencia

**Qué es.** El "error de los mil millones de dólares": tratar la **ausencia** de un valor como si fuera un valor presente.

**Disparadores típicos.** Referencia a `null`/`undefined`/`None`/`nil` sin verificar; `Optional`/`Maybe`/`Result` desempacado con `get()`/`unwrap()` sin comprobar; NPE en accesos encadenados; **valores por defecto peligrosos** (un `""`, `0` o `-1` que se confunde con dato real); tratar una **colección vacía** como error o, al revés, indexar sin verificar tamaño.

**Detección en review.**
- Sigue el rastro de cada valor que *pueda* ser ausente desde su origen hasta su uso: ¿se verifica en cada frontera?
- Desconfía de todo `get()/unwrap()/!!/force` que asuma presencia.
- Cuestiona los defaults: ¿el centinela elegido puede aparecer como dato legítimo? (`-1` como "no encontrado" cuando `-1` es un valor válido).
- Distingue **"vacío"** de **"ausente"** de **"cero"**: son tres estados distintos y confundirlos es un bug clásico.

**Corrección de raíz.** Haz la ausencia **explícita en el tipo** (`Optional`/`Maybe`/nullability del sistema de tipos) y oblígate a manejarla; evita el nulo ambiental. Cuando el lenguaje ofrezca *null-safety* o aviso del compilador, actívalo. Prefiere **objetos nulos/colecciones vacías inmutables** a `null` como retorno de colecciones. Aplica *fail-fast* en la frontera de entrada en vez de propagar el nulo hacia dentro. Nunca "arregles" un NPE añadiendo un `if != null` en el punto del crash sin entender **por qué** llegó ausente hasta ahí.

---

## 4. Manejo de errores

**Qué es.** El código no falla; **finge** que no falló, o falla dejando el sistema a medias.

**Disparadores típicos.** Excepción **tragada** (`catch {}` vacío); `catch`/`except` **demasiado amplio** que atrapa lo que debía propagarse (incluidos errores de programación); códigos de error **ignorados** (retorno no chequeado); **limpieza que no ocurre** en el camino de error (recurso queda abierto); **estados parciales** (se aplicó la mitad de una operación); **reintentos sin idempotencia** (se repite un efecto no idempotente); **propagación incorrecta** (se pierde la causa, se relanza otro tipo sin contexto, se convierte error recuperable en fatal o viceversa).

**Detección en review.**
- Cada bloque de captura debe **hacer algo** significativo: manejar, enriquecer y relanzar, o traducir. Un `catch` que solo loguea y continúa como si nada es sospechoso.
- Verifica que **todos los caminos** (incluido el de error) liberen recursos y dejen invariantes intactas.
- Ante reintentos, pregunta: ¿la operación es **idempotente**? Si no, un reintento duplica efectos.
- Revisa que la **causa original** se conserve (encadenamiento de excepciones, *wrapping* con contexto).

**Corrección de raíz.** Adopta una **política de errores** clara: distingue errores **esperados/recuperables** (parte del contrato, modélalos como valores o tipos de resultado) de **fallos inesperados** (deja que se propaguen y aborten limpio). Captura **estrecho** (el tipo específico) y en el **nivel correcto** (donde puedes decidir). Garantiza limpieza con construcciones del lenguaje (`finally`/`defer`/RAII/`using`/`with`). Diseña operaciones como **transaccionales o idempotentes** para que el reintento sea seguro. Conserva siempre la causa. Enruta a `destroyer` cualquier manejo de error que **filtre información sensible** en mensajes o logs.

---

## 5. Mal uso de API y contratos

**Qué es.** Cada función tiene un **contrato** (precondiciones, postcondiciones, invariantes, orden esperado, unidades). El defecto es violar ese contrato aunque la sintaxis compile.

**Disparadores típicos.** Precondición violada (llamar sin inicializar, con argumento fuera de rango); **orden de llamadas** incorrecto (usar antes de abrir, cerrar dos veces); **unidades/tipos confundidos** (segundos vs milisegundos, metros vs pies, bytes vs caracteres, base 0 vs base 1); **semántica malentendida** (creer que un método copia cuando referencia, que ordena estable cuando no, que es inclusivo cuando es exclusivo); **mutación de argumentos compartidos** (modificar una colección recibida que el llamante sigue usando); uso de **API deprecada** con comportamiento sutilmente distinto al reemplazo.

**Detección en review.**
- Lee la **documentación/contrato** de las APIs no triviales que el diff invoca; no asumas la semántica.
- Rastrea **unidades** con nombres o tipos: un `timeout` sin unidad en el nombre es una trampa.
- Marca cualquier función que **mute** un parámetro de entrada que no sea claramente "de salida".
- Verifica el **orden** de operaciones con estado (inicializar → usar → liberar) en todos los caminos.

**Corrección de raíz.** Haz los contratos **explícitos y verificables**: tipos fuertes para unidades (p. ej. un tipo `Duracion` en vez de `int`), aserciones de precondición en la frontera, `const`/inmutabilidad para argumentos que no deben mutar. Prefiere APIs que hagan **imposible** el mal uso (constructores que exigen todo lo necesario, *builders* que validan). Migra fuera de lo deprecado leyendo la **nota de migración**, no por reemplazo mecánico. Documenta la corrección para que no reincida (ver `plantillas.md`).

---

## 6. Gestión de recursos

**Qué es.** Todo recurso finito (memoria, *handles* de archivo, descriptores, sockets, conexiones, locks, hilos, entradas de pool) tiene un ciclo de **adquisición → uso → liberación**. El defecto rompe ese ciclo.

**Disparadores típicos.** **Fuga** (adquirir sin liberar; se acumula y agota el recurso); **cierre faltante** en el camino de excepción; **doble liberación** (liberar dos veces, corrompiendo el asignador); **uso-después-de-liberar** (referencia a memoria/handle ya liberado); **agotamiento de pools** (no devolver conexiones al pool, o retenerlas más de lo necesario).

**Detección en review.**
- Por cada adquisición, localiza su liberación **pareada** y confirma que ocurre en **todos** los caminos, incluidos *early returns* y excepciones.
- En lenguajes con propiedad/RAII, verifica que el *scope* de vida sea correcto; en lenguajes con recolección, cuidado con recursos **no-memoria** (archivos, sockets) que el GC no cierra a tiempo.
- Busca referencias que **sobreviven** al recurso (callbacks, cachés, listeners no desuscritos) — causa común de fugas "lógicas".

**Corrección de raíz.** Usa construcciones que **acoplan liberación al ámbito**: RAII, `using`/`with`/`try-with-resources`, `defer`, *scope guards*. Prefiere **propiedad clara** (un único dueño responsable de liberar). Para pools, garantiza **devolución en `finally`** y define *timeouts*/límites. Nota de frontera: una fuga que degrada el rendimiento con el tiempo puede parecer problema de `peakformance`, pero si la causa es un recurso no liberado por lógica incorrecta, la **raíz es de correctitud** y la corrige `certero`; `peakformance` interviene si el diseño del *pooling*/asignación es el cuello de botella. Un *use-after-free* explotable se cataloga y se enruta a `destroyer`.

---

## 7. Estado e invariantes

**Qué es.** Una **invariante** es una verdad que siempre debe cumplirse (p. ej. "el saldo nunca es negativo", "la lista está ordenada", "si `estado==CERRADO` entonces `fechaCierre` existe"). El defecto permite que el objeto entre en un estado **imposible**.

**Disparadores típicos.** Invariante rota por un setter parcial; **mutabilidad inesperada** (compartir un objeto que se creía inmutable); **aliasing** (dos referencias al mismo objeto, una lo muta y sorprende a la otra); **orden de inicialización** incorrecto (usar un campo antes de asignarlo, dependencias cíclicas en la construcción); **estado global compartido** que acopla módulos y se corrompe; corrupción de estructuras por mutación concurrente (ver `concurrencia-y-estado.md`).

**Detección en review.**
- Identifica las invariantes del tipo y verifica que **ningún** camino público las pueda romper (constructores, setters, métodos mutadores).
- Marca objetos que se **exponen por referencia** (retornar la colección interna) permitiendo mutación externa.
- Revisa el **orden de construcción/inicialización**: campos usados antes de estar listos, singletons con dependencias circulares.
- Desconfía del estado **global/estático mutable**: es fuente de acoplamiento y corrupción.
- **Invalidación de caché** como invariante entre la caché y su fuente ("una de las dos cosas difíciles"): lectura obsoleta tras escritura, orden de invalidación equivocado, coherencia caché↔origen que se rompe, TTL que no refleja el cambio. Verifica que toda escritura invalide/actualice lo cacheado y que no queden lecturas *stale* observables. *(El* stampede *y la caché no thread-safe se tratan en `concurrencia-y-estado.md` §6; el rendimiento de la caché es de `peakformance`.)*
- **Máquina de estados como lente transversal (no solo en embebido):** modela como máquina de estados cualquier entidad con ciclo de vida —pedido, sesión, conexión, workflow, componente de UI, transacción—. Busca **transiciones inválidas** (un evento en un estado que no lo espera), **estados inalcanzables u huérfanos** y **transiciones que rompen la invariante** del tipo. Una **tabla de transiciones exhaustiva** convierte "estado imposible" en un caso que el compilador/revisor puede verificar (la versión de tiempo real vive en `dominios-especializados.md` §5).

**Corrección de raíz.** Prefiere **inmutabilidad** por defecto; si hay mutación, encapsúlala tras métodos que **preserven la invariante** (validan antes de cambiar). Devuelve **copias defensivas** o vistas de solo lectura de estructuras internas. Centraliza las invariantes en el constructor y en un método de verificación (`assertInvariants()`) usable en pruebas. Elimina el estado global mutable a favor de dependencias explícitas. Para invariantes bajo concurrencia, la protección se diseña en `concurrencia-y-estado.md`.

---

## 8. Datos y (de)serialización

**Qué es.** Los datos cruzan **fronteras** (red, disco, entrada de usuario, otro sistema) y en cada cruce se **codifican/decodifican**. El defecto aparece cuando el supuesto sobre el formato es falso.

**Disparadores típicos.** **Parsing frágil** (dividir por posición/separador asumiendo un formato rígido); **encoding/Unicode** (mezclar bytes y caracteres, normalización, *surrogate pairs*, comparación que ignora combinaciones); **zonas horarias y fechas** (guardar sin zona, asumir la del servidor, DST, año bisiesto, semana ISO); **locale** (formato de números `1,000` vs `1.000`, orden de collation, mayúsculas específicas del idioma); **truncamiento** (cortar por bytes en medio de un carácter, campo más corto que el dato); **coerción de tipos** (conversiones implícitas string↔número↔booleano que dan resultados sorpresa).

**Detección en review.**
- Ante cualquier parseo manual, pregunta por entradas **malformadas, vacías o con caracteres especiales**.
- Toda fecha/hora debe llevar **zona horaria explícita**; marca cualquier "hora local" ambigua.
- Verifica que las comparaciones de texto usen la **semántica correcta** (binaria vs sensible a locale) y que el truncamiento respete **límites de carácter**, no de byte.
- Desconfía de coerciones implícitas; exige conversiones explícitas y validadas.
- **Expresiones regulares como fuente de defecto:** anclas (`^`/`$`) faltantes que aceptan de más, codicioso vs perezoso, clases Unicode y `\w` según locale, `.` que no cruza saltos de línea, validación demasiado laxa (pasa lo inválido) o demasiado estricta (rechaza lo válido). Verifica la regex contra casos válidos **e inválidos límite**, no contra un solo ejemplo feliz. *(El* catastrophic backtracking */ReDoS es rendimiento/seguridad → enruta a `peakformance`/`destroyer`.)*

**Corrección de raíz.** Usa **parsers/serializadores robustos y probados** en lugar de manipulación ad-hoc de strings; valida contra un **esquema**. Trabaja fechas con tipos *timezone-aware* y almacena en un patrón inequívoco (p. ej. instante en UTC + zona de presentación). Sé explícito con el **encoding** en cada frontera (idealmente el mismo, extremo a extremo). Trata la coerción con conversiones explícitas y manejo de fallo. Las particularidades por ecosistema (qué garantiza cada plataforma) se detallan en `lenguajes-y-ecosistemas.md`. Una entrada malformada que provoca comportamiento explotable se enruta a `destroyer`.

---

## 9. Concurrencia (resumen — ver `concurrencia-y-estado.md`)

**Qué es.** Defectos que solo emergen cuando varias líneas de ejecución tocan estado compartido: **carreras de datos**, **condiciones de carrera** lógicas, **publicación insegura**, **interbloqueos**, **inanición**, visibilidad de memoria.

**Señal en review.** Estado mutable compartido sin sincronización; suposición de atomicidad sobre operaciones compuestas ("comprobar-luego-actuar"); orden de adquisición de locks inconsistente; datos publicados a otro hilo sin barrera.

**Nota.** Por su profundidad y por su interacción con invariantes (familia 7) y rendimiento, la concurrencia tiene documento propio: **`concurrencia-y-estado.md`**. La corrección de raíz (inmutabilidad, confinamiento, sincronización correcta, estructuras concurrentes, modelos sin memoria compartida) se desarrolla allí.

---

## 10. Defectos por tipo de sistema (resumen — ver `dominios-especializados.md`)

**Qué es.** Cada tipo de sistema tiene **familias de bugs propias** derivadas de sus supuestos: en sistemas distribuidos, la **idempotencia**, el **exactamente-una-vez** ilusorio, el reloj no monótono y la partición de red; en sistemas de tiempo real, el **incumplimiento de plazos**; en cálculo científico/financiero, la **estabilidad numérica**; en interfaces, el **estado de UI** inconsistente; en procesamiento por lotes, la **reejecución parcial**.

**Señal en review.** Un supuesto válido en un tipo de sistema aplicado a otro donde no se cumple (p. ej. asumir entrega única de un mensaje, o reloj siempre creciente).

**Nota.** El catálogo por dominio se desarrolla en **`dominios-especializados.md`**. Aquí basta con reconocer que la taxonomía anterior es la **base transversal** y que cada dominio la especializa.

---

## Cómo usar esta taxonomía en la práctica

1. **Nombrar antes que corregir.** Al detectar un olor, ubícalo en su familia. El nombre correcto trae consigo el patrón de causa raíz y la corrección adecuada.
2. **Buscar el patrón, no la instancia.** Si aparece un off-by-one, busca los demás bucles del cambio; los defectos vienen en **familias** dentro del mismo código.
3. **Corregir de raíz, sellar con regresión.** Toda corrección se acompaña de una prueba que fallaría con el bug y pasa con el arreglo (ver `pruebas-de-regresion.md`) y se aplica bajo el modelo *tiered* de `correccion-y-refactor.md`.
4. **Enrutar lo que no es tuyo.** `certero` cataloga todo, pero **no** es dueño de todo:
   - Defecto con implicación de **seguridad** → se documenta y se enruta a `destroyer`.
   - Defecto de **lentitud/escalabilidad** → se enruta a `peakformance`.
   - Problemas de **esquema/consultas de datos** → `andulfo`; de **arquitectura** → `eneida`; ownership de la **suite de pruebas** → `amado`.

La detección sistemática de estas familias se apoya en herramienta automática (ver `analisis-estatico-dinamico.md`) y en la metodología de revisión (ver `metodologia-revision.md`); la profundización en causa raíz vive en `debugging-causa-raiz.md`.

---

*Documentos hermanos:* [debugging-causa-raiz.md](debugging-causa-raiz.md) · [concurrencia-y-estado.md](concurrencia-y-estado.md) · [correccion-y-refactor.md](correccion-y-refactor.md)
