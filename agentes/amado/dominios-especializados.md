# Dominios y tipos de prueba especializados

Cierra los nichos del área de QA que no encajan en los módulos generales. Amado
aplica aquí el mismo método (risk-based, autónomo, reproducible) adaptado a la
naturaleza física, técnica o regulatoria de cada dominio.

> Regla: el dominio cambia los **riesgos, oráculos y herramientas**, no los
> principios. Identifica el riesgo dominante del dominio y diseña hacia él.

---

## 1. Testing exploratorio y Session-Based Test Management (SBTM)

Complementa —no reemplaza— al testing estructurado. Imprescindible para descubrir
lo que los casos predefinidos no anticipan.

- **Charter (carta de misión):** "Explorar <área> con <recursos> para descubrir
  <información>". Acotado y con objetivo claro.
- **Sesiones time-boxed** (60–120 min) con foco; *uninterrupted*.
- **Notas estructuradas:** setup, *test notes*, bugs, *issues*, preguntas; ratio
  *Test/Bug/Setup* (TBS) para medir productividad.
- **Debrief (PROOF):** Past, Results, Obstacles, Outlook, Feelings.
- **Tours (heurísticas de exploración):** *feature tour*, *money tour* (lo que
  paga el cliente), *landmark*, *back alley* (lo poco usado), *saboteur*
  (intentar romper), *data tour*, *configuration tour*.
- **Heurísticas de oráculo:** **HICCUPPS** (History, Image, Comparable products,
  Claims, User expectations, Product, Purpose, Standards), **SFDIPOT** (San
  Francisco Depot) para modelar el producto, **CRUSSPIC STMPL** para atributos.
- **Cuándo:** features nuevas/volátiles, áreas de alto riesgo, tras un fix
  complejo, antes de un release, complementando la regresión automatizada.

---

## 2. Mobile (profundidad)

Riesgos dominantes: fragmentación, recursos limitados, conectividad e interrupciones.

- **Fragmentación:** matriz de dispositivos/OS por cuota de mercado real; usa
  *device farms* (BrowserStack, Sauce, AWS Device Farm, Firebase Test Lab) +
  algunos físicos clave.
- **Condiciones de red:** 2G/3G/4G/5G/WiFi, latencia, *packet loss*, *airplane
  mode*, transición de red; *throttling* (Charles, network conditioner).
- **Interrupciones:** llamadas, notificaciones, *split-screen*, rotación,
  *backgrounding/foregrounding*, *low memory kill*, permisos revocados en caliente.
- **Recursos:** consumo de **batería**, CPU, memoria, datos, almacenamiento;
  *jank*/FPS y *startup time*.
- **Específicos de plataforma:** ciclo de vida (Activity/ViewController), *deep
  links*, *push*, *in-app purchases*, biometría, *app stores* (revisión, tamaño).
- **Instalación/upgrade:** *fresh install*, *upgrade* preservando datos, migración.
- Herramientas: Appium, Espresso, XCUITest, Maestro, Detox, Flutter
  integration_test.

---

## 3. Embebidos / IoT / Hardware-in-the-Loop (HIL)

Riesgos dominantes: recursos mínimos, fallo físico, tiempo real, no-actualizable.

- **HIL / SIL / MIL:** Hardware/Software/Model-in-the-Loop; simula sensores y
  actuadores; bancos de prueba.
- **Tiempo real:** *deadlines*, jitter, prioridades, *watchdog timers*,
  determinismo (RTOS).
- **Recursos:** memoria/flash limitada, consumo energético, *brown-out*.
- **Robustez física:** temperatura, vibración, EMI, *power cycling*, *fault
  injection* de hardware.
- **Comunicaciones:** CAN, MQTT, BLE, LoRa, Zigbee, Modbus; pérdida/orden de
  paquetes, reconexión.
- **OTA y *fleet*:** actualización *over-the-air* segura, *rollback*, *bricking*
  prevention, gestión de miles de dispositivos, *staged rollout*.
- **Seguridad IoT:** *secure boot*, identidad de dispositivo, cifrado, superficie
  física, OWASP IoT Top 10.
- **Cumplimiento (cuando aplica):** IEC 61508, ISO 26262 (automotriz), IEC 62304
  (médico), DO-178C (aeroespacial). Ver `verificacion-avanzada.md`.

---

## 4. Game testing

Riesgos dominantes: experiencia, rendimiento, estados emergentes, plataformas.

- **Funcional de juego:** mecánicas, reglas, físicas, IA de NPCs, progresión,
  *save/load*, economía in-game.
- **Exploratorio intensivo:** *exploit hunting*, *clipping*/colisiones,
  *softlocks*, secuencias rotas, *out-of-bounds*.
- **Rendimiento:** FPS estable, *frame time*, *load times*, *streaming* de
  assets, uso de GPU/VRAM, *thermal throttling*.
- **Multijugador:** *netcode*, latencia/lag, *desync*, *rollback*, anti-cheat,
  *matchmaking*, carga de servidores.
- **Compatibilidad:** consolas (cert. de plataforma: TRC/TCR/Lotcheck), PC
  (hardware diverso), controles, resoluciones.
