# Contenedores y orquestación

baluarte trata los contenedores como la unidad estándar de empaquetado y despliegue de la plataforma, y la orquestación como el plano de control que los mantiene vivos, sanos y bien colocados. Su alcance es OPERAR: entrega la plataforma de orquestación, los patrones y las plantillas; no diseña la arquitectura de servicios (eso lo decide `eneida`), no escribe el código ni el Dockerfile propio de cada servicio (eso es de `motor`/`farola`), no fija la latencia objetivo (eso es de `peakformance`) ni decide la política de seguridad del contenedor (eso lo decide `destroyer`). Este documento es agnóstico: donde aparece un mecanismo se citan alternativas equivalentes (orquestadores autogestionados o gestionados, contenedores serverless, schedulers no basados en el orquestador dominante, o VMs cuando contenerizar no aporta).

## 1. Fundamentos de contenedores

Un contenedor es un proceso (o grupo de procesos) aislado mediante primitivas del sistema operativo —espacios de nombres para vista aislada de red, PID, montajes y usuarios; y grupos de control para límites de CPU, memoria e I/O— que comparte el kernel del host. No es una máquina virtual: no lleva su propio kernel ni un sistema operativo completo, de ahí su densidad y arranque rápido.

| Concepto | Definición operativa |
|---|---|
| Imagen | Artefacto inmutable de solo lectura, compuesto por capas apiladas; la plantilla. |
| Contenedor | Instancia en ejecución de una imagen, con una capa de escritura efímera encima. |
| Capas | Diffs cacheables y reutilizables entre imágenes; ordénalas de lo estable a lo volátil para maximizar cache hits. |
| Inmutabilidad | La imagen no se modifica en producción; para cambiar, se reconstruye y se redespliega (nunca `exec` para parchear en caliente). |

**Por qué contenerizar.** Paridad dev/prod (el mismo artefacto atraviesa todos los ambientes), densidad (muchos contenedores por host), portabilidad (corre igual en cualquier runtime conforme al estándar) y velocidad de despliegue.

**Cuándo NO.** No todo debe contenerizarse: cargas con dependencias fuertes de kernel o drivers específicos, bases de datos con estado crítico que ya tienen un plano de operación maduro (frontera con `andulfo`), sistemas monolíticos legacy sin beneficio de portabilidad, o funciones muy esporádicas donde una plataforma serverless de funciones o una VM gestionada resulta más simple y barata. Contenerizar por moda es un antipatrón.

## 2. Imágenes de calidad

La calidad de la imagen determina superficie de ataque, tamaño, cold start y reproducibilidad. baluarte estandariza estas prácticas como plantilla; el contenido del Dockerfile específico de un servicio lo co-implementa con su dueño (`motor`/`farola`).

