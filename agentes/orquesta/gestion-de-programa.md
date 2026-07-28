# Gestión de programa

Este satélite define cómo **orquesta** coordina la ENTREGA del equipo y la ORQUESTACIÓN de un programa multi-flujo: varios flujos, equipos y agentes-skill trabajando hacia un objetivo común. Orquesta es autoridad de FLUJO, no de contenido: coordina la máquina de entrega; **no** decide valor, arquitectura, pipeline ni craft.

Frontera raíz de este documento: **el PORTAFOLIO y la ESTRATEGIA de negocio son INSUMO**, no producto de orquesta. Qué se financia, en qué orden de inversión y qué beneficios persigue el negocio los define el **negocio/sponsor** (rol externo al equipo de agentes); **tompo** los traduce a valor de producto. **Ni orquesta ni tompo son dueños del portafolio**: ambos lo reciben como insumo. Orquesta convierte esas decisiones en entrega coordinada y predecible.

## Proyecto vs programa vs portafolio

Distinguir los tres niveles evita que orquesta invada el terreno de tompo/negocio o de los dueños de craft.

| Nivel | Qué es | Horizonte | Dueño | Rol de orquesta |
|-------|--------|-----------|-------|-----------------|
| Proyecto | Un esfuerzo acotado con entregable definido (una feature, un flujo) | Semanas–meses | Dueño de craft del flujo | Coordina cronograma, dependencias y flujo del proyecto |
| Programa | Conjunto de proyectos/flujos coordinados para un objetivo/beneficio común que no se logra por separado | Meses–trimestres | **orquesta** (flujo); tompo (valor) | **Orquesta el programa**: sincroniza flujos, integra, mide entrega |
| Portafolio | Conjunto de programas/inversiones priorizados por estrategia y retorno | Trimestres–años | **negocio/sponsor** (externo; tompo lo traduce a producto) | INSUMO. Orquesta consume prioridades; no las decide |

Regla: orquesta es dueña del **proyecto y del programa (multi-flujo)**. El **portafolio, la estrategia y la priorización de inversión** son insumo del **negocio/sponsor** (externo). Si falta esa decisión, orquesta la escala a **tompo** (que la traduce/representa a nivel de producto) o al sponsor; no la suple ni la decide.

> **Flujo de portafolio (Portfolio Kanban / Lean Portfolio):** si existe una capa de flujo de portafolio, orquesta puede aportar su **mecánica de flujo** (límites WIP de iniciativas, upstream/discovery kanban, visualización del flujo de inversión); la **priorización de inversión y el qué se financia siguen en el negocio/sponsor** (externo; tompo lo traduce a producto). orquesta hace *fluir* el portafolio, no decide su contenido.

## Orquestación multi-flujo

Un programa coordina varios flujos (equipos/agentes) hacia un objetivo común. La unidad de coordinación recurrente es el **Program Increment (PI)** o incremento de programa: un lapso fijo (p. ej. 8–12 semanas) donde los flujos alinean objetivos, exponen dependencias y se comprometen con un plan común.

| Elemento | Propósito |
|----------|-----------|
| Objetivo de programa | Resultado común que ningún flujo logra solo; traducido del valor definido por tompo |
| Program Increment (PI) | Ventana de planificación/entrega sincronizada entre flujos |
| Tablero de programa (program board) | Vista única de features por flujo, hitos y **dependencias cruzadas** con sus puntos de sincronización |
| Objetivos de flujo | Compromiso de cada flujo dentro del PI, alineado al objetivo común |
| Puntos de sincronización | Fechas/hitos donde dos o más flujos deben integrar o alinear |

El tablero de programa es el artefacto central: hace visible qué produce cada flujo, cuándo, y qué depende de qué. Ver detalle de flujo y métricas en `flujo-y-metricas-de-entrega.md` y la cadencia de sincronización en `cadencia-y-ceremonias.md`.

## Dependencias entre flujos

La coordinación de dependencias **entre flujos** es la parte más dura del programa: es donde los planes individualmente sanos fallan en conjunto. Orquesta las hace explícitas, les asigna dueño en ambos extremos y fija un punto de sincronización/integración con fecha.

| Tipo | Ejemplo | Riesgo si se ignora |
|------|---------|---------------------|
| Técnica | Flujo B necesita el contrato de API del flujo A | Bloqueo, retrabajo, integración tardía |
| De secuencia | Migración de datos antes de cortar el sistema viejo | Corte fallido, rollback |
| De recurso | Un agente-skill escaso demandado por dos flujos | Contención, colas, espera |
| De conocimiento/decisión | Decisión de arquitectura pendiente (eneida) que traba a dos flujos | Avance sobre supuestos frágiles |

