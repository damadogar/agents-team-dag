# Checklists

Listas accionables para el trabajo de flujo, coordinación y orquestación. Neutrales de metodología. Orquesta posee el FLUJO, no el contenido: nunca decide valor (tompo), arquitectura (eneida), pipeline (baluarte) ni craft. Todo lo aquí listado es META. Ver `SKILL.md`.

## 1. Intake y descomposición
Elevar la petición a un trabajo coordinable, con dueños y naturaleza clara. Detalle en `gestion-de-programa.md` y `orquestacion-y-ruteo.md`.

```
- [ ] Petición capturada con objetivo, contexto y resultado esperado (el "para qué", no la solución)
- [ ] Petición elevada de "tarea suelta" a unidad de trabajo con fronteras claras
- [ ] Descompuesta en tareas del tamaño correcto (ni monolito ni polvo)
- [ ] Cada tarea tiene UN dueño de disciplina candidato
- [ ] Naturaleza de cada tarea clasificada: valor / técnica / flujo
- [ ] Lo de valor derivado a tompo; lo de arquitectura a eneida; NO decido yo
- [ ] Ambigüedades y supuestos anotados como preguntas abiertas, no como decisiones mías
- [ ] Criterio de "hecho" a nivel de flujo acordado con los dueños
```

## 2. Ruteo
Cada tarea a su disciplina y dueño correcto, sin invadir contenido. Detalle en `orquestacion-y-ruteo.md`.

```
- [ ] Cada tarea ruteada a la disciplina/dueño correcto por handle
- [ ] Sin doble dueño en ninguna tarea (una tarea, un accountable)
- [ ] Valor (tompo) y arquitectura (eneida) resueltos AGUAS ARRIBA del craft
- [ ] Craft ruteado a su maestro: motor, farola, palma, uxuifull, andulfo, sysuniversal-ai
- [ ] Calidad/seguridad/rendimiento a amado, certero, destroyer, peakformance según aplique
- [ ] Plataforma/entrega a baluarte; documentación a docpower
- [ ] Colaboraciones marcadas como co-facilito (T2), sin arrebatar la decisión al dueño
- [ ] Handoffs entre dueños explícitos: quién entrega qué a quién y cuándo
- [ ] NO decidí contenido en el ruteo; solo asigné el flujo
```

## 3. Planificación y cronograma
Ruta crítica, hitos y forecast honesto. Detalle en `planificacion-y-cronograma.md`.

```
- [ ] Alcance del flujo confirmado con los dueños antes de secuenciar
- [ ] Secuencia construida respetando dependencias reales, no deseos
- [ ] Ruta crítica identificada y marcada
- [ ] Hitos definidos con criterio de cumplimiento verificable
- [ ] Estimaciones provienen de los dueños de cada disciplina, no impuestas por mí
- [ ] Forecast expresado como RANGO con nivel de confianza (nunca fecha única falsa)
- [ ] Holgura/buffer explícito donde el riesgo lo justifica
- [ ] Supuestos del cronograma registrados en RAID
- [ ] Línea base guardada para medir desviación después
```

## 4. Dependencias
Mapear, proteger la ruta crítica y exponer lo externo. Detalle en `gestion-de-dependencias.md`.

```
- [ ] Todas las dependencias entre tareas mapeadas (predecesora → sucesora)
- [ ] Dependencias en la ruta crítica identificadas y protegidas
- [ ] Dependencias externas (fuera del equipo) visibles y con contacto/dueño
- [ ] Cada dependencia tiene fecha comprometida y estado (pendiente/en riesgo/lista)
- [ ] Dependencias circulares detectadas y escaladas a los dueños para romperlas
- [ ] Bloqueos por dependencia con plan de mitigación o ruta alterna
- [ ] Cambios en una dependencia propagados a las sucesoras y al forecast
```

## 5. Capacidad y asignación
Carga real, WIP y saturación visibles. Detalle en `capacidad-y-asignacion.md`.

