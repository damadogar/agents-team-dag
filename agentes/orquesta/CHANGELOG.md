# Changelog — orquesta (Primer Maestro de Delivery y Orquestación)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.3.0] — 2026-07-28

### Added
- **Sección "Protocolo de equipo"** en `gobernanza-y-etica.md`: referencia al nuevo
  `TEAM-PROTOCOL.md` (raíz del repositorio), el protocolo operativo único compartido por
  los 22 agentes + 2 clusters (ownership, plantilla canónica de handoff, gates,
  escalamiento y los momentos exactos en que se debe consultar). orquesta queda como
  Accountable (A) de ese documento.

### Notas
- Adición aditiva: no cambia RACI, Tiered META, ética de coordinación ni ningún
  contenido existente de este archivo. Canario de despliegue del protocolo de equipo
  antes de extenderlo a los otros 21 agentes + 2 clusters.

## [1.2.1] — 2026-07-12

### Changed
- **dueño del PORTAFOLIO aclarado** en `gestion-de-programa.md` y
  `capacidad-y-asignacion.md`: el portafolio/estrategia/priorización de inversión es
  del **negocio/sponsor (rol externo)**; **ni orquesta ni tompo lo poseen** (ambos
  lo tratan como INSUMO); `tompo` lo **traduce** a valor de producto. orquesta
  escala a tompo/sponsor, no decide.

### Notas
- sin cambio de objetivo (Delivery/PM, autoridad de flujo); elimina la titularidad
  ambigua "tompo/negocio" del portafolio.

## [1.2.0] — 2026-07-11

### Added / Fixed — 2ª ronda de QA (4 revisores solo-lectura), lotes A+B
Auditoría de v1.1.0 en 4 dimensiones. Veredicto unánime: **CONVERGIDO — 0 bloqueantes, 0 ALTA,
0 invasión de ownership; experto integral de nivel mundial, universal y operable**; los 4
revisores confirmaron que las adiciones de v1.1.0 quedaron bien integradas. Solo 2 MEDIA + pulido.
Autorizado A+B.

- **Lote A — precisión y consistencia:** clasificación de intake alineada al filtro canónico de
  4 vías — "técnica→eneida/**especialista**" (SKILL §5 paso 1b, interoperabilidad §4.1,
  plantillas §14), para no cortocircuitar el ruteo a craft; puente en `capacidad` §4 bis (evita el
  eco de la tesis de ToC ya enunciada en §3); cita de `orquestacion-y-ruteo` → "pasos 1b-2-3-11";
  disparador "rol/agente no existe" re-etiquetado Modo A → **A/B**; "cada disparador cae en uno o
  más modos (o transversal)"; WSJF escrito **CoD(valor+criticidad+riesgo, tompo) ÷ tamaño(orquesta)**;
  "propone añadir capacidad" en ToC; "priorización"→"secuenciación" en §5 bis; handles
  `[tompo/eneida](SKILL.md)` de `planificacion` pasados a texto plano.
- **Lote B — completitud de élite (contenido nuevo, sin satélites nuevos):**
  - `cadencia-y-ceremonias` **Coordinación distribuida y asíncrona** (async-first, follow-the-sun,
    handoffs cross-timezone, planning timezone-aware) — cierra el hallazgo MEDIA, coherente con un
    equipo de agentes.
  - `gestion-de-programa` frontera **Portfolio Kanban / Lean Portfolio** (mecánica de flujo del
    portafolio = orquesta; priorización de inversión = tompo/negocio).
  - `capacidad-y-asignacion` **contención cross-programa** (capacidad sobre el total; desempate de
    portafolio a tompo).
  - `flujo-y-metricas-de-entrega` **deuda de entrega (delivery debt)**; `comunicacion-y-reporte`
    **check-in de entrega contra OKRs**; `cadencia` **etapas de desarrollo del equipo (Tuckman)**.

Sin archivos nuevos (siguen 17 satélites / 20 archivos). Sin cambios en el objetivo ni las
fronteras. Los junctions propagan solos.

## [1.1.0] — 2026-07-11

### Added / Fixed — 1ª ronda de QA (4 revisores solo-lectura), lotes A+B+C
Auditoría de v1.0.0 en 4 dimensiones (coherencia/índice, experto integral + universalidad +
nivel mundial, fronteras/no-solapamiento, operatividad/tiered). Veredicto unánime:
**convergido — 0 bloqueantes, 0 invasión de ownership, experto integral de nivel mundial,
universal y con fronteras limpias**. Solo precisión, completitud de élite y cierre del lazo de
intake. Autorizado A+B+C.

- **Lote B — completitud de élite (contenido nuevo, sin satélites nuevos):**
  - `planificacion-y-cronograma` §5 bis **Secuenciación económica (Cost of Delay, CD3/WSJF)**:
    orquesta reclama su mitad legítima de la priorización de flujo — computa la duración/tamaño;
    el peso de valor lo aporta tompo (WSJF = valor(tompo) ÷ duración(orquesta)). Cierra el
    hallazgo ALTA.
  - `flujo-y-metricas-de-entrega` §3 bis **Value Stream Mapping** y **Flow Framework** (Kersten).
  - `capacidad-y-asignacion` §4 bis **Theory of Constraints**: cinco pasos de enfoque
    (identificar-explotar-subordinar-elevar-repetir) y drum-buffer-rope.
  - `gestion-de-dependencias` **Coordinación de terceros, proveedores y contratos** (SLA/SoW,
    lead time del tercero, sincronización con otro tren).
  - `planificacion` §3 estimación de **tres puntos/PERT**, **right-sizing** y **#NoEstimates**;
    `comunicacion-y-reporte` **plan de compromiso de entrega** (stakeholder engagement de delivery).
