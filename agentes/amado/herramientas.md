# Catálogo global de herramientas de QA (tool-agnostic)

Mapa del ecosistema de testing del mercado para que Amado **elija, aprovisione y
use la mejor herramienta para cada caso**, en cualquier lenguaje o stack. No es
una lista cerrada ni una recomendación fija: **verifica versiones y novedades por
web** y elige por contexto (stack, equipo, mantenimiento, licencia, CI/CD).

> Criterio de selección: idoneidad técnica > integración con el stack/CI >
> madurez/comunidad > costo/licencia > curva de mantenimiento. Justifica siempre.

---

## 1. Pruebas unitarias / componente (por lenguaje)

- **JS/TS:** Vitest, Jest, Mocha+Chai, node:test.
- **Python:** pytest, unittest.
- **Java/JVM:** JUnit 5, TestNG, Spock (Groovy), Kotest.
- **.NET:** xUnit, NUnit, MSTest.
- **Go:** testing (stdlib), testify.
- **Rust:** cargo test, nextest.
- **Ruby:** RSpec, Minitest. **PHP:** PHPUnit, Pest. **C/C++:** GoogleTest, Catch2.
- **Swift/Kotlin móvil:** XCTest, JUnit/Espresso.

## 2. UI web E2E / funcional

- Playwright, Cypress, Selenium/WebDriver, Puppeteer, WebdriverIO, TestCafe,
  Nightwatch. Codeless/low-code: Katalon, Ranorex, Testim, mabl.

## 3. Mobile

- Appium (cross), Espresso (Android), XCUITest (iOS), Maestro, Detox
  (React Native), Flutter integration_test. Nube de dispositivos: BrowserStack,
  Sauce Labs, AWS Device Farm, Firebase Test Lab.

## 4. Desktop / otros front

- WinAppDriver, Playwright (Electron), Squish, FlaUI (Windows), SikuliX (visión).

## 5. API / servicios / contratos

- **Funcional API:** Postman/Newman, REST-assured, Karate, SoapUI/ReadyAPI,
  Bruno, Hoppscotch, HTTPie, k6 (también API), pytest+requests, supertest.
- **Contract testing:** Pact, Spring Cloud Contract, Specmatic.
- **GraphQL:** GraphQL Inspector, Apollo testing. **gRPC:** ghz, grpcurl.
- **Schema/spec:** Dredd, Schemathesis (property-based desde OpenAPI), Prism.

## 6. Performance / carga

- k6, JMeter, Gatling, Locust, Artillery, Vegeta, wrk, Tsung, NeoLoad,
  LoadRunner. Perfilado: async-profiler, pprof, Py-Spy, Clinic.js.

## 7. Seguridad (DevSecOps)

- **SAST:** Semgrep, SonarQube, CodeQL, Checkmarx, Fortify, Bandit (Py),
  ESLint security, gosec.
- **DAST:** OWASP ZAP, Burp Suite, Nikto, Nuclei.
- **SCA / dependencias:** Snyk, Dependabot, OWASP Dependency-Check, Trivy, Grype,
  npm/pip/cargo audit, Renovate.
- **Secretos:** gitleaks, TruffleHog, detect-secrets.
- **Contenedores/IaC:** Trivy, Grype, Checkov, tfsec, kube-bench, Dockle.
- **Pentest/explotación:** Metasploit, sqlmap, nmap, Nuclei, ffuf.
- **LLM/IA security:** garak, PyRIT, Promptfoo (red-team), Rebuff (prompt injection).

## 8. Fuzzing

- AFL++, libFuzzer, honggfuzz, **OSS-Fuzz/ClusterFuzz**, go-fuzz/native, cargo-fuzz,
  Jazzer (JVM), Atheris (Python), Schemathesis (API), restler (REST).
- **Sanitizers:** ASan, UBSan, TSan, MSan, LeakSanitizer.

## 9. Property-based / model-based

- Hypothesis (Py), fast-check (JS/TS), QuickCheck (Haskell), jqwik (Java),
  ScalaCheck, proptest/quickcheck (Rust), PropEr (Erlang), FsCheck (.NET).

## 10. Mutation testing

- Stryker (JS/.NET/Scala), PIT/Pitest (Java), mutmut & cosmic-ray (Py),
  mull (LLVM), go-mutesting.

## 11. Métodos formales / verificación

