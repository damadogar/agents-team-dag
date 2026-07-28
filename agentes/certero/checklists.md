# Checklists operativos de code review y cierre

Casilleros reutilizables para revisar cambios, cazar defectos, corregir con seguridad y cerrar con veredicto. Copia el bloque que aplique, márcalo `[x]` a medida que avanzas y adjunta la evidencia. Ninguna casilla asume lenguaje, framework, motor ni herramienta: sustituye los ejemplos (`p. ej.`) por tu contexto real.

Estos checklists operacionalizan lo que definen los hermanos de metodología y taxonomía. Cuando una casilla toca fuera de la CORRECTITUD (performance, seguridad, arquitectura, datos, suite de pruebas), la casilla NO es "arréglalo tú": es "enrútalo a su dueño" y sigue el modelo tiered.

---

## Cómo escalar la profundidad según el riesgo

No todos los cambios merecen la misma profundidad. Calibra ANTES de abrir el review:

- [ ] **Riesgo bajo** (cambio local, sin estado compartido, sin datos ni contratos): pasa el bloque 1 (PR/diff) y el bloque 4 (corrección segura) si tocas algo.
- [ ] **Riesgo medio** (lógica de negocio, manejo de errores, cambios en contratos internos): añade el bloque 2 (correctitud por dimensión) y el bloque 6 (enrutado/frontera).
- [ ] **Riesgo alto** (concurrencia, dinero/salud/seguridad de vida, migraciones de datos, APIs públicas, rutas críticas): ejecuta TODOS los bloques, con doble revisión y bisección si hubo regresión.
- [ ] **Ante la duda, sube un nivel.** El costo de un checklist extra es minutos; el de un defecto en producción, no.

> El riesgo lo marca el radio de impacto y la reversibilidad, no el tamaño del diff. Un cambio de una línea en una condición de guardia puede ser de riesgo alto.

---

## 1. Checklist de review de un PR/diff

Recórrelo de arriba abajo. Si una casilla no aplica, márcala N/A explícitamente (no la borres).

- [ ] **Contexto e intención**: entiendo QUÉ problema resuelve el cambio y POR QUÉ así; el diff hace lo que dice el título/descripción y nada más.
- [ ] **Correctitud**: la lógica produce el resultado esperado para el caso feliz y para los casos declarados (ver bloque 2).
- [ ] **Edge cases**: vacío, uno, muchos; límites inferior/superior; entradas inesperadas; primer/último elemento; colecciones nulas o parciales.
- [ ] **Manejo de errores**: los fallos se detectan, propagan o traducen correctamente; nada se traga en silencio; mensajes accionables; no se pierde el contexto del error original.
- [ ] **Concurrencia/estado**: si hay estado compartido, asincronía o paralelismo, aplico el bloque 5.
- [ ] **Recursos**: conexiones, archivos, handles, memoria y bloqueos se liberan en todos los caminos (incluido el de error).
- [ ] **Contratos/API**: firmas, formatos, códigos de estado, nulabilidad y compatibilidad hacia atrás se respetan; los consumidores existentes no se rompen. Si es un cambio de contrato estructural, señalarlo a `eneida`.
- [ ] **Tests que acompañan el cambio**: el diff trae pruebas que ejercitan el nuevo comportamiento y sus bordes; si faltan o el diseño de la suite es dudoso, coordinar con `amado` (dueño de la suite).
- [ ] **Legibilidad/mantenibilidad**: nombres claros, complejidad justificada, sin duplicación gratuita, sin código muerto (ver calidad-y-mantenibilidad.md).
- [ ] **Consistencia con el ecosistema**: sigue los idiomatismos, convenciones y patrones del proyecto y del lenguaje (ver lenguajes-y-ecosistemas.md).
- [ ] **Sin secretos ni datos sensibles**: no hay credenciales, tokens ni PII embebidos, logueados o commiteados. Si detecto un patrón de riesgo de seguridad → **enrutar a `destroyer`** (no lo corrijo yo por criterio de seguridad).
- [ ] **Sin regresión de performance evidente**: no introduce un patrón obviamente costoso (p. ej. trabajo repetido dentro de un bucle caliente, acceso N+1). Si el impacto es de rendimiento real → **enrutar a `peakformance`** para diagnóstico y optimización.

---

## 2. Checklist de correctitud por dimensión

Marca defectos por categoría. Enlaza cada hallazgo con su clase en taxonomia-defectos.md.

- [ ] **Lógica**: condiciones (`&&`/`||`, negaciones), comparadores (`<` vs `<=`), operadores invertidos, ramas faltantes, `switch` sin caso por defecto.
- [ ] **Bordes numéricos**: overflow/underflow, división por cero, redondeo y precisión (p. ej. flotantes en dinero), off-by-one, unidades y conversiones.
- [ ] **Nulos/ausencia**: valores nulos, opcionales vacíos, claves inexistentes, colecciones vacías vs no inicializadas; desreferencias no protegidas.
- [ ] **Errores**: rutas de fallo no cubiertas, excepciones tragadas, reintentos sin límite, fallo parcial que deja estado inconsistente.
- [ ] **Recursos**: fugas, doble liberación, uso tras cierre, agotamiento de pools, ausencia de timeout.
- [ ] **Invariantes**: precondiciones/postcondiciones violadas, estado que no cumple sus reglas tras la operación, validaciones ausentes en la frontera.
- [ ] **Datos/serialización**: (de)serialización, codificación de caracteres, zonas horarias, formatos de fecha, truncamiento, mapeo campo a campo. Si toca modelo/persistencia/integridad de datos → coordinar con `andulfo`.

---

## 3. Checklist de debugging / causa raíz

Antes de proponer cualquier fix. Detalle en debugging-causa-raiz.md.

