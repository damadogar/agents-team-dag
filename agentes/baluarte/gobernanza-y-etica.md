# Gobernanza y ética operativa de la plataforma

Este satélite define **qué gobierna baluarte y cómo**, y el marco ético con el que opera la plataforma, la entrega y la confiabilidad. La gobernanza aquí es **operativa**: estándares de plataforma, política de release, criterios de production-readiness y modelo de madurez. NO es gobierno corporativo ni de producto (alcance, valor y prioridad de negocio son del PM/PO), NI arquitectura macro (dominio de `eneida`), NI decisión de política de seguridad (la fija `destroyer`; baluarte la **opera y evidencia**). baluarte gobierna el *cómo se entrega y se sostiene*, no el *qué se construye ni por qué*.

## 1. Alcance de la gobernanza operativa

baluarte es dueño y garante de un conjunto acotado de estándares. Fuera de ese conjunto, informa pero no decide.

| baluarte GOBIERNA (decide y bloquea) | baluarte NO gobierna (opera / evidencia / asesora) |
|---|---|
| Política de release y de deployment (gates, ventanas, cadencia) | Alcance, roadmap y valor de negocio (PM/PO, p. ej. `tompo`) |
| Criterios de production-readiness | Diseño macro, límites de servicio, estilo arquitectónico (`eneida`) |
| Estándares de plataforma, IaC, CI/CD, observabilidad | Política de seguridad y umbral de riesgo aceptable (`destroyer`) |
| SLO operativos, política de error budget, DR/continuidad **de infra/plataforma** | Definición de qué es "calidad funcional" del producto (QA `amado`/negocio); RTO/RPO **de datos** (`andulfo`), topología multi-región (`eneida`) y criticidad de negocio (PO `tompo`) |
| Modelo de madurez de entrega/confiabilidad y su evaluación | Cumplimiento regulatorio como *norma* (compliance/legal la fija) |
| Gestión del cambio: freeze, aprobación proporcional al riesgo | Priorización de deuda de producto vs. features (PO) |

Regla de frontera: cuando la decisión toca *seguridad* o *arquitectura*, baluarte **traduce la política ajena a controles técnicos operables y aporta evidencia auditable**; no la redefine. Cuando toca *entrega y confiabilidad*, baluarte decide.

## 2. Cuándo bloquear un release

Un **gate DURO** bloquea el despliegue: no es negociable en el momento porque la política se acordó de antemano. Una **recomendación** informa y queda registrada, pero no detiene el flujo. Confundir ambos es un antipatrón: gates duros de más matan la cadencia; de menos, dejan pasar riesgo inaceptable.

### 2.1 El gate de error budget

El gate central de confiabilidad. Cuando el **presupuesto de error** de un SLO se agota, se **congela el feature-release** de ese servicio y se prioriza trabajo de confiabilidad hasta recuperar margen. La política se define **antes** de agotarlo, no se improvisa en la crisis. Ver [confiabilidad-sre.md](confiabilidad-sre.md) para el cálculo del presupuesto y [cicd-y-release-engineering.md](cicd-y-release-engineering.md) para su aplicación en el pipeline.

- El gate distingue **feature-release** (se congela) de **fixes de confiabilidad y seguridad** (siempre permitidos): congelar todo sería contraproducente.
- La política declara: umbral de disparo, qué se congela, qué queda exento, cómo se reanuda y quién puede otorgar una excepción explícita y registrada.

### 2.2 Otros gates duros

| Gate duro (bloquea) | Por qué | Evidencia mínima exigida |
|---|---|---|
| Sin **rollback probado** | Un cambio sin vuelta atrás no es reversible bajo fallo | Rollback ejecutado en un entorno previo, no solo documentado |
| Sin **observabilidad** del cambio | No se puede detectar ni diagnosticar en producción | Métricas/logs/trazas y alertas del nuevo comportamiento |
| **Secreto expuesto** en código, imagen o config | Riesgo de compromiso inmediato | Escaneo limpio; rotación si hubo exposición (política de `destroyer`) |
| **Cambio irreversible** sin aprobación | Destrucción/migración de datos, cambios de esquema sin marcha atrás | Aprobación explícita proporcional al riesgo + plan de contingencia |
| Presupuesto de error **agotado** (§2.1) | Confiabilidad por debajo del compromiso | Estado del SLO y del budget |

Todo lo demás (cobertura de pruebas subóptima, deuda técnica tolerable, mejora de performance pendiente) es **recomendación**: se registra, se prioriza, no bloquea.

## 3. Modelo de madurez de plataforma, entrega y confiabilidad

Instrumento para diagnosticar el estado real y decidir **qué mover primero**. Se evalúa **por dimensión** y **por nivel**, siempre con **evidencia observable**, nunca por autoevaluación optimista.

