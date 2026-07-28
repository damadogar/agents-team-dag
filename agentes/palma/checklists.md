# Checklists maestras de ingeniería mobile

Checklists accionables por fase del ciclo de vida de una app nativa o cross-platform. Cada ítem se verifica con evidencia (código, medición, captura o log), no por opinión. Marca solo lo que puedas demostrar. Consulta los hermanos cuando un ítem cruce una frontera de ownership: la decisión de fondo vive en su dueño y aquí se verifica la implementación mobile.

## 1. Arquitectura de app

- [ ] El dominio (reglas de negocio, entidades, casos de uso) no depende de tipos del framework de UI ni del SDK del sistema operativo.
- [ ] Existe una capa de presentación separada del dominio y de los datos; las dependencias apuntan hacia adentro.
- [ ] La app está modularizada por feature o por capa; los límites de módulo son explícitos y compilables por separado.
- [ ] El grafo de dependencias no tiene ciclos entre módulos; la inyección de dependencias es explícita.
- [ ] El modelo de navegación es único y declarado (stack, tabs, grafo); no hay dos mecanismos compitiendo por el back stack.
- [ ] Los deep links y la navegación programática resuelven al mismo destino que la navegación por UI.
- [ ] El manejo de estado tiene una fuente de verdad por pantalla; el estado de UI es unidireccional y observable.
- [ ] Se distingue estado efímero de UI, estado de sesión y estado persistente; cada uno vive en su capa.
- [ ] El ciclo de vida de proceso está cubierto: la app restaura estado tras muerte en background (process death) sin pérdida percibida.
- [ ] La restauración de estado (saved state, restoration identifiers) se probó matando el proceso, no solo rotando o cambiando de app.
- [ ] La configuración cambiante (rotación, tamaño de ventana, idioma, tema) no reinicia flujos ni pierde datos de formularios.
- [ ] Los límites de arquitectura de sistema los fija [eneida](interoperabilidad-y-aliados.md); aquí se verifica su implementación mobile.

## 2. UI, adaptive y accesibilidad

- [ ] La UI responde a múltiples form-factors: teléfono, tablet, plegable (fold/unfold), ventana redimensionable y escritorio si aplica.
- [ ] Se respetan las safe areas / insets (notch, barra de estado, gestos, teclado); ningún control queda bajo un obstáculo del sistema.
- [ ] Los gestos propios no colisionan con los gestos del sistema (back por borde, control center, multitarea).
- [ ] Dark mode y light mode están implementados; no hay colores quemados que rompan contraste en un modo.
- [ ] VoiceOver / TalkBack recorren la pantalla en orden lógico; cada control accionable tiene label, rol y estado.
- [ ] Dynamic Type / escalado de fuente del sistema no rompe el layout ni trunca contenido esencial hasta el tamaño máximo razonable.
- [ ] Los touch targets cumplen el mínimo recomendado por plataforma; no hay objetivos táctiles solapados.
- [ ] El contraste de color cumple el umbral de accesibilidad para texto e iconografía informativa.
- [ ] La app es operable sin depender solo del color, del sonido o de gestos complejos (hay alternativa accesible).
- [ ] Reduce Motion / animaciones reducidas se honran cuando el usuario lo activa.
- [ ] El detalle visual y de interacción (design system, tokens, motion) proviene de [uxuifull/farola](interoperabilidad-y-aliados.md); aquí se verifica su fidelidad nativa.

## 3. Datos y offline

- [ ] La persistencia local usa un mecanismo apropiado al tipo de dato (clave-valor, base embebida, archivos); no se abusa de uno para todo.
- [ ] La estrategia offline-first está declarada: qué funciona sin red, qué se difiere, qué se bloquea con mensaje claro.
- [ ] Las escrituras offline se encolan y se reintentan con backoff; el usuario ve estado de sincronización.
- [ ] La sincronización tiene una política de resolución de conflictos explícita (last-write-wins, merge, intervención del usuario) y probada.
- [ ] Las migraciones de esquema local son versionadas, idempotentes y probadas contra datos de versiones anteriores.
- [ ] Una migración fallida no deja la base corrupta ni la app en crash-loop; hay ruta de recuperación.
- [ ] Los datos grandes (imágenes, media, blobs) no viven en la base transaccional; se referencian por ruta.
- [ ] La caché tiene política de invalidación y de tamaño máximo; no crece sin límite.
- [ ] El modelo lógico de datos y la política de sync los valida [andulfo](interoperabilidad-y-aliados.md); aquí se verifica la persistencia on-device.

