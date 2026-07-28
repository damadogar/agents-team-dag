# Reproducción y prueba de regresión del fix

Para certero, **una corrección sin prueba no está terminada**: es una hipótesis. La
prueba que **falla antes del fix y pasa después** es la evidencia de que el
defecto existía, de que se entendió y de que se cerró de raíz. Este documento
define cómo reproducir un defecto como prueba, cómo blindar código heredado antes
de tocarlo, y —crucial— **dónde termina certero y empieza `amado`** para no pisar
la manguera de QA.

> Principio rector: **reproduce → test que falla → fix → test que pasa**. La
> prueba de regresión es la firma del corrector; la estrategia y la suite de
> calidad son de `amado`.

## 1. Frontera con `amado` (QA): quién es dueño de qué prueba

Ambos se relacionan con pruebas, pero con propósitos distintos. La línea es
nítida y **no negociable**:

| | **amado** (QA) | **certero** (Review & Debugging) |
|---|---|---|
| **Propósito de la prueba** | Verificar el sistema contra los requisitos; descubrir defectos ejercitándolo | Reproducir un defecto concreto y **probar que su fix lo cierra** |
| **Alcance** | **Estrategia, arquitectura, suite, cobertura, proceso y ejecución** de pruebas (unit/integration/e2e/exploratorio/no-funcional) | **El test puntual** que captura *este* defecto (falla→pasa) y los **tests de caracterización** que blindan lo que va a tocar |
| **Propiedad** | Dueño de la **suite de calidad** y de las metas de cobertura | Dueño de **la evidencia de su propio fix**, no de la suite |
| **Cuándo actúa** | Diseña y corre pruebas para encontrar y prevenir defectos a escala | Cuando corrige un defecto (propio, reportado por `amado`, o de producción) |

**Regla operativa:**
- certero escribe el test **mínimo** que reproduce el defecto y demuestra el fix.
  Ese test **acompaña al fix** (mismo cambio) como su prueba.
- Si el fix revela que la **suite necesita más cobertura**, una nueva **categoría
  de pruebas** o un cambio de **estrategia**, certero **se lo entrega a `amado`** con
  el caso; no absorbe la propiedad de la suite.
- certero puede **ubicar** su test siguiendo las convenciones de la suite de
  `amado` (para que conviva), pero la arquitectura y evolución de esa suite las
  decide `amado`.

> En una frase: **`amado` prueba el sistema; certero prueba su fix.** El test de
> regresión de certero es la evidencia de una corrección, no la política de calidad.

## 2. Reproducir el defecto como una prueba

La reproducción (ver [debugging y causa raíz](debugging-causa-raiz.md)) se
convierte en un artefacto ejecutable:

- **De la repro al test rojo.** Toma el escenario disparador mínimo (entrada,
  estado, orden) y codifícalo como una prueba que, ejecutada contra el código
  actual, **falla** exhibiendo el defecto (resultado incorrecto, excepción, cuelgue,
  corrupción).
- **Determinismo.** El test debe fallar **siempre**, no a veces. Elimina las
  fuentes de no-determinismo: tiempo, reloj, aleatoriedad, orden de iteración,
  concurrencia, red, sistema de archivos, entorno. Inyecta esas dependencias
  (reloj falso, semilla fija, orden forzado) para que el escenario sea repetible.
- **Minimización.** Reduce el caso al núcleo que dispara el bug (delta debugging):
  un test que falla por una razón clara vale más que uno grande y opaco.
- **La aserción correcta.** Afirma el **comportamiento esperado** (lo que *debería*
  pasar), no el buggy. Así el test es rojo ahora y verde tras el fix, y documenta
  la intención.

## 3. Probar defectos difíciles

| Tipo de defecto | Cómo reproducirlo en una prueba |
|---|---|
| Determinista | Caso directo con la entrada/estado que falla; aserción del resultado correcto |
| De borde | Tabla de casos límite (vacío, nulo, cero, negativo, máximo, unicode) — ver [taxonomía](taxonomia-defectos.md) |
| Regresión ("antes funcionaba") | Test que fija el comportamiento correcto previo; bisección para hallar el cambio culpable ([causa raíz](debugging-causa-raiz.md)) |
| Concurrencia / race | Estrés, inyección de scheduling, sanitizers de hilos, invariantes bajo ejecución concurrente — ver [concurrencia](concurrencia-y-estado.md) y [análisis dinámico](analisis-estatico-dinamico.md) |
| Intermitente / flaky | Aislar y hacer determinista la fuente oculta; si es un test flaky de la suite, coordinar con `amado` |
| Dependiente del entorno | Fijar/simular el factor de entorno (versión, locale, zona horaria, plataforma) |
| Basado en propiedades | Property-based/fuzzing para hallar la entrada que rompe un invariante ([análisis dinámico](analisis-estatico-dinamico.md)) |

## 4. Tests de caracterización (blindar antes de tocar)

Cuando hay que corregir o refactorizar **código heredado sin pruebas**, primero se
teje la red de seguridad:

- **Qué son.** Pruebas que capturan el comportamiento **actual** del código —aun
  el "incorrecto"— para detectar cualquier cambio no intencional al modificarlo.
- **Por qué.** Permiten distinguir el cambio **deliberado** (el fix) del
  **accidental** (la regresión). Sin ellas, tocar legacy es apostar.
- **Cómo.** Ejecuta el código con entradas representativas, observa las salidas
  reales y fíjalas como aserciones; luego refactoriza/corrige con la red puesta
  (ver [corrección y refactor](correccion-y-refactor.md) §4).
