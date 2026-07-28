# CI/CD y release engineering

Este satélite define cómo baluarte diseña, opera y endurece la cadena que convierte un commit en valor desplegado de forma **rápida, segura, repetible y reversible**. Es el paved road: el camino pavimentado que baluarte construye y mantiene para que cada equipo entregue sin reinventar el pipeline. baluarte opera con neutralidad tecnológica total: los ejemplos citan alternativas de ecosistemas distintos ("p. ej.") sin favorecer vendor alguno.

## 1. Fundamentos: CI, CD y el objetivo real

**Integración continua (CI)**: cada cambio se integra a la línea principal con frecuencia (idealmente varias veces al día) y se valida automáticamente (build + gates). Su enemigo es la rama que vive semanas y el "merge day" doloroso.

**Continuous Delivery vs Continuous Deployment** — dos "CD" que se confunden y no son lo mismo:

| Término | Significado | Quién decide el paso a prod |
|---|---|---|
| Continuous **Delivery** | Todo cambio queda **siempre desplegable**; artefacto probado y listo. El paso a producción es un botón. | Humano/aprobación (o gate político) |
| Continuous **Deployment** | Todo cambio que pasa los gates va a producción **automáticamente**, sin intervención manual. | El pipeline (gates automáticos) |

El objetivo no es "hacer CI/CD" como fin, sino **reducir el lead time for changes** (tiempo de commit a producción) moviendo **cambios pequeños y frecuentes**, porque el tamaño del lote es el predictor de riesgo: lotes pequeños fallan menos y se diagnostican más rápido.

**Trunk-based vs feature branches — con criterio, no religión**:

| Modelo | Cuándo encaja | Costo/riesgo |
|---|---|---|
| Trunk-based (ramas de vida < 1 día, feature flags) | Equipos con buena cobertura de tests, despliegue continuo, alta madurez | Exige disciplina de flags y CI veloz |
| Feature branches cortas + PR | Equipos medianos, revisión obligatoria, cumplimiento | Riesgo de drift si la rama vive días |
| GitFlow / release branches largas | Software versionado on-prem, múltiples versiones soportadas en paralelo | Alto costo de merge; lead time largo |

baluarte recomienda por **contexto de madurez y modelo de release**, no por moda. En greenfield empuja trunk-based + flags; en brownfield con release branches largas, primero acorta la vida de las ramas y automatiza el merge antes de proponer trunk-based.

## 2. Anatomía de un pipeline

Etapas canónicas, ordenadas para **fail-fast** (lo barato y lo que más falla, primero):

| Etapa | Propósito | Nota de propiedad |
|---|---|---|
| Checkout + resolución de deps | Traer código y dependencias pinneadas | baluarte |
| Build / compile | Producir binario/imagen determinista | baluarte |
| Gates de calidad de código | lint, type-check, format, análisis estático | baluarte **opera**; la correctitud es de `certero` |
| Tests (unit → integración → e2e) | Ejecutar la suite | baluarte **provee el CI y ejecuta**; el diseño/cobertura es de `amado` |
| Escaneo de seguridad | SAST, deps, secretos, escaneo de imagen | baluarte **integra**; qué/política la decide `destroyer` (ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)) |
| Empaquetado + SBOM | Artefacto inmutable + inventario | baluarte |
| Publicación de artefacto | Push a registry versionado | baluarte |
| Despliegue | Rollout a un entorno | baluarte (paved road); config de UN servicio es de su dueño, p. ej. `motor` |
| Verificación post-deploy | Smoke, health, canary analysis | baluarte |

Principios transversales:
- **Fail-fast**: aborta en el primer gate barato que falle; no gastes 40 min de e2e si el lint ya rompió.
- **Paralelización**: fan-out de jobs independientes (p. ej. matriz de plataformas, shards de tests) y fan-in antes de publicar.
- **Caché**: de dependencias y de capas de build (p. ej. cache de módulos, cache de capas de contenedor, cache remoto de build). La caché debe ser **correcta o no existir**: una caché envenenada es peor que ninguna; clave la caché por hash del lockfile/inputs.
- **Idempotencia**: reejecutar una etapa con los mismos inputs produce el mismo resultado; nada de efectos acumulativos ocultos.

## 3. Build reproducible / hermético

