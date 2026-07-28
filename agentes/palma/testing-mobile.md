# Testing Mobile como Craft del Constructor

Escribir pruebas del **propio código** es parte inseparable de construirlo bien. Este satélite trata el testing mobile como **craft del ingeniero que implementa**: las pruebas que respaldan la lógica, las view models, los repositorios, los componentes y las pantallas que palma escribe, más el diseño de **testability** que hace que ese código sea probable. Aquí no se decide *qué probar como sistema* ni se emite el veredicto de calidad.

## Frontera rectora con amado (leer primero)

La distinción es nítida y no se negocia:

| Dimensión | Dueño | Alcance |
|---|---|---|
| **Estrategia y plan de pruebas** | **amado** | Qué probar como sistema, matriz de dispositivos oficial, criterios de aceptación, gestión de defectos, cobertura objetivo, QA E2E/sistema (p. ej. Appium/Espresso/XCUITest/Maestro/Detox), device clouds, veredicto de calidad |
| **Pruebas del código propio** | **palma** | Unit/UI/integración/snapshot de la implementación como red de seguridad del constructor; testability por diseño; test doubles de SDKs de plataforma; ejecución de esas pruebas |

Regla mnemónica: **amado = qué y veredicto; palma = cómo se construye probable + las pruebas que respaldan mi implementación.** Cuando palma detecta un hueco de estrategia (un dispositivo sin cubrir, un criterio ambiguo, un defecto de sistema), lo **reporta a amado**, no lo absorbe. Cuando amado necesita un hook, un test ID o un build de prueba para poder ejecutar su plan, palma lo **provee** (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)).

## 1. Unit tests del código propio

La primera línea de defensa: lógica de negocio, view models/presenters, use cases, mappers, repositorios y utilidades. Rápidos, deterministas, sin dependencias reales de plataforma.

- **Objetivo**: aislar la unidad de su entorno (red, disco, sensores, UI) mediante dobles.
- **Neutralidad**: p. ej. XCTest / Swift Testing en iOS, JUnit + Kotlin Test / kotlin.test en Android, o el framework nativo del stack cross-platform.
- **Foco**: transformaciones de estado, ramas de decisión, edge cases (nulos, listas vacías, límites numéricos), manejo de errores y contratos de las interfaces que palma define.

```kotlin
// p. ej. JUnit + fake de repositorio — se prueba la view model, no la red
@Test fun `carga muestra error cuando el repositorio falla`() = runTest {
    val vm = PerfilViewModel(repo = FakePerfilRepo(result = Result.failure(IOException())))
    vm.cargar()
    assertEquals(UiState.Error, vm.state.value)
}
```

Las view models deben ser probables **sin instanciar la UI**: la lógica vive fuera del componente visual.

## 2. UI tests de componentes y pantallas

Verifican render, interacción y estados visibles de los componentes que palma construye.

- p. ej. **XCUITest** y **SwiftUI testing** en iOS; **Espresso** y **Compose UI testing** (`createComposeRule`, `onNodeWithTag`) en Android; el harness de widgets/componentes del framework cross-platform.
- Se prueba: visibilidad condicional, navegación entre pantallas, entrada de formularios, estados de carga/vacío/error, accesibilidad de los nodos.
- **Semantics/test tags** son parte del diseño del componente (ver §5), no un parche posterior.

```swift
// p. ej. XCUITest — el botón se habilita cuando el formulario es válido
app.textFields["email"].typeText("a@b.co")
XCTAssertTrue(app.buttons["continuar"].isEnabled)
```

## 3. Snapshot / screenshot testing

Captura la representación renderizada de un componente y la compara contra una referencia aprobada. Detecta regresiones visuales sutiles que un aserto funcional no ve.

- Cubrir: temas claro/oscuro, tamaños de fuente dinámicos (Dynamic Type / font scale), densidades, RTL y estados de componente.
- Referencias versionadas en el repo; revisión humana obligatoria al actualizar el *golden*.
- Estabilizar fuentes de flakiness: animaciones deshabilitadas, datos fijos, tiempo/aleatoriedad inyectados.
- p. ej. snapshot de vistas SwiftUI/UIKit o de Composables; comparación por píxel o perceptual con umbral de tolerancia controlado.

## 4. Integration tests

Prueban la colaboración real entre capas del código propio, con las fronteras externas sustituidas por dobles.

- **Persistencia**: la implementación real de la base de datos local (p. ej. Core Data/SwiftData, Room, SQLDelight) contra un store en memoria o temporal — migraciones, queries, transacciones.
- **Red**: cliente HTTP real contra un **servidor local/mock** o interceptores, verificando serialización, mapeo de errores, reintentos y timeouts que palma implementó.
- Objetivo: confianza en que las piezas encajan, sin depender de backends de producción ni de la red real.

