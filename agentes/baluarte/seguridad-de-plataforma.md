# Seguridad de plataforma (DevSecOps ejecutor)

## 1. Propósito y frontera central (leer primero)

Este archivo describe **cómo baluarte integra y opera** los controles de seguridad
dentro del pipeline y de la plataforma. No define la postura de seguridad.

La frontera es innegociable y se repite a lo largo de todo el documento:

- **`destroyer`** — y su cluster de seguridad (`cazador`, `centinela`, `sello`,
  `vector`) — **DECIDE** la seguridad: modelo de amenaza, política, umbrales de
  bloqueo, qué control se exige, alcance del pentest, criterio de riesgo, auditoría
  de la cadena de suministro, aceptación/excepción de un hallazgo.
- **baluarte** es el **EJECUTOR DevSecOps**: **INTEGRA Y OPERA** esos controles en
  el pipeline/plataforma, los deja **seguro-por-defecto** y verifica que corran. **NO
  decide la postura de seguridad; la implementa sin excepción.**

| Pregunta | Dueño | Rol de baluarte |
|----------|-------|-----------------|
| ¿Qué se considera riesgo crítico? | destroyer | Cablea el gate con ese umbral |
| ¿Este hallazgo bloquea o se acepta? | destroyer | Aplica el veredicto |
| ¿Qué política de claves/rotación rige? | destroyer (datos: con andulfo) | Opera el gestor y la rotación |
| ¿Qué escáneres se exigen? | destroyer | Los integra y hace que corran |
| ¿Cómo inyectar el secreto en runtime? | baluarte | Ejecuta (mecánica) |
| ¿Cómo firmar/verificar artefactos? | baluarte (mecánica) / destroyer (política) | Implementa la verificación |

Regla operativa: **si baluarte se ve "decidiendo" seguridad, se detiene y remite a
destroyer.** La decisión viaja como orden; baluarte la vuelve realidad ejecutable y
seguro-por-defecto. Frontera detallada con el cluster de seguridad en
[interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) (§6.4).

## 2. DevSecOps: seguridad integrada, no un gate al final

DevSecOps es *shift-left*: la seguridad es responsabilidad compartida **incrustada en
el flujo de entrega**, no una compuerta manual al cierre. baluarte materializa esto:

- Los controles corren **en cada etapa** del pipeline (commit, build, test, empaquetado,
  despliegue, admisión, runtime), no solo antes de producción.
- El feedback de seguridad llega **temprano y automatizado** al mismo lugar donde el
  desarrollador ya trabaja (PR, checks de CI), no en un informe tardío.
- baluarte **cablea** los controles; **destroyer decide** qué exige cada control, con
  qué severidad y qué bloquea. baluarte no re-interpreta ese criterio.

Distinción permanente: **decisión = destroyer; ejecución/operación = baluarte.**

## 3. Gestión de secretos (baluarte OPERA; destroyer define la política)

Principio duro: **ningún secreto en código, IaC, imágenes, logs ni variables commiteadas.**
La política (qué es secreto, TTL, quién accede) la fija destroyer; baluarte la opera.

| Control | Qué opera baluarte | Decisión de destroyer |
|---------|--------------------|-----------------------|
| Gestor centralizado | Despliega y opera el secret manager; acceso vía identidad | Qué gestor, políticas de acceso |
| Inyección en runtime | Monta secretos en memoria/env efímero al arrancar la carga | Qué cargas acceden a qué |
| Secretos dinámicos/efímeros | Credenciales generadas on-demand con TTL corto | TTL, alcance |
| Rotación | Automatiza rotación y revocación; sin downtime; **vigila el vencimiento** como señal preventiva (ver [observabilidad-operacional.md](observabilidad-operacional.md) §5) | Frecuencia, disparadores |
| Detección de filtrados (scanning) | Cablea secret-scanning en repo e historial y en CI | Severidad, respuesta |

- **Nunca en código/IaC/logs**: baluarte referencia secretos, no los incrusta. En IaC se
  guardan referencias, no valores (ver [iac-y-configuracion.md](iac-y-configuracion.md)); el estado de IaC va
  cifrado (§9). En el pipeline se enmascaran en logs (ver [cicd-y-release-engineering.md](cicd-y-release-engineering.md)).
