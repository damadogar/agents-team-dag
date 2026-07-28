# Seguridad defensiva — Centinela

Controles, hardening por capa y detection engineering para prevenir, detectar,
contener y corregir. Complementa [deteccion-respuesta.md](deteccion-respuesta.md)
(operación de detección e IR) y arquitectura segura -> skill **destroyer**.

---

## 1. Tipos de control

| Tipo | Objetivo | Ejemplos |
|---|---|---|
| **Preventivo** | Impedir el evento | MFA, mínimo privilegio, WAF, hardening, cifrado, allowlisting |
| **Detectivo** | Descubrir el evento | Logging, SIEM, EDR/XDR, IDS, FIM, detección de anomalías |
| **Correctivo** | Reducir/revertir impacto | Aislamiento, rollback, restore desde backup, revocación de credenciales |
| **Disuasivo** | Desincentivar | Banners legales, visibilidad de monitoreo, controles visibles |
| **Compensatorio** | Sustituto cuando el ideal no es viable | Monitoreo reforzado donde no se puede parchear aún |

Diseña en capas: cada vector crítico debe tener **al menos** preventivo +
detectivo, y un plan correctivo.

---

## 2. Hardening por capa (resumen; checklists en [checklists.md](checklists.md))

### 2.1 Identidad
MFA resistente a phishing en privilegiados/remoto; mínimo privilegio; PAM con
JIT/JEA; sin secretos de larga vida; recertificación de accesos; detección de
*impossible travel*, fuerza bruta y abuso de tokens.

### 2.2 Red
Segmentación/microsegmentación, default-deny, mTLS interno, egress filtering,
sin puertos de gestión expuestos, ZTNA en lugar de VPN plana, protección DDoS.

### 2.3 Endpoints / servidores
Líneas base CIS, EDR/XDR, *application allowlisting*, disk encryption, parcheo
gestionado, deshabilitar servicios/protocolos inseguros (SMBv1, LLMNR), FIM.

### 2.4 Aplicaciones / APIs
Validación de entrada y *output encoding*, authz server-side por objeto, headers
de seguridad (CSP, HSTS, X-Content-Type-Options, etc.), rate limiting, schema
validation en gateway, protección anti-bot/credential stuffing, OWASP ASVS como
baseline.

### 2.5 Datos
Clasificación, cifrado en tránsito/reposo, cifrado de campo para lo crítico,
tokenización/enmascaramiento, RLS/CLS, DLP, retención/borrado seguro.

### 2.6 Contenedores / Kubernetes
Imágenes mínimas y firmadas, escaneo de imágenes, *non-root*, read-only FS,
*drop capabilities*, seccomp/AppArmor, Pod Security Standards (restricted),
NetworkPolicies default-deny, RBAC mínimo, *secrets* en gestor (no en manifests),
admission control (OPA/Gatekeeper/Kyverno), sin privilegios `hostPath`/`privileged`.

### 2.7 Cloud
Ver §6 de arquitectura segura -> skill **destroyer**: cuentas
segregadas, guardrails, CSPM/CIEM, logging inmutable, CMK + rotación.

### 2.8 CI/CD
Ver DevSecOps -> skill **destroyer**: aislamiento de runners, OIDC en lugar de
secretos de larga vida, firma de artefactos, protección de ramas, gates.

### 2.9 LLM / agentes
Ver seguridad de IA/LLM -> skill **vector**: aislamiento de herramientas,
mínimo privilegio, validación de E/S, *human-in-the-loop* en acciones sensibles.

---

## 3. Detection engineering

Construir detección como producto de ingeniería (versionada, probada, medida).

### 3.1 Pipeline
1. **Mapear a ATT&CK:** qué TTPs amenazan el sistema (de ofensiva -> skill **cazador**).
2. **Identificar fuentes de telemetría** que evidencian cada TTP (logs, EDR, red,
   identidad, cloud audit). Sin telemetría no hay detección.
3. **Escribir casos de detección** (hipótesis → lógica → datos requeridos).
4. **Reducir falsos positivos:** baselining, enriquecimiento, *allowlists*,
   correlación; afinar antes de poner en guardia.
5. **Probar (detection testing):** atomic tests / BAS para validar que dispara.
6. **Medir y versionar:** cobertura ATT&CK, tasa de FP, MTTD; control de cambios.

### 3.2 Modelo de detección (jerarquía)
- **Indicadores** (IOC) — frágiles, caducan rápido.
- **Comportamientos / TTPs** — más robustos (pirámide del dolor de D. Bianco):
  priorizar TTPs y herramientas sobre hashes/IPs.
- **Anomalías** — baseline + ML/UEBA para desviaciones (con tuning fuerte).

### 3.3 Casos de detección prioritarios (genéricos)
- Autenticación: *impossible travel*, MFA fatigue, fuerza bruta/credential
  stuffing, creación/escalada de cuentas privilegiadas, cambios en federación.
- Endpoint: ejecución sospechosa (LOLBins), persistencia, dumping de credenciales,
  ejecución desde temp/descargas, manipulación de defensas.
- Red: beaconing/C2, DNS tunneling, exfiltración (volumen/destino anómalo),
  escaneo lateral.
- Cloud: cambios en IAM/políticas, desactivación de logging, acceso anómalo a
  almacenamiento, uso de credenciales desde IP/UA nuevos, creación de recursos
  para minería.
- Datos: acceso masivo/anómalo a datos sensibles, exportaciones grandes.
- App/API: pico de errores de authz (IDOR sweeps), abuso de endpoints, BOLA.

### 3.4 Tecnología (agnóstico)
SIEM (correlación, retención, búsqueda), EDR/XDR (endpoint + telemetría),
NDR/IDS (red), UEBA (comportamiento), SOAR (automatización de respuesta), TIP
(threat intel). Selecciona por contexto y madurez; ver [frameworks.md](frameworks.md)
(MITRE D3FEND para mapear defensas).

---

## 4. Defensa activa y engaño (deception)

Honeytokens (credenciales/llaves señuelo), honeypots, *canary* en buckets/DB y en
repos; alta señal y bajo ruido. No reemplaza controles, pero detecta lateralidad
e insiders con muy pocos falsos positivos.

---

## 5. Resiliencia y continuidad

- **Backups 3-2-1-1-0** (3 copias, 2 medios, 1 offsite, 1 offline/inmutable, 0
  errores de verificación); **probar el restore**, no solo el backup.
- **Inmutabilidad/WORM** anti-ransomware; backups fuera del dominio de identidad
  de producción.
- **DR:** RPO/RTO por criticidad, runbooks de recuperación, *game days*.
- **Degradación elegante** y aislamiento para contener sin caída total.

---

## 6. Mapeo a MITRE D3FEND

Para cada técnica ofensiva relevante (ATT&CK), mapea la contramedida defensiva
(D3FEND): *harden, detect, isolate, deceive, evict*. Usa esto para demostrar
**cobertura** y justificar inversiones por gap real, no por catálogo.

---

## 7. Checklist defensivo de cierre

```
- [ ] Cada vector crítico tiene preventivo + detectivo + plan correctivo
- [ ] Hardening por capa aplicado a líneas base reconocidas (CIS)
- [ ] Telemetría suficiente para los TTPs priorizados (sin gaps ciegos)
- [ ] Casos de detección escritos, afinados y probados (BAS/atomic)
- [ ] Cobertura ATT&CK medida; gaps priorizados
- [ ] Backups inmutables + restore probado; DR con RPO/RTO
- [ ] Métricas: MTTD/MTTR, % cobertura, tasa de FP
- [ ] Riesgo residual de detección/respuesta declarado
```
