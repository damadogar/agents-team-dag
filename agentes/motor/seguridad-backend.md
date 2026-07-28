# seguridad-backend.md — Seguridad backend

> Seguridad desde el diseño, no como añadido. Consulta esto para authn/authz,
> protección de datos, hardening, OWASP y compliance.

## 1. Principios

- **Defensa en profundidad**, **menor privilegio**, **fail securely**,
  **secure by default**, **no confíes en el cliente**, **minimiza superficie**.
- **Zero Trust**: autentica y autoriza cada petición; no asumas confianza por red.
- **Separación de secretos del código y de la configuración**.

## 2. Autenticación (authn)

- **Usuarios**: password (Argon2id/bcrypt/scrypt, nunca SHA simple ni texto
  plano), MFA/TOTP/WebAuthn-passkeys, políticas de bloqueo y rate limiting de
  login. Considera passwordless.
- **Federación / SSO**: **OIDC** sobre OAuth2 (Authorization Code + PKCE para
  apps públicas/SPAs/móvil). No uses Implicit ni ROPC (deprecados).
- **Servicio-a-servicio**: mTLS, client credentials (OAuth2), o tokens de
  identidad de workload (SPIFFE/SVID).
- **Tokens**:
  - **JWT** (stateless): firma con RS256/ES256 (asimétrica) o EdDSA; valida
    `iss`, `aud`, `exp`, `nbf`, firma y `kid`. Cortos de vida.
  - **Refresh tokens**: opacos, almacenados, rotación + detección de reuso.
  - **Revocación**: JWT puro no se revoca fácil → access tokens cortos + lista de
    revocación/`jti` o tokens de referencia (introspección) para casos críticos.
  - **Sesiones server-side** (cookie httpOnly/Secure/SameSite) siguen siendo
    excelentes para apps web; no todo necesita JWT.

## 3. Autorización (authz)

- **RBAC** (roles) para la mayoría; **ABAC/PBAC** (atributos/políticas) para
  reglas finas y contextuales; **ReBAC** (relaciones, estilo Google Zanzibar /
  OpenFGA) para permisos por recurso a escala.
- **Autoriza en el backend, en cada request**, lo más cerca del recurso posible.
- **BOLA/IDOR (OWASP API #1)**: valida *ownership*/tenant en CADA acceso a un
  objeto por id. Nunca confíes en ids del cliente sin verificar.
- **Multi-tenancy**: aísla por tenant en datos (RLS, tenant_id en cada query),
  y verifica el tenant del principal en cada operación.
- Centraliza la decisión (policy engine: OPA/Cedar/OpenFGA) cuando crece la
  complejidad; evita reglas dispersas.

## 4. Protección de datos

- **En tránsito**: TLS 1.2+/1.3 en todo (incluido interno; mTLS entre servicios).
  HSTS en el borde.
- **En reposo**: cifrado de DB/discos/backups; cifrado a nivel de campo para PII
  altamente sensible (tokenización para PCI).
- **Gestión de claves**: KMS/HSM, rotación, separación de deberes; nunca claves
  en código.
- **Secretos**: vault gestionado (HashiCorp Vault, AWS Secrets Manager, Azure Key
  Vault, GCP Secret Manager), inyección en runtime, rotación. **gitleaks** en CI.
- **Datos sensibles en logs**: nunca loguees secretos/PII/tokens; enmascara.

## 5. Secure coding y validación

- **Valida toda entrada** (allowlist > denylist), en el servidor, por esquema.
- **Inyección**:
  - SQL: **consultas parametrizadas/ORM**, jamás concatenar input.
  - NoSQL/LDAP/OS command/SSTI: sanitiza y usa APIs seguras; evita `eval`/exec con
    input.
  - Deserialización insegura: evita deserializar tipos arbitrarios.
- **Salida**: codifica según contexto (aunque XSS es más frontend, las APIs deben
  evitar reflejar HTML sin sanitizar).
- **SSRF**: valida/allowlist URLs salientes; bloquea rangos internos/metadata
  (169.254.169.254). Crítico en features que fetchean URLs del usuario.
- **Upload de archivos**: valida tipo/tamaño, escanea, almacena fuera del root,
  nombres aleatorios, sin ejecución.
- **Mass assignment**: usa DTOs explícitos; no bindees el body directo a entidades.

## 6. Hardening de plataforma

- TLS, cabeceras de seguridad (HSTS, CSP donde aplique, `X-Content-Type-Options`),
  CORS restrictivo (no `*` con credenciales).
- **Rate limiting / throttling / WAF** contra fuerza bruta, scraping, DoS L7.
- Contenedores: imágenes mínimas (distroless), no root, read-only FS, escaneo
  (Trivy/Grafeas), firma (cosign/SBOM). Ver [cloud-plataforma.md](cloud-plataforma.md).
- **IAM least-privilege**, sin credenciales de larga vida (roles/OIDC federado).
- Parchado y gestión de vulnerabilidades de dependencias (SCA: `npm audit`,
  Dependabot, Snyk). SAST en CI (Semgrep, CodeQL).

## 7. OWASP (marcos de referencia)

- **OWASP Top 10 (web)**: broken access control, fallos criptográficos,
  inyección, diseño inseguro, misconfiguration, componentes vulnerables,
  identificación/auth fallida, integridad de software/datos, fallos de
  logging/monitoring, SSRF.
- **OWASP API Security Top 10**: BOLA, broken authn, BOPLA (property level),
  consumo de recursos sin límite, BFLA (function level), acceso a flujos de
  negocio sensibles, SSRF, misconfig, inventario impropio, consumo inseguro de
  APIs.
- **OWASP ASVS** como checklist de verificación por niveles (L1/L2/L3).
- **LLM**: OWASP Top 10 for LLM (prompt injection, etc.) — ver
  [ia-llm-backend.md](ia-llm-backend.md).

## 8. Auditoría, trazabilidad y detección

- **Audit log** inmutable (append-only) de acciones sensibles: quién, qué,
  cuándo, desde dónde, resultado. Útil para forense y compliance.
- **Logging de seguridad**: intentos de login, cambios de permisos, accesos
  denegados; alertas. Integra con SIEM si aplica.
- **Detección y respuesta a incidentes** — ver [observabilidad-operacion.md](observabilidad-operacion.md).

## 9. Compliance y gobierno (según dominio)

- GDPR/Habeas Data (privacidad, consentimiento, derecho al olvido, DPA), PCI-DSS
  (pagos), HIPAA (salud), SOC 2 / ISO 27001 (controles), residencia de datos.
- Mapea requisitos a controles técnicos concretos; no es solo papeleo.
- **Privacy by design**: minimización de datos, propósito limitado, retención
  acotada, seudonimización.

## 10. Checklist de seguridad

```
- [ ] Authn robusta (hashing fuerte, MFA, OIDC+PKCE; tokens cortos + rotación)
- [ ] Authz en backend por request; anti-BOLA/IDOR; aislamiento multi-tenant
- [ ] TLS en todo (mTLS interno); cifrado en reposo; KMS + rotación
- [ ] Secretos en vault; gitleaks/SAST/SCA en CI; sin secretos en logs
- [ ] Validación de entrada por esquema; consultas parametrizadas; anti-SSRF
- [ ] Rate limiting / WAF; CORS y cabeceras correctas
- [ ] Contenedores/IAM con menor privilegio; imágenes escaneadas/firmadas
- [ ] Audit log inmutable de acciones sensibles + alertas
- [ ] OWASP Top 10 / API Top 10 / ASVS revisados
- [ ] Requisitos de compliance del dominio mapeados a controles
```
