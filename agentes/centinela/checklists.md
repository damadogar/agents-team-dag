# Checklists de hardening por capa — Centinela

Líneas base accionables. Aplica con criterio (proporcional al riesgo) y mapea a
CIS Benchmarks / cloud well-architected donde haya estándar formal. Marca cada
ítem como **[REQUISITO]** o **[RECOMENDACIÓN]** según contexto.

---

## 1. Identidad y acceso
```
- [ ] MFA resistente a phishing (FIDO2/WebAuthn) en privilegiados y acceso remoto
- [ ] Mínimo privilegio; deny by default; sin permisos "*" ni admin permanente
- [ ] PAM con JIT/JEA, bóveda de credenciales y sesiones grabadas
- [ ] Sin secretos de larga vida; tokens efímeros; rotación automática
- [ ] SSO federado; conditional access por contexto/riesgo
- [ ] Recertificación periódica de accesos; cero cuentas huérfanas
- [ ] break-glass controlado y monitoreado; MFA en root/global admin
- [ ] Lifecycle JML automatizado (alta/cambio/baja)
```

## 2. Red
```
- [ ] Segmentación/microsegmentación con default-deny entre zonas
- [ ] mTLS service-to-service; identidad de workload
- [ ] Sin RDP/SSH/paneles de gestión expuestos a Internet
- [ ] ZTNA en lugar de VPN plana
- [ ] Egress filtering / proxy; metadata service protegido (IMDSv2)
- [ ] Protección DDoS; WAF afinado; rate limiting
- [ ] Seguridad/filtrado DNS; detección de tunneling
```

## 3. Endpoints / servidores
```
- [ ] Línea base CIS aplicada; superficie mínima; servicios inseguros off (SMBv1, LLMNR)
- [ ] EDR/XDR desplegado y monitoreado
- [ ] Application allowlisting donde sea viable
- [ ] Cifrado de disco; arranque seguro
- [ ] Parcheo gestionado con SLA; sin EOL no planificado
- [ ] FIM en archivos/binarios críticos
```

## 4. Aplicaciones / APIs
```
- [ ] Validación de entrada y output encoding contextual
- [ ] Authz server-side por objeto (anti IDOR/BOLA); pruebas de acceso cruzado
- [ ] Headers de seguridad (CSP, HSTS, X-Content-Type-Options, Referrer-Policy)
- [ ] Rate limiting y protección anti-bot/credential stuffing
- [ ] Schema validation en gateway; tamaño/timeout límites
- [ ] Gestión de sesión segura (cookies HttpOnly/Secure/SameSite; invalidación)
- [ ] Baseline OWASP ASVS acorde al nivel de riesgo
- [ ] Sin secretos en cliente/repos; manejo seguro de errores (sin stack traces)
```

## 5. Datos
```
- [ ] Datos clasificados; controles según clasificación
- [ ] Cifrado en tránsito (TLS 1.2+/1.3) y en reposo; campo cifrado para lo crítico
- [ ] Gestión de llaves (KMS/HSM) con rotación y SoD en custodia
- [ ] Tokenización/enmascaramiento/anonimización de PII en no-prod y a terceros/IA
- [ ] RLS/CLS; data access broker; sin conexiones directas amplias
- [ ] DLP en endpoints/correo/SaaS (y prompts/outputs de IA)
- [ ] Retención y borrado seguro; linaje
```

## 6. Contenedores / Kubernetes
```
- [ ] Imágenes mínimas, firmadas y escaneadas; sin CVEs críticas sin gestionar
- [ ] Contenedores non-root, read-only FS, drop capabilities, seccomp/AppArmor
- [ ] Pod Security Standards = restricted; sin privileged/hostPath/hostNetwork
- [ ] NetworkPolicies default-deny; RBAC mínimo
- [ ] Secretos en gestor (no en manifests/env); rotación
- [ ] Admission control (OPA/Gatekeeper/Kyverno) con políticas
- [ ] Runtime security / detección de anomalías en cargas
```

## 7. Cloud
```
- [ ] Cuentas/proyectos/suscripciones segregados por blast radius
- [ ] Guardrails (SCP/Org Policies/Management Groups); compliance-as-code
- [ ] Sin usuarios con llaves de larga vida; roles federados; PIM/JIT
- [ ] Almacenamiento sin acceso público por defecto; CMK + rotación
- [ ] Logging (CloudTrail/Activity/Audit) centralizado e INMUTABLE
- [ ] Detección nativa (GuardDuty/Defender/SCC); CSPM/CIEM/CWPP
- [ ] Private endpoints; egreso controlado; sin 0.0.0.0/0 en gestión
```

## 8. CI/CD
```
- [ ] Runners aislados y efímeros; sin credenciales de larga vida (OIDC)
- [ ] Tokens de CI con mínimo privilegio y scope por repo/entorno
- [ ] Protección de ramas: PR + reviews + checks obligatorios; firma de commits
- [ ] SAST/SCA/secret scan/IaC scan con gate por severidad
- [ ] DAST en staging antes de release
- [ ] Artefactos firmados + SBOM; verificación de procedencia antes de desplegar
- [ ] Acciones/imágenes de terceros pineadas por SHA
- [ ] Aprobación humana para despliegues a entornos sensibles
```

