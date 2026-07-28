# Release Engineering del Binario y Tiendas

El release engineering mobile es el arte de convertir un árbol de código en un **artefacto firmado, versionado, reproducible y publicable** en una o más tiendas, y de gobernar su **liberación gradual y su reversión segura**. A diferencia de la web, en mobile **no existe rollback instantáneo**: el binario aprobado vive en dispositivos de usuarios y en la caché de la tienda. Por eso el release mobile se diseña para ser *prudente por defecto*: firma correcta, empaquetado óptimo, rollout por fases, banderas de funcionalidad, kill switch y actualizaciones OTA de lo que la política de tienda permite.

Este es dominio **T1 de palma**: el SABER MOBILE de firmar, empaquetar, subir, liberar y actualizar. La **entrega operativa** (pipeline, secretos, ejecución) es de [baluarte](interoperabilidad-y-aliados.md); la **política de secretos y firma** es de destroyer; el **negocio, ASO y ficha de tienda** es de tompo.

## 1. Code signing y provisioning

La firma es la identidad criptográfica de la app. Sin ella no hay instalación ni publicación.

| Plataforma | Artefactos de firma | Concepto clave |
|---|---|---|
| iOS (p. ej.) | Certificado de distribución, App ID, perfil de aprovisionamiento, entitlements | El perfil ata *certificado + App ID + capacidades + dispositivos*; caduca (típico 1 año) |
| Android (p. ej.) | Keystore + clave de firma; upload key vs. app signing key (p. ej. Play App Signing) | La tienda puede custodiar la clave de firma final; tú firmas con la *upload key* |

Principios innegociables:

- **Los secretos de firma NUNCA viven en el repositorio ni en el binario.** Se guardan en un gestor de secretos y se **referencian** en el pipeline. Su custodia y rotación las **opera baluarte** bajo **política de destroyer** (ver [seguridad-mobile.md](seguridad-mobile.md)).
- **Rotación planificada** de certificados y perfiles antes de su caducidad; un certificado vencido bloquea todo el pipeline de release.
- **Pérdida de keystore = pérdida de continuidad**: sin Play App Signing, perder la clave impide actualizar la app. Con custodia de tienda, se puede resetear la upload key. Documenta cuál es tu modelo y su plan de recuperación.
- **Entitlements/capacidades** (push, App Groups, deep links asociados, HealthKit, etc.) deben coincidir exactamente entre código, App ID y perfil; su desajuste es causa frecuente de fallo de build o de rechazo.

```
# Regla de oro (pseudo-pipeline neutral)
firma:
  certificado:  ${SECRET.IOS_DIST_CERT}      # referencia, nunca el valor
  perfil:       ${SECRET.IOS_PROV_PROFILE}
  keystore:     ${SECRET.ANDROID_KEYSTORE}
  # operado por baluarte · política de destroyer · saber mobile de palma
```

## 2. Build variants / flavors / schemes

Un mismo código produce múltiples binarios según entorno y marca. Se materializan como *flavors* (Android, p. ej.), *schemes/configurations* (iOS, p. ej.) o *build profiles* (herramientas cross-platform, p. ej.).

| Eje | Ejemplos | Qué cambia |
|---|---|---|
| Entorno | dev / staging / prod | URL de API, claves de terceros, nivel de log, feature flags |
| Marca (white-label) | marcaA / marcaB | app id, ícono, nombre, tema, assets, endpoints |
| Distribución | interna / tienda | firma, telemetría, capacidades de debug |

- **Identificadores distintos por variante** (p. ej. `com.app.dev`, `com.app`) para coinstalar dev y prod en un mismo dispositivo.
- La **configuración por entorno** se inyecta en build-time (archivos de config, variables), nunca se hardcodea el secreto de producción en el binario de dev.
- White-label: un **manifiesto de marca** por cliente (assets + config) mantiene un solo código y N productos.

## 3. Versionado

Dos números conviven y cumplen funciones distintas:

| Número | Ejemplo | Audiencia | Regla |
|---|---|---|---|
| Versión de marketing (semántica) | `4.2.0` | Usuario / tienda | MAJOR.MINOR.PATCH del cambio funcional |
| Build number / version code | `4820` | Tienda / soporte | **Monótono creciente**; único por subida |

- El **build number debe incrementar siempre**; las tiendas rechazan subidas con número repetido o menor.
- **Compatibilidad**: mantén contrato hacia atrás con la API mientras existan versiones antiguas instaladas; coordina versionado de API con motor/eneida.
- **Política de versión mínima** (min OS y min-app-version): define y comunica el *deprecation window*. Un **kill switch de versión** (forzar actualización) protege ante bugs críticos o cambios incompatibles de backend.

## 4. Empaquetado

El objetivo es el **menor tamaño de descarga** con la mejor experiencia de instalación.

- **App Bundle (p. ej. AAB en Android)**: subes un bundle y la tienda genera APKs optimizados por dispositivo (densidad, ABI, idioma). Reduce el tamaño frente al APK universal.
- **App Thinning (p. ej. iOS)**: slicing por dispositivo, on-demand resources y bitcode/optimizaciones; entrega solo los assets relevantes.
- **Dynamic feature / on-demand delivery**: módulos que se descargan bajo demanda o de forma diferida; útil para funciones pesadas o poco usadas.
- **Presupuesto de tamaño**: fija un *size budget* y vigílalo en CI; el tamaño impacta conversión de instalación y hay umbrales de descarga por red móvil. Las **metas de rendimiento** (arranque, tamaño) las coordina peakformance; palma implementa el empaquetado.

## 5. Tiendas y canales de prueba

| Consola (p. ej.) | Producción | Canales de prueba |
|---|---|---|
| App Store Connect | App Store | TestFlight (interno / externo con revisión) |
| Play Console | Play Store | Internal testing / Closed (alfa/beta) / Open testing |

Buenas prácticas de canales:

- **Interno** para el equipo (distribución rápida, sin revisión completa); **cerrado** para beta con usuarios seleccionados; **abierto** para validación amplia previa a producción.
- Usa los canales como **puertas de calidad progresivas**: interno → cerrado → producción con phased rollout.
- Metadatos, capturas, clasificación por edad y ficha (ASO) son **negocio → tompo**; palma entrega el binario y los requisitos técnicos de subida.

## 6. Guidelines de revisión

Las tiendas revisan cada binario. Conocer las causas típicas de rechazo evita ciclos perdidos.

| Causa común de rechazo | Prevención |
|---|---|
| Permisos sin justificación clara (propósito de uso) | Declarar propósito exacto; pedir permiso en contexto |
| Funcionalidad incompleta, crashes, placeholders | Smoke test del build de tienda; sin demos rotas |
| Privacidad: datos no declarados / tracking sin consentimiento | Coordinar labels y consentimiento (ver §9) |
| Login obligatorio sin cuenta demo / sin borrado de cuenta | Proveer credenciales de prueba y flujo de eliminación |
| Pagos fuera del sistema de la tienda cuando aplica | Usar el mecanismo de pago requerido por la política |
| Uso de APIs privadas o capacidades no declaradas | Solo APIs públicas; entitlements coherentes |

- Registra en **notas de revisión** credenciales demo y pasos de reproducción para acelerar.
- **Tiempos**: la revisión suele tardar de horas a algunos días; planifica el calendario de release con holgura.
- **Expedited review**: reserva la revisión acelerada para fixes críticos (seguridad, caída masiva); su abuso erosiona el privilegio.
- Ante rechazo: leer la resolución, corregir causa raíz, responder por el canal formal o apelar con evidencia; no re-subir sin cambio.

## 7. Phased / staged rollout

Liberar a producción **por porcentaje creciente** de usuarios es la principal red de seguridad del release mobile.

```
Día 0: 1-5%   → observar crash-free, ANR, métricas clave
Día 1: 10-20% → si sano, avanzar
Día n: 50% → 100%
```

