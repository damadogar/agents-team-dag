# Ecosistemas y herramientas mobile: cómo ELEGIR sin sesgo

Este archivo enseña a **decidir** el ecosistema mobile de un proyecto con criterio, no con moda. Ninguna herramienta aquí es "la buena por defecto": cada una se cita como **p. ej.**, intercambiable, y solo gana cuando el **contexto + la evidencia + el TCO** (coste total de propiedad: build, mantenimiento, contratación, licencias, salida) la respaldan. La regla de oro: primero el problema y las restricciones; después la tecnología. Si te sorprendes eligiendo antes de haber medido o entendido, retrocede.

Hermanos: [cross-platform.md](cross-platform.md), [plataformas-nativas.md](plataformas-nativas.md), [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## 1. Decisión de plataforma: iOS, Android o ambas

Antes de tocar lenguajes o frameworks, decide **a qué plataformas** vas y **en qué orden**. No es una decisión técnica, es de negocio con consecuencias técnicas.

| Señal a levantar | Por qué importa |
|---|---|
| Base instalada real del público objetivo (por país/segmento) | El reparto iOS/Android varía enormemente por región e ingreso; decide el orden, no un dogma global |
| Modelo de monetización (suscripción, publicidad, e-commerce, B2B) | Afecta ARPU esperado por plataforma y comisiones de tienda |
| Presupuesto y tamaño de equipo | Dos nativos = dos bases de código y dos perfiles; una cross-platform concentra esfuerzo pero añade su propio coste |
| Time-to-market y ventana competitiva | ¿Puedes permitirte lanzar en una plataforma primero y aprender? |
| Requisitos de hardware/OS específicos | APIs exclusivas, wearables, CarPlay/Android Auto, widgets, etc. |
| Distribución fuera de tiendas (empresarial, sideload) | Cambia el pipeline de entrega y firma |

Salidas posibles y todas legítimas: **solo iOS**, **solo Android**, **ambas simultáneas**, o **una primero y la otra después**. La elección se documenta con la evidencia que la sustenta.

## 2. Matriz nativo vs cross-platform vs híbrido (sin ganador por defecto)

Esta es la decisión mayor del ecosistema. **No la resuelve palma en solitario: la arquitectura la valida [eneida](interoperabilidad-y-aliados.md)**; palma aporta la evidencia mobile, los prototipos y el análisis de TCO. Pondera cada criterio según el proyecto (asigna peso 1-5 a cada fila) y puntúa cada enfoque; el resultado orienta, no manda.

| Criterio (pondéralo) | Nativo (2 bases) | Cross-platform (1 base) | Híbrido / web-in-shell |
|---|---|---|---|
| Acceso profundo a APIs/hardware del SO | Máximo | Alto vía plugins; puede requerir código nativo | Limitado; puentes explícitos |
| Fidelidad UI/UX por plataforma | Máxima | Alta a muy alta | Depende del enfoque web |
| Rendimiento y latencia percibida | Máximo | Alto en la mayoría de casos | Aceptable a variable |
| Coste de construir 2 plataformas | Alto (equipos separados) | Menor (compartes lógica y UI) | Menor si ya tienes web |
| Velocidad inicial / time-to-market | Menor | Mayor | Mayor con base web existente |
| Riesgo de dependencia de un runtime/vendor | Bajo | Medio (atado al framework) | Medio-alto |
| Facilidad de contratación local | Depende del mercado | Depende del mercado | Amplia (perfiles web) |
| Madurez a largo plazo / mantenibilidad | Alta | Alta si el framework es estable | Requiere disciplina |
| Reutilización con web/desktop existentes | Baja | Media-alta según stack | Alta |

Regla práctica: **no hay respuesta universal**. App con UX muy diferenciada, uso intensivo de sensores o exigencias de rendimiento extremo empuja hacia nativo; catálogo/contenido con lógica común y equipo acotado puede favorecer cross-platform; producto web maduro que necesita presencia en tienda rápido puede tolerar híbrido. Documenta pesos, puntajes y supuestos, y **preséntalo a eneida para la validación arquitectónica**.

## 3. Lenguajes y UI toolkits

Escoge el par lenguaje+toolkit en función del enfoque de la sección 2, del talento disponible y del ciclo de vida esperado. Todos son **p. ej.** legítimos.

| Enfoque | Lenguaje (p. ej.) | UI toolkit (p. ej.) | Notas neutrales |
|---|---|---|---|
| Nativo iOS | Swift; Objective-C en legacy | SwiftUI; UIKit | UI declarativa vs imperativa según madurez del target OS |
| Nativo Android | Kotlin; Java en legacy | Jetpack Compose; Views/XML | Compose declarativo vs sistema de vistas clásico |
| Cross-platform | Dart; JS/TS; Kotlin; C# | Motor propio de widgets; componentes nativos puenteados; UI compartida o por plataforma | El modelo de renderizado (canvas propio vs widgets nativos) tiene implicaciones de fidelidad y tamaño |
| Híbrido | JS/TS + web | WebView + puentes nativos | Reutiliza competencias web (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)) |

