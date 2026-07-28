# Changelog — certero (Primer Maestro de Code Review & Debugging)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.5.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-etica.md`: referencia a `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates, escalamiento y los momentos exactos en que se debe consultar).

### Notas
- Adición aditiva: no cambia frontmatter, RACI ni ningún contenido existente de este archivo. Parte del rollout del protocolo de equipo (canario: orquesta).

## [1.4.1] — 2026-07-12

### Added
- **`baluarte`** cableado en `interoperabilidad-y-aliados.md` (tabla de
  enrutamiento por capa y tabla §5 de invocación cruzada): frontera correctitud del
  código ↔ plataforma/pipeline (certero define los gates de correctitud que corren
  en el pipeline; baluarte diseña/opera el pipeline; un fallo cuya causa raíz es de
  plataforma/config/despliegue va a baluarte).

### Notas
- sin cambio de objetivo (Code Review & Debugging).

## [1.4.0] — 2026-07-09

### Added / Fixed — 4ª ronda de QA (4 revisores solo-lectura) — cierre
Auditoría de v1.3.0 en 4 dimensiones (coherencia/relación entre archivos, índice
maestro, completitud/nivel mundial, greenfield/brownfield + sesgo + relación con el
equipo), con los revisores instruidos a **no inventar hallazgos**. Veredicto:
**coherente, completo e integral de clase mundial, universal, neutral, fronteras
íntegras**; convergencia confirmada. Solo dos ítems, ambos menores; autorizados:

- **N1 (consistencia):** completado el puntero **§2→§8** en `dominios` (antes solo
  existía §8→§2); el enlace §2↔§8 es ahora efectivamente **recíproco**.
- **B1 (endurecimiento):** **recuperación ante caída abrupta (crash-consistency)**
  como gemelo del apagado ordenado — escrituras a medias (torn/partial writes),
  orden de durabilidad, y replay **idempotente** de journal/WAL a un estado válido
  en el arranque (`concurrencia` §5). Frontera: física de durabilidad (fsync/
  barreras) → `andulfo`; orquestación de la recuperación → `eneida`; correctitud de
  no-corromper y recuperar a un estado válido → `certero`. Índice §0/§10 de
  `SKILL.md` actualizado.

Verificado: 16 satélites (sin archivos nuevos), enlaces cruzados resuelven, sin
frontmatter en satélites, sin FLIT, sin sesgo, sin deslices de tier/ownership,
numeración coherente. Los junctions ya propagan.

## [1.3.0] — 2026-07-09

### Added / Fixed — 3ª ronda de QA (4 revisores solo-lectura) + cierre de asimetría de frontera
Auditoría de v1.2.0 en 4 dimensiones (coherencia y **relación entre archivos**,
índice maestro, completitud/nivel mundial, greenfield/brownfield + sesgo +
fronteras). Veredicto: **coherente, completo, universal, neutral**; el índice "el
mapa corresponde al territorio" (18 capacidades anunciadas, cero sobre-afirmación,
cero huecos); 0 enlaces rotos, 0 satélites huérfanos; sin hallazgos bloqueantes.
Autorizado por el usuario (con la condición de no introducir regresiones):

- **Lote A (consistencia):** `docpower` añadido al **roster de colaboradores** del
  SKILL (frontmatter, cuerpo, §2.1) — ya figuraba en `interoperabilidad` §5;
  **sufijo de enrutado** en la fila "flag/rollout sin reversión" (`dominios` §8:
  reversibilidad lógica → `certero`, mecanismo/operación de rollback →
  `eneida`/plataforma); **enlace recíproco §2↔§8** en `dominios`.
- **Lote B (refinamientos de élite):** **correctitud lógica de la autorización/
  control de acceso** — cierra la última asimetría del marco: un predicado de authz
  lógicamente incorrecto pero **no explotable** (un `&&`/`||` invertido, o una regla
  que niega acceso a legítimos) es correctitud de `certero`, mismo split que en
  memoria y TOCTOU; solo la explotabilidad es de `destroyer` (`taxonomia` §1,
  `interoperabilidad` §3.0, `checklists` §6). **Apagado ordenado / graceful
  shutdown** y ciclo de vida (`concurrencia` §5). **Inyección de fallos** como
  técnica nombrada de verificación del camino de error (`analisis` §B.4). **Máquina
  de estados como lente transversal**, no solo en embebido (`taxonomia` §7). Índice
  §0/§10 de `SKILL.md` actualizado para hacer descubribles las cuatro.

Verificado: 16 satélites (sin archivos nuevos), todos los enlaces cruzados
resuelven, sin frontmatter en satélites, sin FLIT, sin sesgo, sin deslices de
tier/ownership, numeración coherente (`analisis` §A–§H con §B.1–§B.4). Los
junctions ya propagan (no hizo falta re-globalizar).

## [1.2.0] — 2026-07-09

