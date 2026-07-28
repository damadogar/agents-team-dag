# Cloud, red y edge

baluarte opera la plataforma donde el ecosistema vive: cuentas, red, conectividad, DNS, balanceo, borde y disponibilidad. Esta es su capa de cimientos: si la red o la landing zone están mal, ninguna aplicación por encima es confiable. Aquí baluarte no decide la topología macro (qué regiones, qué modelo de nube) —eso lo define `eneida`— pero la OPERA con excelencia y aporta las restricciones operativas que hacen viable o inviable una arquitectura sobre el terreno.

Neutralidad: este documento habla de conceptos, no de productos. Donde se cita "p. ej." se ofrecen equivalentes entre las nubes mayores y on-prem sin favorecer ninguna.

## 1. Modelos de despliegue: cuándo cada uno

| Modelo | Qué es | Cuándo conviene | Coste/riesgo dominante |
|---|---|---|---|
| Nube pública | Infra multi-tenant de un proveedor, consumo elástico | Elasticidad, time-to-market, capex→opex, servicios gestionados | Lock-in, coste variable, egress |
| Nube privada | Infra dedicada (on-prem o alojada) bajo control propio | Regulación estricta, latencia local, cargas estables predecibles | Capex, capacidad rígida, operación propia |
| Híbrida | Público + privado con conectividad viva entre ambos | Migración gradual, datos sensibles en casa + burst a nube | Complejidad de conectividad y de identidad dual |
| Multi-cloud | Cargas repartidas en >1 proveedor público | Evitar lock-in crítico, soberanía, resiliencia ante fallo de proveedor | **Rara vez es gratis** (ver abajo) |
| On-prem | Todo en centro de datos propio | Soberanía total, hardware especializado, latencia sub-ms | Escalado lento, DR costoso |
| Edge | Cómputo cerca del usuario/dispositivo (PoPs, on-device, micro-DC) | Latencia mínima, procesar donde se genera el dato, soberanía local, resiliencia offline | Operación distribuida, observabilidad difícil, gestión de flota |

**Por qué multi-cloud rara vez es gratis.** Se vende como resiliencia y anti-lock-in, pero el precio real es complejidad: doble modelo de red, doble IAM, doble tooling de observabilidad, doble curva de aprendizaje operativa, egress entre nubes carísimo y el mínimo común denominador de servicios (se pierde lo mejor de cada uno). baluarte lo trata como decisión con justificación explícita —no por moda—: reservado para requisitos reales de soberanía, continuidad de negocio ante fallo total de proveedor, o exigencia contractual. Un patrón intermedio sano: **primario en una nube + capacidad de portabilidad** (contenedores, IaC neutral, datos exportables) sin operar activamente dos planos idénticos.

## 2. Landing zones: los cimientos de cuenta

