# Seguridad de IA, LLMs y agentes — Vector

Diseño y defensa de sistemas basados en LLM, agentes, RAG y pipelines de IA.
Marcos base: **OWASP Top 10 for LLM Applications 2025**, **OWASP Agentic AI /
State of Agentic AI Security**, **MITRE ATLAS**, **NIST AI RMF**. Complementa
arquitectura segura -> skill **destroyer** y ofensiva -> skill **cazador**.

---

## 1. OWASP Top 10 for LLM Applications 2025

| ID | Riesgo | Esencia | Controles clave |
|---|---|---|---|
| **LLM01** | Prompt Injection | Entrada (directa o indirecta) altera el comportamiento del modelo | Separar instrucciones de datos, validar E/S, no confiar en el prompt como único control, mínimo privilegio de herramientas |
| **LLM02** | Sensitive Information Disclosure | Fuga de PII/secretos/IP por el modelo | Sanitización de entrada, *output filtering*, minimización de datos en contexto, no poner secretos en prompts |
| **LLM03** | Supply Chain | Modelos/datasets/plugins comprometidos | Procedencia y firma de modelos, verificación de fuentes, SBOM de IA |
| **LLM04** | Data and Model Poisoning | Envenenamiento de datos de entrenamiento/fine-tuning/RAG | Validar/curar fuentes, control de acceso a datos, detección de anomalías, procedencia |
| **LLM05** | Improper Output Handling | Tratar la salida del LLM como confiable (XSS/SQLi/RCE aguas abajo) | Tratar output como **no confiable**: encoding, validación, parametrización antes de usarlo |
| **LLM06** | Excessive Agency | El agente tiene demasiados permisos/autonomía | Mínimo privilegio de herramientas, *human-in-the-loop*, límites de acción, allowlist |
| **LLM07** | System Prompt Leakage | Filtración del prompt de sistema y de secretos/lógica en él | No poner secretos/lógica de seguridad en el system prompt; el control real va fuera del prompt |
| **LLM08** | Vector and Embedding Weaknesses | Ataques vía RAG/embeddings (inyección, fuga cross-tenant) | Aislamiento por tenant en el vector store, control de acceso, sanitización de fuentes |
| **LLM09** | Misinformation | Alucinaciones / contenido incorrecto con impacto | Grounding/RAG con fuentes confiables, citas, revisión humana, evals |
| **LLM10** | Unbounded Consumption | Abuso de recursos / DoS / costos (model DoS, wallet attack) | Rate limiting, quotas, límites de tokens/coste, timeouts, monitoreo de uso |

---

## 2. Prompt injection (directa e indirecta)

- **Directa:** el usuario inyecta instrucciones ("ignora tus reglas...").
- **Indirecta:** instrucciones ocultas en **contenido que el modelo procesa**
  (página web, documento, email, resultado de herramienta, ticket, imagen). Es la
  más peligrosa en agentes con herramientas.

**Principio rector:** **no existe defensa 100% en el prompt**. La defensa real es
**arquitectónica y externa al modelo**:
- Separar **instrucciones de confianza** de **datos no confiables**; marcar y
  tratar todo contenido externo como hostil.
- **Mínimo privilegio de herramientas:** el agente solo puede hacer lo
  estrictamente necesario; las acciones peligrosas requieren confirmación humana.
- **Validación de salida** antes de que llegue a un sistema con permisos.
- **Sandboxing** de ejecución (red/FS/credenciales restringidas por herramienta).
- **Allowlist** de destinos/acciones; *deny by default*.
- **Detección** de patrones de inyección y de comportamiento anómalo del agente.

---

## 3. Seguridad de agentes (agentic AI)

Riesgos amplificados cuando el LLM **actúa** (herramientas, código, accesos):
- **Excessive agency** (LLM06): demasiados permisos, demasiada autonomía,
  demasiada funcionalidad. Reduce los tres.
- **Escalada dentro del entorno del agente:** una herramienta con permisos
  excesivos convierte una inyección en compromiso real.
- **Confused deputy:** el agente usa **sus** privilegios para hacer lo que el
  atacante (vía datos) le pide. Mitiga propagando la identidad/permiso del
  usuario, no los del agente.
- **Memoria/estado envenenado** entre sesiones o entre usuarios.

