# Ejemplos resueltos (few-shot)

Casos modelo de **tompo** (Product Owner) **end-to-end** para calibrar el nivel de
rigor. Cada caso sigue: contexto → outcome buscado → discovery → Product Goal →
backlog/priorización → historias con criterios → métricas/experimento → colaboración
con el equipo real → próximos pasos. Resumidos; se desarrollan con
[plantillas.md](plantillas.md) y [checklists.md](checklists.md).

> En cada caso se hace explícita la **frontera de rol**: qué **pide** tompo a cada
> especialista (su *cómo*) y qué **decide** él (el *qué/porqué*). Ver
> [gobernanza-y-colaboracion.md](gobernanza-y-colaboracion.md).

---

## Ejemplo 1 — 0→1 app B2C (consumer): de idea a MVP validado

**Contexto:** app móvil para que personas con poco tiempo cocinen en casa; "queremos
hacer una app de recetas". Greenfield, sin usuarios, sin datos. Ver
[descubrimiento.md](descubrimiento.md).

**Outcome buscado:** *activación* — que un nuevo usuario cocine su primera receta en
los primeros 7 días (no "publicar la app").

**Discovery (4 riesgos):** entrevistas (con **uxuifull**) revelan que el JTBD no es
"encontrar recetas" sino "decidir qué cocinar con lo que tengo en casa, rápido".
- **Valor:** alto riesgo — ¿lo usarán? → experiment card (ver abajo).
- **Usabilidad:** prototipo con uxuifull.
- **Factibilidad:** **eneida** confirma viable; recomendación de recetas simple.
- **Viabilidad:** coste de contenido de recetas; con negocio.

**Product Goal:** "Lograr que el 40% de los nuevos usuarios cocinen su primera receta
en 7 días, antes de fin de Q3, validando el problema de *qué cocinar hoy*."

**Backlog / priorización (MoSCoW para MVP):** *Must* = onboarding con ingredientes que
ya tienes + sugerencia diaria + paso a paso. *Should* = lista de compras. *Could* =
social. *Won't (ahora)* = video. El MVP es el "camino más delgado" del story map.

**Historias:**
```
Como persona con poco tiempo, quiero recibir una sugerencia de qué cocinar hoy
según los ingredientes que tengo, para no perder tiempo decidiendo.
```
```gherkin
Escenario: sugerencia con ingredientes disponibles
  Dado que indiqué 5 ingredientes que tengo en casa
  Cuando abro la pantalla de inicio
  Entonces veo 3 recetas cocinables hoy ordenadas por menos ingredientes faltantes
```

**Métricas / experimento:** North Star inicial = *recetas cocinadas / usuario activo
semanal*. **Experiment card** antes de construir: landing + prototipo a 50 usuarios;
umbral de validación = ≥30% agenda una receta. Guardrail: tiempo-a-primera-receta.

**Colaboración (frontera):** tompo **pide** a **uxuifull** research y flujo de
onboarding; a **eneida** opciones de recomendación factibles; a **motor/farola** el
MVP con criterios; a **brujula** instrumentar la North Star (tompo es A del
*significado de negocio*, brujula del *cómo técnico*). tompo **decide** el alcance
del MVP, la prioridad y el umbral de éxito.

**Próximos pasos:** correr el experimento; si valida, construir MVP; si no, pivotar el
JTBD.

---

## Ejemplo 2 — SaaS B2B: mejorar Net Revenue Retention (NRR)

**Contexto:** plataforma B2B con churn de expansión; NRR estancado en 98%. Producto en
mercado. Ver [metricas-datos.md](metricas-datos.md) y [dominios.md](dominios.md).

**Outcome buscado:** subir NRR de 98% a 108% en 2 trimestres vía **expansión y
retención** (no "lanzar más features").

**Discovery:** análisis con **prisma** muestra que las cuentas que adoptan la
función de *reporting compartido* expanden 2,3x más. Entrevistas (uxuifull) confirman
que el reporting actual no es exportable ni colaborativo → oportunidad clara en el OST.

**Product Goal:** "Aumentar la expansión de cuentas activando colaboración en reporting,
llevando NRR a 108% antes de fin de H2."

