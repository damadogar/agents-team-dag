# DAG TEAM — Enterprise Agents

Repositorio personal de respaldo y control de versiones del **DAG TEAM**: un equipo de **22 agentes
enterprise** organizados en un núcleo de producto/entrega y **2 clusters** (Data + IA, Seguridad),
implementados como **Claude Code Skills**.

Este repo es el **origen único de verdad (single source of truth)** de cada agente. Todo lo que las
distintas herramientas (Claude Code, Cursor, Claude — perfil de trabajo, `.agents`) usan en tiempo de
ejecución se sincroniza *desde aquí* hacia sus respectivas carpetas de skills mediante *junctions* de
NTFS — nunca al revés.

---

## Estructura del repositorio

Todas las carpetas dentro de `agentes/` son **hermanas entre sí** (un único nivel, sin anidamiento):
los 22 agentes y las 2 carpetas de gobernanza de cluster están al mismo nivel. `cluster-data-ai/` y
`cluster-seguridad/` **no contienen** a sus agentes — solo aportan la gobernanza compartida del
cluster (`gobernanza-y-colaboracion-cluster.md`) más su propio `sincronizar.ps1`. La pertenencia de
cada agente a su cluster es lógica (ver tabla de agentes más abajo), no una relación de carpetas.

```
Agents Team - DAG/
├── README.md                                  (este archivo)
├── RESUMEN-DAG-TEAM.md                         Guía rápida de 1 página: qué agente invocar y cuándo
├── MANUAL-EQUIPO-ENTERPRISE-DAG-TEAM.md        Manual completo del equipo (filosofía, RACI, handoffs,
│                                                anti-patrones, cómo sacarle el máximo provecho)
├── TEAM-PROTOCOL.md                            Protocolo operativo común del equipo
├── agentes/                          ← un único nivel, sin anidamiento
│   ├── tompo/
│   ├── orquesta/
│   ├── eneida/
│   ├── uxuifull/
│   ├── farola/
│   ├── palma/
│   ├── motor/
│   ├── baluarte/
│   ├── peakformance/
│   ├── certero/
│   ├── amado/
│   ├── docpower/
│   ├── andulfo/                       (cluster Data + IA — ver tabla abajo)
│   ├── caudal/                        (cluster Data + IA)
│   ├── brujula/                       (cluster Data + IA)
│   ├── prisma/                        (cluster Data + IA)
│   ├── sysuniversal-ai/                (cluster Data + IA)
│   ├── destroyer/                     (cluster Seguridad — ver tabla abajo)
│   ├── cazador/                       (cluster Seguridad)
│   ├── centinela/                     (cluster Seguridad)
│   ├── sello/                         (cluster Seguridad)
│   ├── vector/                        (cluster Seguridad)
│   ├── cluster-data-ai/               (solo gobernanza compartida del cluster; sin SKILL.md propio)
│   └── cluster-seguridad/             (solo gobernanza compartida del cluster; sin SKILL.md propio)
└── aislado/                          ← NO es parte de los 22; NO sync global (ver aislado/README.md)
    ├── rea/                           Ingeniería inversa con evidencia (estudio aislado)
    └── protector/                     Protección anti-RE + adversarial de hallazgos
```

> **`aislado/`** es un par adversarial para estudio (ingeniería inversa ↔ protección).
> **No** se une al contador de 22 agentes, **no** usa `sincronizar.ps1` hacia skills
> globales y **no** debe co-cargarse en la misma sesión. Detalle de invocación:
> [`aislado/README.md`](aislado/README.md).

Cada carpeta de agente sigue, en general, este patrón (varía levemente por agente):

| Archivo | Contenido |
|---|---|
| `SKILL.md` | Punto de entrada de la skill: frontmatter (`name`, `description`), identidad y disciplina del agente |
| `gobernanza-y-colaboracion.md` / `gobernanza-y-etica.md` | RACI, fronteras de rol, reglas de handoff, ética de la disciplina |
| `CHANGELOG.md` | Historial de versiones del agente |
| `ejemplos.md` | Casos de uso resueltos |
| `plantillas.md` | Plantillas reutilizables (planes, informes, handoffs, etc.) |
| `checklists.md` | Checklists operativos |
| *(archivos de dominio)* | Contenido temático propio de la disciplina (p. ej. `apis-integracion.md`, `priorizacion-valor.md`) |
| `sincronizar.ps1` | Recrea los 4 junctions de la skill hacia esta carpeta maestra |

---

## Los 22 agentes

