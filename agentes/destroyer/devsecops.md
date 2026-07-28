# DevSecOps y Secure SDLC — Destroyer

Integrar seguridad en cada fase del ciclo de vida y en el pipeline. Marco base:
**NIST SSDF (SP 800-218)**, **OWASP SAMM/ASVS**, **SLSA** (supply chain),
**OWASP DSOMM**. Complementa defensiva -> skill **centinela** y
[arquitectura-seguridad.md](arquitectura-seguridad.md).

---

## 1. Seguridad por fase del SDLC (shift-left + shift-right)

| Fase | Actividades de seguridad | Entregable |
|---|---|---|
| **Requisitos** | Requisitos de seguridad/abuse cases, clasificación de datos, compliance | Security requirements + criterios de aceptación de seguridad |
| **Diseño** | Threat modeling (STRIDE), revisión de arquitectura, patrones seguros | Threat model + decisiones (ADR de seguridad) |
| **Desarrollo** | Secure coding, pre-commit hooks, secret scanning, linters de seguridad | Código que pasa gates locales |
| **Pruebas** | SAST, SCA, DAST, IaC scan, pruebas de authz, fuzzing donde aplique | Reporte consolidado + gate |
| **Despliegue** | Firma de artefactos, hardening, config segura, despliegue progresivo | Release firmado y verificado |
| **Operación** | Monitoreo, detección, gestión de vulnerabilidades, parcheo, IR | Telemetría + remediación continua |

**Shift-left** (encontrar temprano = más barato) **y shift-right** (validar en
runtime/producción de forma segura: RASP, *attack surface monitoring*, canary).

---

## 2. Controles en el pipeline CI/CD

> **Frontera de ownership (quién define vs. quién opera):** Destroyer/cluster **DEFINE
> el control de seguridad** — qué gates existen, qué severidad rompe el build, qué
> escáneres (SAST/SCA/DAST/IaC/secret scanning), la política de firma/SBOM/SLSA y las
> reglas de policy-as-code. La **infra/plataforma/pipeline (DevOps) la OPERA `baluarte`**
> (Primer Maestro de Plataforma, Entrega y Confiabilidad = DevOps + SRE + Platform
> Engineering): implementa y ejecuta el CI/CD, los runners, la orquestación y los entornos
> que corren esos gates. `baluarte` **opera** la plataforma que implementa el control,
> **no decide** el control de seguridad (eso es del cluster).

### 2.1 Análisis automatizado (gates)
- **SAST** (código estático): vulnerabilidades en el código propio.
- **SCA** (dependencias): CVEs en librerías y *transitivas*; licencias.
- **Secret scanning:** credenciales en código/historial (pre-commit + CI).
- **IaC scanning:** misconfig en Terraform/CloudFormation/K8s/Helm.
- **Container/image scanning:** vulnerabilidades de imagen base y capas.
- **DAST** (dinámico): app en ejecución (en staging), incl. API.
- **Fuzzing** donde el riesgo lo justifique (parsers, formatos, protocolos).

Política de **gate**: define qué severidad **rompe el build** (p. ej. crítica/alta
explotable) y qué se permite con **excepción documentada y con fecha**. Evita el
gate que todos ignoran: prioriza por explotabilidad (EPSS/contexto), no por
volumen bruto.

### 2.2 Higiene del pipeline (el pipeline es un objetivo de alto valor)
- **Aislamiento de runners**; efímeros; sin credenciales de larga vida.
- **OIDC federado** hacia la nube en lugar de *secrets* estáticos.
- **Mínimo privilegio** de tokens de CI; *scoped* por repo/entorno.
- **Protección de ramas:** PR obligatorio, *required reviews*, *required checks*,
  firma de commits, sin force-push a main.
- **Aprobaciones de despliegue** a entornos sensibles; *deployment environments*.
- **Inmutabilidad y procedencia:** artefactos versionados y firmados.