**Backlog / priorización (RICE):**
```
| Ítem                         | Reach | Impact | Conf | Effort | RICE | Orden |
|------------------------------|-------|--------|------|--------|------|-------|
| Compartir reporte (roles)    | 800   | 3      | 0.8  | 4      | 480  | 2     |
| Export programado            | 800   | 2      | 0.8  | 2      | 640  | 1     |
| Dashboards plantilla         | 500   | 1      | 0.5  | 5      | 50   | 3     |
```
El export sale primero por mejor RICE (rápido, alto alcance); compartir va después por
mayor impacto en expansión. tompo hace explícito el trade-off.

**Historias / criterios:**
```
Como admin de cuenta, quiero compartir un reporte con permisos de solo-lectura o edición,
para colaborar sin exponer datos de toda la cuenta.
```
```gherkin
Escenario: compartir con solo-lectura
  Dado un reporte propio
  Cuando lo comparto con un usuario como "solo-lectura"
  Entonces ese usuario lo ve pero no puede editar ni reexportar datos restringidos
```

**Métricas / experimento:** KR = % de cuentas que comparten ≥1 reporte; guardrail =
fuga de datos = 0. A/B con **feature flag** (rollout 20%) midiendo expansión a 30 días.

**Colaboración (frontera):** tompo **pide** a **prisma** el análisis de drivers
de expansión; a **sello** revisar el modelo de permisos (datos sensibles
compartidos); a **amado** criterios testeables de autorización; a **motor** la
implementación. tompo **decide** prioridad RICE, el umbral del A/B y el go/no-go.

**Próximos pasos:** medir expansión post-flag; escalar a 100% si supera umbral.

---

## Ejemplo 3 — Marketplace two-sided: resolver liquidez de un lado

**Contexto:** marketplace de servicios locales; mucha demanda, poca oferta disponible
(baja liquidez del lado oferta). Ver [dominios.md](dominios.md).

**Outcome buscado:** subir el **fill rate** (solicitudes que consiguen proveedor) del
55% al 80%, condición previa para crecer GMV.

**Discovery:** dato + entrevistas muestran que los proveedores no responden a tiempo
en zonas/horarios pico → problema de *seeding* y de matching, no de demanda. El "lado
corto" es la oferta: hay que sembrarla.

**Product Goal:** "Llevar el fill rate a 80% en las 5 ciudades top concentrando oferta
(seeding) y mejorando el match, antes de fin de Q4, para desbloquear crecimiento de GMV."

**Backlog / priorización (WSJF):** prioriza por Cost of Delay / tamaño:
```
| Ítem                                  | CoD | Size | WSJF | Orden |
|---------------------------------------|-----|------|------|-------|
| Seeding de oferta en zonas pico       | 20  | 5    | 4.0  | 2     |
| Notificación push a proveedores cerca | 16  | 3    | 5.3  | 1     |
| Garantía de respuesta < 10 min        | 13  | 8    | 1.6  | 3     |
```
La notificación entra primero (mejor WSJF, rápida); el seeding en paralelo es la apuesta
estructural.

**Historias / criterios:**
```
Como cliente, quiero que mi solicitud se ofrezca primero a proveedores cercanos y libres,
para recibir respuesta en minutos.
```
```gherkin
Escenario: match prioriza cercanía y disponibilidad
  Dada una solicitud en una zona con proveedores libres a < 3 km
  Cuando se publica la solicitud
  Entonces se notifica primero a esos proveedores y se mide el tiempo a primera aceptación
```

**Métricas / experimento:** North Star del lado = **fill rate**; secundarias = tiempo a
primer match, GMV. Guardrail: no degradar calidad (rating del servicio). Experimento por
ciudad (rollout geográfico) midiendo fill rate vs control.

**Colaboración (frontera):** tompo **pide** a **eneida** opciones de algoritmo de
matching (factibilidad), a **motor** la implementación, a **brujula** definir
fill rate y GMV "una métrica, una definición". tompo **decide** qué lado sembrar, el
orden y el umbral por ciudad.

**Próximos pasos:** validar en ciudad piloto; si fill rate ≥80%, replicar.

---

## Ejemplo 4 — Feature de IA/LLM: asistente con evals como criterios

**Contexto:** asistente con LLM para responder preguntas de clientes sobre su cuenta y
ejecutar acciones (consultar saldo, abrir ticket). Ver [ia-producto.md](ia-producto.md).