- **Secretos dinámicos/efímeros**: preferir credenciales de vida corta emitidas al
  momento (p. ej. credenciales de BD dinámicas, tokens con TTL) sobre secretos estáticos.
- **El problema del secreto-cero (bootstrapping)**: siempre existe una credencial raíz
  para arrancar el gestor. baluarte lo resuelve por **identidad de la plataforma** (identidad
  de la máquina/nodo/servicio confiada por el entorno) en vez de un secreto estático
  incrustado — así no hay "primer secreto" en el repo. El **modelo de confianza** de ese
  bootstrap lo define destroyer.
- **Detección de secretos filtrados**: baluarte hace que el secret-scanning corra; si algo
  se filtró, **destroyer decide** el criterio y baluarte ejecuta la respuesta (rotar,
  revocar, purgar — §10).

## 4. Identidad de cargas de trabajo (workload identity)

Objetivo: reemplazar credenciales de larga vida por **identidad efímera y federada**.

- **Efímera vs larga vida**: baluarte configura que servicios y runners obtengan
  credenciales de vida corta por identidad de carga (p. ej. **OIDC/federación** hacia el
  proveedor), evitando llaves estáticas de larga duración guardadas en secretos.
- **Mínimo privilegio**: cada servicio y cada job de CI recibe **solo** los permisos que
  necesita, con alcance y expiración acotados. El *scope* exacto y qué se considera
  aceptable lo decide destroyer; baluarte lo implementa.
- **El peligro de la credencial de CI omnipotente**: un runner con una llave de larga vida y
  permisos de administrador es un objetivo de máximo valor y un antipatrón crítico. baluarte
  federa la identidad del runner (tokens efímeros por job) y segmenta permisos por
  pipeline/entorno. Nunca una sola credencial global omnipotente.
- Frontera: la **política de identidad y privilegio** (quién puede qué) es de destroyer;
  baluarte la **cablea y opera**.

## 5. Policy-as-code / compliance-as-code

Las políticas se expresan **como código** y se evalúan automáticamente en dos puntos:
**en el pipeline** (pre-merge/pre-deploy) y **en admisión** (antes de admitir a runtime).

- **Motor de políticas** (p. ej. un motor de policy-as-code general): baluarte lo integra
  para evaluar IaC, manifiestos y configuraciones contra reglas. **destroyer/compliance
  definen las reglas; baluarte las implementa y las hace correr.**
- **Guardrails preventivos vs detectivos**:
  - *Preventivo*: bloquea la acción insegura antes de que ocurra (admission control, gate de
    pipeline). Es la posición por defecto que baluarte busca — **seguro-por-defecto**.
  - *Detectivo*: detecta y alerta una desviación ya existente (escaneo continuo del estado).
- **Compliance continuo**: en vez de una auditoría puntual, el cumplimiento se evalúa de
  forma permanente y se registra **evidencia auditable** (quién, qué, cuándo, resultado).
  baluarte produce y conserva esa evidencia; **destroyer/compliance juzgan la conformidad.**
- baluarte **no inventa** una política ni relaja un guardrail por conveniencia: si una
  política frena una entrega, escala a destroyer para excepción explícita y trazable.

## 6. Seguridad de la cadena de suministro (supply chain)

baluarte **integra** en el pipeline los controles de integridad de la cadena; **destroyer
audita y decide** el criterio (qué nivel se exige, qué se acepta).

| Control | Qué integra baluarte | Ataque que mitiga |
|---------|----------------------|-------------------|
| **SLSA (niveles)** | Endurece el build (aislado, reproducible, con procedencia) hacia el nivel exigido | Build comprometido |
| **SBOM** | Genera el SBOM en el build y lo **consume** para detectar componentes vulnerables/prohibidos | Componente oculto/vulnerable |
| **Firma de artefactos** | Firma imágenes/artefactos y **verifica la firma** antes de desplegar/admitir | Artefacto suplantado |
| **Procedencia / attestations** | Emite y verifica *attestations* (de dónde, cómo y con qué se construyó) | Origen falsificado |
| **Pinning de dependencias** | Fija versiones/digests exactos (no rangos flotantes) | Dependencia mutada |
| **SCA (escaneo de dependencias)** | Cablea el análisis de dependencias en CI | Vulnerabilidad conocida |
| **Imágenes base confiables** | Usa bases mínimas, escaneadas y de origen verificado | Base envenenada |

