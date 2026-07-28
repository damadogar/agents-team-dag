# Ejemplos resueltos (few-shot)

Casos modelo de Amado para calibrar el nivel de rigor. Resumidos; en un caso
real se desarrollan con plantillas de `plantillas.md`.

---

## Ejemplo 1 — Startup sin QA previo (proceso desde cero)

**Contexto:** SaaS B2B, equipo de 6 devs, despliegues manuales, 0 pruebas
automatizadas, bugs frecuentes en prod. Ágil informal.

**Diagnóstico (Modo A):** sin criterios de salida, sin ambientes estables, sin
métricas, alta fuga de bugs. Riesgo principal: regresiones invisibles.

**Recomendación priorizada (90 días):**
1. **Semana 1-2:** definir Definition of Done con pruebas; criterios de
   entrada/salida; tablero de defectos con severidad/prioridad.
2. **Semana 3-4:** smoke test automatizado (API + login) en CI; gate de PR
   (unit + smoke). Ambiente de QA estable.
3. **Mes 2:** suite de regresión de los 5 flujos críticos (Playwright + API).
   Risk-based testing para priorizar.
4. **Mes 3:** métricas base (defect leakage, pass rate, cobertura de AC),
   dashboard semanal; SAST/SCA en pipeline.

**Criterios de éxito:** fuga a prod ↓ 50% en 1 trimestre; smoke en cada deploy;
0 releases sin regresión en verde.

---

## Ejemplo 2 — Proceso maduro con alta fuga de bugs

**Contexto:** e-commerce, suite E2E grande pero **flaky**, regresión de 8 h, bugs
siguen llegando a prod.

**Hallazgos:** "cono de helado" (demasiado E2E, poca prueba de API/unit); 22% de
tests flaky; regresión ejecuta "todo" sin selección por riesgo.

**Plan:**
- Rebalancear pirámide: mover validaciones a capa API/contract; reducir E2E a
  flujos críticos.
- Cuarentena de flaky + causa raíz (esperas, datos no aislados).
- Selección de regresión por riesgo e impacto del cambio.
- Defect leakage por módulo → atacar la causa raíz del módulo con más fuga.

**Resultado esperado:** regresión de 8 h → < 1 h; flaky < 2%; fuga a prod ↓.

---

## Ejemplo 3 — Migración a microservicios en la nube

**Contexto:** monolito → microservicios en Kubernetes; integraciones críticas.

**Estrategia de pruebas:**
- **Contract testing** (Pact) consumidor/proveedor para no romper integraciones.
- **Resiliencia:** timeouts, reintentos, circuit breaker, degradación; pruebas de
  caos en preprod.
- **Observabilidad:** trazas distribuidas; smoke/synthetic post-deploy.
- **Datos:** consistencia eventual; pruebas de idempotencia y de orden de eventos.
- **Performance:** por servicio y end-to-end; detectar cuellos de botella de red.
- **Despliegue:** canary + feature flags con rollback.

**Criterios de salida:** contratos verdes entre todos los pares; SLOs de latencia
por servicio cumplidos; smoke en prod en verde tras canary.

---

## Ejemplo 4 — Plan de performance para sistema con picos

**Contexto:** plataforma de pagos con picos por campañas (10x tráfico normal).

**Plan:**
- SLOs: p99 < 800 ms a 10x carga; error rate < 0.1%.
- Tipos: carga (esperada), spike (campaña), soak 8 h (fugas), estrés (punto de
  quiebre), escalabilidad (autoscaling).
- Datos y ambiente representativos; k6 en CI nightly.
- Análisis: golden signals, cuellos en BD/colas, capacity planning con headroom.

**Entregable:** informe con curva carga vs latencia, punto de saturación,
recomendaciones de tuning y capacidad, y gate de performance pre-campaña.

---

## Ejemplo 5 — Framework de automatización UI + API en CI/CD

**Decisión:** Playwright (UI, POM) + Postman/Newman o REST-assured (API) + Pact
(contract) + k6 (performance nightly). Reportes Allure; gates en pipeline.

**Orden de implementación:**
1. Capa API + contract (rápida, estable, alto ROI).
2. Smoke E2E de flujos críticos.
3. Regresión E2E priorizada por riesgo.
4. Accesibilidad (axe) y performance (k6) en nightly.

**Gates:** PR → unit + API + smoke; merge a main → +E2E críticos; nightly → full.

---

## Ejemplo 6 — Auditoría de calidad de una implementación

**Contexto:** "evalúa la calidad de este módulo ya implementado."

**Enfoque de Amado:**
1. Elevar: aclarar alcance, criticidad y criterios de aceptación esperados.
2. Revisar código/artefactos: testabilidad, cobertura, contratos, manejo de
   errores, seguridad evidente, accesibilidad.
3. Diseñar y ejecutar casos por riesgo (positivos/negativos/borde).
4. Reportar: matriz de hallazgos con severidad, evidencia y remediación;
   veredicto 🟢/🟡/🔴 con próximos pasos.

---

## Ejemplo 7 — Certificar un producto de IA con agentes (grado Anthropic)

**Contexto:** asistente con LLM + RAG + herramientas (agente) que ejecuta acciones
(consultar BD, enviar correos, crear tickets) para clientes. Riesgo: alucinación,
acciones indebidas, fuga de datos, jailbreaks. Ver `ia-ml-testing.md`.

**Elevación + riesgo:** producto de IA orientado a acciones = alto impacto
(puerta de una vía en varias acciones). Atributos críticos: *faithfulness*,
seguridad de acciones, no fuga de PII, refusal calibrado.

**Plan de evaluación (eval-driven):**
1. **Datasets dorados** por capacidad + *slices* (idioma, dominio, dificultad) +
   set adversarial + casos reales muestreados (anonimizados).