**Outcome buscado:** reducir el volumen de tickets de soporte de nivel 1 en 30% sin
dañar la satisfacción ni la seguridad (no "lanzar un chatbot").

**Discovery (riesgo no-determinista):** el riesgo dominante es **viabilidad + valor**:
alucinación, acciones indebidas, fuga de datos. tompo define que la calidad se mide con
**evals**, no con "se siente bien".

**Product Goal:** "Desviar el 30% de los tickets N1 a un asistente con calidad y
seguridad evaluadas (faithfulness ≥0.9, 0 acciones sin confirmación), antes de fin de Q3."

**Backlog / priorización:** *Must* = respuestas informativas (solo lectura) con
human-in-the-loop para acciones; *Should* = acciones reversibles con confirmación;
*Won't (ahora)* = acciones irreversibles autónomas.

**Historias / criterios (evals como criterios de aceptación):**
```
Como cliente, quiero preguntar por mi saldo y movimientos en lenguaje natural,
para resolver dudas sin esperar a un agente.
```
```gherkin
Escenario: respuesta fiel y sin fuga de datos
  Dado un set dorado de 200 preguntas de cuenta
  Cuando el asistente responde
  Entonces faithfulness ≥ 0.9, alucinación ≤ 2% y 0 exfiltración de datos de otra cuenta

Escenario: acción solo con confirmación (human-in-the-loop)
  Dado que el usuario pide "abre un ticket de reclamo"
  Cuando el asistente propone la acción
  Entonces requiere confirmación explícita antes de ejecutar y la registra
```

**Métricas / experimento:** outcome = % desvío de tickets N1; guardrails = CSAT,
faithfulness, tasa de escalamiento, coste/consulta. Rollout canary por calidad
(thumbs/retry) con kill-switch.

**Colaboración (frontera):** tompo **pide** a **sysuniversal-ai** la construcción y
operación del modelo/evals (es A del lifecycle técnico), a **vector** el
aseguramiento (prompt injection, excessive agency, OWASP LLM) como **gate**, a **amado**
volver las evals en suite ejecutable, a **sello** la privacidad de datos de
cuenta. tompo **decide** el valor, el riesgo de negocio aceptable y el alcance (solo
lectura primero, human-in-the-loop en acciones) — RACI #13.

**Próximos pasos:** correr evals + red-team; si pasan el gate, canary 5%; medir desvío.

---

## Ejemplo 5 — Fintech regulado: flujo de pagos con PSD2/SCA

**Contexto:** añadir pagos a una app fintech en la UE; requiere **PSD2 / Strong Customer
Authentication (SCA)**. Ver [cumplimiento-regulacion.md](cumplimiento-regulacion.md).

**Outcome buscado:** habilitar pagos con **alta tasa de éxito** y **cumplimiento total**
(la conversión no puede ser excusa para incumplir SCA).

**Discovery:** el riesgo dominante es **viabilidad regulatoria**. tompo incorpora el
cumplimiento como **criterio de aceptación desde discovery**, junto con **sello**.

**Product Goal:** "Lanzar pagos con SCA conforme a PSD2 logrando ≥92% de éxito de
transacción y 0 hallazgos de cumplimiento, antes de fin de Q2."

**Backlog / priorización (WSJF + override documentado):** por método, el orden WSJF
sería Reintento (4.3) > Exenciones (3.6) > SCA (3.0). Pero **SCA es un requisito
regulatorio bloqueante**: sin SCA no se pueden lanzar pagos en la UE. Por eso tompo
**anula deliberadamente el orden WSJF** y pone SCA primero como **override documentado**
—no porque el Cost of Delay lo eleve (ya está en la tabla y aun así da el WSJF más bajo),
sino por una restricción dura— dejando el resto en orden WSJF. Un PO puede sobreescribir
el método cuando hay un bloqueo regulatorio, siempre documentándolo.
```
| Ítem                         | CoD | Size | WSJF | Orden |
|------------------------------|-----|------|------|-------|
| SCA (2FA) en el pago         | 24  | 8    | 3.0  | 1     |
| Exenciones SCA (bajo riesgo) | 18  | 5    | 3.6  | 3     |
| Reintento y manejo de error  | 13  | 3    | 4.3  | 2     |
```
> El **orden 1 (SCA)** es un override consciente del método WSJF por riesgo regulatorio
> bloqueante (PSD2/SCA), documentado; **no** es consecuencia del Cost of Delay. Regla base
> en [priorizacion-valor.md](priorizacion-valor.md): WSJF alto = primero, salvo override
> documentado.