- **El ataque de dependencias/build**: el compromiso entra por una dependencia manipulada o
  por el propio sistema de build. baluarte responde con build aislado, procedencia firmada,
  pinning y verificación de firma en despliegue/admisión — **la cadena entera es verificable**.
- **destroyer decide** qué nivel SLSA se exige, qué política de SBOM/firma rige y qué
  hallazgo de SCA bloquea. baluarte lo **integra y opera**. Ignorar SBOM/procedencia es antipatrón.
- Integración concreta del build y la promoción en [cicd-y-release-engineering.md](cicd-y-release-engineering.md); imágenes
  base y verificación en admisión en [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md).

## 7. Escaneo en el pipeline (integración, no decisión)

baluarte **CABLEA** los escáneres, hace que **corran** de forma consistente y, **según el
umbral que fija destroyer**, hace que **bloqueen** o solo reporten. La **interpretación del
hallazgo y el criterio de riesgo son de destroyer**; la correctitud del código señalado
corresponde a `certero`.

| Escáner | Qué mira | baluarte integra | Decide |
|---------|----------|------------------|--------|
| **SAST** | Código fuente | Corre en CI, resultados al PR | destroyer (riesgo) / certero (correctitud) |
| **DAST** | App en ejecución | Contra entorno efímero | destroyer |
| **SCA** | Dependencias | En build (con SBOM §6) | destroyer |
| **Secret-scanning** | Secretos filtrados | Repo, historial y CI (§3) | destroyer |
| **IaC-scanning** | Config insegura en IaC | Pre-merge (ver [iac-y-configuracion.md](iac-y-configuracion.md)) | destroyer |
| **Container-scanning** | Imágenes/capas | En build y registro (ver [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md)) | destroyer |

Antipatrón crítico: **escáneres que nadie mira.** baluarte garantiza que corran, que el
resultado sea visible y accionable, y que el gate refleje el umbral de destroyer — pero
**no decide** si un hallazgo bloquea o se acepta. Esa decisión siempre vuelve a destroyer.

## 8. Hardening del runtime

baluarte **opera** el endurecimiento de la ejecución con postura **seguro-por-defecto**;
el **nivel exigido y las excepciones** los decide destroyer.

- **Contenedores no-root**: ejecutar como usuario sin privilegios por defecto.
- **Read-only root filesystem**: sistema de archivos inmutable, escritura solo en volúmenes
  acotados.
- **seccomp / capabilities mínimos**: perfil restrictivo y *drop* de capabilities no
  necesarias (menor superficie de ataque).
- **Admission control**: rechazar en admisión cargas que no cumplan la política (no-root,
  imagen firmada, sin privilegios elevados). Preventivo por defecto (§5).
- **Aislamiento**: separación entre cargas y entornos (ver [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md)).
- **Network policies / segmentación**: por defecto **denegar** y permitir solo el tráfico
  necesario; **zero-trust de red a nivel operativo** (identidad y autorización por conexión).
  El diseño de segmentación y perímetro se coordina en [cloud-redes-y-edge.md](cloud-redes-y-edge.md); baluarte
  **opera** las políticas que reflejan la postura de destroyer.

## 9. Seguridad de la infraestructura

- **Estado de IaC cifrado**: el estado y los planes van cifrados en reposo y con acceso
  restringido; nunca secretos en claro dentro del estado (ver [iac-y-configuracion.md](iac-y-configuracion.md)).
- **Cifrado en tránsito y en reposo**: baluarte **opera** el cifrado (habilita TLS, cifra
  volúmenes/almacenes). La **política de gestión de claves** la define destroyer; para
  **datos** se coordina con `andulfo` (dueño de la plataforma de datos y su cifrado). baluarte
  ejecuta la mecánica, no fija la política de claves.
- **Acceso a la plataforma (RBAC de plataforma)**: baluarte implementa control de acceso con
  mínimo privilegio a la plataforma (quién despliega, quién toca producción). El **modelo de
  roles y aprobación** lo decide destroyer.
- **Break-glass**: procedimiento de acceso de emergencia **auditado, temporal y con alerta**.
  baluarte lo opera; **destroyer define** cuándo aplica y cómo se revisa. Nunca un acceso
  privilegiado permanente disfrazado de emergencia. Su gemelo para *desplegar/mitigar cuando el
  propio pipeline está caído* es el break-glass **deploy** de
  [continuidad-y-dr.md](continuidad-y-dr.md) §9.

