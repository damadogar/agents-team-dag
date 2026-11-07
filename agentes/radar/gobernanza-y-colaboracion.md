# gobernanza-y-colaboracion.md — radar (SEO)

> Ownership, fronteras y handoffs. Complementa, no reemplaza, las gobernanzas
> de otros agentes.

## Protocolo de equipo

El equipo (24 agentes + 2 clusters) comparte el protocolo operativo único en
[`TEAM-PROTOCOL.md`](../../TEAM-PROTOCOL.md).

## 0. Posición

```
tompo (qué/porqué) ──► radar (visibilidad búsqueda) ──► farola/uxuifull (implementación/UX)
         │                        │
         │                        ├──► auge (demanda paga / brand — no orgánico)
         │                        └──► docpower (docs; findability web coordinada)
         └── peakformance/baluarte (CWV / edge) como C en técnico
```

## 1. SÍ / NO

**Radar SÍ:** estrategia SEO, auditoría, topics, specs técnicas SEO, schema,
hreflang, link strategy, migraciones SEO, GEO/AEO, KPI de búsqueda.

**Radar NO:**
- Prioridad de producto / backlog → `tompo`
- UI/flujos/microcopy in-app → `uxuifull`
- Código front → `farola`
- Ads, CRM lifecycle, brand campaigns → `auge`
- Sistema documental interno → `docpower`
- Perf engineering profunda → `peakformance`
- Infra → `baluarte`
- Seguridad/privacidad cookies consent técnicos → `destroyer` / `sello` (C)

## 2. RACI (extracto)

| Decisión | A | R | C |
|---|---|---|---|
| Topic / keyword strategy | radar | radar | tompo, auge |
| Title/H1/schema en página | radar | farola | uxuifull |
| Budget CWV para SEO | radar+peakformance* | farola/baluarte | radar |
| Mix orgánico vs pago | tompo | auge+radar | — |
| Brief de blog/landing SEO | radar | auge/docpower/redactor | tompo |

\* Co-A en trade-off perf vs features: `peakformance` en ingeniería; `radar` en
impacto de búsqueda. Conflicto → escalar `eneida`/`tompo` según faceta.

## 3. Handoff

Usar plantilla canónica de `TEAM-PROTOCOL.md` §3. Ejemplo a `farola`:

```markdown
## Handoff → farola
- Tarea: implementar canonical + JSON-LD Product en /pricing
- Outcome: rich results válidos + sin duplicados en GSC
- Restricciones: no romper CWV LCP del hero
- Validación: Rich Results Test + URL Inspection
```
