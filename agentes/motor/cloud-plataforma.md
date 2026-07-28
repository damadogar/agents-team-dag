# cloud-plataforma.md — Empaquetar, desplegar y operar (implementación)

> Para **construir y entregar** lo que codificas: contenedores, IaC, pipelines y
> estrategias de release. **La plataforma objetivo (VM/PaaS/K8s/serverless) la
> decide el arquitecto**; la tabla §1 es para que entiendas la elección e
> implementes acorde (Dockerfiles, manifiestos, CI). Si es inadecuada, escálalo.

## 1. Modelos de cómputo (el arquitecto elige; entiende cada uno)

| Modelo | Úsalo cuando | Riesgos |
|--------|--------------|---------|
| **VMs / IaaS** | Control total, cargas legacy, requisitos específicos de SO | Tú operas todo (parches, escalado) |
| **PaaS gestionado** (App Service, Cloud Run, Elastic Beanstalk, Heroku, Fly) | Quieres entregar rápido sin operar infra; cargas web típicas | Menos control; límites de la plataforma |
| **Contenedores + orquestador** (Kubernetes, ECS) | Múltiples servicios, portabilidad, control de escalado, equipo con capacidad ops | Complejidad operativa real (K8s) |
| **Serverless / FaaS** (Lambda, Functions, Cloud Functions) | Cargas espigadas/variables, event-driven, ops mínima, pago por uso | Cold start, límites de ejecución/tamaño, lock-in, debugging |
| **Serverless containers** (Cloud Run, Fargate) | Quieres contenedores sin operar nodos | Menos control de red/afinidad |

Heurística: **empieza por lo gestionado** (PaaS/serverless/serverless-containers).
Adopta Kubernetes cuando la escala, portabilidad multi-nube o densidad lo
justifiquen **y** exista capacidad operativa (plataforma/SRE).

## 2. Contenedores (buenas prácticas)

- Imágenes **mínimas** (distroless/alpine con cuidado), **multi-stage builds**,
  pin de versiones, capas cacheables.
- **No root**, FS read-only, drop capabilities, `HEALTHCHECK`, señales para
  *graceful shutdown* (SIGTERM).
- **Escaneo** (Trivy/Grype), **SBOM** (Syft), **firma** (cosign), registro
  privado. Sin secretos en la imagen.
- Configuración por **variables de entorno / config externa** (12-Factor).

## 3. Kubernetes (si está justificado)

- **Workloads**: Deployment (stateless), StatefulSet (estado), Job/CronJob,
  DaemonSet.
- **Recursos**: define `requests`/`limits` (evita OOM/noisy neighbor); HPA/VPA/
  KEDA para autoscaling; PodDisruptionBudgets.
- **Salud**: liveness/readiness/startup probes correctos; `terminationGracePeriod`.
- **Config/secretos**: ConfigMap/Secret (cifrado en reposo + KMS), External
  Secrets Operator hacia un vault.
- **Red/seguridad**: NetworkPolicies (deny por defecto), RBAC mínimo, Pod
  Security Standards, namespaces por entorno/equipo.
- **Entrega**: Helm/Kustomize; **GitOps** (Argo CD/Flux) como fuente de verdad.
- **No adoptes K8s** por moda: si tienes 1-3 servicios, un PaaS te dará más
  velocidad con menos riesgo.

## 4. Infraestructura como código (IaC)

- **Declarativa y versionada**: Terraform/OpenTofu (multi-nube), Pulumi (código),
  CloudFormation/Bicep/CDK (nativo). Un solo estilo por organización.
- **Estado remoto** con locking; **módulos** reutilizables; entornos por
  workspace/carpeta; `plan` revisado antes de `apply`.
- **Inmutabilidad**: reconstruir > parchear. **Drift detection**.
- Políticas como código (OPA/Conftest, Sentinel) para gobernanza.

## 5. Networking e IAM (cloud)

