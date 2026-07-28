# Plantillas de entregables — Cazador

Plantillas profesionales listas para usar. Ajusta el detalle al tamaño del
problema. Todo entregable cierra con **Próximos pasos**, **Criterios de éxito
medibles** y **riesgo residual**, y marca cada recomendación como **[REQUISITO] /
[RECOMENDACIÓN FUERTE] / [OPCIONAL]**.

Índice: 1) Threat model · 2) Respuesta 7 vistas · 3) Matriz de controles ·
4) ADR de seguridad · 5) Hallazgo (con CVSS/EPSS/causa raíz) · 6) Plan de IR ·
7) Roadmap · 8) Informe ejecutivo · 9) Autorización/RoE · 10) **Reporte de
pentest** · 11) **Cierre de remediación con retest** · 12) Informe de auditoría ·
13) DPIA · 14) Due diligence de terceros · 15) Postmortem.

---

## 1. Threat model

```
# Threat Model — <sistema>
## Alcance y supuestos
- Sistema / límites: ...
- [SUPUESTO] ...
## Diagrama de flujo de datos (DFD) y límites de confianza
- (Mermaid o descripción de componentes, flujos y trust boundaries)
## Activos a proteger
| Activo | Tipo (dato/identidad/sistema/secreto) | Valor/criticidad |
## Actores de amenaza
| Actor | Motivación | Capacidad | Plausibilidad |
(externo oportunista, crimen organizado, insider, APT, hacktivista, competidor)
## Amenazas (STRIDE por elemento)
| Elemento | S | T | R | I | D | E | Notas |
## Rutas de ataque (attack trees / ATT&CK)
- Ruta 1: <eslabón → eslabón → objetivo> | control que la rompe | detección
## Vectores priorizados
| Vector | Probabilidad | Impacto | Severidad | Mitigación |
## Gaps de detección (ATT&CK) y riesgo residual
```

---

## 2. Respuesta completa (7 vistas)

```
# 1. Strategic Security Assessment
Problema real · contexto · riesgos principales · [SUPUESTOS]
# 2. Threat Model & Attack Surface
Activos · actores · superficies · vectores críticos
# 3. Security Architecture & Controls
Arquitectura segura · controles por capa · patrones (no) recomendados
# 4. Detection, Monitoring & Response
Qué loguear · qué alertar · IR readiness · casos de detección
# 5. DevSecOps & SDLC Integration
Gates en pipeline · controles en repos/despliegues · reglas mínimas
# 6. Governance, Risk & Compliance
Gobierno · roles · gestión de riesgo/excepciones · mensaje a stakeholders
# 7. Roadmap & Next Actions
Fases por riesgo · quick wins · criterios de éxito · RIESGO RESIDUAL
```
Marca cada recomendación: **[REQUISITO] / [RECOMENDACIÓN FUERTE] / [OPCIONAL]**.

---

## 3. Matriz de controles por capa

```
| Capa | Riesgo/Amenaza | Control recomendado | Tipo (P/D/C) | Prioridad | Marco | Estado |
|------|----------------|---------------------|--------------|-----------|-------|--------|
| Identidad | ... | MFA FIDO2 | Preventivo | Alta | NIST 800-63 | Falta |
```
(P=Preventivo, D=Detectivo, C=Correctivo)

---

## 4. ADR de seguridad (Architecture Decision Record)

```
# ADR-SEC-<n>: <título>
Estado: Propuesto | Aceptado | Rechazado | Reemplazado
Contexto: problema, restricciones, requisitos de seguridad, amenazas relevantes
Decisión: control/patrón elegido
Alternativas consideradas: 2-3 con trade-offs (seguridad, coste, operabilidad)
Consecuencias: positivas, negativas, RIESGO RESIDUAL
Validación: cómo se verifica que el control funciona
```

---

## 5. Hallazgo de seguridad

```
ID: DST-<año>-<n>            Título: <claro y específico>
Severidad: 🔴/🟠/🟡/🟢       CVSS: <vector + score>   EPSS: <%>   KEV: sí/no
Estado del control: Presente / Parcial / Ausente / No verificado / No aplica
Clase/categoría: <p. ej. Broken Access Control / Inyección / Misconfig>
Ubicación: <componente / endpoint / archivo:línea / recurso>
Descripción: <qué es y por qué es un problema>
Ruta de ataque: <eslabón → eslabón → impacto> (PoC controlada y AUTORIZADA;
  mínimo necesario, sin datos reales, sin daño, dentro de alcance)
Evidencia: <captura/log/snippet, SIN exponer secretos/PII reales>
Impacto de negocio: <financiero / operativo / datos / reputacional / regulatorio>
Atacante plausible: <oportunista / crimen org. / insider / APT>
Causa raíz: <5 porqués>   ¿Otras instancias (variant analysis)?: <sí/no, dónde>
Recomendación (fix de raíz): <accionable, mapeada al marco del cliente si lo hay>
Control compensatorio (si el fix tarda): <con dueño y vencimiento>
Esfuerzo · Owner · SLA · Confianza del hallazgo (alta/media/baja)
Riesgo residual tras remediación · Plan de RETEST
```

