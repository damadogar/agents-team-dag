# checklists.md — Checklists operativos de Analytics Engineering

Checklists accionables de Brujula. Úsalos como *gates* antes de
modelar, certificar métricas o publicar cambios. Resumen en [SKILL.md](SKILL.md)
§23.

---

## 1. Diseño de modelo semántico (antes de construir)

- [ ] Concepto/proceso de negocio entendido y validado con PO/BA
- [ ] *Grain* explícito de cada tabla de hechos definido
- [ ] Dimensiones identificadas; reutiliza conformadas (bus matrix)
- [ ] Datos requeridos disponibles en core (confirmado con caudal)
- [ ] Enfoque elegido (estrella/OBT/incremental) justificado
- [ ] 2–3 alternativas evaluadas → ADR semántico

## 2. Definición de métrica

- [ ] Definición de negocio aprobada por PO/BA
- [ ] Fórmula, *grain*, dimensiones válidas, filtros y *time grain* documentados
- [ ] Aditividad evaluada (aditiva/semi/no aditiva, ratios)
- [ ] *Owner* asignado y estado (propuesta/certificada)
- [ ] No duplica una métrica existente (revisado en el catálogo)
- [ ] Reconciliación contra fuente/detalle

## 3. Construcción y calidad

- [ ] Modelos en capas (staging/intermediate/marts) sin lógica duplicada
- [ ] Tests: `unique`, `not_null`, `relationships`, `accepted_values` en críticos
- [ ] Materialización adecuada (view/table/incremental) justificada
- [ ] Idempotencia verificada (reejecución no duplica)
- [ ] Reconciliación del modelo contra core
- [ ] Documentación de modelo y columnas escrita

## 4. Seguridad / gobernanza de la capa

- [ ] PII no expuesta en marts sin enmascaramiento/justificación
- [ ] Control de acceso a métricas/modelos según política (con andulfo/destroyer)
- [ ] Linaje y diccionario actualizados (qué dato sensible llega a consumo)
- [ ] Clasificación de datos respetada

## 5. Despliegue / cambio

- [ ] Cambio compilado y testeado en dev/stg; tests en CI verdes
- [ ] Impacto en consumidores analizado (linaje/exposures)
- [ ] Cambio incompatible → expand/contract + *deprecation* anunciada
- [ ] Delta esperado de métrica validado con PO/BA (si cambia definición)
- [ ] Plan de **rollback** disponible (modelo/métrica anterior en paralelo)
- [ ] Documentación/diccionario regenerados y publicados
- [ ] Comunicación a consumidores enviada

## 6. Operación continua

- [ ] *Freshness* de marts dentro de SLA
- [ ] Métricas certificadas con definición única y *owner*
- [ ] Sin métricas duplicadas/divergentes activas
- [ ] Performance p95 de dashboards clave dentro de SLO
- [ ] Modelos sin docs/tests = 0 en capa certificada
- [ ] Catálogo navegable y linaje al día
