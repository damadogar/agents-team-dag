# Plantillas

Plantillas reutilizables de orquesta: el Primer Maestro de Delivery y Orquestación. Rellena los campos entre `<...>`. orquesta posee el FLUJO y la coordinación (META), NO el craft: nunca decide valor (tompo), arquitectura (eneida), pipeline/entrega (baluarte) ni contenido de disciplina. Cada plantilla marca al DUEÑO (A) de la decisión. orquesta co-facilita (T2) o ejerce potestad de flujo (T3, "pendiente de ratificación") solo cuando el dueño está ausente o saturado.

Regla de oro: toda plantilla de entregable cierra con **Dueño(s)**, **Dependencias/Riesgos** y **Próximo paso**.

Hermanos: `planificacion-y-cronograma.md`, `gestion-de-dependencias.md`, `capacidad-y-asignacion.md`, `gestion-de-riesgos-raid.md`, `flujo-y-metricas-de-entrega.md`, `cadencia-y-ceremonias.md`, `orquestacion-y-ruteo.md`, `metodologias-y-marcos.md`, `comunicacion-y-reporte.md`, `gestion-de-programa.md`, `gestion-de-cambios-y-alcance.md`, `incidentes-y-coordinacion-de-crisis.md`, `interoperabilidad-y-aliados.md`, `gobernanza-y-etica.md`, `ejemplos.md`, `checklists.md`.

## 1. Mapa de trabajo descompuesto + ruteo

```
Objetivo/Épica: <resultado de negocio — valor lo define tompo>
Ventana: <rango de fechas + confianza>

| # | Tarea/Entregable        | Dueño (A) | Consultados (C) | Depende de | Estado      |
|---|-------------------------|-----------|-----------------|------------|-------------|
| 1 | <p. ej. contrato API>   | eneida    | motor, andulfo  | —          | En curso    |
| 2 | <endpoint backend>      | motor     | eneida          | #1         | Bloqueada   |
| 3 | <UI de la pantalla>     | farola    | uxuifull        | #1         | Lista       |
| 4 | <pipeline de release>   | baluarte  | motor           | #2         | Pendiente   |
| 5 | <plan de pruebas>       | amado     | certero         | #2,#3      | Pendiente   |

Reglas de ruteo: cada tarea tiene UN dueño (A). orquesta rutea y secuencia, no ejecuta el craft.
Dueño(s): <por fila>  |  Dependencias/Riesgos: <cruces críticos>  |  Próximo paso: <acción de flujo>
```

## 2. Paquete de handoff (delegar una tarea al dueño)

Alineado con `interoperabilidad-y-aliados.md` §4.

```
Para: <handle del dueño (A), p. ej. motor>     De: orquesta     Fecha: <AAAA-MM-DD>
Tarea: <qué se pide, en una frase>
Outcome esperado: <resultado observable / criterio de "hecho">
Contexto: <por qué, enlaces, antecedentes mínimos suficientes>
Prioridad de valor: <la fija tompo — orquesta la transmite>
Restricciones técnicas: <las fija eneida — contratos, patrones, límites>
Dependencias: <predecesoras / insumos y de quién>
Fecha/ventana: <rango + nivel de confianza; NO fecha única falsa>
Gates a cumplir: <calidad=amado · correctitud=certero · seguridad=destroyer · entrega/operabilidad=baluarte>
Lo que decide el dueño: <el "cómo"/craft es del dueño; orquesta no lo predefine>
Seguimiento: <cadencia de check-in y canal>
Dueño(s): <handle>  |  Dependencias/Riesgos: <lista>  |  Próximo paso: <confirmación de aceptación>
```

## 3. Plan de entrega (hitos, ruta crítica, releases)

```
Programa/Producto: <nombre>          Horizonte: <fechas>
| Hito                 | Fecha (rango) | Ruta crítica | Dueño (A) | Criterio de salida        |
|----------------------|---------------|--------------|-----------|---------------------------|
| <MVP contratos>      | <rango>       | Sí           | eneida    | <contratos firmados>      |
| <Beta interna>       | <rango>       | Sí           | motor     | <flujo E2E + gates amado> |
| <Release 1.0>        | <rango>       | Sí           | baluarte  | <deploy + SLO baluarte>   |

Releases: <estrategia de corte/versionado — la técnica de despliegue es de baluarte>
Dueño(s): <por hito>  |  Dependencias/Riesgos: <bloqueos de ruta crítica>  |  Próximo paso: <acción>
```

## 4. Mapa de dependencias

```
| Origen (necesita)     | Destino (provee)      | Tipo        | Criticidad | Fecha límite | Estado     |
|-----------------------|-----------------------|-------------|------------|--------------|------------|
| farola (#3 UI)        | eneida (#1 contrato)  | Técnica     | Alta       | <fecha>      | En riesgo  |
| motor (#2 endpoint)   | andulfo (esquema)     | Datos       | Alta       | <fecha>      | OK         |
| amado (pruebas)       | baluarte (entorno QA) | Entorno     | Media      | <fecha>      | Pendiente  |

Tipo: Técnica · Datos · Entorno · Decisión · Externa/tercero
Dueño(s): <owner de cada dependencia>  |  Dependencias/Riesgos: <las de criticidad Alta>  |  Próximo paso: <desbloqueo>
```

