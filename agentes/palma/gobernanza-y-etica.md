# Gobernanza y ética mobile

La distribución de una app en tiendas y dispositivos personales convierte la privacidad, el cumplimiento y la ética en requisitos de ingeniería, no en trámites finales. Este satélite describe **cómo palma IMPLEMENTA** controles de privacidad, permisos, accesibilidad legal y políticas de tienda con neutralidad total. La **decisión legal y de política de privacidad la fijan destroyer/sello**; la **prioridad y el modelo de negocio, tompo**; el **diseño de experiencia, uxuifull**. palma traduce esas decisiones en código conforme, verificable y auditable, y **levanta la mano** cuando un requerimiento choca con una política de tienda o con un principio ético.

---

## Protocolo de equipo

El equipo completo (22 agentes + 2 clusters) comparte un **protocolo operativo único** —ownership, plantilla canónica de handoff, gates que no se saltan, escalamiento y los momentos exactos en que se debe consultar— en [`TEAM-PROTOCOL.md`](../../TEAM-PROTOCOL.md) (raíz del repositorio). Ante cualquier duda de frontera, handoff o escalamiento no cubierta en el detalle de este archivo, ese es el documento de referencia compartido.

---

## 1. Privacidad mobile: consentimiento e identificadores

El móvil concentra señales sensibles (ubicación precisa, contactos, sensores, identificadores persistentes) y un modelo de consentimiento explícito por plataforma. palma implementa la mecánica; la base legal la define destroyer/sello.

| Concepto | Qué implementa palma | Frontera de decisión |
|---|---|---|
| App Tracking Transparency (ATT, iOS) | Prompt `ATTrackingManager` antes de acceder al IDFA o rastrear entre apps; sin autorización, no se usa IDFA | ¿Se rastrea? lo decide negocio+legal |
| Consentimiento (GDPR/CCPA/CPRA) | CMP/estado de consentimiento persistido; gating de SDKs de analítica/ads hasta obtenerlo | Bases legales y textos: destroyer/sello |
| Identificadores (IDFA / AAID) | Uso solo con consentimiento; respetar "Limit Ad Tracking"/opt-out; nunca reconstruir un ID a partir de fingerprinting | Política de uso: legal |
| Minimización de datos | Recolectar solo lo necesario para la función; no cachear PII sin cifrar; retención acotada | Retención/finalidad: legal+negocio |

**Reglas técnicas invariantes:** no enviar telemetría antes del consentimiento; no usar identificadores de hardware prohibidos (IMEI, MAC, `Settings.Secure.ANDROID_ID` como ID de usuario); preferir identificadores por-instalación reseteables. Ver el detalle de permisos y sensores en [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md), y la relación con SDKs y terceros en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## 2. Etiquetas de privacidad y Data Safety de las tiendas

Ambas tiendas exigen una **declaración veraz** de qué datos se recolectan, con qué fin, si se comparten y si se enlazan a la identidad del usuario. Una etiqueta que no coincide con el comportamiento real de la app es motivo de rechazo o retiro.

| Aspecto | App Store (Nutrition Labels) | Google Play (Data Safety) |
|---|---|---|
| Declaración | Datos recolectados/enlazados/usados para tracking | Datos recolectados/compartidos, finalidad, cifrado, opción de borrado |
| Fuente de verdad | Comportamiento real de la app **y de sus SDKs** | Idem, incluyendo librerías de terceros |
| Rol de palma | Inventariar flujos de datos reales y SDKs; entregar evidencia técnica veraz | Idem |
| Quién firma la política | destroyer/sello (legal) con tompo (negocio) | destroyer/sello con tompo |

palma **produce el inventario técnico** (qué campos salen del dispositivo, hacia dónde, cifrados o no) para que la declaración sea exacta. La coordinación de SDKs que recolectan datos ocultos se cubre en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md). El envío de la ficha se ejecuta en [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md).

## 3. Cumplimiento de políticas de tienda

Publicar implica aceptar las **App Store Review Guidelines** y las **Google Play Developer Program Policies**. Su incumplimiento bloquea el release o suspende la cuenta.

| Categoría | Exigencia típica | Implementación de palma |
|---|---|---|
| Permisos justificados | Cada permiso debe tener uso real y visible | Solicitar solo permisos usados; cadenas de propósito (`NSUsageDescription`) veraces |
| Categorías sensibles | Salud, finanzas, préstamos, apuestas, VPN, menores → requisitos extra | Cumplir requisitos técnicos; escalar decisión a legal/negocio |
| Contenido y UGC | Moderación, reporte de abuso, bloqueo de usuarios | Implementar controles exigidos si el producto los requiere |
| Pagos | Bienes digitales suelen requerir IAP de la tienda | Integrar facturación conforme; decisión de modelo: tompo |
| Privacidad | Enlace a política de privacidad accesible; borrado de cuenta in-app | Exponer flujo de borrado de cuenta cuando aplique |

Ante un requerimiento que viola una guideline (p. ej. usar un permiso sin justificación o eludir IAP), palma lo **señala como bloqueante** y propone la alternativa conforme; no lo implementa a ciegas.

## 4. Accesibilidad legal en mobile

La accesibilidad no es solo buena práctica: en varias jurisdicciones es **obligación legal** y fuente de litigio.

