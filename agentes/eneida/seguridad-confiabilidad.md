# Seguridad, Confiabilidad, Observabilidad y Operación (primera clase)

Eneida trata estas cuatro como preocupaciones de **primera clase desde el
diseño**, no como añadidos posteriores.

---

## 1. Seguridad por diseño

**Threat modeling con STRIDE** (hazlo cuando el riesgo lo amerite):
- **S**poofing → autenticación fuerte.
- **T**ampering → integridad (firmas, hashing, validación).
- **R**epudiation → logs/auditoría no repudiables.
- **I**nformation disclosure → cifrado y control de acceso.
- **D**enial of service → rate limiting, cuotas, autoscaling.
- **E**levation of privilege → menor privilegio, separación de roles.

Complementa con **clasificación de datos** (público/interno/confidencial/PII) y
**superficie de ataque** mínima.

### 1.b Zero Trust (NIST SP 800-207)

Modelo de seguridad por defecto en entornos enterprise: **"nunca confíes,
verifica siempre"**. No hay red interna de confianza implícita; cada acceso se
verifica por identidad, dispositivo y contexto.

Principios:
- **Verificación explícita y continua**: autentica y autoriza en cada solicitud
  con la máxima señal disponible (identidad, salud del dispositivo, ubicación,
  comportamiento), no solo al inicio de sesión.
- **Mínimo privilegio just-in-time**: acceso acotado en alcance y tiempo
  (JIT/JEA), elevación temporal con auditoría.
- **Asumir brecha**: micro-segmentación, radio de impacto mínimo, cifrado
  extremo a extremo, telemetría y detección continua.
- **Identidad como perímetro**: el control de acceso se basa en identidad
  (usuario/servicio/carga), no en la ubicación de red. mTLS y workload identity
  entre servicios.
- **Política centralizada (PDP/PEP)**: motor de decisión de políticas que evalúa
  cada acceso; puntos de aplicación distribuidos.

> Aplícalo gradualmente: empieza por identidades fuertes (MFA, SSO), inventario
> de activos y segmentación de lo crítico; evita el "big bang". Cruza con AWS/
> Azure/GCP WAF pilar de Seguridad (`frameworks.md`).

**Controles base (OWASP):**
- **AuthN/AuthZ robustas**: OIDC/OAuth2, MFA, RBAC/ABAC, sesiones/tokens seguros,
  rotación; deny by default.
- **Cifrado** en tránsito (TLS) y en reposo; gestión de claves (KMS/HSM).
- **Gestión de secretos** fuera del código (vault/secret manager); nunca en git.
- **Validación de entrada** y salida (anti-inyección, anti-XSS, sanitización).
- **Supply chain**: SCA de dependencias, SBOM, firma de artefactos, escaneo de
  imágenes, pin de versiones.
- **DevSecOps**: SAST/DAST/secret-scanning en CI; gates que bloquean.
- Cumplimiento según dominio: PCI-DSS, HIPAA, GDPR, Habeas Data, SOC2, ISO 27001.

---

## 2. Confiabilidad (SRE)

> Fundamentos de SRE/DORA y sus métricas en `frameworks.md §3`; aquí su
> aplicación operativa.

- **SLI** (indicador) → **SLO** (objetivo interno) → **SLA** (compromiso
  externo). El SLO es más estricto que el SLA.
- **Error budget**: si se agota, se congelan features y se prioriza fiabilidad.
- **Eliminar toil** con automatización; **postmortems sin culpa**.
- **Despliegues progresivos**: canary, blue-green, feature flags, rollback
  automático. Cambios pequeños y frecuentes (DORA).
- Diseña para **RTO/RPO**; prueba la recuperación (game days, chaos).
- Patrones de estabilidad: circuit breaker, timeout, retry+jitter, bulkhead,
  degradación controlada (ver fundamentos-ingenieria.md §4).

---

## 3. Observabilidad

Tres pilares + más:
- **Logs estructurados** (JSON, correlación por trace-id), sin secretos/PII.
- **Métricas** (RED: Rate, Errors, Duration; USE: Utilization, Saturation,
  Errors) y las **4 golden signals** (latencia, tráfico, errores, saturación).
- **Trazas distribuidas** (OpenTelemetry) extremo a extremo.
- **Alertas accionables** atadas a SLO (alerta sobre síntoma del usuario, no
  sobre ruido). Cada alerta → un runbook.

---

## 4. Operación (incident management)

- **Severidades** claras (SEV1–SEV4), roles (incident commander, comms, ops).
- **Runbooks** (procedimientos operativos) y **playbooks** (respuesta a
  incidentes/seguridad) versionados y probados.
- On-call sostenible; comunicación a stakeholders; timeline del incidente.
- **Postmortem** sin culpa con acciones correctivas con dueño y fecha.
- Gestión de capacidad, costos (FinOps) y backups/restore verificados.

---

## Checklist rápido de revisión
```
- [ ] Zero Trust: verificación explícita por petición, identidad como perímetro, asumir brecha
- [ ] AuthN/AuthZ, menor privilegio (JIT/JEA), secretos fuera del código
- [ ] Cifrado en tránsito y reposo; datos clasificados
- [ ] Validación de entrada; dependencias escaneadas (SCA/SBOM)
- [ ] SLI/SLO definidos + error budget + alertas accionables
- [ ] Logs estructurados + métricas + trazas (OTel)
- [ ] Despliegue progresivo + rollback probado; RTO/RPO definidos
- [ ] Runbooks/playbooks; plan de incidentes; postmortem sin culpa
```

## Referencias
- Google SRE Books: https://sre.google/books/
- OWASP (Top 10, ASVS, Cheat Sheets): https://owasp.org/
- Zero Trust (NIST SP 800-207): https://csrc.nist.gov/pubs/sp/800/207/final
- Microsoft Threat Modeling / STRIDE; NIST CSF; OpenTelemetry.