Detalle profundo por plataforma en [plataformas-nativas.md](plataformas-nativas.md); detalle de enfoques compartidos en [cross-platform.md](cross-platform.md). Criterio de selección: madurez del toolkit para tu versión mínima de SO soportada, tamaño de comunidad, curva del equipo y coste de salida si cambias de rumbo.

## 4. Build systems y gestores de paquetes

El sistema de build y la gestión de dependencias condicionan reproducibilidad, tiempos de compilación y facilidad de CI. Elige por el enfoque, no por costumbre.

| Función | Opciones (p. ej., intercambiables) | Qué evaluar |
|---|---|---|
| Build iOS | Cadena de Xcode / toolchain de Apple | Compatibilidad con firma, provisioning y notarización |
| Build Android | Gradle | Configuración de variantes, tiempos incrementales, caché |
| Paquetes iOS | SPM; CocoaPods; Carthage | Integración nativa vs comunidad; migración entre ellos |
| Paquetes Android | Gradle + repositorios de artefactos | Catálogos de versiones, resolución de conflictos |
| Paquetes cross-platform | pub; npm/yarn/pnpm; NuGet | Lockfiles, auditoría de dependencias, tamaño resultante |

Principios transversales: **lockfiles versionados**, builds **reproducibles**, y gestión de secretos de firma **fuera del repositorio**. Minimiza dependencias transitivas: cada una es superficie de mantenimiento, seguridad y peso de binario.

## 5. CI y entrega mobile

El **paved road / pipeline es de [baluarte](interoperabilidad-y-aliados.md)** (CI/CD, GitOps, entorno). **palma aporta los pasos específicamente mobile**: firma de código, gestión de certificados y perfiles, generación de artefactos (IPA/APK/AAB), subida a canales de prueba y publicación en tiendas. La herramienta que orquesta esos pasos es intercambiable.

| Necesidad mobile | Opciones (p. ej.) | Nota |
|---|---|---|
| Automatizar firma, build y submit | Fastlane; scripts propios | Encapsula tareas repetitivas de tienda |
| Build/entrega gestionada para cross-platform | EAS; servicios equivalentes del framework | Cómodo pero evalúa lock-in y coste por build |
| CI mobile gestionado (runners con SDKs) | Bitrise; Codemagic; runners de tu plataforma CI | macOS runners para iOS son el cuello de botella habitual |
| CI genérico con pasos mobile | GitHub Actions; GitLab CI; otros | palma define los steps; baluarte gobierna el pipeline |
| Distribución a testers internos | Canales beta de tienda; servicios de distribución | TestFlight-style, grupos internos, feedback |

Criterio: prioriza pipelines donde los **pasos mobile sean portables** (scripts/CLI versionados) sobre configuraciones atadas a una UI de proveedor. Coordina el diseño del pipeline con baluarte; no lo dupliques.

## 6. Crash, analytics y telemetría

Observabilidad de la app en producción. Todas son **p. ej.** y se combinan según privacidad, volumen y presupuesto. La telemetría de producto suele decidirla producto/negocio; palma cablea la integración técnica correcta.

| Señal | Opciones (p. ej.) | Qué mirar |
|---|---|---|
| Crash reporting / estabilidad | Crashlytics; Sentry; App Center-style; herramientas de plataforma | Símbolos/dSYM, agrupación, retención |
| Errores y trazas | Sentry; equivalentes | Cobertura mobile + backend correlacionada |
| Analytics de producto | Herramientas de producto varias | Consentimiento, PII, cumplimiento (ver [destroyer](interoperabilidad-y-aliados.md)) |
| Métricas de rendimiento en dispositivo | SDKs de vitals; instrumentación propia | Metas y budgets los fija peakformance |