- **Localización:** texto, audio/doblaje, *culturalization*.
- **Compliance:** *age rating* (ESRB/PEGI), *loot box*, accesibilidad de juegos.
- **Soak/stability:** sesiones largas, fugas de memoria, *crash rate*.

---

## 5. Web3 / Blockchain / Smart contracts

Riesgos dominantes: irreversibilidad, valor financiero directo, inmutabilidad.

- **Seguridad de contratos (crítica):** *reentrancy*, overflow/underflow, control
  de acceso, *front-running*/MEV, *oracle manipulation*, *flash loan attacks*,
  *integer/logic bugs*. Catálogo SWC Registry; checklist *Smart Contract
  Weakness*.
- **Análisis especializado:** estático (Slither, Mythril), *fuzzing*
  (Echidna, Foundry/forge fuzz), **formal verification** (Certora, Halmos,
  scribble), *symbolic execution* (Manticore).
- **Property-based/invariantes:** invariantes económicos (suma de balances,
  colateralización) que nunca deben romperse — ver `verificacion-avanzada.md`.
- **Gas:** costo/optimización, límites de bloque, *gas griefing*.
- **Entornos:** *testnets*, *mainnet forking* (Foundry/Hardhat), *local chains*
  (Anvil/Ganache).
- **Integración:** wallets, *signing*, *upgradeability* (proxies), eventos,
  indexers (The Graph).
- **Auditoría:** dado el riesgo financiero e **irreversible**, exige auditoría
  independiente + *bug bounty* (Immunefi) antes de mainnet.

---

## 6. AR / VR / XR

Riesgos dominantes: confort físico, rendimiento, espacial.

- **Rendimiento estricto:** mantener 72–120 FPS; *motion-to-photon latency* baja
  (clave contra el mareo).
- **Comodidad/seguridad:** *motion sickness*, *guardian/chaperone* (límites de
  juego), fatiga, *eye strain*; sesiones limitadas en prueba.
- **Tracking espacial:** *6DoF*, *drift*, oclusión, *hand/eye tracking*,
  recentrado, *room scale* vs estacionario.
- **Interacción:** *raycast*, *grab*, *teleport*, UI espacial/diegética,
  accesibilidad XR.
- **Compatibilidad:** múltiples *headsets* (Quest, Vision Pro, PSVR, SteamVR),
  *controllers*, *passthrough*.

---

## 7. Desktop

- **Multiplataforma:** Windows/macOS/Linux; *packaging* (MSI/MSIX, DMG/notarized,
  AppImage/deb/rpm), firma de código.
- **Instalación/actualización:** instalador, *silent install*, *auto-update*,
  desinstalación limpia, permisos/UAC.
- **Integración con SO:** sistema de archivos, registro, *file associations*,
  bandeja, atajos, multi-monitor/DPI scaling, *offline*.
- **Recursos y estabilidad:** memoria/CPU, *crash reporting*, persistencia local.
- Herramientas: WinAppDriver, FlaUI, Playwright (Electron), Squish, SikuliX.

---

## 8. Otros dominios sensibles (resumen)

- **Sistemas regulados (salud/finanzas/gobierno):** trazabilidad total
  requisito↔prueba↔evidencia, validación (CSV/GxP), auditoría, retención;
  cumplimiento (HIPAA, PCI-DSS, SOX, FDA 21 CFR Part 11, Habeas Data). Ver
  `frameworks.md`.
- **Big Data / streaming:** volumen, *schema evolution*, *exactly-once*, *late
  data*, reproceso/backfill — ver `calidad-a-escala.md` (datos/ETL).
- **APIs públicas / SDKs:** versionado, *backward compatibility*, *deprecation*,
  *contract testing*, documentación como prueba.

---

## 9. Gobierno y madurez del proceso QA (cómo dirigir, no solo probar)

- **RACI de calidad:** quién es Responsable/Aprobador/Consultado/Informado en
  estrategia, diseño, ejecución, gates y defectos.
- **Modelo de madurez (TMMi) aplicado:** *assessment* del estado actual →
  *gap analysis* → *roadmap* incremental (no saltar niveles).
- **Definition of Ready / Done** con criterios de calidad explícitos.
- **Comunidad de práctica de QA:** estándares, *guilds*, revisión entre pares,
  mentoría, *onboarding* de QAs.
- **Gestión de equipo:** dimensionamiento, *embedded* vs *enabling team*,
  carrera técnica (QA → QE/SET), KPIs de equipo sin métricas vanidosas.
- **Mejora continua:** retro de calidad, análisis de causa raíz de fugas,
  ajuste de la estrategia con datos.

---

## 10. Cómo decidir el enfoque por dominio (método)

```
1. Identifica el RIESGO DOMINANTE del dominio (¿qué duele más si falla?)
2. Define el ORÁCULO viable (cómo sabrás si está bien sin resultado exacto)
3. Elige TÉCNICAS y HERRAMIENTAS del mercado adecuadas (ver herramientas.md)
4. Aprovisiona el entorno (simulador/HIL/testnet/device farm) — ejecucion-autonoma.md
5. Aplica risk-based + exploratorio + automatización donde aporte
6. Cumple la regulación si el dominio la exige
7. Reporta con evidencia reproducible y veredicto
```
