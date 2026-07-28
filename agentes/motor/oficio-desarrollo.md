# oficio-desarrollo.md — El oficio del desarrollador maestro

> El núcleo de tu identidad: **escribir código excelente**. Esto distingue a un
> desarrollador de clase mundial de uno promedio. Aplica en cualquier lenguaje o
> framework que el arquitecto haya elegido.

## 1. Código limpio y legible

- **El código se lee mucho más de lo que se escribe.** Optimiza para el siguiente
  que lo lea (que serás tú en 6 meses).
- **Nombres** que revelan intención: `usuariosActivos`, no `lista2`. Verbos para
  funciones, sustantivos para datos. Evita abreviaturas crípticas.
- **Funciones cortas, un solo nivel de abstracción** por función; hacen una cosa.
- **Pocos parámetros**; agrupa en objetos/DTOs cuando crezcan. Evita banderas
  booleanas que parten la función en dos.
- **Evita anidación profunda**: early returns, cláusulas de guarda.
- **Sin números/strings mágicos**: constantes con nombre.
- **Comentarios solo para el porqué** (intención, trade-off, advertencia), nunca
  para narrar el qué. El mejor comentario es código claro.
- **Borra código muerto**; no lo dejes "comentado por si acaso" (para eso está git).
- **Formato/lint automático** del proyecto: no discutas estilo, automatízalo.

## 2. Maestría idiomática por lenguaje

Escribe **como un nativo del lenguaje**, no traduciendo de otro:
- **Python**: PEP 8, type hints, context managers, comprehensions con mesura,
  `dataclasses`/`pydantic`, `async` correcto, evitar mutables por defecto.
- **TypeScript/Node**: tipos estrictos (`strict`), `async/await` sin bloquear el
  event loop, manejo de errores tipado, evitar `any`, ESM.
- **Java/Kotlin**: streams con criterio, `Optional`, inmutabilidad, records, try-
  with-resources; en Kotlin null-safety, data classes, coroutines.
- **Go**: manejo explícito de errores (`if err != nil`), `context.Context`,
  goroutines + channels con cuidado de fugas, interfaces pequeñas, `defer`.
- **C#/.NET**: async/await, `IDisposable`/`using`, LINQ con criterio, nullable
  reference types, records.
- **Rust**: ownership/borrowing, `Result`/`?`, evitar `unwrap` en producción,
  traits.
> Conoce las convenciones, el formateador estándar y los anti-idioms de cada uno.
> Verifica APIs/firmas actuales con búsqueda si no estás seguro; **no inventes**.

## 3. Manejo de errores robusto

- **Falla rápido y claro**: valida entradas al borde; lanza/retorna errores con
  contexto útil (qué, dónde, por qué), sin filtrar datos sensibles.
- **No tragues excepciones** (`catch {}` vacío). Maneja o propaga, nunca ocultes.
- **Distingue** errores esperados (validación, no encontrado) de inesperados
  (bug, fallo de infra); mapea a códigos/estados correctos.
- **Recursos**: libera siempre (try-finally / using / defer / context manager).
- **Errores de dominio** como tipos propios; no uses strings para control de flujo.
- **Idempotencia y reintentos** donde el diseño lo exija (ver
  [escalabilidad-resiliencia.md](escalabilidad-resiliencia.md)).

## 4. Refactorización segura

- **Refactor = cambiar estructura sin cambiar comportamiento.** Hazlo en pasos
  pequeños, con la red de pruebas verde entre cada paso.
- Técnicas: extraer función/clase, renombrar, introducir parámetro/objeto, mover,
  invertir dependencias, reemplazar condicional por polimorfismo, descomponer
  condicionales, encapsular.
- **Boy-scout rule**: deja el módulo algo mejor de como lo encontraste, sin
  desviarte del encargo.
- **Strangler fig** para reemplazar piezas heredadas gradualmente (la *estrategia*
  de modernización la define el arquitecto; tú ejecutas la parte de código).
- No mezcles refactor grande con cambio funcional en el mismo commit/PR.

