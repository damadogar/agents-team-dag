# Platform Engineering y plataforma interna de desarrollo (IDP)

Este satélite define cómo baluarte concibe, construye, opera y gobierna la **plataforma interna de desarrollo** como el corazón de su disciplina de Platform Engineering. Aquí vive el *paved road*: el conjunto de caminos pavimentados que permite a los equipos de producto entregar software rápido, seguro y confiable sin reinventar la infraestructura en cada iniciativa. La ejecución de esos caminos (pipelines, IaC, contenedores, observabilidad) se detalla en los satélites hermanos; este documento fija la **estrategia, el producto y los contratos** de la plataforma.

## 1. Qué es Platform Engineering y por qué surgió

Platform Engineering es la disciplina de **diseñar y operar plataformas internas como producto** para reducir la fricción entre la intención de un equipo de producto y su ejecución en entornos reales. Surgió como respuesta a un fallo de escala del DevOps ingenuo: cuando se pide que "cada equipo sea dueño de todo su ciclo de vida" (build, deploy, infra, seguridad, observabilidad), cada equipo termina reinventando lo mismo, con calidad dispar y una **carga cognitiva** insostenible.

| Etapa | Problema | Respuesta de la plataforma |
|-------|----------|----------------------------|
| Ops centralizado | Cuello de botella: todo pasa por tickets | Silos y lead time alto |
| DevOps "todos hacen todo" | Cada equipo reinventa CI, IaC, secretos, monitoreo | Duplicación, deriva, inseguridad |
| Platform Engineering | Un equipo dedicado ofrece capacidades **self-service** reutilizables | Paved road: velocidad + consistencia |

La motivación central es **reducir carga cognitiva extrínseca** para que los equipos gasten su capacidad mental en el dominio del negocio, no en fontanería. El marco organizacional que sustenta esto (equipos *stream-aligned*, *platform teams* como equipo de habilitación, modos de interacción X-as-a-Service) se desarrolla en [metodologia-y-cultura.md](metodologia-y-cultura.md) bajo Team Topologies.

baluarte no reemplaza a los equipos de producto: `motor` y `farola` siguen siendo dueños de sus features. La plataforma **los habilita**; no construye la lógica de negocio por ellos, les entrega el camino sobre el cual construirla.

## 2. La plataforma como PRODUCTO

El error más común y más caro es tratar la plataforma como un proyecto de infraestructura. **Una plataforma es un producto**, y sus usuarios son internos: los developers.

- **Usuarios internos.** Los clientes de la plataforma son los ingenieros de `motor`, `farola` y demás equipos de entrega. Sus necesidades se investigan como las de cualquier cliente: entrevistas, telemetría de uso, tickets, *shadowing*.
- **Product management de plataforma.** Hay un rol de PM (o *product owner* de plataforma) que prioriza un **roadmap** con base en dolor real, no en la tecnología más novedosa. Sin PM, la plataforma se convierte en un vertedero de herramientas sin coherencia.
- **Adopción voluntaria vs mandato.** La regla de oro: **el paved road gana por ser el más fácil, no por ser obligatorio.** Si la vía pavimentada es la de menor esfuerzo para lograr algo bien hecho, la adopción es natural. El mandato sin experiencia de usuario genera *shadow platforms* y resentimiento.
- **Métrica de valor = adopción + satisfacción**, no cantidad de features publicadas.

> baluarte trata cada capacidad de la plataforma como una hipótesis de producto: se lanza mínima, se mide su uso y su NPS interno, y se itera o se retira.

## 3. IDP: la plataforma interna de desarrollo

Una **Internal Developer Platform (IDP)** es la superficie integrada — no un conjunto disperso de herramientas — mediante la cual los equipos consumen las capacidades de la plataforma en régimen de autoservicio.

La diferencia entre una IDP y "un montón de herramientas" es la **integración y la abstracción coherente**: un catálogo, plantillas, un plano de orquestación y contratos estables que ocultan la complejidad subyacente. Diez herramientas potentes sin pegamento no son una IDP; son diez fuentes de carga cognitiva.

Capas típicas de una IDP (neutral respecto de proveedor):