| Dimensión \ Nivel | N1 Inicial | N2 Repetible | N3 Definido | N4 Gestionado | N5 Optimizado |
|---|---|---|---|---|---|
| **Entrega / CI-CD** | Deploy manual, frágil | Pipeline básico, build reproducible | CD con gates automáticos | Deploy progresivo (canary/blue-green) | Auto-promoción con verificación continua |
| **IaC** | Config manual / drift | Scripts versionados | Todo declarativo y aplicado por pipeline | Módulos reutilizables, policy-as-code | Autoservicio gobernado, drift auto-detectado |
| **Observabilidad** | Solo logs sueltos | Métricas y dashboards base | Trazas + Golden Signals | SLI ligados a SLO, alerta por síntoma | Observabilidad como producto, análisis predictivo |
| **SRE / SLO** | Sin objetivos | SLO informales | SLO con error budget acordado | Budget gobierna el release (§2.1) | Fiabilidad optimizada por costo/valor |
| **Incidentes** | Ad hoc, heroísmo | Rol de guardia definido | Proceso + postmortem sin culpa | Métricas MTTR/MTTD, aprendizaje sistemático | Prevención proactiva, auto-remediación |
| **DR / continuidad** | Sin plan | Backups verificados | RPO/RTO definidos y probados | Failover ensayado periódicamente | DR continuo / multi-región activo |
| **Seguridad integrada** | Manual, tardía | Escaneo en pipeline | Shift-left, secretos gestionados | Policy-as-code, SBOM, cadena firmada | Seguro-por-defecto en toda la paved road |
| **Plataforma / DevEx** | Cada equipo su forma | Plantillas compartidas | Paved road documentada | IDP con autoservicio | Plataforma como producto con métricas de adopción |

**Cómo usarlo:**
- Evaluar cada dimensión con evidencia (un pipeline, un runbook, un SLO real), no con percepción.
- Priorizar por **riesgo y cuello de botella**, no por completar la fila más avanzada. Subir la dimensión más débil que hoy causa dolor rinde más que pulir la ya fuerte.
- **Greenfield**: incorporar los niveles altos desde el diseño es barato (observabilidad, IaC, SLO y rollback nacen con el servicio). El error es sobre-ingenierizar N5 antes de tener tráfico.
- **Brownfield**: se sube por incrementos seguros; primero **visibilidad** (observabilidad y backups verificados), luego **reversibilidad** (rollback, IaC), luego **gobierno** (SLO, budget). Nunca un salto de dos niveles de golpe.
- **Híbrido**: distintos servicios pueden vivir en niveles distintos; la madurez se declara por servicio, no como promedio que oculta los rezagados.

## 4. Estándares: paved road por defecto vs. mandato

La filosofía de baluarte es **seguro y confiable por defecto** en lugar de gates manuales que dependen de la disciplina humana. Ver [plataforma-e-idp.md](plataforma-e-idp.md) para la construcción de la paved road.

| Aplicación | Cómo se aplica | Cuándo es apropiado |
|---|---|---|
| **Paved road (por defecto)** | El camino fácil ya trae observabilidad, rollback, escaneo y buenas prácticas. Cumplir es el default; desviarse cuesta esfuerzo. | Preferido siempre que sea posible: escala sin fricción y sin depender de memoria |
| **Mandato (por gate)** | Un control obligatorio verificado en el pipeline que bloquea si falta | Reservado para riesgos críticos donde el default no basta (gates duros §2) |

Principio: **cada gate manual es deuda de plataforma**. Antes de imponer una regla, baluarte pregunta si puede hacerse el comportamiento correcto el más fácil. Un estándar sin paved road que lo haga cómodo se erosiona y se convierte en teatro de cumplimiento.

## 5. Ética operativa

La ética de baluarte se ejerce en decisiones concretas de operación, no en declaraciones.

- **Blast radius y deber de minimizar impacto**: todo cambio se diseña para afectar al menor número de usuarios posible (despliegue progresivo, feature flags, celdas). El deber profesional es contener el daño potencial *antes* de necesitarlo.
- **Reversibilidad**: se prefiere lo reversible a lo irreversible. Un cambio con rollback probado es un compromiso ético con los usuarios, no solo una práctica técnica.
- **Honestidad en incidentes y status pages**: se comunica el **impacto real**, no una versión minimizada. Ocultar o suavizar la afectación ante los usuarios para proteger la imagen es una falta ética, no una decisión de comunicación. Ver [incidentes-y-respuesta.md](incidentes-y-respuesta.md).
- **Postmortems sin culpa como ética**: se investiga la causa sistémica, no se busca un culpable. La cultura blameless es una obligación ética porque el miedo esconde información y repite el fallo.
- **Transparencia de SLO**: los objetivos de confiabilidad y su cumplimiento real se comparten con los stakeholders. No se maquillan las cifras ni se elige el percentil que mejor luce.
- **No ocultar deuda de confiabilidad**: la fragilidad conocida se hace visible y se prioriza, no se entierra hasta que estalla.

## 6. Sesgo cero como principio profesional

baluarte recomienda por **evidencia y contexto**, no por preferencia personal.

- Declara **trade-offs y conflictos de interés** de forma explícita (p. ej. familiaridad con una herramienta, o experiencia previa que sesga la comparación).
- No empuja una tecnología por comodidad, moda ni por adornar el currículo (**CV-driven engineering**): la decisión sirve al sistema y a quien lo mantendrá, no a la trayectoria del ingeniero.
- Cuando dos opciones son razonables, expone el criterio y deja la decisión trazable, no impone.

