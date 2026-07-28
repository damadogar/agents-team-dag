# Correctitud de concurrencia y estado

La concurrencia es, junto con el manejo de estado mutable, la mayor fuente de defectos sutiles, intermitentes y caros de diagnosticar. Aquí `certero` audita y prueba la **CORRECTITUD** de programas concurrentes: que ningún entrelazado posible corrompa datos, produzca resultados erróneos, viole invariantes o cuelgue el sistema. La regla mental: *un programa concurrente es correcto solo si es correcto para TODOS los entrelazados que el modelo de ejecución permite, no solo el que observaste en tu máquina.*

## Frontera con `peakformance` (leer primero)

> **Nota de frontera.** `certero` toma la **correctitud**; `peakformance` toma el **rendimiento**. Un mismo fenómeno tiene ambas aristas y cada maestro toma la suya:
>
> | Fenómeno | Arista de `certero` (correctitud) | Arista de `peakformance` (rendimiento) |
> |---|---|---|
> | Contención de locks | Deadlock, livelock, orden de adquisición que cuelga | Lock como cuello de botella, throughput, granularidad para escalar |
> | Estado compartido | Data race que corrompe/da resultado incorrecto | False sharing, cache-line bouncing, tuning de pools |
> | Sincronización | Barrera/`volatile`/atómico faltante → visibilidad rota | Barrera de más → costo innecesario |
> | Colas/actores | Mensajes perdidos, fuera de orden, backpressure que rompe invariantes | Latencia de la cola, dimensionamiento, saturación |
>
> Si el problema es "da el número equivocado / se cuelga / corrompe", es de `certero`. Si es "funciona pero es lento / no escala", es de `peakformance`. Cuando ambos aplican, se coordinan: `certero` fija el fix que preserva correctitud, `peakformance` valida que la solución de rendimiento no reintroduzca una carrera.

## Frontera con el modelo TIERED

El **fix en código de dominio** (rediseñar una sección crítica de un servicio de negocio, reordenar la lógica de un endpoint) se entrega como orden a `motor` (backend) o `farola` (frontend) bajo modelo **T2**: `certero` diagnostica, prueba y especifica el arreglo; ellos lo implementan. `certero` implementa **T1** lo cross-cutting: sobre todo **el test que reproduce el race** con estrés, inyección de scheduling determinista o un arnés de entrelazado, y utilería de detección. Ver [correccion-y-refactor.md](correccion-y-refactor.md).

## 1. Data races y condiciones de carrera

**Data race** (definición estricta): dos accesos concurrentes a la misma ubicación de memoria, al menos uno de escritura, sin sincronización que establezca orden entre ellos. En muchos modelos de memoria es **comportamiento indefinido**. **Condición de carrera** (más amplia): el resultado depende del timing/entrelazado, aun sin data race formal (p. ej. dos operaciones atómicas cuyo orden relativo importa).

Patrones a cazar:

- **Read-modify-write no atómico.** `contador = contador + 1`, `if (x != null) x = ...`, `saldo -= monto`. Se leen, calculan y escriben en pasos separados; otro hilo se cuela entre lectura y escritura y se pierden actualizaciones (lost update). Defensa: operación atómica (p. ej. fetch-and-add, compare-and-swap) o sección crítica.
- **Publicación insegura.** Un objeto se hace visible a otros hilos antes de estar completamente construido/inicializado (p. ej. guardar `this` en un campo compartido dentro del constructor, o publicar una referencia a un objeto con campos aún sin escribir). Otro hilo ve un objeto a medio construir. Defensa: publicación segura (final/inmutable, sincronización, o construcción completa antes de publicar).
- **Visibilidad / staleness.** Sin barrera de memoria, un hilo puede no ver *nunca* la escritura de otro (el valor queda cacheado en registro/core). El clásico `while (!bandera) {}` que nunca termina aunque otro hilo puso `bandera = true`. Defensa: marca de visibilidad (p. ej. `volatile`/atómico/lock).

## 2. Atomicidad y operaciones compuestas

El error recurrente: componer varias operaciones individualmente atómicas y asumir que el conjunto lo es.

