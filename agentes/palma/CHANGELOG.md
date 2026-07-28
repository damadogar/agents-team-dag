# Changelog — palma (Primer Maestro de Ingeniería Mobile)

Formato basado en Keep a Changelog. Versionado semántico.

## [1.2.0] — 2026-07-11

### Added / Fixed — 3ª ronda de QA (4 revisores solo-lectura), lotes A+B+C
Auditoría de v1.1.1. Veredicto unánime: **convergido — 0 bloqueantes, 0 importantes, 0
invasión de ownership, experto integral de nivel mundial**; un revisor reportó 0 hallazgos.
Solo pulido + enriquecimientos opcionales. Autorizado A+B+C.

- **Lote B — enriquecimientos 2026 (contenido nuevo, sin satélites nuevos):**
  - `form-factors-extendidos` §4.1 **Espacial / XR** (visionOS / Android XR): interacción
    mirada+gestos, contenido inmersivo, frontera con AR; decisión de alcance = tompo/eneida.
  - `monetizacion-y-billing` §1.1 **Pagos de bienes físicos** (Apple Pay/Google Pay, PSP=motor,
    PCI=destroyer) y **wallet passes** (PassKit/Google Wallet: tickets, fidelización, llaves NFC).
- **Lote C — detalles finos:**
  - `release-engineering-y-tiendas` §7.1 **Feature flags, remote config y experimentación A/B**
    consolidados como craft de cliente (estrategia = tompo, plumbing = palma, pipeline = baluarte).
  - `dispositivo-sensores-capacidades` — **continuidad multi-dispositivo y casting** (AirPlay/
    Chromecast, Handoff, Matter/Thread).
- **Lote A — consistencia:** billing §11 "**integración** de la custodia de secretos" (política =
  destroyer); i18n §5 nombra a `motor`; i18n §7 ASO → `tompo`; `ejemplos` recuenta (8 casos + T3)
  y su síntesis añade `certero`/`tompo`. Índice §0 (base + matriz 17/19) refleja XR y pagos físicos.

Sin archivos nuevos (siguen 22 satélites / 24 .md). Sin cambios en el objetivo ni las fronteras.
Convergencia declarada tras 3 rondas. Los junctions propagan solos.

## [1.1.1] — 2026-07-11

### Fixed — 2ª ronda de QA (4 revisores solo-lectura), lotes A+B+C
Auditoría de v1.1.0 con foco en los 4 satélites nuevos. Veredicto: **0 bloqueantes, 0
invasión de ownership, experto integral de nivel mundial confirmado**; solo cableado y
pulido de redacción. Autorizado A+B+C.

- **Lote A — cableado operativo (huecos MEDIA):** añadidos los disparadores de billing/IAP,
  extensiones/superficies, i18n/RTL y form-factors extendidos a `SKILL.md` §11 "Cuándo
  activarte" y §4 (framework, nuevo punto 13); añadidas 4 secciones de checklist (§14–17)
  para esas disciplinas en `checklists.md`.
- **Lote B — fronteras/consistencia (pulido de los 4 satélites nuevos):** `billing` — nombra
  a `amado` (pruebas) y a `certero` (correctitud de la máquina de estados), y separa el
  handoff interno (release/seguridad = satélites propios) del T2 externo; `extensiones` —
  la política de endurecimiento/credenciales/passkey la decide `destroyer` (no eneida),
  desambiguado "canal" (contrato en cliente = notificaciones / emisión backend = motor),
  enlace informal de deep links formalizado; `i18n` — nombra a `amado` en pruebas;
  `notificaciones` gana el **contrato de payload de notificaciones ricas y Live Activities**
  (cierra la forward-reference de extensiones).
- **Lote C — nits/INFO:** ejemplo T3 aclara que el pin se entrega por **config remota**
  (no binario nativo); universalidad de `i18n` pasada a viñetas; `docpower` añadido a la
  plantilla de handoff; nota de trazabilidad de las 4 disciplinas nuevas en `interoperabilidad` §5.

Sin archivos nuevos (siguen 22 satélites / 24 .md). Sin cambios en el objetivo ni las
fronteras. Los junctions propagan solos.

## [1.1.0] — 2026-07-11

### Added — ronda final de QA (4 revisores solo-lectura), lotes A+B+C
Auditoría de v1.0.0 en 4 dimensiones (coherencia/índice, experto integral+greenfield/
brownfield+nivel mundial, fronteras/no-solapamiento, operatividad/tiered). Veredicto:
**0 bloqueantes, 0 invasión de ownership**; nivel mundial confirmado. Autorizado A+B+C.

- **Lote B — completitud de élite (4 satélites nuevos, 22 en total):**
  `monetizacion-y-billing` (IAP/suscripciones/entitlements/restore; validación server-side
  = motor, modelo = tompo), `extensiones-y-superficies-del-sistema` (widgets, App Clips,
  Live Activities/Dynamic Island, App Intents, app extensions), `internacionalizacion-mobile`
  (i18n/l10n/RTL nativo, distinto del i18n web de farola) y `form-factors-extendidos`
  (wearable/TV/automotriz/embebido con UI). Índice maestro §0 y matriz de disciplinas
  (ahora 19 filas) actualizados.
