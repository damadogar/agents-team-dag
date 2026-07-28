# Checklists operativas

> Estas listas son las guías de verificación de baluarte para Plataforma, Entrega y Confiabilidad. Son conceptuales y portables: describen QUÉ verificar, no CON QUÉ. baluarte las aplica con neutralidad tecnológica y respeta siempre las fronteras de ownership: la política de seguridad la decide destroyer, el diseño de pruebas es de amado, el modelo y la integridad de datos son de andulfo, y la arquitectura macro la gobierna eneida. baluarte opera, entrega y sostiene; no invade esas disciplinas, se coordina con ellas.

## 1. Release readiness (antes de desplegar un cambio)

- [ ] El artefacto a desplegar es inmutable, versionado y trazable a un commit/tag concreto; se despliega exactamente lo que se probó (no se recompila en el camino).
- [ ] La cadena de CI está verde: todas las suites diseñadas por amado pasaron; no hay pruebas saltadas ni "flaky" ignoradas sin justificación.
- [ ] El escaneo de seguridad pasó el umbral definido por destroyer (dependencias, SAST/imagen, secretos); los hallazgos por encima del umbral están resueltos o tienen excepción firmada por destroyer.
- [ ] La estrategia de despliegue está elegida y justificada según el riesgo (recreate, rolling, blue/green o canary) y coincide con la criticidad del servicio.
- [ ] Si aplica canary/despliegue progresivo: hay criterios cuantitativos de promoción y de aborto automático basados en señales, no en percepción.
- [ ] El blast radius está acotado: se conoce a qué usuarios, regiones o tenants alcanza el cambio y cómo limitarlo si algo sale mal.
- [ ] El ROLLBACK está definido y PROBADO (no solo documentado); se conoce el tiempo estimado de reversión y quién lo ejecuta.
- [ ] Las migraciones de esquema o datos son compatibles hacia atrás (expand/contract): la versión anterior y la nueva coexisten sin romperse. El plan de datos se coordina con andulfo.
- [ ] Existe la observabilidad necesaria para VERIFICAR el cambio en producción (métricas, logs y trazas de la nueva ruta), no solo para desplegarlo. Ver [observabilidad-operacional.md](observabilidad-operacional.md).
- [ ] La comunicación está lista: interesados avisados, canal de despliegue abierto, responsable de guardia identificado durante y después.
- [ ] La ventana de cambio es adecuada: se evita el pico de tráfico y los periodos de congelación; hay tiempo de observación posterior antes de considerar el cambio estable.
- [ ] Detalles del proceso de release en [cicd-y-release-engineering.md](cicd-y-release-engineering.md); el rollback y la comunicación se alinean con [incidentes-y-respuesta.md](incidentes-y-respuesta.md).

## 2. Production Readiness Review (PRR) — antes de onboardear un servicio a producción/on-call

- [ ] Hay SLIs definidos que reflejan la experiencia real del usuario (latencia, errores, disponibilidad, frescura según corresponda) y SLOs con objetivo numérico y ventana.
- [ ] Existe error budget derivado del SLO y una política acordada de qué hacer cuando se agota (frenar cambios, priorizar confiabilidad). Ver [confiabilidad-sre.md](confiabilidad-sre.md).
- [ ] Hay dashboards y alertas basados en SLO y síntomas (no en causas ruidosas); cada alerta es accionable y apunta a un runbook. Ver [observabilidad-operacional.md](observabilidad-operacional.md).
- [ ] Los runbooks de las operaciones críticas y de los fallos esperados existen y fueron PROBADOS al menos una vez, no solo redactados.
- [ ] La capacidad está dimensionada con headroom para picos y pérdida de una zona; el autoscaling tiene límites, señales y comportamiento verificados.
- [ ] Las dependencias (upstream y downstream) están mapeadas junto a sus modos de fallo, timeouts, reintentos, circuit breakers y comportamiento en degradación.
- [ ] Hay estrategia de DR/backup con RTO/RPO objetivo y, sobre todo, con RESTORE probado; el plan de datos se acuerda con andulfo. Ver [continuidad-y-dr.md](continuidad-y-dr.md).
- [ ] La seguridad está integrada desde el inicio: gestión de secretos, hardening base, autenticación/autorización de servicio y superficie mínima; el criterio y la política los fija destroyer. Ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md).
- [ ] Existen health checks (liveness/readiness) correctos y graceful shutdown/startup: el servicio drena conexiones y no pierde trabajo en un despliegue o reinicio.
- [ ] El equipo de on-call está formado en el servicio, conoce sus runbooks y sabe escalar; la rotación es sostenible (ver checklist 8).
- [ ] Se emite un veredicto PRR go/no-go explícito con criterios de éxito y con los pendientes registrados con dueño y fecha.

## 3. Respuesta a incidentes (durante)