- **Halt & resume**: si sube la tasa de crashes/ANR o cae una métrica de negocio, **pausa el rollout** (la mayoría de tiendas lo permiten) sin afectar a quienes ya actualizaron mientras investigas.
- Monitorea **crash-free users/sessions**, ANR, errores y KPIs durante toda la rampa. La observabilidad y los SLO operativos los define/opera baluarte; palma define **qué señales mobile** vigilar y los umbrales de avance/halt.
- Un porcentaje pequeño y sano durante suficiente tiempo antes de ampliar es preferible a un 100% apresurado.

## 7.1 Feature flags, remote config y experimentación (A/B) de cliente

Complemento del rollout: desacoplar *deploy* de *release* con banderas evaluadas en cliente.
- **Feature flags / kill switches**: activar/desactivar features sin publicar; *kill switch*
  para apagar en caliente una feature de riesgo (ver §7 y §10).
- **Remote config**: parámetros ajustables sin release (umbrales, endpoints, textos no
  localizables), con caché y valor por defecto seguro offline.
- **Experimentación A/B**: asignación estable por usuario, *exposure logging* y *guardrails*
  (métricas de seguridad que abortan el experimento).
- Frontera: la **estrategia del experimento y qué se mide** las decide `tompo` (producto, con
  analítica); palma integra el *plumbing* (evaluación de flags, exposición, degradación segura);
  el pipeline de entrega es de `baluarte`.

## 8. OTA (Over-The-Air updates)

Las herramientas OTA (p. ej. CodePush, EAS Update) entregan cambios **sin pasar por una nueva subida a tienda**, pero su alcance es limitado por diseño y por política.

| Se PUEDE actualizar OTA | NO se puede actualizar OTA |
|---|---|
| Bundle de JS / lógica interpretada | Código nativo compilado |
| Assets (imágenes, fuentes, textos) | Dependencias nativas nuevas / permisos nuevos |
| Fixes y ajustes dentro de la capa JS | Cambios que requieren recompilar el shell nativo |

Reglas duras:

- **NUNCA usar OTA para eludir la revisión de la tienda** ni para introducir funcionalidad que la política exige revisar. Es motivo de expulsión y viola las guidelines. Esto es materia de [gobernanza-y-etica.md](gobernanza-y-etica.md).
- OTA cambia la **superficie de confianza**: el canal y la firma del bundle OTA deben protegerse igual que el binario (integridad, rollback de OTA defectuoso). Ver [seguridad-mobile.md](seguridad-mobile.md).
- Versiona el bundle OTA **atado a la versión nativa compatible**; un OTA no debe aterrizar sobre un binario nativo incompatible.
- OTA es una herramienta de **hotfix rápido dentro de lo permitido**, no un canal de entrega paralelo a la tienda.

## 8.1 Distribución empresarial y tiendas alternativas

Más allá de las tiendas públicas, palma conoce los canales de distribución controlada:
- **Movilidad empresarial (MDM/MAM/EMM):** distribución gestionada (p. ej. Apple Business
  Manager / Managed Google Play), **managed app config**, per-app VPN, políticas de la
  organización y *app wrapping*. La app declara y respeta la configuración administrada.
- **Distribución interna/ad-hoc:** perfiles empresariales, tracks internos de prueba, firmas
  de empresa para flotas propias.
- **Tiendas alternativas y sideloading (p. ej. DMA en la UE, 2024+):** marketplaces de
  terceros e instalación fuera de la tienda oficial donde la regulación lo habilita; implica
  gestionar notarización/verificación, canal de actualización propio y confianza del binario.

La **decisión** de qué canal usar es de producto (`tompo`) y cumplimiento (`sello`/`destroyer`);
palma **implementa** la distribución elegida.

## 9. Privacy labels / Data Safety

Cada tienda exige declarar **qué datos recolecta la app, para qué y si se comparten** (p. ej. Privacy Nutrition Labels, Data Safety form).

