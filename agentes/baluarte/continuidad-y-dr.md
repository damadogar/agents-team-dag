# Continuidad y recuperación ante desastres (HA/DR)

La continuidad del negocio depende de dos capacidades complementarias: mantener el servicio en pie ante fallos rutinarios (alta disponibilidad) y reconstruirlo tras una pérdida mayor (disaster recovery). baluarte es dueño de la HA/DR de la **plataforma e infraestructura** —cómputo, red, orquestación, estado de la plataforma— y de la **orquestación** del failover y la recuperación del entorno. Este satélite fija esa frontera, los objetivos que la gobiernan (RTO/RPO), los patrones probados y los antipatrones a evitar. La HA/DR de los **datos** pertenece a `andulfo`; el plan completo se co-diseña.

## 1. HA vs DR: dos capacidades bajo la continuidad del negocio

- **Alta disponibilidad (HA)**: evitar que un fallo local (una instancia, un nodo, una zona) se convierta en indisponibilidad. Se resuelve con redundancia, health checks y failover automático dentro de un sitio o región. Es un problema de diseño continuo, no de evento excepcional.
- **Disaster recovery (DR)**: recuperar el servicio tras una pérdida mayor —caída de una región completa, corrupción masiva, ransomware, error operativo destructivo—. Implica reconstruir o activar el entorno en otro lugar y volver a operar.
- **Business Continuity (BC)**: el marco mayor que engloba a ambas. Incluye personas, procesos, comunicación y prioridades de negocio, no solo tecnología. HA y DR son las palancas técnicas de la continuidad; el BCP define qué procesos deben sobrevivir y en qué orden.

| Dimensión | HA | DR |
|---|---|---|
| Escenario | Fallo local/parcial | Pérdida mayor de sitio/región |
| Horizonte | Segundos–minutos, continuo | Minutos–horas, evento raro |
| Mecanismo | Redundancia + failover automático | Activación/reconstrucción del entorno |
| Métrica dominante | Disponibilidad (uptime) | RTO/RPO |
| Alcance baluarte | Cómputo, red, orquestación | Orquestación de failover y reconstrucción de infra |

## 2. RTO y RPO: los objetivos que lo gobiernan todo

Dos objetivos derivados del impacto de negocio definen cuánto invertir y qué patrón elegir.

- **RTO (Recovery Time Objective)**: tiempo máximo tolerable para restaurar el servicio tras el incidente. "¿Cuánto puede estar caído?".
- **RPO (Recovery Point Objective)**: cantidad máxima de datos que se tolera perder, medida en tiempo. "¿Hasta qué momento atrás puedo recuperar?". Un RPO de 5 minutos implica que, en el peor caso, se pierden hasta 5 minutos de transacciones.

**Cómo derivarlos**: no se inventan; se obtienen de un análisis de impacto de negocio (BIA) que cuantifica el coste por hora de caída y el coste de pérdida de datos por proceso crítico. El negocio (con `eneida` y el PO) fija los objetivos; baluarte y `andulfo` los hacen técnicamente alcanzables y reportan su coste.

**Coste creciente y no lineal**: cada orden de magnitud de mejora (de horas a minutos a segundos) multiplica el coste. Un RTO de 24 h se cubre con backup-restore barato; un RTO de segundos exige active-active permanentemente encendido. Perseguir RPO/RTO ≈ 0 en todo el sistema es un despilfarro; se aplican objetivos por criticidad (tiering de servicios).

**Frontera de responsabilidad sobre RTO/RPO**:

| Objetivo | Dueño | Contenido |
|---|---|---|
| RPO/RTO de **datos** | `andulfo` | Réplica del motor, consistencia, backups de datos, punto de recuperación de la información |
| RTO de **infra/plataforma** | baluarte | Reprovisionar cómputo/red, orquestar el failover, levantar el entorno |
| **RTO extremo-a-extremo** | co-diseñado | Suma coordinada: no basta con datos recuperados si la plataforma no está lista, ni viceversa |

El RTO que percibe el negocio es la **suma de ambos caminos ejecutados en coordinación**. Por eso el runbook de failover es conjunto: `andulfo` promueve/recupera el dato, baluarte prepara y conmuta la plataforma, y el orden de pasos se ensaya junto. Ver [confiabilidad-sre.md](confiabilidad-sre.md) para cómo estos objetivos se relacionan con SLOs y error budgets.

## 3. Dominios de fallo y redundancia

La redundancia solo elimina un riesgo si abarca el **dominio de fallo** correcto. Un servicio duplicado dentro de la misma zona no sobrevive a la caída de esa zona.

