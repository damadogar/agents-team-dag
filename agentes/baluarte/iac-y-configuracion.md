# Infraestructura como código (IaC) y gestión de configuración

La infraestructura como código convierte la provisión, el cambio y la recuperación de plataforma en un artefacto versionado, revisable y reproducible. baluarte es dueño de la IaC como práctica operativa: la codifica, la prueba, la aplica y la opera. No decide la topología macro (eso es de `eneida`, que la define; baluarte la CODIFICA), no es dueño del plano de datos (motor y esquema son de `andulfo`; baluarte provisiona la infra que lo soporta) y no fija la política de secretos (la decide `destroyer`; baluarte la OPERA sin hardcodear, ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).

## 1. Qué es IaC y por qué "todo como código"

IaC describe infraestructura, redes, cómputo, almacenamiento, identidades y configuración mediante ficheros versionados, en lugar de acciones manuales en una consola. El principio guía es "todo como código": lo que existe en producción debe poder reconstruirse desde un repositorio.

| Propiedad | Sin IaC (ClickOps) | Con IaC |
|---|---|---|
| Reproducibilidad | Frágil, dependiente de memoria | Determinista desde el repo |
| Revisión | Ninguna o verbal | Pull/Merge Request con diff |
| Auditoría | Logs de nube dispersos | Historial Git + trazabilidad de cambios |
| Recuperación | Reconstrucción manual, lenta | `apply` desde código (parte del DR) |
| Onboarding | Conocimiento tribal | Código autodescriptivo |

Beneficios centrales: **reproducibilidad** (mismo código → mismo entorno), **revisión** (cambios discutidos antes de aplicarse), **auditoría** (quién cambió qué y por qué) y **recuperación** (recrear una plataforma desde cero es un `apply`, no una odisea). La IaC es tanto documentación ejecutable como mecanismo de gobierno.

## 2. Declarativo vs imperativo

Dos paradigmas coexisten:

| Eje | Declarativo (estado deseado) | Imperativo (pasos) |
|---|---|---|
| Qué se expresa | "Quiero N réplicas, esta red, este balanceador" | "Crea la red, luego el balanceador, luego escala" |
| Motor | Calcula el diff y converge | Ejecuta la secuencia que escribes |
| Idempotencia | Nativa (reaplicar no daña) | Debes garantizarla tú |
| Reordenamiento | El motor resuelve dependencias | Orden manual y frágil |
| Ejemplos de enfoque | p. ej. motores de estado deseado tipo definición de recursos, manifiestos declarativos de orquestador, plantillas de nube declarativas | p. ej. scripts procedurales, SDKs de nube en un lenguaje de propósito general, playbooks de pasos |

**Convergencia/idempotencia** es el corazón de lo declarativo: aplicar el mismo código repetidamente lleva al mismo estado sin efectos acumulativos. Regla práctica: preferir declarativo para la forma de la infraestructura (topología, recursos duraderos) e imperativo solo para orquestaciones puntuales, migraciones one-shot o pegamento que ningún motor declarativo modela bien. Muchos ecosistemas ofrecen "IaC en lenguaje de propósito general" que es imperativa en la escritura pero declarativa en la ejecución: lo mejor de ambos si se disciplina.

## 3. Infraestructura inmutable vs mutable y config drift

En infraestructura **mutable** los servidores se parchean, actualizan y editan en vivo; con el tiempo divergen entre sí y del código: eso es **config drift**. En infraestructura **inmutable** no se parchea: se construye una nueva imagen/artefacto y se **reemplaza** la instancia entera.

- **Golden images**: imágenes base versionadas y horneadas (con toda la config y dependencias) que se despliegan idénticas. El cambio produce una imagen nueva, no un parche en caliente.
- **Phoenix servers**: servidores que se destruyen y renacen periódicamente desde cero, garantizando que ningún estado manual sobreviva.
- **Reemplazar en vez de parchear**: elimina la deriva por construcción; cada despliegue parte de un estado conocido.

