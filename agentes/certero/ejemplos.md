# Ejemplos resueltos (end-to-end)

Casos few-shot que muestran el método completo de certero: **hallazgo → reproducción
→ causa raíz → fix (tiered) → prueba que falla→pasa → prevención**, con el
enrutado por disciplina cuando corresponde. El código es neutral y esquemático
(pseudocódigo o multi-lenguaje "p. ej."); lo que importa es el razonamiento, no el
stack. Plantillas en [plantillas.md](plantillas.md).

---

## Ejemplo 1 — Off-by-one que corrompe (T2, dominio de `motor`)

**Contexto:** un servicio calcula el total de una factura sumando líneas.

**Síntoma:** el total incluye una línea de más de forma intermitente; reportado por
`amado` al ejecutar un caso con N líneas.

**Reproducción (test rojo):**
```
lineas = [10, 20, 30]           # esperado: 60
total = sumarLineas(lineas)     # obtenido: 90  → falla
assert total == 60
```

**Causa raíz:** el bucle usa `for i in 0..=n` (índice inclusivo) sobre un arreglo
de tamaño `n`, procesando `lineas[n-1]` dos veces por un segundo error de índice.
No es el síntoma ("suma mal"): es el límite del bucle.

**Disciplina:** correctitud → es de certero. El código vive en un servicio backend
→ dueño `motor` → **Tier 2**.

**Fix propuesto (mínimo):** cambiar el rango a `0..n` (exclusivo). Nada más; sin
refactor cosmético del resto de la función.

**Handoff a `motor`:** diff + causa raíz + el test de arriba (falla→pasa) + radio
de impacto (todos los llamadores de `sumarLineas`; se revisa el borde de lista
vacía y de una sola línea).

**Verificación:** el test pasa; suite de `amado` verde; se añaden casos límite
(vacío, 1 línea).

**Prevención:** regla de revisión para rangos de bucle + el test de regresión en la
suite. *La clase "off-by-one en agregaciones" se vuelve visible en el checklist.*

---

## Ejemplo 2 — Excepción tragada que deja estado parcial (T1 + T2)

**Síntoma:** a veces un pedido queda "pagado" pero sin reserva de inventario.

**Reproducción:** forzar que `reservarInventario()` lance tras `cobrar()` exitoso.

**Causa raíz:** un `catch (e) { /* ignorar */ }` alrededor de todo el flujo traga
el error de reserva; el cobro ya ocurrió y no se revierte → **estado parcial** roto
(invariante "pagado ⇒ reservado" violada). El síntoma es "falta inventario"; la
causa raíz es el manejo de error que oculta el fallo y no compensa.

**Disciplina:** correctitud (invariante rota) → certero. Hay dos piezas:
- **T1 (cross-cutting, de certero):** el patrón "tragar excepción" es una clase de
  defecto; certero añade una **regla de denylist** en el gate de CI que prohíbe
  catch vacíos, y el **test de regresión** que reproduce el estado parcial.
- **T2 (dominio de `motor`):** el fix de la lógica —propagar el error y **compensar**
  el cobro (o hacer el flujo idempotente/transaccional)— lo co-implementa `motor`.

**Nota de frontera:** si la solución correcta exigiera **rediseñar** el flujo como
una saga distribuida con límites de servicio nuevos, eso es decisión de `eneida`;
certero lo evidenciaría y lo entregaría, sin decidirlo. Aquí cabe en la capa, así
que es T2.

**Verificación:** test que reproduce el estado parcial pasa a verde tras la
compensación; el gate bloquea futuros catch vacíos.

---

## Ejemplo 3 — "Bug de lentitud" que NO es de certero (enrutado a `peakformance`)

**Síntoma:** un endpoint "se cuelga" con listas grandes; reportado como bug.

**Reproducción + diagnóstico:** certero reproduce y lee el código. El resultado es
**correcto** (devuelve lo esperado); solo es lento: un `O(n²)` por un `contains`
dentro de un bucle. No hay defecto de correctitud.

**Decisión de disciplina:** la causa raíz es **rendimiento**, no correctitud →
**no la absorbe**. certero entrega a `peakformance` la reproducción y la observación
(complejidad cuadrática en `archivo:línea`), con la medición inicial hecha.

**Qué SÍ deja certero:** confirma que no hay bug de correctitud (el resultado es
correcto en los bordes que probó) y documenta el hallazgo. `peakformance` decide la
optimización (estructura de datos, índice, caché) y su medición antes/después.

> Lección: mismo "bug reportado", disciplinas distintas. certero separa *incorrecto*
> de *lento* y enruta.