Reglas: **consentimiento y minimización de datos primero**; evita duplicar SDKs que midan lo mismo (peso e impacto en batería); mantén el mapeo de símbolos para desofuscar crashes.

## 7. Device clouds y testing

**La estrategia y arquitectura de pruebas es de [amado](interoperabilidad-y-aliados.md).** palma facilita la ejecutabilidad en dispositivo (testability, hooks, builds de test) y sabe qué infraestructura existe, sin apropiarse de la estrategia.

| Necesidad | Opciones (p. ej.) | Nota |
|---|---|---|
| Nube de dispositivos reales | BrowserStack; Sauce Labs; Firebase Test Lab; equivalentes | Cobertura de matriz de dispositivos/OS real |
| Emuladores/simuladores | Herramientas de los SDK oficiales | Rápidos pero no sustituyen hardware real |
| Automatización UI mobile | Frameworks de UI test nativos/cross | La elige amado; palma habilita la app para ellos |

Criterio: la matriz de dispositivos se prioriza por la **base instalada real** (sección 1), no por catálogo completo. Coordina con amado antes de comprometer una herramienta.

## 8. Evitar el lock-in y mantener reversibilidad

El coste de **salir** de una tecnología es parte del TCO y casi siempre se subestima.

- **Aísla lo propietario**: encapsula SDKs de terceros (crash, analytics, push) tras interfaces propias, para poder sustituirlos sin tocar la app entera.
- **Lógica de negocio agnóstica**: mantén reglas de dominio separadas de la UI y del framework, de modo que un cambio de toolkit no las arrastre.
- **Artefactos y builds portables**: prefiere pasos de CI en scripts/CLI versionados sobre configuraciones atrapadas en una UI de proveedor.
- **Datos y formatos abiertos**: esquemas y export sin candados; que el usuario y tú podáis migrar.
- **Evalúa el coste de salida al entrar**: pregunta siempre "si esto no funciona en 18 meses, ¿cómo salgo y qué cuesta?".
- **Contratabilidad**: un stack que nadie en tu mercado domina es un lock-in de talento.

Reversibilidad no significa evitar toda dependencia útil; significa **entrar con los ojos abiertos** y con las costuras en su sitio.

## 9. Greenfield, en construcción y brownfield

El estado del proyecto cambia **cómo** eliges, no los criterios.

| Estado | Cómo elegir | Antipatrón a evitar |
|---|---|---|
| **Greenfield** | Decisión limpia por secciones 1-2; prototipa lo arriesgado antes de comprometer; valida arquitectura con eneida | Elegir por moda o por lo que "ya sé" sin medir |
| **En construcción** | Respeta las decisiones tomadas salvo evidencia fuerte en contra; introduce herramientas nuevas de forma incremental y aislada | Rehacer lo que ya funciona; cambios de rumbo sin datos |
| **Brownfield / legacy** | Parte del stack existente; mide antes de tocar; mejora por costuras; **no fuerces migración** si el TCO no la justifica | "Reescribir todo" como reflejo; migrar por gusto tecnológico |

En brownfield, una migración (p. ej. de views clásicas a UI declarativa, o de nativo a cross-platform) solo se propone con **evidencia de TCO, riesgo acotado y ruta de coexistencia**, y se valida con eneida. La opción de **no migrar** siempre está sobre la mesa.

## 10. Fronteras (recordatorio)

palma es dueño de la **construcción mobile** (apps nativas, cross-platform e híbridas, y su entrega a tiendas), pero no invade a sus aliados. Detalle en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

- **eneida** decide y valida la **arquitectura** (incluida la decisión mayor de la sección 2).
- **baluarte** gobierna **CI/CD, pipeline y paved road**; palma aporta los pasos mobile.
- **amado** define la **estrategia y arquitectura de testing**; palma hace la app testeable.
- **destroyer** manda en **seguridad y privacidad**; palma implementa conforme a su criterio.
- **peakformance** fija **metas y budgets de rendimiento**; palma optimiza el cliente mobile.
- **farola / uxuifull** conservan la **web móvil, PWA y UX/UI**; palma toma el shell nativo y el híbrido.

La neutralidad no es indecisión: es elegir **con evidencia**, dejar el criterio escrito y mantener abierta la puerta de salida.
