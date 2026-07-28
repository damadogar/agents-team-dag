# Checklists de Product Ownership

Checklists accionables de **tompo** (Product Owner). Marca casillas; adapta a la
criticidad y al marco (Scrum/SAFe/Kanban/LeSS/Nexus). Cada checklist dice su
**propósito** y enlaza al satélite que lo desarrolla.

> **Frontera de rol (recordatorio):** tompo decide el **qué/porqué**; el **cómo** es del
> especialista. La **DoD** es de **amado**, no de tompo; los gates de seguridad/
> cumplimiento son de **destroyer/cazador/centinela/sello/vector**. Ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## 1. Discovery (¿hay problema validado?)

*Propósito:* no construir hasta validar el problema, la evidencia de usuario y los 4
riesgos. Detalle en [descubrimiento.md](descubrimiento.md).

- [ ] El **problema** está definido en términos de usuario/JTBD, no de solución.
- [ ] Hay **evidencia de usuario** real (entrevistas, datos, soporte), no opinión.
- [ ] El **outcome** buscado es medible y está trazado al Product Goal.
- [ ] La oportunidad nace del **OST** (outcome→oportunidad→solución→experimento).
- [ ] Los **4 grandes riesgos** están evaluados y con plan para derribarlos:
  - [ ] **Valor** — ¿lo querrán/usarán? (tompo + uxuifull research)
  - [ ] **Usabilidad** — ¿sabrán usarlo? (uxuifull)
  - [ ] **Factibilidad** — ¿se puede construir? (eneida/motor/farola)
  - [ ] **Viabilidad** — ¿funciona para el negocio (legal, coste, seguridad)? (sello, negocio)
- [ ] El supuesto más riesgoso tiene un **experiment card** (prueba mínima + umbral).

---

## 2. Calidad de historia (INVEST)

*Propósito:* que cada historia sea construible y valiosa. Detalle en
[backlog-requisitos.md](backlog-requisitos.md).

- [ ] **I**ndependiente: se puede entregar sin acoplarse a otra.
- [ ] **N**egociable: describe intención, no un contrato cerrado de solución.
- [ ] **V**aliosa: aporta valor observable al usuario/negocio (link al outcome).
- [ ] **E**stimable: el equipo la entiende lo suficiente para dimensionarla.
- [ ] **S**mall (pequeña): cabe en un sprint / es "pull-able" en flujo.
- [ ] **T**esteable: tiene criterios de aceptación verificables.

### Criterios de aceptación

- [ ] Escritos en **Gherkin** (Given-When-Then) u otra forma verificable.
- [ ] Cubren camino feliz **y** casos de error/borde relevantes.
- [ ] Acordados con **amado** (quien los vuelve casos de prueba) — RACI #7.
- [ ] No describen el **cómo** técnico (eso es de eneida/motor/farola).
- [ ] Incluyen criterios de **cumplimiento/accesibilidad** si aplican.

---

## 3. Definition of Ready (entrada a sprint/flujo)

*Propósito:* gate de entrada; la **DoD es de amado**. Plantilla en
[plantillas.md](plantillas.md), detalle en [backlog-requisitos.md](backlog-requisitos.md).

- [ ] Outcome/valor claro y trazado.
- [ ] INVEST cumplido y criterios de aceptación testeables.
- [ ] Diseño/UX disponible (handoff de **uxuifull**) si aplica.
- [ ] Dependencias técnicas identificadas (**eneida/motor/farola**), sin bloqueos.
- [ ] Requisitos de seguridad/cumplimiento marcados (**sello**) si aplica.
- [ ] El equipo la entiende y la considera dimensionable.

---

## 4. Refinamiento de backlog (DEEP)

*Propósito:* mantener el backlog sano y "pull-able". Detalle en
[backlog-requisitos.md](backlog-requisitos.md).

- [ ] **D**etailed appropriately: lo de arriba más detallado que lo de abajo.
- [ ] **E**stimated: ítems próximos dimensionados por el equipo.
- [ ] **E**mergent: el backlog evoluciona con el aprendizaje (loop de métricas).
- [ ] **P**rioritized: ordenado por valor/riesgo con método explícito.
- [ ] Ítems obsoletos eliminados; duplicados fusionados.
- [ ] Historias grandes partidas en incrementos verticales de valor.
- [ ] Cada ítem del tope del backlog cumple (o está cerca de) la **DoR**.

---

## 5. Priorización

*Propósito:* que el orden del backlog sea justificable y trazable, no por opinión.
Detalle en [priorizacion-valor.md](priorizacion-valor.md).

- [ ] Hay un **método explícito** (RICE/WSJF/MoSCoW/Kano/ICE) adecuado al contexto.
- [ ] Cada ítem tiene **trazabilidad** en la cadena **outcome → oportunidad → solución → historia → criterio de aceptación → métrica** (no features huérfanas).
- [ ] Se consideró el **coste de retraso** (Cost of Delay) y la urgencia.
- [ ] El **esfuerzo/tamaño** proviene del equipo (no impuesto por tompo).
- [ ] Se hizo explícito el **trade-off** ("si priorizo esto, dejo de hacer aquello").
- [ ] La decisión es comunicable a stakeholders con su porqué.

---

## 6. Sprint Review / aceptación del incremento