- **VPC/subnets** públicas/privadas, NAT, security groups/firewalls mínimos,
  endpoints privados a servicios gestionados.
- **IAM least-privilege**, roles efímeros, federación OIDC (sin llaves de larga
  vida en CI), separación de cuentas por entorno (blast radius).
- **Service-to-service**: private networking + mTLS/mesh; no expongas servicios
  internos públicamente.

## 6. CI/CD

- **CI**: build reproducible, lint, tests (unit/integration/contract), SAST/SCA,
  escaneo de imagen y secretos, artefacto versionado e inmutable. Pipeline rápido
  (paraleliza, cachea).
- **CD**: promoción por entornos (dev→staging→prod) con gates; aprobación manual
  donde el riesgo lo exija; trazabilidad commit→artefacto→deploy.
- **Principios DORA** (*deployment frequency*, *lead time*, *change failure rate*,
  *MTTR*): son métricas de equipo que gobierna el arquitecto/líder; tú contribuyes
  con despliegues pequeños y frecuentes y pipelines rápidos.

## 7. Estrategias de despliegue

| Estrategia | Idea | Cuándo |
|------------|------|--------|
| **Rolling** | Reemplazo gradual de instancias | Default simple |
| **Blue-Green** | Dos entornos; switch instantáneo; rollback inmediato | Releases críticos; costo de doble infra |
| **Canary** | % creciente de tráfico a la nueva versión con métricas | Validar en prod con bajo riesgo |
| **Feature flags** | Desacopla deploy de release; activa por segmento | Experimentos, kill-switch, rollout gradual |
| **Shadow/dark launch** | Envía tráfico espejo sin afectar respuesta | Validar rendimiento/correctness sin riesgo |

- **Rollback** siempre disponible y probado. Migraciones de DB compatibles
  (expand/contract) para poder revertir el código — ver
  [datos-persistencia.md](datos-persistencia.md).
- Automatiza rollback por SLO (si error budget se quema, revierte).

## 8. Entornos y configuración (12-Factor)

- Paridad dev/prod razonable; config en el entorno; backing services como
  recursos enchufables; procesos stateless; logs como streams; build/release/run
  separados.
- Gestión de feature flags y de configuración dinámica (con auditoría).

## 9. Multi-nube / lock-in

- **Lock-in no es malo per se**: los servicios gestionados aceleran. Decide
  conscientemente. Abstrae solo lo que cambie de verdad (almacenamiento de
  objetos, colas) si necesitas portabilidad real.
- Multi-nube añade complejidad enorme; adóptalo por requisito (regulatorio,
  resiliencia, negociación), no por miedo.

## 10. Platform engineering (lo define el arquitecto/plataforma; consúmelo)

> El diseño de la plataforma interna es del arquitecto/equipo de plataforma. Como
> desarrollador, **consume los golden paths** y aprovecha el autoservicio; si
> faltan o estorban, da feedback.

- **Golden paths** y plantillas (scaffolding): úsalos para entregar rápido y seguro.
- **IDP (Internal Developer Platform)**/portal (Backstage): autoservicio.
- Aprovecha la observabilidad, seguridad y CI/CD estandarizadas por defecto.

## 11. Checklist de plataforma

```
- [ ] Modelo de cómputo confirmado (lo elige el arquitecto); implemento acorde
- [ ] Imágenes mínimas, no root, escaneadas/firmadas, SBOM, sin secretos
- [ ] IaC declarativa, versionada, estado remoto con lock, plan revisado
- [ ] IAM least-privilege; OIDC federado en CI; cuentas separadas por entorno
- [ ] CI con tests + SAST/SCA + escaneo de imagen/secretos; artefacto inmutable
- [ ] Estrategia de release (canary/blue-green) con rollback probado
- [ ] Migraciones DB compatibles con rollback de código
- [ ] Config 12-Factor; feature flags con kill-switch
- [ ] Observabilidad y alertas de despliegue (DORA + SLO)
```