---

## 6. Plan de respuesta a incidentes (resumen)

```
# IR Plan — <org/sistema>
Severidades: SEV1..SEV4 con criterios
Roles: Incident Commander, técnico, comunicaciones, scribe, legal
Flujo: Preparación → Detección/Análisis → Contención → Erradicación → Recuperación → Lecciones
Cadena de comunicación y escalamiento (interno/externo/regulador)
Playbooks: <lista por tipo>
Break-glass y preservación de evidencia
Métricas: MTTD, MTTR
```

---

## 7. Roadmap priorizado por riesgo

```
## Fase 0 — Quick wins (0-30 días, alto impacto/bajo esfuerzo)
- [ ] MFA en accesos privilegiados/remoto
- [ ] Secret scanning + rotación de expuestos
- [ ] Logging centralizado inmutable de identidad/cloud
- [ ] Eliminar exposición de puertos de gestión
## Fase 1 — Estructural (1-3 meses)
- [ ] Segmentación / mínimo privilegio / PAM
- [ ] SAST/SCA/IaC en CI con gate
- [ ] Casos de detección prioritarios + IR readiness
## Fase 2 — Madurez (3-12 meses)
- [ ] Zero Trust ampliado, detection engineering, purple teaming
- [ ] Supply chain (SBOM/firma/SLSA), gestión de vulnerabilidades madura
Cada ítem: dueño · criterio de éxito · riesgo que reduce
```

---

## 8. Informe ejecutivo (1 página)

```
Situación: ...
Riesgo principal (en términos de negocio): impacto $ / operativo / reputacional / regulatorio
Probabilidad y escenario: ...
Opciones (con trade-offs y coste): A / B / C
Recomendación: ...
Inversión requerida y tiempo: ...
Riesgo residual si se aprueba / si no se actúa: ...
Decisión solicitada / aceptación de riesgo: ...
```

---

## 9. Autorización y reglas de enfrentamiento (RoE) — prerrequisito de Modo G

> Ningún pentest/red team se ejecuta sin esto firmado (ver §0 de [SKILL.md](SKILL.md)).

```
# Autorización de pruebas de seguridad — <organización>
Solicitante / autoriza (cargo): ...        Fecha y vigencia: <desde–hasta>
Sistemas EN alcance (IP/dominios/apps/cuentas): ...
Sistemas/acciones FUERA de alcance (exclusiones explícitas): ...
Tipo de ejercicio: pentest | red team | revisión | validación de control
Modelo de conocimiento: black / grey / white box
Ventanas permitidas (horario/fechas) y entorno (prod / staging / aislado): ...
Reglas de enfrentamiento:
  - Técnicas permitidas / prohibidas (p. ej. NO DoS, NO ingeniería social a clientes)
  - Límite de impacto: sin exfiltrar datos reales, sin degradar servicio
  - Manejo de datos sensibles encontrados (no copiar; reportar)
Kill switch y contactos 24/7 (técnico + negocio): ...
Deconfliction (cómo distinguir el ejercicio de un ataque real): ...
Get-out-of-jail letter (autorización legal escrita): adjunta sí/no
Confidencialidad y entrega/destrucción de evidencia al cierre: ...
Firmas: autorizante __________   ejecutor __________
```

---

## 10. Reporte de pentest / hacking ético (profesional)

```
# Reporte de Pruebas de Seguridad — <sistema> — <fecha>
Clasificación: CONFIDENCIAL

## 1. Resumen ejecutivo (no técnico)
- Objetivo y alcance del ejercicio
- Postura general (1 frase) y nivel de riesgo
- Hallazgos por severidad: 🔴 n · 🟠 n · 🟡 n · 🟢 n
- 3-5 riesgos de negocio principales y recomendación de alto nivel

## 2. Alcance, metodología y limitaciones
- Sistemas en/fuera de alcance · modelo (black/grey/white) · ventanas
- Metodología y referencias (OWASP WSTG/MASTG, PTES, NIST 800-115) — como guía, no dogma
- Herramientas/categorías usadas (ver herramientas.md)
- Limitaciones: qué NO se pudo probar y por qué (declarar “no verificado”)

## 3. Resumen de hallazgos (tabla)
| ID | Título | Severidad | CVSS | Componente | Estado | Owner |
|----|--------|-----------|------|------------|--------|-------|

## 4. Detalle por hallazgo (usar plantilla §5 para cada uno)
- Incluir cadena de ataque (chaining) cuando varios fallos se combinan
- Evidencia reproducible (pasos mínimos), sin datos reales ni secretos

## 5. Narrativa de ataque / kill chain
- Cómo un atacante encadenaría los hallazgos extremo a extremo
- Mapeo a MITRE ATT&CK (técnicas observadas)

## 6. Cobertura y lo no probado
- Qué áreas se cubrieron y a qué profundidad; gaps explícitos (no dejar nada en duda)

## 7. Remediación priorizada y retest
- Tabla de fixes por riesgo + plan y fecha de RETEST (ver §11)

## 8. Conclusión y riesgo residual
- Veredicto inequívoco + nivel de confianza + próximos pasos medibles
## Anexos: evidencia, comandos/PoC controladas, alcance, autorización
```

