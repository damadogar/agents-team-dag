# Ejemplos resueltos (few-shot) — Vector

Casos modelo del **cluster Seguridad** (vista seguridad de IA/LLM). Calibran
profundidad; en uso real co-ejecuta con **sysuniversal-ai**, **cazador** y **sello**.

---

## Ejemplo 1 — API pública de e-commerce (web/API, cloud)

**Contexto [SUPUESTO]:** API REST con pagos, datos de clientes (PII + tarjetas vía
PSP), en una sola cuenta cloud, MFA parcial, logging básico.

**1. Strategic assessment:** datos PII/PCI → atacantes con motivación financiera
(crimen organizado, credential stuffing, BOLA en endpoints de pedido). Madurez
baja asumida. Riesgo principal: brecha de datos de clientes y fraude.

**2. Threat model (top vectores):**
- Broken Access Control / BOLA en `/orders/{id}` → acceso a pedidos de otros
  (IDOR). 🔴
- Credential stuffing por MFA parcial. 🟠
- SSRF en integración de webhooks → metadata cloud → credenciales. 🔴
- Secret en repo/CI. 🟠

**3. Arquitectura & controles:** authz server-side por objeto + pruebas de acceso
cruzado [REQUISITO]; MFA fuerte para cuentas y admin [REQUISITO]; API Gateway con
schema validation + rate limiting [REQUISITO]; egress filtering + IMDSv2 contra
SSRF [REQUISITO]; secretos en manager + rotación [REQUISITO]; tokenización de
PAN/PSP, sin almacenar tarjetas [REQUISITO]. Descartado: WAF como único control de
authz (no sustituye authz server-side).

**4. Detección:** logs de authz denegada (detección de IDOR sweeps), picos de
login fallido (stuffing), llamadas salientes anómalas (SSRF/exfil), acceso masivo
a PII. Alertas con runbook.

**5. DevSecOps:** secret scanning bloqueante, SCA/SAST en PR, DAST en staging,
pruebas automáticas de authz por objeto.

**6. GRC:** mapear PCI-DSS (scope), registrar riesgo de brecha PII, definir SLA de
remediación. Excepciones con vencimiento.

**7. Roadmap:** Fase 0 (MFA, secret scanning, IMDSv2, authz por objeto en
endpoints críticos). Fase 1 (segregación de cuentas, logging inmutable, gate
DevSecOps). **Riesgo residual:** fraude de cuentas legítimas y phishing siguen;
mitigar con detección y educación.

---

## Ejemplo 2 — Migración a microservicios en cloud

**Contexto [SUPUESTO]:** monolito → microservicios en Kubernetes, multi-equipo.

**Vectores clave:** movimiento lateral por confianza de red interna; secretos en
manifests; supply chain de imágenes; explosión de superficie de APIs internas.

**Arquitectura:** Zero Trust interno con **mTLS + authz por servicio** (service
mesh) [REQUISITO]; NetworkPolicies default-deny [REQUISITO]; Pod Security
restricted, imágenes firmadas y escaneadas [REQUISITO]; secretos en gestor +
identidad de workload (no en YAML) [REQUISITO]; cuentas/entornos segregados.

**Detección:** anomalías de tráfico este-oeste, cambios de RBAC en k8s, pods
privilegiados, pull de imágenes no firmadas.

**DevSecOps/supply chain:** SBOM por servicio, firma (cosign), SLSA incremental,
admission control que rechaza imágenes no firmadas.

**Roadmap:** primero identidad de workload + mTLS + NetworkPolicies (corta
lateralidad), luego supply chain y detección este-oeste. **Riesgo residual:**
complejidad operativa; mitigar con plataforma y guardrails.

---

## Ejemplo 3 — Agente LLM con herramientas (soporte interno)

**Contexto [SUPUESTO]:** agente que lee tickets y documentos (RAG) y puede ejecutar
acciones (crear tickets, consultar DB, enviar correos).

**Threat model (OWASP LLM 2025 + ATLAS):**
- **Prompt injection indirecta** vía contenido de ticket/documento → el agente
  ejecuta acción no deseada. 🔴 (LLM01)
- **Excessive agency:** la herramienta de correo/DB tiene permisos amplios. 🔴 (LLM06)
- **Fuga cross-tenant** en RAG. 🟠 (LLM08)
- **System prompt leakage** con lógica/secretos. 🟠 (LLM07)