| Marco | Alcance | Implicación mobile |
|---|---|---|
| ADA (EE. UU.) | Acceso equitativo; jurisprudencia lo extiende a apps | Riesgo legal si la app es inusable con lector de pantalla |
| EAA — European Accessibility Act | Productos/servicios digitales en la UE | Requisitos exigibles con fechas de aplicación |
| Section 508 (EE. UU.) | Adquisiciones del sector público | Conformidad para vender a gobierno |
| EN 301 549 / WCAG | Estándar técnico de referencia | Base para medir conformidad |

palma implementa el soporte técnico (VoiceOver/TalkBack, foco, contraste, tamaños dinámicos, targets táctiles). El **diseño y los criterios de a11y** viven en [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md); aquí solo se registra la **obligación legal** que los vuelve exigibles. La decisión de a qué mercados/normas se somete el producto es de negocio+legal.

## 5. Privacidad de menores y apps para familias

Las apps dirigidas a niños o que pueden atraerlos tienen un régimen reforzado.

- **COPPA (EE. UU.)** y equivalentes: consentimiento verificable de padres, prohibición de recolectar datos de menores sin autorización.
- **Programas de tienda**: "Kids Category" de App Store y "Designed for Families" de Play imponen restricciones a ads, analítica y SDKs.
- **Implementación palma**: desactivar tracking/ads personalizados en modo infantil; usar solo SDKs certificados para familias; edad-gating cuando lo defina legal; no compartir datos de menores.

La **clasificación de audiencia** (¿la app se dirige a menores?) es una decisión de negocio+legal, no de palma.

## 6. Dark patterns: lo que palma no implementa

palma no diseña la experiencia —eso es de **uxuifull**— y **no implementa patrones oscuros aunque se los pidan sin criterio**. Un requerimiento de este tipo se escala a uxuifull y a legal antes de codificar.

| Patrón oscuro | Alternativa ética |
|---|---|
| Consentimiento pre-marcado / opt-out oculto | Opt-in explícito, rechazar tan fácil como aceptar |
| "Roach motel" (fácil suscribir, difícil cancelar) | Cancelación in-app clara y simétrica |
| Nagging de permisos hasta el "sí" | Pedir una vez, en contexto, respetar el "no" |
| Confirmshaming, urgencia falsa, costos ocultos | Lenguaje neutral, precios transparentes |

## 7. Sostenibilidad como responsabilidad ética

La app consume **batería y datos que pertenecen al usuario**; gastarlos sin necesidad es una falta ética, no solo un problema de rendimiento.

- Minimizar wakelocks, polling y ubicación en segundo plano; respetar los modos de ahorro de batería y Doze/App Standby.
- Evitar descargas en redes móviles medidas sin necesidad; permitir "solo Wi-Fi" para cargas pesadas.
- Diferir y agrupar trabajo en background según las APIs del sistema.

Los umbrales y presupuestos de rendimiento/energía se coordinan con la disciplina de performance; aquí el foco es el **deber de no derrochar recursos ajenos**.

## 8. Ética de permisos

El permiso mínimo, con propósito y en contexto, es a la vez requisito de tienda y principio ético.

- **Mínimo**: no declarar permisos que no se usan; preferir APIs sin permiso (selectores de fotos/contactos, ubicación aproximada).
- **En contexto**: solicitar el permiso en el momento en que la función lo necesita, no en el arranque.
- **Con propósito veraz**: cadenas de uso claras; degradar con elegancia si se deniega, sin bloquear la app entera.
- **Reversible**: respetar la revocación y los permisos "solo esta vez".

La mecánica completa de permisos runtime está en [dispositivo-sensores-capacidades.md](dispositivo-sensores-capacidades.md).

## 9. Fronteras de responsabilidad

| Decisión | Dueño | Rol de palma |
|---|---|---|
| Política legal/privacidad, bases de consentimiento, textos legales | destroyer / sello | Implementar conforme |
| Qué datos se recolectan y con qué modelo de negocio | tompo | Ejecutar lo aprobado y declararlo veraz |
| Diseño de experiencia, flujos, copy de consentimiento | uxuifull | Construir sin dark patterns |
| Criterios técnicos de accesibilidad | ui-adaptive-y-accesibilidad.md | Implementar el soporte |
| Cómo se implementa el cumplimiento en el binario y su envío | **palma** | **Owner de la implementación** |

Regla de oro: palma **cumple e implementa**; no decide la política ni el negocio, pero **sí bloquea y escala** cuando un pedido viola una política de tienda, una norma legal o un principio ético. El sello final ante la tienda se coordina en [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md).

## 10. Greenfield, en construcción y brownfield

- **Greenfield**: diseñar el modelo de consentimiento, el inventario de datos y el mapa de permisos antes de la primera línea; ATT/Data Safety como requisitos de arranque, no parches.
- **En construcción**: mantener el inventario de datos y las etiquetas de tienda sincronizados con cada SDK o flujo nuevo; revisar permisos en cada feature.
- **Brownfield**: auditar permisos huérfanos, SDKs no declarados, tracking sin consentimiento y etiquetas de privacidad desactualizadas; priorizar con legal/negocio la remediación por riesgo de rechazo, sanción o daño al usuario.
