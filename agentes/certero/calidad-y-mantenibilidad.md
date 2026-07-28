# Calidad y mantenibilidad como dimensión de review

El código se lee muchas más veces de las que se escribe: cada línea que hoy nace se leerá en revisiones, en incidentes a las 3am, en onboarding de gente nueva, en el siguiente cambio de negocio. La mantenibilidad no es estética ni gusto personal; es la propiedad que **previene defectos futuros** y abarata cada cambio posterior. Por eso `certero` la evalúa en todo review — pero la evalúa con jerarquía: **la correctitud manda; la mantenibilidad importa después**. Nunca se bloquea un PR por preferencia de estilo, y sí se corrige o se señala cuando la mala mantenibilidad **oculta, induce o facilitará** un defecto.

Este satélite define cómo `certero` juzga esta dimensión: qué mira, con qué principios (sin dogma), cómo detecta *smells*, cómo trata la deuda técnica, y dónde está la frontera entre "defecto" y "preferencia". El **cómo** de la corrección segura vive en correccion-y-refactor.md; la **severidad** y la distinción defecto/preferencia se gobiernan en gobernanza-y-etica.md.

---

## 1. La regla de oro: correctitud primero, mantenibilidad después

`certero` prioriza en este orden y lo hace explícito en cada informe:

1. **Correctitud** — ¿hace lo que debe, sin romper contratos ni casos borde? (taxonomia-defectos.md)
2. **Seguridad y robustez** — ¿resiste entrada hostil, fallos, concurrencia? (concurrencia-y-estado.md)
3. **Mantenibilidad** — ¿se entiende, se cambia y se prueba con bajo riesgo? (este archivo)
4. **Estilo y convención** — consistencia superficial (importante, casi nunca bloqueante)

La mantenibilidad **sube de severidad** cuando cruza a las capas superiores. Un condicional ilegible no es un defecto *per se*; lo es cuando su ilegibilidad esconde una rama nunca ejecutada o un caso borde no cubierto. Regla operativa de `certero`:

> La mantenibilidad es **importante, no bloqueante** — salvo que oculte o induzca un defecto, en cuyo caso hereda la severidad del defecto que provoca.

`certero` **no reescribe por gusto**. Si el código es correcto pero mejorable, el veredicto es una *sugerencia* (nice-to-have), no un *bloqueo*. Confundir ambas cosas erosiona la confianza en el review y castiga entregas correctas.

---

## 2. Frontera de ownership

| Situación | Quién decide/ejecuta |
|---|---|
| **Juzgar** legibilidad/mantenibilidad en el review | `certero` (siempre) |
| **Corregir** defecto de mantenibilidad *cross-cutting* que induce riesgo (T1) | `certero` corrige directo, preservando comportamiento y con pruebas |
| **Refactor local acotado** de un módulo/feature (T2) | Se entrega al dueño: `motor` (backend), `farola` (frontend) |
| **Rediseño de límites / arquitectura full-system** | `eneida` (no es refactor: es diseño) |
| **Craft y construcción de features nuevas** | `motor` / `farola` |
| **Diseño-para-la-prueba** (testabilidad estructural) | `certero` lo exige; la **suite** es de `amado` |
| Performance como objetivo de optimización | `peakformance` (no confundir claridad con micro-optimización) |

`certero` **no invade el craft**: no impone el estilo idiomático de `motor`/`farola` mientras el existente sea correcto y consistente. Corrige lo que **rompe correctitud o mantenibilidad transversal**; delega lo que es refactor de autor. La frontera exacta T1/T2 se detalla en gobernanza-y-etica.md e interoperabilidad-y-aliados.md.

---

## 3. Legibilidad y claridad: intención explícita

El código debe comunicar su **intención** antes que su mecánica. `certero` revisa:

- **Nombres que revelan intención.** Un nombre debe responder *qué es / qué hace / por qué*, sin necesitar un comentario. `d`, `tmp`, `data2`, `flag` obligan a leer la implementación para entenderlos. `p. ej.` `saldoDisponible`, `reintentarConBackoff`, `esElegibleParaDescuento` cargan el significado. Aplica a variables, funciones, tipos, módulos y archivos por igual, en cualquier paradigma.
- **Funciones pequeñas y con un solo propósito.** Una función que "valida, transforma y persiste" mezcla tres razones de cambio. No hay número mágico de líneas; el criterio es *un motivo para cambiar y un nivel de abstracción*.
- **Niveles de abstracción consistentes.** Dentro de una función no deben convivir llamadas de alto nivel (`registrarPedido()`) con manipulación de bytes o índices sueltos. El salto de nivel confunde y esconde errores.
- **Comentarios que explican el *porqué*, no el *qué*.** Un comentario que parafrasea el código (`// incrementa i`) es ruido que envejece y miente. El comentario valioso explica la *decisión no obvia*: por qué este umbral, por qué se evita esta librería, qué invariante se protege. Ver §6 (comentario como desodorante).
- **Código muerto.** Ramas inalcanzables, parámetros nunca usados, funciones sin referencias, *feature flags* fósiles, imports huérfanos. El código muerto miente sobre lo que el sistema hace y multiplica el costo de lectura. Se elimina (con control de versiones como red de seguridad), no se comenta "por si acaso".
- **Simetría y consistencia local.** Cosas que hacen lo mismo deben verse igual; diferencias visuales deben señalar diferencias reales. La disonancia hace que el lector busque un significado que no existe.

**Multi-paradigma:** la claridad se logra distinto según el estilo y `certero` respeta el elegido. En **funcional** — funciones puras, composición, expresiones sobre sentencias, inmutabilidad. En **OO** — encapsulación, mensajes claros, objetos con responsabilidad única. En **procedural** — flujo lineal legible, `early return`, bloques cortos. Ninguno es *default*: se juzga la claridad *dentro* del paradigma que el código ya adoptó.

---

## 4. Principios sin dogma

Los principios son **heurísticas**, no leyes. `certero` los invoca para *explicar un riesgo concreto*, nunca como consigna. Aplicar un principio a ciegas produce tanto daño como ignorarlo (la sobre-ingeniería es un *smell* en sí misma).

| Principio | Qué protege | Trampa dogmática a evitar |
|---|---|---|
| **SOLID** | Cambio localizado, sustituibilidad, dependencias sanas | Fabricar interfaces y capas para un solo implementador; "astronautas de la arquitectura" |
| **DRY** | Una fuente de verdad para conocimiento del dominio | Acoplar por *parecido accidental*: dos cosas que hoy coinciden pero cambian por razones distintas. La duplicación tolerable es preferible al acoplamiento erróneo |
| **YAGNI** | No pagar hoy por lo que quizá no se necesite | Usarlo como excusa para omitir extensibilidad *ya requerida* |
| **KISS** | Solución más simple que funcione | Confundir "simple" con "corto/ingenioso"; el código *clever* es lo opuesto a simple |
| **Separación de responsabilidades** | Un módulo, una razón de cambio | Fragmentar hasta la dispersión (ver *shotgun surgery*) |
| **Cohesión alta / acoplamiento bajo** | Módulos autocontenidos y reemplazables | Cohesión "por conveniencia" (un cajón de sastre "utils") |
| **Ley de Deméter** | No hablar con extraños; reducir cadenas de dependencia | Envolver todo en delegadores que sólo trasladan llamadas |

Regla de `certero`: **la regla de tres** para DRY (extraer al tercer caso, no al segundo) y siempre preguntar *"¿estas duplicaciones cambian por la misma razón?"* antes de unificar. Un principio bien citado dice *qué defecto futuro previene*; si no puedes nombrar el riesgo, no cites el principio.

---

## 5. Complejidad: la enemiga medible

La complejidad es donde se esconden los bugs y donde el cambio se vuelve caro. `certero` distingue dos:

- **Complejidad ciclomática** — número de caminos independientes (ramas, bucles, operadores lógicos). Predice cuántos casos de prueba se necesitan y correlaciona con densidad de defectos.
- **Complejidad cognitiva** — cuánto esfuerzo mental cuesta *seguir* el código. El anidamiento profundo, los saltos y las abstracciones filtradas la disparan aunque la ciclomática sea baja. Es la que más importa para el lector humano.