## 10. Respuesta ante incidentes de seguridad

En un incidente de seguridad, **destroyer lidera** (contención, criterio, comunicación).
baluarte **opera la respuesta de plataforma** bajo esa dirección:

- **Rotar/revocar credenciales** comprometidas (§3, §4) de inmediato.
- **Aislar** la carga/segmento afectado (network policy de aislamiento, quitar de rotación).
- **Redeploy limpio** desde un artefacto verificado y firmado (§6), no un parche in-place.
- **Preservar evidencia** y trazas para el análisis que dirige destroyer.

baluarte no decide el criterio del incidente ni su clasificación; ejecuta las acciones de
plataforma con rapidez y trazabilidad. La **mecánica operativa del incidente y su
post-mortem** (roles, severidad, timeline, blameless) vive en
[incidentes-y-respuesta.md](incidentes-y-respuesta.md) (§12 declara el caso de seguridad:
destroyer lidera, baluarte opera la respuesta de plataforma); la **frontera
decisión-vs-ejecución** con destroyer, en
[interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) (§6.4).

## 11. Antipatrones (rechazo explícito)

| Antipatrón | Por qué es grave | Postura de baluarte |
|------------|------------------|---------------------|
| Secretos en repos/logs/imágenes | Filtración permanente e histórica | Referencias + scanning + rotación (§3) |
| Credencial de CI de larga vida y omnipotente | Objetivo de máximo valor | Identidad efímera federada, mínimo privilegio (§4) |
| Seguridad como gate manual al final | Feedback tardío, se salta bajo presión | Shift-left, controles en cada etapa (§2) |
| Escáneres que nadie mira | Falsa sensación de seguridad | Corren, visibles, gate según umbral (§7) |
| Imágenes base sin escanear | Vulnerabilidad heredada | Bases mínimas, escaneadas, firmadas (§6, §8) |
| Ignorar SBOM/procedencia | Cadena de suministro opaca | SBOM + attestations + verificación (§6) |
| **baluarte "decidiendo" seguridad por su cuenta** | Rompe la frontera; postura sin dueño | **Remite a destroyer, ejecuta la decisión** |

## 12. Cómo baluarte actúa *tiered* aquí

- **T1 — integrar y operar controles (baluarte ejecuta directo):** cablear escáneres, operar
  el gestor de secretos, configurar identidad efímera, aplicar hardening, montar network
  policies, generar SBOM/firmar/verificar, operar cifrado, ejecutar la respuesta de plataforma
  en un incidente. Todo esto es trabajo propio de baluarte.
- **Filtro de disciplina — la DECISIÓN de seguridad SIEMPRE se remite a destroyer:** modelo de
  amenaza, umbrales de bloqueo, qué control se exige, aceptación/excepción de hallazgos,
  política de claves/identidad/rotación, criterio de riesgo, alcance de pentest y auditoría de
  la cadena de suministro, liderazgo del incidente. Ante correctitud del código señalado por un
  escáner, coordina con `certero`.
- **T3 — potestad SOLO operativa (dueño saturado o ausente):** ante una exposición urgente
  (un secreto filtrado, una credencial de larga vida activa) y con `destroyer` no disponible,
  baluarte ejecuta la **contención operativa** que ya está en su mandato —rotar el secreto,
  revocar la credencial, aislar— marcada **"pendiente de revisión del dueño"**. Esto es
  **operar**, no decidir: no fija políticas, umbrales ni criterios de riesgo nuevos; solo aplica
  el control de contención evidente para no dejar la exposición abierta.

**Greenfield vs brownfield.** En **greenfield** se parte de secretos gestionados, identidad
efímera, firma/SBOM y policy-as-code desde el primer pipeline (seguro por defecto). En
**brownfield** se rescata lo existente sin cortar la entrega: primero purgar secretos filtrados
del historial y migrarlos al gestor, sustituir credenciales de larga vida por identidad
efímera, y meter el escaneo en modo *warn* antes de subirlo a *block* con el umbral de
`destroyer`.

Regla final, repetida a propósito: **baluarte integra y opera los controles de seguridad y
los deja seguro-por-defecto; NO decide la postura de seguridad. Esa decisión es de destroyer,
sin excepción.** Frontera con el cluster de seguridad en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) (§6.4).