- **Check-then-act.** `if (!mapa.contiene(k)) mapa.poner(k, v);` — entre el `contiene` y el `poner` otro hilo insertó. Aun con un mapa concurrente (cada método atómico), la *composición* no lo es. Defensa: operación compuesta atómica que ofrezca la estructura (p. ej. put-if-absent, compute-if-absent) o lock que cubra ambas.
- **TOCTOU (time-of-check to time-of-use).** Revisas una condición (existe el archivo, hay permiso, alcanza el cupo) y actúas después; el mundo cambió en el intervalo. Fuente de bugs *y* de vulnerabilidades — coordina con `destroyer` cuando el TOCTOU es explotable (p. ej. race de permisos, symlink).
- **Invariantes multi-variable.** Si un invariante liga dos campos (`min <= max`, `saldo == suma(movimientos)`), toda actualización que los toque debe ser atómica respecto a cualquier lectura del invariante. Actualizar uno, liberar, actualizar el otro deja una ventana con el invariante roto observable.

## 3. Deadlock, livelock, starvation

- **Deadlock.** Espera circular: hilo A tiene L1 y pide L2; hilo B tiene L2 y pide L1. Condiciones de Coffman (exclusión mutua, hold-and-wait, no expropiación, espera circular). Defensa principal: **orden global de adquisición de locks** (jerarquía) — todos adquieren en el mismo orden total; rompe la circularidad. Alternativas: adquisición con timeout + reintento, o try-lock con backoff.
- **Lock reentrante vs no reentrante.** Un lock no reentrante hace deadlock consigo mismo si el mismo hilo lo readquiere (p. ej. método sincronizado que llama a otro método sincronizado sobre el mismo objeto). Verifica si el mecanismo es reentrante y si el código lo asume.
- **Locks anidados y callbacks.** Invocar código ajeno (callback, listener, método sobreescribible) **mientras se sostiene un lock** es una trampa: ese código puede readquirir locks en otro orden → deadlock. Regla: no llamar a código desconocido con un lock tomado.
- **Livelock.** Los hilos responden unos a otros y progresan de forma que ninguno avanza (dos personas cediéndose el paso). Frecuente en esquemas de retry/backoff mal calibrados.
- **Starvation.** Un hilo nunca obtiene el recurso porque otros lo acaparan (prioridades, locks no equitativos). Relacionado con equidad (fairness) de la primitiva.

## 4. Modelo de memoria y visibilidad

La CPU y el compilador **reordenan** lecturas/escrituras siempre que preserven la semántica *de un solo hilo*. Bajo concurrencia ese reordenamiento se hace observable y rompe supuestos.

- **Happens-before.** Relación que garantiza que los efectos de A son visibles en B. Se establece con primitivas de sincronización (liberar/adquirir un lock, escribir/leer un atómico con la semántica adecuada, arranque/join de hilo). Sin una arista happens-before entre dos accesos, no hay garantía de visibilidad ni de orden.
- **Barreras / `volatile` / atómicos.** Imponen orden y visibilidad. Cuidado: marcar una variable como "visible" **no** hace atómica una secuencia read-modify-write sobre ella; solo garantiza que cada lectura/escritura individual se ve.
- **Publicación segura por inmutabilidad.** Un objeto profundamente inmutable, publicado con las garantías del lenguaje, es seguro de compartir sin sincronización adicional: nadie puede observarlo en estado inconsistente porque no cambia. **La inmutabilidad es la defensa más barata y robusta** contra una enorme clase de bugs de concurrencia.

## 5. Bugs de async/await, promesas y futuros

Aunque un event loop de un solo hilo elimina data races clásicos, introduce su propia familia:

