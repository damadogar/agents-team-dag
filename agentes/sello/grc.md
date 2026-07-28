# Gobierno, riesgo y compliance (GRC) — Sello

Modelo mínimo de gobierno, gestión de riesgo, políticas, métricas y comunicación
ejecutiva. Marco base: **NIST CSF 2.0** (función **Govern**), **ISO 27001:2022**,
**NIST 800-53/800-30/800-37**. Complementa [frameworks.md](frameworks.md).

---

## 1. Gestión de riesgo de ciberseguridad

Ciclo (NIST 800-30 / ISO 27005):
1. **Identificación:** activos, amenazas (de ofensiva -> skill **cazador**),
   vulnerabilidades, impacto de negocio.
2. **Evaluación:** **Riesgo = Probabilidad × Impacto**, ajustado por exposición y
   atacante plausible; cuantitativo (FAIR) donde aporte, cualitativo si no.
3. **Priorización:** registro de riesgos (risk register) ordenado por riesgo
   residual y *risk appetite*.
4. **Tratamiento:** **Mitigar / Transferir / Aceptar / Evitar.** Toda aceptación
   con dueño, justificación y fecha de revisión.
5. **Monitoreo:** revisión periódica, KRIs, reevaluación tras cambios.

### Registro de riesgo (campos)
```
ID · Descripción · Activo · Amenaza/vector · Prob × Impacto · Riesgo inherente ·
Controles actuales · Riesgo residual · Tratamiento · Dueño · Fecha revisión
```

---

## 2. Priorización de vulnerabilidades (riesgo real, no conteo)

Combina señales en lugar de usar solo CVSS base:
- **CVSS** (severidad técnica base/temporal/ambiental).
- **EPSS** (probabilidad de explotación en los próximos 30 días).
- **CISA KEV** (explotación activa conocida → urgencia máxima).
- **Contexto:** exposición (Internet vs interno), criticidad del activo,
  existencia de control compensatorio.

| Severidad | Criterio (combinado) | SLA de remediación |
|---|---|---|
| 🔴 Crítica | KEV / explotable + expuesto + activo crítico | 24-72 h o inmediato |
| 🟠 Alta | Alto CVSS + EPSS notable o expuesto | ≤ 7-30 días |
| 🟡 Media | Riesgo moderado, sin ruta clara de explotación | ≤ 90 días / sprint |
| 🟢 Baja | Higiene / defensa en profundidad | Backlog |

---

## 3. Políticas y estándares

- **Jerarquía:** Política (qué/por qué) → Estándar (qué obligatorio) → Procedimiento
  (cómo) → Guía (recomendado).
- **Controles mínimos obligatorios** (baseline) por tipo de sistema/criticidad.
- **Proceso de excepciones:** solicitud → riesgo → control compensatorio →
  aprobación por nivel adecuado → **fecha de vencimiento** → revisión. Sin
  excepciones perpetuas silenciosas.
- **Políticas núcleo típicas:** control de acceso, gestión de secretos/cripto,
  clasificación de datos, SDLC seguro, respuesta a incidentes, gestión de
  vulnerabilidades, uso aceptable, terceros, y **uso seguro de IA/LLM**.

---

## 4. Roles y responsabilidades (modelo mínimo)

| Rol | Responsabilidad |
|---|---|
| **CISO / responsable de seguridad** | Estrategia, riesgo, programa, reporte a dirección |
| **Security Architect** | Diseño seguro, estándares técnicos, revisión |
| **AppSec / Product Security** | Seguridad en SDLC, threat modeling, gates |
| **SecOps / SOC** | Detección, monitoreo, respuesta a incidentes |
| **GRC** | Riesgo, políticas, cumplimiento, auditoría |
| **Owners de sistema/datos** | Aceptan riesgo de su ámbito, clasifican datos |
| **Ingeniería / DevOps** | Implementan controles, remedian, operan seguro |

Usa **RACI** para procesos clave (gestión de vulnerabilidades, IR, cambios,
excepciones). En orgs pequeñas, una persona cubre varios roles — pero la
**rendición de cuentas** debe estar nombrada.

---

## 5. Métricas y KPIs de seguridad

| Métrica | Qué demuestra |
|---|---|
| MTTD / MTTR | Capacidad de detección y respuesta |
| Mean time to remediate (por severidad) | Eficacia de gestión de vulnerabilidades |
| % cobertura MFA / endpoints con EDR / activos inventariados | Higiene base |
| Cobertura ATT&CK de detección | Madurez de detección |
| Backlog de vulnerabilidades por severidad y antigüedad | Deuda de seguridad |
| % excepciones vencidas | Disciplina de riesgo |
| Resultados de phishing simulado / formación | Factor humano |
| Hallazgos por release / *escape rate* a prod | Eficacia DevSecOps |

Reporta **tendencias** y **riesgo**, no vanidad. Vincula cada métrica a una
decisión.

---

## 6. Comunicación a ejecutivos (riesgo → negocio)

- Traduce técnico a **impacto de negocio**: pérdida financiera potencial,
  interrupción operativa, daño reputacional, exposición regulatoria.
- Usa **escenarios** ("si X, entonces pérdida estimada Y, probabilidad Z") y
  *risk register* priorizado, no listas de CVEs.
- Presenta **opciones con trade-offs y coste**, y una **recomendación**; deja la
  aceptación de riesgo (apetito) en manos del negocio, documentada.
- Estructura de 1 página: situación → riesgo principal → opciones → recomendación
  → inversión → riesgo residual (plantilla en [plantillas.md](plantillas.md)).

---

## 7. Compliance (nivel conceptual — no asesoría legal)

Marcos frecuentes y su foco (mapeo, no interpretación legal vinculante):
- **PCI-DSS** (tarjetas), **HIPAA** (salud, EE.UU.), **GDPR** (datos personales,
  UE), **Ley 1581 / Habeas Data** (Colombia), **SOX** (financiero),
  **ISO 27001** (SGSI), **SOC 2** (controles de servicio).

Principio: **el cumplimiento es un piso, no un techo.** Diseña por riesgo y
**mapea** los controles a los requisitos aplicables; coordina con legal/
privacidad para obligaciones específicas (p. ej. plazos de notificación de brecha).

---

## 8. Gestión de terceros (TPRM)

- Inventario de proveedores y **criticidad/acceso a datos** de cada uno.
- Due diligence (SOC 2 / ISO / cuestionarios), cláusulas de seguridad y
  notificación de brecha en contratos.
- Mínimo privilegio para accesos de terceros; revisión periódica; plan de salida.
- Riesgo de **cuarta parte** (subprocesadores) y de supply chain de software.

---

## 9. Checklist GRC de cierre

```
- [ ] Riesgos en registro priorizado con dueño y tratamiento
- [ ] Vulnerabilidades priorizadas por CVSS+EPSS+KEV+contexto, con SLA
- [ ] Políticas/estándares mínimos definidos; excepciones con vencimiento
- [ ] Roles y RACI nombrados (aunque la org sea pequeña)
- [ ] Métricas que informan decisiones (tendencia + riesgo)
- [ ] Mensaje ejecutivo en términos de impacto de negocio y opciones
- [ ] Compliance mapeado (no confundido con asesoría legal)
- [ ] Terceros con due diligence y mínimo privilegio
- [ ] Riesgo residual aceptado por el dueño correcto
```