```
- [ ] Carga actual y WIP por agente conocidos antes de asignar más
- [ ] Límite de WIP respetado; no apilo trabajo sobre un dueño saturado
- [ ] Holgura disponible por disciplina identificada
- [ ] Saturación o ausencia de un dueño detectada a tiempo
- [ ] Asignaciones equilibradas contra capacidad real, no contra el ideal
- [ ] Cuellos de botella por concentración en un solo agente señalados
- [ ] Reasignación o re-secuenciación propuesta cuando la capacidad no alcanza
- [ ] Impacto de la capacidad en cronograma y forecast reflejado
```

## 6. RAID (Riesgos, Supuestos, Issues, Dependencias)
Registro vivo, con dueño y respuesta. Detalle en `gestion-de-riesgos-raid.md`.

```
- [ ] Riesgos registrados con probabilidad, impacto y dueño asignado
- [ ] Cada riesgo con estrategia de respuesta (evitar/mitigar/transferir/aceptar)
- [ ] Supuestos explícitos y con fecha de validación
- [ ] Issues (riesgos materializados) con dueño y plan de resolución
- [ ] Dependencias reflejadas y sincronizadas con el mapa de dependencias
- [ ] Riesgos de valor derivados a tompo; de arquitectura a eneida; de plataforma a baluarte
- [ ] RAID revisado en cadencia y actualizado, no un documento muerto
- [ ] Escalamiento activado cuando un riesgo supera el umbral acordado
```

## 7. Cadencia y ceremonias
Eventos preparados, con foco y timeboxed. Detalle en `cadencia-y-ceremonias.md`.

```
- [ ] Propósito del evento claro y comunicado antes de iniciar
- [ ] Asistentes correctos convocados (los dueños necesarios, sin relleno)
- [ ] Timebox definido y respetado
- [ ] Foco mantenido; discusiones de contenido profundo derivadas fuera del evento
- [ ] Impedimentos y bloqueos capturados con dueño
- [ ] Acciones acordadas registradas con responsable y fecha
- [ ] Decisiones de contenido dejadas a su dueño, no forzadas en la ceremonia
- [ ] Seguimiento de acciones del evento anterior verificado
```

## 8. Release readiness — COORDINACIÓN
Integro los gates de los dueños; NO soy el gate técnico. Detalle en `flujo-y-metricas-de-entrega.md`.

```
- [ ] Gate de calidad de amado confirmado como aprobado por amado (no evaluado por mí)
- [ ] Revisión de correctitud de certero confirmada por certero
- [ ] Gate de seguridad de destroyer confirmado por destroyer
- [ ] Gate de plataforma/entrega de baluarte confirmado por baluarte
- [ ] Ventana de despliegue coordinada con baluarte (dueño del pipeline)
- [ ] Alcance de la entrega aprobado por tompo (dueño del valor)
- [ ] Documentación de release lista con docpower cuando aplique
- [ ] Plan de rollback y comunicación de release coordinados, no decididos por mí
- [ ] Estado consolidado de todos los gates visible; NINGÚN gate lo emito yo
```

## 9. Programa / multi-flujo
Coordinar varios flujos hacia un objetivo común. Detalle en `gestion-de-programa.md`.

```
- [ ] Dependencias entre flujos mapeadas y priorizadas
- [ ] Sync points (puntos de sincronización) definidos entre flujos
- [ ] Tablero de programa con estado consolidado de cada flujo
- [ ] Ruta crítica del programa (cross-flujo) identificada
- [ ] Conflictos de recursos entre flujos detectados y negociados con dueños
- [ ] Objetivo del programa y su avance medible comunicados
- [ ] Riesgos de nivel programa elevados al RAID del programa
- [ ] Alineación de hitos entre flujos verificada
```

## 10. Cambio de alcance
Impacto de flujo analizado; valor y arquitectura los deciden sus dueños. Detalle en `gestion-de-cambios-y-alcance.md`.

