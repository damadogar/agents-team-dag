# Monetización y Billing en el Dispositivo

El billing mobile es una de las disciplinas **más propensas a bugs y a pérdida de dinero** de toda la app: involucra máquinas de estado asíncronas, redes poco fiables, dos sistemas de pago propietarios, validación criptográfica y un backend que debe ser la única fuente de verdad. Un error aquí no es cosmético: desbloquea contenido pago sin cobrar, cobra dos veces, o deja a un usuario que pagó sin su compra. Por eso el principio rector es **desconfianza estructural del cliente**: el dispositivo *inicia y refleja* la compra; el servidor *decide* si es legítima.

Este es dominio **T1 de palma**: el SABER MOBILE de integrar el billing EN EL DISPOSITIVO — flujo de compra, restore, entitlements en cliente y reacción a los estados. El **modelo de negocio y el pricing** los decide tompo; la **validación server-side de recibos y el procesamiento de notificaciones de servidor** los implementa motor. Palma no fija precios ni valida recibos: los integra correctamente en la app.

## 1. Modelos de monetización

El *catálogo* de productos lo define tompo (negocio); palma lo **integra** con exactitud técnica.

| Modelo | Descripción | Consideración técnica |
|---|---|---|
| Compra única (non-consumable) | Se compra una vez y permanece (quitar ads, desbloqueo pro) | Debe poder **restaurarse** en cualquier dispositivo del usuario |
| Consumible | Se agota al usarse (monedas, vidas) | El backend lleva el balance; **nunca** contar solo con el estado local |
| No consumible | Permanente, no re-comprable | El sistema de tienda bloquea la doble compra y devuelve "ya comprado" |
| Suscripción auto-renovable | Acceso mientras esté vigente | Máquina de estados compleja (ver §5); requiere notificaciones de servidor |
| Free trial | Periodo gratuito previo al cobro | Elegibilidad la determina la tienda; el cliente la muestra, no la decide |
| Offers promocionales | Descuentos de introducción/retención/winback | Firmadas por la tienda o el servidor; el cliente presenta la oferta |

- **Precios por región**: los define la tienda por *price tier*/moneda local; el cliente **muestra el precio localizado que devuelve la API de la tienda**, nunca un precio hardcodeado (cambia por país, impuestos y tipo de cambio).
- Qué modelo, qué precio y qué oferta = **decisión de tompo**. Palma garantiza que la integración refleje fielmente el catálogo.

## 1.1 Pagos de bienes físicos y wallet passes

No todo pago pasa por el IAP de la tienda: los **bienes y servicios físicos** se cobran con el
*payment sheet* nativo (p. ej. Apple Pay / Google Pay), fuera del sistema de compras de la
tienda (que prohíbe su IAP para lo físico).
- **Payment sheet**: presentación nativa, tokenización de la tarjeta, dirección de envío y
  contacto; el **procesamiento del pago y el PSP** viven en el backend (`motor`), el
  cumplimiento **PCI** y la política de datos de tarjeta los decide `destroyer`. palma integra
  la hoja de pago en el cliente.
- **Wallet passes** (p. ej. PassKit / Google Wallet): tarjetas de embarque, entradas,
  fidelización, cupones y **llaves NFC**; generación/firma del pase en el backend, adición y
  **actualización push** del pase, y la experiencia en la wallet del sistema.
- Frontera: `tompo` decide el modelo comercial; `motor` procesa el pago y firma los pases;
  `destroyer` fija PCI/seguridad; palma **integra** el sheet y los pases en el dispositivo.

## 2. APIs de billing

Todas exponen el mismo ciclo conceptual; se eligen por plataforma o por conveniencia cross-platform. Son ejemplos **intercambiables**.

| Capa (p. ej.) | Ámbito | Aporta |
|---|---|---|
| StoreKit 2 (p. ej. iOS) | Nativo iOS | Transacciones firmadas (JWS), `Transaction.currentEntitlements`, async/await |
| Google Play Billing (p. ej. Android) | Nativo Android | `BillingClient`, purchase tokens, acknowledgment obligatorio |
| Capa cross-platform (p. ej. RevenueCat) | Multiplataforma | Abstrae ambas tiendas, entitlements unificados, webhooks al backend |

Principios neutrales de integración:

- **Cargar productos desde la tienda** antes de mostrar precios; si la carga falla (red/config), degradar con elegancia, nunca mostrar una pantalla de compra rota.
- **Acknowledgment/finish obligatorio**: una compra no confirmada/consumida se **reembolsa automáticamente** en algunas tiendas. Confirmar solo **después** de entregar el contenido (idealmente tras validación server-side).
- **Escuchar la cola de transacciones/updates** de forma persistente, no solo durante la pantalla de compra: llegan transacciones pendientes, diferidas o de otro dispositivo.

## 3. Ciclo de compra en el cliente