- **Frontera:** si la caracterización revela que falta una suite entera o una
  estrategia de pruebas para ese módulo, es trabajo de `amado`; certero deja la red
  mínima para corregir con seguridad y lo señala.

## 5. Verificación de no-regresión del fix

El test verde local no basta. Antes de dar por cerrada la corrección:

1. **Corre la suite afectada** (la de `amado`, si existe) y confirma que sigue
   verde; un fix que rompe otra prueba es una regresión.
2. **Revisa el radio de impacto** (llamadores, contratos, invariantes) con casos
   que ejerciten esos bordes ([corrección y refactor](correccion-y-refactor.md) §3).
3. **Deja la prueba como gate** de prevención: el test de regresión vive en la
   suite y en el [pipeline](revision-a-escala.md) para que la clase de defecto no
   pueda volver silenciosa.
4. Si el fix es un **handoff** (T2/T3), la prueba que falla→pasa **viaja con el
   parche** para que el dueño la ejecute y la mantenga (ver
   [interoperabilidad](interoperabilidad-y-aliados.md) §4).

## 6. Anti-patrones (prohibidos)

- Declarar un fix "resuelto" sin una prueba que falle antes y pase después.
- Escribir el test **después** del fix afirmando el comportamiento buggy (verde
  falso que no prueba nada).
- Un test no determinista que "a veces" atrapa el bug.
- Apropiarse de la suite o de la estrategia de cobertura de `amado`.
- Tocar código heredado sin red de caracterización.
- Entregar un handoff de fix sin la prueba que lo evidencia.

## 7. Revisión de la calidad de los tests que trae el PR (test smells)

Un test **es código**, y su correctitud es arista de `certero`. Cuando un cambio
llega con pruebas, `certero` no solo verifica que *existan*: verifica que **prueben
de verdad** lo que dicen. Un test verde que no prueba nada es peor que no tener
test — da una falsa sensación de seguridad y bloquea la detección de regresiones
reales.

> Frontera con `amado` (recordatorio de §1): la *estrategia*, la *arquitectura de
> la suite*, la *cobertura* y el *proceso* de QA son de `amado`. **Revisar la
> correctitud de un test concreto del diff** —¿afirma algo?, ¿puede fallar?— es de
> `certero`, igual que revisar cualquier otra línea de código del cambio. Si el
> hallazgo es "falta toda una categoría de pruebas o hay que rediseñar la suite",
> eso se entrega a `amado`.

Catálogo de *test smells* que `certero` caza en review:

| Test smell | Qué es | Por qué es un defecto | Cómo se corrige |
|---|---|---|---|
| **Test sin aserción** | Ejecuta código pero no verifica nada (o solo "no lanzó excepción") | Pasa siempre; no detecta ninguna regresión de valor | Afirmar el resultado/efecto esperado, no solo la ausencia de fallo |
| **Test tautológico** | La aserción repite la implementación (o usa la misma función para calcular esperado y obtenido) | Verde por construcción; no puede fallar aunque el código esté mal | Afirmar contra un valor esperado **independiente** y conocido |
| **Prueba del mock, no del código** | Verifica que se llamó a un doble de prueba, no el comportamiento real | Sobre-*mocking*: acopla el test a la implementación; no valida correctitud | Probar el efecto observable real; *mockear* solo las fronteras (reloj, red, disco) |
| **Aserción débil** | Comprueba menos de lo que importa (p. ej. "no es nulo" cuando debía valer 42; solo el *happy path*) | Deja pasar valores incorrectos y todos los bordes | Afirmar el valor exacto y los casos límite/error |
| **Dependencia de orden** | El test solo pasa si otros corrieron antes (estado compartido entre tests) | Falla o pasa según el orden; *flaky* encubierto | Aislar el estado; cada test se monta y limpia solo |
| **Espera por tiempo (`sleep`)** | Sincroniza con un `sleep` arbitrario en vez de con una condición | *Flaky* (lento o intermitente); frágil ante la carga | Esperar por la condición/evento, no por el reloj |
| **Test no determinista** | Depende de reloj real, aleatoriedad sin semilla, orden de iteración, red | Falla esporádicamente; erosiona la confianza en la suite | Inyectar reloj/semilla; controlar el no-determinismo (ver §2) |
| **Test que no puede fallar** | Condición imposible, `try/catch` que traga el fallo, aserción tras un `return` | No protege nada; ruido verde | Reescribir para que falle ante el defecto que debía cubrir |
| **Un test, mil cosas** | Verifica muchos comportamientos en un solo caso gigante | Cuando falla no dice *qué* se rompió; difícil de diagnosticar | Un comportamiento por test, nombre que describa el caso |

Prueba de fuego de un buen test (además de la §2): **debe poder fallar**. La
técnica canónica es la de este mismo documento —ver que el test **falla ANTES**
del fix y **pasa DESPUÉS**— y, para tests que acompañan un cambio sin bug previo,
la disciplina equivalente es el *mutation testing* como señal (ver
[análisis estático y dinámico](analisis-estatico-dinamico.md)): si mutar el código
no rompe ningún test, esos tests no lo están cubriendo.

---

**Relacionados:** [debugging y causa raíz](debugging-causa-raiz.md) ·
[corrección y refactor](correccion-y-refactor.md) ·
[análisis estático y dinámico](analisis-estatico-dinamico.md) ·
[interoperabilidad (frontera con `amado`)](interoperabilidad-y-aliados.md).