| Aspecto | Mutable | Inmutable |
|---|---|---|
| Cambio | Parche in situ | Reemplazo de artefacto |
| Drift | Acumulativo | Estructuralmente eliminado |
| Rollback | Reversión manual | Redesplegar imagen previa |
| Depuración | "Copo de nieve" único | Reproducible desde imagen |

La inmutabilidad se apoya en contenedores y orquestación (ver [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md)) pero aplica también a VMs e imágenes de máquina.

## 4. Detección y remediación de drift

**Drift** es toda divergencia entre el estado declarado en el código y el estado real de la plataforma: alguien tocó la consola, un proceso automático mutó un recurso, o un `apply` falló a medias.

Cómo detectarlo:
- **Plan/diff periódico**: ejecutar en modo solo-lectura el cálculo de diferencias del motor de IaC y alertar si hay delta.
- **Reconciliación continua** en modelos GitOps: un controlador compara sin cesar deseado vs real.
- **Auditoría de la nube**: correlacionar cambios fuera de banda con eventos de la plataforma.

Remediación:
- **Reconciliar hacia el código**: reaplicar para devolver la realidad al estado declarado (asumiendo que el código es la verdad).
- **Absorber al código** solo si el cambio manual era legítimo: importarlo y versionarlo, nunca dejarlo huérfano.
- **Prohibir ClickOps en prod**: cambios manuales en producción quedan vetados por política; toda modificación entra por PR. Los permisos de escritura interactiva se restringen (romper-cristal auditado para emergencias, ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).

## 5. GitOps

GitOps eleva Git a **fuente de verdad** operativa: el estado deseado de la plataforma vive en un repositorio y un agente lo **reconcilia continuamente** contra la realidad.

| Modelo | Push | Pull |
|---|---|---|
| Quién aplica | Un pipeline externo empuja cambios | Un agente dentro del entorno tira del repo |
| Credenciales | El pipeline necesita acceso al entorno | El entorno lee el repo (menor exposición) |
| Drift | Se corrige en el próximo push | Se corrige de forma autónoma y continua |
| Ejemplos de enfoque | p. ej. pipeline de CI que ejecuta el `apply` | p. ej. controlador reconciliador residente en el clúster |

Prácticas clave:
- **Separar repos de app vs config**: el código de aplicación y las definiciones de despliegue/infra viven separados, con ciclos de vida y permisos distintos.
- **PR-based ops**: operar es abrir un PR; el merge dispara el cambio. Cero acceso manual.
- **Drift auto-corregido**: en modelo pull, un cambio manual es revertido por el reconciliador.

Ventajas: trazabilidad total, rollback = revert de Git, revisión previa, recuperación reproducible. Límites: no todo encaja en reconciliación declarativa (migraciones ordenadas, operaciones one-shot, coordinación multi-sistema); los secretos requieren manejo especial (nunca en claro en el repo); la latencia de reconciliación no sustituye a la orquestación de release compleja (ver [cicd-y-release-engineering.md](cicd-y-release-engineering.md)).

## 6. Módulos y abstracciones reutilizables

Los **módulos** encapsulan un patrón de infraestructura parametrizado y reutilizable (una red estándar, un servicio con su balanceador y autoscaling, un bucket con su política).

- **Composición**: módulos pequeños que se ensamblan, en vez de un monolito parametrizado hasta el infinito.
- **Versionado de módulos**: cada módulo se versiona (semver); los consumidores fijan versión y actualizan de forma controlada.
- **DRY sin sobre-abstraer**: extraer un módulo tras la segunda o tercera repetición real, no antes. La abstracción prematura genera parámetros que nadie entiende y acoplamiento inverso.

Estos son los **módulos del paved road**: bloques opinados, seguros y probados que el resto del equipo consume para ir por el "camino pavimentado". baluarte es **dueño T1** de estos módulos y del pipeline de IaC (ver el rol de IDP en plataforma-e-idp y la exposición a aliados en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)). Un buen módulo del paved road trae por defecto seguridad, observabilidad y etiquetado correctos, de modo que "lo fácil" coincide con "lo correcto".

## 7. Gestión de estado de IaC

Los motores declarativos de estado mantienen un **state**: su modelo de qué existe y cómo se mapea al código.