```
[Catálogo] → usuario elige → [Iniciar compra] → hoja de pago de la tienda
   → resultado (éxito | cancelado | pendiente | error)
      → éxito: obtener recibo/transacción firmada
          → ENVIAR AL SERVIDOR (motor) para validar  ← frontera crítica
              → servidor confirma entitlement
                  → desbloquear contenido + acknowledge/finish
```

- **Restore purchases** (obligatorio y frecuentemente olvidado): un botón explícito que re-sincroniza compras previas (non-consumables y suscripciones) en un dispositivo nuevo o tras reinstalar. Las tiendas **exigen** este flujo; su ausencia es causa de rechazo (ver [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md)).
- **Entitlements**: el "derecho de acceso" derivado de las compras. El cliente los **lee** (de la API de la tienda y/o del backend) para decidir qué mostrar desbloqueado; la **verdad** vive en el servidor.
- **Family Sharing / compras compartidas**: una compra puede pertenecer a un grupo familiar; el entitlement puede llegar sin que este dispositivo hiciera la compra. No asumir "quien compra = quien usa".
- **Desbloqueo de contenido**: aplicar el entitlement de forma reactiva y en un solo lugar (fuente de verdad de estado premium), para que toda la UI reaccione consistentemente.

## 4. Validación de recibos — NUNCA confiar solo en el cliente

Este es el punto más importante del satélite. El recibo/transacción **debe validarse en el servidor**, jamás solo en el dispositivo.

Por qué el cliente no basta:

- El dispositivo puede estar **rooteado/jailbroken**; el estado local y las respuestas de la tienda pueden ser **manipuladas** por herramientas de fraude.
- Un flag `isPremium = true` en almacenamiento local es trivial de falsificar.
- El backend necesita conocer el estado real para servir contenido, sincronizar entre dispositivos y prevenir fraude.

Modelo correcto (**frontera con motor**):

1. El cliente obtiene la **transacción firmada** (p. ej. JWS de StoreKit 2 / purchase token de Play) tras la compra.
2. La envía al backend por canal seguro (ver [seguridad-mobile.md](seguridad-mobile.md)).
3. **motor** verifica la firma/JWS contra la clave pública de la tienda **o** consulta la API server-to-server de la tienda, y **registra el entitlement**.
4. El cliente recibe el estado *confirmado por el servidor* y desbloquea.

- Las transacciones firmadas (**JWS / signed transactions**) permiten verificación **on-device** de la firma como señal de UX inmediata, pero **no sustituyen** la validación server-side autoritativa.
- **Nunca** enviar/almacenar secretos de validación (shared secret, service account) en el binario: eso es materia de destroyer y [seguridad-mobile.md](seguridad-mobile.md).

## 5. Suscripciones: estados y transiciones

Una suscripción no es un booleano; es una **máquina de estados** que evoluciona sin acción del usuario. El cliente debe **reaccionar** a cada estado, no inferirlo.

| Estado | Significado | Acceso | Qué muestra el cliente |
|---|---|---|---|
| Activa | Vigente y pagada | Sí | Contenido premium normal |
| Grace period | Falló el cobro; la tienda reintenta y mantiene acceso | Sí | Aviso suave de actualizar método de pago |
| Billing retry | Falló el cobro; sin gracia | Normalmente no | Prompt de recuperación de pago |
| On hold | Reintentos agotados, aún recuperable | No | CTA para reactivar |
| Pausada | El usuario pausó (Android, p. ej.) | No | Fecha de reanudación |
| Expirada / cancelada | Terminó, sin renovación | No | Oferta de re-suscripción / winback |

- **Upgrades/downgrades y proration**: cambiar de plan implica prorrateo (crédito/cargo diferido según la política de la tienda). El cliente inicia el cambio con el modo de proration adecuado; el **efecto económico** lo resuelve la tienda.
- **Cancelación**: el usuario cancela en los ajustes de la tienda; la app **no puede** cancelar por él, pero debe enlazar a la gestión de suscripción y reflejar el estado "cancelará al final del periodo".
- **Refunds**: los concede la tienda; el cliente se entera vía notificación de servidor (§6) → debe **revocar el entitlement** cuando el backend lo indique.

## 6. Server notifications

Las tiendas notifican los cambios de estado (renovación, fallo, refund, cancelación) directamente al backend en tiempo real: **App Store Server Notifications** / **Play Real-time Developer Notifications** (p. ej.).

- **motor** recibe, verifica y procesa estas notificaciones — es su frontera. Son la **fuente de verdad temporal** del estado de suscripción, más fiables que preguntar al cliente.
- **palma reacciona al estado ya reconciliado**: la app consulta al backend (o recibe un push) y **actualiza el entitlement local**. El cliente no procesa la notificación de servidor; consume su resultado.
- Diseñar el cliente para **re-sincronizar entitlements** al arrancar, al volver a foreground y tras señal push, de modo que un cambio ocurrido "fuera de la app" (renovación nocturna, refund) se refleje pronto.