*Propósito:* aceptar contra **criterios de aceptación** (lo de tompo), **no contra la
DoD** (que es de amado, RACI #8/#11). Detalle en
[stakeholders-liderazgo.md](stakeholders-liderazgo.md).

- [ ] Cada historia se evalúa contra **sus criterios de aceptación**.
- [ ] El incremento ya cumple la **DoD** entregada por **amado** (prerrequisito, no lo valida tompo).
- [ ] Lo que no cumple criterios se rechaza y vuelve al backlog (no se "acepta a medias").
- [ ] Se recoge feedback de stakeholders y se traduce en ítems/aprendizajes.
- [ ] Se actualiza el avance hacia el **Product Goal** y se re-prioriza si hace falta.
- [ ] tompo **no** convierte la review en validación técnica (eso es del equipo).

---

## 7. Release readiness

*Propósito:* go/no-go de **valor** (tompo) con **gates** de otros owners. Plantilla en
[plantillas.md](plantillas.md).

- [ ] **Gate de calidad = amado:** DoD, regresión en verde, no funcional dentro de umbral.
- [ ] **Gate de seguridad = destroyer:** sign-off de superficie de seguridad/datos.
- [ ] **Cumplimiento = sello:** privacidad/regulación firmadas si aplica.
- [ ] **IA = sysuniversal-ai + vector:** evals/safety si el release incluye IA.
- [ ] **Métricas listas:** instrumentación validada con **brujula**; sabremos leer el outcome.
- [ ] **Rollback / kill-switch** definido por el equipo; trigger de negocio definido por tompo.
- [ ] Estrategia de entrega (feature flag/canary/% rollout) acordada.
- [ ] **Go/No-Go de valor** decidido por tompo y comunicado a stakeholders.

---

## Incidente / expedite en producción

*Propósito:* ante un incidente o bug crítico que afecta valor/usuarios, re-priorizar
con urgencia desde la óptica de **valor** sin invadir el cómo técnico. Detalle en
[ejecucion-autonoma.md](ejecucion-autonoma.md).

- [ ] **Re-priorización urgente** (clase **expedite**; L2 con aviso), negociando la
  interrupción del trabajo en curso con los Developers.
- [ ] Decisión **hotfix vs backlog** tomada desde **valor/negocio** (el fix técnico es de
  motor/farola/eneida; el cómo no lo decide tompo).
- [ ] **Comunicación a stakeholders:** impacto, qué se prioriza, trade-off y plan de
  validación posterior.
- [ ] **Gate de calidad = amado** y **gate de seguridad = destroyer** respetados si aplican.
- [ ] Trazabilidad y medición del incidente intactas (outcome/métrica de recuperación).

---

## 8. Lanzamiento / GTM (alto nivel)

*Propósito:* coordinar el lanzamiento sin invadir product marketing/PM. Detalle en
[stakeholders-liderazgo.md](stakeholders-liderazgo.md).

- [ ] Outcome del lanzamiento y métrica de adopción definidos.
- [ ] Mensaje/posicionamiento alineado con **PM / product marketing** (no es ownership de tompo).
- [ ] Segmento/canal de lanzamiento y plan de rollout escalonado.
- [ ] Soporte, ventas y éxito de cliente informados (enablement) si aplica.
- [ ] Release notes / comunicación a usuarios listas.
- [ ] Plan de medición post-lanzamiento y umbral para escalar/pausar.
- [ ] Riesgos de negocio y plan de contingencia comunicados.

---

## 9. Cumplimiento (privacidad, accesibilidad, IA responsable)

*Propósito:* que el cumplimiento entre como **criterio desde discovery**, no como parche.
tompo lo **incorpora**; el sign-off técnico/legal es de **sello**. Detalle en
[cumplimiento-regulacion.md](cumplimiento-regulacion.md) e [ia-producto.md](ia-producto.md).

- [ ] **Privacidad:** base legal, minimización de datos, consentimiento, derechos del titular (GDPR/Habeas Data/CCPA) — con sello.
- [ ] **Accesibilidad:** criterios **WCAG 2.2 AA** incorporados a las historias (con uxuifull y amado).
- [ ] **Seguridad:** datos sensibles, autorización y superficie de ataque revisadas con destroyer.
- [ ] **IA responsable (si aplica):** transparencia, evals, human-in-the-loop, sesgo, OWASP LLM / NIST AI RMF / EU AI Act — con sysuniversal-ai y vector.
- [ ] Requisitos regulatorios del **dominio** (HIPAA/PCI/PSD2…) marcados como criterios y priorizados.
- [ ] Trazabilidad: requisito de cumplimiento ↔ criterio de aceptación ↔ evidencia.

---

## 10. Cierre de PO

*Propósito:* no cerrar nada sin outcome, medición y próximo paso (regla de oro del skill).

- [ ] **Outcome buscado** declarado explícitamente (resultado, no feature).
- [ ] **Cómo se medirá** definido (métrica/experimento + guardrails + cuándo se lee).
- [ ] **Próximo paso** claro y con owner.
- [ ] Supuestos abiertos marcados **[SUPUESTO]** y plan para validarlos.
- [ ] Frontera de rol respetada (qué/porqué de tompo; cómo de los especialistas).
- [ ] Trazabilidad **outcome → oportunidad → solución → historia → criterio de aceptación → métrica** intacta.

---

> Plantillas para llenar estas listas en [plantillas.md](plantillas.md); casos
> resueltos end-to-end en [ejemplos.md](ejemplos.md); rol del PO por marco en
> [frameworks-marcos.md](frameworks-marcos.md).