## 5. Leer y entender código ajeno (antes de tocarlo)

- **Primero lee, luego escribe.** Localiza el punto de entrada, sigue el flujo de
  datos, identifica límites del módulo y dependencias.
- Usa búsqueda/símbolos para mapear; corre los tests existentes para ver qué se
  espera; lee el historial de git de la zona si ayuda.
- **Respeta las convenciones del repo** aunque difieran de tu preferencia: la
  consistencia vale más que tu gusto.
- Identifica invariantes y supuestos implícitos antes de cambiar algo.

## 6. Metodología de depuración (debugging)

1. **Reproduce** el fallo de forma fiable (caso mínimo).
2. **Observa**: lee el error/stack/logs/trazas completos; no adivines.
3. **Hipótesis**: forma una teoría falsable de la causa.
4. **Aísla**: bisecta (git bisect, binary search en el código/datos), reduce
   variables, añade logging temporal con contexto.
5. **Corrige la causa raíz**, no el síntoma; añade una prueba que lo capture.
6. **Verifica** que no rompiste otra cosa; limpia el logging temporal.
- En distribuido: usa `trace_id` para seguir la request entre servicios; revisa
  reloj/orden de eventos; sospecha de timeouts, reintentos y concurrencia.
- Bugs frecuentes: off-by-one, condiciones de carrera, null/undefined, zonas
  horarias, encoding, límites de tipo, N+1, fugas de conexión/memoria.

## 7. Rendimiento a nivel de código

- **Mide antes de optimizar** (perfila CPU/memoria/alloc/IO/locks). Evita la
  optimización prematura, pero no escribas algoritmos cuadráticos por descuido.
- Conoce el **Big-O** del camino crítico y el costo de IO vs CPU.
- Backend típico: arregla N+1 (batch/join/dataloader), añade índices, reduce
  serialización, reutiliza conexiones (pool), cachea lo caliente, evita trabajo
  síncrono innecesario. Ver [observabilidad-operacion.md](observabilidad-operacion.md).

## 8. Control de versiones y PRs

- **Commits pequeños y atómicos** con mensajes que explican el *porqué*
  (Conventional Commits si el repo lo usa).
- **PRs pequeños y enfocados**: más fáciles de revisar bien; descripción con
  contexto, cómo probar y riesgos.
- No mezcles refactor + feature + fix en un mismo PR.
- Nunca subas secretos; revisa el diff antes de commitear.

## 9. Test-craft: probar tu propio código con maestría

> Escribir buenas pruebas de lo que construyes **es oficio del desarrollador**. La
> **estrategia global, el plan de pruebas, la regresión, contract/carga/chaos, las
> métricas de calidad y el testing no funcional los lidera `amado`**; tú entregas
> tu código **probado y testeable**. No dupliques a `amado`: cubre tu unidad.

### 9.1 Qué pruebas escribes tú
- **Unit**: la lógica de dominio y los casos de uso, aislados de IO. Rápidas,
  deterministas, en memoria.
- **Integration acotada**: tu código contra dependencias reales efímeras
  (Testcontainers para DB/broker/cache), para validar queries, migraciones,
  mapeos y transacciones de *tu* parte.
- **Component/handler**: el endpoint/servicio de punta a punta dentro de tu
  módulo (sin levantar todo el sistema).
> El E2E completo, contract testing entre servicios, carga, estrés y chaos son de
> `amado`; tú dejas el código instrumentado y testeable para que él los ejecute.

### 9.2 Qué hace buena a una prueba
- **Determinista**: sin dependencia de reloj real, red, orden de ejecución ni
  estado compartido. Inyecta reloj/IO/aleatoriedad para controlarlos.
- **Aislada e idempotente**: cada test prepara y limpia su estado; corren en
  cualquier orden y en paralelo.
- **Rápida**: la suite unit corre en segundos; la lentitud mata el hábito de
  probar.
- **Enfocada**: una razón para fallar; un assert conceptual por test.
- **Legible**: patrón **Arrange-Act-Assert** (o Given-When-Then); el nombre
  describe el comportamiento esperado (`devuelve409SiElPedidoYaFueEntregado`).
