# Gestión de dependencias

> Orquesta **posee el FLUJO**: mapea, secuencia, calendariza, coordina y **desatasca** dependencias. Tiene **autoridad de flujo, no de contenido**. NUNCA decide arquitectura ni cómo desacoplar (eso es **eneida**), ni prioridad/valor (**tompo**), ni pipeline CI/CD (**baluarte**). Hace **visible** el impacto de flujo de cada dependencia; el **craft** lo deciden los dueños.

Una dependencia es toda relación en la que un elemento de trabajo **necesita** algo de otro para poder empezar, avanzar o terminar. Sin gestión explícita, las dependencias son la causa raíz #1 de retrasos, esperas y bloqueos ocultos. La misión de orquesta es que **ninguna dependencia sorprenda**: todas mapeadas, secuenciadas, con dueño y con un plan de desatasco.

## Tipos de dependencia

| Tipo | Definición | Ejemplos en el equipo | Quién decide el contenido |
|------|-----------|----------------------|---------------------------|
| **Técnica** | Un trabajo depende de un artefacto/contrato/servicio de otro | motor expone API → farola la consume; contrato de eventos; esquema de datos (andulfo) | **eneida** (diseño/desacople) |
| **De recurso/capacidad** | Dos trabajos compiten por la misma persona/agente o entorno escaso | uxuifull requerido por farola y palma a la vez; único entorno de staging | **orquesta** (secuencia/capacidad) |
| **Organizacional / cross-agente** | Handoff o coordinación entre dueños de disciplina | destroyer debe revisar antes de release; docpower documenta tras congelar API | Dueños + **orquesta** coordina |
| **Externa** | Vendor, tercero, otro equipo/programa, licencia, dato externo | API de pago de un proveedor; aprobación legal; entrega de otro tren | Externo (orquesta gestiona la interfaz) |

### Relaciones de precedencia (semántica temporal)

| Relación | Significado | Uso típico |
|----------|-------------|-----------|
| **Finish-to-Start (FS)** | B no empieza hasta que A termina | Lo más común: contrato listo → integración |
| **Start-to-Start (SS)** | B no empieza hasta que A empieza | Trabajo paralelizable con arranque acoplado |
| **Finish-to-Finish (FF)** | B no termina hasta que A termina | QA que cierra junto al desarrollo |
| **Start-to-Finish (SF)** | B no termina hasta que A empieza | Raro; transiciones/relevos |
| **Lead / Lag** | Adelanto o espera entre A y B | Buffer de integración, tiempo de propagación |

## Mapa de dependencias y visualización

Orquesta mantiene un **mapa vivo** y elige la vista según la escala:

| Vista | Para qué sirve | Cuándo |
|-------|----------------|--------|
| **Dependency board** (tablero de hilos/stickies, estilo program board SAFe) | Ver dependencias entre flujos/iteraciones de un vistazo | Programa multi-flujo; planificación de PI |
| **Matriz DSM** (Design Structure Matrix) | Detectar **ciclos** y clústeres de acoplamiento; ordenar la secuencia | Muchos elementos interdependientes; brownfield |
| **Grafo dirigido (DAG)** | Ruta/cadena crítica, orden topológico, cuellos de botella | Secuenciación fina; identificar la ruta crítica |
| **Tabla RAID (Dependencies)** | Registro con dueño, fecha objetivo, estado, riesgo asociado | Siempre; fuente de verdad textual |

**Detectar dependencias ocultas** (las más peligrosas): revisar supuestos ("asumo que X estará listo"), contratos aún no acordados, entornos/datos/credenciales compartidos, aprobaciones (seguridad, legal, cambios), personas clave con conocimiento único, y **dependencias transitivas** (A→B→C). Técnicas: pre-mortem de integración, walkthrough del DAG hasta las hojas, preguntar "¿qué necesitas que aún no tienes?" a cada dueño, e inspeccionar la DSM en busca de bucles no declarados.

## Team Topologies: reducir handoffs por diseño de interacción

Orquesta no rediseña equipos (eso conversa con eneida/liderazgo), pero **usa los tipos e interacciones** para minimizar dependencias de coordinación.