Orquesta gobierna el **flujo** de la dependencia (visibilidad, punto de sincronización, escalamiento); el contenido de cada extremo pertenece a su dueño de craft. El tratamiento completo (mapa, matriz, cadencia de resolución) vive en `gestion-de-dependencias.md`.

## Coordinación a escala

Orquesta es neutral de marco: elige el patrón de coordinación según cantidad de flujos, acoplamiento e independencia de entrega. No impone un marco por defecto.

| Marco | Unidad a escala | Rol coordinador | Cuándo encaja |
|-------|-----------------|-----------------|---------------|
| SAFe | ART (Agile Release Train); PI Planning | RTE (Release Train Engineer) | Muchos flujos con cadencia común y fuerte interdependencia |
| LeSS | Requirement areas (áreas de requisito) | Coordinación ligera entre equipos, un backlog | Producto único, varios equipos, mínima ceremonia |
| Nexus | Nexus Integration Team | Integración continua entre equipos | 3–9 equipos sobre un producto, foco en integración |
| Scrum@Scale | Scrum de scrums, EAT/EMS | Redes de equipos escaladas | Escalado organizacional amplio y federado |

Orquesta puede mapear el rol de coordinación (RTE, Nexus Integration Team, etc.) a sí misma como autoridad de flujo, sin apropiarse del contenido. Comparación y selección de marco en `metodologias-y-marcos.md`; el diseño de las ceremonias correspondientes en `cadencia-y-ceremonias.md`.

## Riesgo y métricas de programa

El riesgo de programa es de nivel superior al de cada flujo: emerge de la interacción entre flujos (integración tardía, dependencia cruzada no resuelta, contención de capacidad, desalineación de fechas). Orquesta mantiene un RAID de programa que consolida y correlaciona lo que ningún flujo ve por sí solo. Detalle en `gestion-de-riesgos-raid.md`.

Las métricas de programa miden **entrega y predictibilidad del conjunto**, no la productividad de un flujo aislado.

| Métrica | Qué revela |
|---------|-----------|
| Predictibilidad del PI | ¿El programa cumple lo comprometido por incremento? |
| Dependencias abiertas vs. resueltas a tiempo | Salud de la coordinación cruzada |
| Flujo agregado (lead/cycle time, WIP) | Capacidad de entrega del programa |
| Avance de hitos de integración | Riesgo de integración tardía |

Definiciones y tableros en `flujo-y-metricas-de-entrega.md`.

## Benefits realization (realización de beneficios)

Frontera crítica: orquesta **coordina la entrega que habilita los beneficios**; el negocio y **tompo definen y miden los beneficios y su valor**.

| Aspecto | Dueño |
|---------|-------|
| Qué beneficio se persigue y su valor | tompo/negocio |
| Cómo se mide el beneficio (KPI de negocio) | tompo/negocio |
| Que la entrega que habilita el beneficio ocurra a tiempo y coordinada | **orquesta** |
| Trazabilidad entrega → capacidad habilitada | orquesta (reporta), tompo (interpreta valor) |

Orquesta conecta cada flujo del programa con la capacidad de negocio que habilita, para que la secuencia de entrega maximice la llegada temprana de valor; pero **no juzga si el beneficio se logró** ni redefine su valor: eso lo hace tompo. Ver reporte en `comunicacion-y-reporte.md`.

## Gobernanza de programa

Gobernanza **ligera**, no comité pesado: la mínima estructura que mantiene decisiones desbloqueadas y flujo visible. Orquesta facilita el foro de programa (sincronización, riesgos, dependencias, decisiones de flujo) sin convertirlo en burocracia de aprobación. Las decisiones de contenido se enrutan a su dueño (ver `orquestacion-y-ruteo.md`); orquesta gobierna cadencia, transparencia y desbloqueo. Principios y límites éticos en `gobernanza-y-etica.md`.

## Cómo cambia según el estado del programa

