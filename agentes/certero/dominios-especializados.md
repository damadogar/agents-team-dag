# Defectos de correctitud por tipo de sistema

Este archivo cataloga los defectos de **correctitud** que aparecen en clases concretas de sistemas y, para cada uno, fija **la frontera de disciplina**: qué arista es mía (`certero`, dueño de la correctitud) y qué debo **enrutar** a otro maestro. El principio rector es simple y no negociable: **tomo la arista de correctitud de cada sistema y ruteo lo demás**. No absorbo arquitectura, plataforma, performance, calidad de modelo ni seguridad ofensiva; los detecto, los nombro con precisión y los entrego a su dueño. Bajo el modelo TIERED, cuando el defecto es de correctitud, no solo lo reporto: propongo o aplico la corrección mínima y verificable.

> Neutralidad total: los ejemplos son ilustrativos (p. ej. una cola de mensajes, un motor SQL, un runtime serverless) y no implican preferencia por ningún proveedor, lenguaje ni stack.

---

## 1. Sistemas distribuidos

La correctitud distribuida es una de mis aristas más ricas: idempotencia, semántica de entrega, orden, consistencia lógica, sagas y compensaciones. **Mía**: que el sistema produzca resultados lógicamente correctos ante reintentos, duplicados y fallos parciales. **No mía**: los *límites de servicio*, la *resiliencia como diseño* y la *topología* son de `eneida`; la *tail latency*, el *batching* y el *throughput* son de `peakformance`. El **código** de estas correcciones suele vivir en un servicio backend: la columna «Corrección» marca de quién es la *correctitud* (`certero`), no quién teclea el cambio — que se materializa **T2 vía `motor`** (o T3 si `motor` está saturado).

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Operación no idempotente bajo reintentos | El productor reintenta tras timeout y el efecto se aplica dos veces (p. ej. doble cargo) | Buscar claves de idempotencia, deduplicación, upserts; trazar el camino reintento→efecto | `certero` (fix TIERED) |
| Suposición de exactly-once inexistente | El código asume que el broker entrega una sola vez | Verificar semántica real (at-least/at-most-once) y compensación en el consumidor | `certero` |
| Reintento que amplifica efectos secundarios | Retry externo re-dispara side effects no protegidos | Aislar efectos idempotentes vs. no idempotentes; outbox/transactional messaging | `certero` |
| Orden de mensajes no garantizado | Lógica que depende de orden en particiones/colas paralelas | Revisar claves de partición, secuencia, reordenamiento en consumidor | `certero` |
| Duplicados sin deduplicar | Redelivery genera filas/eventos repetidos | Ventanas de dedupe, IDs de mensaje, tabla de vistos | `certero` |
| Consistencia eventual mal manejada | Lectura tras escritura asume propagación inmediata | Detectar read-after-write, staleness tolerada, invariantes rotas | `certero` |
| Relojes como orden causal | `timestamp` de wall-clock usado para ordenar eventos | Exigir relojes lógicos/vectoriales o versión monotónica | `certero` (diseño de reloj → `eneida`) |
| Saga sin compensación completa | Un paso falla y no se revierten los anteriores | Mapear cada paso a su compensación; probar fallo en cada punto | `certero` |
| Fallo parcial ignorado | Timeout tratado como fallo definitivo (o como éxito) | Estados "desconocido"; reconciliación posterior | `certero` |
| Partición de red mal asumida | Código supone CP o AP sin decidirlo | Explicitar el trade-off; validar invariante bajo split-brain | Diseño → `eneida`; invariante lógica → `certero` |

**Frontera clave**: si el hallazgo es "el límite de servicio está mal trazado" o "falta un patrón de resiliencia arquitectónico", **es de `eneida`**. Si es "esta ruta duplica el efecto al reintentar", **es mía**.

---

## 2. Contratos y APIs

