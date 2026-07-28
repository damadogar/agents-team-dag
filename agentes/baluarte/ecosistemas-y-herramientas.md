# Panorama de ecosistemas y herramientas (neutral, por categoría)

Este archivo es la brújula de **neutralidad** de baluarte. Su tema central no es un catálogo de productos, sino un **método para elegir** la herramienta correcta según el contexto, sin favorecer a ningún fabricante, nube ni ecosistema. baluarte no dice "usa X"; dice "para este problema, con estos requisitos y esta madurez de equipo, estas son las alternativas, estos los criterios de decisión y este el trade-off que estoy aceptando". El sesgo cero es explícito y deliberado: cualquier ejemplo nombrado aquí es **ilustración representativa de una categoría**, jamás una recomendación por defecto.

## 1. Principio rector: la herramienta se elige por contexto, no por moda

Una herramienta es una respuesta a un problema situado. La misma pieza puede ser excelente en un contexto y ruinosa en otro. baluarte rechaza tres motores de mala decisión —el hype, el CV-driven development ("lo elijo porque quiero aprenderlo") y la imitación acrítica de lo que hace otra empresa— y ancla toda elección en variables verificables:

- **Requisitos reales** (funcionales y no funcionales: escala, latencia, cumplimiento, SLA, RPO/RTO).
- **Madurez del equipo** que la operará el día 2, no el día 0.
- **Escala presente y proyectada** (evitar tanto sub-dimensionar como sobre-dimensionar "por si acaso").
- **Ecosistema existente**: lo que ya se opera bien tiene un valor enorme que rara vez aparece en un comparativo de features.
- **Coste total de propiedad (TCO)**: licencia + infraestructura + operación + formación + coste de salida.
- **Riesgo de lock-in** y existencia de una estrategia de salida.
- **Comunidad, soporte y longevidad** del proyecto o proveedor.
- **Día-2 ops**: parches, upgrades, backups, observabilidad, respuesta a incidentes.

## 2. Marco de decisión reutilizable (rúbrica de criterios ponderados)

baluarte evalúa candidatos con una rúbrica explícita y reproducible. Los pesos se ajustan al contexto (un banco pondera cumplimiento y salida; una startup pondera velocidad y curva de aprendizaje), pero el marco es siempre el mismo:

| Criterio | Qué se evalúa | Peso típico | Pregunta guía |
|---|---|---|---|
| Fit funcional | ¿Resuelve el problema real, no uno adyacente? | 20% | ¿Cubre el caso de uso sin forzar el modelo mental? |
| Madurez / comunidad | Longevidad, releases, contribuyentes, gobernanza | 12% | ¿Seguirá vivo y soportado en 3-5 años? |
| Operabilidad (día 2) | Upgrades, backups, observabilidad, HA, incidentes | 18% | ¿Podemos operarlo sin un equipo dedicado que no tenemos? |
| TCO | Licencia + infra + operación + formación + salida | 15% | ¿Cuál es el coste completo a 3 años, no el sticker price? |
| Lock-in / salida | Estándares abiertos, exportabilidad, reversibilidad | 12% | Si mañana hay que salir, ¿cuánto cuesta y es posible? |
| Seguridad / supply chain | CVEs, cadencia de parches, firma, SBOM, superficie | 10% | ¿Amplía o reduce nuestra superficie de ataque? |
| Curva / carga cognitiva | Aprendizaje, docs, encaje con el equipo | 8% | ¿El equipo lo dominará o vivirá pegado a la documentación? |
| Interoperabilidad | Estándares abiertos, APIs, formatos portables | 5% | ¿Habla protocolos abiertos o dialectos propietarios? |

El resultado no es un número mágico que decide solo: es una conversación estructurada que hace **explícitos los trade-offs**. Una herramienta con fit perfecto pero inoperable por el equipo puntúa bajo, y con razón.

## 3. Un método para evaluar cualquier herramienta

Ocho lentes que baluarte aplica a cualquier candidato, sea de la categoría que sea:

1. **Fit funcional**: ¿resuelve el problema central o uno vecino? Cuidado con estirar una herramienta fuera de su propósito.
2. **Madurez y comunidad**: cadencia de releases, salud de la gobernanza, tamaño y diversidad de contribuyentes, roadmap.
3. **Operabilidad (día 2)**: lo barato de instalar suele ser caro de operar. Upgrades, migraciones, backups, tuning, respuesta a incidentes.
4. **TCO real**: incluye licencia, infraestructura, tiempo de ingeniería, formación y el coste —frecuentemente ignorado— de salir.
5. **Lock-in y estrategia de salida**: ¿los datos y la configuración son portables? ¿Existe un camino de reversión documentado?
6. **Seguridad y supply chain**: historial de CVEs, firma de artefactos, SBOM, procedencia, superficie de ataque que añade.
7. **Curva de aprendizaje y carga cognitiva**: cada herramienta nueva es un impuesto permanente sobre la atención del equipo.
8. **Interoperabilidad y estándares abiertos**: ¿se integra por protocolos estándar o exige un ecosistema cerrado?

## 4. Tabla-catálogo por categoría

Para cada categoría: el problema que resuelve, los arquetipos/enfoques, los criterios de elección y **3+ ejemplos representativos de ecosistemas distintos, solo como ilustración neutral**. Nombrar no es recomendar. La decisión detallada de cada dominio vive en el archivo hermano correspondiente.

### 4.1 IaC / provisioning
- **Problema**: describir y crear infraestructura de forma repetible, versionada y auditable.
- **Arquetipos**: declarativo vs imperativo; multi-nube (agnóstico) vs nativo del proveedor; lenguaje de dominio (DSL) vs lenguaje de propósito general.
- **Criterios**: número de nubes, madurez del equipo, necesidad de portabilidad real, gestión de estado, ecosistema de módulos, gobernanza de drift.
- **Ilustración**: DSL declarativo multi-nube · IaC nativo de un proveedor · IaC en lenguaje de propósito general · enfoque imperativo con SDK.
- Detalle: [iac-y-configuracion.md](iac-y-configuracion.md).

### 4.2 Gestión de configuración
- **Problema**: llevar servidores/nodos a un estado deseado y mantenerlo.
- **Arquetipos**: push vs pull; con agente vs sin agente; declarativo vs procedural.
- **Criterios**: inmutable vs mutable (¿de verdad necesito config management o basta con imágenes inmutables?), tamaño de flota, conectividad, idempotencia.
- **Ilustración**: agentless sobre SSH · basado en agente pull · declarativo de estado de sistema · imágenes doradas + reemplazo inmutable.
- Detalle: [iac-y-configuracion.md](iac-y-configuracion.md).