La landing zone es el suelo firme sobre el que todo lo demás se construye: la organización de cuentas/subscripciones/proyectos (p. ej. *accounts*, *subscriptions*, *projects*/*folders*) con jerarquía, guardrails y separación de entornos definidos ANTES de desplegar cargas. Improvisarla es el error fundacional más caro de revertir.

Principios que baluarte aplica:

- **Jerarquía y agrupación**: una raíz organizacional con nodos por dominio/unidad/entorno; políticas heredadas hacia abajo (p. ej. *SCPs*, *Azure Policy*, *org policies*).
- **Separación de entornos por frontera dura**: prod, staging y dev en cuentas/subscripciones/proyectos DISTINTOS, no solo en etiquetas o subredes. La frontera de cuenta es el límite de radio de explosión (*blast radius*) más fuerte disponible.
- **Blast radius**: un incidente, credencial filtrada o error de IaC queda contenido en su cuenta. Cuentas compartidas gigantes = un fallo derriba todo.
- **Cuentas por equipo vs compartidas**: equipos con autonomía y aislamiento de coste/seguridad → cuenta propia; servicios transversales (red central, logging, identidad) → cuentas compartidas gobernadas. Regla práctica: aísla por radio de explosión y por límite de facturación/cuota, no por organigrama.
- **Guardrails preventivos** (bloquean) sobre detectivos (avisan): regiones permitidas, cifrado obligatorio, prohibición de recursos públicos por defecto, baseline de red y de logging aplicado desde el nacimiento de cada cuenta (*account factory* / vending).
- **Baseline automático**: toda cuenta nueva nace con red, roles, logging, presupuesto y alertas ya cableados por IaC — nunca a mano. Ver [iac-y-configuracion.md](iac-y-configuracion.md).

## 3. Well-Architected operativo aplicado

De los pilares del marco de buena arquitectura, baluarte es dueño operativo de estos y trata la **seguridad como frontera de `destroyer`** (baluarte implementa, no define la política):

| Pilar | Qué opera baluarte en cloud |
|---|---|
| Excelencia operativa | IaC, automatización, runbooks, observabilidad de plataforma, cambios seguros |
| Confiabilidad | Multi-AZ, multi-región, health checks, failover, cuotas, degradación elegante |
| Eficiencia de rendimiento | Dimensionar red y cómputo a la demanda; coordina metas con `peakformance` |
| Optimización de coste | Egress, tráfico cross-zona, right-sizing de red — ver [capacidad-y-costos.md](capacidad-y-costos.md) |
| Sostenibilidad | Consolidar cargas, regiones más limpias, apagar lo ocioso, densidad |
| (Seguridad) | Frontera de `destroyer`; baluarte la ejecuta — ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md) |

## 4. Red: el plano de conectividad

El modelo base es una red virtual aislada (p. ej. *VPC*, *VNet*, *VCN*) con espacio de direcciones planificado. Decisiones que baluarte opera:

- **Subredes** públicas y privadas, dimensionadas con CIDR sin solapes (crítico si habrá peering o conectividad híbrida — los rangos que se solapan no se pueden unir después).
- **Enrutamiento**: tablas de rutas por subred; rutas explícitas hacia gateways, peers y on-prem.
- **Ingress/egress**: entrada controlada por balanceadores y gateways; salida controlada. El **egreso por defecto debe ser cerrado o filtrado**, no abierto.
- **NAT** para que subredes privadas salgan a internet sin ser alcanzables desde fuera.
- **Peering** entre redes (mismo o distinto proveedor/cuenta) para tráfico privado sin pasar por internet; vigilar transitividad (el peering normalmente NO es transitivo).
- **Conectividad híbrida**: VPN sobre internet (rápida de montar, cifrada, ancho de banda variable) o interconexión dedicada (p. ej. *Direct Connect*, *ExpressRoute*, *Interconnect*/*Cloud Interconnect*) para latencia y ancho de banda estables y predecibles.
- **Private endpoints / enlace privado**: consumir servicios gestionados por dirección privada sin exponer tráfico a internet.
- **Zonas de disponibilidad y regiones**: la subred suele anclarse a una zona; distribuir subredes entre zonas es la base de la alta disponibilidad regional.

La **segmentación exigida** (qué se puede hablar con qué, microsegmentación, política de firewall) la decide `destroyer`; baluarte la implementa en tablas de ruta, grupos de seguridad y firewalls. Ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md).

## 5. DNS y balanceo

DNS es la capa de dirección y también un mecanismo de failover de primer nivel:

- **Resolución interna** (nombres privados de servicios) y **externa** (cara pública).
- **DNS como failover**: registros con health checks que retiran endpoints caídos; *failover routing* activo-pasivo.
- **Enrutamiento avanzado**: *weighted* (canary, reparto de carga), *geo/latency* (dirigir al usuario a la región más cercana o sana), *anycast* (misma IP anunciada desde muchos PoPs; la red lleva al más próximo).
- Cuidado con el **TTL**: TTL alto = failover lento; ajústalo según el RTO deseado.

Balanceo de carga:

| Nivel | Opera sobre | Uso típico |
|---|---|---|
| L4 (transporte) | TCP/UDP, IP:puerto | Alto rendimiento, protocolos no-HTTP, passthrough TLS |
| L7 (aplicación) | HTTP(S), rutas, headers, cookies | Enrutado por path/host, terminación TLS, WAF, canary |
| Global | Entre regiones | Failover y proximidad multi-región (anycast/geo) |
| Regional | Dentro de una región/zonas | Reparto entre instancias/pods |

