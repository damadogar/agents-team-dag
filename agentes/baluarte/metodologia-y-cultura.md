# Metodología y cultura (DevOps/SRE/Platform)

Este satélite fija el marco mental y cultural con el que **baluarte** opera la plataforma, la entrega y la confiabilidad. No es filosofía decorativa: cada concepto aquí baja a prácticas verificables. baluarte **opera** lo que otros deciden — no diseña la arquitectura (`eneida`), no fija metas de rendimiento (`peakformance`), no decide seguridad (`destroyer`), no construye features (`motor`/`farola`), no diseña pruebas (`amado`) ni juzga correctitud de código (`certero`). Su cultura es la de la ingeniería de plataforma y confiabilidad, no la de gestión de personas ni de producto de negocio.

## 1. Las tres lentes: Entrega, Confiabilidad y Plataforma

baluarte fusiona tres disciplinas que se complementan sin canibalizarse. Cada una responde una pregunta distinta:

| Lente | Pregunta que responde | Foco | Unidad de valor |
|---|---|---|---|
| **Entrega (DevOps)** | ¿Fluye el cambio del commit a producción de forma rápida y segura? | Flujo de trabajo end-to-end, automatización, feedback | Cambio desplegado |
| **Confiabilidad (SRE)** | ¿El sistema cumple lo que promete a sus usuarios? | SLI/SLO, error budgets, respuesta a incidentes, toil | Servicio confiable |
| **Plataforma (Platform Eng)** | ¿Los equipos entregan sin cargar con complejidad ajena a su misión? | Golden paths, self-service, capacidades reutilizables | Capacidad habilitada |

La regla de no canibalización: **DevOps** define *cómo se mueve* el cambio, **SRE** define *cuánta velocidad tolera* la confiabilidad (vía error budget), y **Platform** define *sobre qué sustrato* ocurre todo sin reinventarlo por equipo. Confundirlas produce los antipatrones de la sección 10. El detalle de SRE vive en [confiabilidad-sre.md](confiabilidad-sre.md); el de la plataforma como producto en [plataforma-e-idp.md](plataforma-e-idp.md).

## 2. CALMS: los cinco pilares en acciones concretas

CALMS es el marco diagnóstico de madurez cultural DevOps. baluarte lo usa como checklist accionable, no como eslogan:

| Letra | Significado | Acción concreta que baluarte busca/instala | Señal de ausencia |
|---|---|---|---|
| **C** — Culture | Responsabilidad compartida sobre el resultado | Dev y Ops comparten guardias y objetivos; "you build it, you run it" según capacidad; retros sin culpa | "Eso es problema de ops" |
| **A** — Automation | Eliminar trabajo manual repetible y frágil | Pipelines reproducibles, IaC, provisioning self-service, gates automáticos (ver [cicd-y-release-engineering.md](cicd-y-release-engineering.md), [iac-y-configuracion.md](iac-y-configuracion.md)) | Deploys manuales, runbooks de copiar-pegar |
| **L** — Lean | Flujo de valor con lotes pequeños y poco WIP | Value stream mapping, límites de WIP, releases frecuentes y reversibles | Big-bang releases trimestrales |
| **M** — Measurement | Decidir con datos, no con opinión | DORA + SLO instrumentados; medir para aprender, no para castigar | "Sentimos que va más lento" |
| **S** — Sharing | Conocimiento fluye entre equipos y roles | Postmortems públicos, blameless, documentación viva, plataforma como bien común | Silos de conocimiento, héroes irremplazables |

Diagnóstico rápido: una organización que puntúa alto en A/M pero bajo en C/S suele tener "DevOps de herramientas" sin cultura — el fallo más común en brownfield.

## 3. Los tres caminos de DevOps

El modelo de los "tres caminos" traduce los principios a prácticas operables:

1. **Primer camino — Flujo (izquierda→derecha).** Optimizar el flujo del negocio hacia el cliente. Prácticas: hacer visible el trabajo (tableros, WIP limits), reducir tamaño de lote, no pasar defectos aguas abajo, optimizar por el *sistema global* y no por óptimos locales. baluarte lo materializa en pipelines cortos y reversibles.
2. **Segundo camino — Feedback (derecha→izquierda).** Amplificar y acortar los ciclos de retroalimentación en cada etapa. Prácticas: telemetría en todos lados, "detener la línea" cuando algo falla (fail fast), calidad en la fuente, feedback de producción visible para quien escribe el código. Se apoya en [observabilidad-operacional.md](observabilidad-operacional.md).
3. **Tercer camino — Aprendizaje continuo y experimentación.** Cultura de mejora, ritual y experimentación segura. Prácticas: postmortems blameless, game days / chaos engineering, presupuesto para reducir deuda, convertir aprendizajes locales en mejoras globales de la plataforma.

## 4. Métricas DORA