### 4.3 CI/CD (motores de pipeline)
- **Problema**: construir, probar y entregar cambios de forma automática y fiable.
- **Arquetipos**: pipelines-as-code vs configuración por UI; self-hosted vs gestionado (SaaS); acoplado al SCM vs independiente.
- **Criterios**: dónde vive el código, requisitos de aislamiento/cumplimiento, coste de runners, extensibilidad, seguridad de la cadena (permisos, secretos, aislamiento de jobs).
- **Ilustración**: motor integrado en la plataforma de SCM · servidor de automatización extensible autogestionado · SaaS de pipelines-as-code · CI cloud-native basado en contenedores.
- Detalle: [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

### 4.4 GitOps / reconciliación
- **Problema**: que el estado deseado viva en Git y un agente reconcilie continuamente el clúster hacia él.
- **Arquetipos**: pull-based (agente en el clúster) vs push-based; app-of-apps vs por-aplicación.
- **Criterios**: número de clústeres, modelo de multi-tenancy, gestión de secretos en Git, estrategia de promoción entre entornos, detección de drift.
- **Ilustración**: reconciliador con panel de aplicaciones · toolkit de reconciliación por controladores · plataforma GitOps de despliegue progresivo.
- Detalle: [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

### 4.5 Orquestación de contenedores
- **Problema**: programar, escalar y recuperar cargas en contenedores sobre una flota.
- **Arquetipos**: orquestador gestionado vs autogestionado; el estándar de facto vs orquestadores más simples; **serverless containers** (sin gestionar nodos); PaaS de contenedores.
- **Criterios**: complejidad justificada por la escala, capacidad del equipo para operar el plano de control, portabilidad, coste, madurez del ecosistema de extensiones.
- **Ilustración**: orquestador de contenedores gestionado por un proveedor · el mismo orquestador autogestionado · serverless containers · orquestador ligero para el borde · PaaS que abstrae el orquestador.
- Frontera: no todo necesita el orquestador estándar; a veces un runtime más simple es la elección correcta. Detalle: [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md).

### 4.6 Registro de artefactos / imágenes
- **Problema**: almacenar, versionar, firmar y distribuir imágenes y paquetes.
- **Arquetipos**: gestionado por el proveedor de nube vs autogestionado; registro dedicado vs repositorio universal multi-formato.
- **Criterios**: soporte de firma y escaneo, replicación geográfica, control de acceso, formatos soportados, retención/GC, integración con la cadena de suministro.
- **Ilustración**: registro nativo de la nube · registro universal multi-formato autogestionable · registro OSS enfocado en seguridad.
- Detalle: [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md), [seguridad-de-plataforma.md](seguridad-de-plataforma.md).

### 4.7 Observabilidad (métricas / logs / traces)
- **Problema**: entender el comportamiento del sistema en producción; señales para operar y depurar.
- **Arquetipos**: suite integrada (una plataforma) vs best-of-breed por señal; agente propietario vs **estándar abierto de instrumentación**; almacenamiento propio vs gestionado.
- **Criterios**: neutralidad de instrumentación (para no reinstrumentar al cambiar de backend), volumen y cardinalidad, coste por ingesta/retención, correlación entre señales, portabilidad de dashboards y alertas.
- **Ilustración**: métricas pull + series temporales OSS · stack de logs con motor de búsqueda · backend de trazas distribuidas · plataforma SaaS integrada de las tres señales. La instrumentación vía un **estándar abierto** desacopla la app del backend y es la mejor defensa contra el lock-in de observabilidad.
- Detalle: [observabilidad-operacional.md](observabilidad-operacional.md).

### 4.8 Gestión de secretos
- **Problema**: custodiar, rotar y entregar credenciales sin exponerlas en código ni config.
- **Arquetipos**: gestor dedicado autogestionado vs servicio gestionado de la nube; secretos estáticos vs **dinámicos/efímeros**; identidad de carga (workload identity) para eliminar credenciales de larga vida.
- **Criterios**: rotación automática, auditoría, integración con IaC/CI/orquestador, modelo de sellado/desellado, coste operativo.
- **Ilustración**: bóveda de secretos con secretos dinámicos · gestor de secretos gestionado por la nube · integración nativa del orquestador con proveedores externos.
- Detalle: [seguridad-de-plataforma.md](seguridad-de-plataforma.md).

### 4.9 Policy-as-code / admission
- **Problema**: expresar y hacer cumplir políticas (seguridad, cumplimiento, coste) como código verificable.
- **Arquetipos**: motor de políticas de propósito general vs específico del orquestador; validación en CI (shift-left) vs admission en runtime.
- **Criterios**: lenguaje de política y su curva, punto de aplicación (pipeline vs clúster), auditabilidad, cobertura de recursos, biblioteca de políticas existente.
- **Ilustración**: motor de políticas con lenguaje declarativo propio · controlador de admisión basado en plantillas · validador de manifiestos en pipeline.
- Detalle: [seguridad-de-plataforma.md](seguridad-de-plataforma.md), [gobernanza-y-etica.md](gobernanza-y-etica.md).

### 4.10 Service mesh / networking
- **Problema**: gestionar tráfico servicio-a-servicio: mTLS, enrutamiento, resiliencia, telemetría.
- **Arquetipos**: mesh con sidecar vs sin sidecar (a nivel de nodo/kernel); mesh completo vs solo librería de resiliencia; ¿de verdad necesito un mesh?
- **Criterios**: número de servicios, requisitos de mTLS y multi-tenancy, sobrecarga (latencia/recursos), complejidad operativa frente al beneficio real.
- **Ilustración**: mesh con proxy sidecar · mesh sin sidecar basado en el nivel de nodo · malla ligera acoplada al orquestador · resiliencia por librería sin mesh. Advertencia: un mesh es una respuesta a escala; adoptarlo prematuramente añade complejidad sin retorno.
- Detalle: [cloud-redes-y-edge.md](cloud-redes-y-edge.md), [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md).

### 4.11 Feature flags / progressive delivery
- **Problema**: desacoplar despliegue de release; entregar de forma gradual y reversible.
- **Arquetipos**: flags gestionados (SaaS) vs OSS autogestionado vs solución interna; canary/blue-green/rolling; automatizado por métricas.
- **Criterios**: latencia de evaluación, targeting, gobernanza de deuda de flags, integración con observabilidad para promoción automática, coste.
- **Ilustración**: plataforma SaaS de flags · servicio OSS autogestionado · controlador de despliegue progresivo guiado por métricas.
- Detalle: [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

### 4.12 Portal de desarrollador / catálogo (IDP)
- **Problema**: reducir la carga cognitiva ofreciendo self-service, catálogo y golden paths.
- **Arquetipos**: portal OSS extensible vs SaaS vs ensamblado sobre herramientas existentes; IDP como producto interno.
- **Criterios**: madurez de la plataforma subyacente (un IDP sin plataforma detrás es una fachada), esfuerzo de mantenimiento, adopción real, integración con el catálogo de servicios.
- **Ilustración**: portal OSS de catálogo y plantillas · plataforma SaaS de portal interno · orquestador de infraestructura self-service.
- Nota: el IDP es un medio para bajar la carga cognitiva, no un fin. Detalle: [plataforma-e-idp.md](plataforma-e-idp.md), [gobernanza-y-etica.md](gobernanza-y-etica.md).

### 4.13 Chaos engineering / carga
- **Problema**: validar la resiliencia inyectando fallos controlados y verificando hipótesis.
- **Arquetipos**: inyección de fallos a nivel de infra/red/proceso; experimentos gestionados vs OSS; game days.
- **Criterios**: blast radius controlable, integración con observabilidad, reversibilidad, seguridad para ejecutar en producción.
- **Fronteras claras**: la **carga de rendimiento** (load/stress/soak) es de peakformance; el **diseño del experimento de caos como prueba** es de amado; la **ejecución en producción con salvaguardas operativas** (blast radius, rollback, ventana, observabilidad) es de baluarte.
- **Ilustración**: plataforma de chaos gestionada · herramientas OSS de inyección de fallos · framework de fault injection a nivel de orquestador.
- Detalle: [incidentes-y-respuesta.md](incidentes-y-respuesta.md) (§9) y [continuidad-y-dr.md](continuidad-y-dr.md) (§8). Frontera: `amado` **diseña** el experimento como prueba; baluarte lo **ejecuta** como game-day/DiRT en producción.

### 4.14 Escaneo de seguridad (SAST / DAST / SCA / secretos)
- **Problema**: detectar vulnerabilidades en código, dependencias, imágenes y config antes y después de desplegar.
- **Arquetipos**: SAST (código), DAST (app en ejecución), SCA (dependencias/SBOM), escáner de secretos, escáner de imágenes/IaC.
- **Criterios**: cobertura de lenguajes, tasa de falsos positivos, integración en pipeline, gestión de resultados, cadencia de la base de datos de vulnerabilidades.
- **Frontera**: baluarte **integra y opera** el escaneo en la cadena (gates en CI, escaneo de imágenes en el registro, admission), pero la **decisión de política de seguridad y la aceptación de riesgo** son de destroyer. baluarte ejecuta lo que la política exige.
- **Ilustración**: escáner de dependencias/SCA con SBOM · SAST integrado en el SCM · escáner de imágenes en el registro · detector de secretos en pre-commit y pipeline.
- Detalle: [seguridad-de-plataforma.md](seguridad-de-plataforma.md).

## 5. Lock-in y estrategia multi-cloud / portabilidad

El lock-in no es intrínsecamente malo: es un **trade-off** entre velocidad hoy y opcionalidad mañana. La pregunta correcta no es "¿esto genera lock-in?" (todo lo hace en algún grado) sino "¿el lock-in que acepto es proporcional al valor que recibo, y tengo una salida?".

- **Cuándo abstraer** (estándares abiertos, capas de portabilidad): cuando la probabilidad de cambio es real, el coste de salida sería prohibitivo, o hay requisitos regulatorios/de negociación que exigen opcionalidad.
- **Cuándo aceptar un gestionado propietario**: cuando la velocidad y el menor coste operativo superan claramente el riesgo, y el servicio no es el corazón diferenciador del negocio. Operar uno mismo una base de datos o un orquestador "por no depender" puede costar más que el lock-in que se evita.
- **El coste de la portabilidad prematura**: construir una capa de abstracción multi-nube "por si acaso" impone un impuesto permanente (complejidad, menor común denominador de features, doble testing) que rara vez se recupera. La portabilidad se diseña donde el riesgo lo justifica, no en todas partes por defecto.

Regla práctica de baluarte: **abstrae en las fronteras de alto riesgo y alto coste de salida; acopla deliberadamente donde el gestionado da ventaja y la reversión es asumible.** Y siempre documenta la estrategia de salida, aunque nunca se ejecute.

## 6. Consolidación vs best-of-breed

Cada herramienta añadida es un coste recurrente: formación, operación, integración, superficie de ataque y —sobre todo— **carga cognitiva** del equipo. El mejor stack no es el que tiene la mejor herramienta en cada casilla, sino el que el equipo puede **operar con excelencia el día 2**.

- **Best-of-breed** tiene sentido cuando una capacidad es diferencial y el equipo tiene capacidad para operarla bien. Best-of-breed sin capacidad de operación es deuda disfrazada de sofisticación.
- **Consolidación / "boring technology"**: preferir tecnología aburrida, probada y ya dominada reduce el riesgo y libera atención para los problemas que sí son del negocio. Racionalizar el tooling (retirar solapamientos) suele dar más valor que añadir la siguiente herramienta brillante.
- **Carga cognitiva y Team Topologies**: la plataforma existe para **reducir la carga cognitiva** de los equipos de stream. Demasiadas herramientas la aumentan y sabotean ese propósito. La decisión de consolidar se alinea con la topología de equipos y la estrategia de plataforma (véase [metodologia-y-cultura.md](metodologia-y-cultura.md) — Team Topologies — y [plataforma-e-idp.md](plataforma-e-idp.md)).

Antes de adoptar, baluarte pregunta: **¿qué herramienta retiramos?** Añadir sin retirar es cómo nace el pantano de tooling.

## 7. Estándares abiertos e interoperabilidad como defensa

Los estándares abiertos son la palanca estructural contra el lock-in: instrumentación de observabilidad neutral, formatos de imagen y artefactos abiertos, APIs y protocolos estándar, formatos de datos portables, especificaciones de interfaz comunes. Preferir componentes que **hablan protocolos abiertos** conserva opcionalidad sin pagar el impuesto de una capa de abstracción propia. La interoperabilidad se diseña en las costuras del sistema: donde dos herramientas se encuentran, un estándar abierto mantiene ambas reemplazables. Véase [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## 8. Greenfield, brownfield e híbrido

- **Greenfield**: hay libertad, pero la restricción real es la **capacidad de operación** del equipo, no el catálogo. Elegir aburrido y consolidado acelera; elegir la frontera tecnológica sin equipo para operarla hunde el proyecto. Diseñar la estrategia de salida desde el inicio es barato aquí.
- **Brownfield**: el ecosistema existente tiene un peso enorme y legítimo. La coherencia con lo que ya se opera bien suele vencer a la superioridad marginal de una alternativa. Los cambios son incrementales, con estrangulamiento gradual y sin big-bang.
- **Híbrido**: lo común en la práctica. baluarte define fronteras claras (qué se estandariza, qué se tolera como legado, qué se migra y cuándo), evitando tanto la fragmentación como la migración forzada sin retorno.

## 9. Cómo baluarte usa este panorama

baluarte **recomienda una elección justificada por el contexto**, nunca una preferencia de vendor. Ante una decisión de herramienta:

1. Enmarca el problema y los requisitos no funcionales.
2. Aplica la rúbrica ponderada (§2) con pesos ajustados al contexto.
3. Presenta **3+ alternativas** de ecosistemas distintos con sus trade-offs.
4. Recomienda una, **declarando explícitamente el criterio decisivo y lo que se sacrifica**.
5. Documenta la estrategia de salida y las condiciones que reabrirían la decisión.

El entregable no es "usa X", sino "para este contexto elijo X **porque** [criterio], aceptando [trade-off], con salida vía [estándar/plan]; si cambia [condición], reevaluamos". La justificación y los trade-offs son el producto; la herramienta es solo la conclusión.

## 10. Antipatrones

- **Elegir por hype o CV-driven development**: adoptar tecnología para el currículo o por moda, no por el problema.
- **Best-of-breed sin capacidad de operarlo**: la mejor herramienta que nadie sabe mantener el día 2 es la peor decisión.
- **Lock-in accidental**: acoplarse a un servicio sin haberlo decidido conscientemente ni documentado la salida.
- **Reinventar lo que un gestionado ya resuelve**: operar a mano una capacidad commodity "por independencia" y pagar más de lo que el lock-in habría costado.
- **"Una herramienta más" sin retirar la anterior**: crecimiento no gestionado del tooling que dispara la carga cognitiva y la superficie de ataque.
- **Portabilidad prematura**: abstraer multi-nube "por si acaso" cuando el riesgo no lo justifica, pagando complejidad permanente.
- **Comparar por checklist de features** ignorando operabilidad, TCO y salida —donde se decide el éxito real.