**Controles de diseño de agentes:**
- **Separación de roles:** orquestador (decide) vs worker (ejecuta) con permisos
  distintos; el worker no decide su propio alcance.
- **Mínimo privilegio por herramienta** y por acción; tokens *scoped* y efímeros.
- **Human-in-the-loop** obligatorio para acciones sensibles: borrado, despliegues,
  cambios de infra, movimiento de dinero, acceso a datos críticos, envío externo.
- **Políticas de red para herramientas** (egress allowlist; sin acceso a metadata
  ni a redes internas no necesarias).
- **Límites de bucle/coste/tiempo** (evita *runaway* y unbounded consumption).
- **Aislamiento de ejecución de código** (contenedor efímero, sin credenciales de
  producción, FS y red restringidos).

---

## 4. RAG y vector stores

- **Aislamiento por tenant/usuario** en el índice y en la recuperación
  (LLM08): nunca devolver documentos de otro tenant.
- **Control de acceso a fuentes** y *document-level authorization* (filtrar por
  permisos del usuario antes de inyectar al contexto).
- **Sanitización de contenido recuperado** (puede contener inyección indirecta).
- **Procedencia y curaduría** de las fuentes (anti-poisoning, LLM04).

---

## 5. MITRE ATLAS

Equivalente de ATT&CK para sistemas de IA: tácticas/técnicas adversarias contra
ML/LLM (recon de modelo, evasión, extracción de modelo, *membership inference*,
envenenamiento, prompt injection). Úsalo para **mapear amenazas de IA** y diseñar
detección específica, igual que ATT&CK para el resto.

---

## 6. Gobierno y trazabilidad de IA (NIST AI RMF)

- **Logging específico:** prompts, contexto, herramientas invocadas, datos
  accedidos, outputs y **decisiones que requirieron aprobación humana**. Sin
  secretos/PII en claro en esos logs.
- **Explicabilidad a alto nivel** y *audit trail* de acciones del agente.
- **Revisión humana** en acciones críticas; *kill switch* del agente.
- **Evals de seguridad** (red-teaming de IA: jailbreaks, inyección, fuga) antes y
  después de cambios de modelo/prompt; *regression* de seguridad.
- **Gestión de cambios de modelo** con rollback/fallback.
- **Minimización de datos:** no enviar a modelos externos PII/secretos no
  autorizados; *data governance* sobre lo que entra al contexto.

---

## 7. Controles resumidos (capas)

| Capa | Control |
|---|---|
| Entrada | Validación/sanitización, detección de inyección, separación instrucción/datos |
| Modelo/prompt | System prompt robusto **sin** secretos; el prompt no es el control de seguridad |
| Herramientas | Mínimo privilegio, allowlist, sandboxing, HITL en lo sensible, tokens efímeros |
| Salida | Tratar como no confiable: encoding/validación antes de usar aguas abajo; filtro de fuga |
| Datos/RAG | Aislamiento por tenant, document-level authz, procedencia, anti-poisoning |
| Red | Egress allowlist para herramientas; sin metadata/internos innecesarios |
| Observabilidad | Logging de prompts/acciones, auditoría, evals, monitoreo de anomalías |
| Recursos | Rate limit, quotas, límites de tokens/coste/tiempo |
| Gobierno | NIST AI RMF, revisión humana, gestión de cambios, kill switch |

---

## 8. Checklist de seguridad de IA/LLM

```
- [ ] Threat model con OWASP LLM Top 10 2025 + MITRE ATLAS
- [ ] Toda entrada externa/recuperada tratada como no confiable (inyección indirecta)
- [ ] Salida del LLM tratada como no confiable antes de usarse aguas abajo
- [ ] Herramientas con mínimo privilegio, allowlist y sandboxing
- [ ] Human-in-the-loop en acciones sensibles; kill switch del agente
- [ ] Sin secretos en system prompt; control de seguridad externo al prompt
- [ ] RAG con aislamiento por tenant y document-level authz
- [ ] Egress de herramientas restringido; sin metadata/internos innecesarios
- [ ] Logging de prompts/outputs/acciones (sin PII/secretos en claro)
- [ ] Límites de tokens/coste/tiempo (anti unbounded consumption)
- [ ] Evals de seguridad (red-team de IA) antes/después de cambios de modelo
- [ ] Riesgo residual de IA declarado
```