| Capa | Rol | Ejemplos de mecanismo (p. ej.) |
|------|-----|-------------------------------|
| **Portal / interfaz** | Punto de entrada del developer | Portal de developer, CLI interna, extensión de IDE |
| **Catálogo de servicios y software templates** | Descubrir y crear | Catálogo de software (p. ej. Backstage-style, portales propios), *scaffolders* |
| **Orquestación (control plane)** | Traducir intención declarada en recursos reales | Orquestadores declarativos, operadores, controladores GitOps |
| **Plantillas y golden paths** | Casos comunes pre-resueltos | Motores de plantillas, generadores de repos, blueprints |
| **Aprovisionamiento** | Crear infra/entornos bajo demanda | IaC parametrizado, *environments-as-a-service* |
| **Plano de datos operacional** | Estado, secretos, observabilidad conectada | Ver [observabilidad-operacional.md](observabilidad-operacional.md), [seguridad-de-plataforma.md](seguridad-de-plataforma.md) |

El detalle de cómo cada capa se materializa vive en [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md) (plano de orquestación de cargas), [iac-y-configuracion.md](iac-y-configuracion.md) (aprovisionamiento) y [cicd-y-release-engineering.md](cicd-y-release-engineering.md) (entrega).

## 4. Golden paths / paved roads

Un **golden path** es un camino opinado, documentado y soportado para un caso de uso común, que lleva al developer del "quiero hacer X" al "X está corriendo en producción, observado y seguro" con el mínimo de decisiones.

Principios:
- **Opinado pero no carcelario.** Toma decisiones por el usuario en lo que no aporta valor diferencial (estructura de repo, formato de logs, política de despliegue) y le deja libertad donde sí importa (la lógica de dominio).
- **Escape hatches.** Todo golden path cubre el 80% común y **provee salidas explícitas** para el 20% no cubierto. Un camino sin escape hatch se convierte en una jaula que los equipos rodean por fuera.
- **Cubre el ciclo completo**: crear → construir → probar → desplegar → observar → operar.

Ejemplo de golden path *end-to-end* "crear un servicio":

1. El developer elige la plantilla "servicio HTTP" en el catálogo y responde 3 preguntas (nombre, equipo dueño, tipo de datos).
2. La plataforma **genera** el repositorio con: estructura estándar, pipeline de CI pre-cableado, Dockerfile base, manifiestos de despliegue, healthchecks y dashboards por defecto.
3. Registra el servicio en el **catálogo** con su dueño, dependencias y enlaces de operación.
4. Aprovisiona un **entorno** de desarrollo/preview automáticamente.
5. El primer `push` dispara CI, corre las pruebas (la suite, los *frameworks* y la cobertura los **diseña** `amado`; baluarte **provee el CI y las ejecuta**), construye imagen firmada y despliega a un entorno efímero.
6. El servicio nace ya conectado a logs, métricas y trazas, con **políticas de seguridad y coste aplicadas por defecto** (§8).

Resultado: minutos hasta un servicio funcional y observable, sin abrir un solo ticket. La plataforma **operacionaliza** la decisión arquitectónica de `eneida` (p. ej. "estilo hexagonal, comunicación por eventos") empaquetándola en la plantilla; no inventa la arquitectura, la vuelve el camino por defecto.

## 5. Self-service

El autoservicio es el mecanismo por el cual la plataforma escala sin escalar su propio equipo linealmente. Objetivo: **eliminar el ticket como interfaz.**

| Necesidad del developer | Antes (ticket) | Con self-service |
|-------------------------|----------------|------------------|
| Aprovisionar un entorno | Solicitud a Ops, días de espera | Un comando/clic, minutos |
| Crear un servicio nuevo | Copiar-pegar de otro repo | Software template del catálogo |
| Desplegar a un entorno | Ventana coordinada manual | Pipeline self-service, sin gate humano innecesario |
| Rotar un secreto / abrir un acceso | Correo a seguridad | Flujo aprobado embebido en el paved road |

El **portal/catálogo de servicios** y las **software templates** son el frente visible: el developer describe *qué* quiere de forma declarativa y la plataforma resuelve el *cómo*. baluarte cuida que el self-service tenga **barandales** (los límites, cuotas y políticas se aplican solos), de modo que "sin ticket" no signifique "sin gobierno".

## 6. Developer Experience (DevEx)

DevEx es la calidad percibida y objetiva de la experiencia de construir, probar, entregar y operar software en la organización. Es el **indicador rector** de si la plataforma cumple su misión.

Cómo se mide (combinar señales cuantitativas y percibidas):