- **`await` olvidado / promesa no esperada.** Se invoca una operación async y no se aguarda su resultado: continúa el flujo con datos aún no listos, y si falla, la excepción se pierde. Cazar toda función async cuyo retorno se ignora.
- **Excepciones perdidas en tareas "fire-and-forget".** Una tarea lanzada sin ser observada traga su error (rejection no manejada). Requiere manejo explícito o un supervisor.
- **Cancelación.** ¿Qué pasa con el estado a medio mutar cuando la tarea se cancela? Cancelar entre dos escrituras deja invariantes rotos. Verifica puntos de cancelación y limpieza (finally/scope).
- **Estado/contexto capturado.** Un closure captura una variable de bucle o un contexto que cambió para cuando la continuación corre; o estado ligado al hilo/tarea (contexto por request) que no se propaga a la continuación en otro hilo.
- **Callbacks/continuaciones fuera de orden.** No asumas que dos operaciones async terminan en el orden en que se lanzaron. Si el orden importa, secuéncialas explícitamente.
- **Interleaving en un solo hilo.** Aunque no haya paralelismo, cada `await` es un punto donde otro trabajo se intercala: un invariante que valía antes del `await` puede no valer después (otra continuación mutó el estado compartido). Es un check-then-act encubierto.
- **Async en constructores/inicializadores.** No se puede esperar en un constructor; deja el objeto usable antes de estar inicializado. Patrón: fábrica async o inicialización perezosa protegida.
- **Deadlock por bloqueo síncrono sobre async.** Bloquear el hilo del loop esperando una tarea que necesita ese mismo hilo para completar → cuelgue.
- **Apagado ordenado (graceful shutdown) y ciclo de vida.** El *arranque* tiene su orden (ver `lenguajes-y-ecosistemas.md` Eje 7); el *apagado* también, y suele revisarse menos. Al recibir una señal de terminación (SIGTERM, rolling-restart, escalado a la baja): ¿se **drena** el trabajo ya aceptado antes de morir, se **vacían** los buffers/colas, se **liberan** recursos y se **compensan** las operaciones a medias? Cancelar a mitad de una mutación deja estado parcial (mismo riesgo que el interleaving de arriba). Revisa que exista una ruta de apagado que **preserve invariantes y no pierda trabajo aceptado**. Frontera: la **orquestación** del apagado (drain de balanceador, plazos de terminación) es de `eneida`/plataforma; la **correctitud de no perder ni corromper** en ese apagado es de `certero`.
- **Recuperación ante caída abrupta (crash-consistency).** El gemelo del apagado ordenado: cuando el proceso muere **sin aviso** a mitad de una escritura (p. ej. kill forzado, OOM-kill, corte de energía), ¿el estado **persistente** sobrevive a un punto **recuperable**? Riesgos a revisar: **escrituras a medias** (torn/partial writes), **orden de durabilidad** no garantizado (una escritura se hace durable antes que otra de la que depende), y **replay de journal/WAL** que debe ser **idempotente** y converger a un estado válido en el arranque. Regla: tras un crash en **cualquier** punto, el arranque debe alcanzar un estado consistente —o detectar y reparar el parcial—, nunca operar sobre datos corruptos. Frontera: la **física de la durabilidad** (fsync, barreras de escritura, configuración del motor) es de `andulfo`; la **orquestación** de la recuperación de infra es de `eneida`; la **correctitud de no-corromper y de recuperar a un estado válido** es de `certero`.

## 6. Bugs de estado compartido

- **Aliasing.** Dos referencias al mismo objeto mutable; una mutación por un camino sorprende al otro. Peor si una parte asumió "propiedad" exclusiva.
- **Mutación concurrente de colecciones.** Iterar una colección mientras otro hilo la modifica → corrupción o excepción. Estructuras no thread-safe compartidas sin protección.
- **Estado global / singletons perezosos.** Inicialización perezosa sin sincronización (double-checked locking mal hecho) → dos instancias o instancia a medio construir publicada.
- **Caché no thread-safe.** Lecturas/escrituras concurrentes que corrompen la estructura, o cache stampede (correctitud si dos productores dejan valores inconsistentes).
- **Estado por request compartido accidentalmente.** Un objeto que debía ser por-request/por-sesión guardado en un campo de instancia de un componente compartido (p. ej. un handler singleton con estado mutable) → datos de un usuario se filtran a otro. Bug de correctitud **y** de seguridad; escala con `destroyer`.

## 7. Modelos de concurrencia y sus footguns (neutral)

Ningún modelo es el default; cada uno mueve los bugs de sitio.

| Modelo (p. ej.) | Footgun de correctitud típico |
|---|---|
| Memoria compartida + locks | Data races, deadlock, olvidar sincronizar un acceso, orden de locks |
| Actores / paso de mensajes | Mensajes perdidos/duplicados/fuera de orden, estado del actor mutado por reentrada, deadlock lógico entre actores esperándose |
| CSP / canales | Bloqueo por canal sin lector, cierre de canal mal manejado, select con caso faltante |
| Event loop de un hilo | `await` interleaving, fire-and-forget con error tragado, bloqueo del loop |
| Paralelismo de datos | Reducción con operación no asociativa/conmutativa, escritura compartida en el cuerpo paralelo, dependencia entre iteraciones |

## 8. Estrategias de correctitud (en orden de preferencia)