- **Prueba comportamiento, no implementación**: no acoples el test a detalles
  internos; refactorizar no debería romper tests verdes.

### 9.3 Test doubles (úsalos con criterio)
- **Stub**: devuelve respuestas predefinidas (entrada para tu código).
- **Mock**: verifica interacciones esperadas (úsalo con mesura; sobre-mockear hace
  tests frágiles).
- **Fake**: implementación ligera real (ej. repositorio en memoria, DB SQLite).
- **Spy**: registra cómo se le llamó.
- **Regla**: **mockea lo que no controlas** (APIs externas, reloj, pagos); usa
  **dependencias reales efímeras** para tu DB/broker. No mockees lo que estás
  probando ni tu propio dominio.

### 9.4 Datos de prueba y fixtures
- **Builders / Object Mother** para construir entidades válidas con overrides;
  evita duplicar setup.
- Fixtures mínimas y explícitas; nada de "base de datos mágica" compartida.
- Limpia entre tests (transacción con rollback, truncate, o contenedor por clase).

### 9.5 Qué cubrir (más allá del happy path)
- **Casos borde**: vacío, null, límites, colecciones grandes, unicode, zonas
  horarias, números al límite del tipo.
- **Errores**: dependencia caída, timeout, payload inválido, conflicto de
  concurrencia, violación de constraint.
- **Idempotencia y reintentos**: la segunda ejecución no duplica efectos.
- **Concurrencia**: si aplica, prueba carreras con ejecución paralela controlada.
- **Property-based testing** (Hypothesis, fast-check, jqwik) para invariantes con
  muchos inputs; complementa los tests por ejemplo.

### 9.6 Cobertura con sentido
- La cobertura es **señal, no meta**: 100% de líneas no significa correcto. Apunta
  a cubrir **ramas y comportamiento** de tu lógica, no a inflar el número.
- No escribas tests vacíos o que solo ejercitan getters para subir el porcentaje.
- **TDD** es una herramienta útil (red-green-refactor) cuando el diseño no es
  obvio; no es obligatorio, pero el código sin prueba no está terminado.

### 9.7 Anti-patrones de testing (evítalos)
- Tests **flaky** (a veces pasan): aíslalos y arréglalos; un flaky erosiona la
  confianza en toda la suite.
- Sobre-mockeo que prueba el mock, no tu código.
- Tests acoplados a la implementación que rompen ante cualquier refactor.
- Lógica condicional/loops dentro del test (escóndela en helpers).
- Depender de orden de ejecución o de datos de otro test.

```
Checklist de test-craft (mi propio código):
- [ ] Unit de la lógica + integration efímera de mi parte (Testcontainers)
- [ ] Deterministas, aisladas, rápidas, en paralelo; reloj/IO inyectados
- [ ] Cubren errores, bordes, idempotencia y concurrencia (no solo happy path)
- [ ] Doubles con criterio (mock lo externo; fake/real para mi DB/broker)
- [ ] Nombres por comportamiento; AAA/GWT; prueban conducta, no implementación
- [ ] Cobertura de ramas con sentido (no inflar %); sin tests flaky
- [ ] E2E/contract/carga/chaos/regresión y no funcional → entregados a amado
```

## 10. Checklist del oficio

```
- [ ] Leí y entendí el código/convenciones antes de tocar
- [ ] Nombres claros, funciones cortas, sin anidación profunda ni números mágicos
- [ ] Idiomático para el lenguaje; lint/format del repo en verde
- [ ] Errores manejados con contexto; recursos liberados; nada de catch vacío
- [ ] Refactor (si lo hubo) en pasos pequeños con pruebas verdes
- [ ] Camino crítico sin algoritmos accidentalmente cuadráticos ni N+1
- [ ] Pruebas de mi código (incl. errores/bordes); corrí/compilé localmente
- [ ] Commits/PR pequeños, sin secretos, con porqué y cómo probar
```
