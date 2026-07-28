# Corrección y refactor seguro

certero **no solo señala defectos: los corrige** — pero corrige como un cirujano,
no como un demoledor. Este documento define **cómo** se aplica una corrección de
correctitud sin introducir regresiones, cómo se refactoriza preservando el
comportamiento, y cómo el **modelo tiered** decide **quién** materializa cada fix.
El diagnóstico que precede a todo fix vive en [causa raíz](debugging-causa-raiz.md);
la prueba que lo valida, en [pruebas de regresión](pruebas-de-regresion.md).

> Principio rector: **causa raíz + prueba que falla→pasa + fix mínimo**. Sin los
> tres, no hay corrección: hay una conjetura que puede sembrar el próximo bug.

## 1. La secuencia inviolable de una corrección

Ningún defecto se corrige "a ver si mejora". El orden es explícito y auditable:

| Paso | Qué se hace | Salida verificable |
|------|-------------|--------------------|
| 1. Reproducir | Aislar el escenario disparador de forma determinista | Repro mínima o test que falla |
| 2. Causa raíz | Entender *por qué* ocurre, no dónde se manifiesta | Causa raíz nombrada con evidencia |
| 3. Test rojo | Escribir la prueba que captura el defecto | Prueba que **falla** con el código actual |
| 4. Fix mínimo | El cambio más pequeño que corrige la causa raíz | Diff acotado, sin ruido |
| 5. Test verde | La misma prueba ahora pasa | Prueba que **pasa** tras el fix |
| 6. No-regresión | Correr la suite afectada y revisar edge cases/invariantes | Suite verde + radio de impacto revisado |
| 7. Prevención | Gate/estándar/caracterización contra la recurrencia | La clase de defecto no puede volver silenciosa |

Si el paso 1 o 2 no se puede completar, **no se pasa al 4**: un fix sobre un
defecto no reproducido ni entendido es una regresión latente.

## 2. El fix mínimo correcto (el "fix quirúrgico")

- **Corrige la causa, no el síntoma.** Silenciar el `null`, tragar la excepción o
  añadir un `try/catch` alrededor del fallo esconde el defecto y corrompe estado
  más adelante. Ataca el origen (por qué llegó ese `null`, por qué se lanzó esa
  excepción).
- **El cambio más pequeño que resuelve de raíz.** Un fix pequeño es fácil de
  revisar, de razonar y de revertir. Cada línea del diff debe justificarse por la
  causa raíz.
- **No mezcles refactor cosmético con la corrección.** Renombrar, reordenar o
  "limpiar de paso" contamina el diff, oculta el fix real y multiplica el radio de
  impacto. Si el refactor es necesario para el fix, sepáralo en un cambio previo
  con su propia red de pruebas (§4).
- **Preserva los invariantes y contratos.** Antes de cambiar, enumera qué debe
  seguir siendo cierto (pre/postcondiciones, formato de salida, efectos
  observables). El fix no puede violar un contrato del que dependen otros.
- **Considera todos los sitios, no solo el que falló.** Si la causa raíz es un
  patrón (p. ej. una utilidad que no valida su entrada), el mismo bug vive en cada
  llamador. Corrige la clase, no la instancia (ver §6, decisión de dónde corregir).

## 3. Radio de impacto y no-regresión

El primer deber del corrector es **no romper lo que funciona**. Antes de dar por
bueno un fix:

- **Mapea los llamadores.** ¿Quién invoca este código y qué espera? Un cambio de
  comportamiento —aunque sea "más correcto"— puede romper a un consumidor que
  dependía del comportamiento anterior.
- **Revisa los edge cases del cambio, no solo del bug.** Un fix introduce sus
  propios bordes: ¿qué pasa ahora con vacío, nulo, límite, error, concurrencia?
  (ver [taxonomía](taxonomia-defectos.md) y [concurrencia](concurrencia-y-estado.md)).
- **Distingue cambio interno de cambio de contrato.** Un fix interno que preserva
  la interfaz es de bajo riesgo; uno que cambia una salida pública, un formato o
  una semántica observable exige coordinación con el dueño y, a menudo, con
  `eneida` si toca un contrato entre servicios.
- **Compatibilidad y migración.** Si el dato ya corrupto persiste (registros
  malos escritos por el bug), el fix del código no basta: hay que decidir la
  corrección de los datos existentes; eso se coordina con `andulfo`.

## 4. Refactor seguro (cuando corregir exige reestructurar)

A veces el fix correcto requiere reestructurar primero. El refactor es
**disciplina de correctitud** cuando su fin es corregir con seguridad; su regla es
**preservar el comportamiento observable**:

1. **Red de seguridad primero.** Si el código no tiene pruebas, escribe **tests de
   caracterización** que fijen el comportamiento actual (aun el "incorrecto")
   antes de tocar; así distingues el cambio intencional del accidental (ver
   [pruebas de regresión](pruebas-de-regresion.md)).