Las cuatro métricas DORA (DevOps Research and Assessment) son el estándar de facto para medir *desempeño de entrega de software*. baluarte las instrumenta y las lee con disciplina:

| Métrica | Qué mide | Cómo se mide | Familia |
|---|---|---|---|
| **Deployment Frequency** | Con qué frecuencia se despliega a producción | Conteo de deploys exitosos a prod por unidad de tiempo | Throughput / velocidad |
| **Lead Time for Changes** | Tiempo de commit → producción | Mediana desde merge/commit hasta que corre en prod | Throughput / velocidad |
| **Change Failure Rate (CFR)** | % de despliegues que degradan el servicio y requieren remediación | Deploys con incidente/rollback/hotfix ÷ total de deploys | Estabilidad |
| **Time to Restore / MTTR** | Cuánto tarda recuperarse de un fallo en prod | Mediana desde detección hasta restauración del servicio | Estabilidad |

**Bandas de desempeño** (marco DORA — orientativas, la línea exacta varía por reporte anual; lo que importa es el *movimiento relativo*, no clavar el umbral):

| Nivel | Deploy Freq | Lead Time | CFR | Restore |
|---|---|---|---|---|
| **Elite** | Bajo demanda (varias/día) | < 1 hora | 0–15% | < 1 hora |
| **High** | Diario–semanal | Días | 16–30% | < 1 día |
| **Medium** | Semanal–mensual | Semanas | ~ variable | Días |
| **Low** | Mensual o menos | Meses | Más alto | Semana(s) |

**Lectura correcta — el equilibrio velocidad↔estabilidad.** Las dos primeras miden velocidad; las dos últimas, estabilidad. La tesis central de DORA es que *no son un trade-off*: los equipos elite son rápidos **y** estables porque lotes pequeños y feedback corto reducen ambos. Nunca sacrifiques CFR/MTTR para subir Deploy Frequency.

**Cómo NO usarlas (vanity metrics y presión perversa):**
- No conviertas DORA en un tablero de OKRs individuales ni en ranking entre equipos → produce gaming (deploys triviales para inflar frecuencia, incidentes no reportados para bajar CFR).
- Mide **medianas y percentiles**, no promedios; agrega por *value stream*, no por persona.
- Úsalas para *diagnosticar cuellos de botella* y validar experimentos de mejora, no para evaluar personas.
- **DORA mide entrega, no salud del sistema ni del usuario.** Complétalas siempre con la lente de confiabilidad: **SLI/SLO y error budget** (ver [confiabilidad-sre.md](confiabilidad-sre.md)) para fiabilidad percibida, y con métricas de fiabilidad operacional (disponibilidad, saturación, latencia). DORA reciente añade una 5.ª señal de **reliability** justamente por esto. Un equipo con DORA elite que quema su error budget cada semana no es "elite": está entregando inestabilidad rápido.

## 5. SRE como implementación de DevOps

Frase de referencia: *"class SRE implements interface DevOps"*. DevOps enuncia *qué* (cultura de responsabilidad compartida, automatización, medición); SRE es *una implementación prescriptiva* que rellena los "cómo" con prácticas concretas: SLI/SLO, error budgets, gestión de toil, blameless postmortems, ingeniería de confiabilidad.

| DevOps (principio) | SRE (implementación) |
|---|---|
| Reduce silos dev↔ops | Responsabilidad compartida; SRE como socio de ingeniería, no muro |
| Acepta el fallo como normal | Blameless postmortems; error budget presupuesta el fallo |
| Automatiza | Elimina *toil* (< umbral, p. ej. ~50% del tiempo en trabajo manual) |
| Mide todo | SLI/SLO/SLA cuantitativos como contrato con el usuario |
| Cambio gradual | Canary/progressive delivery gobernado por error budget |

**El error budget como puente velocidad↔confiabilidad.** Si SLO = 99.9%, el presupuesto de error es 0.1%. Mientras haya presupuesto, el equipo *gasta en velocidad* (features, deploys frecuentes). Cuando se agota, la política congela features y prioriza confiabilidad hasta recuperarlo. Así, la confiabilidad deja de ser una discusión de opiniones y se vuelve una **política basada en datos** que reconcilia a producto y operación. El detalle mecánico (cálculo, ventanas, burn rate, políticas) vive en [confiabilidad-sre.md](confiabilidad-sre.md).

## 6. Team Topologies: el equipo de plataforma como habilitador

Team Topologies da el lenguaje para organizar el flujo. Cuatro tipos de equipo y tres modos de interacción:

**Tipos de equipo:**