## 7. Errores y edge cases (donde nacen los bugs)

| Caso | Riesgo | Manejo en cliente |
|---|---|---|
| Compra interrumpida (app cerrada a mitad) | Transacción huérfana no confirmada | Escuchar la cola al reabrir y **reanudar/finalizar** |
| Transacción **pendiente** (aprobación parental, efectivo diferido) | Estado "deferred": ni éxito ni fallo | Mostrar "pendiente", **no** desbloquear; esperar update |
| Red caída tras pagar, antes de validar | Cobrado sin entitlement aplicado | Reintento idempotente de validación; **restore** lo recupera |
| Doble cobro / doble tap | Cargo duplicado o UI inconsistente | Deshabilitar CTA en vuelo; idempotencia por transaction id |
| Entitlement desincronizado entre dispositivos | Premium en uno, no en otro | Re-sync desde backend como verdad; no confiar en local |
| Acknowledgment omitido | La tienda **revierte** la compra | Confirmar siempre tras entregar contenido |

Regla transversal: **toda validación/entrega debe ser idempotente**. Reprocesar la misma transacción no debe cobrar, entregar ni duplicar dos veces.

## 8. Pruebas de billing

- **Sandbox de tiendas**: entornos de prueba dedicados (p. ej. Sandbox de App Store, cuentas de test de Play) que simulan compras sin cargo real.
- **Cuentas de test** específicas; nunca probar con cuentas/tarjetas reales.
- **Ciclos de suscripción acelerados**: en sandbox, una suscripción "mensual" renueva en minutos, permitiendo observar renovación, grace period, billing retry y expiración en una sesión.
- Probar explícitamente: primera compra, **restore**, upgrade/downgrade, cancelación, refund (vía notificación), transacción pendiente, red caída y reinstalación.
- La **estrategia formal de pruebas** (matriz de casos, cobertura) la define **`amado`**; palma aporta el **conocimiento de los edge cases mobile** a probar y ejecuta las pruebas de su propio código.

## 9. Fronteras

| Aporta palma (T1) | Deriva a |
|---|---|
| Flujo de compra, restore, entitlements en cliente, reacción a estados | — |
| Envío de la transacción firmada para validar | Validación server-side → **motor** |
| Reacción al estado reconciliado por notificaciones | Procesamiento de server notifications → **motor** |
| Integración fiel del catálogo | Modelo de negocio/pricing/ofertas → **tompo** |
| Requisitos técnicos de la compra | Cumplimiento de políticas de tienda → [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md) |
| Manejo de la transacción en el dispositivo | Secretos y validación criptográfica → [seguridad-mobile.md](seguridad-mobile.md) (decide destroyer) |
| Máquina de estados de suscripción / idempotencia (código *bug-prone*) | Revisión de correctitud del código → **certero** |

Ver también [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md) para el contrato cliente-backend de estado de compra.

## 10. Greenfield, en construcción y brownfield

- **Greenfield**: desde el día 1, validación server-side obligatoria, entitlements con el backend como verdad, botón de restore, listener persistente de transacciones e idempotencia. Nunca un `isPremium` local como única fuente.
- **En construcción**: cablear la validación con motor, cubrir la máquina de estados de suscripción completa (no solo activa/expirada), y probar en sandbox con ciclos acelerados antes del primer release.
- **Brownfield**: auditar si el cliente confía en estado local (riesgo de fraude/desbloqueo gratis), si existe restore, si se confirman las transacciones (acknowledgment), y si se manejan pendientes/refunds; priorizar cerrar la validación server-side ausente.

## 11. Modelo tiered

- **T1 — palma (aquí):** billing en el dispositivo — flujo de compra, restore, entitlements en cliente, reacción a estados de suscripción, edge cases y pruebas en sandbox. El cumplimiento de políticas de tienda y la **integración** de la custodia de secretos (cuya *política* la decide `destroyer`) se resuelven en **satélites hermanos de la propia palma** ([release-engineering-y-tiendas.md](release-engineering-y-tiendas.md), [seguridad-mobile.md](seguridad-mobile.md)) — es organización interna, no handoff externo.
- **T2 — deriva al dueño ajeno:**
  - **Validación server-side de recibos y procesamiento de server notifications → motor.**
  - **Modelo de negocio, pricing y ofertas → tompo.**
  - **Decisión de la postura de seguridad (custodia de secretos de validación) → destroyer.**
  - **Correctitud de la máquina de estados / idempotencia → certero.**

palma no valida recibos ni decide el negocio: aporta el **saber mobile** que hace que la compra fluya, se restaure, se sincronice y reaccione con exactitud a cada estado, sin confiar jamás solo en el cliente.
