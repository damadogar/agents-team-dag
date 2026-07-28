# Detección, monitoreo y respuesta a incidentes — Centinela

Qué registrar, qué alertar y cómo prepararse para responder. Operacionaliza
[defensiva.md](defensiva.md). Marco base: **NIST SP 800-61** (Incident Handling)
y NIST CSF 2.0 funciones **Detect / Respond / Recover**.

---

## 1. Estrategia de logging (qué, dónde, cuánto, para qué)

### 1.1 Qué registrar (mínimo)
- **Identidad/acceso:** logins (éxito/fallo), MFA, cambios de privilegio,
  creación/borrado de cuentas, cambios de política/federación, uso de PAM.
- **Aplicación/API:** authz denegada, errores 4xx/5xx relevantes, acciones
  sensibles (pagos, exportes, borrados), validación fallida.
- **Datos:** acceso/lectura/exportación de datos sensibles, cambios de esquema,
  DDL/DML sensible.
- **Infra/host:** procesos, ejecución, cambios de configuración, integridad de
  archivos (FIM), servicios/persistencia.
- **Red:** conexiones, DNS, flujos, eventos de WAF/IDS/proxy, egreso.
- **Cloud:** audit trail (CloudTrail/Activity/Audit Logs), cambios de IAM y de
  recursos, desactivación de seguridad.
- **CI/CD:** quién desplegó qué, cambios de pipeline, acceso a secretos.
- **LLM/agentes:** prompts, outputs, herramientas invocadas, datos accedidos,
  decisiones que requirieron aprobación (ver seguridad de IA/LLM -> skill **vector**).

### 1.2 Cómo (calidad del log)
- **Centralizado e inmutable** (WORM / cuenta de log separada); el atacante no
  debe poder borrar su rastro.
- **Sincronización horaria (NTP)** y timestamps UTC; formato estructurado
  (JSON/OCSF) con campos consistentes (actor, acción, recurso, resultado, origen).
- **Sin secretos/PII en claro** en los logs (riesgo de fuga). Enmascarar.
- **Retención** acorde a riesgo/regulación (p. ej. accesos críticos meses-años);
  *hot* para búsqueda, *cold* para archivo.
- **Cobertura:** evita puntos ciegos; mapea fuentes a los TTPs que quieres
  detectar (ATT&CK).

---

## 2. De log a alerta (señal sobre ruido)

- Alerta sobre **comportamientos/TTPs**, no solo IOCs (ver pirámide del dolor).
- **Enriquece** (geo, identidad, criticidad de activo, threat intel) y
  **correlaciona** múltiples señales antes de paginar.
- Define **severidad y SLA** por alerta; suprime ruido conocido con allowlists
  documentadas (no silenciar a ciegas).
- Cada alerta debe tener un **runbook** asociado (qué hacer cuando dispara).
- Métricas de calidad: tasa de FP, *alert fatigue*, % de alertas accionables.

---

## 3. IR readiness (preparación de respuesta)

### 3.1 Ciclo NIST 800-61
1. **Preparación:** plan, roles, herramientas, accesos *break-glass*, contactos,
   formación, *tabletop exercises*.
2. **Detección y análisis:** triage, validación, alcance, clasificación de
   severidad, línea de tiempo.
3. **Contención, erradicación y recuperación:** aislar, eliminar la causa,
   restaurar desde fuente confiable, validar.
4. **Post-incidente:** lecciones aprendidas, *postmortem sin culpa*, mejoras.

### 3.2 Componentes mínimos
- **Plan de IR** y **clasificación de severidad** (SEV1-SEV4) con criterios.
- **Playbooks** por tipo de incidente (ver §4) y **runbooks** técnicos.
- **Cadena de comunicación y escalamiento:** quién decide, quién comunica,
  cuándo se involucra legal, dirección, clientes, reguladores.
- **Criterios de escalamiento** (cuándo SEV sube, cuándo se activa crisis).
- **Roles:** *Incident Commander*, comunicaciones, líder técnico, scribe.
- **Notificación regulatoria:** plazos legales (p. ej. GDPR 72h) a nivel de
  proceso; coordinar con legal — Centinela no da asesoría legal vinculante.
- **Preservación de evidencia** y cadena de custodia para forense.

### 3.3 Contención sin destruir evidencia
Aislar host/red, revocar credenciales/tokens/sesiones, rotar secretos, bloquear
cuentas, *snapshot* forense **antes** de limpiar. Documenta cada acción con
timestamp.

---

## 4. Playbooks (esqueletos)

Por cada tipo: disparadores → triage → contención → erradicación → recuperación →
comunicación → lecciones. Tipos clave:
- **Cuenta comprometida / phishing:** revocar sesiones, reset + rotación, revisar
  reglas de buzón/forwarding, buscar persistencia y pivots.
- **Ransomware:** aislar, identificar alcance, **no** pagar como primera opción,
  restaurar desde backup inmutable, preservar evidencia, comunicar.
- **Exfiltración de datos:** cortar egreso, identificar qué/cuánto/dónde, evaluar
  notificación, contener fuente.
- **Compromiso en cloud:** rotar credenciales/keys, revisar IAM/logging, revertir
  cambios de política, buscar persistencia (roles, funciones, claves).
- **Compromiso de supply chain / dependencia:** identificar artefactos afectados,
  congelar despliegues, SBOM, reconstruir desde fuente confiable.
- **Incidente en agente LLM:** revocar herramientas/credenciales del agente,
  revisar logs de prompts/acciones, contener acciones automatizadas.

---

## 5. SOC y operación

- **Modelo:** interno / MSSP / híbrido según madurez y presupuesto; define qué se
  externaliza y qué retienes (decisión y contención nunca se delegan del todo).
- **Niveles:** triage (L1) → investigación (L2) → caza/forense (L3) + detection
  engineering.
- **Threat hunting:** hipótesis basadas en ATT&CK; busca lo que las alertas no
  ven; alimenta nuevas detecciones.
- **SOAR:** automatiza respuesta repetible (enriquecer, contener, abrir ticket)
  con *human-in-the-loop* en lo irreversible.
- **Threat intelligence:** prioriza por adversarios relevantes a tu sector.

---

## 6. Métricas de detección y respuesta

| Métrica | Qué mide | Objetivo |
|---|---|---|
| MTTD | Tiempo medio de detección | Tendencia a la baja |
| MTTR | Tiempo medio de respuesta/contención | Tendencia a la baja |
| Cobertura ATT&CK | % de TTPs relevantes con detección | Creciente, priorizada por riesgo |
| Tasa de falsos positivos | Ruido de alertas | Baja y estable |
| % alertas accionables | Calidad de detección | Alta |
| Tiempo de restore (DR) | Recuperación probada | ≤ RTO comprometido |

---

## 7. Checklist de cierre (detección y respuesta)

```
- [ ] Logging cubre identidad, app, datos, infra, red, cloud, CI/CD y LLM
- [ ] Logs centralizados, inmutables, con tiempo sincronizado y sin secretos
- [ ] Alertas sobre TTPs, enriquecidas, con severidad/SLA y runbook
- [ ] Plan de IR + severidades + cadena de comunicación + escalamiento
- [ ] Playbooks para los incidentes plausibles del sistema
- [ ] Preservación de evidencia y break-glass definidos
- [ ] Tabletop / game day realizado o planificado
- [ ] Métricas MTTD/MTTR/cobertura definidas; riesgo residual declarado
```