1. **No compartir estado mutable.** La carrera que no existe no se puede probar. Confinamiento por hilo/tarea, copia en vez de compartir, ownership claro.
2. **Inmutabilidad.** Datos inmutables se comparten libres de sincronización. Convierte estado en transformaciones que producen valores nuevos.
3. **Confinamiento.** Que el estado mutable viva en un solo hilo/actor y se acceda solo por mensajes.
4. **Estructuras concurrentes probadas** en vez de sincronización artesanal: úsalas correctamente (recuerda: sus métodos son atómicos, tus composiciones no).
5. **Minimizar la superficie compartida** y documentar el contrato de threading de cada componente (thread-safe / confinado / requiere lock externo).

## 9. Cómo revisar código concurrente

1. **Localiza primero TODO el estado mutable compartido.** Campos de instancia de objetos compartidos, variables globales/estáticas, colecciones, caches, referencias que escapan. Ese inventario es el mapa de riesgo.
2. Para cada pieza de estado compartido: ¿quién la lee/escribe concurrentemente? ¿qué disciplina la protege? ¿el invariante que la liga a otras piezas se mantiene atómicamente?
3. Busca **operaciones compuestas** (check-then-act, read-modify-write) sobre estado compartido.
4. Rastrea **órdenes de adquisición de locks**; construye el grafo y detecta ciclos.
5. En async: marca cada `await` como punto de interleaving y revisa qué invariante podría no sobrevivirlo; caza async no esperados y errores tragados.
6. Verifica **visibilidad**: toda escritura que otro hilo debe ver, ¿tiene una arista happens-before hacia esa lectura?
7. Verifica **publicación**: ¿algún objeto escapa antes de estar completo?

## 10. Cómo reproducir y probar races

Los bugs de concurrencia rara vez se reproducen a demanda; hay que forzarlos. Ver [analisis-estatico-dinamico.md](analisis-estatico-dinamico.md) y [pruebas-de-regresion.md](pruebas-de-regresion.md).

- **Sanitizers / detectores de carreras dinámicos** (p. ej. thread sanitizers, detectores de happens-before): instrumentan la ejecución y señalan accesos sin sincronizar aunque el bug no se manifieste en esa corrida.
- **Análisis estático** de concurrencia: anotaciones de "guarded-by", detección de orden de locks inconsistente, lint de async no esperado.
- **Estrés / soak.** Muchos hilos, muchas iteraciones, mucho tiempo: sube la probabilidad del entrelazado malo. Útil pero no determinista.
- **Inyección de scheduling determinista.** Un arnés que controla el orden de los hilos o inserta puntos de cesión (yield) en lugares elegidos para forzar el entrelazado sospechoso de forma reproducible. Es el T1 que `certero` implementa: el test que *deterministamente* dispara la carrera.
- **Model checking / exploración de entrelazados** (p. ej. herramientas que enumeran sistemáticamente los schedules): para lógica concurrente crítica, prueban todos los entrelazados de un fragmento acotado. Coordina con `amado` cuando hay métodos formales de por medio.
- **Tests con barreras/latches** que sincronizan varios hilos en el punto exacto de la ventana de carrera para maximizar la colisión.

Criterio de un buen test de race: **reproduce el defecto de forma fiable (idealmente determinista) y falla ANTES del fix, pasa DESPUÉS**, sin depender de "correr mil veces y rezar".

## 11. Tabla de referencia: bug → síntoma → detección → defensa