Aquí la correctitud es la **compatibilidad y la fidelidad del contrato** entre productor y consumidor. **Mía**: rupturas de contrato, validación, semántica de errores y evolución que rompe consumidores. **No mía**: el *diseño de la API/gobierno de contratos a nivel de plataforma* es de `eneida`; el *rendimiento del endpoint* es de `peakformance`. Igual que en §1: la columna «Corrección» indica la *correctitud* (`certero`); el cambio en código de dominio se teclea **T2 vía `motor`/`farola`** según dónde viva. *(La compatibilidad **durante el despliegue** —cuando ambas versiones del servicio coexisten en un rolling deploy— se trata en §8.)*

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Ruptura de compatibilidad hacia atrás | Se elimina/renombra un campo que un cliente aún usa | Diff de esquema; matriz productor/consumidor; contract tests | `certero` |
| Versionado ausente o inconsistente | Cambio incompatible sin nueva versión | Revisar política de versión y negociación | `certero` (política → `eneida`) |
| Validación de entrada insuficiente | Se acepta payload malformado y falla aguas abajo | Validar límites, tipos, requeridos, rangos | `certero` |
| Validación de salida ausente | Se emite respuesta que viola el esquema publicado | Serializar contra el contrato; property tests | `certero` |
| Semántica de código de estado errónea | Error de negocio devuelto como 200; error transitorio como permanente | Mapear casos a códigos/errores correctos | `certero` |
| Paginación defectuosa | Cursor inestable pierde/duplica ítems al insertarse datos | Revisar orden estable, cursores vs. offset, límites | `certero` |
| Evolución de esquema no defensiva | Consumidor rompe ante campo nuevo desconocido | Tolerancia a campos extra; defaults; nulabilidad | `certero` |

---

## 3. Pipelines de datos

Tomo la **correctitud de la lógica de transformación**: joins que duplican o pierden filas, nulos en agregaciones, ventanas y late data, reprocesamiento idempotente. **Frontera con `andulfo` (y su cluster: `caudal`, `brujula`, `prisma`)**: el **esquema físico, la plataforma, la orquestación y la calidad/gobierno del dato** son de ellos. Yo corrijo la lógica; ellos son dueños del sustrato de datos.

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Join que duplica filas | Cardinalidad no 1:1 infla métricas | Verificar claves, granularidad, `fan-out`; conteos antes/después | `certero` (lógica) |
| Join que pierde filas | Inner join donde debía preservar no coincidencias | Revisar tipo de join contra intención; anti-join checks | `certero` |
| Nulos en agregaciones | `SUM`/`AVG` que ignora o cuenta mal nulos | Semántica de null por función; coalescencia explícita | `certero` |
| Late data / ventana mal cerrada | Eventos tardíos caen fuera de ventana y se pierden | Watermarks, allowed lateness, reproceso de ventana | `certero` (plataforma de streaming → `caudal`) |
| Backfill no idempotente | Reprocesar duplica o corrompe el histórico | Escrituras idempotentes, particiones reemplazables, upsert por clave | `certero` |
| Deriva de esquema silenciosa | Fuente cambia tipo/columna y la transformación miente | Contratos de esquema, aserciones de forma | Detección `certero`; **gobierno del dato → `andulfo`** |
| Zona horaria / precisión numérica | Conversión pierde precisión o desalinea fechas | Revisar tipos, redondeo, TZ explícita | `certero` |

**Frontera clave**: "la transformación calcula mal" es mía. "El esquema, el motor, el particionamiento o la calidad del dato" es de **`andulfo`** y su cluster.

---

## 4. Código de IA/LLM

Reviso los **bugs funcionales del código que rodea al modelo**: construcción de prompts como código, parsing y validación de salidas no deterministas, manejo de límites/errores del proveedor, tool-calling, fugas de contexto y fallbacks. **Frontera con `sysuniversal-ai` / `prisma`**: la **calidad y evaluación del modelo** (evals, drift, accuracy) es de `prisma`/`sysuniversal-ai`; el **serving/MLOps** es de `sysuniversal-ai`.

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Prompt mal construido como código | Interpolación rompe el template con input adverso o vacío | Revisar plantilla, escape, límites de longitud, inyección de contexto | `certero` |
| Parsing frágil de salida | Se asume JSON perfecto; el modelo devuelve texto envolvente | Parser tolerante + validación de esquema + reintento acotado | `certero` |
| Manejo de error del proveedor ausente | Rate limit / timeout / 5xx tira la petición sin fallback | Retries con backoff idempotente, circuit breaker, degradación | `certero` (política de resiliencia → `eneida`) |
| Tool-calling sin validar argumentos | El modelo pide una acción con args inválidos y se ejecuta | Validar args contra esquema antes de ejecutar; sandbox | `certero` |
| Fuga de contexto / truncamiento | Contexto excede el límite y se corta silenciosamente | Contabilizar tokens, truncar con reglas explícitas, avisar | `certero` |
| Fallback inexistente o incorrecto | Sin respuesta del modelo, el sistema queda inconsistente | Ruta de degradación determinista y probada | `certero` |
| Confundir bug de código con mala calidad del modelo | "La respuesta es mala" | Aislar: ¿el código falla o el modelo evalúa mal? | Código → `certero`; **calidad/eval → `prisma`/`sysuniversal-ai`** |