## 4. Capacidades y permisos

- [ ] Cada permiso se solicita en contexto, justo antes de usar la capacidad, con explicación previa (pre-prompt) cuando aporta.
- [ ] La app funciona de forma degradada si el permiso se deniega; nunca queda inutilizable ni entra en bucle de solicitud.
- [ ] Se maneja el estado "denegado permanentemente": se guía al usuario a Ajustes en vez de re-preguntar en vano.
- [ ] Cámara, micrófono, galería: se usa el nivel mínimo de acceso (selección limitada de fotos si la plataforma lo ofrece).
- [ ] Ubicación: se pide el nivel correcto (while-in-use vs always, precisa vs aproximada) y se justifica en la ficha de la tienda.
- [ ] Biometría: hay fallback a credencial del dispositivo; se maneja bloqueo, no-enrolado y cambio de biometría (invalidación).
- [ ] BLE / NFC: se manejan estados de hardware apagado, sin permiso, fuera de rango y timeouts; no hay bloqueos indefinidos.
- [ ] Las capacidades sensibles se verifican como disponibles en runtime antes de invocarlas (feature detection), no se asumen.

## 5. Notificaciones, deep links y background

- [ ] El registro de push sobrevive a reinstalación y a reinicio del dispositivo; el token se refresca y se re-registra.
- [ ] Las notificaciones se agrupan/categorizan y respetan los canales/autorizaciones del sistema y la elección del usuario.
- [ ] Los deep links / universal links / app links tienen verificación de dominio configurada y probada (no abren el navegador por error).
- [ ] Un deep link a un destino profundo construye un back stack coherente cuando la app estaba cerrada.
- [ ] El trabajo en background respeta los límites del SO (ventanas de ejecución, límites de tareas, restricciones por batería).
- [ ] El background fetch / sync degrada limpiamente cuando el sistema lo posterga o lo mata; no asume ejecución garantizada.
- [ ] Los payloads de notificación no contienen datos sensibles en claro visibles en pantalla de bloqueo.
- [ ] El manejo de notificación (tap) navega al destino correcto y es idempotente ante taps repetidos.

## 6. Seguridad mobile

- [ ] Los secretos y tokens se guardan en el almacén seguro de la plataforma (Keychain / Keystore), nunca en almacenamiento plano.
- [ ] No hay claves, endpoints privados ni secretos embebidos en el binario ni en el repositorio.
- [ ] El transporte usa TLS; si [destroyer](interoperabilidad-y-aliados.md) exige certificate/public-key pinning, está implementado con plan de rotación.
- [ ] Datos sensibles en reposo se cifran; se define qué se puede persistir y qué no.
- [ ] Se aplica el nivel MASVS acordado con destroyer (resistencia, almacenamiento, criptografía, autenticación, red).
- [ ] La app oculta contenido sensible en el selector de apps (screenshot de background) cuando corresponde.
- [ ] Se maneja detección de entorno comprometido (root/jailbreak) según la política de riesgo definida por destroyer.
- [ ] El deep link y el IPC (intents, url schemes, extensiones) validan y sanitizan toda entrada externa.
- [ ] El nivel de exigencia, el modelo de amenazas y el pinning los decide [destroyer](interoperabilidad-y-aliados.md); aquí se verifica su ejecución mobile.

## 7. Performance craft

- [ ] El arranque en frío cumple el budget de tiempo hasta interactivo definido por [peakformance](interoperabilidad-y-aliados.md).
- [ ] No hay trabajo pesado, I/O ni red bloqueando el hilo principal durante el arranque ni durante la interacción.
- [ ] El scroll y las animaciones mantienen el frame objetivo; no hay jank ni frames perdidos en listas largas.
- [ ] El uso de memoria es estable; no hay fugas de memoria ni retención de vistas/contextos tras cerrar pantallas.
- [ ] El consumo de batería y de red se midió en sesiones reales; no hay wakeups ni polling innecesarios en background.
- [ ] El tamaño del app bundle / descarga está dentro del budget; se usan formatos y compresión adecuados para assets.
- [ ] Las imágenes se decodifican y se dimensionan al tamaño de destino; no se cargan a resolución completa para thumbnails.
- [ ] Los budgets numéricos (tiempos, tamaños, percentiles) los fija [peakformance](interoperabilidad-y-aliados.md); aquí se verifica el cumplimiento on-device.