| Dimensión | Señales / métricas |
|-----------|--------------------|
| **Velocidad de arranque** | Tiempo a primer commit productivo (onboarding), tiempo al primer deploy |
| **Flujo de entrega** | DORA por equipo: lead time, frecuencia de despliegue, tasa de fallo de cambios, tiempo de restauración |
| **Percepción** | Encuestas periódicas de DevEx, NPS interno de la plataforma |
| **Fricción** | Tiempo en esperas (builds, aprobaciones), tasa de reintentos, abandono de flujos |

Frameworks útiles: **SPACE** (Satisfaction, Performance, Activity, Communication, Efficiency) aplicado para no reducir DevEx a una sola cifra, y los modelos de *developer productivity* centrados en fricción y *flow state*. **Señales de fricción** que baluarte vigila: builds lentos, entornos frágiles, documentación desactualizada, pasos manuales repetitivos, esperas por aprobaciones, y "abstracciones que gotean" (§10).

DORA como métrica de flujo se cruza con [cicd-y-release-engineering.md](cicd-y-release-engineering.md); DevEx como cultura se cruza con [metodologia-y-cultura.md](metodologia-y-cultura.md).

## 7. Carga cognitiva y Thinnest Viable Platform

La plataforma existe para redistribuir carga cognitiva. Tres tipos:

- **Intrínseca**: la complejidad esencial del dominio del problema (irreducible; es donde el equipo debe pensar).
- **Extrínseca**: la impuesta por *cómo* hay que hacer las cosas — fontanería, herramientas, configuración. **Es la que la plataforma debe absorber.**
- **Pertinente** (germane): el esfuerzo de aprender y relacionar conceptos valiosos del dominio.

El paved road **baja la carga extrínseca** para liberar capacidad hacia la intrínseca y pertinente.

**Thinnest Viable Platform (TVP):** empezar con lo mínimo que resuelve un dolor real y ampliar por demanda. No *boil the ocean*. Una TVP puede ser tan simple como una wiki con caminos recomendados y un par de plantillas; crece hacia un IDP completo solo cuando el uso lo justifica. baluarte prefiere entregar valor temprano y estrecho antes que una plataforma monumental que nadie pidió (véase antipatrón "campo de sueños", §11).

## 8. Diseño de la plataforma: APIs, contratos y compatibilidad

Como todo producto con consumidores, la plataforma expone **contratos** y debe honrarlos.

- **APIs y contratos internos.** Las capacidades se ofrecen tras interfaces estables (API declarativa, esquema de plantilla, contrato del catálogo). Los equipos programan contra el contrato, no contra la implementación.
- **Versionado de la plataforma.** Las plantillas, las APIs de aprovisionamiento y los golden paths se versionan. Un cambio no puede romper a los equipos consumidores de un día para otro.
- **Compatibilidad y deprecación gradual.** Cambios *breaking* siguen un ciclo: anuncio → periodo de convivencia (viejo y nuevo) → herramientas de migración → *sunset* con fecha clara. La plataforma **nunca rompe a sus usuarios por sorpresa**; eso destruye la confianza de la que depende la adopción voluntaria.
- **Golden path como contrato vivo.** Cuando `eneida` cambia un estándar arquitectónico, baluarte lo propaga como nueva versión del path y acompaña la migración, no lo impone abruptamente.

## 9. Gobernanza embebida (secure & compliant by default)

La mejor gobernanza es la que el developer **no tiene que recordar** porque ya viene puesta en el camino.

En lugar de *gates* manuales al final (revisiones, aprobaciones, checklists humanos), baluarte incrusta seguridad, compliance y control de coste **por defecto** en el paved road:

- **Policy-as-code**: reglas de seguridad, red, etiquetado y coste evaluadas automáticamente en el pipeline y en el aprovisionamiento.
- **Plantillas seguras**: los servicios nacen con configuración endurecida, secretos gestionados, permisos mínimos y observabilidad activa.
- **Coste por defecto**: cuotas, *tagging* y presupuestos aplicados desde la plantilla, para que el gobierno financiero sea inherente, no una auditoría posterior.

Frontera importante: **`destroyer` decide la seguridad**; baluarte la **integra** como paved road seguro por defecto. La plataforma no inventa la política de seguridad, la vuelve el default ejecutable. El detalle vive en [seguridad-de-plataforma.md](seguridad-de-plataforma.md) y el marco de reglas y ética en [gobernanza-y-etica.md](gobernanza-y-etica.md).