## 9. LLM / agentes
```
- [ ] Entrada externa/recuperada tratada como no confiable (prompt injection indirecta)
- [ ] Salida del LLM tratada como no confiable antes de usarse aguas abajo
- [ ] Herramientas con mínimo privilegio, allowlist y sandboxing
- [ ] Human-in-the-loop en acciones sensibles; kill switch
- [ ] Sin secretos en system prompt; control de seguridad externo al prompt
- [ ] RAG con aislamiento por tenant y document-level authz
- [ ] Egress de herramientas restringido (sin metadata/internos innecesarios)
- [ ] Logging de prompts/outputs/acciones sin PII/secretos en claro
- [ ] Límites de tokens/coste/tiempo; evals de seguridad ante cambios de modelo
```

## 10. Revisión de PR (seguridad)
```
- [ ] ¿Introduce nueva entrada/superficie sin validación?
- [ ] ¿Maneja authz server-side correctamente (no confía en el cliente)?
- [ ] ¿Secretos fuera del código? ¿Logs sin PII/secretos?
- [ ] ¿Salida correctamente encodeada/parametrizada (anti inyección/XSS)?
- [ ] ¿Dependencias nuevas revisadas (SCA) y pineadas?
- [ ] ¿Cambios de IaC sin misconfig (puertos, public, IAM amplio)?
- [ ] ¿Necesita threat model (toca auth, datos sensibles o exposición)?
- [ ] ¿Telemetría/logging suficiente para detectar abuso?
```

## 11. Bases de datos (seguridad)
```
- [ ] Sin credenciales por defecto; cuentas con mínimo privilegio (sin admin para la app)
- [ ] Autenticación fuerte; sin cuentas compartidas; rotación de credenciales
- [ ] Cifrado en tránsito (TLS) y en reposo (TDE/volumen); campo cifrado para lo crítico
- [ ] Inyección imposible: parametrización en la app; sin SQL dinámico concatenado
- [ ] RLS/CLS y enmascaramiento donde hay PII; need-to-know
- [ ] Superficie de red mínima: BD no expuesta a Internet; allowlist de orígenes
- [ ] Auditoría de accesos y DDL/DML sensibles; logs inmutables; sin PII en logs
- [ ] Parcheo al día; features inseguras deshabilitadas; hardening (CIS por motor)
- [ ] Backups cifrados + restore probado; separados del dominio de identidad de prod
- [ ] Datos no-prod enmascarados/anonimizados; sin copias de prod sin proteger
```

## 12. Web / API a profundidad (mapeable a OWASP ASVS / API Top 10)
```
- [ ] Access control por objeto y función probado (horizontal/vertical/cross-tenant)
- [ ] Autenticación y gestión de sesión robustas (MFA, rotación, invalidación)
- [ ] Validación de entrada + output encoding contextual (anti inyección/XSS)
- [ ] SSRF, XXE, deserialización, redirecciones abiertas verificadas
- [ ] Lógica de negocio: abuso, condiciones de carrera, manipulación de precios/flujos
- [ ] Rate limiting, anti-automatización, protección de recursos
- [ ] Cabeceras de seguridad y CORS correctos; cookies seguras
- [ ] Manejo de errores sin fuga (stack traces, datos sensibles)
- [ ] APIs: esquema validado, versionado, autorización por endpoint, mass assignment
```

## 13. Pentest / hacking ético (ejecución autorizada)
```
- [ ] Autorización firmada + alcance + RoE + ventanas + exclusiones + contactos
- [ ] Reconocimiento y enumeración documentados (superficie real)
- [ ] Hallazgos priorizados por explotabilidad, no por volumen
- [ ] PoC controlada: mínimo necesario, sin daño, sin exfiltración real, en alcance
- [ ] Post-explotación acota impacto sin salir del scope
- [ ] Chaining evaluado (fallos menores → impacto alto)
- [ ] Evidencia reproducible por hallazgo; severidad y ruta de ataque claras
- [ ] Cada hallazgo con fix propuesto y plan de RETEST
- [ ] Limpieza post-ejercicio (artefactos, cuentas, cambios) y reporte de cierre
```

## 14. DFIR / forense (preparación y ejecución)
```
- [ ] Plan de IR + severidades + roles + cadena de comunicación + break-glass
- [ ] Capacidad de preservar evidencia (snapshot/memoria) ANTES de limpiar
- [ ] Cadena de custodia y timestamps confiables (NTP/UTC)
- [ ] Contención sin destruir evidencia (aislar, revocar, rotar)
- [ ] Búsqueda de persistencia y movimiento lateral; alcance confirmado
- [ ] Erradicación de causa raíz + recuperación desde fuente confiable
- [ ] Postmortem sin culpa → lecciones convertidas en controles/detecciones
- [ ] Notificación regulatoria coordinada con legal (plazos según jurisdicción)
```

## 15. Revisión profunda de código seguro (secure code review)
```
- [ ] Entradas no confiables identificadas y validadas/encodeadas en cada uso
- [ ] Authz verificada en cada operación sensible (no solo en la UI)
- [ ] Sin secretos en código; manejo seguro de credenciales/tokens
- [ ] Criptografía correcta (algoritmo, modo AEAD, IV/nonce, sal, gestión de llaves)
- [ ] Manejo de errores/excepciones sin fuga; fail-closed
- [ ] Concurrencia: condiciones de carrera, TOCTOU, idempotencia
- [ ] Dependencias revisadas (SCA) y superficie de deserialización controlada
- [ ] Se corrige la CLASE del bug (variant analysis), no solo la instancia
- [ ] Prueba de seguridad automatizada añadida (anti-regresión)
```
