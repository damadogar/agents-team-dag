# Marcos de referencia y estándares de QA

Base de conocimiento de Amado. Verifica versiones vigentes por web antes de
afirmar capacidades o "última versión".

---

## 1. Estándares de testing

- **ISTQB** (Foundation/Advanced/Expert): vocabulario común, niveles y tipos de
  prueba, técnicas de diseño, proceso de prueba fundamental, gestión de defectos.
- **ISO/IEC/IEEE 29119** (1-5): proceso de pruebas de software.
  - 29119-1: conceptos y vocabulario.
  - 29119-2: procesos de prueba (organizacional, gestión, dinámico).
  - 29119-3: documentación (estrategia, plan, casos, reportes).
  - 29119-4: técnicas de diseño de casos (equivalencia, BVA, tablas de decisión,
    transición de estados, pairwise, etc.).
  - 29119-5: testing dirigido por palabras clave (keyword-driven).
- **IEEE 829** (heredado): plantillas de documentación de pruebas (test plan,
  test design, test case, test procedure, test report).
- **ISO/IEC 25010** (SQuaRE): modelo de calidad del producto (funcionalidad,
  fiabilidad, usabilidad, eficiencia/performance, mantenibilidad, portabilidad,
  seguridad, compatibilidad) — útil para definir atributos de calidad.

---

## 2. Seguridad (DevSecOps)

- **OWASP Top 10** (web) y **OWASP API Security Top 10** (APIs).
- **OWASP ASVS** (Application Security Verification Standard): niveles de
  verificación L1/L2/L3.
- **OWASP WSTG** (Web Security Testing Guide): metodología de pruebas.
- **NIST** (SP 800-53, SSDF 800-218), **CIS Benchmarks**.
- Prácticas: SAST, DAST, IAST, SCA (dependencias), escaneo de secretos,
  gestión de vulnerabilidades, shift-left security en el pipeline.

---

## 3. Accesibilidad

- **WCAG 2.1 / 2.2** niveles A/AA/AAA (perceptible, operable, comprensible,
  robusto). Objetivo común: **AA**.
- **WAI-ARIA** para componentes ricos.
- Normativa según región (ADA, EN 301 549, etc.).

---

## 4. Confiabilidad y entrega

- **Google SRE / DORA:** SLI/SLO/SLA, error budget, las 4 métricas DORA.
- **AWS / Azure Well-Architected** (pilar de Reliability y Operational
  Excellence) para razonar resiliencia y operación.
- **Pirámide de pruebas** (Cohn) y **Testing Trophy** (Dodds) para balance de
  niveles.

---

## 5. Performance

- Tipos: carga, estrés, spike, soak/endurance, escalabilidad, volumen.
- Métricas: latencia p50/p95/p99, throughput/RPS, error rate, saturación.
- Modelado de carga realista, ambiente representativo, análisis de cuellos de
  botella (golden signals: latencia, tráfico, errores, saturación).

---

## 6. Rigor en sistemas críticos

- **NASA/JPL Power of 10** y prácticas de software crítico (DO-178C, IEC 61508,
  ISO 26262 en sus dominios): trazabilidad fuerte, cobertura MC/DC, verificación
  formal donde el riesgo lo exige.

---

## 7. Risk-based testing

- Riesgo = Impacto × Probabilidad, ajustado por criticidad y exposición.
- Marcos: ISO 31000 (gestión de riesgos) como referencia conceptual.
- Mantener matriz de riesgo viva ligada a la selección de pruebas (ver
  `defectos-y-riesgo.md`).

---

## 8. IA aplicada a testing (2026)

- Generación/mantenimiento de casos, auto-healing, priorización de regresión,
  análisis de fallos, NL-to-test.
- **Guardas:** revisión humana obligatoria, trazabilidad, no enviar PII/secretos
  a modelos no autorizados, evaluar y versionar prompts y salidas.
