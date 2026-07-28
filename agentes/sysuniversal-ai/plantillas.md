# plantillas.md — Plantillas de entregables (AI Engineering)

Formatos reutilizables. Adapta y completa; marca `[SUPUESTO]` y
`[COBERTURA ADJUNTA]` cuando aplique. Todo entregable cierra con **próximos pasos**
y **criterios de éxito medibles**.

---

## 1. Informe ejecutivo (1 página)
```
# Informe — <sistema de IA / iniciativa>
Caso de uso y decisión que habilita: ...
Recomendación: ...
Enfoque (prompting/RAG/fine-tuning/propio) y por qué: ...
Riesgos clave (seguridad/drift/costo): ...
Costo estimado (inferencia/entrenamiento): ...
Estado vs SLOs (calidad/latencia/costo/seguridad): ...
Próximos pasos: ...
Criterios de éxito medibles: ...
```

## 2. Análisis técnico (opciones)
```
# Análisis — <decisión>
Contexto y restricciones: ...
Opciones:
| Opción | Calidad | Latencia | Costo | Seguridad | Operabilidad | Lock-in |
|--------|---------|----------|-------|-----------|--------------|---------|
| A      | ...     | ...      | ...   | ...       | ...          | ...     |
Recomendación + trade-offs: ...
Reversibilidad: ...
```

## 3. ADR de IA (Architecture Decision Record)
```
# ADR-<n>: <decisión de IA>
Estado: Propuesto | Aceptado | Reemplazado
Contexto: <caso, restricciones, datos, modelo de prisma>
Decisión: <modelo/arquitectura/enfoque elegido>
Alternativas consideradas: <2-3 con por qué no>
Consecuencias: <positivas/negativas, costo, lock-in, operación>
Plan de evals, monitoreo y rollback: ...
```

## 4. Diseño de arquitectura de IA
```
# Arquitectura — <sistema>
Enfoque: <prompting/RAG/fine-tuning/propio>
Diagrama (Mermaid): <componentes: gateway, serving, guardrails, stores, obs>
Datos requeridos (a caudal/brujula): <fuentes, frescura, contrato>
Modelo (de prisma): <artefacto, versión, métricas>
Serving: <online/batch/streaming, model server, GPU>
Guardrails: <entrada/salida, OWASP LLM>
Observabilidad: <calidad/drift/sistema/costo/seguridad>
NFRs/SLOs: <latencia, throughput, costo, disponibilidad>
Rollback: <estrategia>
```

## 5. Plan de despliegue/operación
```
# Despliegue — <modelo/sistema> v<x>
Estrategia: shadow | canary | blue-green
Gates previos: evals calidad/seguridad, no-regresión, costo
Pasos de rollout: <% y criterios de avance>
Monitoreo: <métricas + umbrales + alertas>
Rollback: <disparadores + procedimiento + versión previa>
Aprobaciones / audit: ...
Criterios de éxito: ...
```

## 6. Model card / System card
```
# Model/System Card — <nombre> v<x>
Propósito y uso permitido / no permitido: ...
Datos (training/eval, fuentes, PII): ...
Enfoque/modelo base: ...
Métricas (offline/online) y umbrales: ...
Límites y casos donde falla: ...
Riesgos (sesgo, toxicidad, seguridad) y mitigaciones: ...
Guardrails y monitoreo: ...
Owners y aprobaciones: ...
```

## 7. Plan de evaluación (evals)
```
# Evals — <sistema>
Eval set: <tamaño, fuente, versión, casos adversariales/borde>
Métricas de calidad: <exactitud, faithfulness (RAG), formato>
Métricas de seguridad: <inyección, fuga PII, salidas inseguras>
Métricas de costo/latencia: <tokens, costo/req, p95>
Umbrales y criterios de aprobación: ...
Online (canary/shadow): <qué se mide en prod>
```

## 8. Especificación de requisitos de datos IA-ready (a caudal/brujula)
```
# Requisitos de datos — <sistema de IA>
Para: caudal / brujula
Datasets/features necesarios: <esquema, tipo: tabular/texto/embeddings/imagen>
Frescura/latencia de datos: ...
Volumen/histórico (training) y point-in-time: ...
Calidad/contratos esperados: ...
Restricciones (PII/residencia, gobernanza de andulfo): ...
Handoff y criterios de aceptación: ...
```

## 9. Matriz de hallazgos
```
| # | Hallazgo | Evidencia | Impacto | Severidad | Recomendación | Esfuerzo | Owner |
|---|----------|-----------|---------|-----------|---------------|----------|-------|
| 1 | ...      | ...       | ...     | 🔴/🟠/🟡/🟢 | ...           | S/M/L    | ...   |
```

## 10. Declaración de cobertura adjunta
```
[COBERTURA ADJUNTA] — SysUniversal-AI cubriendo: <rol ausente>
Alcance asumido / NO incluye: ...
Handoff esperado a <prisma / caudal / ...>: <artefactos, deuda>
Criterios para migrar ownership / riesgos: ...
```