## 5. Registro RAID

```
Programa: <nombre>          Corte: <fecha>
[R] Riesgos
| ID | Riesgo            | Dueño (A) | Prob | Impacto | Exposición | Respuesta (mitigar/evitar/transferir/aceptar) | Disparador |
|----|-------------------|-----------|------|---------|------------|-----------------------------------------------|------------|
| R1 | <p.ej. latencia>  | eneida    | M    | A       | Alta       | <acción>                                       | <umbral>   |
[A] Supuestos     | ID | Supuesto | Dueño | Validez | Acción si es falso |
[I] Incidencias   | ID | Issue | Dueño (A) | Severidad | Estado | Acción/fecha |
[D] Dependencias  | ID | Dependencia | De→A | Criticidad | Fecha | Estado |
Dueño(s): <por ítem>  |  Dependencias/Riesgos: <top exposición>  |  Próximo paso: <revisión programada>
```

## 6. Plan de capacidad / asignación

```
Sprint/Periodo: <rango>
| Agente        | Disciplina        | WIP/Carga | Capacidad | Holgura | Señal de saturación        |
|---------------|-------------------|-----------|-----------|---------|----------------------------|
| motor         | Backend           | 3 items   | 3         | 0       | Cola creciente / bloqueada |
| farola        | Frontend          | 2         | 4         | 2       | OK                         |
| baluarte      | DevOps/SRE        | 4         | 3         | -1      | SATURADO → re-secuenciar   |
| andulfo       | Datos             | 1         | 3         | 2       | OK                         |

Nota: orquesta ajusta secuencia y WIP (flujo); NO reasigna el craft por su cuenta.
Si un dueño está saturado, orquesta puede ejercer potestad de flujo T3 (re-secuenciar), marcada "pendiente de ratificación".
Dueño(s): <líder de cada disciplina>  |  Dependencias/Riesgos: <cuellos de botella>  |  Próximo paso: <balanceo>
```

## 7. Forecast probabilístico

```
Alcance pronosticado: <épica/lote — N items restantes>
Base: <throughput histórico / muestras — evidencia, no deseo>
| Escenario | Fecha estimada | Confianza |
|-----------|----------------|-----------|
| P50       | <fecha>        | 50%       |
| P85       | <fecha>        | 85%       |
Rango comunicado: <P50–P85>   (orquesta comunica RANGOS, nunca una fecha única "comprometida")
Supuestos: <alcance estable, sin cambios de prioridad tompo, capacidad constante>
Dueño(s): orquesta (forecast de flujo)  |  Dependencias/Riesgos: <lo que rompería el supuesto>  |  Próximo paso: <re-forecast en fecha>
```

## 8. Plan de cadencia

```
Equipo/Programa: <nombre>          Zona horaria: <TZ>
| Evento               | Propósito                 | Timebox | Participantes            | Entradas          | Salidas               |
|----------------------|---------------------------|---------|--------------------------|-------------------|-----------------------|
| Sincronización       | Alinear flujo/bloqueos    | 15 min  | dueños de tareas activas | Tablero           | Bloqueos ruteados     |
| Planificación        | Comprometer lote          | 60 min  | tompo + dueños           | Backlog priorizado| Lote acordado         |
| Revisión de entrega  | Inspeccionar incremento   | 45 min  | equipo + interesados     | Incremento        | Feedback              |
| Retrospectiva        | Mejorar el proceso        | 45 min  | equipo                   | Métricas de flujo | Acciones de mejora    |

orquesta facilita la cadencia; el CONTENIDO de cada evento es de su dueño (valor=tompo, técnico=eneida...).
Dueño(s): orquesta (facilitación)  |  Dependencias/Riesgos: <ausencias clave>  |  Próximo paso: <agenda>
```

## 9. Reporte de estado

```
Programa: <nombre>     Periodo: <rango>     Estado global: <🟢/🟡/🔴>
Por qué (RAG): <la razón del color, no solo el color>
Avance: <hitos logrados vs plan; alcance entregado>
Flujo: <throughput, WIP, lead/cycle time, edad de items — de flujo-y-metricas-de-entrega.md>
Riesgos/Bloqueos: <top 3, con dueño (A) y acción>
Forecast: <P50–P85 del hito próximo, con confianza>
Decisiones necesarias: <qué se necesita y de quién — valor=tompo, técnico=eneida>
Próximo paso: <acciones de flujo con responsable y fecha>
Dueño(s): orquesta (reporte)  |  Dependencias/Riesgos: <resumen>  |  Próximo paso: <acción>
```

## 10. Tablero de programa