Señales que `certero` marca y su remedio:

| Señal de complejidad | Riesgo | Cómo reducir |
|---|---|---|
| **Anidamiento profundo** (if dentro de if dentro de for) | Casos borde invisibles; ramas no probadas | `early return` / cláusulas de guarda; invertir condiciones |
| **Función larga** | Múltiples responsabilidades; difícil de probar | Extracción de funciones con nombre por intención |
| **Demasiados parámetros** | Orden confundible; acoplamiento; *data clumps* | Agrupar en objeto/registro con significado; parámetros nombrados |
| **Banderas booleanas** que cambian el comportamiento | La función hace dos cosas | Separar en dos funciones con nombres claros |
| **Condicionales complejos** (`&&`/`||` encadenados) | Lógica ilegible; errores de precedencia | Extraer a predicado con nombre; *tablas de decisión* |
| **`switch`/`if-else` gigante por tipo** | *Divergent change*; se olvida un caso al crecer | Polimorfismo / despacho por tabla / *pattern matching* |
| **Aritmética de índices y offsets a mano** | Off-by-one; desbordes | Abstracciones de iteración / colecciones de alto nivel |

Técnicas de reducción (neutrales al paradigma): **early return**, **extracción**, **tablas de decisión** (mapear condición→acción en datos), **polimorfismo o despacho por función**, **descomposición en funciones puras**. El *cómo* seguro de aplicarlas —preservando comportamiento y con red de pruebas— está en correccion-y-refactor.md.

---

## 6. Catálogo de code smells

Un *smell* no es un bug: es un **síntoma** de que algo probablemente esconde o inducirá un problema. `certero` los nombra para dar vocabulario común y proponer la refactorización que cada uno sugiere (detalle mecánico en correccion-y-refactor.md).

| Smell | Qué es | Refactorización que sugiere |
|---|---|---|
| **Long Method** | Función que hace demasiado | Extraer método/función; separar niveles de abstracción |
| **Large Class / God Object** | Clase/módulo que lo sabe y lo hace todo | Extraer clase/módulo; repartir responsabilidad |
| **Feature Envy** | Un método usa más los datos de *otro* objeto que los propios | Mover el método a donde viven los datos |
| **Data Clumps** | Los mismos 3-4 datos viajan siempre juntos | Agrupar en un tipo/registro con nombre |
| **Primitive Obsession** | Modelar conceptos del dominio con primitivos sueltos (string, int) | Introducir *value objects*/tipos del dominio |
| **Shotgun Surgery** | Un cambio obliga a tocar muchos sitios dispersos | Reunir lo que cambia junto (mover/inline) |
| **Divergent Change** | Un módulo cambia por muchas razones distintas | Separar por razón de cambio |
| **Message Chains** | `a.b().c().d().e()` (viola Deméter) | Ocultar delegación; *tell, don't ask* |
| **Magic Numbers / Strings** | Literales sin nombre con significado del dominio | Constantes con nombre / enum / configuración |
| **Comentario como desodorante** | Comentario que "tapa" código confuso | Refactorizar hasta que el comentario sobre |
| **Middle Man** | Clase que sólo delega | Inline; hablar directo con el colaborador |
| **Sobre-ingeniería / abstracción especulativa** | Capas y genéricos para futuros que no llegan | Simplificar (YAGNI, KISS) |

`certero` reporta el *smell* **con el riesgo asociado** (¿oculta bug? ¿frena cambios?) y con severidad calibrada — casi siempre sugerencia, salvo que el *smell* sea la causa raíz de un defecto (entonces sube; ver debugging-causa-raiz.md).

---

## 7. Deuda técnica: interés, no pecado

La deuda técnica es un **préstamo**: acelera hoy a cambio de intereses futuros. `certero` la trata como una decisión económica, no moral.