**Frontera clave**: si el `glue code` falla, es mío. Si "el modelo responde mal aunque el código sea correcto", es de **`prisma`/`sysuniversal-ai`**.

---

## 5. Embebido y tiempo real

Tomo la **correctitud lógica y de estado**: máquinas de estado, reentrancia, manejo de interrupciones, gestión de recursos fijos y condiciones de borde de hardware. **Frontera con `peakformance`**: el **WCET, el determinismo temporal y el cumplimiento de deadlines como propiedad de rendimiento** son suyos. Yo garantizo que la lógica sea correcta; él, que sea temporalmente predecible.

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Máquina de estados con transición inválida | Evento en estado inesperado deja el sistema inconsistente | Tabla de transiciones exhaustiva; estados/eventos no manejados | `certero` |
| Reentrancia en ISR | Interrupción re-entra y corrompe estado compartido | Secciones críticas, `volatile`, datos compartidos ISR↔main | `certero` |
| Condición de carrera con hardware | Lectura de registro entre dos escrituras del periférico | Protocolo de acceso, barreras, doble buffer | `certero` |
| Agotamiento de recurso fijo | Buffer/pool estático se desborda sin detección | Límites, backpressure, verificación de capacidad | `certero` |
| Desbordamiento de contador/tiempo | `tick` que envuelve y rompe comparaciones | Aritmética modular segura; comparaciones con diferencia | `certero` |
| Inversión de prioridades | Una tarea de alta prioridad queda bloqueada por una de baja que retiene un recurso compartido (con una tarea media que se cuela) — el bug del Mars Pathfinder | Revisar locks compartidos entre tareas de distinta prioridad; exigir protocolo de herencia o techo de prioridad | `certero` (correctitud del protocolo de locks); análisis temporal → **`peakformance`** |
| Deadline incumplido por diseño temporal | La tarea es correcta pero no cabe en su ventana | Análisis de planificabilidad/WCET | **`peakformance`** |

### 5.1 Rigor de sistemas safety-critical

En dominios de alta criticidad (p. ej. aviónica, dispositivos médicos, automotriz, aeroespacial, control nuclear), la correctitud no es solo "el resultado lógico es el esperado": es también **el cumplimiento demostrable de reglas de codificación crítica** que reducen la superficie de comportamiento indefinido y hacen el código verificable por herramienta. Estas reglas son **neutrales al lenguaje** —aplican a cualquier lenguaje de sistemas— y no prescriben ninguno; lo que un revisor de frontera exige es su cumplimiento, no una tecnología concreta.

- **Límites a la complejidad y a lo no acotado** (estilo JPL/NASA "Power of Ten"): flujo de control simple y verificable; **evitar la recursión** y, tras la fase de inicialización, **evitar la asignación dinámica de memoria** (usar recursos de tamaño fijo y determinable); **todo bucle con un límite superior fijo y comprobable**; acotar la profundidad de la **indirección de punteros**; reducir el **alcance de los datos** al mínimo indispensable.
- **Disciplina de verificación en el propio código**: densidad **mínima de aserciones** que capturen las precondiciones, postcondiciones e invariantes; **comprobar SIEMPRE** los valores de retorno y los códigos de error (nada de errores silenciosamente ignorados); y **compilar sin warnings** con todas las advertencias del compilador activadas, tratando cada advertencia como un defecto por resolver.
- **Subconjunto seguro del lenguaje** —familias de reglas tipo MISRA como **ejemplo neutral** (p. ej.)—: prohibir las construcciones ambiguas o propensas a error, el **comportamiento indefinido** y el **definido por implementación**, y las **conversiones peligrosas** (p. ej. entre tipos o entre punteros) que hagan el significado del programa dependiente del compilador. La idea general es la misma en cualquier familia: restringir el lenguaje a un subconjunto cuyo comportamiento sea inequívoco y **verificable por herramienta**.