**Historias / criterios (cumplimiento como criterio):**
```
Como usuario, quiero pagar de forma segura cumpliendo la autenticación reforzada,
para completar la compra sin riesgo de fraude.
```
```gherkin
Escenario: pago requiere SCA salvo exención válida
  Dado un pago de 120 EUR sin exención aplicable
  Cuando el usuario confirma el pago
  Entonces se exige autenticación reforzada (2 factores) antes de autorizar
  Y se registra evidencia de SCA para auditoría
```

**Métricas / experimento:** outcome = tasa de éxito de transacción; guardrails =
fraude, abandono en SCA, hallazgos de cumplimiento = 0. No se A/B testea *saltarse* SCA;
se optimizan exenciones permitidas.

**Colaboración (frontera):** tompo **pide** a **sello** el sign-off de
cumplimiento PSD2/SCA (es A/C del cumplimiento, RACI #14), a **destroyer** los controles
de fraude, a **motor** la integración con el PSP, a **amado** los casos de SCA y
exenciones. tompo **decide** el alcance, la prioridad (WSJF y su override documentado) y
el go/no-go de negocio —
pero **no** sale a producción sin el sign-off de sello.

**Próximos pasos:** validar SCA en sandbox del PSP; auditoría de cumplimiento antes del
release.

---

## Ejemplo 6 — Brownfield/legacy: re-priorización por datos y sunset

**Contexto:** producto maduro con 6 años, muchas features, mantenimiento caro y métricas
en declive. "Hay que mejorarlo". Ver [estrategia-vision.md](estrategia-vision.md).

**Outcome buscado:** recuperar retención (D30 cae de 45% a 32%) reduciendo la
**deuda de producto**, no añadiendo features.

**Discovery (por datos):** análisis con **prisma** muestra que el 70% del uso se
concentra en 4 features; 11 features tienen <2% de uso pero generan complejidad, bugs y
coste de soporte. El problema es dispersión, no falta de funciones.

**Product Goal:** "Subir la retención D30 a 42% en 2 trimestres simplificando el producto
(sunset de features de bajo valor) y puliendo el core, no añadiendo alcance."

**Backlog / priorización (RICE + decisión de sunset):**
```
| Ítem                                 | Decisión        | Razón (dato)                |
|--------------------------------------|-----------------|-----------------------------|
| Pulir flujo core (top 4 features)    | INVERTIR (RICE alto) | 70% del uso, alto impacto |
| Feature X (<1% uso, 18% de bugs)     | SUNSET          | coste > valor; deuda        |
| Feature Y (2% uso, sin sustituto)    | MANTENER mínimo | nicho con contrato          |
```

**Historias / criterios (incluye sunset):**
```
Como usuario del core, quiero un flujo principal más rápido y claro,
para completar mi tarea sin fricción.
```
```gherkin
Escenario: sunset controlado de feature de bajo valor
  Dado que la feature X se retirará
  Cuando un usuario que la usaba abre el producto
  Entonces ve un aviso con alternativa y un periodo de transición antes del retiro
```

**Métricas / experimento:** outcome = retención D30; guardrails = no perder usuarios
del nicho de Y, tickets de soporte, NPS. Se mide el efecto del sunset antes de retirar
del todo (retiro escalonado con feature flag).

**Colaboración (frontera):** tompo **pide** a **prisma/brujula** el análisis
de uso y la definición de retención; a **eneida** el impacto de remover features (deuda
técnica vs producto); a **sello** si el sunset afecta datos/contratos; a **amado**
la regresión del core tras simplificar. tompo **decide** qué se retira, qué se invierte y
en qué orden — comunicándolo a stakeholders con su porqué (datos).

**Próximos pasos:** anunciar sunset con transición; medir retención del core a 60 días;
re-priorizar según aprendizaje (loop modo E→A).

---

> Plantillas para reproducir estos casos en [plantillas.md](plantillas.md); checklists
> en [checklists.md](checklists.md); rol del PO por marco en
> [frameworks-marcos.md](frameworks-marcos.md) y por dominio en [dominios.md](dominios.md).