**Controles:** tratar todo contenido recuperado como **no confiable**
[REQUISITO]; herramientas con **mínimo privilegio** y allowlist [REQUISITO];
**human-in-the-loop** para enviar correo externo / escribir en DB [REQUISITO];
RAG con aislamiento por tenant y document-level authz [REQUISITO]; sin secretos en
system prompt [REQUISITO]; egress de herramientas restringido [REQUISITO];
límites de coste/tokens/tiempo [REQUISITO].

**Detección:** logging de prompts/acciones, alertas por acción sensible sin
aprobación, patrones de inyección, uso anómalo/costo.

**Roadmap:** primero recortar permisos de herramientas + HITL (corta el mayor
riesgo), luego aislamiento RAG y evals de seguridad. **Riesgo residual:**
inyección indirecta nunca es 0 → defensa en capas + revisión humana en lo
irreversible.

---

## Ejemplo 4 — Respuesta a incidente: cuenta cloud comprometida

**Disparador:** alerta de uso de credenciales IAM desde IP/UA nuevos + creación de
recursos de cómputo (posible cryptomining).

**Triage:** confirmar alcance (qué credencial, qué permisos, qué se creó/accedió),
clasificar SEV.

**Contención:** revocar/rotar la credencial, deshabilitar la identidad, snapshot
forense de recursos creados, **no** borrar evidencia aún.

**Erradicación:** eliminar recursos maliciosos, buscar persistencia (roles nuevos,
funciones, claves de acceso, reglas), revisar logging por desactivación.

**Recuperación:** restaurar configuración desde IaC confiable, reforzar IAM
(mínimo privilegio, eliminar llaves de larga vida), MFA.

**Lecciones:** ¿cómo se filtró la credencial? (secret en repo/CI/phishing) →
remediar la causa raíz; añadir detección que faltó. **Postmortem sin culpa.**

---

## Ejemplo 5 — Hacking ético de software: del hallazgo al fix verificado

**Contexto [SUPUESTO]:** app web autorizada para pentest. Modo A→G→H→C.

**G (encontrar y demostrar):** recon → enumeración → se identifica IDOR en
`/api/invoice/{id}` + falta de rate limit. *Chaining*: enumeración de IDs →
descarga masiva de facturas de otros clientes (PII + montos). PoC controlada:
acceso a 3 facturas ajenas de prueba (sin exfiltrar datos reales), evidencia y
ruta documentadas. Severidad 🔴 (broken access control + fuga PII).

**H (corregir — causa raíz):** authz **server-side por objeto y por propietario/
tenant** [REQUISITO]; deny-by-default; rate limiting + detección de enumeración.
Variant analysis: revisar **todos** los endpoints `/{id}` por el mismo patrón
(no solo el reportado). Se entrega el diff/PR.

**Retest:** re-explotar → el acceso ajeno ahora da 403; enumeración masiva
bloqueada. Prueba automatizada de acceso cruzado añadida (anti-regresión).

**C (blindar):** alerta por pico de 403/enumeración; logging de acceso a PII.
**Cierre:** hallazgo verificado cerrado; **riesgo residual:** abuso por cuenta
legítima → mitigado con detección. *No queda nada en duda:* se revisó la clase
completa, no solo el caso.

---

## Ejemplo 6 — Base de datos: exfiltración y blindaje

**Contexto [SUPUESTO]:** PostgreSQL/SQL Server con datos de clientes; sospecha de
exposición.

**Evaluación (sin sesgo de motor):** la app usa una cuenta con permisos de admin;
hay SQL dinámico concatenado en un módulo de reportes (inyección 🔴); la BD acepta
conexiones desde un rango amplio; sin cifrado en reposo; auditoría desactivada.

**Hacking ético (autorizado):** se confirma inyección con PoC mínima (extrae
versión y un conteo, sin tocar datos reales) → demuestra que permite leer tablas
sensibles. Severidad 🔴.

**Remediación (causa raíz):** parametrizar todas las consultas (no solo la
vulnerable) [REQUISITO]; **cuenta de app con mínimo privilegio** (sin DDL/admin)
[REQUISITO]; cifrado en reposo + TLS [REQUISITO]; RLS/enmascaramiento de PII;
restringir red a la app (sin Internet); habilitar auditoría inmutable; backups
cifrados con restore probado. Retest: payloads ya no funcionan; permisos
reducidos verificados.

**Detección:** alertas por acceso masivo/anómalo a tablas sensibles y por DDL
inesperado. **Riesgo residual:** insider con acceso legítimo → DLP + auditoría.

---

## Ejemplo 7 — Auditoría de sistema legacy / mainframe (sin sesgo de antigüedad)