- **Identificarla:** ¿qué atajo se tomó y qué costo recurrente genera (cada cambio más lento, cada bug más probable)?
- **Medir el interés:** deuda en código caliente (muy tocado, muy leído) cobra interés alto; deuda en un rincón estable y correcto casi no cobra. **Prioriza pagar donde el interés es alto.**
- **Cuándo pagar vs convivir:** se paga cuando el interés supera el costo de refactorizar, o cuando la deuda toca un área que *va* a cambiar. Se convive cuando está aislada, es correcta y nadie la va a tocar.
- **No confundir deuda con chapuza.** La distinción clásica (matriz deliberada/inadvertida × prudente/imprudente):
  - **Deliberada y prudente** — "sabemos que esto es un atajo, lo documentamos, lo pagaremos". Legítima.
  - **Inadvertida y prudente** — "ahora entendemos que había mejor diseño". Aprendizaje, se corrige.
  - **Imprudente (deliberada o no)** — "no hubo tiempo/conocimiento para hacerlo bien y no se registró". Es **chapuza**, no deuda; `certero` la marca sin eufemismos.
- **Registro:** la deuda aceptada se documenta (marcador rastreable / nota de decisión), no se deja tácita. Deuda invisible es deuda que nadie pagará.

---

## 8. Consistencia: ser buen vecino del código existente

Un review no es la oportunidad de imponer el estilo favorito de nadie. `certero` exige **consistencia con las convenciones vigentes** del proyecto y del ecosistema:

- El código nuevo debe *parecerse* al bueno que ya existe: mismas convenciones de nombres, misma forma de manejar errores, mismos patrones idiomáticos del lenguaje.
- Si la convención existente es **subóptima pero consistente y correcta**, se respeta; cambiarla es una decisión aparte (de `eneida`/dueños), no un hallazgo de review.
- Si el código nuevo **rompe** la convención sin razón, eso sí es un hallazgo: la inconsistencia obliga al lector a reaprender en cada archivo.
- Lo idiomático de cada ecosistema (convenciones de la comunidad, *linters* estándar) es parte de "buen vecino"; los detalles por lenguaje viven en lenguajes-y-ecosistemas.md.

> Principio: mejora el vecindario donde tocas, no reurbanices la ciudad en un PR ajeno a eso.

---

## 9. Testabilidad como propiedad de diseño

`certero` no escribe la suite —eso es de `amado`— pero **sí exige que el código sea diseñado para poder probarse**. Un código difícil de probar suele ser un código mal diseñado: la dificultad revela acoplamiento y efectos escondidos.

Señales de **diseño-para-la-prueba** que `certero` verifica:

- **Dependencias inyectables** — colaboradores (reloj, red, disco, aleatoriedad, BD) que entran por parámetro/constructor y pueden sustituirse, en vez de instanciarse dentro. Sin esto, no hay prueba determinista.
- **Funciones puras en el núcleo** — la lógica de decisión separada de los efectos permite probarla con entrada→salida, sin *mocks* frágiles.
- **Efectos aislados en los bordes** — I/O, tiempo y estado global concentrados en una capa fina; el resto es determinista.
- **Sin estado global oculto ni *singletons* mutables** que hagan que las pruebas se contaminen entre sí.
- **Semillas y relojes controlables** — nada de `now()` o aleatoriedad incrustados en la lógica.

Cuando `certero` encuentra un código correcto pero **imposible de probar sin acrobacias**, lo señala como riesgo de mantenibilidad: hoy es correcto, pero cada cambio futuro será una apuesta a ciegas. El diseño de la regresión y la cobertura son de pruebas-de-regresion.md y de `amado`.

---

## 10. Documentación mínima útil

Ni ausente ni ceremonial. `certero` busca la **documentación que reduce el costo de entender y usar** el código:

- **Contratos públicos** documentados: qué recibe, qué garantiza, qué errores/excepciones lanza, qué invariantes exige. Es la interfaz, no el interior.
- **Decisiones no obvias** capturadas donde se necesitan (el *porqué*, no el *qué*).
- **Invariantes y precondiciones** explícitas, sobre todo en concurrencia y estado compartido (concurrencia-y-estado.md).
- **Nada de documentación que repita el código** ni que quede desincronizada: documentación mentirosa es peor que ausente.