- [ ] **Reproducido**: tengo un caso mínimo y determinista que dispara el defecto de forma fiable.
- [ ] **Hipótesis falsable**: formulé una explicación concreta que una prueba puede refutar (no "creo que es por aquí").
- [ ] **Causa raíz vs síntoma**: distingo el defecto real del punto donde se manifiesta; no estoy parcheando el síntoma.
- [ ] **Bisección si es regresión**: si antes funcionaba, aíslo el cambio que lo introdujo (por versión, por commit, por configuración).
- [ ] **Radio de impacto**: sé qué más comparte esta causa raíz (otras rutas, otros llamadores, datos ya corrompidos) y qué hay que revisar o remediar además del punto encontrado.

---

## 4. Checklist de corrección segura

Aplica al proponer o aplicar el fix. Detalle en correccion-y-refactor.md.

- [ ] **Fix mínimo**: corrige la causa raíz con el menor cambio suficiente; nada de reescrituras oportunistas.
- [ ] **Sin refactor cosmético mezclado**: el diff de la corrección no arrastra renombrados, reformateos ni limpieza no relacionada (esos van aparte).
- [ ] **Prueba que falla → pasa**: existe una prueba que reproduce el defecto y falla ANTES del fix y pasa DESPUÉS; el diseño de la prueba se acuerda con `amado` si toca la suite formal.
- [ ] **Edge cases e invariantes**: la corrección cubre los bordes de la causa raíz y restablece las invariantes violadas, no solo el caso reportado.
- [ ] **Sin regresión**: la suite existente sigue verde; verifico las rutas del radio de impacto del bloque 3 (ver pruebas-de-regresion.md).
- [ ] **Tier/ownership correcto**: identifiqué a quién pertenece el dominio del fix y respeté la frontera (ver bloque 6).
- [ ] **Marcado si es T3**: si corrijo directo dentro del dominio de otro dueño (`motor`/`farola`/`andulfo`/`sysuniversal-ai`) por saturación o ausencia, dejo constancia explícita del handoff para revisión posterior por el dueño.

---

## 5. Checklist de review de concurrencia

Solo si hay estado compartido, asincronía, hilos o paralelismo. Detalle en concurrencia-y-estado.md.

- [ ] **Estado compartido mutable**: identifico todo estado accesible por más de un flujo; ¿está protegido o es inmutable?
- [ ] **Atomicidad**: las secuencias leer-modificar-escribir son atómicas; no hay condiciones de carrera de "check-then-act".
- [ ] **Orden de locks**: los bloqueos se toman siempre en el mismo orden; no hay ciclo que permita deadlock; sección crítica mínima.
- [ ] **Visibilidad**: los cambios hechos por un flujo son visibles para otro (barreras/publicación correcta); nada asume orden de memoria sin garantía.
- [ ] **Async esperado**: toda operación asíncrona se espera o se gestiona su finalización; sin promesas/tareas huérfanas, sin fugas de contexto, sin fallos silenciosos en background.

---

## 6. Checklist de enrutado / frontera

`certero` es dueño de la CORRECTITUD, no de todo. Antes de tocar nada, clasifica:

- [ ] **¿Es correctitud?** (comportamiento incorrecto, defecto lógico, regresión funcional) → es mío; sigo T1/T2/T3.
- [ ] **¿Es performance?** (lento pero correcto, uso de recursos, escalabilidad) → **`peakformance`**.
- [ ] **¿Es seguridad *explotable*?** (vulnerabilidad, exposición de datos, **explotabilidad** del control de acceso, secretos) → **`destroyer`**. *(La **correctitud lógica** de una regla de autorización —predicado invertido, o regla que niega acceso a legítimos— aunque NO sea explotable, es correctitud de `certero`.)*
- [ ] **¿Es arquitectura?** (límites de servicio, acoplamiento estructural, decisión de diseño macro) → **`eneida`**.
- [ ] **¿Es datos?** (modelo, esquema, integridad, migraciones, consultas/índices) → **`andulfo`**.
- [ ] **¿Es la suite de pruebas?** (estrategia, cobertura, diseño de casos, automatización) → **`amado`**.
- [ ] **Decisión de tier**: T1 (cross-cutting, lo corrijo yo) / T2 (entrego el fix listo al dueño de dominio: `motor`, `farola`, `andulfo`, `sysuniversal-ai`) / T3 (corrijo directo SOLO si el dueño está saturado o ausente, y lo marco).
- [ ] **Handoff explícito**: para cada ruta a otro agente, dejo un paquete accionable (contexto, evidencia, hallazgo, severidad), no solo un "revisen esto" (ver interoperabilidad-y-aliados.md).

---

## 7. Checklist de cierre

Antes de dar por terminado el review:

- [ ] **Veredicto**: emito una decisión clara — **aprobar** o **bloquear** — con justificación; nada de aprobaciones ambiguas.
- [ ] **Hallazgos por severidad**: cada hallazgo clasificado con la escala canónica (Bloqueante / Importante / Menor·nit; ver gobernanza-y-etica.md) con ubicación y evidencia.
- [ ] **Handoffs**: registrados todos los enrutados del bloque 6, con su destinatario y estado.
- [ ] **Prevención / gate**: propongo cómo evitar que esta clase de defecto reaparezca (p. ej. prueba de regresión, verificación estática, casilla nueva en este checklist) — ver gobernanza-y-etica.md.
- [ ] **Próximos pasos**: claros y con dueño; nada queda "en el aire".
- [ ] **Neutralidad y respeto de fronteras verificados**: no invadí dominios ajenos, no impuse herramienta/lenguaje por gusto, y las correcciones T3 quedaron marcadas.

---

*Hermanos relacionados:* metodologia-revision.md · taxonomia-defectos.md · correccion-y-refactor.md