- **Lote C — intake entrante:** `plantillas` §14 **Señal entrante a orquesta** +
  `interoperabilidad` §4.1 **Intake entrante (el recíproco)**: cierra el lazo del rol "front door".
- **Lote A — consistencia:** "12 agentes" → **14** (SKILL §0.1, interoperabilidad §5, este
  CHANGELOG); lista "Hermanos" de `plantillas` completada (16); paso **1b. CLASIFICAR** en el
  protocolo (SKILL §5); disparadores **elegir/adaptar metodología** y **rol/agente inexistente**
  (SKILL §3bis); incidente re-etiquetado Modo D → **C/transversal**; blindaje de insumos en
  WSJF (valor=tompo) y EMV (impactos de los dueños).

Sin archivos nuevos (siguen 17 satélites / 20 archivos). Sin cambios en el objetivo ni las
fronteras. Los junctions propagan solos.

## [1.0.0] — 2026-07-11

### Added — creación del agente
Nace **orquesta**, el agente-skill que fusiona la disciplina completa de **Delivery /
Program Management** y es el **orquestador del equipo enterprise**: descompone la
petición, **asigna y delega** cada tarea al agente/rol correcto, secuencia según
dependencias, equilibra la carga, gestiona el cronograma, los riesgos (RAID) y los
impedimentos, coordina la cadencia y reporta el avance. Con **neutralidad metodológica
total** (Scrum/Scrum Master, Kanban/flujo, SAFe/RTE, LeSS/Nexus/Scrum@Scale,
PMBOK/PMP, PRINCE2, waterfall/stage-gate e híbridos son opciones que se eligen por
contexto, nunca por moda) y **autoridad de flujo** (dirige la coordinación con
autoridad real, pero nunca sobre el valor ni la arquitectura). Universal: greenfield,
en construcción y brownfield.

**Origen del agente:** el equipo enterprise ya tenía el asiento reservado. `tompo` (PO)
declara explícitamente que **no asume la capa de Product Manager/portafolio** ("del
orquestador mayor del equipo"); `eneida` (arquitectura) lista al **"Delivery Manager /
Orquestador (futuro PM del equipo)"** como rol distinto, dueño de "cronograma,
capacidad, coordinación y seguimiento operativo", con RACI "Alcance y fecha de release
→ Delivery = R, PO = A". orquesta llena ese asiento sin romper nada. Es, además, la
cabeza de todas las notas de ruteo ("un orquestador debe rutear a…") que quedaron
sembradas por el equipo.

**El triángulo de fronteras (para no pisar la manguera):** **tompo** decide el
**qué/por qué** (valor, prioridad, backlog) · **eneida** decide el **cómo técnico**
(arquitectura, dependencias técnicas, severidad) · **orquesta** decide el **quién/
cuándo/cómo-coordinado** (asignación, secuencia, capacidad, cronograma, RAID, cadencia,
reporte, desatasco). Fronteras adicionales blindadas: **baluarte** opera el pipeline
CI/CD / orquesta coordina el *cuándo/quién* del release y consume DORA como señal de
entrega; **amado/certero** deciden el gate de calidad/correctitud / orquesta lo integra
en la cadencia; el **craft** de cada dominio es del especialista / orquesta lo rutea,
nunca lo ejecuta.

**Modelo tiered — interpretación META (única en el equipo):** orquesta es el único
agente META (su craft *es* coordinar). **T1** orquesta directo (planificar, rutear,
secuenciar, RAID, flujo, cadencia, reporte). **T2** co-facilita con el dueño de la
decisión de dominio (el dueño decide). **T3** potestad **solo de flujo** si el dueño
está ausente/saturado y el flujo se detiene: re-secuencia, re-asigna o aplica plan por
defecto, marcado **"pendiente de ratificación del dueño"**; jamás decide valor,
arquitectura o craft.

**Estructura inicial (20 archivos: SKILL.md + 17 satélites + CHANGELOG.md + sincronizar.ps1):**

- `SKILL.md` — entrada, §0 índice maestro (base de conocimiento + matriz de 16
  disciplinas), principios rectores, §2 identidad (+ §2.1 alcance SÍ/NO/colabora),
  modos A–E, §3bis disparadores, framework de análisis, protocolo, §8 modelo tiered
  META, relación con el equipo, comportamiento por defecto, checklist de cierre.
- Núcleo de craft de delivery/orquestación: `planificacion-y-cronograma`,
  `gestion-de-dependencias`, `capacidad-y-asignacion` (con la **detección de
  saturación/ausencia** que operacionaliza el T3 de todo el equipo),
  `gestion-de-riesgos-raid`, `flujo-y-metricas-de-entrega`, `cadencia-y-ceremonias`,
  `orquestacion-y-ruteo` (**el corazón**: tabla de despacho señal→agente),
  `metodologias-y-marcos`, `comunicacion-y-reporte`, `gestion-de-programa`,
  `gestion-de-cambios-y-alcance`, `incidentes-y-coordinacion-de-crisis`.
- Frontera/gobernanza: `interoperabilidad-y-aliados` (hub anti-solapamiento: filtro de
  disciplina, modelo tiered META, contrato de handoff, cross-invocación con los 14
  agentes, fronteras confundibles con tompo/eneida/baluarte + amado/certero) y
  `gobernanza-y-etica`.
- Operativos: `plantillas`, `ejemplos`, `checklists`.
- `sincronizar.ps1` (4 junctions) y este `CHANGELOG.md`.

**Alcance elegido:** delivery del equipo **+** orquestación de programa (multi-flujo);
el portafolio y la estrategia de negocio quedan como **insumo de tompo**, no los decide
orquesta.

Globalizado con `sincronizar.ps1`: junctions a `.cursor`, `.claude`, `.claude-trabajo`
y `.agents`. Invocable como `/orquesta`.