- La declaración debe reflejar la **realidad del binario y sus SDKs de terceros** (analytics, ads, crash reporting también recolectan datos).
- Se coordina con **destroyer/sello** (clasificación de datos y cumplimiento) y con **tompo** (decisión de negocio sobre qué datos y por qué). Palma asegura que lo declarado **coincide técnicamente** con lo que el binario hace.
- Una declaración inexacta es causa de rechazo y de riesgo regulatorio.

## 10. Runbook de release y rollback

Como **no hay rollback instantáneo en tienda**, la reversión se diseña de antemano.

**Checklist de release (resumen):**

1. Congelar rama, incrementar build number, verificar versión semántica.
2. Build de variante `prod` firmada con credenciales referenciadas.
3. Verificación de tamaño, entitlements, privacy labels y smoke test del artefacto.
4. Subir al canal interno → cerrado; validar; promover.
5. Enviar a revisión con notas y credenciales demo.
6. Aprobado: iniciar **phased rollout** desde porcentaje bajo.
7. Vigilar crash-free/ANR/KPIs; avanzar o **halt**.

**Estrategia de rollback (capas):**

| Mecanismo | Alcance | Latencia |
|---|---|---|
| Halt del phased rollout | Detener expansión a nuevos usuarios | Minutos |
| Feature flag remoto | Apagar la función defectuosa sin re-subir | Segundos-minutos |
| Kill switch | Bloquear versión/forzar update ante bug crítico | Minutos |
| OTA (si el fix está en capa JS) | Corregir sin ciclo de tienda | Minutos-horas |
| Nueva versión con build number mayor | Reemplazo del binario (la tienda no "revierte") | Horas-días (revisión) |

Regla: **nunca dependas de un solo mecanismo**. Toda función riesgosa se libera detrás de flag/kill switch para poder mitigar sin esperar una nueva revisión.

## 11. Frontera con baluarte

| Aporta baluarte (T2 entrega/infra) | Aporta palma (T1 saber mobile) |
|---|---|
| CI/CD, paved road, runners, ejecución del pipeline | QUÉ y CÓMO firmar por tienda; variantes; empaquetado |
| Custodia y rotación operativa de secretos de firma | Requisitos de firma, entitlements, provisioning |
| Observabilidad y SLO operativos, artefactos, GitOps | Señales mobile a vigilar, umbrales de rollout/halt |
| Orquestación de la entrega y del rollback de infra | Estrategia de rollout/OTA/kill switch mobile |

baluarte **provee el camino pavimentado y opera la entrega y los secretos**; palma **define el conocimiento mobile del release** (firma, empaquetado, subida, rollout, OTA) y qué firmar/publicar por tienda. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## 12. Greenfield, en construcción y brownfield

- **Greenfield**: establece desde el día 1 identificadores por variante, esquema de versionado, custodia de firma con baluarte/destroyer, canales de prueba y phased rollout como default.
- **En construcción**: cablea las variantes al CI, formaliza el runbook, introduce flags/kill switch y OTA (dentro de política) antes del primer release a producción.
- **Brownfield**: audita firma y su rotación, reproducibilidad del build, tamaño del artefacto, exactitud de privacy labels y presencia de red de seguridad (flags/rollout); prioriza cerrar la ausencia de rollback controlado.

## 13. Modelo tiered

- **T1 — palma (aquí):** release engineering mobile: code signing y provisioning, variantes, versionado, empaquetado, subida a tiendas, phased rollout, OTA, privacy labels y runbook de rollback mobile.
- **T2 — deriva:**
  - **CI/CD, infraestructura de entrega y custodia operativa de secretos → baluarte.**
  - **Política de secretos, firma y clasificación de datos → destroyer.**
  - **Negocio, ficha de tienda, ASO y decisión de datos declarados → tompo.**

palma no opera el pipeline ni fija la política de secretos ni decide el negocio: aporta el **saber mobile** que hace que el binario se firme, empaquete, publique y libere con excelencia, y que se pueda revertir con seguridad.