| Tipo de equipo | Rol en el ecosistema |
|----------------|----------------------|
| **Stream-aligned** | Flujo de valor end-to-end (p. ej. motor+farola sobre una feature) |
| **Platform** | Provee servicios self-service que reducen carga cognitiva (baluarte) |
| **Enabling** | Habilita/eleva capacidad temporalmente (destroyer, peakformance, certero en modo asesor) |
| **Complicated-subsystem** | Subsistema que exige expertise profunda (sysuniversal-ai, andulfo en núcleo) |

| Modo de interacción | Qué implica para el flujo | Cómo lo orquesta orquesta |
|---------------------|---------------------------|---------------------------|
| **Collaboration** | Alto contacto, descubrimiento conjunto; útil pero **caro y temporal** | Co-facilitar (T2), poner fecha de fin, vigilar que no se vuelva permanente |
| **X-as-a-Service** | Un equipo **consume** lo del otro con mínimo contacto vía contrato/API | Preferir esto: convierte una colaboración en un contrato → **menos handoffs** |
| **Facilitating** | Un equipo ayuda a otro a superar un obstáculo | Escalar aquí cuando una cadena se atasca por falta de capacidad |

**Regla de flujo**: si una dependencia de colaboración se repite, orquesta **propone** (a eneida/dueños) convertirla en X-as-a-Service (contrato estable). Propone, no decide el contrato.

## Secuenciación e integración

- **Puntos de integración**: identificar dónde convergen dos o más flujos (unión de contratos, merge de features, ensamble de subsistemas). Cada punto es una dependencia de alto riesgo → se calendariza explícitamente con buffer.
- **Ruta / cadena crítica de dependencias**: la secuencia más larga de dependencias encadenadas que determina la fecha mínima de entrega. Orquesta la **identifica, la protege** (holgura, foco, sin cambios de contexto) y vigila que ningún eslabón resbale sin alerta.
- **Orden topológico**: derivar del DAG el orden válido de ejecución; lo que no está en la ruta crítica se paraleliza.
- **Integración temprana y frecuente**: adelantar la primera integración reduce el riesgo de descubrir incompatibilidades tarde (principio de lotes pequeños / Reinertsen: acelerar la **retroalimentación** sobre las interfaces).

## Desatasco de cadenas de bloqueo (función núcleo)

Cuando una dependencia bloquea, orquesta actúa en este orden y **hace visible** el costo de flujo (tiempo perdido, trabajo represado):

| Palanca | Acción de orquesta | Límite de autoridad |
|---------|--------------------|--------------------|
| **Escalar** | Llevar el bloqueo al dueño y, si sigue, subir de nivel con datos | No decide el contenido, exige decisión |
| **Re-secuenciar** | Reordenar trabajo para adelantar lo desbloqueado y postergar lo atascado | Solo flujo; respeta prioridad de tompo |
| **Paralelizar** | Dividir para que partes independientes avancen; crear stub/mock del lado faltante | Propone stubs; el diseño lo valida eneida |
| **Romper la dependencia** | **Proponer** desacople (contrato, feature flag, interfaz, doble vía) | **eneida decide** el desacople arquitectónico |
| **Absorber / bufferear** | Añadir holgura, trabajo alternativo mientras se resuelve | Ajuste de cronograma, no de alcance |

### Frontera clave con eneida

> **Reducir el acoplamiento = decisión de eneida** (arquitectura: cómo se parte, qué contrato, qué patrón de desacople). **Mapear, calendarizar, coordinar y desatascar operativamente esa dependencia, y hacer visible su impacto de flujo = orquesta.** Orquesta puede **proponer** "esto se destraba si desacoplamos X de Y", pero la forma técnica del desacople la define eneida. Orquesta nunca escribe ni impone la solución técnica.

## Coordinación de terceros, proveedores y contratos

Las dependencias **externas** (proveedor, otro tren/equipo, licencia, aprobación legal, dato de un tercero) son las de mayor incertidumbre y menor control directo. Orquesta gestiona la **interfaz de flujo** con ellas, no el contrato comercial (negocio/compras) ni su craft.

- **Contrato de interfaz de entrega:** por cada tercero, explicitar qué se recibe, **cuándo** (fecha/ventana comprometida), en qué formato y con qué criterio de aceptación; tratarlo como punto de integración de alto riesgo con buffer.
- **SLA / SoW como dependencia:** el nivel de servicio y el enunciado de trabajo del proveedor son **insumos del cronograma**; su incumplimiento es un riesgo con dueño y contingencia (→ `gestion-de-riesgos-raid.md`).
- **Lead time del tercero:** casi siempre mayor y menos flexible que el interno; se secuencia **primero** y se protege con holgura extra; nunca en la ruta crítica sin plan B.
- **Sincronización con otro tren/programa:** cuando la dependencia es otro equipo, se coordina como dependencia cross-flujo (→ `gestion-de-programa.md`), con puntos de sync y un dueño de enlace.
- **Frontera:** la **decisión** de contratar/seleccionar proveedor es de negocio/compras (y la técnica, de eneida); orquesta **coordina la entrega** contra esa dependencia y hace visible su impacto de flujo.

