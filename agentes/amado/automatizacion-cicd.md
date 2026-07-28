# Automatización de pruebas e integración en CI/CD

Referencia de Amado para el modo **D (Ejecución y Automatización)**.

---

## 1. Qué automatizar (y qué no)

Automatiza donde el **ROI** es claro:
- ✅ Regresión estable y repetitiva.
- ✅ Smoke / sanity de cada build.
- ✅ APIs y contratos.
- ✅ Performance crítico y cargas recurrentes.
- ✅ Validaciones data-driven con muchas combinaciones.

Mantén manual / exploratorio:
- ❌ Funcionalidad muy volátil o aún en diseño.
- ❌ Usabilidad y exploración creativa.
- ❌ Casos de una sola ejecución (one-off).
- ❌ Aquello cuyo costo de mantenimiento supera el valor.

**Regla:** automatizar por valor y estabilidad, no por moda ni por cobertura
vanidosa.

---

## 2. Pirámide de automatización

```
        /\        E2E UI (pocos, flujos críticos)  — lentos, frágiles
       /  \       Integración / API / contract     — muchos, rápidos
      /____\      Unitarias (base ancha)           — muchísimas, instantáneas
```

Antipatrón a evitar: **cono de helado** (mayoría E2E/manual). Genera lentitud,
flakiness y alto costo de mantenimiento.

---

## 3. Selección de herramientas (guía 2026)

| Capa | Opciones | Notas de elección |
|---|---|---|
| UI web | Playwright, Cypress, Selenium | Playwright/Cypress para velocidad y DX; Selenium para amplitud de navegadores/legacy |
| Mobile | Appium, Espresso, XCUITest, Maestro | Nativo vs cross-platform según stack |
| API | Postman/Newman, REST-assured, Karate, Pact (contract) | Pact para evitar romper integraciones |
| Performance | k6, JMeter, Gatling, Locust | k6 (JS, CI-friendly); JMeter (madurez/UI) |
| Seguridad | OWASP ZAP, Semgrep, Trivy, gitleaks | SAST/DAST/SCA/secretos en pipeline |
| Accesibilidad | axe-core, Lighthouse, Pa11y | Integrables en E2E/CI |
| BDD | Cucumber, SpecFlow, Behave | Solo si negocio realmente colabora en los .feature |

Siempre **justifica la elección** por contexto (stack, equipo, mantenimiento,
licenciamiento, integración con CI/CD). Verifica versiones vigentes por web.

---

## 4. Patrones de arquitectura de automatización

- **Page Object Model (POM):** encapsula páginas/selectores; reduce duplicación.
- **Screenplay:** actores, tareas y preguntas; mejor escalabilidad que POM.
- **API client layers:** clientes tipados reutilizables por servicio.
- **Data-driven:** separa datos de la lógica de prueba (CSV/JSON/fixtures).
- **Keyword-driven / BDD:** legibilidad para negocio cuando aporta valor.
- **Fixtures/factories** para datos; **teardown** para idempotencia.

Principios: tests **independientes, deterministas, rápidos, legibles**; sin sleeps
fijos (usa esperas explícitas); selectores estables (data-testid).

---

## 5. Integración en CI/CD

Etapas típicas del pipeline con **gates de calidad**:

```
build → lint/format → unit (cobertura mínima) → SAST/SCA/secretos
      → deploy a QA → integración/API → smoke
      → E2E (críticos) → accesibilidad → performance (nightly)
      → reporte + publicación de evidencias → gate de release
```

- **Gates de calidad:** fallar el pipeline si cobertura < umbral, vulnerabilidad
  crítica, smoke/E2E en rojo, o regresión rota.
- **Estrategia de ejecución:** PR (rápidos: unit/API/smoke), nightly (full
  regresión/performance), pre-release (E2E críticos + UAT).
- **Reportes:** Allure, JUnit XML, HTML; publicar evidencias (screenshots, video,
  logs) en la herramienta de gestión.
- **Flakiness:** cuarentena de tests inestables, retries acotados con análisis de
  causa raíz (no esconder el problema).

---

## 6. Tendencias 2026

- **AI testing agents:** generación y mantenimiento de casos, auto-healing de
  selectores, priorización de regresión por riesgo, análisis de fallos.
- **Generación de casos con LLM:** a partir de requisitos/AC, con revisión humana.
- **Visual testing:** comparación de UI (Applitools, Percy, Playwright snapshots).
- **TestOps y observabilidad:** métricas de calidad como telemetría; correlación
  test ↔ release ↔ incidente; quality gates como datos.
- **Synthetic monitoring** en producción (smoke continuo desde el exterior).

**Guarda:** todo lo generado por IA pasa por **revisión humana**; no se mergea
automatización opaca ni sin trazabilidad.
