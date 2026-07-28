# Review y calidad a escala enterprise

Revisar un archivo es artesanía; sostener la correctitud en un monorepo con
cientos de contribuidores y miles de cambios al día es **ingeniería de proceso**.
Este documento define cómo certero **escala** su disciplina: automatizando lo
objetivo en **gates de CI**, midiendo la calidad con métricas honestas, y
sembrando una **cultura de review** que previene clases enteras de defectos —
*shift-left*— en vez de cazarlos uno a uno.

> Principio rector: **automatiza lo objetivo, reserva el juicio humano para lo que
> lo necesita, y previene la clase de defecto en vez de perseguir la instancia.**

## 1. Gates de calidad en CI/CD (defender lo ganado)

Un estándar sin gate se erosiona. Lo que se puede verificar por máquina, se
verifica por máquina en cada cambio — de forma neutral (herramientas "p. ej.",
elegidas por ecosistema):

| Gate | Qué protege | Naturaleza |
|---|---|---|
| Formato / linter | Estilo y anti-patrones objetivos; elimina las guerras de estilo del review humano | Bloqueante barato |
| Type-check / análisis estático de correctitud | Nulabilidad, exhaustividad, contratos, dataflow (ver [análisis estático](analisis-estatico-dinamico.md)) | Bloqueante |
| Suite de pruebas | No-regresión funcional; incluye el **test de regresión** que acompaña cada fix | Bloqueante (suite propiedad de `amado`) |
| Umbrales de complejidad / tamaño de diff | Frena funciones inmantenibles y PRs gigantes | Advertencia o bloqueo suave |
| Denylist de anti-patrones | Prohíbe patrones peligrosos conocidos (p. ej. tragar excepciones, comparaciones inseguras) | Bloqueante configurable |
| Cobertura como señal | Detecta código nuevo sin prueba (señal, no meta ciega — ver [análisis dinámico](analisis-estatico-dinamico.md)) | Advertencia |

**Fronteras de los gates (no todo gate es de certero):**
- El **gate de seguridad** (SAST/dependencias vulnerables) lo gobierna `destroyer`;
  el **gate de performance** (perf budgets/regresiones) lo gobierna `peakformance`.
  certero coordina que convivan en el pipeline, pero no arbitra esas escalas.
- La **arquitectura de la suite** y las metas de cobertura son de `amado`; certero
  aporta el test de cada fix y ayuda a que el pipeline lo ejecute.
- La infraestructura del pipeline como plataforma es de su dueño (p. ej. `eneida`/
  plataforma); certero define **qué** verifica el gate de correctitud, no cómo se
  opera la infra.

**Anti-erosión:** un gate que da muchos **falsos positivos** se termina
ignorando. Cura las reglas, tríalas y ajústalas para que cada fallo del gate sea
una señal real (ver [análisis estático/dinámico](analisis-estatico-dinamico.md) §
integración).

## 2. Ownership del código y enrutado de reviews

- **CODEOWNERS / mapa de dueños.** Cada área tiene un dueño (`motor`, `farola`,
  `andulfo`…) que debe revisar/aprobar los cambios a su código. certero es un
  **revisor transversal de correctitud**, no el dueño de cada archivo.
- **Enrutado por disciplina.** Un cambio con aristas de varias disciplinas se
  revisa por varias manos: correctitud (certero), dominio (dueño), y —según el
  diff— seguridad (`destroyer`), performance (`peakformance`), datos (`andulfo`),
  arquitectura (`eneida`). Cada uno en su carril.
- **Aprobación mínima suficiente.** Ni un cuello de botella de un solo revisor ni
  un "aprobado automático": el número de revisores escala con el **riesgo** del
  cambio (ver §5).

## 3. Métricas de calidad (medir para mejorar, no para castigar)

Neutras, orientadas al sistema y nunca a señalar personas:

| Métrica | Qué indica | Cuidado |
|---|---|---|
| **Defect escape rate** | Defectos que llegan a producción vs los atrapados antes | La meta es reducir escapes, no ocultar reportes |
| **Change failure rate** (DORA) | % de cambios que causan fallo/rollback | Señal de calidad del proceso de entrega |
| **Tiempo de detección → corrección** (MTTR de defectos) | Qué tan rápido se cierra un defecto una vez visto | Bajo MTTR reduce el costo del bug |
| **Cobertura de review** | % de cambios que pasan por review efectivo | Cobertura ≠ calidad; el review debe ser real, no un sello |
| **Densidad de defectos por área** | Dónde se concentran los bugs (hotspots) | Guía dónde invertir prevención, no a quién culpar |
| **Reintroducción de defectos** | Bugs que vuelven tras "arreglarse" | Alto → fixes de síntoma, falta prueba de regresión |

Marcos de referencia: **DORA** (velocidad y estabilidad de entrega) y **SPACE**
(productividad multidimensional: satisfacción, rendimiento, actividad,
comunicación, eficiencia). Úsalos para diagnosticar el **sistema**, no para rankear
personas — las métricas mal usadas se corrompen (ley de Goodhart).

## 4. Shift-left: prevenir la clase, no cazar la instancia

Cada defecto atrapado tarde es más caro. certero empuja la calidad hacia el inicio:

1. **Estándares y convenciones escritos** (manejo de errores, invariantes,
   nulabilidad, contratos) para que el defecto no nazca.
2. **Gates locales** (pre-commit/pre-push, editor con linter/type-check) que
   atrapan antes de abrir el PR.
3. **Plantillas y checklists** de PR ([checklists](checklists.md)) que hacen visible
   lo que hay que verificar.
4. **Prevención de la clase:** cuando un defecto se corrige, pregunta *¿cómo evito
   toda esta familia?* — una regla de linter, un tipo que hace imposible el estado
   inválido, un test de caracterización, un cambio de API. Ese es el verdadero
   cierre (ver [corrección y refactor](correccion-y-refactor.md) §5–7).
5. **Post-mortem sin culpa** de los escapes graves, con acciones de prevención
   (ver [debugging y causa raíz](debugging-causa-raiz.md)).

## 5. Escalar la profundidad del review al riesgo del cambio

No todo cambio merece la misma lupa. Calibra el esfuerzo:

| Riesgo del cambio | Señales | Profundidad de review |
|---|---|---|
| Bajo | Cambio pequeño, aislado, con pruebas, en código no crítico | Review ligero + gates automáticos |
| Medio | Toca lógica de negocio, varios llamadores, o un borde delicado | Review completo por dimensiones ([checklists](checklists.md)) |
| Alto | Concurrencia, datos/persistencia, contratos públicos, migraciones, código crítico o sin pruebas | Review profundo + repro/tests + co-revisión con el dueño y la disciplina implicada |

El riesgo, no el tamaño, manda: un diff de una línea que cambia una condición de
autorización o un orden de locks es de **alto** riesgo.

## 6. Automatización asistida y su límite

- Linters, type-checkers, sanitizers y análisis asistido **amplifican** al
  revisor: filtran lo mecánico para que el juicio humano se enfoque en la lógica,
  los invariantes y el diseño.
- **Ninguna herramienta sustituye el juicio.** Los falsos positivos erosionan
  confianza y los falsos negativos dan falsa seguridad. El revisor tría, no
  obedece (ver [análisis estático/dinámico](analisis-estatico-dinamico.md) §límites).
- La automatización se **gobierna**: reglas versionadas, revisadas y con dueño; no
  un cajón de reglas que nadie mantiene.

## 7. Anti-patrones a escala (prohibidos)