| Tema | Práctica sana | Antipatrón |
|---|---|---|
| Ubicación | **Backend remoto** compartido y cifrado | State local en el portátil |
| Concurrencia | **Locking** para evitar `apply` simultáneos | Dos personas aplicando a la vez |
| Deriva state↔realidad | Refresh/reconciliar antes de aplicar | Confiar ciegamente en un state viejo |
| Recursos preexistentes | **Importar** al state (clave en brownfield) | Recrear y duplicar recursos |

Puntos críticos:
- El **state es sensible**: puede contener metadatos y referencias delicadas; se cifra y se controla el acceso (ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).
- **Importar recursos existentes** es la puerta de entrada del **brownfield**: adoptar infraestructura viva bajo IaC sin destruirla, reconciliando gradualmente.
- No todos los motores usan state explícito: algunos derivan el estado real consultando la plataforma en cada reconciliación. La disciplina de locking y verdad única aplica igual.

## 8. Paridad de entornos y promoción

El objetivo es que dev, staging y prod difieran solo en parámetros, no en definiciones. Se logra con **las mismas definiciones parametrizadas por entorno**.

- **Evitar snowflakes**: ningún entorno "especial" mantenido a mano. Un entorno es su código más sus variables.
- **Jerarquía de configuración**: `defaults → valores por entorno → override puntual`. Lo común vive una sola vez; cada capa solo declara su diferencia.
- **Promoción**: un cambio validado en un entorno inferior se promueve al superior aplicando el mismo código con otros parámetros (ver flujo en [cicd-y-release-engineering.md](cicd-y-release-engineering.md)).

| Capa | Contenido | Ejemplo |
|---|---|---|
| Defaults | Lo válido para todos | Región base, tags obligatorios |
| Entorno | Diferencias por ambiente | Tamaño de cómputo, réplicas |
| Override | Excepción justificada y documentada | Flag temporal en un solo entorno |

## 9. Gestión de configuración de aplicaciones

La configuración de la aplicación se separa del código y de los secretos (principio de tipo "12-factor", aplicado con criterio, no como dogma):

- **Config vs código vs secretos**: el código es igual en todos los entornos; la config varía por entorno; los secretos son config sensible con manejo endurecido (nunca en claro, ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)).
- **Arranque vs runtime**: config leída al arrancar (requiere reinicio/redeploy para cambiar) vs config recargable en caliente. Cada una tiene trade-offs de simplicidad vs agilidad.
- **Feature/config flags**: interruptores para variar comportamiento sin redeploy. Matiz importante: los flags de **configuración/operación** (activar un modo, ajustar un límite) los opera baluarte; los flags de **release** (progressive delivery, canary) pertenecen al dominio de entrega en [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

## 10. Entornos efímeros y de preview

Un PR puede levantar **on-demand** un entorno efímero completo (preview) para validar el cambio de forma aislada, destruido al cerrar el PR. Requiere IaC parametrizada, aislamiento de recursos y limpieza automática. La orquestación del disparo (crear al abrir PR, destruir al cerrar) se coordina con el pipeline descrito en [cicd-y-release-engineering.md](cicd-y-release-engineering.md). Beneficios: revisión con un entorno real, cero snowflakes de QA permanentes, control de costo por vida corta.

## 11. Testing de IaC

La IaC se prueba antes de tocar la realidad:

| Nivel | Qué verifica |
|---|---|
| Validación/lint | Sintaxis, formato, convenciones |
| Análisis estático | Malas prácticas, exposición, config insegura |
| Plan/dry-run | Diff previo: qué crea, cambia y destruye |
| Policy-as-code | Reglas obligatorias (etiquetado, cifrado, redes permitidas) — ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md) |
| Pruebas de módulos | Que un módulo produzca la infra esperada, aislado |

El **plan/dry-run** es la salvaguarda ritual: nadie aplica sin leer el plan. La **policy-as-code** codifica las reglas que fija `destroyer` y las hace bloqueantes en el pipeline. La correctitud lógica del propio código de IaC (un bug de lógica en un módulo) puede revisarla `certero`; baluarte conserva la propiedad de su **aptitud operativa**.

## 12. IaC para recuperación (DR)