## 10. Métricas de éxito de la plataforma

Lo que se mide define lo que la plataforma optimiza. baluarte mide **valor entregado a los equipos**, nunca actividad interna.

| Sí se mide | No se mide (vanidad) |
|------------|----------------------|
| **Adopción** (% de equipos/servicios en el paved road) | Número de herramientas integradas |
| **Satisfacción** (DevEx, NPS interno) | Líneas de YAML o de IaC producidas |
| **Reducción de lead time** de los equipos | Cantidad de features de plataforma |
| **Reducción de toil** de los equipos de producto | Tamaño del equipo de plataforma |
| DORA agregado y por equipo | "Uptime" de la plataforma sin correlación con valor |

La consigna: **la plataforma triunfa cuando los equipos entregan mejor, no cuando la plataforma hace más cosas.**

## 11. Construir vs comprar vs ensamblar — y antipatrones

**Decisión build/buy/assemble.** Rara vez conviene construir todo desde cero. La estrategia madura es **ensamblar**: comprar/adoptar componentes probados (catálogo, orquestador, motor de plantillas, secretos) e integrarlos con el pegamento propio que codifica los golden paths de la organización.

| Enfoque | Cuándo | Riesgo |
|---------|--------|--------|
| **Comprar** | Capacidad genérica y madura en el mercado | Menor control, posible lock-in |
| **Ensamblar** | Caso general: integrar piezas + pegamento propio | Requiere equipo que mantenga la integración |
| **Construir** | Capacidad diferencial que no existe fuera | Alto coste sostenido |

**Riesgo clave: "el IDP casero que se vuelve un producto sin equipo".** Un ensamblado interno *es* un producto y necesita PM, roadmap, soporte y mantenimiento. Sin un equipo dueño, se vuelve legacy frágil que nadie puede evolucionar ni retirar.

**Antipatrones que baluarte evita:**

- **Plataforma como *gatekeeper* / torre de control.** Volver a ser el cuello de botella por tickets, ahora disfrazado de plataforma. El paved road debe habilitar, no bloquear.
- **"Campo de sueños"** (*build it and they will come*). Construir sin usuarios ni dolor validado. Sin demanda real, no hay adopción.
- **Obligar sin DevEx.** Mandato de uso sobre un camino incómodo: produce evasión, *shadow IT* y resentimiento.
- **Plataforma sin PM.** Sin product management, se acumulan herramientas incoherentes sin priorización.
- **Abstracción que gotea y frustra.** Ocultar complejidad hasta que falla y expone las tripas sin darle al developer control ni contexto para resolver.
- **Golden path rígido sin escape hatch.** Un único camino inflexible que no admite los casos legítimos fuera del molde; los equipos lo rodean y la plataforma pierde relevancia.

## 12. Cómo baluarte actúa aquí (modelo tiered)

- **Tier 1 (dueño directo — baluarte ejecuta).** La plataforma/IDP, el portal/catálogo, las software templates, el plano de orquestación y los **golden paths** son responsabilidad directa de baluarte: los diseña, construye, versiona, opera y evoluciona como producto. También el marco de métricas de plataforma y la gobernanza embebida por defecto.
- **Contenido de dominio (se entrega / se co-implementa).** La lógica de negocio, las features y los servicios concretos de cada equipo **no** son de baluarte. `motor` y `farola` los construyen sobre el paved road; baluarte los **habilita y co-implementa** la integración con la plataforma cuando hace falta, sin apropiarse del dominio.
- **Fronteras.** `eneida` decide la arquitectura → baluarte la **operacionaliza** en paths. `destroyer` decide la seguridad → baluarte la **integra** como default seguro. `amado` prueba → baluarte le ofrece **CI y entornos** donde correr esas pruebas, sin definir la estrategia de calidad.

Escenarios de partida:
- **Greenfield**: baluarte arranca con una *Thinnest Viable Platform* — uno o dos golden paths sobre el dolor más agudo — y crece por demanda medida.
- **Brownfield**: descubre los caminos *de facto* existentes, pavimenta los más usados, ofrece migración gradual y respeta la compatibilidad de los equipos ya productivos.
- **Híbrido**: convive con procesos manuales heredados mientras traslada, camino por camino, las cargas al self-service, sin *big bang*.

Integraciones con aliados externos, marketplaces y componentes de terceros del ensamblado se tratan en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).
