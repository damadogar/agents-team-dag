# checklists.md — Checklists operativos de AI Engineering

Listas accionables por fase. Marca lo que aplique; lo que quede fuera del foco se
marca `[COBERTURA ADJUNTA]` con su handoff.

---

## 1. Arquitectura del sistema de IA
- [ ] Caso de uso, decisión/acción y restricciones claras (latencia/calidad/seg/costo)
- [ ] Enfoque más simple que cumple (prompting < RAG < fine-tuning < propio)
- [ ] Componentes definidos (gateway, serving, guardrails, observabilidad)
- [ ] Requisitos de datos IA-ready negociados con caudal/brujula
- [ ] Modelo recibido de prisma con model card y métricas
- [ ] Abstracción de proveedor (anti lock-in) y estrategia de salida
- [ ] NFRs declarados (SLOs, seguridad, privacidad, recoverability)

## 2. MLOps / ciclo de vida
- [ ] Todo versionado (datos, código, features, modelo, prompts, config, entorno)
- [ ] Model registry con estados, lineage y model card
- [ ] CI/CD/CT con gates de calidad/seguridad/no-regresión/costo
- [ ] Estrategia de despliegue (shadow/canary/blue-green)
- [ ] Monitoreo de calidad/drift/skew/sistema/costo/seguridad
- [ ] Disparadores de retraining definidos
- [ ] Rollback probado + versión previa sana

## 3. Sistema LLM / RAG / agente
- [ ] Prompts versionados + eval set
- [ ] Guardrails de entrada y salida activos
- [ ] (RAG) retrieval evaluado, citations, filtros de acceso, freshness del índice
- [ ] (Agente) límites de pasos/costo, tools con permisos mínimos, human-in-the-loop
- [ ] OWASP LLM Top 10 revisado con destroyer
- [ ] Versión de modelo/proveedor fijada + alternativa

## 4. Despliegue seguro
- [ ] Eval set superado (calidad + seguridad)
- [ ] Monitoreo activo antes de servir tráfico real
- [ ] Sin PII/secretos a modelos no autorizados
- [ ] Sin train/serving skew
- [ ] Despliegue gradual + rollback disponible
- [ ] Aprobación y audit del cambio

## 5. Performance / costo
- [ ] SLOs de latencia/throughput/costo definidos
- [ ] Batching/caching/cuantización evaluados (sin sacrificar calidad sin medir)
- [ ] Autoscaling y colas con backpressure
- [ ] Routing por costo/calidad donde aplica
- [ ] Costo por petición/token monitoreado y presupuestado

## 6. Operación continua
- [ ] Alertas por SLO y por drift/seguridad
- [ ] Runbooks publicados (ver runbooks.md)
- [ ] Revisión periódica de modelos/proveedores (cambian rápido)
- [ ] Responsible AI: evals de sesgo/toxicidad, model/system card al día

## 7. Cierre de entregable
- [ ] Informe + análisis + ejecución guiada
- [ ] Próximos pasos y criterios de éxito medibles
- [ ] Handoffs marcados (prisma / caudal / brujula / andulfo / eneida / destroyer)
- [ ] `[COBERTURA ADJUNTA]` declarada si aplica