- [ ] El incidente está DECLARADO formalmente y con una severidad asignada según impacto real (usuarios, SLO, negocio), no según la sensación del momento.
- [ ] Hay un Incident Commander (IC) designado y los roles clave repartidos (comunicaciones, operaciones/scribe); una sola persona no acumula todo.
- [ ] Se prioriza MITIGAR antes de diagnosticar: parar el sangrado primero (rollback, feature flag, failover, drenar tráfico); entender la causa raíz viene después.
- [ ] Se comunica pronto y periódicamente a los interesados y al canal de estado, con lenguaje de impacto para el usuario y próximos pasos, aunque no haya solución todavía.
- [ ] Se registra el timeline en vivo (qué se observó, qué se hizo, a qué hora); esto alimentará el postmortem y evita perder contexto.
- [ ] La mitigación se VERIFICA con los SLIs/SLOs y las señales, no solo porque "ya se ve mejor"; se confirma que el impacto al usuario cesó.
- [ ] No hay héroe solitario: si el IC o cualquier respondiente se satura o lleva demasiado tiempo, se rota y se pide ayuda o escalado.
- [ ] Al cerrar, se agenda un postmortem blameless con dueño y fecha antes de disolver el incidente (ver checklist 4).
- [ ] El proceso completo, severidades y plantillas viven en [incidentes-y-respuesta.md](incidentes-y-respuesta.md); si es un fallo de seguridad, se involucra a destroyer de inmediato.

## 4. Postmortem (después)

- [ ] El timeline está completo y ordenado: detección, respuesta, mitigación y resolución, con marcas de tiempo y quién hizo qué.
- [ ] El impacto está cuantificado: usuarios/solicitudes afectadas, presupuesto de error consumido, duración y efecto de negocio; no adjetivos, números.
- [ ] Se identifican causas raíz MÚLTIPLES (técnicas, de proceso y de contexto) con enfoque blameless: se buscan condiciones del sistema, no culpables.
- [ ] Cada acción correctiva tiene dueño y fecha, es concreta y verificable, y está priorizada por reducción de riesgo.
- [ ] Al menos una acción previene la CLASE de fallo (no solo esta instancia): la corrección ataca el patrón, no el síntoma puntual.
- [ ] Las acciones se rastrean hasta su cierre real; el postmortem no se considera terminado cuando se publica, sino cuando las acciones se completan.
- [ ] El aprendizaje se comparte con otros equipos afectables por la misma clase de fallo; el conocimiento no se queda en el equipo del incidente.
- [ ] Formato de postmortem y criterios blameless en [incidentes-y-respuesta.md](incidentes-y-respuesta.md); los cambios de confiabilidad derivados se planifican con la lente de [confiabilidad-sre.md](confiabilidad-sre.md).

## 5. Prueba de DR / game-day

- [ ] Hay una hipótesis de estado estable definida y medible (qué significa "normal") antes de inyectar el fallo, para saber si el sistema se desvía.
- [ ] El blast radius del experimento es mínimo y controlado; existe un botón de aborto y las condiciones para detenerlo de inmediato.
- [ ] Los objetivos RTO/RPO están fijados de antemano y se van a medir contra el resultado real, no a estimar después.
- [ ] Se ejecuta un failover REAL (no simulado en teoría): se conmuta a la capacidad/región/réplica de respaldo y se observa el comportamiento.
- [ ] Se prueba el RESTORE de datos y servicio, no solo la existencia del backup; un backup que nunca se restauró no cuenta como recuperación.
- [ ] Se mide el tiempo real de recuperación y la pérdida real de datos, y se compara contra RTO/RPO objetivo; las brechas se registran.
- [ ] El failback (vuelta al estado primario) se ejecuta de forma ordenada y también se verifica; recuperar no es solo "irse", también es "volver".
- [ ] La consistencia e integridad de los datos tras el ejercicio se valida junto con andulfo; baluarte no decide sobre integridad de datos por su cuenta.
- [ ] Se documentan hallazgos y se convierten en acciones con dueño y fecha; el game-day sin acciones de mejora es teatro. Ver [continuidad-y-dr.md](continuidad-y-dr.md).

## 6. Revisión de IaC / pipeline (PR de plataforma)

- [ ] El cambio es reproducible y está versionado: la infraestructura se describe como código, sin pasos manuales fuera de control de versiones.
- [ ] No hay secretos en el código ni en el estado: credenciales, tokens y claves salen de un almacén de secretos, no del repositorio. El criterio lo respalda destroyer. Ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md).
- [ ] El cambio es idempotente: aplicarlo varias veces converge al mismo estado sin efectos colaterales acumulados.
- [ ] El blast radius está acotado por stack/workspace/estado: un cambio no puede alterar por accidente entornos o recursos que no le corresponden.
- [ ] El plan/dry-run fue revisado por un humano ANTES de aplicar: se leyó qué crea, cambia y DESTRUYE, con atención especial a los reemplazos y borrados.
- [ ] Se verificó y resolvió el drift: el estado real coincide con el declarado; no se aplica encima de una divergencia no entendida.
- [ ] El coste del cambio está estimado y es aceptable; los recursos nuevos no introducen gasto sorpresa (ver checklist 7).
- [ ] El cambio es reversible o tiene un camino de reversión claro; se sabe cómo deshacerlo si degrada el sistema.
- [ ] La política-as-code pasa (etiquetado, redes, cifrado, cumplimiento); las reglas de seguridad y cumplimiento las define destroyer, baluarte solo verifica que el pipeline las respete.
- [ ] Convenciones de pipeline y gates en [cicd-y-release-engineering.md](cicd-y-release-engineering.md).

