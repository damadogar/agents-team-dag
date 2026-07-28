# Estrategia de QA y Test Plan

Referencia de Amado para los modos **A (Diagnóstico)** y **B (Estrategia y Plan)**.

---

## 1. Estrategia de QA (Quality Strategy)

Documento vivo de alto nivel. Define **cómo** se asegura la calidad en el
producto/organización, independiente de un release concreto.

Contenido mínimo:

- **Visión y objetivos de calidad:** qué significa "calidad aceptable" aquí
  (atributos prioritarios: fiabilidad, seguridad, rendimiento, usabilidad…).
- **Alcance:** sistemas, módulos y tipos de prueba cubiertos / fuera de alcance.
- **Niveles de prueba:** unitaria → integración → sistema → aceptación (UAT).
- **Tipos de prueba:** funcional, no funcional (performance, seguridad,
  compatibilidad, accesibilidad, usabilidad), regresión, smoke, sanity,
  exploratoria, contract testing.
- **Enfoque de riesgo:** cómo se prioriza (ver `defectos-y-riesgo.md`).
- **Automatización:** estrategia y pirámide objetivo (ver `automatizacion-cicd.md`).
- **Ambientes y datos:** estrategia de entornos y gestión de datos de prueba.
- **Roles y responsabilidades:** quién hace qué (calidad compartida).
- **Herramientas:** gestión de pruebas, defectos, automatización, CI/CD, reporting.
- **Métricas y criterios de éxito** (ver `metricas-reporting.md`).

---

## 2. Pirámide / niveles de prueba

| Nivel | Quién | Qué valida | Velocidad / costo |
|---|---|---|---|
| Unitaria | Dev | Lógica de una unidad aislada | Muy rápida / muy barata |
| Integración / componente | Dev + QA | Interacción entre módulos, contratos | Rápida |
| Contract testing | QA + Dev | Compatibilidad consumidor/proveedor (APIs) | Rápida |
| Sistema / E2E | QA | Flujos completos de negocio | Lenta / cara |
| Aceptación (UAT) | Negocio/PO | Cumple necesidad real del usuario | Manual / cara |
| No funcional | QA especializado | Performance, seguridad, accesibilidad | Variable |

Regla: **base ancha (unit/integración), punta angosta (E2E)**. Evita el
"cono de helado" (todo manual/E2E).

---

## 3. Test Plan (IEEE 829 / ISO/IEC/IEEE 29119-3)

Plan por proyecto, release o feature. Estructura recomendada:

1. **Identificador y alcance** — qué se prueba y qué no.
2. **Referencias** — requisitos, AC, arquitectura, riesgos.
3. **Objetivos de prueba** y criterios de calidad.
4. **Enfoque / estrategia** — niveles, tipos, técnicas (ver `diseno-pruebas.md`).
5. **Criterios de entrada (entry)** — qué debe cumplirse para empezar.
6. **Criterios de salida (exit)** — qué define "terminado y aprobado".
7. **Criterios de suspensión/reanudación.**
8. **Entregables de prueba** — casos, scripts, datos, reportes.
9. **Ambientes y datos** — configuración, anonimización.
10. **Cronograma e hitos.**
11. **Recursos y responsabilidades.**
12. **Riesgos del proyecto/producto y mitigaciones.**
13. **Herramientas.**
14. **Métricas y reporting.**

Mini-plan por feature: secciones 1, 3, 4, 5, 6, 8, 12 (versión condensada).

---

## 4. Criterios de entrada y salida (ejemplos)

**Entrada:**
- Requisitos/AC revisados y testeables.
- Build desplegada en ambiente estable.
- Casos de prueba diseñados y datos disponibles.
- Smoke test del build en verde.

**Salida:**
- 100% de casos críticos/altos ejecutados; sin defectos abiertos 🔴/🟠.
- Cobertura de requisitos acordada alcanzada.
- Regresión automatizada en verde.
- Riesgos residuales documentados y aceptados por el dueño.
- Métricas de salida dentro de umbral (ver `metricas-reporting.md`).

---

## 5. Arquitectura de pruebas

### 5.1 Estrategia de ambientes
- **dev:** pruebas de desarrollo/unitarias, datos sintéticos.
- **QA/test:** ejecución funcional, integración, regresión.
- **staging/preprod:** réplica de prod; performance, UAT, smoke previo a release.
- **prod:** smoke/synthetic monitoring, observabilidad, canary.

### 5.2 Gestión de datos de prueba
- Datos representativos, versionados y **anonimizados** (sin PII real).
- Estrategias: subset enmascarado de prod, generación sintética, factories/fixtures.
- Aislamiento por test (idempotencia, limpieza/teardown).
- Cumplimiento: GDPR/HIPAA/PCI/Habeas Data al manipular datos.

### 5.3 Integración con CI/CD y herramientas
- Gestión de pruebas y defectos (Azure DevOps, Jira/Xray, TestRail, etc.).
- Automatización en pipeline con **gates de calidad** y reportes (ver
  `automatizacion-cicd.md`).

---

## 6. QA por metodología

- **Scrum/Kanban:** QA en refinement (AC testeables), planning (estimación de
  pruebas), durante el sprint (shift-left), review y retro. Definition of Done
  incluye pruebas y regresión.
- **SAFe:** participa en PI planning; gestiona dependencias y riesgos a nivel ART.
- **Waterfall:** fases formales con entregables IEEE 829 y gates por fase.
- **Híbrido:** combina gates formales con iteración ágil; adapta el rigor a la
  criticidad.
