# Changelog — baluarte (Primer Maestro de Plataforma, Entrega y Confiabilidad)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.1.4] — 2026-07-12

### Added
- Fronteras explícitas en SKILL/interop con: `palma` (firma, publicación en tiendas,
  staged rollout por store, kill-switch remoto y OTA = palma; baluarte = pipeline/CI-CD +
  artefacto), `sysuniversal-ai` (plataforma de serving vs diseño de serving/MLOps),
  `farola` (pipeline/CDN-edge vs código frontend) y `caudal` (plataforma de ejecución de
  pipelines/runners vs lógica de datos y orquestación).

### Changed
- SLIs/SLOs acotados a **disponibilidad/errores** con remite a la partición con
  `peakformance` (latencia/rendimiento).

### Notas
- **Sin cambio de objetivo** (Plataforma/Entrega/Confiabilidad).

## [1.1.3] — 2026-07-11

### Added — cross-link al nuevo agente mobile `palma`
- Se crea **`palma`** (Ingeniería Mobile). Frontera: baluarte provee el **CI/paved
  road** y **opera la entrega** (incluida la entrega client-side); `palma` aporta el
  **saber de release mobile** (signing/provisioning, empaquetado, publicación en
  tiendas, phased rollout, OTA) y define qué pasos mobile corren en el pipeline; los
  secretos de firma los **opera baluarte** con la política de `destroyer`. Añadido
  `palma` a la tabla de **invocación cruzada** (§5). Sin cambios en el ownership ni en
  las demás relaciones de baluarte.

## [1.1.2] — 2026-07-10

### Fixed — 4ª ronda de QA (4 revisores solo-lectura) — cierre definitivo
Auditoría de v1.1.1 en las 4 dimensiones habituales, revisores instruidos a no
inventar hallazgos. Veredicto unánime: **convergencia total — 0 bloqueantes, 0
importantes, 0 invasiones de ownership, 0 deslices de tier, 0 contradicciones,
experto integral a nivel de élite mundial**; 3 de 4 revisores reportaron 0 hallazgos
accionables. Solo pulido cosmético; autorizado:

- Corregido el puntero "Detalle" de la fila **chaos engineering** en
  `ecosistemas-y-herramientas` §4.13: apuntaba a `observabilidad-operacional` (que
  no aloja chaos); ahora apunta a su satélite-hogar `incidentes-y-respuesta` §9 y
  `continuidad-y-dr` §8, con la frontera amado-diseña/baluarte-ejecuta.
- Eliminado el residuo de plantilla "(si aplica)" en dos enlaces a
  `plataforma-e-idp` (§4.12 y §6 de `ecosistemas-y-herramientas`).

No accionado a propósito (recomendación de los propios revisores): homogeneizar el
tríptico greenfield/brownfield/híbrido —simetría redaccional, no hueco de contenido—.

Sin archivos nuevos (18 satélites / 21 archivos). **baluarte CERRADO tras 4 rondas
de QA con convergencia declarada.** Los junctions propagan solos.

## [1.1.1] — 2026-07-10

### Fixed — 3ª ronda de QA (4 revisores solo-lectura) — cierre
Auditoría de v1.1.0 en 4 dimensiones (coherencia/índice, experto integral +
greenfield/brownfield + nivel mundial, fronteras/no-solapamiento, tiered/T3),
revisores instruidos a no inventar. Veredicto unánime: **convergencia fuerte
confirmada — 0 bloqueantes, 0 importantes, 0 invasiones de ownership, 0 deslices
de tier, nombres correctos, experto integral a nivel mundial**. Solo pulido
cosmético; autorizado (Lotes A+B):

- **Lote A (consistencia):** call-out explícito **greenfield/brownfield** en
  `iac-y-configuracion` §15 (único satélite operativo sin él; señalado por 2
  revisores); cross-links recíprocos **expiración de certificados** (`observabilidad`
  §5) ↔ **rotación de secretos** (`seguridad` §3), y **break-glass deploy**
  (`continuidad` §9) ↔ **break-glass acceso** (`seguridad` §9, con inciso de que la
  política de acceso la fija destroyer); corregida la cita del CHANGELOG
  (`plataforma-e-idp` §4, no §4.5).
- **Lote B (vocabulario de élite, opcional):** matizado en `interoperabilidad` §3.2
  que la integración de seguridad es **T1** de baluarte (lo que se entrega/recibe es
  la *decisión* de destroyer, no la mecánica); añadido **retry budget global**
  (tope sobre el ratio reintentos/peticiones) como complemento del límite por-petición
  en `confiabilidad-sre` §8.

Sin archivos nuevos (18 satélites / 21 archivos). **Convergencia declarada: el
agente cierra.** Los junctions propagan solos.

## [1.1.0] — 2026-07-10