**Núcleo de producto y entrega (12)**
| Agente | Rol |
|---|---|
| `tompo` | Product Ownership — el qué y el porqué: valor, backlog, prioridad |
| `orquesta` | Delivery/Orquestación — quién/cuándo/en qué orden: coordina y desatasca |
| `eneida` | Arquitectura de software, contratos y ADRs con trade-offs |
| `uxuifull` | UX/UI integral: research, flujos, design system, accesibilidad |
| `farola` | Frontend engineering (web) |
| `palma` | Mobile engineering |
| `motor` | Backend engineering / APIs |
| `baluarte` | Plataforma, entrega y confiabilidad: CI/CD, IaC, SRE, SLOs |
| `peakformance` | Performance engineering: budgets, profiling, tuning |
| `certero` | Code review y debugging: correctitud |
| `amado` | Calidad: estrategia y ejecución de QA |
| `docpower` | Documentation engineering |

**Cluster Data + IA (5)** — cadena `andulfo → caudal → brujula → prisma → sysuniversal-ai`
| Agente | Rol |
|---|---|
| `andulfo` | Plataforma de datos / DBA / HA-DR |
| `caudal` | Data engineering: pipelines y movimiento de datos |
| `brujula` | Analytics engineering: capa semántica y métricas oficiales |
| `prisma` | Data science: modelos e insights |
| `sysuniversal-ai` | AI engineering en producción: serving, MLOps/LLMOps, RAG/agentes |

**Cluster Seguridad (5)** — cadena `destroyer → cazador → centinela → sello` (+ `vector` en IA)
| Agente | Rol |
|---|---|
| `destroyer` | Núcleo del cluster: arquitectura segura, DevSecOps, criptografía |
| `cazador` | Ofensiva autorizada: pentest/red team (requiere RoE firmado) |
| `centinela` | Defensiva: detección, hardening, DFIR/IR |
| `sello` | GRC, ISO, privacidad, auditoría, riesgo |
| `vector` | Seguridad de IA/LLM/agentes (MLSecOps) |

Guía rápida de invocación y las "5 reglas de oro" del equipo: ver [`RESUMEN-DAG-TEAM.md`](RESUMEN-DAG-TEAM.md).
Manual completo (filosofía, RACI de entrega, protocolo de handoff, anti-patrones): ver
[`MANUAL-EQUIPO-ENTERPRISE-DAG-TEAM.md`](MANUAL-EQUIPO-ENTERPRISE-DAG-TEAM.md).

---

## Arquitectura de sincronización

Cada agente vive en **un único lugar físico** (esta carpeta, `agentes/<nombre>/`) y se expone a 4
herramientas mediante *junctions* de directorio de NTFS (no symlinks, no copias):

```
agentes/<nombre>/  (maestro, versionado en este repo)
        │
        ├──J──► %USERPROFILE%\.claude\skills\<nombre>          (Claude Code)
        ├──J──► %USERPROFILE%\.cursor\skills\<nombre>          (Cursor)
        ├──J──► %USERPROFILE%\.claude-trabajo\skills\<nombre>  (perfil de trabajo)
        └──J──► %USERPROFILE%\.agents\skills\<nombre>          (integración .agents)
```

La sincronización es **unidireccional**: el maestro alimenta a las 4 herramientas, nunca al revés.
Cada `sincronizar.ps1` recrea sus 4 junctions apuntando siempre a esta carpeta maestra.

### Cómo re-sincronizar (en esta máquina)

```powershell
powershell -ExecutionPolicy Bypass -File "C:\DAG\Agents Team - DAG\agentes\<nombre>\sincronizar.ps1"
```

O para los 24 de una vez:

```powershell
Get-ChildItem "C:\DAG\Agents Team - DAG\agentes" -Directory | ForEach-Object {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $_.FullName "sincronizar.ps1")
}
```

> Los scripts tienen la ruta maestra **hardcodeada** a `C:\DAG\Agents Team - DAG\agentes\<nombre>`.
> Si este repo se clona en otra ruta o en otra máquina, hay que ajustar `$master` en cada
> `sincronizar.ps1` (o clonar exactamente en esa misma ruta) antes de ejecutar la sincronización. No
> requiere permisos de administrador (usa junctions de directorio, no symlinks).

---

## Estado de este repositorio

Esta primera subida corresponde al **estado íntegro del equipo a la fecha**, sin modificaciones: los
22 agentes + 2 clusters ya reorganizados en una única carpeta maestra (`agentes/`) y con sus
`sincronizar.ps1` actualizados a la ruta actual. Sirve como punto de referencia y de reversión antes
de iniciar cualquier cambio futuro (p. ej., la introducción de un `TEAM-PROTOCOL.md` consolidado que
los 22 agentes referencien).

---

## Uso

Este es un repositorio **personal**, no un producto de código abierto. No incluye licencia de
distribución pública.
