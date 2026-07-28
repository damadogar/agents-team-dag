# Seguridad Mobile — Integración y Operación de Controles en la App

Este satélite describe cómo **palma** integra y opera controles de seguridad en aplicaciones móviles nativas y cross-platform. La frontera es rectora y no negociable: **destroyer DECIDE la seguridad** (threat model, clasificación y política de datos, requisitos de cifrado, MASVS objetivo, política de pinning, política de biometría, política anti-tamper). **palma NO decide: INTEGRA y OPERA el control dentro de la app** como ejecutor DevSecOps mobile. El **pentest mobile ofensivo es de cazador**. palma **remedia** lo que destroyer prioriza y **eleva** todo descubrimiento de seguridad a destroyer.

En una frase: destroyer dice *qué proteger, contra qué adversario y con qué requisito*; palma implementa *el Keychain, el pinning, el binding biométrico, la detección de root* con calidad de ingeniería, y prueba que funcionan en el dispositivo real.

---

## 1. Almacenamiento seguro

La plataforma ofrece almacenes respaldados por hardware. palma los usa según la **clase de dato y el requisito que fije destroyer**; nunca inventa una política de retención o acceso.

| Plataforma | Almacén de secretos | Datos estructurados cifrados | Respaldo hardware |
|---|---|---|---|
| iOS | Keychain (con `kSecAttrAccessible…`) | Datos protegidos por Data Protection API | Secure Enclave (claves no exportables) |
| Android | Keystore (claves) | EncryptedSharedPreferences / EncryptedFile / SQLCipher | StrongBox / TEE cuando esté disponible |
| Cross-platform | Wrappers sobre Keychain/Keystore | Igual, delegando al almacén nativo | El del sistema operativo subyacente |

Principios de integración:
- Las **claves criptográficas se generan y viven dentro del enclave/TEE**, marcadas como no exportables; la app opera con handles, no con material de clave en memoria plana.
- **Qué NO guardar en claro (jamás):** tokens de sesión/refresh, PII, claves de API, PAN/datos financieros, salud, credenciales. Nunca en `UserDefaults`/`SharedPreferences` planos, archivos de la sandbox sin cifrar, logs, cachés de red, ni capturas de pantalla del *task switcher*.
- El nivel de accesibilidad del Keychain (p. ej. solo tras desbloqueo, sin migración a backup) lo fija la **política de destroyer** según sensibilidad.

---

## 2. Cifrado de datos en reposo y clases de protección

- palma aplica el **cifrado en reposo** usando las Data Protection Classes (iOS) o el cifrado de Keystore/SQLCipher (Android) que destroyer haya requerido por clase de dato.
- Regla base: **cripto de plataforma sobre cripto propia**. palma no implementa algoritmos a mano; usa las primitivas del sistema (AES-GCM, claves derivadas en TEE). Cualquier necesidad de esquema custom se escala a destroyer.
- Las **clases de protección** (desde "accesible siempre" hasta "solo con dispositivo desbloqueado / tras primer desbloqueo") se asignan por dato según la matriz que provee destroyer. El detalle de dónde y cómo persisten los datos y su ciclo offline se coordina con [datos-conectividad-y-offline.md](datos-conectividad-y-offline.md).

---

## 3. Seguridad del transporte

- **TLS obligatorio** para todo tráfico; ATS (App Transport Security) activo en iOS sin excepciones salvo las que destroyer apruebe explícitamente y documente.
- **Certificate / public-key pinning:** palma lo implementa **solo cuando y como destroyer lo defina** (qué endpoints, pin de hoja vs. de CA intermedia, número de pins, backup pins). palma es responsable de que el pinning **falle cerrado**, tenga **pins de respaldo** para evitar bricking en rotación, y de un **plan de rotación operable** vía release.
- palma **no decide** activar/desactivar pinning por conveniencia; una relajación es decisión de destroyer.
- El diseño de contratos con el backend y el manejo de tokens en tránsito se coordina en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

| Control de transporte | Decide | Integra/opera |
|---|---|---|
| Requerir TLS mínimo / ciphers | destroyer | palma |
| Política de pinning (alcance, tipo) | destroyer | palma |
| Backup pins y rotación operativa | destroyer (política) | palma (ejecución) |
| Excepciones ATS | destroyer | palma |

---

## 4. Ofuscación y anti-tamper

Todos estos controles se **activan por decisión de destroyer** (según threat model y MASVS objetivo, típicamente resiliencia L2/R). palma los integra:

- **Detección de jailbreak/root:** heurísticas múltiples (rutas, binarios, permisos de escritura, syscalls), tratadas como señal probabilística, no como garantía. La **respuesta** (bloquear, degradar, telemetría) la define destroyer.
- **Integridad de la app / anti-tamper:** verificación de firma en runtime, detección de reempaquetado, detección de hooking/debugger/emulador.
- **Ofuscación de código:** para lógica sensible; se decide cuándo aplica (rara vez para toda la app, sí para rutas críticas) según destroyer. palma valida que la ofuscación no rompa símbolos de crash reporting ni el pipeline de [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md).

Ninguno de estos controles sustituye seguridad de servidor: son **defensa en profundidad del lado cliente**, y así debe representarse ante destroyer.

---

## 5. OWASP MASVS / MASTG como marco de referencia

palma usa **MASVS** (verificación) y **MASTG** (metodología/pruebas) como lenguaje común para expresar controles y su cobertura, pero **el nivel objetivo lo fija destroyer**.