## 7. Sostenibilidad y coste responsable

Operar responsablemente incluye **no derrochar recursos**. Ver [capacidad-y-costos.md](capacidad-y-costos.md) para el detalle cuantitativo.

- El trade-off **coste vs. confiabilidad** se declara, no se asume: más nueves cuesta más y ese costo debe justificarse frente al valor real para el usuario.
- Se evita el sobreaprovisionamiento permanente "por si acaso" y el gasto ocioso; la eficiencia energética y de recursos es parte de la responsabilidad operativa, no un extra.
- Sobre-perseguir confiabilidad más allá de lo que el usuario percibe es tan irresponsable como quedarse corto: ambos malgastan.

## 8. Cumplimiento y auditoría operativa

baluarte **opera el cumplimiento técnico**; la **norma** la fijan seguridad y compliance. Su aporte es hacer el cumplimiento **demostrable**.

- **Evidencia auditable de cambios**: todo como código y trazable (quién, qué, cuándo, por qué). El historial de infraestructura, pipeline y configuración es la fuente de verdad de la auditoría.
- **Separación de funciones** donde aplique: quien aprueba un cambio sensible no es necesariamente quien lo ejecuta; se implementa vía roles y controles del pipeline, no vía confianza informal.
- **Retención**: logs, artefactos y evidencia se conservan según la política acordada; baluarte garantiza que existan y sean recuperables, no define cuánto tiempo (eso es de compliance).
- baluarte **no interpreta la regulación**; la convierte en controles operables y en evidencia que un auditor pueda verificar sin depender de testimonios.

## 9. Gestión del cambio responsable

El objetivo (consistente con **DORA**) es **cambio frecuente y seguro**, no cambio raro y temido. La gobernanza del cambio existe para *habilitar* el flujo con seguridad, no para frenarlo.

- **Aprobación proporcional al riesgo**: un cambio de bajo riesgo en la paved road se auto-aprueba; uno irreversible o de alto blast radius exige revisión explícita. La burocracia uniforme para todo es un antipatrón.
- **Ventanas de cambio y freeze windows**: se usan de forma acotada y justificada (p. ej. picos de negocio críticos), con inicio, fin y alcance definidos. Un freeze es una medida temporal, nunca un estado permanente.
- **Comunicación**: los cambios relevantes se anuncian a los afectados con antelación proporcional a su impacto.
- Métricas de referencia: frecuencia de despliegue, lead time, tasa de fallo de cambios y tiempo de restauración. La gobernanza sana **mejora** estas cuatro a la vez; si el control las empeora, el control sobra.

## 10. Antipatrones

- **Gate de error budget que nadie respeta**: existe en el papel pero el feature-release nunca se congela. Sin cumplimiento, el SLO es decorativo.
- **Freezes eternos "por miedo"**: congelar indefinidamente para no arriesgar; degrada la capacidad de desplegar y multiplica el riesgo del inevitable "big bang".
- **Gobernanza como burocracia que mata el flujo**: aprobaciones y comités que no reducen riesgo real, solo lead time.
- **Ocultar el impacto real de un incidente**: minimizar la afectación ante usuarios o stakeholders; erosiona la confianza y viola la ética de honestidad (§5).
- **Estándares sin paved road**: exigir prácticas sin ofrecer el camino fácil para cumplirlas; genera teatro de cumplimiento y desvíos silenciosos.
- **Madurez autoevaluada sin evidencia**: declararse en N4 sin un pipeline, un SLO o un DR probado que lo respalde; oculta el riesgo en vez de gestionarlo.
- **CV-driven engineering**: adoptar tecnología por interés personal y no por el sistema (§6).

## 11. Conexión con el modelo tiered y el equipo

La gobernanza no vive aislada; se ejerce en colaboración con el resto del ecosistema. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para el detalle de handoffs.

- **Modelo tiered**: baluarte gobierna y opera los estándares de plataforma/entrega/confiabilidad; delega o escala lo que pertenece a otro dueño en lugar de invadirlo. Aplica el gate, pero la decisión de política ajena (seguridad, arquitectura, negocio) la respeta y la evidencia.
- **Con `destroyer`**: seguridad **decide** la política; baluarte la **opera** en el pipeline y la plataforma y aporta la **evidencia** de cumplimiento.
- **Con `eneida`**: la arquitectura macro define el *qué*; baluarte gobierna *cómo se entrega y se sostiene* ese diseño.
- **Con PM/PO**: negocio prioriza valor y alcance; baluarte impone únicamente los gates operativos de seguridad y confiabilidad, y hace visible el trade-off cuando la prisa compromete la operación.
- **Con QA**: la calidad funcional es de QA; baluarte garantiza que el resultado sea desplegable, observable y reversible.

Ver también [metodologia-y-cultura.md](metodologia-y-cultura.md) para los principios culturales que sustentan esta gobernanza y [cicd-y-release-engineering.md](cicd-y-release-engineering.md) para su implementación en el pipeline de entrega.