- TLA+ (TLC, Apalache), PlusCal, P, Alloy, SPIN/Promela, Coq, Isabelle, Lean,
  Dafny, Z3 (SMT), CBMC. **Cobertura MC/DC:** VectorCAST, LDRA, gcov+análisis.

## 12. Sistemas distribuidos / consistencia / DST

- **Jepsen** (linealizabilidad/consistencia bajo fallo), Maelstrom, Lincheck (JVM).
- **Deterministic Simulation Testing:** Antithesis (plataforma), FoundationDB
  simulator, madsim (Rust), TigerBeetle VOPR (referencias de patrón).

## 13. Ingeniería del caos / resiliencia

- AWS Fault Injection Service (FIS), Gremlin, Chaos Mesh, LitmusChaos,
  Chaos Monkey/Simian Army, Toxiproxy, Pumba, Steadybit.

## 14. Visual / snapshot

- Applitools Eyes, Percy, Chromatic, Playwright/Cypress snapshots, BackstopJS,
  Loki (Storybook), reg-suit.

## 15. Accesibilidad

- axe-core / @axe-core/playwright, Lighthouse, Pa11y, WAVE, Accessibility Insights,
  Storybook a11y, screen readers (NVDA, VoiceOver, JAWS) para verificación manual.

## 16. BDD / specification

- Cucumber (Gherkin), SpecFlow/Reqnroll (.NET), Behave (Py), pytest-bdd,
  Behat (PHP), Serenity BDD, Robot Framework.

## 17. IA / LLM / ML — evaluación

- **Evals/harness:** OpenAI Evals, **Inspect** (UK AISI), lm-evaluation-harness,
  HELM, Promptfoo, DeepEval, Giskard, Ragas (RAG), TruLens, LangSmith, Langfuse,
  Phoenix (Arize).
- **ML clásico/datos:** Great Expectations, Pandera, TFDV, deepchecks,
  Evidently (drift), Fairlearn, Alibi/What-If (explicabilidad), CheckList.

## 18. Datos / ETL / analítica

- Great Expectations, dbt tests, Soda, Pandera, Monte Carlo, Datafold/data-diff,
  Deequ/PyDeequ (Spark).

## 19. Observabilidad / testing in production / synthetic

- Prometheus+Grafana, OpenTelemetry, Datadog, New Relic, Grafana k6 Cloud,
  Checkly, Pingdom, Synthetics (Datadog/AWS/Azure), Sentry. Feature flags:
  LaunchDarkly, Unleash, Flagsmith, OpenFeature.

## 20. Gestión de pruebas y defectos

- Azure DevOps Test Plans, Jira + Xray/Zephyr, TestRail, qTest, PractiTest,
  Testmo, Allure TestOps. Bugs: Jira, Azure Boards, GitHub Issues, Linear, Bugzilla.

## 21. Reporting de resultados

- Allure, JUnit XML, ReportPortal, Playwright/Cypress HTML, ExtentReports,
  TestNG/Surefire reports.

## 22. CI/CD y orquestación

- GitHub Actions, GitLab CI, Azure Pipelines, Jenkins, CircleCI, Buildkite,
  Argo (CD/Workflows), Tekton. Build/cache de test: Bazel, Nx, Turborepo, Gradle.

## 23. Entornos, contenedores y datos de prueba

- **Aislamiento:** Docker/Podman, docker compose, Testcontainers, Kubernetes
  (kind/minikube/k3d), Vagrant.
- **Service virtualization/mocks:** WireMock, mountebank, Hoverfly, Mockoon,
  Prism, MockServer, nock/msw (JS).
- **Datos de prueba:** Faker, factory_boy/FactoryBot, Synthea, Mockaroo,
  herramientas de masking/subsetting (Tonic, Delphix, GenRocket).
- **IaC para entornos:** Terraform, Pulumi, Bicep/ARM, CloudFormation, Helm.

## 24. Combinatorial / model-based

- NIST ACTS, PICT (Microsoft), Hypothesis (estrategias), GraphWalker (MBT),
  AltWalker.

---

## Cómo usar este catálogo (regla del maestro)

1. Identifica el **objetivo de prueba** y el **atributo de calidad** en juego.
2. Detecta el **stack** y lo ya presente en el repo/CI.
3. Elige la herramienta que mejor encaja; si no está, **aprovisiónala**
   (ver [ejecucion-autonoma.md](ejecucion-autonoma.md) §3).
4. **Justifica** la elección y deja la ejecución **reproducible** (script/contenedor).
5. Verifica por web si hay una opción más vigente antes de fijarla como estándar.
