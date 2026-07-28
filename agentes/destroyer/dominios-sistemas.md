# Cobertura por tipo y era de sistema (sin sesgo) — Destroyer

Matriz de "qué mirar" según el tipo de sistema, **sin privilegiar ninguno**. Lo
moderno no es superior por nuevo; lo establecido no lo es por costumbre. Para cada
tipo: activos típicos, vectores característicos y focos de control. Los principios
de fondo (mínimo privilegio, defensa en profundidad, evidencia) son **comunes**.

---

## 1. Web / API
- **Vectores:** broken access control, inyección, XSS/CSRF/SSRF, auth/sesión,
  abuso de API (BOLA), exposición de datos.
- **Foco:** authz server-side por objeto, validación/encoding, gestión de sesión,
  rate limiting, headers de seguridad, OWASP ASVS/API Top 10 como verificación.

## 2. Móvil (iOS/Android, nativo/híbrido)
- **Vectores:** almacenamiento local inseguro, *hardcoded secrets*, comunicación
  insegura, *reverse engineering*, IPC, permisos excesivos, *cert pinning* ausente.
- **Foco:** OWASP MASVS/MASTG, almacenamiento seguro (Keychain/Keystore), TLS +
  pinning, ofuscación razonable, validación server-side (no confiar en el cliente),
  *root/jailbreak* awareness, mínimo de permisos.
- **Integración en la app:** Destroyer **decide** la postura (modelo de amenaza, nivel
  MASVS objetivo, política de pinning/biometría, manejo de secretos); el constructor
  mobile **`palma`** la **integra y opera** en el binario. Destroyer no construye la
  app: verifica, prioriza la remediación y `palma` la ejecuta.

## 3. Desktop / cliente pesado
- **Vectores:** binarios sin firmar, actualización insegura, almacenamiento de
  credenciales, DLL hijacking, escalada local, IPC.
- **Foco:** firma de código, canal de actualización seguro y verificado, manejo
  de secretos del SO, mínimo privilegio del proceso, hardening del host.

## 4. Monolito / cliente-servidor clásico
- **Vectores:** una brecha compromete todo, dependencias acopladas, secretos en
  config, autorización dispersa.
- **Foco:** segmentación interna lógica, authz centralizada y consistente, gestión
  de secretos, hardening del host/runtime, backups y parcheo. **No** requiere
  microservicios para ser seguro.

## 5. Microservicios / distribuidos
- **Vectores:** movimiento lateral este-oeste, confianza implícita entre servicios,
  superficie de APIs internas, secretos en orquestador, *supply chain* de imágenes.
- **Foco:** identidad de workload + mTLS, authz por servicio, NetworkPolicies
  default-deny, observabilidad distribuida, *blast radius* acotado.

## 6. Serverless / FaaS
- **Vectores:** permisos de función excesivos, *event injection*, dependencias,
  secretos en variables, *cold start* y límites, datos en tránsito por eventos.
- **Foco:** mínimo privilegio por función, validación de eventos/entradas, secretos
  en gestor, límites de ejecución/coste, trazabilidad de invocaciones.

## 7. Mainframe / legacy / heredado
- **Vectores:** protocolos y cifras obsoletas, cuentas compartidas, escasez de
  logging moderno, dependencias sin soporte (EOL), integraciones frágiles.
- **Foco:** **evaluar el control real, no la antigüedad**; segmentación y control
  de acceso, registro y monitoreo (aunque sea vía gateway), cifrado donde sea
  viable, gestión de EOL/riesgo, controles compensatorios cuando no se puede
  modernizar. Un legacy bien aislado y monitoreado puede tener riesgo aceptable.

## 8. IoT / dispositivos conectados
- **Vectores:** credenciales por defecto, firmware sin firmar, OTA inseguro, falta
  de cifrado, exposición física, flota difícil de parchear.
- **Foco:** identidad por dispositivo, *secure boot* + firma de firmware, OTA
  autenticado, cifrado de comunicaciones, segmentación de flota, gestión de ciclo
  de vida y *end-of-support*.

## 9. OT / ICS / SCADA
- **Vectores:** protocolos industriales sin auth, IT/OT planos, sistemas que no se
  pueden parar ni parchear, impacto en seguridad física (safety).
- **Foco:** **prioridad en disponibilidad y safety**; modelo Purdue / IEC 62443,
  DMZ industrial, monitoreo pasivo no intrusivo, inventario de activos, cambios con
  ventana y validación. No imponer prácticas IT que rompan el proceso.

## 10. Embebido / firmware
- **Vectores:** memoria insegura, *secure boot* ausente, claves en firmware,
  *debug ports* abiertos (JTAG/UART), actualización insegura, *side-channels*.
- **Foco:** cadena de arranque verificada, almacenamiento seguro de claves,
  deshabilitar interfaces de debug en producción, actualización firmada, hardening
  de memoria, gestión de secretos del dispositivo.

## 11. Data platforms / pipelines / analítica
- **Vectores:** acceso amplio a datos, fuga en datasets/no-prod, linaje opaco,
  *poisoning*, secretos en notebooks/jobs, exposición de almacenamiento.
- **Foco:** clasificación y mínimo acceso, enmascaramiento/anonimización en
  no-prod, gobierno y linaje, control de secretos en jobs, cifrado, auditoría de
  acceso a datos sensibles.

## 12. IA / ML / LLM / agentes
- **Vectores:** prompt injection, excessive agency, fuga de datos, poisoning,
  abuso de herramientas, system prompt leakage (ver seguridad de IA/LLM -> skill **vector**).
- **Foco:** OWASP LLM Top 10 + MITRE ATLAS + NIST AI RMF; aislamiento de
  herramientas, validación E/S, HITL en lo sensible, aislamiento RAG, evals.

## 13. Blockchain / smart contracts / Web3
- **Vectores:** reentrancy, errores de lógica/aritmética, control de acceso en
  contratos, manejo de claves/wallets, oráculos, *front-running*, gobernanza.
- **Foco:** auditoría de contratos, patrones seguros, gestión de claves (HSM/
  multisig), pruebas exhaustivas, control de upgrades, validación de oráculos.

## 14. Edge / CDN / distribuido geográficamente
- **Vectores:** superficie ampliada, consistencia/confianza entre nodos, datos en
  ubicaciones múltiples, gestión de claves distribuida, exposición física del nodo.
- **Foco:** identidad y cifrado entre nodos, mínimo de datos en el borde,
  hardening del nodo, gestión central de configuración y secretos, soberanía de
  datos por región.

## 15. Entornos especiales
- **Air-gapped / aislados:** vector dominante = medios extraíbles e *insider*;
  foco en control de medios, *data diodes*, control físico y procesos.
- **Híbrido / multi-nube:** identidad federada coherente, consistencia de
  controles entre entornos, soberanía de datos, anti *lock-in*.

---

## Regla transversal
Identifica el tipo (o combinación) de sistema **antes** de elegir el "qué mirar",
pero aplica los **mismos principios de fondo** y la **misma vara de evidencia** a
todos. No premies ni penalices por moda tecnológica: evalúa el **control real y su
eficacia** frente al **riesgo calibrado**.