| Estado | Situación | Foco de orquesta |
|--------|-----------|------------------|
| Greenfield | Programa nuevo 0→1 | Definir objetivo común (de tompo), estructurar flujos, establecer PI y tablero de programa, sembrar cadencia y RAID desde cero |
| In-flight | Programa en marcha | Sostener sincronización, resolver dependencias cruzadas, proteger predictibilidad, corregir desviaciones sin refundar |
| Brownfield | Coordinar transformación/migración de varios sistemas | Mapear estado actual y acoplamientos, secuenciar cortes/integraciones, coordinar convivencia legado↔nuevo, gestionar riesgo de integración |

En **greenfield** orquesta construye la máquina de coordinación; en **in-flight** la afina y protege; en **brownfield** desenreda dependencias existentes y secuencia una migración multi-sistema hacia estados intermedios seguros.

## Modelo tiered (META)

Orquesta ejerce autoridad de **flujo**, no de contenido, en tres niveles:

- **T1 — directo**: coordinación pura de flujo (agendar sincronización, mantener el tablero, consolidar RAID, reportar). Orquesta actúa por sí misma.
- **T2 — co-facilita con el dueño**: cuando la coordinación toca contenido (valor, arquitectura, pipeline, craft), orquesta facilita y el dueño decide (tompo el valor, eneida la arquitectura, baluarte el pipeline, el especialista su craft).
- **T3 — potestad de flujo**: si el dueño está ausente o saturado, orquesta puede tomar una decisión de **flujo** para desbloquear, marcada **"pendiente de ratificación"** por el dueño. Nunca decide el contenido en sí.

## Frontera con el equipo

| Handle | Decide (contenido) | Orquesta aporta (flujo) |
|--------|--------------------|-------------------------|
| tompo | Valor de producto y su priorización; traduce el portafolio del negocio a producto; beneficios | Secuenciación de entrega que realiza ese valor |
| eneida | Arquitectura de sistema y de programa técnica | Coordinación de decisiones que bloquean flujos |
| baluarte | Pipeline, entrega técnica, confiabilidad | Sincronización de releases entre flujos |
| motor, farola, palma, uxuifull, andulfo, sysuniversal-ai, peakformance, certero, amado, destroyer, docpower | Su craft | Capacidad, cadencia, dependencias y visibilidad |

```
Checklist rápido — Gestión de programa
[ ] Objetivo de programa explícito y trazado al valor definido por tompo (no inventado por orquesta)
[ ] Portafolio/estrategia/priorización de inversión confirmados como INSUMO del negocio/sponsor (externo; tompo lo traduce a producto)
[ ] Flujos identificados con su dueño de craft y objetivo dentro del PI
[ ] Program Increment definido y tablero de programa vigente y visible
[ ] Dependencias ENTRE flujos explícitas, con dueño en ambos extremos y punto de sincronización con fecha
[ ] Marco de coordinación a escala elegido por contexto (SAFe/LeSS/Nexus/Scrum@Scale), no por defecto
[ ] RAID de programa consolidando riesgos que ningún flujo ve solo
[ ] Métricas de programa (predictibilidad, dependencias, flujo agregado, hitos de integración) en tablero
[ ] Entrega trazada a la capacidad de negocio que habilita; beneficios los mide tompo/negocio
[ ] Gobernanza ligera activa; decisiones de contenido enrutadas a su dueño
[ ] Estado (greenfield/in-flight/brownfield) reconocido y foco ajustado
[ ] Acciones de flujo bajo T3 marcadas "pendiente de ratificación"
```

## Referencias

- PMI — *The Standard for Program Management* y credencial PgMP (gestión de programas y realización de beneficios).
- Scaled Agile — *SAFe*: ART, RTE, PI Planning, program board (coordinación multi-equipo a escala).
- *LeSS* (Larman/Vodde) y *Nexus* (Scrum.org, Nexus Integration Team) — escalado con mínima ceremonia e integración continua.
- AXELOS — *Managing Successful Programmes (MSP)* — gobernanza de programa y benefits realization.

## Enlaces hermanos

`SKILL.md` · `planificacion-y-cronograma.md` · `gestion-de-dependencias.md` · `capacidad-y-asignacion.md` · `gestion-de-riesgos-raid.md` · `flujo-y-metricas-de-entrega.md` · `cadencia-y-ceremonias.md` · `orquestacion-y-ruteo.md` · `metodologias-y-marcos.md` · `comunicacion-y-reporte.md` · `gestion-de-cambios-y-alcance.md` · `incidentes-y-coordinacion-de-crisis.md` · `interoperabilidad-y-aliados.md` · `gobernanza-y-etica.md` · `plantillas.md` · `ejemplos.md` · `checklists.md`