Un build es **hermético** si depende solo de inputs declarados (no de la red viva, la hora, el usuario, ni el estado de la máquina) y **reproducible** si los mismos inputs producen bit a bit el mismo output.

Palancas:
- **Pinning total**: versiones exactas + lockfile commiteado; nada de rangos flotantes (`^`, `latest`, `:latest`). Digest inmutable de imágenes base (p. ej. referencia por `@sha256:` en lugar de tag móvil).
- **Fuentes de dependencias controladas**: proxy/mirror interno de paquetes para no depender de la disponibilidad ni de la mutabilidad de un registro público.
- **Builds cacheables y deterministas**: eliminar timestamps embebidos, orden estable de archivos, `SOURCE_DATE_EPOCH` o equivalente; separar capas que cambian poco (deps) de las que cambian mucho (código fuente).
- **SBOM** (Software Bill of Materials, p. ej. formato SPDX o CycloneDX) generado en el build y adjunto al artefacto, base para escaneo y respuesta ante vulnerabilidades. La **política** de qué se hace con el SBOM es de `destroyer` (ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)); baluarte garantiza que **se genera y viaja con el artefacto**.

Un build reproducible es la precondición de la trazabilidad y de la respuesta a incidentes de supply chain: si no puedes reconstruir el binario, no puedes auditarlo.

## 4. Gestión de artefactos y versionado

Regla de oro: **build once, deploy many**. El artefacto se construye **una vez**, se prueba, y ese **mismo** artefacto se promueve por los entornos. Reconstruir por entorno rompe la garantía (build de staging ≠ build de prod).

| Principio | Detalle |
|---|---|
| Inmutabilidad | Un artefacto publicado nunca se sobrescribe. Nada de reusar un tag; cada build es un objeto nuevo. |
| Registry versionado | Repositorio de artefactos/imágenes con retención y control de acceso (p. ej. registro de contenedores, registro de paquetes, almacén de binarios). |
| Promoción | El mismo artefacto avanza dev → staging → prod cambiando solo **configuración**, no el binario. |
| Versionado | **SemVer** para APIs/librerías con contrato público; versión por **commit/hash** (o `git describe`) para trazabilidad absoluta build→commit. Combinar: `1.4.2+sha.abc123`. |
| Retención | Política de expiración por antigüedad/uso; conservar lo que esté desplegado o sea rollback-target. |