- Gates con tantos falsos positivos que el equipo los ignora o los saltea.
- Review humano reducido a un "sello" sin lectura real.
- Métricas usadas para rankear o castigar personas.
- Cobertura como meta ciega (tests que ejecutan pero no afirman).
- Un único revisor cuello de botella para todo el repo.
- Perseguir instancias de un bug sin prevenir su clase.
- Absorber en el gate de certero lo que es gate de seguridad (`destroyer`) o de
  performance (`peakformance`).

> Las §8–§9 cubren dos **clases de cambio de alto volumen/riesgo** que el review a escala debe tratar explícitamente, más allá de los gates y métricas anteriores.

## 8. Cambios de gran escala (LSC) y codemods

Un **cambio de gran escala** (LSC: *large-scale change*) toca cientos o miles de
archivos a la vez — renombrar una API, migrar una firma, cambiar un import,
retirar un patrón deprecado en todo el monorepo. Auditar sitio por sitio a mano no
solo es inviable: es *menos* fiable que revisar la transformación, porque el ojo
humano se satura y deja pasar el sitio número 800. certero revisa estos cambios
como **ingeniería de proceso**, no como un diff gigante.

- **Shepherding y aprobación por ownership.** Un LSC no lo aprueba globalmente un
  solo revisor: se **conduce** (shepherd) de forma central, pero cada área lo
  aprueba por su **CODEOWNERS** (§2). El autor/pastor del cambio garantiza la
  transformación; los dueños (`motor`, `farola`, `andulfo`…) confirman que en su
  territorio no rompe invariantes locales. certero verifica la **correctitud de la
  transformación**, no reemplaza el consentimiento de cada dueño.
- **Rollout por olas, incremental y reversible.** Nada de un único commit
  monstruoso e irreversible. Se despliega en **olas** (p. ej. por paquete, por
  directorio, por servicio), cada ola verde en CI antes de la siguiente, y cada una
  **revertible por sí sola**. Si una ola rompe algo, se revierte esa ola sin
  arrastrar al resto. Preferir muchos commits mecánicos pequeños y homogéneos a uno
  colosal y heterogéneo.
- **Revisar el CODEMOD, no cada sitio.** Cuando el cambio es una **migración
  mecánica** producida por un codemod (p. ej. un script AST, un `sed` estructural,
  una regla de refactor de la herramienta del ecosistema), el objeto de review es
  la **transformación** y su cobertura de casos, no la copia número N. Verifica:
  (1) que el codemod es **correcto y determinista** para las formas que dice cubrir;
  (2) qué hace con los **casos que no encajan** — ¿los salta, los marca, o los
  rompe en silencio?; (3) una **muestra representativa de sitios** —incluidos los
  bordes: genéricos, macros, código generado, comentarios, strings, casos con
  formato raro— para confirmar que la salida es la esperada; y (4) que el **diff no
  mecánico** (los ajustes hechos a mano encima del codemod) va **separado y
  marcado**, porque ahí es donde se cuela el defecto de correctitud. La regla:
  confías en la máquina para lo uniforme y gastas el juicio humano en los bordes y
  en lo escrito a mano.