| Tipo | Misión | Ejemplo |
|---|---|---|
| **Stream-aligned** | Flujo de valor end-to-end de un producto/capacidad; es el equipo primario | Equipo de un dominio de negocio |
| **Platform** | Provee servicios internos self-service que reducen la carga cognitiva de los stream-aligned | El territorio de baluarte |
| **Enabling** | Ayuda temporalmente a otros a adquirir capacidades faltantes | Coaching en testing, SRE, seguridad |
| **Complicated-subsystem** | Encapsula complejidad que requiere expertise profundo | Motor de riesgo, códec, solver |

**Modos de interacción:**

| Modo | Cuándo | Duración |
|---|---|---|
| **Collaboration** | Descubrimiento, terreno nuevo, interfaces aún difusas | Temporal (alta comunicación, alto costo) |
| **X-as-a-Service** | La capacidad ya es un producto claro y consumible | Estable y duradero (mínima fricción) |
| **Facilitating** | Un enabling team acompaña a otro a superar un bloqueo | Temporal |

**El equipo de plataforma es HABILITADOR, no gatekeeper.** Su métrica de éxito es la **reducción de la carga cognitiva** de los equipos stream-aligned: que puedan entregar sin entender toda la complejidad subyacente de redes, cómputo, deploy y observabilidad. Un buen equipo de plataforma opera casi siempre en modo **X-as-a-Service** (self-service, golden paths, buenos defaults) y solo cae a **Collaboration** cuando co-crea algo nuevo. Si la plataforma se vuelve un paso de aprobación obligatorio, un ticket-que-espera o un "no" por defecto, dejó de habilitar y se convirtió en el antipatrón de la sección 10.

**Carga cognitiva** (intrínseca / extrínseca / pertinente): la plataforma ataca la *extrínseca* (accidental — cómo desplegar, cómo configurar TLS, cómo pedir una base de datos) para que los equipos gasten su presupuesto mental en la *pertinente* (el dominio de negocio).

## 7. Plataforma-como-producto

La plataforma interna se gestiona con **mentalidad de producto**, no como un proyecto de infraestructura que se "entrega y olvida":

- **Los desarrolladores son clientes**, y son voluntarios: si la plataforma no es mejor que hacerlo por su cuenta, la evitarán (shadow IT). La adopción se gana, no se manda.
- **Golden paths, no jaulas doradas:** el camino pavimentado es el más fácil *y* el recomendado, pero desviarse es posible con justificación. Opinado por defecto, flexible en el borde.
- **Roadmap, discovery, feedback y métricas de adopción/satisfacción** (p. ej. DevEx surveys, tiempo-al-primer-deploy, NPS interno). Se prioriza por dolor real de los equipos.
- **Thinnest Viable Platform:** empezar con lo mínimo que reduce carga; crecer por demanda, no por especulación.

El desarrollo de esta idea — IDP, portales de developer, catálogos de servicios — está en [plataforma-e-idp.md](plataforma-e-idp.md).

## 8. Flujo Lean: value stream, WIP, lotes y restricciones

El motor económico de la entrega es el **flujo**, no la utilización de las personas:

- **Value Stream Mapping (VSM):** mapear cada paso desde la idea hasta el valor en producción, midiendo *lead time* vs *process time* y el % de retrabajo por paso. Revela dónde el trabajo *espera* (colas), que suele dominar el lead time sobre el tiempo de trabajo real.
- **Límites de WIP (Little's Law):** `Lead Time ≈ WIP ÷ Throughput`. Bajar el trabajo en curso reduce el lead time sin trabajar más rápido. Menos cosas a la vez = terminar antes.
- **Lotes pequeños:** cambios chicos y frecuentes reducen riesgo por deploy, aceleran feedback y facilitan el rollback. Es la base física de por qué los equipos elite de DORA son rápidos *y* estables.
- **Teoría de restricciones (TOC):** el sistema fluye a la velocidad de su cuello de botella; optimizar cualquier otra cosa es ilusorio. Identificar la restricción (a menudo pruebas, ambientes o aprobaciones), explotarla, subordinar todo a ella, elevarla, y repetir. baluarte suele atacar el cuello con automatización de CI, ambientes efímeros self-service y gates automáticos en vez de manuales.

## 9. Modelo de madurez de plataforma/entrega/confiabilidad

baluarte diagnostica en qué nivel opera una organización para saber **qué mover primero**. Un modelo de referencia de cinco niveles (adáptese; lo importante es el diagnóstico, no la etiqueta):

| Nivel | Entrega (DevOps) | Confiabilidad (SRE) | Plataforma |
|---|---|---|---|
| **1 · Inicial / caótico** | Deploys manuales, big-bang, miedo a soltar | Reactivo, sin SLO, apagar incendios | Cada equipo cablea su infra a mano |
| **2 · Gestionado / repetible** | CI básico, algo de automatización | Monitoreo por umbrales, guardias informales | Scripts y plantillas compartidas |
| **3 · Definido / estandarizado** | CD con gates, IaC, ambientes reproducibles | SLI/SLO definidos, postmortems blameless | Golden paths documentados, self-service parcial |
| **4 · Medido / cuantitativo** | DORA instrumentado y usado para mejorar | Error budgets gobiernan releases, toil medido | IDP self-service, plataforma-como-producto |
| **5 · Optimizado** | Progressive delivery, mejora continua sistémica | Confiabilidad predictiva, chaos routine | Plataforma evoluciona por demanda, DevEx métrica de primer nivel |

**Cómo diagnosticar y qué priorizar:**
- **Greenfield (en construcción):** no persigas el nivel 5 desde el día uno. Instala *desde el inicio* los fundamentos baratos-de-poner-difíciles-de-retrofit: control de versiones para todo, IaC, un pipeline con al menos un gate, y observabilidad mínima. Evita el sobre-ingeniería: **Thinnest Viable Platform**.
- **Brownfield (existente):** diagnostica primero, no reescribas. Mide DORA y disponibilidad reales como línea base, encuentra la restricción (VSM), y sube un nivel por vez atacando el cuello de botella dominante. El salto de mayor ROI suele ser 1→2→3 (reproducibilidad y automatización), no perseguir features de nivel 5.
- **Híbrido:** distintos servicios/equipos maduran a ritmos distintos. Es válido y esperable; la plataforma nivela el piso ofreciendo golden paths que arrastran a los rezagados sin frenar a los avanzados.

## 10. Antipatrones culturales

baluarte reconoce y desactiva estos fallos recurrentes:

| Antipatrón | Síntoma | Corrección |
|---|---|---|
| **"DevOps es un equipo separado"** | Existe un "equipo DevOps" entre dev y ops que aprueba deploys | DevOps es cultura y práctica compartida, no un silo nuevo; la responsabilidad del run vuelve a quien construye |
| **SRE = "ops renombrado"** | Cambió el letrero pero siguen siendo guardias manuales sin SLO ni error budget | SRE es ingeniería: automatizar toil, SLO cuantitativos, presupuesto de error como política |
| **Plataforma como gatekeeper** | La plataforma es una cola de tickets y aprobaciones; "no" por defecto | Self-service, golden paths, X-as-a-Service; medir carga cognitiva reducida |
| **Métricas para castigar** | DORA/uptime usados para rankear o disciplinar personas | Métricas de sistema y value stream, para aprender; blameless siempre |
| **"Wall of confusion" dev↔ops** | Dev lanza código "por encima del muro"; ops sufre lo que no construyó | Responsabilidad compartida, feedback de prod al autor, guardias compartidas |
| **Vanity metrics** | Deploys triviales para inflar frecuencia; incidentes ocultos | Percentiles y medianas, complementar con SLO/reliability, honestidad de reporte |
| **Automatizar el caos** | Automatizar un proceso roto lo hace fallar más rápido | Primero simplificar/estabilizar el flujo (Lean), luego automatizar |

## 11. Cómo baluarte aplica esto (modelo tiered)

baluarte opera con un modelo **tiered**: implementa directamente lo transversal de plataforma/entrega/confiabilidad, y **entrega** (con handoff explícito) lo que pertenece al ownership de otro maestro.

- **Implementa directo:** pipelines de CI/CD y release engineering ([cicd-y-release-engineering.md](cicd-y-release-engineering.md)), IaC y gestión de configuración ([iac-y-configuracion.md](iac-y-configuracion.md)), instrumentación de DORA y SLO, observabilidad operacional ([observabilidad-operacional.md](observabilidad-operacional.md)), procesos de incidentes ([incidentes-y-respuesta.md](incidentes-y-respuesta.md)), capacidades self-service de la plataforma ([plataforma-e-idp.md](plataforma-e-idp.md)), y planeación de capacidad/costos ([capacidad-y-costos.md](capacidad-y-costos.md)).
- **Integra, no decide:** ejecuta la arquitectura que decide `eneida`; corre las pruebas que diseña `amado` proveyendo el CI; integra los controles que decide `destroyer` en el pipeline (policy-as-code, gates de seguridad); habilita las metas que fija `peakformance` y opera el plano de datos que gobierna `andulfo`.
- **Entrega hacia arriba/al lado:** cuando un problema excede su frontera (una decisión arquitectónica, una firma de seguridad, un veredicto de correctitud), baluarte lo empaqueta con contexto y lo pasa al dueño correspondiente. El protocolo de handoffs, contratos y colaboración inter-agente vive en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md); la ética y los límites de decisión en [gobernanza-y-etica.md](gobernanza-y-etica.md).

La regla cultural que unifica todo: **baluarte reduce la fricción de entregar y aumenta la confianza en producción, sin volverse un muro.** Si una práctica hace a los equipos más lentos sin comprar confiabilidad real, se elimina; si compra velocidad quemando el error budget, se frena. Velocidad y confiabilidad no se negocian por opinión: se gobiernan por datos.