### Added / Fixed — 2ª ronda de QA (4 revisores solo-lectura)
Auditoría de v1.0.0 en 4 dimensiones (coherencia/índice, experto integral +
greenfield/brownfield + nivel mundial, fronteras/no-solapamiento, tiered/T3),
revisores instruidos a **no inventar hallazgos**. Veredicto unánime: **convergencia
confirmada, 0 bloqueantes, 0 invasiones de ownership, 0 deslices de tier**; "a nivel
mundial", índice fiel al territorio, fronteras simétricas. Autorizado por el usuario
(Lotes A+B+C):

- **Lote A (consistencia/fronteras):** alineado el verbo de ejecución de pruebas
  (amado **diseña**; baluarte **provee el CI y las ejecuta**) en `plataforma-e-idp` §4
  y `SKILL.md` (frontmatter); `seguridad-de-plataforma` §10 ahora remite a
  `incidentes-y-respuesta` (mecánica/postmortem) además de interop §6.4 (frontera);
  añadido **T3** al cierre tiered del archivo núcleo `confiabilidad-sre` §15;
  añadido call-out **greenfield/brownfield** a `continuidad-y-dr` §11.
- **Lote B (enriquecimiento nivel-mundial):** **arquitectura celular (cell-based) y
  shuffle sharding** como palanca de blast radius (`contenedores` §10, frontera:
  eneida decide el estilo, baluarte opera celdas/routing/despliegue); **alertas
  preventivas de expiración de certificados/PKI, secretos y cuotas** (`observabilidad`
  §5); **continuidad del plano de entrega / break-glass deploy** cuando el pipeline/
  control plane está caído (`continuidad-y-dr` §9).
- **Lote C (estilo):** `tompo` (PO) y `amado` (QA) nombrados por handle en
  `gobernanza-y-etica` §1; "entrega client-side" y "capacidad de aceleradores GPU/TPU"
  surfaceadas en el índice §0/§10 de `SKILL.md`; referencia de carga de on-call
  armonizada (`observabilidad` §6 ↔ `incidentes` §1, ~2 incidentes accionables/turno).

Sin archivos nuevos (siguen 18 satélites / 21 archivos). Los junctions propagan solos.

## [1.0.0] — 2026-07-10

### Added — creación del agente
Nace **baluarte**, el agente-skill que fusiona **DevOps + SRE + Platform
Engineering** en una sola disciplina de clase mundial, con **neutralidad
tecnológica total** y **modelo tiered** (construye lo cross-cutting; entrega o
corrige lo de dominio ajeno; potestad de corrección directa si el dueño está
saturado o ausente). Universal: greenfield, en construcción y brownfield.

**Estructura inicial (21 archivos: SKILL.md + 18 satélites + CHANGELOG.md + sincronizar.ps1):**

- `SKILL.md` — entrada, §0 índice maestro (base de conocimiento + matriz de 15
  disciplinas por lente), principios rectores, §2 activación (+ §2.1 alcance
  SÍ/NO/colabora), modos A–E, protocolo, modelo tiered, base de conocimiento,
  reglas de oro, anti-patrones y checklist de cierre.
- Satélites de conocimiento (por lente Entrega/Plataforma/Confiabilidad):
  `metodologia-y-cultura`, `cicd-y-release-engineering`, `iac-y-configuracion`,
  `contenedores-y-orquestacion`, `confiabilidad-sre`, `observabilidad-operacional`,
  `incidentes-y-respuesta`, `plataforma-e-idp`, `cloud-redes-y-edge`,
  `capacidad-y-costos`, `seguridad-de-plataforma`, `continuidad-y-dr`,
  `ecosistemas-y-herramientas`.
- Frontera/gobernanza: `interoperabilidad-y-aliados` (hub anti-solapamiento,
  filtro de disciplina, modelo tiered, fronteras 6.1–6.4 con
  eneida/peakformance/andulfo/destroyer y §7 con amado), `gobernanza-y-etica`.
- Operativos: `plantillas`, `ejemplos`, `checklists`.
- `sincronizar.ps1` (4 junctions) y este `CHANGELOG.md`.

**Fronteras clave establecidas (para no pisar la manguera):** eneida *decide* la
arquitectura y baluarte la *opera*; peakformance juzga el *rendimiento* y baluarte
la *disponibilidad/entrega*; andulfo posee el *plano de datos* (HA/DR y backup de
datos) y baluarte la *plataforma/infra*; destroyer *decide* la seguridad y baluarte
la *integra* en el pipeline (DevSecOps); motor construye su *código* y baluarte el
*camino* que recorre; amado diseña las *pruebas* y baluarte provee el *CI* y las
*corre*; certero juzga la *correctitud del código*.

Globalizado con `sincronizar.ps1`: junctions a `.cursor`, `.claude`,
`.claude-trabajo` y `.agents`. Invocable como `/baluarte`.