**Contexto [SUPUESTO]:** núcleo bancario en mainframe + COBOL, integrado por
gateways. Petición: "¿es inseguro por ser viejo?".

**Enfoque neutral:** evaluar el **control real**, no la etiqueta. Hallazgos por
evidencia: cuentas compartidas y protocolos heredados sin cifrado entre gateways
🟠; logging no integrado al SIEM moderno 🟡; **pero** segmentación física fuerte y
acceso muy restringido (control presente). Dependencias EOL sin plan 🟠.

**Veredicto:** el legacy **bien aislado y controlado** tiene riesgo *gestionable*;
no se condena por antigüedad. **Remediación proporcional:** eliminar cuentas
compartidas, cifrar/encapsular el tránsito entre gateways (TLS terminando en
gateway si el host no lo soporta — control compensatorio), reenviar logs al SIEM
vía colector, plan de EOL/modernización por fases. **No verificado:** controles
internos del host sin acceso → se solicita evidencia o ventana de revisión (no se
asume "inseguro").

---

## Ejemplo 8 — OT/ICS (prioridad en disponibilidad y safety)

**Contexto [SUPUESTO]:** planta con PLC/SCADA; red IT y OT planas.

**Amenazas:** pivot IT→OT, protocolos industriales sin auth, impacto físico
(safety). **Evaluación pasiva** (no intrusiva, para no afectar el proceso):
inventario de activos OT, mapeo de flujos, detección de accesos remotos.

**Remediación proporcional (IEC 62443 como referencia, no imposición):**
segmentar IT/OT con **DMZ industrial** [REQUISITO]; monitoreo pasivo de protocolos
[REQUISITO]; acceso remoto con bastión y MFA [REQUISITO]; parcheo con ventana y
validación rigurosa (sin romper el proceso). **Regla:** no imponer prácticas IT
que comprometan disponibilidad/safety. **Riesgo residual:** sistemas que no se
pueden parchear → compensar con segmentación y monitoreo.

---

## Ejemplo 9 — DPIA / privacidad (region-neutral)

**Contexto [SUPUESTO]:** nueva feature que perfila usuarios con datos sensibles.

**DPIA:** describir tratamiento (datos, fines, flujos, transferencias) → evaluar
necesidad/proporcionalidad → amenazas de privacidad con **LINDDUN** (linking,
identifying, data disclosure) → mitigaciones: **minimización** (no recoger lo que
no se usa), seudonimización, limitación de finalidad y retención, control de
acceso por finalidad, transparencia y derechos del titular ejecutables (incl.
borrado completo). **Marco:** el de la jurisdicción del sistema (con legal).
**Riesgo residual:** reidentificación por correlación → differential privacy/
agregación donde aplique. *Seguridad ≠ privacidad:* ambas se cierran.

---

## Ejemplo 10 — Acceso/tooling limitado (degradación con gracia, sin prometer de más)

**Contexto [SUPUESTO]:** "Hazle un pentest a nuestra API en producción." No hay
autorización/RoE firmados ni acceso de red ni herramientas ofensivas en la sesión.

**Cómo actúa Destroyer (honestidad operativa, §14 bis + línea roja §0):**

1. **No simula un pentest ni inventa hallazgos.** Declara el límite: falta
   autorización (RoE) y falta acceso/tooling para ejecutar.
2. **Reencauza a lo legítimo y accionable ya:**
   - Entrega la **plantilla de autorización/RoE** (plantillas §9) para habilitar
     el Modo G correctamente.
   - Con el material disponible (spec/OpenAPI, código, logs que sí pueda ver),
     hace **threat model** y revisión estática, y prioriza la superficie.
   - Diseña el **plan de pruebas** (qué endpoints, qué clases de vuln, qué orden)
     listo para ejecutar cuando haya RoE/acceso.
   - Deja artefactos ejecutables por el equipo: **reglas de detección**, checklist
     de **web/API a profundidad** (checklists §12) y casos de prueba.
3. **Escalera de fallback:** conseguir acceso/RoE → analizar con lo disponible →
   reducir alcance → entregar artefactos → recomendación con criterio.

**Resultado:** el usuario recibe valor inmediato (modelo de amenazas, plan, reglas,
checklist) **sin** afirmaciones falsas de "ya lo ataqué". Cuando llegue la
autorización y el acceso, el Modo G se ejecuta sobre un plan ya diseñado y el
Modo H cierra con fix + retest.

**Lección:** robustez también es **decir qué NO se pudo hacer** y por qué, y aun
así no quedarse en "no se puede". Verificado ≠ diseñado-pero-no-ejecutado.