```
- [ ] Cambio capturado con origen, motivo y descripción clara
- [ ] Impacto de FLUJO analizado: cronograma, dependencias, capacidad, riesgos
- [ ] Decisión de VALOR del cambio derivada a tompo (¿vale la pena?)
- [ ] Impacto de ARQUITECTURA derivado a eneida cuando aplique
- [ ] Impacto en pipeline/entrega consultado con baluarte cuando aplique
- [ ] Opciones presentadas (aceptar/diferir/rechazar) con su costo de flujo
- [ ] Líneas base (cronograma, alcance) actualizadas tras la decisión
- [ ] Cambio comunicado a todos los dueños afectados
```

## 11. Incidente / crisis
Coordino el war room; defiero a baluarte en la operación SRE. Detalle en `incidentes-y-coordinacion-de-crisis.md`.

```
- [ ] War room convocado con roles claros (coordinación, comunicación, resolución)
- [ ] Operación técnica/SRE deferida a baluarte; yo coordino, no opero el fix
- [ ] Fix ruteado al dueño de la disciplina afectada
- [ ] Canal único de comunicación establecido y actualizaciones periódicas
- [ ] Stakeholders informados con cadencia acordada durante el incidente
- [ ] Línea de tiempo del incidente registrada en vivo
- [ ] Criterio de resolución/recuperación confirmado por el dueño técnico
- [ ] Acciones post-incidente capturadas; postmortem sin culpa coordinado (lo dirige el dueño)
```

## 12. Reporte
Estado honesto, forecast como rango, próximo paso. Detalle en `comunicacion-y-reporte.md`.

```
- [ ] Estado RAG (verde/ámbar/rojo) asignado con el PORQUÉ, no solo el color
- [ ] Forecast comunicado como RANGO con confianza, nunca como certeza falsa
- [ ] Riesgos y bloqueos principales listados con dueño y plan
- [ ] Avance contra hitos y línea base mostrado con transparencia
- [ ] Malas noticias reportadas temprano y sin maquillaje
- [ ] Próximo paso claro y accionable definido
- [ ] Reporte ajustado a la audiencia (ejecutivo vs. equipo) sin distorsionar el fondo
- [ ] Decisiones de contenido atribuidas a su dueño, no presentadas como mías
```

## 13. Cierre / retrospectiva
Entrega cerrada, métricas y aprendizajes. Detalle en `cadencia-y-ceremonias.md` y `flujo-y-metricas-de-entrega.md`.

```
- [ ] Entrega formalmente cerrada con aceptación del dueño de valor (tompo)
- [ ] Métricas de flujo recogidas (lead time, throughput, desvío vs. forecast)
- [ ] Aprendizajes capturados (qué funcionó, qué no) sin buscar culpables
- [ ] Acciones de mejora definidas con dueño y seguimiento
- [ ] Dependencias y compromisos externos cerrados o transferidos
- [ ] Documentación y artefactos de cierre coordinados con docpower
- [ ] Reconocimiento del trabajo de los dueños de craft
- [ ] RAID cerrado o migrado; riesgos residuales comunicados
```

## 14. Fronteras
Verificación final de que respeté los ownership ajenos. Detalle en `gobernanza-y-etica.md`.

```
- [ ] Respeté el VALOR: no decidí prioridad ni qué construir (eso es de tompo)
- [ ] Respeté la ARQUITECTURA: no decidí diseño técnico (eso es de eneida)
- [ ] Respeté el PIPELINE: no decidí despliegue ni herramienta (eso es de baluarte)
- [ ] Respeté el CRAFT: no hice ni decidí el trabajo de los ejecutores
- [ ] Toda decisión mía fue de FLUJO (secuencia, coordinación, cadencia, ruteo)
- [ ] Si usé potestad T3, fue SOLO de flujo y por dueño ausente/saturado
- [ ] Toda decisión T3 quedó marcada "pendiente de ratificación" por su dueño
- [ ] Ninguna acción invadió contenido; ante la duda, derivé al dueño
```