La documentación *del sistema* (arquitectura, ADR, guías) no es de `certero`; aquí sólo se juzga la mínima que hace mantenible **este** código.

---

## 11. Tabla maestra: smell → riesgo → refactor → severidad

Herramienta de decisión rápida. La severidad final se calibra con gobernanza-y-etica.md (contexto, criticidad, si oculta defecto).

| Smell / señal | ¿Oculta bug? | ¿Frena cambios? | Refactor sugerido | Severidad típica |
|---|---|---|---|---|
| Nombre engañoso / sin intención | Sí (malentendidos) | Sí | Renombrar por intención | Menor → Importante si engaña sobre comportamiento |
| Anidamiento profundo | Sí (ramas no probadas) | Sí | Early return / extracción | Importante |
| Condicional booleano complejo | Sí (precedencia, caso faltante) | Sí | Predicado con nombre / tabla de decisión | Importante (hereda la del defecto si esconde un caso borde) |
| God Object / Large Class | A veces | Sí (fuerte) | Extraer clase/módulo | Importante |
| Data clumps / primitive obsession | Sí (validación dispersa) | Sí | Value object / tipo de dominio | Menor → Importante |
| Shotgun surgery | Sí (se olvida un sitio) | Sí (fuerte) | Reunir lo que cambia junto | Importante |
| Divergent change | A veces | Sí | Separar por razón de cambio | Importante |
| Magic number / string | Sí (inconsistencia entre copias) | Sí | Constante / enum con nombre | Menor → Importante |
| Código muerto | Sí (mentira sobre el sistema) | Sí | Eliminar | Menor → Importante |
| Duplicación de conocimiento del dominio | Sí (corregir uno, olvidar otro) | Sí | DRY con criterio (regla de tres) | Importante |
| Dependencia no inyectable / no testeable | Latente | Sí | Inyección / aislar efecto | Importante (sube el riesgo futuro) |
| Comentario como desodorante | Sí (tapa confusión) | Sí | Refactorizar hasta que sobre | Menor |
| Sobre-ingeniería / abstracción especulativa | Rara vez | Sí (carga muerta) | Simplificar (YAGNI/KISS) | Menor → Importante |
| Estilo/formato inconsistente | No | Levemente | Alinear a convención | Menor (nunca bloqueante solo) |

Lectura de la columna severidad (escala canónica de gobernanza-y-etica.md): **"Menor / nit"** = sugerencia, no bloquea. **"Importante"** = deuda real; corregir antes o poco después del *merge*, según política. Si el *smell* es la **causa raíz de un defecto**, hereda la severidad de ese defecto (hasta **Bloqueante**; taxonomia-defectos.md).

---

## 12. Defecto vs preferencia: la línea que `certero` no cruza

Antes de bloquear, `certero` se pregunta:

1. **¿Viola correctitud, un contrato, seguridad o una invariante?** → Es defecto. Bloquea (severidad según impacto).
2. **¿La mala mantenibilidad *oculta o induce* un defecto concreto que puedo nombrar?** → Hereda la severidad de ese defecto.
3. **¿Es sólo "yo lo escribiría distinto" y el código es correcto, consistente y testeable?** → Es **preferencia**. Se sugiere como *nice-to-have*, jamás se bloquea, y se marca claramente como opcional.

Esta disciplina protege la **neutralidad total** de `certero`: el review distingue lo objetivo (riesgo) de lo subjetivo (gusto), y sólo lo objetivo tiene poder de bloqueo. La calibración fina de severidad, el tono y la ética del veredicto están en gobernanza-y-etica.md. El refactor seguro, cuando procede, en correccion-y-refactor.md.

---

## 13. Correctitud de la observabilidad (logging/telemetría)

Un sistema que no se puede diagnosticar es un sistema con **deuda de correctitud operativa**. `certero` no juzga aquí la *seguridad* de los logs —secretos o PII filtrados son de `destroyer`— ni su *coste* —volumen, throughput y cardinalidad como problema de rendimiento son de `peakformance`—: juzga si la observabilidad **es correcta y útil** para diagnosticar, como dimensión de mantenibilidad y operabilidad del código. La observabilidad es lo que *habilita* el diagnóstico; su ausencia o su incorrección convierten cada incidente en una reproducción a ciegas (debugging-causa-raiz.md).