### Added / Fixed — 2ª ronda de QA final (5 revisores solo-lectura) + refinamientos de élite
Auditoría integral de v1.1.0 en 5 dimensiones (coherencia entre archivos, índice
maestro de SKILL.md, completitud/nivel mundial, greenfield/brownfield + sesgo/
universalidad, relación con el equipo). Veredicto de los revisores: **sólido,
universal, neutral y con fronteras consistentes; sin hallazgos bloqueantes**.
Correcciones y adiciones autorizadas por el usuario:

- **Lote A (índice + consistencia):** el **índice maestro** de `SKILL.md`
  (tabla §0, §10, disparadores §2, frontera §2.1 y frontmatter) ahora hace
  **descubribles** las ~11 capacidades añadidas en v1.1.0 (código-IA, MC-DC/
  métodos formales/metamorphic, safety-critical, linearizabilidad, aislamiento
  transaccional, test smells, LSC, cadena de suministro, estabilidad numérica,
  observabilidad) — la matriz de 13 disciplinas y la lista de 16 satélites quedan
  intactas; **enlaces cruzados recíprocos** de cadena de suministro entre
  `revision-a-escala` §9 y `lenguajes-y-ecosistemas` (Eje 9); refs internas
  corregidas (`D.4`→`A.4` en `analisis` §G.1; `§8`→`§6` en `calidad` §3);
  **`prisma`** alineado (cuerpo del SKILL + fila propia en `interoperabilidad` §5);
  **frontera con `docpower`** añadida (comentario que miente sobre el código =
  correctitud del comentario; la forma documental es de docpower); transiciones
  ante las secciones nuevas de `concurrencia` y `revision-a-escala`.
- **Lote B (refinamientos de élite):** **correctitud durante el rollout / versiones
  que coexisten** y migraciones **expand-contract** (`dominios` §8, frontera
  deploy→`eneida`, DDL/plan→`andulfo`, secuenciación→`certero`); **cambios de
  config y feature flags** como clase de cambio de alto riesgo (`dominios` §9);
  **problema ABA + reclamación segura** lock-free (hazard pointers/EBR/RCU) en
  `concurrencia` §13; **inversión de prioridades** (`dominios` §5, tiempo real);
  **correctitud de expresiones regulares** (`taxonomia` §8, ReDoS→`peakformance`/
  `destroyer`); **invalidación de caché** como clase nombrada (`taxonomia` §7).

Verificado: 16 satélites (sin archivos nuevos), todos los enlaces cruzados
resuelven, sin frontmatter en satélites, sin FLIT, sin sesgo, sin deslices de
tier/ownership, numeración de secciones coherente. Los junctions ya propagan (no
hizo falta re-globalizar).

## [1.1.0] — 2026-07-09