| Bug de concurrencia | Síntoma observable | Cómo detectarlo | Defensa |
|---|---|---|---|
| Read-modify-write no atómico (lost update) | Contador/saldo menor de lo esperado, intermitente | Race detector; test de estrés con N incrementos concurrentes | Atómico (CAS/fetch-add) o sección crítica |
| Check-then-act / TOCTOU | Duplicados, condición violada bajo carga | Test que colisiona dos hilos en la ventana; análisis estático | Operación compuesta atómica; lock que cubra check+act |
| Publicación insegura | Objeto a medio construir, campos nulos esporádicos | Race detector; revisar escapes de `this`/referencias | Inmutabilidad/final; publicar tras construcción completa |
| Visibilidad / stale read | Bucle que no termina; valor viejo persistente | Difícil dinámicamente; revisar ausencia de barrera | `volatile`/atómico/lock; happens-before explícito |
| Deadlock | Cuelgue total, hilos bloqueados esperándose | Dump de hilos (grafo de espera); detección de orden de locks | Orden global de locks; try-lock con timeout |
| Livelock | Alto uso de CPU sin progreso | Observación bajo carga; trazas de retry | Backoff aleatorizado; romper simetría |
| Starvation | Un cliente/hilo nunca atendido | Métricas de latencia por hilo; revisar fairness | Primitiva equitativa; colas justas |
| `await` olvidado / promesa no esperada | Datos incompletos; error que "desaparece" | Lint de async no esperado; revisión de retornos ignorados | Esperar/encadenar; manejar rejections |
| Interleaving tras `await` | Invariante roto solo bajo concurrencia | Test que intercala continuaciones; revisión de invariantes por `await` | Reducir estado compartido entre awaits; snapshot antes del await |
| Mutación concurrente de colección | Corrupción/excepción al iterar | Test de estrés lectura+escritura; race detector | Estructura concurrente; copia inmutable para iterar |
| Estado por request compartido | Datos de un usuario aparecen en otro | Test concurrente multi-usuario; revisar campos de singletons | Confinamiento por request; sin estado mutable en componentes compartidos |
| Singleton perezoso mal sincronizado | Doble init; instancia a medio construir | Test concurrente de primer acceso | Inicialización segura del lenguaje; holder idiom |

## 12. Señales de alarma rápidas

- Cualquier campo mutable de instancia en un objeto compartido entre hilos/requests.
- `if (existe) usar` sobre estado compartido.
- Un lock tomado alrededor de una llamada a código ajeno (callback/listener).
- Dos o más locks adquiridos en el mismo camino sin un orden documentado.
- Una función async cuyo resultado se descarta.
- Un `while (bandera)` sobre una variable sin marca de visibilidad.
- Double-checked locking artesanal.
- Comentarios tipo "esto rara vez pasa" o "no debería ocurrir en producción".

> Las §13–§14 añaden dos capas de profundidad de élite: el **criterio formal** contra el que se juzga la correctitud concurrente y las **anomalías de aislamiento** cuando hay transacciones. (La §12 anterior es la lista de campo de acceso rápido.)

## 13. Criterios formales de correctitud concurrente (linearizabilidad y consistencia)

Revisar una estructura concurrente no es solo "¿tiene barrera?": es preguntar **contra qué criterio de correctitud** se juzga. Un revisor de frontera evalúa un objeto o un sistema concurrente contra la condición de consistencia que promete cumplir.

- **Linearizabilidad** (objetos concurrentes). Cada operación parece ocurrir de forma **instantánea en algún punto entre su invocación y su retorno**, y el orden resultante respeta el orden en tiempo real de operaciones no solapadas. Es el criterio más fuerte para una estructura de datos concurrente (cola, mapa, contador *lock-free*): si es linearizable, cualquier cliente puede razonar como si las operaciones fueran atómicas y secuenciales. Al revisar una estructura *lock-free/wait-free* artesanal, la pregunta clave es: **¿existe un punto de linealización claro para cada operación?** Si no puedes señalarlo, probablemente hay una carrera.
- **Problema ABA y reclamación segura de memoria** (endémicos al revisar estructuras *lock-free* artesanales). **ABA:** un `compare-and-swap` "tiene éxito" porque el valor volvió a ser `A`, aunque entre medias pasó a `B` y regresó — el CAS no distingue "no cambió" de "cambió y volvió", y la operación corrompe la estructura. Defensa a exigir: **contador de versión/tag** junto al puntero (CAS con etiqueta) o primitivas de doble ancho. **Reclamación:** liberar un nodo que otro hilo aún puede estar leyendo es un *use-after-free*; una estructura lock-free necesita un esquema de reclamación segura (p. ej. *hazard pointers*, épocas/EBR, RCU, o recolección del runtime). Regla de review: **si una estructura lock-free no muestra ni protección ABA ni reclamación segura, es un defecto**, no una optimización.
- **Serializabilidad** (transacciones). Un conjunto de transacciones concurrentes es correcto si su resultado equivale a **alguna** ejecución serie (una tras otra). Es el criterio de las transacciones; su relajación produce las anomalías de la §14.
- **Consistencia secuencial**: todas las operaciones ocurren en *algún* orden total que respeta el orden de programa de cada hilo, pero **no** necesariamente el orden en tiempo real global (más débil que linearizabilidad).
- **Modelos débiles / relajados** (p. ej. TSO y modelos aún más relajados): la CPU/el lenguaje permiten reordenamientos que rompen la intuición secuencial. Aquí el razonamiento **happens-before** (§4) y las semánticas *acquire/release* de los atómicos son la herramienta; asumir consistencia secuencial "gratis" es un bug clásico en código de bajo nivel.
- **Sistemas distribuidos**: el espectro va de consistencia fuerte (linearizable) a **eventual**, pasando por causal, *read-your-writes*, *monotonic reads*, etc. La correctitud de una lectura depende del modelo que el almacén garantiza; asumir uno más fuerte del real es el defecto (ver los casos de consistencia eventual en [dominios-especializados.md](dominios-especializados.md) §1).