Ver [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md) para inmutabilidad de imágenes y digests, y [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para federación de registries entre organizaciones.

## 5. Deployment vs Release — desacoplar es la clave

Distinción central del release engineering moderno:

- **Deployment**: poner el binario en producción (el código corre en los servidores).
- **Release**: activar la funcionalidad para los usuarios (el código produce efecto observable).

Desacoplarlos permite desplegar de día, con tráfico, sin exponer nada, y **activar** la función cuando el negocio decida, gradualmente y con rollback instantáneo **sin redesplegar**.

**Feature flags como mecanismo de release** — distinguir dos naturalezas de flag:

| Tipo de flag | Propósito | Vida | Dueño de la decisión |
|---|---|---|---|
| Flag de **release** | Activar/desactivar una funcionalidad nueva, rollout gradual, kill-switch | Corta; se retira tras estabilizar | Producto + baluarte (mecanismo) |
| Flag de **configuración/operación** | Ajuste operativo permanente (límites, toggles de integración) | Larga/permanente | Operación / dueño del servicio |

baluarte provee el **mecanismo** (SDK/servicio de flags, evaluación segura, defaults a prueba de fallos, higiene de flags muertos). El **qué** activar y a quién es de producto y del dueño del servicio. Un flag olvidado es deuda: baluarte instrumenta inventario y caducidad de flags de release.

## 6. Estrategias de despliegue

| Estrategia | Cómo funciona | Cuándo usar | Riesgo | Costo |
|---|---|---|---|---|
| **Recreate** | Apagar versión vieja, levantar nueva | Dev/entornos sin SLA; apps que no toleran dos versiones a la vez | Alto (downtime) | Bajo |
| **Rolling** | Reemplazo gradual de instancias | Default sensato para servicios stateless con health checks | Medio (dos versiones conviven) | Bajo |
| **Blue-green** | Dos entornos completos; conmutar tráfico de golpe | Rollback instantáneo, cutovers de BD controlados | Bajo en rollout, alto en coste | Alto (doble infra) |
| **Canary** | Enviar un % pequeño de tráfico a la nueva versión, observar, ampliar | Servicios con buen tráfico y buenas métricas | Bajo si hay observabilidad | Medio |
| **Shadow / dark launch** | Duplicar tráfico real a la nueva versión **sin** servir su respuesta | Validar carga/comportamiento sin riesgo al usuario | Muy bajo (usuario no afectado) | Medio/alto (doble cómputo) |
| **A/B a nivel infra** | Enrutar por cohorte para comparar variantes | Experimentación con dimensión de negocio | Bajo | Medio |

**Progressive delivery**: el canary **automatizado** por métricas/SLO. El pipeline promueve o revierte el canary según señales objetivas (tasa de error, latencia p99, saturación) en lugar de la intuición de un humano mirando un dashboard. Requiere observabilidad sólida (ver [observabilidad-operacional.md](observabilidad-operacional.md)) y umbrales derivados de los SLO (ver [confiabilidad-sre.md](confiabilidad-sre.md)). El **rendimiento/percentiles** que alimentan el análisis los define y juzga `peakformance`; baluarte **orquesta** la promoción/aborto en el pipeline, no dictamina si un p99 es aceptable.

### 6.1 Entrega client-side (móvil, escritorio, embebido, extensiones)

Todas las estrategias anteriores asumen que **controlas la flota** de instancias (servidores). Cuando el artefacto corre en un **cliente que no controlas tras el envío** —una app en una tienda, un binario de escritorio instalado, firmware embebido, una extensión— las reglas cambian: **no hay rollback de binario**. Una vez que una versión está "en la naturaleza", no puedes revertirla en el dispositivo del usuario; solo puedes **empujar hacia adelante** una versión nueva que el usuario debe adoptar. baluarte es dueño de esta **entrega** (no `farola`/`motor`, que construyen el cliente); sus palancas:

| Palanca client-side | Qué resuelve |
|---|---|
| **Staged rollout por tienda** | Liberar a un % creciente de usuarios (p. ej. 1%→10%→100%) y **halt** si suben crashes/errores; es el "canary" del mundo cliente, gobernado por la consola de la store, no por tu balanceador |
| **Server-driven config / feature flags** | El **release** se controla desde el servidor aunque el binario ya esté instalado: la funcionalidad se activa/desactiva remotamente (desacople deployment↔release llevado al cliente). Es el sustituto del rollback: **kill-switch remoto** de una feature rota |
| **Forced-update / kill-switch de versión** | Poder **obligar** a actualizar (o bloquear) versiones de cliente con un bug crítico o incompatibilidad de seguridad, comunicándolo desde el servidor |
| **Compatibilidad hacia atrás del backend con N versiones de cliente** | Como conviven muchas versiones de cliente "en la naturaleza", el backend debe **soportar las versiones antiguas** durante su ventana de vida (versionado de API, nunca romper el contrato que usa una versión aún instalada). Es la restricción más dura: el servidor no controla cuándo el usuario actualiza |
| **Release trains** | Cadencia fija y predecible de releases (p. ej. cada 2–4 semanas) porque el ciclo de revisión/publicación de la store no es instantáneo ni reversible |
| **Firma / notarización** | Firmar y (según plataforma) notarizar el artefacto para que la tienda/OS lo acepte; la **política** de firma es de `destroyer`, baluarte la **opera** (ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)) |

Frontera: `farola`/`motor` construyen el cliente y su lógica; baluarte es dueño del **camino de entrega** (pipeline de build de cliente, staged rollout, config remota, gestión de compatibilidad de API con las versiones vivas). El **objetivo de compatibilidad** (cuántas versiones soportar) se acuerda con `eneida`/producto; baluarte lo opera.

## 7. Rollback y roll-forward

Todo despliegue debe tener una salida planificada **antes** de ejecutarse.

- **Rollback**: volver al artefacto anterior conocido-bueno. Barato y confiable **si** el artefacto es inmutable y la migración de datos es compatible.
- **Roll-forward**: arreglar hacia adelante con un nuevo despliegue. Preferible cuando el rollback es más riesgoso que avanzar (p. ej. cambios de esquema ya aplicados).
- **Auto-rollback por SLO burn**: el pipeline revierte automáticamente si el **error budget** se consume a una tasa peligrosa durante el rollout (ver [confiabilidad-sre.md](confiabilidad-sre.md)). Esto exige que rollback esté **probado** en no-prod: un rollback nunca ejecutado no existe.

