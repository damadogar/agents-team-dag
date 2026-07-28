<div align="center">

<img src="assets/dag-team-logo.png" alt="DAG TEAM" width="150" />

# DAG TEAM — Guía Rápida (1 página)
**22 agentes enterprise · 2 clusters gobernados**

</div>

---

### Cómo decidir a quién invocar
**¿La tarea cruza más de un dominio o crea dependencias?**
→ **Sí:** iniciativa orquestada (empieza en `tompo` o `orquesta`).
→ **No:** tarea suelta (ve directo al especialista del dominio).

---

### Los 22 agentes en una línea

**Núcleo de producto y entrega (12)**
- `tompo` — El qué y el porqué: valor, backlog, prioridad.
- `orquesta` — Quién/cuándo/en qué orden: coordina y desatasca.
- `eneida` — Arquitectura, contratos y ADRs con trade-offs.
- `uxuifull` — Experiencia: research, flujos, design system, accesibilidad.
- `farola` — Frontend web.
- `palma` — Mobile.
- `motor` — Backend / APIs.
- `baluarte` — CI/CD, IaC, SRE, SLOs, entrega y confiabilidad.
- `peakformance` — Rendimiento: budgets, profiling, tuning.
- `certero` — Correctitud: code review y debugging.
- `amado` — Calidad: estrategia y ejecución de pruebas.
- `docpower` — Documentación con forma profesional.

**Cluster Data + IA (5)** · cadena: `andulfo → caudal → brujula → prisma → sysuniversal-ai`
- `andulfo` — Plataforma de datos / DBA / HA-DR.
- `caudal` — Pipelines y movimiento de datos.
- `brujula` — Capa semántica y métricas oficiales.
- `prisma` — Ciencia de datos: modelos e insights.
- `sysuniversal-ai` — IA en producción: serving, MLOps/LLMOps, RAG/agentes.

**Cluster Seguridad (5)** · cadena: `destroyer → cazador → centinela → sello` (+ `vector` en IA)
- `destroyer` — Núcleo: arquitectura segura, DevSecOps, cripto.
- `cazador` — Ofensiva autorizada: pentest/red team (requiere RoE).
- `centinela` — Defensa: detección, hardening, DFIR/IR.
- `sello` — GRC, ISO, privacidad, auditoría, riesgo.
- `vector` — Seguridad de IA/LLM/agentes (MLSecOps).

---

### Orden canónico de una iniciativa
```
tompo → eneida → orquesta → uxuifull → [motor/farola/palma/cluster datos-IA]
      → certero + amado + peakformance + seguridad → baluarte → docpower → retro
```

---

### 5 reglas de oro
1. **Un dueño por decisión** (nunca ownership difuso).
2. **Colaborar sí, reemplazar no** — cada cruce se resuelve con *handoff explícito*.
3. **Los gates no se saltan:** correctitud (`certero`) · calidad (`amado`) · seguridad (`destroyer`).
4. **Ofensiva solo con RoE firmado** (`cazador`).
5. **Neutralidad tecnológica:** dales tu contexto real y deciden por evidencia y riesgo.

---

### Invocación suelta — atajos frecuentes
| Necesito… | Invoco |
|---|---|
| Priorizar / historias | `tompo` |
| Plan multi-tarea | `orquesta` |
| ADR / arquitectura | `eneida` |
| Accesibilidad / rediseño de flujo | `uxuifull` |
| UI web · App móvil · Backend | `farola` · `palma` · `motor` |
| CI/CD · SLOs · IaC | `baluarte` |
| Optimizar rendimiento | `peakformance` |
| Revisar PR / cazar bug | `certero` |
| Plan de pruebas | `amado` |
| Documentar | `docpower` |
| Tuning BD · Pipeline · Métricas | `andulfo` · `caudal` · `brujula` |
| Análisis / modelo | `prisma` |
| IA a producción / RAG | `sysuniversal-ai` |
| Threat model / pentest / detección / ISO / seguridad IA | `destroyer` · `cazador` · `centinela` · `sello` · `vector` |

<div align="center">

*DAG TEAM · Enterprise Agents — Resumen v1.0. Manual completo en `MANUAL-EQUIPO-ENTERPRISE.md`.*

</div>