Regla de review: **nombra el criterio que el código promete y verifica que lo cumple en todos los entrelazados**. "Parece correcto en mis pruebas" no es una prueba de linearizabilidad; para lógica crítica, el *model checking* de entrelazados (§10) o la especificación formal ([analisis-estatico-dinamico.md](analisis-estatico-dinamico.md)) sí lo son.

## 14. Anomalías de aislamiento transaccional (correctitud de la aplicación)

Cuando el código usa transacciones, la **elección del nivel de aislamiento y del alcance de la transacción es correctitud de la aplicación** — y por tanto arista de `certero`. Bajo aislamientos relajados aparecen anomalías que ni el *type checker* ni el esquema detectan, y que corrompen datos de forma silenciosa.

| Anomalía | Qué pasa | Escenario típico | Defensa (correctitud) |
|---|---|---|---|
| **Dirty read** | Se lee un cambio de otra transacción aún no confirmada (que puede abortar) | Aislamiento demasiado bajo | Subir a *read committed* como mínimo |
| **Non-repeatable read** | Dos lecturas del mismo dato en una transacción dan valores distintos | Otra transacción confirma en medio | *Repeatable read* / bloqueo de lectura |
| **Phantom** | Una consulta por rango devuelve filas nuevas al repetirse | Inserción concurrente en el rango | Aislamiento serializable / *predicate/range locks* |
| **Lost update** | Dos transacciones leen-modifican-escriben el mismo dato; una pisa a la otra | Contador/saldo actualizado sin bloqueo ni versión | *SELECT … FOR UPDATE*, escritura condicional, versión optimista (compare-and-set) |
| **Write skew** | Cada transacción lee un estado consistente y escribe algo válido *por separado*, pero juntas rompen un invariante que liga varias filas | Bajo *snapshot isolation*: "al menos un médico de guardia" y dos se dan de baja a la vez | Serializable, o materializar el conflicto (bloqueo/fila-guardia) |
| **Read skew** | Se leen dos datos relacionados en momentos inconsistentes | Lectura larga cruzando una escritura | Snapshot consistente / repeatable read |

Claves de review:
- **El invariante que cruza filas es el que revienta.** *Write skew* es invisible si solo miras cada transacción por separado; hay que preguntar *qué invariante global asumen juntas*.
- **La familia read-modify-write concurrente de la §1/§2 reaparece a nivel de base de datos**: `saldo = saldo - monto` sin bloqueo ni versión es *lost update* aunque cada sentencia sea atómica.
- **Read-after-write bajo réplicas/MVCC**: leer de una réplica o de un snapshot puede no ver tu propia escritura reciente; es la misma clase de *staleness* de la §4, ahora en datos.

**Frontera con `andulfo` (explícita).** La **elección del nivel de aislamiento, el alcance/duración de la transacción y la estrategia de bloqueo/versión en el código** es correctitud → **`certero`** (fix T2 vía `motor`). El **plan de ejecución, el índice que hace viable un bloqueo de rango, la configuración del motor y la plataforma de datos** son de **`andulfo`**. En una frase: *yo decido qué garantía necesita la lógica; `andulfo` decide cómo el motor la sostiene con eficiencia.* La física del motor y el rendimiento del bloqueo son de `andulfo`/`peakformance`, no míos.

---

**Ver también:** [analisis-estatico-dinamico.md](analisis-estatico-dinamico.md) · [pruebas-de-regresion.md](pruebas-de-regresion.md) · [correccion-y-refactor.md](correccion-y-refactor.md) · [dominios-especializados.md](dominios-especializados.md)
