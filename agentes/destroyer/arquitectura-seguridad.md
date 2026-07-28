# Arquitectura de seguridad — Destroyer

Diseño de sistemas seguros "by design": Zero Trust, defensa en profundidad,
identidad, red, datos, cloud, SaaS multi-tenant y OT/ICS. Acompaña a §3 de
[SKILL.md](SKILL.md).

---

## 1. Principios de arquitectura segura

- **Security & privacy by design / by default.** El estado seguro es el estado
  inicial; abrir es una decisión explícita y auditada.
- **Defensa en profundidad.** Capas independientes (red, host, app, datos,
  identidad) que no comparten modo de fallo. Ningún control único es suficiente.
- **Mínimo privilegio + need-to-know.** Cada identidad (humana o de máquina)
  recibe solo el acceso necesario, por el tiempo necesario (JIT/JEA).
- **Separación de funciones (SoD).** Quien aprueba no ejecuta; quien desarrolla
  no despliega a prod sin gate.
- **Fail-safe / fail-closed.** Ante fallo o duda, deniega (salvo que la
  disponibilidad sea el activo crítico dominante → decisión explícita).
- **Secure defaults.** Cifrado activado, puertos cerrados, cuentas sin permisos
  por defecto, MFA obligatorio.
- **Superficie mínima.** Menos código, menos puertos, menos dependencias, menos
  privilegios = menos ataque.
- **Reducción del radio de explosión (blast radius).** Segmentación, aislamiento
  de cuentas/tenants, límites de confianza claros.
- **Inmutabilidad y reproducibilidad.** Infra como código, imágenes firmadas,
  despliegues reproducibles; nada cambia "a mano" en prod.

---

## 2. Zero Trust (NIST SP 800-207)

**Premisa:** "never trust, always verify". La red **no** es un perímetro de
confianza. Cada acceso se evalúa por identidad + dispositivo + contexto + riesgo.

Pilares:
1. **Identidad fuerte:** MFA resistente a phishing (FIDO2/WebAuthn), identidad de
   workloads (SPIFFE/SVID, managed identities), no secretos de larga vida.
2. **Dispositivo/postura:** salud del endpoint como condición de acceso.
3. **Microsegmentación:** segmentación por carga/servicio, no por subred plana.
4. **Acceso por política dinámica (PEP/PDP):** un Policy Decision Point evalúa
   cada request; el Policy Enforcement Point la aplica.
5. **Cifrado extremo a extremo (mTLS) entre servicios.**
6. **Telemetría continua:** toda decisión de acceso es observable y auditable.

Patrones de adopción: ZTNA en lugar de VPN plana; service mesh con mTLS y
authz por servicio; *identity-aware proxy* para apps internas; acceso a datos
mediante broker con políticas, no conexión directa.

> Zero Trust es un **viaje**, no un producto. Prioriza identidad y
> microsegmentación primero; evita el "Zero Trust de marketing" de un único vendor.

---

## 3. Arquitectura de identidad (IAM / PAM)

- **Autenticación:** MFA en todo acceso privilegiado y remoto; **passwordless /
  FIDO2** preferido; SSO federado (OIDC/SAML); evita MFA débil (SMS/OTP) donde el
  riesgo lo justifique (phishing/SIM-swap).
- **Autorización:** RBAC como base, ABAC/ReBAC donde la granularidad lo exige;
  **deny by default**; revisión periódica de accesos (access recertification).
- **PAM (acceso privilegiado):** bóveda de credenciales, *check-out* con
  aprobación, sesiones grabadas, JIT (Just-In-Time) y JEA (Just-Enough-Access),
  rotación automática, eliminación de cuentas con privilegio permanente.
- **Identidad de máquina/workload:** SPIFFE/SPIRE, managed identities (cloud),
  short-lived tokens; **prohibido** secretos de larga vida hardcodeados.
- **Federación y B2B:** límites de confianza claros, *guest* con permisos
  acotados, *conditional access* por contexto y riesgo.
- **Lifecycle (JML):** Joiner-Mover-Leaver automatizado; desaprovisionamiento
  inmediato; cero cuentas huérfanas.

---

## 4. Arquitectura de datos

- **Clasificación:** público / interno / confidencial / restringido (PII, PCI,
  PHI, secretos). La clasificación gobierna los controles.
- **Cifrado en tránsito:** TLS 1.2+ (preferible 1.3), mTLS interno; sin
  protocolos/cifras obsoletas.
- **Cifrado en reposo:** a nivel de volumen/DB (TDE) y, para datos altamente
  sensibles, **a nivel de campo/aplicación** con KMS/HSM y rotación de llaves;
  *envelope encryption*; separación de deberes en custodia de llaves.
- **Tokenización / enmascaramiento / anonimización** de PII en entornos no
  productivos y en exposición a terceros/IA.
- **Acceso mínimo a datos:** RLS/CLS, *data access broker*, sin conexiones
  directas amplias; *query auditing* sobre datos sensibles.
- **Retención y borrado:** políticas de retención, *secure deletion*, derecho al
  olvido donde aplique; linaje de datos.
- **DLP:** prevención de fuga en endpoints, correo, SaaS y, cada vez más, en
  prompts/outputs de IA.

---

## 5. Arquitectura de acceso y red

- **Segmentación:** zonas (DMZ, app, datos, gestión, OT) con flujos explícitos;
  microsegmentación dentro de zonas; *default deny* entre segmentos.
- **Bordes:** WAF (con reglas afinadas, no solo OWASP CRS por defecto), API
  Gateway (authn/authz, rate limiting, schema validation), CDN/anti-DDoS,
  *bot management*.