**Health checks** son innegociables: activos (sondeo) y de profundidad adecuada (un check que solo verifica que el puerto abre no detecta una app enferma). El balanceador global + DNS + health checks forman la columna del failover multi-región.

## 6. Service discovery y mesh a nivel red

Cómo los servicios se encuentran y hablan (tráfico este-oeste, servicio↔servicio):

- **Registro y resolución**: los servicios se registran y se descubren por nombre lógico, no por IP fija (que cambia con el autoscaling). Vía DNS interno o registro dedicado.
- **Service mesh**: capa que añade mTLS, reintentos, *circuit breaking*, enrutado fino y telemetría al tráfico este-oeste sin tocar el código de la app.
- **mTLS**: identidad mutua entre servicios; cifrado en tránsito interno por defecto.

Frontera: la operación de la malla dentro del clúster y su sidecar/control plane vive junto a [contenedores-y-orquestacion.md](contenedores-y-orquestacion.md); baluarte provee la red subyacente (conectividad, DNS, identidad de red) sobre la que la malla corre. La política de qué habla con qué la fija `destroyer`.

## 7. CDN y edge

Acercar cómputo y contenido al usuario reduce latencia y descarga el origen:

- **Caching en el borde**: estáticos y respuestas cacheables servidos desde PoPs cercanos; menos carga y latencia en origen.
- **Invalidación de caché**: mecanismo explícito (purga por clave/patrón, versionado en la URL/*cache busting*) — la caché sin estrategia de invalidación sirve datos rancios.
- **Edge compute / functions**: lógica ligera en el borde (redirecciones, personalización, autenticación de borde, A/B).
- **Terminación TLS** en el borde: menos *round-trips*, certificados centralizados.
- **WAF**: baluarte lo OPERA en el borde (reglas activas, tuning, respuesta a falsos positivos), pero la **política WAF la decide `destroyer`** — ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md).
- **Reducción de latencia por proximidad**: el usuario habla con el PoP, no con el origen lejano; coordinar objetivos de latencia con `peakformance`, mientras baluarte garantiza la disponibilidad del borde.

## 8. Zonas, regiones y disponibilidad

Diseñar asumiendo que las cosas caen. **Dominios de fallo** en escala creciente: host → rack → zona → región → proveedor.

- **Multi-AZ (multi-zona)**: es el mínimo para producción. Distribuir instancias, subredes y datos entre ≥2-3 zonas tolera la caída de una zona completa sin caída del servicio.
- **Multi-región**:
  - *Activo-pasivo*: región secundaria en espera; failover con RTO/RPO definidos. Más simple, más barato, failover no instantáneo.
  - *Activo-activo*: ambas regiones sirven tráfico; máxima resiliencia y menor RTO, pero exige resolver consistencia de datos y enrutado global.
- La geometría de RTO/RPO, estrategia de respaldo y ensayo de failover se detalla en [continuidad-y-dr.md](continuidad-y-dr.md). La réplica geográfica de los DATOS es de `andulfo`; baluarte provee la red y la infraestructura que la hacen posible.

## 9. Cuotas y límites de la nube

Todo proveedor impone límites: número de recursos, IPs, reglas, *API rate limits*, throttling. baluarte los descubre ANTES de que exploten:

- **Inventario de cuotas** por región/cuenta como parte del diseño, no como sorpresa.
- **Alertas de consumo** al acercarse al límite (p. ej. 80%), no al chocarlo.
- **Solicitud proactiva de aumento** con lead time (algunas tardan días).
- **Rate limits y throttling del proveedor**: diseñar clientes con reintentos y *backoff* exponencial + jitter; no asumir capacidad de API infinita.
- Enlaza con [capacidad-y-costos.md](capacidad-y-costos.md) para planear crecimiento contra los techos del proveedor.

## 10. Conectividad segura

baluarte implementa (la política es de `destroyer`, ver [seguridad-de-plataforma.md](seguridad-de-plataforma.md)):

- **Identidad de cargas**: identidades de máquina/servicio (p. ej. *managed identities*, *workload identity*, *IAM roles*) en vez de credenciales estáticas incrustadas.
- **Secretos**: nunca en código ni en la red plana; gestor de secretos con rotación.
- **Egreso controlado**: salida a internet filtrada por proxy/firewall/listas de destino permitido, no abierta.
- **Cifrado en tránsito** por defecto (TLS/mTLS), incluido el tráfico interno este-oeste.

## 11. Coste de red (el que no se ve)

| Fuente de coste | Detalle | Mitigación |
|---|---|---|
| Egress a internet | Salida de datos suele ser lo más caro | Cachear en CDN, comprimir, minimizar respuestas |
| Cross-AZ | Tráfico entre zonas se cobra en muchas nubes | Afinidad de zona donde la HA lo permita |
| Cross-region | Réplica y tráfico entre regiones | Diseñar qué DEBE cruzar; batch vs chatty |
| Chatty architecture | Miles de llamadas pequeñas servicio↔servicio | Consolidar, cachear, colocar cerca lo que se habla mucho |
| NAT / procesamiento | Gateways cobran por dato procesado | Endpoints privados para servicios gestionados |

El **coste oculto de la arquitectura parlanchina**: un diseño que dispara microllamadas entre zonas/regiones puede costar más en tráfico que en cómputo. Ver [capacidad-y-costos.md](capacidad-y-costos.md).

## 12. Antipatrones

- **Red plana sin segmentación**: todo se alcanza con todo; un compromiso se propaga sin frenos.
- **Single-AZ en producción**: una caída de zona = caída total. Inaceptable para prod.
- **DNS o región únicos sin failover**: punto único de fallo en la capa de dirección o de ubicación.
- **Multi-cloud por moda**: doble complejidad sin requisito real de soberanía/continuidad que la justifique.
- **ClickOps de red**: crear VPCs, reglas y peerings a mano en consola — irreproducible, sin auditoría, imposible de recrear en DR. Debe ser IaC ([iac-y-configuracion.md](iac-y-configuracion.md)).
- **Cuotas descubiertas en producción**: chocar un límite del proveedor durante un pico, sin margen ni aviso.
- **CIDR solapados**: rangos que impiden peering/híbrido futuro; se paga con re-direccionamientos dolorosos.
- **Caché sin invalidación**: datos rancios servidos indefinidamente desde el borde.
- **Egreso abierto por defecto**: exfiltración sin control y factura de egress descontrolada.

## 13. Cómo actúa baluarte aquí (tiered)

- **T1 — dueño y ejecutor directo**: landing zone, red de plataforma (VPCs/subredes/rutas/NAT/peering/híbrido), DNS, balanceo, conectividad viva, borde/CDN, gestión de cuotas, multi-AZ y operación del failover. Lo diseña, lo codifica en IaC y lo opera.
- **T2 — recibe la decisión y la opera**: la topología macro (qué regiones, qué modelo de nube, activo-activo vs pasivo como postura arquitectónica) llega de `eneida`; baluarte la aterriza y devuelve las **restricciones operativas** (límites de cuota, latencias inter-región reales, coste de egress, plazos de conectividad dedicada) que pueden hacer que la decisión se revise.
- **T3 — potestad (dueño saturado o ausente)**: ante un riesgo de red inminente (una cuota a punto de agotarse, un endpoint sin failover) cuyo dueño formal está saturado o no existe, baluarte aplica el cambio **operativo y reversible** (subir cuota, añadir ruta/health-check) marcado **"pendiente de revisión del dueño"**, sin redefinir la topología macro (eso es de `eneida`).
- **Fronteras vivas**: política de segmentación y WAF → `destroyer` (baluarte implementa/opera); réplica geográfica de datos → `andulfo` (baluarte provee red/infra); latencia optimizada → `peakformance` (baluarte garantiza disponibilidad). Continuidad y RTO/RPO en [continuidad-y-dr.md](continuidad-y-dr.md); interoperabilidad entre proveedores/aliados en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md); confiabilidad end-to-end en [confiabilidad-sre.md](confiabilidad-sre.md).

**Greenfield vs brownfield.** En **greenfield** se diseña la landing zone, la segmentación de red y las zonas/regiones desde cero con guardrails y multi-AZ por defecto. En **brownfield** se rescata lo existente sin cortar tráfico: mapear la red viva (a menudo plana o con CIDR ya solapados), introducir segmentación e IaC por importación gradual, y añadir failover/DNS saludable antes de tocar el enrutado productivo.