- **El diff genuinamente INSEPARABLE.** A veces un cambio grande **no se puede
  "solo dividir"**: un cambio de tipo o de contrato atómico que, partido, dejaría el
  árbol sin compilar o con un invariante roto entre commits. Ahí no se fuerza una
  división artificial; se hace **revisable de otra forma**: (a) **por capas** —
  separar el diff mecánico/generado del diff semántico, revisando cada estrato con
  su propia lente; (b) **por invariante** — organizar el review alrededor de las
  propiedades que deben seguir siendo ciertas (p. ej. "ningún llamador queda sin
  migrar", "la conversión preserva la semántica en los bordes") en vez de recorrer
  líneas; y (c) **co-revisión con el dueño** del área, porque un inseparable
  cruza-fronteras necesita a quien conoce los invariantes locales sentado al lado.
  Un inseparable es señal de riesgo **alto** (§5): merece repro, pruebas de
  caracterización y más de un par de ojos.

Ver [metodología de review](metodologia-revision.md) para cómo estructurar la
lectura de un diff por dimensiones e invariantes.

## 9. Revisión de cadena de suministro / dependencias (como correctitud)

> **Vista complementaria:** los footguns concretos por gestor (resolución transitiva y "diamantes", integridad del lockfile, incumplimiento de semver) están en [lenguajes-y-ecosistemas.md](lenguajes-y-ecosistemas.md) (Eje 9). Aquí el ángulo es **revisar el diff de dependencias como proceso a escala**; allá, el **idioma del ecosistema**. Frontera común en ambos: lo *explotable* (CVE/malware) → `destroyer`; el *cambio de comportamiento funcional* → `certero`.

Tu código puede no cambiar una sola línea y aun así **cambiar de comportamiento**
porque una dependencia debajo cambió. Eso es un **defecto de correctitud** y entra
de lleno en el carril de certero: no basta con revisar lo que *tú* escribiste;
también se revisa lo que tu árbol de dependencias **decidió por ti**.

- **Diffs de lockfile como diff de código.** El **lockfile** (p. ej. el manifiesto
  de versiones resueltas del ecosistema) es código: un cambio ahí es un cambio de
  comportamiento potencial. Revísalo — qué subió, de qué a qué, y por qué — con la
  misma seriedad que un diff fuente. Un lockfile que se mueve "solo" en un PR que no
  lo tocaba es una señal a explicar.
- **Saltos de versión y su semántica.** Lee los saltos con la lente de **semver**:
  un *patch* o *minor* no debería cambiar comportamiento observable, pero el
  **incumplimiento de semver** es común — una librería mete un cambio de conducta en
  un supuesto *patch*. Un *major* declara ruptura y exige revisar los sitios de uso.
  No confíes en el número: confía en el **changelog** y, ante la duda, en una prueba
  de caracterización del comportamiento que dependes.
- **Dependencias transitivas.** El riesgo no está solo en lo que declaraste, sino en
  lo que **tus dependencias arrastran**. Una transitiva puede saltar de versión sin
  que tu manifiesto directo cambie. Revisa el árbol resuelto, no solo la lista
  directa.
- **Integridad y provenance del lockfile.** Verifica que las entradas del lockfile
  conserven su **integridad** (hashes/checksums que fijan el artefacto exacto) y su
  **procedencia** — que lo que se resuelve es lo que se publicó, del origen
  esperado. Un lockfile sin integridad fija reintroduce no-determinismo: "en mi
  máquina otra versión".
- **Typosquatting y confusión de nombres.** Una dependencia nueva con un **nombre
  casi idéntico** al legítimo (una letra cambiada, un guion, un scope distinto) o
  una **confusión de dependencia** (interna vs pública) es un defecto de correctitud
  antes que nada: no es el paquete que creías. Revisa nombres nuevos en el diff de
  manifiesto con lupa.

**Frontera con `destroyer`.** Lo **explotable** —malware inyectado, una **CVE**
conocida, una cadena de suministro comprometida como vector de ataque— es del
carril de seguridad de `destroyer`; la **explotabilidad** de una dependencia no la
arbitra certero. Lo que certero cubre aquí es el **cambio de comportamiento
funcional**: la dependencia que, sin malicia, **rompe la correctitud** de tu
sistema (un default distinto, un redondeo cambiado, un orden de iteración que ya no
se garantiza, una API que ahora lanza donde antes devolvía). El typosquatting y la
provenance los mira certero como *"¿es el artefacto correcto y hace lo mismo?"*;
`destroyer` los mira como *"¿es un ataque?"*. Mismo diff, dos lentes, un handoff
limpio.

---

**Relacionados:** [metodología de review](metodologia-revision.md) ·
[análisis estático y dinámico](analisis-estatico-dinamico.md) ·
[gobernanza y ética](gobernanza-y-etica.md) · [checklists](checklists.md).