- **Acceso remoto:** ZTNA > VPN plana; *bastion*/jump host con grabación para
  administración; sin RDP/SSH expuestos a Internet.
- **Egreso controlado:** *egress filtering* y proxies; relevante contra
  exfiltración y C2 (y contra SSRF a metadata).
- **DNS:** filtrado/seguridad DNS, detección de tunneling y dominios maliciosos.
- **Service-to-service:** mTLS + authz por servicio (service mesh / sidecar).

---

## 6. Arquitectura cloud segura (AWS / Azure / GCP)

Patrones transversales (referencias en [frameworks.md](frameworks.md) — WAF de
cada nube, CIS Benchmarks):

- **Landing zone / org segura:** múltiples cuentas/proyectos/suscripciones por
  blast radius (prod/no-prod/seguridad/log-archive); SCP/Org Policies/Management
  Groups como guardrails; cuenta de logging centralizada e inmutable.
- **Identidad:** SSO central, roles federados, **sin usuarios IAM con llaves de
  larga vida**; permisos mínimos con análisis de acceso (Access Analyzer / PIM /
  IAM Recommender); MFA en root/global admin y *break-glass* controlado.
- **Red:** VPC/VNet privadas, *private endpoints/PrivateLink*, sin buckets/blobs
  públicos por defecto, NSG/Security Groups restrictivos, egreso controlado.
- **Datos:** cifrado con CMK gestionadas, rotación, *key policies* mínimas;
  bloqueo de acceso público a almacenamiento.
- **Detección nativa:** GuardDuty/Defender for Cloud/SCC, Config/Policy para
  *compliance as code*, CloudTrail/Activity Log/Audit Logs **inmutables y
  centralizados**.
- **CSPM/CIEM/CWPP:** postura, derechos de identidad y protección de workloads.
- **Metadata service:** IMDSv2 / restricción de acceso (mitiga SSRF→credenciales).
- **Anti-patrones:** cuenta única monolítica, llaves de acceso de larga vida,
  `0.0.0.0/0` en puertos de gestión, secretos en variables/AMIs, logging
  desactivado o mutable.

---

## 7. SaaS multi-tenant

- **Aislamiento de tenant:** define el modelo (silo / pool / híbrido) y **aplícalo
  en cada capa** (red, cómputo, datos, caché, logs). El *tenant context* va en un
  token verificado, **nunca** en un parámetro manipulable por el cliente.
- **Defensa contra cross-tenant:** toda query/recurso lleva *tenant_id*
  verificado en backend (no confiar en el cliente); pruebas específicas de
  *cross-tenant access* (clase IDOR a escala de tenant).
- **Llaves por tenant** para datos altamente sensibles; *noisy neighbor* y límites
  de cuota por tenant.
- **Onboarding/offboarding:** aprovisionamiento y borrado seguro de datos por
  tenant; exportación/portabilidad controlada.

---

## 8. OT / ICS / IoT (cuando aplica)

- **Modelo Purdue / IEC 62443:** segmentación por niveles; DMZ industrial entre
  IT y OT; flujos unidireccionales (data diodes) donde sea posible.
- **Prioridad invertida:** en OT prima **disponibilidad y seguridad física
  (safety)**; cambios y parcheo con ventanas y validación rigurosa.
- **Visibilidad pasiva:** monitoreo que no interfiera con procesos; inventario de
  activos OT; detección de protocolos industriales.
- **IoT:** identidad por dispositivo, *secure boot*, firma de firmware, OTA
  seguro, no credenciales por defecto, segmentación de la flota.

---

## 9. Patrones recomendados vs. descartados (guía)

| Recomendado | Por qué | Descartado / con cuidado | Por qué |
|---|---|---|---|
| Zero Trust + microsegmentación | Limita movimiento lateral | "Castillo y foso" (perímetro plano) | Una brecha = todo comprometido |
| MFA resistente a phishing (FIDO2) | Anula robo de credenciales | MFA por SMS como único factor | Phishing / SIM-swap |
| Secrets manager + rotación | No exposición, trazable | Secretos en código/env/repos | Fuga garantizada con el tiempo |
| mTLS service-to-service | Identidad + cifrado interno | Confianza por red interna | Lateralidad tras brecha |
| IaC + policy-as-code | Reproducible, auditable, guardrails | Cambios manuales en prod | Drift, error, no auditable |
| Egress filtering | Frena exfiltración/C2/SSRF | Egreso abierto | Exfiltración silenciosa |
| Cuentas/tenants segregados | Blast radius acotado | Cuenta cloud monolítica | Compromiso total |

---

## 10. Checklist de revisión de arquitectura

```
- [ ] Límites de confianza y flujos de datos dibujados (DFD) y revisados
- [ ] Threat model hecho sobre la arquitectura (STRIDE por elemento)
- [ ] Identidad: MFA fuerte, mínimo privilegio, sin secretos de larga vida
- [ ] Segmentación / microsegmentación y default-deny entre zonas
- [ ] Datos clasificados; cifrado en tránsito y reposo; PII protegida
- [ ] Secret management + rotación; nada de secretos en código/logs
- [ ] Cloud: cuentas segregadas, guardrails (SCP/Policy), logging inmutable
- [ ] Egress controlado; metadata service protegido (IMDSv2)
- [ ] Observabilidad/auditoría suficiente para detectar e investigar
- [ ] Patrones inseguros identificados y descartados con justificación
- [ ] Riesgo residual declarado por decisión de arquitectura
```