```
Instancia  ⊂  Zona (AZ)  ⊂  Región  ⊂  Proveedor
```

- **Instancia/nodo**: se cubre con N+1 (una réplica extra sobre lo necesario) o N+2. Base de cualquier servicio serio.
- **Zona (AZ)**: diseñar **multi-AZ como línea base** de producción. Distribuir réplicas en al menos dos zonas independientes de forma que la caída de una no reduzca el servicio por debajo del mínimo. Es HA, no DR.
- **Región**: la protección multi-región es el terreno de **DR** y del active-active geográfico. Ver [cloud-redes-y-edge.md](cloud-redes-y-edge.md).
- **Proveedor**: multi-cloud/multi-proveedor mitiga el fallo del proveedor completo; añade complejidad alta y rara vez se justifica salvo requisito regulatorio o de riesgo extremo.

**Eliminar SPOFs** (single points of failure) es el trabajo central: todo componente en el camino crítico sin redundancia es un punto único. El inventario y la eliminación sistemática de SPOFs se detalla en [confiabilidad-sre.md](confiabilidad-sre.md). La **decisión** de qué topología multi-región adoptar es de `eneida`; baluarte la **opera**: la implementa, la mantiene y ejecuta el failover.

## 4. Estrategias/patrones de DR

Elegir el patrón es elegir un punto en la curva RTO/RPO vs coste. De más barato/lento a más caro/rápido:

| Patrón | RTO típico | RPO típico | Coste | Idea |
|---|---|---|---|---|
| **Backup & restore** | Horas–días | Horas | Muy bajo | Sin entorno secundario; se reconstruye desde backups + IaC bajo demanda |
| **Pilot light** | Decenas de min | Minutos | Bajo | Núcleo mínimo encendido en el sitio secundario (datos replicándose); el resto se escala al activar |
| **Warm standby** | Minutos | Segundos–min | Medio | Copia reducida del entorno siempre corriendo; se escala al tamaño de producción en failover |
| **Hot standby** | Segundos–min | ~Segundos | Alto | Copia completa a escala lista para recibir tráfico casi de inmediato |
| **Active-active multi-región** | ~0 (sin corte) | ~0 | Muy alto | Todas las regiones sirven tráfico en paralelo; la caída de una se absorbe |

**Cómo decidir**: partir del RTO/RPO por servicio (tiering) y del presupuesto. Servicios de misión crítica con RTO en segundos justifican warm/hot standby o active-active; servicios internos tolerantes a horas se cubren con backup-restore o pilot light. El active-active da la mejor recuperación pero exige resolver consistencia de datos multi-región (dominio de `andulfo`) y enrutamiento global (ver [cloud-redes-y-edge.md](cloud-redes-y-edge.md)). No todos los servicios necesitan el mismo patrón: se mezclan según criticidad.

## 5. Patrones de alta disponibilidad (HA)

Dentro de un sitio/región, la disponibilidad se construye con:

- **Balanceo + health checks + failover**: un balanceador reparte carga solo entre instancias sanas; una instancia que falla su health check se retira automáticamente y el tráfico se redirige. Health checks profundos (no solo "el puerto responde") evitan enviar tráfico a instancias degradadas.
- **Réplicas sin estado (stateless)**: los servicios sin estado escalan y se recuperan trivialmente —cualquier réplica atiende cualquier petición—. Empujar el estado fuera del cómputo (a la capa de datos/caché) es el mayor habilitador de HA.
- **Quórum/consenso para lo que tiene estado**: los componentes de plataforma con estado (p. ej. coordinadores de orquestación, gestores de configuración distribuida, sistemas de bloqueo) requieren un número impar de nodos y consenso para tolerar fallos sin split-brain. **Matiz de frontera**: el consenso y la consistencia de **los datos de negocio** es de `andulfo`; baluarte se ocupa del quórum de los **componentes de plataforma**.
- **Graceful degradation por zona**: ante la caída de una zona, el sistema debe seguir sirviendo con capacidad reducida en las zonas restantes en lugar de caer entero. El diseño de degradación elegante se cubre en [confiabilidad-sre.md](confiabilidad-sre.md).

## 6. Backup y restore (lo que sí es de baluarte)

El backup de baluarte es el que permite **reconstruir el entorno**, no los datos de negocio:

- **Configuración de plataforma como código**: IaC (definiciones de infraestructura), estado de orquestación, configuración declarativa y **referencias de secretos** (los punteros a los secretos, gestionados en su bóveda; nunca los secretos en claro). Con esto el entorno se reconstruye de forma reproducible. Ver [iac-y-configuracion.md](iac-y-configuracion.md).
- **Backups inmutables y versionados**: los respaldos deben ser inmutables (WORM) y versionados, de modo que un atacante con credenciales —o un error operativo— no pueda alterarlos ni borrarlos. Esto es la defensa clave contra ransomware.
- **Regla 3-2-1**: al menos **3** copias, en **2** medios/tecnologías distintas, con **1** fuera del sitio (offsite / otra región o cuenta). Variante 3-2-1-1-0: añadir 1 copia offline/air-gapped y 0 errores verificados en la restauración.
- **El restore probado — regla de oro**: *un backup no probado no existe*. La única prueba de un backup es una restauración exitosa y verificada. La capacidad de recuperación real es "reconstruir el entorno desde IaC + restaurar", medida y cronometrada periódicamente, no la mera existencia del respaldo. La reconstrucción del entorno desde IaC se apoya en [iac-y-configuracion.md](iac-y-configuracion.md).

**Frontera explícita**: el backup y restore de **los datos** (dumps, snapshots del motor, PITR, réplica física) es de `andulfo`. baluarte respalda **cómo se levanta el entorno**; `andulfo` respalda **qué información vive dentro**. Un DR real necesita ambos, y se prueban juntos.

## 7. Failover y failback

- **Failover automático vs manual**: el automático (disparado por health checks/detección de fallo) minimiza el RTO pero exige lógica robusta anti-oscilación y anti-split-brain. El manual (con aprobación humana) es más seguro contra falsos positivos pero añade minutos u horas de RTO y depende de personas disponibles. Se elige según criticidad; lo crítico tiende a automatizarse **y ensayarse**.
- **Criterios de disparo**: definir umbrales objetivos y medibles (pérdida de health de la región, latencia/errores sostenidos, pérdida de conectividad) que decidan el failover, evitando el juicio heroico bajo presión.
- **DNS y gestión de tráfico**: el failover regional se materializa redirigiendo tráfico —DNS con TTL bajo, balanceo global, anycast, health-based routing—. Ver [cloud-redes-y-edge.md](cloud-redes-y-edge.md) para los mecanismos.
- **Split-brain**: dos sitios que se creen simultáneamente "el primario" corrompen el estado. Se previene con quórum, fencing (STONITH) y una única autoridad de decisión. Es un riesgo central del failover de estado.
- **Failback ordenado**: tras resolver el incidente, volver al sitio primario es un procedimiento **planificado, no automático**: resincronizar datos (coordinado con `andulfo`), validar integridad, drenar y reconmutar tráfico gradualmente. Olvidar el failback deja al sistema operando indefinidamente en un modo secundario no diseñado para permanencia.

## 8. Pruebas de DR y game-days de recuperación

*Un plan de DR se valida ejecutándolo, no leyéndolo.* Un plan solo escrito es una hipótesis.

- **DiRT (Disaster Recovery Testing)** / ejercicios de recuperación programados: simular la pérdida de una zona o región y ejecutar el runbook real de failover, midiendo RTO/RPO efectivos contra los objetivos.
- **Ejercicios de failover regional**: conmutar deliberadamente a la región secundaria en ventana controlada y operar allí un tiempo. Revela dependencias ocultas al sitio primario.
- **Prueba periódica del restore**: restaurar el entorno desde IaC y los backups en un entorno limpio, con cadencia fija, y cronometrarlo. Cubre la parte de baluarte; la restauración de datos la prueba `andulfo`, idealmente en el mismo ejercicio.
- **Chaos de infraestructura**: inyección controlada de fallos (matar nodos, cortar zonas, degradar red) para validar que la HA responde como se diseñó.

Estos ejercicios se coordinan como game-days junto a [incidentes-y-respuesta.md](incidentes-y-respuesta.md): mismo formato, blast radius acotado, hipótesis explícita, aprendizajes registrados.

## 9. Runbook de DR y comunicación durante el desastre

El runbook de DR es el guion ejecutable del peor día: precondiciones, criterios de activación, secuencia paso a paso de failover (quién promueve datos —`andulfo`—, quién conmuta plataforma —baluarte—, en qué orden), puntos de verificación, y el procedimiento de failback. Debe estar accesible **aunque el sistema principal esté caído** (fuera de banda).

La comunicación durante el desastre —cadencia de actualizaciones, roles, canal de estado, escalamiento— y las plantillas asociadas se rigen por [incidentes-y-respuesta.md](incidentes-y-respuesta.md). Un DR bien orquestado técnicamente puede fracasar si la comunicación con negocio y usuarios se improvisa.