## Dependencia como riesgo y en programa

- Toda dependencia sin resolver y en ruta crítica se **registra como riesgo** → ver `gestion-de-riesgos-raid.md` (la "D" de RAID; probabilidad/impacto, dueño, plan de mitigación).
- Dependencias **entre múltiples flujos/equipos** (cross-team, estilo Nexus/LeSS/SAFe program board) → se gestionan a nivel de programa: ver `gestion-de-programa.md`.
- Ruteo de quién resuelve qué dependencia → `orquestacion-y-ruteo.md`; encaje con marcos → `metodologias-y-marcos.md`.

## Cómo cambia según el estado del sistema

| Contexto | Naturaleza de las dependencias | Foco de orquesta |
|----------|-------------------------------|------------------|
| **Greenfield** | **Emergentes**: los contratos aún no existen, aparecen al descomponer | Descubrir temprano, forzar acuerdos de contrato mínimos, integrar pronto para materializar dependencias latentes |
| **En construcción (in-flight)** | **Descubiertas**: aparecen a mitad de ejecución, rompen supuestos | Re-mapear continuamente, actualizar el DAG y la ruta crítica, desatascar sin frenar el resto |
| **Brownfield / legado** | **Heredadas**: acoplamientos históricos, sistemas legados, "cajas negras" | Documentar lo existente (DSM del legado), aislar con anticorrupción/stubs (propone; eneida diseña), secuenciar con márgenes amplios |

## Tiered META (autoridad de flujo)

- **T1 — coordina directo**: mapear, secuenciar, calendarizar y publicar el estado de dependencias.
- **T2 — co-facilita CON el dueño**: proponer re-secuencia, paralelización o desacople; **el dueño decide** el contenido.
- **T3 — potestad de flujo**: solo si el dueño está ausente/saturado, toma una decisión **de flujo** (reordenar, insertar buffer, activar un stub temporal) y la marca **"pendiente de ratificación"** por el dueño. Nunca decide contenido técnico, valor ni pipeline.

## Referencias

- Skelton & Pais, *Team Topologies* (tipos de equipo y modos de interacción).
- Reinertsen, *The Principles of Product Development Flow* (colas, lotes, puntos de integración, retroalimentación).
- Steward / Eppinger, *Design Structure Matrix (DSM) Methods* (matriz de dependencias, detección de ciclos, secuenciación).
- Scaled Agile — *Program/PI Planning & Program Board*; Scrum.org — *Nexus* / LeSS (dependencias cross-team).

```
Checklist rápido — Gestión de dependencias
[ ] Cada elemento tiene sus dependencias mapeadas (técnica / recurso / organizacional / externa)
[ ] Relación de precedencia declarada (FS/SS/FF/SF + lead/lag) donde importa
[ ] Vista elegida y viva: dependency board, DSM, grafo/DAG y tabla RAID
[ ] Dependencias ocultas cazadas: supuestos, transitivas, entornos/datos, aprobaciones, personas clave
[ ] Ruta/cadena crítica identificada, protegida y monitoreada
[ ] Puntos de integración calendarizados con buffer; integración temprana buscada
[ ] Cada dependencia tiene DUEÑO y fecha objetivo; las críticas están en el registro RAID
[ ] Modo de interacción óptimo (preferir X-as-a-Service sobre collaboration permanente)
[ ] Bloqueos con plan de desatasco: escalar / re-secuenciar / paralelizar / romper (propuesta) / bufferear
[ ] Desacople técnico DERIVADO a eneida; orquesta mapea, calendariza, coordina y hace visible el impacto
[ ] Prioridad respetada (tompo), pipeline respetado (baluarte); no decidí contenido
[ ] Multi-flujo → gestion-de-programa.md; dependencia-riesgo → gestion-de-riesgos-raid.md
[ ] Decisiones T3 de flujo marcadas "pendiente de ratificación" por el dueño
```