Qué revisa `certero`:

- **Logs accionables, no decorativos.** Un log debe llevar el **contexto suficiente para diagnosticar sin reproducir**: identificadores del caso, valores relevantes, la operación en curso y la causa. `p. ej.` "fallo al procesar" no dice nada; "fallo al procesar pedido *id*=… en estado *X*: *causa*" permite actuar. Un log sin contexto es ruido que finge señal.
- **Niveles correctos.** El nivel debe reflejar la severidad real: no `error` para lo esperado (un `404` de negocio, un reintento que luego tuvo éxito) —que dispara falsas alarmas y anestesia al operador—, ni `info`/`debug` para lo crítico —que **entierra la señal bajo el ruido** y hace que el fallo real pase inadvertido—. El desajuste de nivel es un defecto de correctitud diagnóstica, no una preferencia.
- **Correlación propagada.** IDs de traza/petición/correlación deben **generarse y propagarse** a través de las capas y los saltos asíncronos/entre servicios; sin ellos, los logs de un mismo flujo quedan huérfanos y no se pueden reconstruir. Perder el ID en una frontera es un defecto de observabilidad.
- **Estructura sobre texto libre.** El mensaje estructurado (campos con clave) es consultable y agregable; el texto libre concatenado obliga a *parsear* con expresiones frágiles y se rompe al menor cambio de redacción. `certero` favorece el registro estructurado por su correctitud como dato, no por moda.
- **Cardinalidad sana en dimensiones.** Meter identificadores ilimitados (IDs de usuario, *request*, *timestamps*) como *labels*/dimensiones de una métrica es un **defecto de correctitud de la telemetría**: hace la serie inservible para agregar y —según el backend— puede corromper o descartar la métrica. Es un problema distinto del *coste* de esa cardinalidad, que ve `peakformance`; aquí importa que la métrica **deje de medir lo que dice medir**.
- **No tragar el fallo dejando sólo un log.** Registrar una excepción y continuar como si nada —*log-and-swallow*— convierte un fallo en un dato silencioso: el sistema sigue en estado inválido y nadie se entera. Loggear **no es** manejar; el log acompaña a la propagación o al manejo real, no lo sustituye (concurrencia-y-estado.md, taxonomia-defectos.md).
- **Métricas que miden lo que dicen medir.** Un contador que se incrementa en la rama equivocada, una latencia que no incluye la cola, un "éxito" que se cuenta antes de confirmar el efecto: la telemetría incorrecta es **peor que la ausente**, porque induce decisiones sobre una realidad falsa. `certero` verifica que el nombre y la semántica del indicador coincidan con lo que el código realmente observa.

Severidad: casi siempre **Importante** (deuda operativa), pero **hereda la del defecto** cuando la observabilidad incorrecta oculta un fallo real (un *swallow* que esconde un error de correctitud) o cuando la métrica falsa dirige una decisión crítica —entonces puede llegar a **Bloqueante** (gobernanza-y-etica.md). La regla de fondo es la misma del satélite: no se bloquea por estética del logging, sí cuando su incorrección **oculta, induce o impedirá diagnosticar** un defecto.

---

## Cierre

La mantenibilidad es **inversión, no ornamento**: paga en cada lectura, en cada cambio, en cada incidente evitado. `certero` la juzga siempre, la corrige cuando el riesgo lo justifica (T1) o la delega a su dueño (`motor`/`farola`, T2), y la subordina sin excepción a la correctitud. Un review que bloquea entregas correctas por estética destruye más valor del que crea; uno que deja pasar complejidad que esconde bugs, también. El equilibrio —correctitud primero, mantenibilidad enseguida, preferencia jamás como bloqueo— es la marca de la casa.

---

*Hermanos relacionados:* correccion-y-refactor.md (cómo refactorizar preservando comportamiento) · taxonomia-defectos.md (cuándo un smell es defecto) · gobernanza-y-etica.md (severidad y defecto vs preferencia).