---

## 3. Seguridad de la cadena de suministro (supply chain)

Riesgo creciente (dependencias, build, distribución). Controles:
- **SBOM** (CycloneDX/SPDX) generado y conservado por release.
- **Firma de artefactos y procedencia** (Sigstore/cosign, in-toto, SLSA
  *provenance*); verifica firma antes de desplegar.
- **SLSA** como marco de madurez de integridad del build (niveles crecientes:
  fuente, build, procedencia, aislamiento).
- **Pinning** de dependencias/imágenes por hash; *lockfiles*; mirrors internos.
- **Dependency review** en PR; política de actualización y de paquetes permitidos.
- **Verificación de acciones de CI de terceros** (pin por SHA, no por tag móvil).
- **Modelos de IA como dependencia:** procedencia y verificación del modelo/pesos
  (ver seguridad de IA/LLM -> skill **vector**).

---

## 4. Gestión de secretos

- **Secrets manager** centralizado (Vault, cloud KMS/Secrets Manager); nunca en
  código, env commit, imágenes, ni logs.
- **Identidades efímeras** y *short-lived tokens*; rotación automática.
- **Detección + remediación:** secret scanning en repos e historial; si un
  secreto se expone, **rotarlo** (no solo borrarlo del repo).
- **Mínimo privilegio** del secreto y *scoping* por entorno.

> **Frontera:** Destroyer **define** la política de secretos/cripto (qué se cifra, cómo se
> rota, mínimo privilegio, prohibición de secretos de larga vida). La infra/plataforma
> (**`baluarte`**) **opera** el secrets manager/KMS, la rotación automática y la federación
> OIDC del pipeline; opera el gestor, no decide la política de seguridad.

---

## 5. Gestión de vulnerabilidades

- **Priorización por riesgo**, no por conteo: **CVSS + EPSS + contexto**
  (exposición, explotación activa en KEV de CISA, criticidad del activo).
- **SLAs de remediación** por severidad (ver matriz en GRC -> skill **sello**).
- **Excepciones controladas:** con dueño, justificación, control compensatorio y
  **fecha de vencimiento**; nunca excepción perpetua silenciosa.
- **Flujo:** detectar → priorizar → asignar dueño → remediar/mitigar → verificar →
  cerrar; métricas de *mean time to remediate* y *backlog* por severidad.

---

## 6. Políticas mínimas de calidad de seguridad

```
- [ ] Threat model para features que tocan datos sensibles, auth o exposición
- [ ] PR con revisión + checks de seguridad obligatorios para mergear
- [ ] Secret scanning bloqueante (pre-commit + CI)
- [ ] SCA/SAST/IaC en cada PR; gate por severidad definido
- [ ] DAST en staging antes de release
- [ ] Artefactos firmados + SBOM por release
- [ ] Sin secretos de larga vida en CI (OIDC); runners aislados
- [ ] Despliegue progresivo con rollback (canary/blue-green)
- [ ] Gestión de vulnerabilidades con SLA y excepciones con vencimiento
```

---

## 7. Madurez (OWASP SAMM / DSOMM)

Evalúa madurez por dominio (gobierno, diseño, implementación, verificación,
operación) y propón una **ruta incremental**. No exijas nivel 3 en todo desde el
día uno: prioriza por riesgo y por *quick wins* de alto impacto (secret scanning,
SCA, MFA en CI, protección de ramas) antes de capacidades avanzadas (fuzzing
continuo, SLSA alto, RASP).

---

## 8. Anti-patrones DevSecOps

- Gate que genera miles de hallazgos sin priorización → todos lo ignoran.
- Escáner sin dueño de remediación ni SLA → ruido sin reducción de riesgo.
- Secretos "temporales" en variables de CI que se vuelven permanentes.
- Seguridad solo al final (auditoría pre-release) en lugar de continua.
- Confiar en tags móviles de acciones/imágenes de terceros.