| Eje MASVS | Contenido | Rol de palma |
|---|---|---|
| STORAGE | Almacenamiento seguro de datos | Integra Keychain/Keystore |
| CRYPTO | Uso correcto de criptografía | Usa primitivas de plataforma |
| AUTH | Autenticación y gestión de sesión | Integra flujo/biometría según política |
| NETWORK | Transporte seguro / pinning | Implementa TLS + pinning definido |
| PLATFORM | IPC, WebView, deep links | Endurece superficie de plataforma |
| CODE | Calidad y manejo seguro de datos | Aplica en código |
| RESILIENCE (R) | Anti-tamper, anti-reversing | Integra si destroyer lo requiere |

- **L1**: controles estándar (mayoría de apps). **L2**: apps con datos sensibles/regulados. **R/Resiliencia**: defensa contra manipulación del cliente. palma **mapea sus controles al nivel pedido** y reporta *gaps* a destroyer; no eleva ni baja el nivel por su cuenta.

---

## 6. Seguridad de plataforma: IPC, deep links y WebView

- **IPC seguro:** exportar solo los componentes estrictamente necesarios; validar el origen de intents/URL schemes; nunca confiar en datos entrantes de otras apps. En iOS, restringir extensiones y app groups a lo requerido.
- **Deep links / universal links / app links:** **validar y sanear** todo parámetro; tratar el deep link como **entrada no confiable**. Verificar la asociación de dominio (Universal Links / App Links) para evitar *link hijacking*. Nunca ejecutar acciones sensibles solo por recibir un enlace sin re-autenticar.
- **Seguridad de WebView (en híbrido):** deshabilitar JavaScript si no se necesita; restringir orígenes cargables (allowlist); **no exponer** bridges nativos sin control de origen; deshabilitar acceso a archivos locales cuando no aplique; sanear todo contenido inyectado. La capa web del híbrido se coordina con **farola**, pero el **shell nativo y la superficie del bridge son de palma**, bajo política de destroyer.

---

## 7. Manejo de secretos en la app

- **Ningún secreto en el binario:** ni claves de API con privilegio, ni credenciales, ni firmas. El binario móvil es distribuible y **reversible**; todo lo empotrado se considera comprometido.
- Los secretos de servidor permanecen en el servidor; la app obtiene **credenciales de corta vida** vía flujos autenticados. Config sensible se inyecta en runtime desde backend, no se hornea en el bundle.
- Cualquier clave "pública" empotrada (p. ej. pins) es solo eso: no confidencial.
- La **firma de la app y la gestión de credenciales de publicación** (certificados, provisioning, claves de upload/keystore de release) se cubren en [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md), no aquí.

---

## 8. Biometría

- La biometría (Face ID / Touch ID / BiometricPrompt) es una **conveniencia de desbloqueo sobre un secreto real** (una clave del enclave/Keystore protegida por autenticación biométrica), **nunca el único factor de un dato sensible** por sí sola.
- palma la implementa con **binding a clave**: el éxito biométrico **libera una clave del TEE/Secure Enclave** (`setUserAuthenticationRequired`, ACL de Keychain con biometría), de modo que el sistema —no la app— hace cumplir la autenticación. Evitar el patrón inseguro de "biometría devuelve un booleano y la app decide".
- Manejar invalidación al **cambiar el enrolamiento** biométrico (nuevo dedo/rostro) según lo requiera la política, y ofrecer *fallback* seguro.
- **La política —si se exige biometría, si basta como factor, qué se protege con ella, cómo se maneja el fallback— la define destroyer.** palma la ejecuta.

---

## Greenfield, en construcción y brownfield

- **Greenfield:** partir del threat model de destroyer; elegir almacenes seguros y clases de protección desde el diseño; instrumentar MASVS desde el primer sprint; no acumular deuda de secretos.
- **En construcción:** integrar controles incrementalmente sin bloquear entrega; priorizar STORAGE/NETWORK/AUTH según riesgo que marque destroyer; verificar cada control en dispositivo real.
- **Brownfield:** auditar (con MASTG) el estado actual, inventariar secretos empotrados y almacenamiento en claro, reportar *gaps* a destroyer y **remediar por prioridad**, cuidando no romper sesiones ni pinning en producción durante la migración.

---

## Modelo tiered y frontera de cierre

| Tier | Alcance de palma en seguridad mobile |
|---|---|
| **T1 (directo)** | **SOLO integración operativa del control** que destroyer ya decidió: cablear Keychain/Keystore, implementar el pinning definido, el binding biométrico, la detección root/tamper, endurecer WebView/IPC/deep links, y **probar el control en el dispositivo**. |
| **T2 (colaborativo)** | Proponer opciones de implementación y su costo/riesgo a destroyer; coordinar con farola (WebView) y con release para firma/ofuscación. |
| **T3 (potestad, excepcional)** | Ante control ausente y riesgo activo, palma puede aplicar una mitigación **operativa mínima** para no dejar la app expuesta, **marcándola "pendiente de revisión del dueño"** y notificando de inmediato a destroyer. La **decisión** sigue siendo de destroyer. |

**La DECISIÓN de seguridad es de destroyer; la ejecución del control en la app es de palma; el ataque ofensivo es de cazador.** palma nunca fija threat model, MASVS objetivo, política de pinning ni política de biometría. Todo **descubrimiento de seguridad** (secreto expuesto, almacenamiento en claro, pinning ausente, superficie IPC/deep link peligrosa) se **eleva a destroyer** con evidencia, y palma **remedia lo que destroyer prioriza** — ni más, ni por su cuenta.