## 7. Higiene FinOps / capacidad (periódica)

- [ ] Hay headroom suficiente para picos previstos y para la pérdida de una zona/región sin degradar el SLO.
- [ ] El rightsizing está revisado: los recursos aprovisionados corresponden al uso real; ni asfixia ni sobredimensión crónica.
- [ ] El waste está identificado y con plan de acción: recursos huérfanos, entornos zombis, almacenamiento sin dueño, capacidad reservada sin uso.
- [ ] Las cuotas y límites están revisados y con margen; no se está a punto de chocar contra un tope que provoque un incidente.
- [ ] El coste unitario (por solicitud, por usuario, por transacción) se conoce y se sigue en el tiempo; el gasto se entiende en términos de negocio, no solo de factura total.
- [ ] Todo trade-off coste↔confiabilidad se hace explícito y NO se recorta capacidad hasta romper el SLO ni el error budget; ahorrar no puede degradar la fiabilidad acordada. Ver [confiabilidad-sre.md](confiabilidad-sre.md).
- [ ] El forecast de capacidad y coste está actualizado con la tendencia de crecimiento; se anticipa la necesidad antes de que sea urgente.

## 8. Onboarding a on-call sano

- [ ] La rotación es sostenible: tamaño de equipo, frecuencia y carga permiten descanso; nadie está de guardia de forma crónica ni sin relevo.
- [ ] Las alertas son accionables y de bajo ruido: cada página exige una acción humana; el ruido y las alertas informativas no despiertan a nadie.
- [ ] Los runbooks están accesibles desde la alerta y actualizados; el respondiente encuentra qué hacer sin buscar a ciegas. Ver [observabilidad-operacional.md](observabilidad-operacional.md).
- [ ] Los accesos y permisos necesarios están concedidos, incluido un mecanismo break-glass auditado para emergencias; los criterios de acceso los define destroyer.
- [ ] La ruta de escalado es clara: a quién y cuándo escalar, con contactos vigentes y expectativas de tiempo de respuesta por severidad.
- [ ] La formación y los incident drills se realizaron: el nuevo on-call practicó un incidente simulado antes de tomar guardia real. Ver [incidentes-y-respuesta.md](incidentes-y-respuesta.md).

## 9. Checklist de cierre de baluarte (meta, antes de entregar cualquier trabajo)

- [ ] El objetivo está entendido y es MEDIBLE: se sabe qué resultado se busca y cómo se comprobará el éxito.
- [ ] Se leyó el estado real del sistema (señales, configuración, dependencias) antes de proponer o actuar; no se trabajó sobre suposiciones.
- [ ] Los hallazgos están clasificados por severidad y por lente (entrega, confiabilidad, plataforma, coste), priorizados por riesgo.
- [ ] Todo cambio a producción lleva blast radius acotado y ROLLBACK probado; nada llega a prod sin camino de reversión verificado (ver checklist 1).
- [ ] El resultado se VERIFICÓ por SLO/observabilidad, no por percepción; hay evidencia de que el sistema quedó en el estado esperado.
- [ ] Se comprobó la no-regresión de confiabilidad y de coste: el cambio no degrada el SLO, el error budget ni el gasto unitario.
- [ ] El toil identificado se automatizó o se dejó registrado para automatizar; no se normaliza el trabajo manual repetitivo.
- [ ] El modelo tiered está aplicado y el ownership es claro: baluarte ejecutó lo suyo, delegó lo delegable y dejó explícito quién es dueño de cada pendiente.
- [ ] El trabajo está enrutado correctamente a otras disciplinas: seguridad a destroyer, pruebas a amado, datos/integridad a andulfo, arquitectura a eneida. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).
- [ ] Se dejó prevención de la clase de problema (guardarraíl, alerta, política, runbook), no solo el arreglo puntual.
- [ ] La seguridad quedó integrada sin exponer nada: no se filtraron secretos, credenciales ni datos sensibles en logs, código o salidas; la política es de destroyer. Ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md).
- [ ] La neutralidad tecnológica se respetó y los trade-offs relevantes (coste, riesgo, tiempo, complejidad) están declarados de forma explícita.
- [ ] Se emite un veredicto claro con criterios de éxito y pendientes con dueño y fecha; las plantillas de entrega están en [plantillas.md](plantillas.md).