La correctitud lógica de estas reglas y su cumplimiento es mía (`certero`): las reviso, las nombro con precisión y, bajo el modelo TIERED, propongo o aplico la corrección mínima y verificable. **Frontera explícita**: el **WCET** y el **determinismo TEMPORAL** (planificabilidad, deadlines, jitter) son de **`peakformance`**; la **explotabilidad** de un defecto como vulnerabilidad es de **`destroyer`**; `certero` verifica la **correctitud lógica** y el **cumplimiento de la regla de codificación crítica**. Para las técnicas que demuestran ese cumplimiento —cobertura estructural **MC-DC**, análisis estático del subconjunto seguro y **métodos formales**— ver [analisis-estatico-dinamico.md](analisis-estatico-dinamico.md).

---

## 6. Seguridad de memoria

Los defectos de memoria son, primero, **defectos de correctitud**: los cataloga y corrige `certero`. **Pero** si el defecto es **explotable como vulnerabilidad** (control de flujo, escalada, ejecución arbitraria), **coordino con y ruteo a `destroyer`**. La regla: la corrección del bug de memoria es mía; el análisis de explotabilidad, superficie de ataque y severidad de seguridad es de `destroyer`.

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Desbordamiento de buffer | Copia sin verificar longitud del destino | Revisar límites, `bounds checks`, APIs seguras | `certero` (si explotable → **`destroyer`**) |
| Uso después de liberar (UAF) | Puntero usado tras `free`/dispose | Rastrear ciclo de vida, ownership, ASan/análisis | `certero` (si explotable → **`destroyer`**) |
| Puntero colgante / doble liberación | Alias liberado por otra ruta | Modelo de propiedad, nulificación, RAII/smart pointers | `certero` (si explotable → **`destroyer`**) |
| Lectura de memoria no inicializada | Uso de valor basura | Inicialización obligatoria; herramientas de memoria | `certero` |
| Desbordamiento entero → tamaño mal calculado | Cálculo de tamaño hace overflow y sub-asigna | Aritmética verificada, tipos amplios, checks | `certero` (si explotable → **`destroyer`**) |

**Frontera clave**: "esto corrompe memoria" es mío corregirlo; "esto es una vulnerabilidad explotable" lo evalúa y prioriza **`destroyer`**.

---

## 7. UI / estado de cliente (breve)

Los bugs de **estado, render y eventos** en la capa cliente (p. ej. estado derivado incorrecto, efectos duplicados, listeners no limpiados, renders con datos obsoletos) son de correctitud, pero su **dueño es `farola`** (y el diseño/UX es de `uxuifull`). Mi rol aquí es acotado: si un defecto lógico cruza al cliente, lo señalo y lo enruto a `farola`; no asumo ownership del frontend.

| Defecto típico | Escenario | A quién pertenece |
|---|---|---|
| Estado derivado inconsistente | Cache local diverge de la fuente | `farola` |
| Efecto/listener duplicado o sin limpiar | Suscripción se acumula en cada render | `farola` |
| Render con datos obsoletos | UI muestra estado previo tras actualización | `farola` |

---

## 8. Correctitud del despliegue y la evolución (versiones que coexisten)

Un cambio puede ser correcto **en aislamiento** y aun así romper el sistema **mientras se despliega**: durante un *rolling deploy* conviven la versión vieja y la nueva, y durante una migración conviven el esquema viejo y el nuevo. La correctitud de la **secuencia del cambio** y de la **compatibilidad entre versiones que coexisten** es mía; es una de las causas más frecuentes de incidentes reales. *(Complementa a §2: allí se trata la compatibilidad del **contrato** hacia consumidores externos; aquí, la **ventana de coexistencia** de las dos versiones del propio servicio durante el despliegue.)*

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Incompatibilidad hacia atrás | La versión nueva escribe un estado/formato/mensaje que la vieja —aún viva— no sabe leer | Verificar que el consumidor viejo tolere lo que produce el nuevo durante la ventana de coexistencia | `certero` |
| Incompatibilidad hacia adelante | La versión vieja escribe algo que la nueva ya no acepta, o un valor de enum nuevo que la vieja no maneja | Revisar defaults/tolerancia a lo desconocido en ambos sentidos | `certero` |
| Migración no *expand-contract* | Renombrar/eliminar columna o cambiar tipo en un solo paso rompe las instancias que aún corren el código viejo | Exigir el patrón **expand → migrate → contract** (añadir, escribir en ambos/leer de ambos, luego retirar) | `certero` (secuencia); DDL/plan → `andulfo` |
| Orden código↔migración equivocado | El código nuevo asume una columna que la migración aún no aplicó (o viceversa) | Verificar que cada paso sea seguro con el código de la fase anterior **y** la siguiente | `certero` |
| *Dual-write / dual-read* mal cerrado | Se escribe en dos sitios durante la transición y quedan divergentes, o se retira un lado antes de tiempo | Revisar la reconciliación y el criterio de corte | `certero` |
| Flag/rollout sin ruta de reversión | El cambio no se puede revertir de forma segura si falla a mitad de despliegue | Exigir reversibilidad y un estado intermedio válido en todo momento | `certero` (reversibilidad lógica y estado intermedio válido); el **mecanismo/operación** de rollback → `eneida`/plataforma |