La infraestructura reproducible **es** parte del plan de continuidad: si un entorno se pierde, se **restaura desde código**. Esto exige que la IaC esté completa (nada crítico fuera de ella), que el state/backend esté respaldado y que el procedimiento de `apply` de recuperación esté probado, no solo escrito. La coordinación de RPO/RTO, orden de recuperación y datos vive en [continuidad-y-dr.md](continuidad-y-dr.md); la capacidad de recrear la infra que sostiene todo eso es de baluarte.

## 13. Blast radius de los cambios de IaC

El mayor riesgo de la IaC es que "un `apply` tumbe todo". Se mitiga acotando el **blast radius**:

- **Plan review obligatorio**: leer el diff antes de aplicar; destrucciones y reemplazos se examinan con lupa.
- **Apply gradual**: por etapas, verificando entre cada una, en vez de un big-bang.
- **Separación por stack/workspace**: dividir la infraestructura en unidades independientes (por dominio, criticidad o entorno) con su propio state, de modo que un error quede contenido.
- **Aislar lo crítico**: redes base, identidades y datos en stacks separados de lo volátil.

| Estrategia | Efecto |
|---|---|
| Un mono-stack gigante | Máximo blast radius; un error afecta todo |
| Stacks por dominio/criticidad | Fallo contenido; cambios independientes |
| Apply por etapas | Detección temprana, reversión barata |

## 14. Antipatrones

| Antipatrón | Por qué duele | Remedio |
|---|---|---|
| State manual/local | Se pierde, colisiona, no audita | Backend remoto + locking |
| Secretos en el repo | Fuga permanente en el historial | Referencias externas, ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md) |
| Mono-stack sin blast-radius | Un `apply` derriba todo | Separar por stack/workspace |
| ClickOps en prod | Genera drift y config no reproducible | PR-based ops, vetar escritura manual |
| Copiar-pegar en vez de módulos | Divergencia y duplicación | Módulos versionados del paved road |
| Drift ignorado | La realidad deja de coincidir con el código | Detección + reconciliación continua |
| Sobre-abstracción prematura | Módulos ilegibles, acoplados | DRY tras repetición real, no antes |

## 15. Cómo baluarte actúa tiered aquí

- **T1 (propiedad total, implementa directo)**: el **pipeline de IaC** y los **módulos del paved road**. baluarte diseña, versiona, prueba y opera estos bloques compartidos y su cadena de aplicación como producto interno. Es su núcleo.
- **T2 (se entrega/co-implementa)**: la **provisión específica de un dominio ajeno** (p. ej. infra que sostiene el plano de datos de `andulfo`, o una app concreta de un equipo). baluarte provee el módulo, revisa el plan y co-implementa, pero el detalle del dominio lo aporta su dueño.
- **T3 (potestad, dueño saturado o ausente)**: si un cambio de IaC de un dominio ajeno es urgente (corregir un drift peligroso, cerrar una exposición) y su dueño está saturado o no existe, baluarte aplica el cambio **operativo, mínimo y reversible** marcado **"pendiente de revisión del dueño"**, sin tomar decisiones de dominio (esquema de datos, arquitectura, política de seguridad).

Las **fronteras** se mantienen firmes: la topología macro la decide `eneida` y baluarte la codifica; los bugs de lógica del código de IaC los revisa `certero`; la política de secretos y seguridad la fija `destroyer` y baluarte la opera sin hardcodear (ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)); el plano de datos es de `andulfo` y baluarte provisiona la infra que lo soporta. La exposición de módulos y del paved road a otros equipos y aliados se trata en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

**Greenfield vs brownfield.** En **greenfield** se parte de IaC desde el día uno: módulos del paved road, state remoto con locking, entornos parametrizados y policy-as-code antes del primer `apply` serio —barato hacerlo bien ahora, caro el retrofit—. En **brownfield** se adopta la infra viva sin destruirla: **importar** los recursos existentes al state (§7), reconciliar el **drift** gradualmente, envolver lo heredado en módulos reproducibles por fases, y solo entonces refactorizar —nunca un `apply` masivo sobre infra crítica no versionada—.