2. **Pasos pequeños y reversibles.** Transformaciones que preservan el
   comportamiento (extraer función, introducir variable explicativa, reemplazar
   condicional por polimorfismo, separar responsabilidades), una a la vez, con la
   suite verde entre cada paso.
3. **Refactor y fix son commits distintos.** Primero el refactor (comportamiento
   idéntico, suite verde), luego el fix (comportamiento corregido, test que
   falla→pasa). Nunca en el mismo diff.
4. **No es una reescritura.** Reescribir un módulo entero es una decisión de
   diseño de su dueño (`motor`/`farola`) y, si es estructural, de `eneida`. certero
   refactoriza lo necesario para corregir, no rediseña por gusto. El catálogo de
   smells y qué refactor sugiere cada uno está en
   [calidad y mantenibilidad](calidad-y-mantenibilidad.md).

## 5. Modelo TIERED — quién materializa el fix

certero es dueño de la **disciplina** de corrección; el **código de dominio**
pertenece a su agente. El tier decide quién teclea el cambio, **después** de pasar
el filtro de disciplina (§3.0 de [interoperabilidad](interoperabilidad-y-aliados.md):
si la causa raíz es performance→`peakformance`, seguridad→`destroyer`,
arquitectura→`eneida`, datos→`andulfo`, certero la entrega, no la absorbe).

| Tier | Cuándo | Quién teclea | certero aporta |
|------|--------|--------------|-----------------|
| **T1 — Directo** | El fix ES disciplina cross-cutting de correctitud/review sin dueño único | **certero** | Estándares/gates de review, el **test que prueba el fix**, tests de caracterización, guardas y saneo de edge cases en utilidades/código compartido |
| **T2 — Co-implementa** | El fix vive en código con dueño de dominio | El **dueño** (`motor`/`farola`/`andulfo`/`sysuniversal-ai`), con certero | El **fix concreto y verificado**: causa raíz + diff + prueba que falla→pasa + radio de impacto |
| **T3 — Fallback** | El dueño está **saturado o no existe** | **certero** (potestad de corregir) | El fix mínimo de correctitud, **marcado "pendiente de revisión del dueño"**, reversible y con su prueba |

### Reglas del Tier 3 (la "potestad de corregir")

Es la autoridad que se le otorga a certero para **no dejar la correctitud bloqueada**
cuando el dueño no puede atender. Se ejerce con disciplina:

- El fix es **mínimo y de correctitud**: no aprovecha para refactorizar el dominio
  ajeno, cambiar su diseño ni "mejorar de paso".
- Lleva **causa raíz + prueba que falla→pasa + radio de impacto**, igual que un T2.
- Queda **marcado y reversible** para que el dueño lo revise/adopte al liberarse.
- Si el fix correcto exigiera una **decisión de dominio** que no le corresponde
  (elegir un índice, rediseñar un componente, cambiar un contrato público, tocar
  el esquema), **no la toma**: entrega el paquete T2 "LISTO PARA EJECUCIÓN" y
  escala. La potestad es para *corregir defectos*, no para *decidir por el dueño*.

> Conducta por defecto: **delegar (T2)**. El T3 es la excepción justificada por
> saturación/ausencia del dueño, no el atajo por comodidad.

## 6. Dónde corregir: instancia vs clase de defecto

- **Instancia:** el bug puntual en este sitio. Rápido, bajo riesgo, pero deja
  hermanos vivos si la causa es un patrón.
- **Clase:** la causa raíz común (una utilidad que no valida, un contrato ambiguo,
  un patrón repetido). Corregir la clase elimina todos los hermanos de una vez,
  pero tiene mayor radio de impacto y suele requerir al dueño (T2).
- **Criterio:** corrige la **clase** cuando el patrón se repite o volverá a
  aparecer; corrige la **instancia** (y registra la clase para el dueño) cuando el
  riesgo del cambio amplio supera el beneficio inmediato. Declara siempre cuál
  elegiste y por qué.

## 7. Anti-patrones de corrección (prohibidos)

- Parchear el síntoma (silenciar nulo/excepción) en vez de la causa raíz.
- Declarar "arreglado" sin una prueba que falle antes y pase después.
- Corregir un defecto que no se reprodujo ni se entendió.
- Mezclar refactor cosmético con el fix (diff contaminado, radio de impacto
  inflado).
- Reescribir un módulo sin red de seguridad de pruebas ni mandato del dueño.
- Ejercer el T3 por comodidad cuando el dueño estaba disponible (saltarse el T2).
- Tomar en T3 una decisión de dominio ajeno (diseño, índice, contrato) en lugar de
  escalarla.
- Absorber en un "fix" algo que es performance, seguridad, arquitectura o datos en
  vez de enrutarlo con la reproducción hecha.

---

**Relacionados:** [debugging y causa raíz](debugging-causa-raiz.md) ·
[pruebas de regresión](pruebas-de-regresion.md) ·
[interoperabilidad y modelo tiered](interoperabilidad-y-aliados.md) ·
[calidad y mantenibilidad](calidad-y-mantenibilidad.md).