---

## 11. Cierre de remediación con retest (verificación de fix)

```
# Acta de Remediación y Retest — <sistema> — <fecha>
Hallazgo(s) cubiertos: <IDs>     Severidad original: ...

Por cada hallazgo:
- Causa raíz confirmada (5 porqués): ...
- Variant analysis: ¿se buscó y cerró toda la clase? <sí/no, dónde>
- Fix aplicado: <descripción + diff/PR/IaC/regla>  Commit/Release: ...
- Verificación funcional: el sistema sigue operando (sin regresión): sí/no
- RETEST de seguridad: se re-ejecutó el ataque/PoC → resultado: BLOQUEADO/aún explotable
  Evidencia del retest (antes vs. después): ...
- Prueba automatizada anti-regresión añadida: <ubicación>
- Detección añadida/ajustada (si aplica): ...
- Compensatorio + vencimiento (si el fix definitivo no está): ...
- Estado final: CERRADO (verificado) / ABIERTO / ACEPTADO (con dueño y fecha)
- Riesgo residual declarado: ...

Resumen: hallazgos cerrados n/N · pendientes · MTTR de remediación
Veredicto: <inequívoco> — “nada queda en duda” o lista de lo que falta y cómo cerrarlo
```

---

## 12. Informe de auditoría / evaluación (Modo F)

```
# Informe de Auditoría de Seguridad — <sistema> — <fecha>
Alcance y FASE evaluada (antes/durante/después) · qué NO entra en alcance
Marco de referencia del cliente (si existe) → mapeo; si no, riesgo+evidencia
Criticidad calibrada (criterio explícito) · método de recolección de evidencia

## Resultados por dominio
| Dominio | Estado (Presente/Parcial/Ausente/No verificado/NA) | Madurez (0-5) | Evidencia | Hallazgos |
(humano, físico, identidad, red, app/API, datos/BD, cripto, supply chain,
 detección/respuesta, IA/LLM, gobierno)

## Hallazgos priorizados (plantilla §5) + madurez global medida
## Brechas vs. riesgo + roadmap (§7) + riesgo residual
## Declaración de independencia, alcance, limitaciones y confianza
```

---

## 13. DPIA / evaluación de impacto de privacidad

```
# DPIA — <tratamiento> — <fecha>   (no es asesoría legal; coordinar con DPO/legal)
1. Descripción: datos, categorías (¿sensibles?), fines, base de licitud, flujos,
   actores (responsable/encargado), transferencias, retención
2. Necesidad y proporcionalidad: ¿se puede lograr con menos datos?
3. Amenazas a la privacidad (LINDDUN): linking/identifying/.../non-compliance
4. Riesgos a los derechos del titular + probabilidad/impacto
5. Mitigaciones: minimización, seudonimización/anonimización, control de acceso,
   transparencia, derechos ejecutables (incl. borrado completo), PETs
6. Riesgo residual + decisión + revisión periódica + jurisdicción aplicable
```

---

## 14. Due diligence de terceros / proveedores

```
# Evaluación de Proveedor — <nombre> — <fecha>
Servicio y datos a los que accede · criticidad · subprocesadores (4ª parte)
Atestaciones (SOC 2 / ISO 27001 / pentest / cumplimiento) revisadas: ...
Controles clave: cifrado, acceso, MFA, logging, notificación de brecha (plazo)
Cláusulas contractuales de seguridad/privacidad: presentes sí/no
Hallazgos y riesgo · Acceso con mínimo privilegio · Plan de salida/portabilidad
Veredicto: aprobar / aprobar con condiciones / rechazar · revisión periódica
```

---

## 15. Postmortem de incidente (sin culpa)

```
# Postmortem — <incidente> — <fecha>
Resumen e impacto (qué, cuándo, alcance, datos/usuarios afectados)
Línea de tiempo (detección → contención → erradicación → recuperación)
Causa raíz (técnica y de proceso) · ¿cómo se detectó? ¿cómo debió detectarse?
Qué funcionó / qué no (sin culpar a personas)
Acciones correctivas: control/detección a crear, dueño, fecha, criterio de cierre
Métricas: MTTD, MTTR · Notificaciones realizadas (con legal) · Lecciones
```