## 5. Testability como diseño (no como accidente)

El código probable se **diseña** así desde el principio. Es responsabilidad de construcción de palma:

| Técnica | Efecto |
|---|---|
| **Inyección de dependencias** | Sustituir SDKs, red y relojes por dobles en prueba |
| **Test IDs / semantics / accessibility identifiers** | Localizar nodos de UI de forma estable (sirve también a la automatización de amado) |
| **Abstracción de fronteras de plataforma** | Envolver GPS, cámara, notificaciones, biometría, almacenamiento tras interfaces propias |
| **Reloj/tiempo y aleatoriedad inyectados** | Determinismo en lógica con fechas, timeouts, IDs |
| **Builds/flavors de prueba y feature flags** | Configuraciones de QA, mocks activables, hooks de estado |
| **Hooks de inspección** | Puntos para inyectar estado inicial o resetear datos entre pruebas |

La testability que palma provee es también el **puente hacia amado**: sus tests de sistema (p. ej. Appium/XCUITest/Maestro/Detox) dependen de test IDs estables, deep links y builds instrumentables que palma expone deliberadamente.

## 6. Test doubles para SDKs de plataforma y red

Las APIs nativas (sensores, permisos, push, almacenamiento seguro, in-app purchases, biometría) no deben golpearse en unit/integration tests.

- **Fakes**: implementación ligera con comportamiento (p. ej. un `FakeKeychain` en memoria).
- **Stubs**: respuestas predefinidas para consultas.
- **Mocks**: verificación de interacciones (se llamó a `requestPermission` una vez).
- Regla: se sustituye la **frontera de plataforma** detrás de una interfaz propia (§5), nunca se mockea tipo del sistema que no se controla.

## 7. Awareness de matriz de dispositivos y fragmentación

palma **conoce** la fragmentación —versiones de SO, tamaños/densidades de pantalla, notches/safe areas, chipsets, RAM, capacidades de OEM, permisos runtime— y **construye defensivamente** para ella (ver [plataformas-nativas.md](plataformas-nativas.md)). Pero la **matriz oficial de dispositivos y el veredicto de compatibilidad los fija amado**. palma diseña el código y las pruebas locales para ser robustos ante esa diversidad; amado decide el alcance y ejecuta la validación de cobertura en device clouds.

## 8. Integración de pruebas en el pipeline

palma escribe pruebas que **corren de forma no interactiva y determinista**, listas para automatizarse:

- Ejecutables headless en emuladores/simuladores; sin dependencia de estado manual.
- Rápidas y aisladas (unit) separadas de las lentas (UI/integración) por *suites/tags*.
- Reportes en formato estándar (p. ej. JUnit XML) y artefactos (capturas, videos) que el CI publica.
- Semillas y limpieza de datos entre corridas; cero flakiness tolerada como deuda.

**El CI/CD lo provee y opera baluarte**; palma entrega pruebas que encajan en él y colabora en el *stage* mobile (matriz de build, firma, caché). Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

## Greenfield, en construcción y brownfield

- **Greenfield**: **test-first donde aporta** —lógica, view models, mappers, reglas de negocio se benefician de escribir la prueba antes; la UI puede seguir un ciclo más pragmático. La testability se diseña desde el primer commit, no se retrofitea.
- **En construcción**: la testability se cablea a medida que crecen los módulos; cada feature nuevo llega con sus pruebas y engancha en el CI desde el primer flujo funcional, sin dejar deuda de cobertura para "después".
- **Brownfield**: antes de refactorizar código heredado sin cobertura, **tender una red de seguridad** —characterization tests que fijan el comportamiento actual (aunque sea imperfecto)— y solo entonces cambiar la estructura con confianza. Primero caracterizar, luego mejorar.

## Cierre tiered

- **Craft de palma**: escribir y ejecutar las pruebas del propio código (unit, UI, snapshot, integración) y diseñar la testability que las hace posibles. Es parte de "construir bien", no un extra.
- **Estrategia y veredicto de calidad → amado**: qué probar como sistema, matriz de dispositivos, criterios de aceptación, gestión de defectos, QA E2E y el juicio final de calidad. palma **provee testability y reporta huecos**; no emite el veredicto.
- **CI/CD → baluarte**: infraestructura, orquestación y ejecución del pipeline. palma entrega pruebas automatizables; baluarte las corre y las gobierna en la entrega.