### Fixed / Added — Ronda de QA (4 revisores solo-lectura) + endurecimiento
Auditoría de la v1.0.0 con 4 revisores independientes (tier/ownership, coherencia,
completitud nivel mundial, sesgo/universalidad). Veredicto: frontera y neutralidad
**sólidas** ("ningún deslice bloqueante"; "de los agentes más rigurosamente
neutrales"). Correcciones y adiciones autorizadas por el usuario en dos lotes:

- **Lote A (consistencia):** escala de severidad unificada a la canónica
  **Bloqueante/Importante/Menor·nit** (se eliminaron "Alto/Medio/Bajo",
  "Media/Alta", "mayor" en `metodologia-revision`, `calidad-y-mantenibilidad`,
  `checklists`); etiquetas de tier en `dominios-especializados` §1/§2 (columna
  «Corrección» = correctitud `certero`; el código de dominio se teclea **T2 vía
  `motor`/`farola`**); enrutado de infra/despliegue corregido a **`eneida`/
  plataforma** en `debugging-causa-raiz` (antes `sysuniversal-ai`); referencia
  `§0`→`§3.0` en `correccion-y-refactor`; typo cirílico "matриз"→"matriz";
  **`prisma`** añadido al frontmatter de `SKILL.md`; hedges de neutralidad
  (`git blame`, `Mermaid`, ejemplos con extensión concreta → "p. ej.").
- **Lote B (completitud de élite):** **revisión de código generado por IA** (APIs
  alucinadas, plausible-pero-incorrecto, tests autogenerados tautológicos, límites
  del review asistido por IA) + higiene de commits/bisectabilidad en
  `metodologia-revision`; **MC-DC**, **métodos formales con método** (modelo↔código)
  y **testing metamórfico** en `analisis-estatico-dinamico`; **rigor
  safety-critical** (JPL *Power of Ten*, MISRA, subconjunto seguro) en
  `dominios-especializados` §5.1; **linearizabilidad/serializabilidad y modelos de
  consistencia** + **anomalías de aislamiento transaccional** (write skew, lost
  update, phantom; frontera *elección de aislamiento/tx = `certero`*, *plan/índice =
  `andulfo`*) en `concurrencia-y-estado`; **test smells** (revisar la correctitud
  de los tests del PR; frontera con `amado`) en `pruebas-de-regresion`; **LSC/
  codemods** y **revisión de cadena de suministro** en `revision-a-escala`;
  **triaje severidad × prioridad** en `gobernanza-y-etica`; **estabilidad numérica
  avanzada** (cancelación, ULP, determinismo FP, Kahan) y **supply-chain footguns**
  en `lenguajes-y-ecosistemas`; **correctitud de la observabilidad/logging** en
  `calidad-y-mantenibilidad`.

Verificado: 16 satélites (sin archivos nuevos), todos los enlaces cruzados
resuelven, sin frontmatter en satélites, sin FLIT, sin sesgo, sin deslices de
tier/ownership. Las adiciones de Lote B se hicieron dentro de los satélites
existentes; la matriz de 13 disciplinas se mantiene.

## [1.0.0] — 2026-07-09

### Added — Creación del agente
- Nace **certero**, dueño integral de la **correctitud y la calidad del código** del
  ecosistema, con neutralidad tecnológica total (sesgo cero), aplicable a cualquier
  industria/dominio/lenguaje/paradigma y a sistemas greenfield, en construcción y
  brownfield/auditoría/rescate. Eje único: **correctitud** (bugs de lógica, edge
  cases, manejo de errores, concurrencia como correctitud, fugas de recursos,
  invariantes, regresiones, mantenibilidad).
- **Modelo tiered de corrección** (no solo revisa, también corrige): Tier 1
  implementa directo lo cross-cutting que ES su disciplina (proceso/estándares de
  review, gates de calidad en CI, el test de regresión que prueba el fix, tests de
  caracterización, correcciones sin dueño único); Tier 2 entrega/co-implementa el
  fix verificado en dominio ajeno vía su dueño (`motor`/`farola`/`andulfo`/
  `sysuniversal-ai`/`eneida`); Tier 3 es la **potestad de corregir** — fallback a
  corrección directa cuando el dueño está **saturado o no existe**, marcada
  "pendiente de revisión del dueño". Conducta por defecto: **delegar (T2)**.
- **Filtro de disciplina antes del tier:** si la causa raíz resulta ser
  performance→`peakformance`, seguridad→`destroyer`, arquitectura→`eneida` o
  datos/esquema→`andulfo`, certero la **evidencia y la entrega** (con la
  reproducción hecha), **no la absorbe**.
- **Frontera explícita con `amado` (QA):** `amado` prueba el sistema y reporta;
  certero revisa el código y corrige. certero escribe **solo el test que reproduce y
  prueba SU fix** (falla→pasa); la estrategia, suite, cobertura y proceso de QA son
  de `amado`.
- `SKILL.md` (§0–§14: principios, cuándo activarte + alcance SÍ/NO/colabora, modos
  A–E, protocolo, entradas, disciplina de decisión, salidas, formato, accesos +
  modelo tiered, base de conocimiento, reglas de oro, estilo, anti-patrones,
  checklist de cierre) + 16 archivos satélite de conocimiento:
  `metodologia-revision.md`, `taxonomia-defectos.md`, `debugging-causa-raiz.md`,
  `analisis-estatico-dinamico.md`, `correccion-y-refactor.md`,
  `concurrencia-y-estado.md`, `calidad-y-mantenibilidad.md`,
  `pruebas-de-regresion.md`, `lenguajes-y-ecosistemas.md`, `revision-a-escala.md`,
  `dominios-especializados.md`, `interoperabilidad-y-aliados.md`,
  `gobernanza-y-etica.md`, `plantillas.md`, `ejemplos.md`, `checklists.md`.
- Matriz de cobertura de **13 disciplinas** de correctitud/calidad; cada una con un
  hogar en la base de conocimiento.
- `sincronizar.ps1` (mismo patrón que eneida, farola, uxuifull, andulfo,
  peakformance…): 4 junctions de directorio hacia `.cursor`, `.claude`,
  `.claude-trabajo`, `.agents`.

### Contexto
- Se incorpora al equipo enterprise como **revisor/corrector de bugs** transversal,
  cerrando el hueco entre `amado` (QA: prueba y reporta) y los dueños de dominio
  (`motor`/`farola`/`andulfo`…). Reutiliza el patrón *tiered* validado en
  `peakformance` (audita y corrige), re-ejeado de *performance* a *correctitud*.
- Principios no negociables: entiende antes de tocar · causa raíz, no síntoma ·
  reproduce antes de corregir · verifica con prueba que falla→pasa · fix mínimo
  correcto · no introduzcas regresiones · sesgo cero · respeta el ownership (tiered)
  · distingue defecto de estilo y bloqueante de sugerencia · revisa el código, no a
  la persona.