## 8. Telemetría

- [ ] Hay reporte de crashes con símbolos/mapping subidos por build; los stack traces llegan legibles (deobfuscados).
- [ ] Se mide crash-free users/sessions y se define umbral de alerta.
- [ ] Se capturan ANR / hangs / freezes del hilo principal y se atribuyen a versión y pantalla.
- [ ] Se mide la adopción de versiones para saber a quién afecta un bug y planear rollout/kill switch.
- [ ] Los embudos y eventos de producto están instrumentados con un esquema de eventos consistente y documentado.
- [ ] La telemetría respeta el consentimiento del usuario y no captura PII ni contenido sensible sin base legal.
- [ ] Los identificadores usados en analítica cumplen la política de privacidad (no fingerprinting encubierto).
- [ ] El mapping de ofuscación se archiva por cada build publicado para poder simbolizar crashes futuros.

## 9. Testing

- [ ] El dominio y la lógica de presentación tienen pruebas unitarias; los ViewModels/reducers se prueban sin UI.
- [ ] Las pruebas de UI cubren los flujos críticos y son estables (no flaky); los tiempos de espera son deterministas.
- [ ] Hay pruebas de snapshot para componentes visuales clave, ejecutadas en configuraciones representativas (tema, tamaño de fuente).
- [ ] Los casos de restauración de estado, offline y permisos denegados están cubiertos por pruebas.
- [ ] Las pruebas corren en CI contra un rango de versiones de SO y de tamaños de pantalla definido.
- [ ] La estrategia global de calidad, cobertura E2E y criterios de aceptación los define [amado](interoperabilidad-y-aliados.md); aquí se prueba el propio código.

## 10. Release y tiendas

- [ ] El firmado (signing) está configurado con claves gestionadas de forma segura; nadie firma con claves locales sin control.
- [ ] Las variantes/flavors (dev, staging, prod) están separadas por identificador de app y configuración; no se publica un build de debug.
- [ ] El versionado (versión visible y build number) es monotónico y trazable a un commit.
- [ ] El rollout es por fases (phased/staged) con criterio de pausa/rollback basado en métricas de crash y adopción.
- [ ] Existe kill switch o feature flag remoto para desactivar una funcionalidad rota sin publicar una nueva versión.
- [ ] Las actualizaciones OTA (si aplican) respetan las reglas de la tienda y tienen firma/verificación de integridad.
- [ ] La ficha cumple las guidelines de cada tienda (permisos justificados, contenido, metadatos, screenshots vigentes).
- [ ] Hay plan de mínima versión soportada y de deprecación forzada (force update) cuando el backend rompe compatibilidad.
- [ ] La compatibilidad de contrato con backend se coordina con [motor/eneida](interoperabilidad-y-aliados.md); el cliente tolera versiones de API en transición.

## 11. Privacidad y gobernanza

- [ ] El consentimiento de tracking (ATT / consent) se solicita correctamente y se respeta la elección en toda la sesión.
- [ ] Las etiquetas de privacidad de datos (nutrition labels / data safety) declaran con exactitud qué se recoge y para qué.
- [ ] La recolección de datos se minimiza a lo necesario; hay base legal o consentimiento por cada categoría.
- [ ] Existe ruta para exportar y eliminar datos del usuario acorde a la normativa aplicable.
- [ ] La accesibilidad legal exigida por jurisdicción se contempla, no solo la accesibilidad como buena práctica.
- [ ] Los SDKs de terceros se inventarían con su comportamiento de datos; ninguno recoge más de lo declarado.

## 12. Frontera / handoff