```
Programa: <nombre>          Corte: <fecha>
| Flujo (stream)      | Dueño (A) | Estado | Hito próximo | Depende de (flujo) | Riesgo top |
|---------------------|-----------|--------|--------------|--------------------|-----------| 
| Backend/API         | motor     | 🟢     | <hito>       | Arquitectura       | <riesgo>   |
| Datos               | andulfo   | 🟡     | <hito>       | —                  | <riesgo>   |
| Plataforma/Entrega  | baluarte  | 🟢     | <hito>       | Backend            | <riesgo>   |
| Frontend/UX         | farola    | 🟢     | <hito>       | Contratos          | <riesgo>   |

Dependencias entre flujos: <cruces críticos>     Hitos comunes: <integraciones/releases compartidos>
Dueño(s): <líder de cada flujo>  |  Dependencias/Riesgos: <cruces>  |  Próximo paso: <sincronización de flujos>
```

## 11. Solicitud / registro de cambio de alcance

```
ID de cambio: <CR-###>     Solicitante: <quién>     Fecha: <AAAA-MM-DD>
Descripción: <qué se pide cambiar/añadir/quitar>
Impacto de FLUJO (orquesta): <cronograma, dependencias, capacidad, ruta crítica, forecast>
Impacto de VALOR (tompo): <prioridad, trade-off de alcance — lo decide tompo>
Impacto TÉCNICO (eneida): <arquitectura, deuda, factibilidad — lo decide eneida>
Impacto de ENTREGA (baluarte): <riesgo de release/operación — si aplica>
Opciones: <A: absorber · B: reprogramar · C: intercambiar alcance · D: rechazar>
Decisión: <opción elegida>     Dueño de la decisión (A): <tompo para valor / eneida para técnico>
Dueño(s): orquesta orquesta el flujo del cambio; NO decide el trade-off de valor
Dependencias/Riesgos: <replanificación necesaria>  |  Próximo paso: <actualizar plan/forecast>
```

## 12. Coordinación de incidente / war room

```
Incidente: <ID/título>     Severidad: <Sev1/2/3>     Inicio: <hora>     Estado: <activo/mitigado/resuelto>
Roles:
  - Incident Commander (IC): <orquesta o delegado — coordina, NO arregla>
  - Comms: <comunica a interesados>     - Scribe: <registra timeline>
  - Resolvers: <dueños técnicos: baluarte (plataforma/operación), motor, andulfo, destroyer (seguridad)...>
Timeline: <hh:mm evento / decisión / acción>
Ruteo del fix: <síntoma → dueño del área → acción>  (orquesta rutea; el fix es del dueño técnico)
Impacto: <usuarios/servicios/SLO afectados>
Acciones post-incidente: <postmortem sin culpa — lo lidera baluarte/dueño técnico; orquesta agenda y da seguimiento>
Dueño(s): IC=orquesta (coordinación) · fix=dueño técnico  |  Dependencias/Riesgos: <escalado>  |  Próximo paso: <acción inmediata>
```

## 13. Informe de cierre + retrospectiva

```
Programa/Release: <nombre>          Cierre: <fecha>
Qué se entregó: <alcance real vs comprometido; hitos cumplidos>
Métricas de flujo: <lead/cycle time, throughput, predictibilidad P50/P85 vs real, WIP medio>
Calidad/entrega: <resultados de gates — amado, certero, destroyer, baluarte>
Aprendizajes: <qué funcionó / qué no — de proceso y flujo>
| Acción de mejora            | Dueño (A) | Fecha  | Métrica objetivo |
|-----------------------------|-----------|--------|------------------|
| <p. ej. reducir handoffs>   | orquesta  | <fecha>| <cycle time>     |
Reconocimientos: <equipo/aliados>
Dueño(s): orquesta (informe + seguimiento de acciones)  |  Dependencias/Riesgos: <deuda arrastrada>  |  Próximo paso: <trackear acciones>
```

## 14. Señal entrante a orquesta (intake de otro agente/usuario)

El recíproco del handoff: cuando un agente o el usuario detecta trabajo que **no es de su dominio** (o es multi-disciplina), lo rutea a orquesta con este formato mínimo.

```
Para: orquesta     De: <handle emisor / usuario>     Fecha: <AAAA-MM-DD>
Señal/necesidad: <qué se necesita, en una frase>
Naturaleza (si se sabe): <valor / técnica / multi-disciplina / flujo>
Outcome esperado: <resultado y para cuándo, si aplica>
Contexto/urgencia: <por qué ahora; criticidad; ¿es incidente?>
Restricciones conocidas: <fecha dura, dependencia, presupuesto>
Qué NO es de mi dominio: <por qué se rutea a orquesta>
```

orquesta responde: **clasifica** (valor→tompo · técnica→eneida/especialista · flujo→orquesta), **descompone**, **rutea** y devuelve el mapa señal→dueño + la secuencia. Cierra el lazo del rol *front door* (ver `interoperabilidad-y-aliados.md` §4.1).
Dueño(s): orquesta (intake/ruteo)  |  Dependencias/Riesgos: <lo que condiciona el despacho>  |  Próximo paso: <mapa señal→dueño>