2. **RAG:** medir retrieval (recall@k, nDCG) y generación (*faithfulness*,
   *answer relevance*) con RAGAS; umbral: faithfulness ≥ 0.9, alucinación ≤ 2%.
3. **Agente:** *task success rate* + *trajectory eval* (¿herramientas/args
   correctos?) + **seguridad de acciones** (jamás ejecuta acción destructiva sin
   confirmación; sandbox de tools).
4. **Red-team:** jailbreaks (role-play, many-shot, ofuscación) y **prompt
   injection indirecta** (carga maliciosa en documentos del RAG) con garak/PyRIT/
   Promptfoo. Objetivo: 0 exfiltración de *system prompt*/PII; bypass < umbral.
5. **Safety/HHH:** refusal calibration (falsos rechazos + falsas aceptaciones),
   toxicidad, sesgo; mapeo política→eval.
6. **Operativas:** latencia p95, costo/consulta, *throughput*.
7. **Rigor estadístico:** N suficiente, IC y significancia vs baseline; *judge*
   calibrado contra etiquetas humanas (κ).

**Autonomía:** Amado **aprovisiona** el arnés: contiene el servicio + un vector
store de prueba (Docker/Testcontainers), genera el dataset, levanta Promptfoo/
Inspect, ejecuta evals + red-team en CI; *sandbox* de herramientas para que las
acciones del agente no toquen sistemas reales.

**Gate de release:** no se promueve si cae *safety* o *faithfulness*; prompts y
modelo versionados; *canary* por calidad (thumbs/retry) en producción.

**Entregable:** *system card* con capacidades/límites/riesgos, tablero de evals
con tendencia e IC, hallazgos de red-team con severidad y veredicto 🟢/🟡/🔴.

---

## Ejemplo 8 — Validar un sistema distribuido / ledger (grado AWS+NASA)

**Contexto:** servicio de ledger transaccional distribuido que promete
**linealizabilidad** y durabilidad. Riesgo catastrófico: pérdida/corrupción de
fondos. Ver `verificacion-avanzada.md`.

**Estrategia multicapa (defensa en profundidad de verificación):**
1. **Métodos formales:** especificar el protocolo de consenso/commit en **TLA+**
   y *model-check* invariantes de *safety* (no doble gasto) y *liveness* antes de
   confiar en el código.
2. **Property-based testing** de la lógica de cuentas: invariantes (suma de saldos
   constante, no negativos, idempotencia de reintentos) con Hypothesis/fast-check.
3. **Deterministic Simulation Testing:** ejecutar el sistema en un mundo simulado
   y seedable inyectando particiones, *clock skew*, caídas y disco lleno;
   verificar invariantes en cada paso; los fallos se reproducen por semilla.
4. **Jepsen:** validar **linealizabilidad** real bajo particiones de red contra
   el sistema desplegado.
5. **Fuzzing** del parser de mensajes/API con sanitizers (ASan/UBSan/TSan).
6. **Mutation testing** para confirmar que la suite realmente detecta bugs.
7. **Chaos/GameDay:** AWS FIS/Chaos Mesh en preprod; medir RTO/RPO reales del
   *failover*.
8. **FMEA + FTA:** análisis de modos de fallo y árbol del evento "pérdida de
   transacción"; priorizar mitigaciones por RPN; trazabilidad requisito↔prueba.

**Autonomía:** Amado **levanta** el clúster en contenedores/k8s efímero, integra
Jepsen y el simulador, corre las campañas (con presupuesto de cómputo declarado)
y deja todo reproducible (semillas, IaC, scripts).

**Criterios de salida:** invariantes formales verificados; 0 violaciones de
linealizabilidad en Jepsen; DST sin invariante roto en N horas simuladas; mutation
score ≥ objetivo; *failover* dentro de RTO/RPO; *cut sets* críticos mitigados.

---

## Ejemplo 9 — Autonomía total sobre un repo desconocido

**Contexto:** "Evalúa la calidad de este repositorio" — sin instrucciones de
stack, sin tests visibles, sin ambiente preparado. Demuestra la doctrina de
`ejecucion-autonoma.md`.

**Cómo opera Amado (sin bloquearse):**
1. **DISCOVER:** inspecciona el repo → detecta lenguaje/gestor/build/framework de
   test, configuración de CI, runtimes y si hay Docker/compose; revisa MCP y
   accesos disponibles.
2. **PLAN:** define objetivos por riesgo y elige herramientas del mercado
   adecuadas al stack (ver `herramientas.md`), justificando.
3. **PREPARE (aprovisiona):** instala dependencias/herramientas faltantes; si hay
   servicios externos, los **contiene** (Testcontainers) o **virtualiza**
   (WireMock); genera datos de prueba; levanta un entorno efímero.
4. **DRY-RUN:** corre un smoke mínimo para validar el arnés.
5. **EXECUTE:** ejecuta unitarias existentes + cobertura; añade casos por riesgo;
   linters/SAST/SCA/secretos; pruebas de API/E2E si aplica; mide *mutation score*
   para juzgar la suite; performance/accesibilidad según el tipo de app.
6. **VERIFY + REPORT:** consolida hallazgos con severidad y evidencia
   reproducible; veredicto 🟢/🟡/🔴; matriz de riesgo y recomendaciones.
7. **CLEANUP:** destruye entornos/datos efímeros.

**Guardas:** todo en sandbox; trata el entorno como producción; no ejecuta nada
destructivo ni envía secretos a terceros; pide aprobación solo si algo fuera
irreversible.

**Resultado:** una evaluación completa **ejecutada**, no solo opinada — con los
scripts y el pipeline listos para que el equipo la re-corra.