- [ ] Todo lo que no es ingeniería mobile se derivó a su dueño con un contrato claro (entrada, salida, criterio de aceptación).
- [ ] La arquitectura de sistema quedó en manos de [eneida](interoperabilidad-y-aliados.md) y el backend/API en [motor](interoperabilidad-y-aliados.md).
- [ ] El diseño UX/UI y el design system vienen de [uxuifull/farola](interoperabilidad-y-aliados.md); no se inventó criterio visual propio.
- [ ] La estrategia de pruebas y aceptación es de [amado](interoperabilidad-y-aliados.md); los budgets de rendimiento de [peakformance](interoperabilidad-y-aliados.md); la seguridad de [destroyer](interoperabilidad-y-aliados.md); los datos de [andulfo](interoperabilidad-y-aliados.md).
- [ ] Cada handoff dejó registro de qué se pidió, qué se recibió y qué queda pendiente; no hay ownership ambiguo.
- [ ] No se absorbió trabajo ajeno "por rapidez"; si se cubrió temporalmente, quedó declarado y con fecha de devolución.

## 13. Greenfield vs brownfield

- [ ] Greenfield: se fijó desde el inicio la versión mínima de SO, los form-factors soportados y la estrategia de estado/navegación.
- [ ] Greenfield: la modularización y las fronteras de dominio se establecieron antes de acumular deuda.
- [ ] Greenfield: signing, variantes, CI y telemetría se configuraron antes del primer release, no después.
- [ ] Brownfield: se inventarió versión mínima real de usuarios, deuda de arquitectura y acoplamientos al framework antes de cambiar nada.
- [ ] Brownfield: se midió el estado actual (crash-free, arranque, tamaño) para tener línea base antes de optimizar.
- [ ] Brownfield: los cambios entran de forma incremental y reversible; cada refactor va acompañado de pruebas de caracterización.
- [ ] Brownfield: se verificó compatibilidad de migraciones de datos y de contratos de API con las versiones ya instaladas en producción.
- [ ] En ambos estados: se confirmó que el plan respeta las fronteras de [ownership](interoperabilidad-y-aliados.md) y los budgets/estrategias de los dueños.

## 14. Monetización y billing (si el producto monetiza en la app)
- [ ] Modelo de negocio y pricing definidos por `tompo`; palma integra el billing en cliente.
- [ ] Flujo de compra, **restore purchases** y entitlements implementados y probados en sandbox.
- [ ] **Validación de recibos server-side** (nunca solo en cliente) coordinada con `motor`; server notifications procesadas.
- [ ] Estados de suscripción cubiertos: activa, grace period, billing retry, on-hold, pausada, expirada.
- [ ] Edge cases: compra interrumpida, transacción pendiente, red caída, doble cobro, entitlement desincronizado.
- [ ] Correctitud de la máquina de estados/idempotencia revisada (frontera con `certero`).

## 15. Extensiones y superficies del sistema (si aplica)
- [ ] Widgets/Live Activities respetan el presupuesto de refresco y los límites de memoria/tiempo de la extensión.
- [ ] Datos compartidos app↔extensión vía contenedor/app group; sin duplicar la fuente de verdad.
- [ ] App Clips/Instant Apps dentro del límite de tamaño y con transición a la app completa.
- [ ] App Intents/atajos expuestos y probados; notificaciones ricas vía notification service extension.
- [ ] Diseño de las superficies validado con `uxuifull`; backend de push con `motor`.

## 16. Internacionalización (i18n/l10n/RTL) (si hay más de un locale/región)
- [ ] Strings externalizados en catálogos; nada hardcodeado; claves semánticas con comentarios para traductores.
- [ ] Pluralización y formateo locale-aware (fecha/número/moneda/calendario) con las APIs nativas.
- [ ] **RTL**: layout con leading/trailing, mirroring de iconos direccionales, bidi probado (árabe/hebreo).
- [ ] Cambio de idioma (sistema y/o per-app) sin fugas; pseudo-localización para detectar truncamiento/expansión.
- [ ] Ficha de tienda localizada; copy y estrategia de idiomas definidos por `uxuifull`/`tompo`.

## 17. Form-factors extendidos (si el alcance incluye wearable/TV/automotriz)
- [ ] Alcance de form-factors decidido por `tompo`/`eneida`; diseño por `uxuifull`; palma construye.
- [ ] Wearable: companion vs standalone definido; batería/CPU acotadas; complications/tiles si aplica.
- [ ] TV: navegación por focus/D-pad, 10-foot UI legible, sign-in en TV.
- [ ] Automotriz: plantillas del SO respetadas, guidelines de distracción del conductor cumplidas.
- [ ] Estrategia de code-sharing núcleo vs específico por superficie definida.