**Compatibilidad de esquema — expand/contract (expandir-contraer)** para migraciones de BD sin downtime:

1. **Expand**: añadir lo nuevo (columna/tabla) de forma retrocompatible; el código viejo sigue funcionando.
2. **Migrar/backfill**: poblar datos; desplegar código que escribe en ambos formatos.
3. **Contract**: una vez que ninguna versión desplegada usa lo viejo, eliminarlo.

Esto permite que **dos versiones del código convivan** (imprescindible para rolling/canary/blue-green) y que el rollback no rompa. **Matiz de propiedad**: la *física* de datos —diseño de la migración, índices, integridad, performance de la migración, RPO/RTO— es de `andulfo`; baluarte **orquesta la compatibilidad del despliegue**: exige que las migraciones sean retrocompatibles, las secuencia en el pipeline (separadas del deploy de código) y garantiza que ninguna etapa rompa a la versión que aún corre.

## 8. Gates del pipeline

| Gate | Qué valida | Automático/Manual |
|---|---|---|
| Quality gate | lint/type/test/cobertura mínima verdes | Automático (baluarte opera; correctitud de `certero`) |
| Security gate | Sin vulnerabilidades sobre umbral, sin secretos | Automático (política de `destroyer`) |
| Performance gate | Sin regresión sobre budget | Automático (budgets de `peakformance`) |
| **Error budget gate** | Si el budget de fiabilidad está agotado, se **congela** el despliegue de features y solo pasan fixes | Automático/política (ver [confiabilidad-sre.md](confiabilidad-sre.md)) |
| Aprobación manual | Cambio de alto riesgo, ventana regulada, cumplimiento | Manual |

**Aprobaciones manuales: cuándo sí, cuándo no.** Sí en cambios irreversibles, regulados o de altísimo impacto. **No** como muleta por falta de confianza en la automatización: una aprobación manual que nadie entiende y todos aprueban en automático es teatro de control, alarga el lead time y no reduce riesgo. La respuesta correcta es mejor cobertura de gates automáticos, no más humanos apretando "aprobar".

## 9. Entornos y paridad

- **dev / staging / prod** con la **máxima paridad** posible (misma forma de infra vía IaC, ver [iac-y-configuracion.md](iac-y-configuracion.md)). La diferencia debe ser **escala y datos**, no arquitectura ni configuración estructural. Drift de entornos = bugs que solo aparecen en prod.
- **Entornos efímeros / preview**: uno por PR/rama, creado on-demand y destruido al cerrar. Aceleran revisión y validan el propio IaC en cada cambio (ver [iac-y-configuracion.md](iac-y-configuracion.md) y [capacidad-y-costos.md](capacidad-y-costos.md) por el costo de efímeros).
- **Datos de prueba**: sintéticos o anonimizados; nunca PII de producción en no-prod sin enmascaramiento. La estrategia de datos de prueba se coordina con `amado` (diseño) y `andulfo`/`destroyer` (enmascaramiento y cumplimiento).

## 10. Pipeline seguro (integración, no política)

baluarte **integra** los controles; la **política** (qué escanear, qué bloquea, qué severidad) la decide `destroyer` (ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).

- **Secretos fuera del código y del repo**: gestor de secretos / bóveda; nada de credenciales en el YAML del pipeline ni en variables commiteadas. Escaneo de secretos como gate.
- **OIDC / identidad efímera vs credenciales de larga vida**: el runner obtiene un token **de corta duración** por federación de identidad (p. ej. OIDC del proveedor de CI hacia el proveedor de nube) en lugar de una clave estática de larga vida guardada en el sistema de CI. Elimina el secreto más peligroso: la credencial permanente robable.
- **Menor privilegio del runner**: cada job recibe solo los permisos que necesita, con alcance por entorno; el runner que despliega a prod no es el mismo rol que corre lint. Aislar runners por sensibilidad de entorno.
- **Integridad de la cadena**: firmar artefactos y verificar firma antes de desplegar; procedencia/attestation del build. baluarte lo instrumenta; el estándar lo fija `destroyer`.

## 11. Métricas del pipeline

**DORA** como norte de rendimiento de entrega:

| Métrica DORA | Qué mide |
|---|---|
| Deployment frequency | Con qué frecuencia se despliega a prod |
| Lead time for changes | Commit → producción |
| Change failure rate | % de despliegues que causan degradación |
| Time to restore (MTTR) | Cuánto se tarda en recuperar de un fallo |

Métricas operativas propias del pipeline que baluarte vigila:
- **Tiempo total de pipeline** (y por etapa) — un CI lento mata la frecuencia; optimizar el camino crítico.
- **Flakiness** — % de fallos no deterministas; un pipeline flaky entrena al equipo a ignorar rojos (la *detección* de flakiness la lidera `amado`; baluarte da la infra de reintentos controlados y quarantine, sin ocultar el problema).
- **MTTR del pipeline roto** — cuánto vive la línea principal en rojo; debe ser minutos, no horas.

## 12. Antipatrones

| Antipatrón | Por qué duele | Contramedida |
|---|---|---|
| **Snowflake deploys** | Cada entorno/deploy es único y hecho a mano; irreproducible | IaC + build once, deploy many |
| **"Prohibido desplegar los viernes"** | Parche cultural que **oculta** que el rollback no es confiable | Arreglar rollback y confianza, no prohibir días |
| **Pipeline irreproducible localmente** | Nadie puede depurar el CI sin pushear y rezar | Etapas ejecutables local/contenedor; paridad de build |
| **Rollback no probado** | Se descubre roto en plena crisis | Ensayar rollback en cada release/gameday |
| **Big-bang releases** | Lote enorme, riesgo enorme, diagnóstico imposible | Cambios pequeños, flags, progressive delivery |
| **Gates manuales de teatro** | Aprobación automática mental; alarga lead time sin reducir riesgo | Sustituir por gates automáticos reales |

## 13. Greenfield, brownfield e híbrido

- **Greenfield**: instaurar desde el día uno trunk-based + flags + build once + entornos efímeros + gates automáticos. Barato hacerlo bien ahora, caro retrofit.
- **Brownfield**: no reescribir el pipeline de golpe. Secuencia típica: (1) hacer el build reproducible y versionado, (2) meter el artefacto en un registry inmutable, (3) automatizar rollback y probarlo, (4) acortar la vida de las ramas, (5) introducir canary/flags. Cada paso reduce riesgo aisladamente.
- **Híbrido** (parte en nube, parte on-prem/edge, o multi-equipo con madurez desigual): un **plano de control de entrega común** con paved roads por tipo de destino; la promoción de artefactos cruza fronteras vía registries federados (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)). No fuerces continuous deployment donde el destino no lo tolera; entrega **continuous delivery** con activación controlada.

## 14. Cómo actúa baluarte aquí (modelo tiered)

- **T1 — implementa directo**: la **infraestructura del pipeline**, las etapas, la caché, la gestión de artefactos, la estrategia de despliegue, el mecanismo de flags y el **rollback**. Esto es identidad central de baluarte y lo construye y opera él mismo.
- **T2 — entrega a su dueño**: la **configuración de despliegue de un servicio concreto** (variables, recursos, healthchecks específicos) se entrega como **plantilla/paved road** al dueño del servicio (p. ej. `motor` para un servicio backend), que la particulariza. baluarte da el pipeline y el estándar; el dueño llena su config (ver [plantillas.md](plantillas.md) y [checklists.md](checklists.md)).
- **T3 — potestad (dueño saturado o ausente)**: si un cambio de entrega que toca a un servicio con dueño es urgente (p. ej. cablear su rollback o su gate) y el dueño está saturado o no existe, baluarte lo implementa **directo, reversible y marcado "pendiente de revisión del dueño"**, sin alterar la lógica del servicio.

**Fronteras que baluarte respeta**: no diseña los tests (`amado`), no juzga el bug (`certero`), no fija la política de seguridad (`destroyer`), no dictamina los percentiles de rendimiento (`peakformance`) ni la física de datos (`andulfo`). baluarte es el dueño de que el cambio **llegue** a producción de forma rápida, segura y reversible — no del contenido de cada disciplina que el pipeline orquesta.

Ver también [confiabilidad-sre.md](confiabilidad-sre.md) para SLO/error budgets que alimentan los gates, [observabilidad-operacional.md](observabilidad-operacional.md) para las señales del progressive delivery, y [checklists.md](checklists.md)/[plantillas.md](plantillas.md) para el material operativo listo para usar.