**Continuidad del propio plano de entrega (break-glass).** El caso que más se olvida: **desplegar o mitigar cuando el propio pipeline/plano de control está caído** (el CI, el GitOps o la consola de la plataforma no responden, justo cuando más se necesitan). baluarte prepara una **ruta de despliegue de emergencia fuera de banda** —credenciales break-glass selladas, un camino mínimo y **auditado** para aplicar un cambio sin el pipeline normal, y la capacidad de reconstruir el plano de control desde IaC—. Como todo break-glass: acceso restringido, uso registrado y alarmado, y revisión posterior obligatoria (la **política de acceso** break-glass la fija `destroyer`; baluarte la opera —es el gemelo, para *desplegar*, del break-glass de *acceso* de [seguridad-de-plataforma.md](seguridad-de-plataforma.md) §9). Un plan de DR que asume que la maquinaria de entrega siempre estará viva no es un plan de DR.

## 10. Antipatrones

- **DR en papel nunca probado**: plan documentado que jamás se ejecutó; falla justo cuando se necesita.
- **Backup sin restore probado**: se respalda religiosamente pero nunca se restaura; se descubre corrupto o incompleto en la emergencia.
- **Single-region / single-AZ en producción crítica**: un dominio de fallo sin redundancia real; la caída de esa zona o región es total.
- **RTO/RPO no definidos**: sin objetivos no hay forma de dimensionar ni de saber si el DR es suficiente; se sobre o infra-invierte a ciegas.
- **Failover manual heroico y no ensayado**: depender de que una persona concreta ejecute pasos memorizados bajo presión, sin runbook ni práctica.
- **Backups mutables o borrables por el atacante**: respaldos que el ransomware o una credencial comprometida pueden cifrar o eliminar; equivalen a no tener backup.
- **Olvidar el failback**: quedarse operando indefinidamente en el sitio secundario, acumulando deuda y riesgo.
- **Confundir HA con DR**: creer que el multi-AZ (HA) protege de la pérdida de región (DR), o viceversa. Son capas distintas y ambas hacen falta.

## 11. Actuación tiered de baluarte

| Ámbito | Tier | Actuación |
|---|---|---|
| HA/DR de **infra**: cómputo, red, orquestación, multi-AZ/multi-región operados | **T1** | baluarte diseña, implementa y opera de forma directa |
| **Orquestación del failover** de plataforma y del failback | **T1** | baluarte es dueño del runbook de infra y de su ejecución |
| **Backup de configuración** (IaC/estado/referencias de secretos) y **restore del entorno** | **T1** | baluarte respalda, versiona (inmutable) y prueba la reconstrucción |
| **DR de los datos** (RPO/RTO de datos, réplica, consistencia, backup/restore de datos) | **T2 · co-diseño** | Dueño: `andulfo`. baluarte co-diseña, aporta la infra de recuperación y coordina el runbook conjunto |
| **Topología multi-región / arquitectura de continuidad** | decide `eneida` | baluarte la **opera**; no decide, implementa y mantiene |
| **Objetivos RTO/RPO de negocio** | fija el negocio | baluarte hace alcanzable la parte de infra y reporta su coste |
| **Riesgo de continuidad inminente sin dueño** (p. ej. un SPOF crítico y `andulfo`/`eneida` saturados o ausentes) | **T3 · potestad** | baluarte aplica la mitigación de **infra** reversible (añadir redundancia, automatizar un failover básico) marcada "pendiente de revisión del dueño"; no decide réplica de datos ni topología macro |

**Greenfield vs brownfield.** En **greenfield** la continuidad se diseña desde el inicio: multi-AZ por defecto, RTO/RPO acordados antes del primer lanzamiento, backup de config y restore probados como parte del paved road. En **brownfield** se hace *retrofit* sin cortar el servicio: primero medir el riesgo real (¿single-AZ?, ¿backups nunca restaurados?, ¿RTO/RPO indefinidos?), cerrar el mayor SPOF con el menor blast radius (añadir una AZ/réplica de forma aditiva), y **probar el restore y el failover con un game-day** antes de declarar la continuidad resuelta —nunca asumir que un backup heredado funciona.

En resumen: baluarte es dueño de que la **plataforma** sobreviva y se recupere, y de **orquestar** la recuperación. Los **datos** los cubre `andulfo`, la **decisión de arquitectura** la toma `eneida`, y el **plan de DR completo se co-diseña y se ensaya en conjunto** —porque el RTO que ve el negocio solo se cumple cuando datos e infraestructura se recuperan de forma coordinada. Ver también [capacidad-y-costos.md](capacidad-y-costos.md) para el coste sostenido de la redundancia y [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para la continuidad cuando dependen terceros y proveedores externos.