- **Minimalismo.** Bases distroless o slim; incluir solo el runtime y las dependencias necesarias, sin shell ni gestores de paquetes en la imagen final. Menos bytes = menos CVEs, pull más rápido y menor cold start.
- **Multi-stage builds.** Separar la etapa de compilación (con toolchain pesado) de la etapa final (solo el binario/artefacto). Reduce tamaño drásticamente y evita filtrar secretos de build.
- **No-root.** Definir un usuario sin privilegios y `USER` explícito; sistema de archivos de solo lectura donde sea posible; descartar capacidades no usadas. baluarte aplica el hardening que `destroyer` define como política (enlaza [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).
- **Pinning.** Fijar versiones por digest (no por etiqueta móvil como `latest`) para builds deterministas.
- **Escaneo de vulnerabilidades.** Escaneo de imagen y de dependencias en el pipeline, con umbrales que bloquean el release; firma y attestations de procedencia (enlaza [seguridad-de-plataforma.md](seguridad-de-plataforma.md) y [cicd-y-release-engineering.md](cicd-y-release-engineering.md)).
- **Tamaño y cold start.** Imágenes pequeñas mejoran el tiempo hasta "listo", crítico en autoscaling y en contenedores serverless que arrancan bajo demanda.
- **Reproducibilidad.** Builds herméticos y deterministas: mismas entradas → misma imagen (bit a bit cuando el toolchain lo permite). Es responsabilidad del pipeline (enlaza [cicd-y-release-engineering.md](cicd-y-release-engineering.md)).

## 3. Runtime de contenedores

Los estándares abiertos (formato de imagen y de runtime) garantizan que una imagen construida en un lugar corra en cualquier runtime conforme. El plano se divide en un runtime de alto nivel (gestiona ciclo de vida, imágenes, red) y uno de bajo nivel (crea el contenedor a partir de la especificación).

**Aislamiento reforzado.** Cuando el riesgo lo exige —multi-tenencia con cargas no confiables, ejecución de código de terceros— baluarte propone sandboxes que refuerzan la frontera con el kernel (p. ej. runtimes con microVM ligera, sandbox en espacio de usuario que intercepta syscalls, o VMs completas). Es un trade-off de aislamiento contra densidad y latencia de arranque; `destroyer` decide cuándo la política lo obliga.

## 4. Orquestación (agnóstica)

Un orquestador resuelve, de forma continua, lo que un host aislado no puede: **scheduling** (dónde corre cada carga), **self-healing** (reemplazar lo que muere), **service discovery** (encontrar réplicas sin IPs fijas), **scaling** (ajustar réplicas) y **rollout/rollback** (desplegar sin caídas). Alternativas: orquestadores autogestionados, sus variantes gestionadas por proveedor, plataformas de contenedores serverless (sin gestionar nodos), o schedulers no basados en el estándar dominante para casos batch/HPC.

**Modelo declarativo.** El operador describe el *estado deseado* (cuántas réplicas, qué imagen, qué recursos); un bucle de reconciliación compara continuamente el estado real contra el deseado y actúa para converger. baluarte gobierna estos manifiestos como código versionado (enlaza [iac-y-configuracion.md](iac-y-configuracion.md)); nunca opera por comandos imperativos ad hoc en producción (antipatrón "cluster mascota").

## 5. Scheduling y colocación

El scheduler decide en qué nodo coloca cada carga según recursos disponibles y restricciones.

| Mecanismo | Propósito |
|---|---|
| Requests/limits | *Request* = lo garantizado (usado por el scheduler); *limit* = tope duro. Sin límites, una carga puede ahogar al nodo. |
| Afinidad/anti-afinidad | Atraer cargas a nodos/zonas concretos o separar réplicas para no colocarlas juntas. |
| Taints/tolerations (o equivalentes) | Reservar nodos para cargas específicas; repeler las que no toleran la marca. |
| Spread topológico | Distribuir réplicas entre zonas/nodos para sobrevivir a la pérdida de una zona. |

**Bin-packing vs resiliencia.** Empaquetar denso baja costo pero concentra el riesgo (una caída de nodo tumba muchas réplicas). Dispersar da disponibilidad a mayor costo. Es un trade-off explícito que baluarte dimensiona junto a [capacidad-y-costos.md](capacidad-y-costos.md); `peakformance` fija el tamaño de recurso por rendimiento, baluarte lo ajusta por disponibilidad.

## 6. Patrones de workload

- **Stateless.** Réplicas intercambiables sin estado local; el patrón preferido: escala, se reemplaza y se balancea trivialmente.
- **Stateful (con matiz).** Cargas con identidad estable y almacenamiento asociado (patrón tipo *StatefulSet*). baluarte orquesta el patrón, pero el **estado con datos serios** (bases de datos, integridad, backups, replicación) es de `andulfo`; contenerizarlo sin dueño de datos es antipatrón.
- **Sidecar.** Contenedor auxiliar en la misma unidad que extiende la carga principal (proxy de red, recolector de logs, refresco de secretos).
- **Ambassador.** Sidecar que representa un servicio remoto como si fuera local (proxy de salida).
- **Adapter.** Normaliza la salida de la carga a un formato estándar (p. ej. adaptar métricas/logs heterogéneos).
- **Init.** Contenedor que corre a término antes del principal (migraciones ligeras, espera de dependencias, preparación de volumen).
- **Jobs/CronJobs.** Cargas a término, únicas o programadas (batch, mantenimiento).
- **Por-nodo (tipo DaemonSet).** Una instancia por nodo (agentes de logging, métricas, red, seguridad).

## 7. Salud y ciclo de vida

Zero-downtime depende de que el orquestador sepa cuándo una carga está viva, lista y arrancando.

| Sonda | Pregunta que responde | Efecto |
|---|---|---|
| Liveness | ¿Sigue sano el proceso? | Si falla, se reinicia. |
| Readiness | ¿Puede recibir tráfico ya? | Si falla, se saca del balanceo (sin reiniciar). |
| Startup | ¿Terminó de arrancar? | Protege arranques lentos de que liveness los mate prematuramente. |

**Graceful shutdown.** Al terminar: sacar de readiness → drenar conexiones → `SIGTERM` (con `preStop` si hace falta) → periodo de gracia → `SIGKILL`. El código debe manejar `SIGTERM` (frontera con `motor`/`farola`).

**Rolling update seguro.** Reemplazar réplicas por lotes controlados (surge/unavailable) verificando readiness antes de continuar; rollback automático si el nuevo lote no queda sano. Un presupuesto de disrupción (patrón tipo *PodDisruptionBudget*) garantiza un mínimo de réplicas disponibles durante drenajes de nodo y mantenimientos.

## 8. Autoscaling de cargas

- **Horizontal.** Ajustar el número de réplicas por métricas de utilización o de negocio (señales RED/RED-like, colas, latencia). Preferido para cargas stateless.
- **Vertical.** Ajustar request/limit de cada réplica; útil cuando escalar horizontalmente no aplica, pero suele requerir reinicio.
- **De cluster/nodos.** Añadir o quitar nodos cuando el scheduler no puede colocar (o cuando sobran).
- **Escalado a cero.** Bajar a cero réplicas sin tráfico (contenedores serverless, autoescaladores dirigidos por eventos); ahorra costo a cambio de cold start.

**Riesgos.** Definir mínimos, máximos y ventanas de estabilización para evitar oscilación (flapping); mitigar el *thundering herd* (arranques masivos simultáneos que saturan dependencias) con arranque escalonado y límites de concurrencia. baluarte coordina umbrales con [capacidad-y-costos.md](capacidad-y-costos.md) y las metas de disponibilidad con [confiabilidad-sre.md](confiabilidad-sre.md).

## 9. Networking del cluster

- **Service discovery.** Nombres estables que resuelven a réplicas sanas; balanceo interno sin IPs fijas.
- **Ingress/gateway.** Punto de entrada norte↔sur (del exterior al cluster): terminación TLS, enrutamiento por host/ruta, rate limiting básico.
- **Este↔oeste vs norte↔sur.** Tráfico interno entre servicios vs tráfico de entrada/salida; distinguirlos guía dónde aplicar políticas.
- **Políticas de red.** Segmentación por defecto-denegar y reglas explícitas de qué habla con qué (enlaza [cloud-redes-y-edge.md](cloud-redes-y-edge.md) y [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).

**Service mesh.** Añade mTLS automático entre servicios, control fino de tráfico (retries, timeouts, canary por peso, inyección de fallos) y observabilidad uniforme, normalmente vía sidecars o un modo sin sidecar. **Coste:** complejidad operativa, latencia extra por salto y consumo de recursos. **Cuándo sí:** muchos servicios, requisitos de mTLS/zero-trust este-oeste, necesidad de tráfico avanzado. **Cuándo es sobre-ingeniería:** pocos servicios donde una librería de resiliencia o un gateway simple bastan. Mesh "porque sí" es antipatrón.

## 10. Multi-tenencia y aislamiento

Aislar equipos o clientes dentro del cluster combina varios mecanismos:

| Nivel | Mecanismo | Fuerza |
|---|---|---|
| Lógico | Namespaces/proyectos + RBAC | Aislamiento suave (comparte kernel y nodos). |
| Recursos | Quotas y límites por tenant | Evita que un tenant agote el cluster (vecino ruidoso). |
| Red | Políticas de red por tenant | Corta el tráfico lateral no autorizado. |
| Duro | Nodos dedicados, sandboxes o clusters separados | Aislamiento fuerte para cargas no confiables o reguladas. |

La política multi-tenant (qué nivel exige cada tenant) la decide `destroyer`; baluarte la implementa (enlaza [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).

**Arquitectura celular (cell-based) y shuffle sharding — contención de blast radius a escala.** Cuando la escala o el aislamiento lo justifican, el patrón más fuerte para acotar el radio de un fallo es partir el sistema en **celdas** independientes: réplicas completas y autónomas del stack, cada una sirviendo a un subconjunto de tenants/usuarios, sin estado compartido entre celdas. Un fallo (o un tenant tóxico, una *poison pill*, un despliegue malo) queda **confinado a su celda** en vez de tumbar a todos. Palancas asociadas: **routing por celda** (asignar cada tenant a una celda y enrutarlo de forma estable), **despliegue por celda** (canary a nivel de celda: actualizar una antes que el resto), y **shuffle sharding** (repartir cada tenant en una combinación distinta de recursos para que dos tenants rara vez compartan todo, reduciendo el radio de un vecino ruidoso). Frontera: la **decisión de adoptar celdas como estilo** (cómo se particiona el dominio) es de `eneida`; baluarte **opera las celdas, su enrutado y su despliegue progresivo por celda**, y las provisiona vía IaC. Cruza con [confiabilidad-sre.md](confiabilidad-sre.md) (blast radius, dependencias) y [cloud-redes-y-edge.md](cloud-redes-y-edge.md) (enrutado).

## 11. Almacenamiento para contenedores

- **Efímero.** La capa de escritura del contenedor y volúmenes temporales: se pierden al reprogramar. Correcto para cachés y scratch.
- **Persistente.** Volúmenes provisionados que sobreviven al ciclo de la réplica, con clases según rendimiento/durabilidad, atados a la identidad en cargas stateful.

**Frontera con `andulfo`.** baluarte provee y orquesta los volúmenes; los **datos con estado serio** —motores de base de datos, integridad transaccional, replicación, backup/restore, RPO/RTO— son de `andulfo`. Montar un volumen no convierte a baluarte en dueño del dato.

## 12. Operar el cluster (día-2)

- **Upgrades sin downtime.** Actualizar plano de control y nodos por fases (drenar → actualizar → validar → siguiente), respetando presupuestos de disrupción.
- **Capacidad del control plane.** Dimensionar y monitorear los componentes del plano; degradado, deja de reconciliar aunque las cargas sigan corriendo.
- **Gestión de nodos.** Rotación inmutable de nodos (reemplazar, no parchear en caliente), autoreparación de nodos enfermos, drenaje seguro.
- **Día-2.** Backups del estado del cluster, rotación de certificados/secretos, upgrades de add-ons, y todo reproducible desde código (enlaza [iac-y-configuracion.md](iac-y-configuracion.md)). Métricas y alertas del cluster viven en [observabilidad-operacional.md](observabilidad-operacional.md).

## 13. Antipatrones

- Contenedores tratados como VMs (múltiples servicios, systemd/SSH dentro, "mascotas" con estado a mano).
- Un pod/contenedor gigante que concentra todo, imposible de escalar o desplegar por partes.
- Cargas sin límites de recursos → vecino ruidoso y caídas de nodo.
- Root por defecto y sin hardening → superficie de ataque innecesaria.
- Estado crítico corriendo sin dueño de datos (`andulfo`) ni backups.
- Service mesh adoptado sin necesidad ("porque sí").
- Cluster mascota configurado a mano, no reproducible desde código.
- Etiquetas móviles (`latest`) en producción → despliegues no deterministas.

## 14. Cómo baluarte actúa tiered aquí

- **T1 — Directo (dueño).** La plataforma de orquestación y sus patrones/plantillas son de baluarte: instala y opera el orquestador, define plantillas de manifiesto, políticas de scheduling y autoscaling, presupuestos de disrupción, clases de almacenamiento, ingress/mesh, multi-tenencia y el día-2. Diseña, corrige y gobierna sin pedir permiso dentro de su frontera.
- **T2 — Co-implementación.** El manifiesto de despliegue de un servicio ajeno se entrega o co-implementa con su dueño: baluarte aporta la plantilla y el patrón correcto; `motor`/`farola` aportan el Dockerfile y las particularidades de su código; `eneida` valida que respete los límites de arquitectura; `destroyer` la política de seguridad; `andulfo` cualquier dependencia de datos con estado. baluarte no impone diseño de servicio ni reescribe código ajeno.
- **T3 — Potestad (dueño saturado o ausente).** Si un ajuste urgente del workload (límites de recursos, probes, disruption budget) es de un servicio con dueño y este está saturado o no existe, baluarte lo aplica **directo, reversible y marcado "pendiente de revisión del dueño"**, sin tocar la lógica del contenedor.

**Greenfield vs brownfield.** En **greenfield** se parte de imágenes minimalistas no-root, plantillas de manifiesto con probes/límites/disruption budgets y autoscaling desde el primer despliegue. En **brownfield** se adopta lo existente sin romperlo: contenerizar por fases (empezar por lo stateless), meter probes y límites donde falten, migrar cargas mascota a manifiestos reproducibles, y solo entonces endurecer aislamiento y mesh.

baluarte se coordina además con [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) cuando la orquestación cruza fronteras con plataformas de terceros o equipos externos.