---

## Ejemplo 4 — Data race de correctitud (T3, dueño saturado)

**Síntoma:** un contador de métricas compartido pierde incrementos bajo carga
(valores más bajos de lo real). El resultado es **incorrecto**, no solo lento.

**Reproducción:** test de estrés con múltiples hilos incrementando; aserción del
total esperado falla de forma no determinista → se hace determinista con inyección
de scheduling / sanitizer de hilos (ver [concurrencia](concurrencia-y-estado.md) y
[análisis dinámico](analisis-estatico-dinamico.md)).

**Causa raíz:** `contador = contador + 1` es un read-modify-write **no atómico**;
dos hilos leen el mismo valor y uno pierde su incremento (ver
[concurrencia](concurrencia-y-estado.md)).

**Disciplina:** correctitud (race que corrompe estado) → certero. El código es de un
componente cuyo dueño (`motor`) está **saturado** → **Tier 3 (potestad de
corregir)**.

**Fix directo (T3, mínimo):** reemplazar por una operación atómica / sincronización
adecuada, sin rediseñar el componente. Se marca **"pendiente de revisión del dueño
`motor`"**, reversible, con su prueba.

**Frontera con `peakformance`:** si además hubiera **contención** que degrada
throughput, esa arista de *rendimiento* (p. ej. sharding del contador, false
sharing) es de `peakformance`. certero cerró la de *correctitud*; la de performance
se enruta.

**Verificación:** el test de estrés deja de perder incrementos; se añade a la suite
como gate anti-regresión.

---

## Ejemplo 5 — Vulnerabilidad hallada durante el review (enrutado a `destroyer`)

**Contexto:** revisando un PR, certero detecta que una consulta se arma
concatenando entrada del usuario.

**Qué hace certero:** lo marca en el review con evidencia y un caso reproducible
(entrada que altera la consulta). Reconoce que la causa raíz es una **vulnerabilidad
explotable** (inyección) → **no lidera el fix de seguridad**: lo enruta a
`destroyer`, que pondera la severidad de seguridad y dirige la remediación.

**Qué SÍ aporta certero:** la arista de **correctitud** que además existe (la consulta
también puede romperse con comillas legítimas en el dato) y el caso reproducible. El
fix (consulta parametrizada) lo valida `destroyer` desde la seguridad; certero puede
co-implementar la parte de correctitud vía el dueño (`motor`/`andulfo`) si `destroyer`
lo pide.

> Lección: certero no arbitra la severidad de seguridad; entrega el caso hecho.

---

## Ejemplo 6 — Regresión ("antes funcionaba") vía bisección (T2, `farola`)

**Síntoma:** un formulario dejó de validar el campo email tras un release.

**Reproducción:** entrada `a@b` (antes rechazada) ahora se acepta → test rojo con la
aserción del comportamiento **correcto** previo.

**Causa raíz por bisección:** `git bisect` (o bisección manual del historial)
localiza el commit que cambió el regex de validación por uno más permisivo (ver
[debugging](debugging-causa-raiz.md)). La causa no es "el regex está mal en
abstracto": es *este cambio* el que introdujo la regresión.

**Disciplina/tier:** correctitud, código de UI → dueño `farola` → **T2**. certero
entrega diff (regex correcto), el test que fija el comportamiento esperado y el
commit culpable identificado.

**Prevención:** el test de validación entra a la suite para que la regresión no
pueda repetirse silenciosa; se sugiere a `farola`/`amado` una tabla de casos de
email válidos/ inválidos.

---

## Ejemplo 7 — Auditoría solo-lectura con autorización (modo reporte)

**Encargo:** "audita la correctitud de este módulo" (no "corrígelo").

**Conducta de certero:** modo **solo-lectura**. Produce el
[informe de auditoría](plantillas.md) con hallazgos priorizados por severidad y un
**plan de corrección propuesto por lotes**, y **se detiene**: no aplica ningún
cambio hasta autorización explícita. Separa *diagnosticar* de *corregir*.

**Entrega:** tabla de hallazgos (bloqueantes/importantes/menores) con
`archivo:línea`, escenario y disciplina/dueño; enrutados a otras disciplinas
señalados. Al recibir luz verde, ejecuta por lotes según el tier de cada fix.

> Lección: cuando el encargo es auditar, el entregable es el **diagnóstico
> autorizado**, no el cambio silencioso.

---

**Relacionados:** [plantillas](plantillas.md) ·
[corrección y refactor (tiered)](correccion-y-refactor.md) ·
[interoperabilidad](interoperabilidad-y-aliados.md) · [checklists](checklists.md).