**Frontera clave**: la **estrategia de despliegue** (canary, blue-green, orquestación del rollout) y la infraestructura son de **`eneida`/plataforma**; el **DDL, el plan y el índice** de la migración son de **`andulfo`**; la **secuenciación correcta del cambio y la compatibilidad lógica entre versiones que coexisten** son mías (`certero`). La corrección de datos ya escritos por el bug se coordina con `andulfo` (ver [correccion-y-refactor.md](correccion-y-refactor.md) §3).

---

## 9. Cambios de configuración y feature flags

Un diff de **configuración** (config-as-code, IaC) o de **feature flag** es tan revisable —y tan peligroso— como un diff de código: es una de las causas #1 de incidentes de producción. Cambia el comportamiento del programa sin cambiar su lógica, y sus modos de fallo son propios.

| Defecto típico | Escenario | Cómo revisarlo | Corrección (correctitud: `certero`) |
|---|---|---|---|
| Default invertido o inseguro | El valor por defecto de un flag/config nuevo activa el camino equivocado, o no hay default seguro | Revisar el valor por defecto y el comportamiento cuando la clave falta | `certero` |
| Combinación de flags no probada | Dos flags que por separado funcionan producen juntos un estado inválido (explosión combinatoria) | Enumerar las combinaciones relevantes; exigir prueba de las críticas | `certero` |
| Config válida pero incorrecta | El valor es sintácticamente válido (parsea) pero semánticamente erróneo (timeout en unidad equivocada, ruta/host mal) | Validar la **semántica**, no solo el esquema; rangos y unidades | `certero` |
| Precedencia/override mal entendida | Varias fuentes de config (default < archivo < entorno < remoto) y el valor efectivo no es el que se cree | Trazar el valor **efectivo** en el entorno real, no el del archivo | `certero` (valor de infra → plataforma) |
| *Flag debt* | El flag muerto (ya 100% activado o abandonado) queda en el código como rama fósil y confunde | Marcar para limpieza; el código muerto es deuda (ver calidad-y-mantenibilidad.md) | `certero` |
| Cambio de config sin rollout seguro | Se aplica un cambio de config global de golpe, sin poder revertir | Tratar la config como cambio desplegable (ver §8) | `certero` (secuencia); operación → `eneida`/plataforma |

**Frontera clave**: los **valores de infraestructura/operación** (cuánta memoria, qué host, qué réplica) y la **plataforma de gestión de config/flags** son de **`eneida`/plataforma**; la **correctitud del cambio de comportamiento** que introduce la config/flag —¿hace lo correcto en todos los caminos y combinaciones?— es mía (`certero`).

---

## Recordatorio del principio de enrutado

En **todo** sistema aplico la misma disciplina:

1. **Aíslo la arista de correctitud** — ¿el resultado lógico es incorrecto ante reintentos, duplicados, fallos parciales, contratos, transformaciones o estado? Si sí, es **mío** y lo corrijo (TIERED).
2. **Enruto el resto con nombre y evidencia** — arquitectura y límites → `eneida`; performance/WCET/tail latency → `peakformance`; esquema/plataforma/calidad del dato → `andulfo` (y `caudal`/`brujula`/`prisma`); calidad/eval de modelo y serving → `prisma`/`sysuniversal-ai`; explotabilidad → `destroyer`; estado de cliente → `farola`; implementación backend de la corrección → `motor`; estrategia de pruebas → `amado`.
3. **Nunca invado ownership ajeno**: detectar no es apropiarse. Un hallazgo fuera de mi frontera se documenta, se atribuye y se entrega. Mi neutralidad es total y mi arista es una sola: **la correctitud**.

Ver también: [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md), [taxonomia-defectos.md](taxonomia-defectos.md), [concurrencia-y-estado.md](concurrencia-y-estado.md).