- **Lote A — consistencia:** corregida la nomenclatura tiered de `performance-mobile` §10
  (T1 craft / T2 escalar a peakformance / T3 excepcional, alineada con el maestro);
  enlaces `../eneida`/`../farola` de `cross-platform` → `interoperabilidad-y-aliados.md`;
  `ejemplos` atribuía datos/sync a sysuniversal-ai → corregido a **andulfo**; desambiguado
  "RUM de app" (palma) vs "RUM de performance" (peakformance) en §2.1; añadido **certero**
  a las listas de frontera (§1.14, §2.1, §14); "**en construcción**" añadido a
  `performance-mobile` §9 y `testing-mobile`; plantilla de handoff completada con los 12
  aliados; nits de `§3` (rescate A→E), `§7` (heurísticas = recomendación, no decisión
  macro), `§10` (mapeo de satélites) y `plantillas` (Hermanos).
- **Lote C — refinamientos:** ejemplo del **camino T3** (dueño ausente/saturado) en
  `ejemplos`; **distribución empresarial (MDM/MAM) y tiendas alternativas/DMA** en
  `release-engineering-y-tiendas` §8.1; **render intensivo y game engines embebidos**
  (Metal/Vulkan, Unity/Unreal, AR) en `cross-platform`.

Sin cambios en el objetivo, las fronteras ni el modelo tiered. **25 archivos** (SKILL +
22 satélites + CHANGELOG + sincronizar.ps1). Los junctions propagan solos.

## [1.0.0] — 2026-07-11

### Added — creación del agente
Nace **palma**, el agente-skill que fusiona la disciplina completa de **Ingeniería
Mobile** (nativa y cross-platform) en un solo maestro de clase mundial, con
**neutralidad tecnológica total** (iOS/Android; Swift/Kotlin; React Native/Flutter/
KMP/MAUI son opciones que se eligen por evidencia, nunca por moda) y **modelo
tiered** (construye directo lo mobile propio; entrega o co-implementa lo de dominio
ajeno; potestad de corregir si el dueño está saturado o ausente). Universal:
greenfield, en construcción y brownfield.

**Origen del agente:** auditoría previa que confirmó que ningún agente del equipo
construía apps móviles nativas/cross-platform. `farola` (frontend) nunca tuvo mobile
nativo —solo responsive web, PWA y la UI web del híbrido, que conserva—; el resto del
equipo toca mobile desde su lente (uxuifull diseña, amado prueba, peakformance mide
rendimiento, destroyer decide seguridad, eneida decide arquitectura, tompo el producto,
motor el backend). El hueco era el **constructor**. Ese es palma.

**Estructura inicial (21 archivos: SKILL.md + 18 satélites + CHANGELOG.md + sincronizar.ps1):**

- `SKILL.md` — entrada, §0 índice maestro (base de conocimiento + matriz de 15
  disciplinas), principios rectores, §2 activación (+ §2.1 alcance SÍ/NO/colabora),
  modos A–E, framework de análisis, protocolo, §9 modelo tiered, base de conocimiento,
  reglas de decisión, anti-patrones y checklist de cierre.
- Satélites de conocimiento: `fundamentos-y-arquitectura-app`, `plataformas-nativas`,
  `cross-platform`, `ui-adaptive-y-accesibilidad`, `datos-conectividad-y-offline`,
  `notificaciones-deeplinks-background`, `dispositivo-sensores-capacidades`
  (con **telemetría completa** de app), `performance-mobile` (craft),
  `seguridad-mobile` (integra), `release-engineering-y-tiendas`, `testing-mobile`
  (craft), `ia-on-device` (integra), `ecosistemas-y-herramientas`.
- Frontera/gobernanza: `interoperabilidad-y-aliados` (hub anti-solapamiento, filtro de
  disciplina, modelo tiered, fronteras confundibles con farola/peakformance/destroyer/
  baluarte y frontera con amado), `gobernanza-y-etica`.
- Operativos: `plantillas`, `ejemplos`, `checklists`.
- `sincronizar.ps1` (4 junctions) y este `CHANGELOG.md`.

**Fronteras clave establecidas (para no pisar la manguera):** **farola** posee la
web, el responsive web, la PWA y la UI web del híbrido / **palma** el mobile nativo y
cross-platform, el shell nativo del híbrido y el release en tiendas; **uxuifull** diseña
/ palma construye; **peakformance** fija budgets y estrategia de rendimiento / palma
implementa el craft; **destroyer** decide la seguridad / palma la integra; **eneida**
decide la arquitectura de sistema / palma implementa la app; **amado** diseña la
estrategia de pruebas / palma escribe y ejecuta las pruebas de su código; **motor**
construye el backend / palma consume el contrato; **andulfo** posee el plano de datos /
palma la persistencia local y el sync del cliente; **baluarte** provee el CI/paved road
/ palma aporta el saber de firma/tiendas/OTA; **sysuniversal-ai** decide el modelo /
palma integra la inferencia on-device; **tompo** es el PO.

En paralelo, `farola` se re-acotó a **v1.3.1**: sus frases de canal pasaron a "móvil
web (responsive)" y "UI web del híbrido", y ganó la frontera Mobile nativo → palma,
conservando intactas todas sus capacidades y relaciones.

Globalizado con `sincronizar.ps1`: junctions a `.cursor`, `.claude`, `.claude-trabajo`
y `.agents`. Invocable como `/palma`.
