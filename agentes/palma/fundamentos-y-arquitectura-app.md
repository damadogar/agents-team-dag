# Fundamentos y Arquitectura de App Mobile

Este satélite define cómo se estructura la aplicación móvil a nivel de implementación: los patrones que organizan su código, cómo se aísla la lógica de negocio del framework de UI, cómo se modulariza, navega, gestiona estado, inyectan dependencias y sobrevive el estado a un ciclo de vida hostil. Todo con **neutralidad tecnológica total**: los patrones son universales; las herramientas se citan solo como ejemplos intercambiables.

La frontera es explícita: **palma construye la arquitectura de la app**; la arquitectura del **sistema** (límites de servicio, contratos macro, topología distribuida) la decide [eneida](interoperabilidad-y-aliados.md); la **correctitud** del código la revisa certero; el **diseño** de UX/UI lo define uxuifull y palma lo implementa fielmente. Ver también [plataformas-nativas.md](plataformas-nativas.md), [cross-platform.md](cross-platform.md) y [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md).

## 1. Patrones de arquitectura de app

No existe un patrón "correcto": existe el patrón adecuado al tamaño del equipo, la complejidad del estado y la vida esperada del código. Todos comparten un objetivo — separar responsabilidades para que la UI sea delgada, la lógica testeable y el cambio localizado.

| Patrón | Idea central | Flujo de datos | Fortaleza | Costo / riesgo |
|--------|--------------|----------------|-----------|----------------|
| **MVC** | Vista + Controlador + Modelo | Bidireccional | Simple, universal | Controladores obesos (Massive VC), acoplamiento a la vista |
| **MVP** | Presenter orquesta; vista pasiva vía interfaz | Bidireccional (contrato) | Vista muy testeable (mockable) | Mucho boilerplate de interfaces |
| **MVVM** | ViewModel expone estado observable; la vista se enlaza | Reactivo (binding) | Encaja con UI declarativa; desacople natural | ViewModels que crecen; bindings mágicos difíciles de rastrear |
| **MVI** | Estado inmutable único + intents del usuario | Unidireccional (UDF) | Estado predecible, reproducible, depurable | Verbosidad; muchas clases de estado/evento |
| **Redux-like / UDF** | Store único, reducers puros, acciones | Unidireccional estricto | Time-travel, testabilidad total, trazabilidad | Sobre-ingeniería en apps pequeñas |
| **TCA (Composable Arch.)** | Feature = State+Action+Reducer+Effect composables | Unidireccional | Composición y aislamiento de efectos formalizados | Curva de aprendizaje; opinión fuerte |
| **VIPER** | View-Interactor-Presenter-Entity-Router | Bidireccional por capas | Responsabilidades muy segmentadas | Alto boilerplate; sobredimensionado para lo simple |
| **Clean Architecture** | Capas concéntricas; dependencias hacia el dominio | Depende de la capa externa | Independencia de framework/UI/datos | Indirección y ceremonia si se aplica dogmáticamente |

Criterios de elección:

- **UI declarativa moderna** → gravita a MVVM o MVI/UDF, porque el estado observable e inmutable calza con el render por difado.
- **Estado complejo, muchos efectos secundarios, necesidad de reproducibilidad** → MVI, redux-like o TCA.
- **App pequeña / prototipo / pantalla CRUD** → MVC/MVVM ligero; imponer VIPER o redux aquí es deuda ceremonial.
- **Base de código grande y longeva con múltiples equipos** → Clean Architecture como esqueleto, con MVVM/MVI dentro de cada feature.

Regla práctica: **un patrón de presentación (MVVM/MVI) + un esqueleto de capas (Clean) no compiten, se combinan.** El patrón organiza la pantalla; las capas organizan el proyecto.

## 2. Separación dominio / framework

El principio no negociable: **la lógica de negocio no conoce el framework de UI ni el motor de ejecución.** Las entidades, reglas, casos de uso e invariantes del dominio no deben importar el toolkit de vistas nativo, el framework declarativo ni el runtime cross-platform. Si mañana se reescribe la UI o se migra de motor, el dominio permanece intacto.

```text
   [ UI / Framework ]  →  [ Presentación (VM/Reducer) ]  →  [ Casos de uso ]  →  [ Dominio ]
          (volátil)              (adaptador)                  (aplicación)        (estable, puro)
                                                                   ↑
                                                          [ Datos / repos ]  (implementan interfaces del dominio)
```

- Las **dependencias apuntan hacia adentro**: el dominio define interfaces (puertos); las capas externas las implementan (adaptadores). Inversión de dependencias en su forma pura.
- El dominio se prueba **sin emulador ni pantalla**: son pruebas unitarias rápidas de lógica pura.
- La presentación traduce estado de dominio a estado de UI y eventos de UI a intenciones de dominio; no contiene reglas de negocio.
- **Señal de alarma:** un tipo del framework de UI o del motor cross-platform importado dentro de una entidad o caso de uso. Eso es acoplamiento que hipoteca la portabilidad.

## 3. Modularización

Un solo módulo monolítico no escala: compila lento, colisiona en merges y difumina el ownership. La modularización parte la app en unidades con fronteras explícitas.

- **Feature modules:** cada funcionalidad vive en su módulo, con su UI, presentación y casos de uso; expone una API mínima y oculta el resto.
- **Capas transversales:** módulos de dominio, de datos, de diseño/UI compartida (design system), de utilidades e infraestructura (red, persistencia, telemetría).
- **Grafo de dependencias dirigido y acíclico:** las features dependen de núcleos compartidos, nunca entre sí directamente; la comunicación inter-feature ocurre por interfaces o por la capa de navegación/eventos.
- **Build times:** la modularización habilita compilación incremental y en paralelo, y cacheo de artefactos. Menos superficie recompilada por cambio.
- **Ownership por equipo:** cada módulo tiene dueño; los límites de módulo son también límites organizacionales (Ley de Conway aplicada a propósito).
- **Monorepo mobile:** una sola raíz con muchos módulos favorece refactors atómicos y versión única de dependencias; exige tooling de build y convenciones de frontera estrictas para no degenerar en acoplamiento implícito.

Regla: **modularizar por dominio/feature, no por tipo técnico.** Una carpeta gigante de "todos los ViewModels" es lo contrario de un módulo.

## 4. Navegación

La navegación es un subsistema, no una colección de saltos ad hoc. Modela el grafo de destinos y las transiciones entre ellos.

- **Primitivas:** *stack* (pila push/pop, jerárquico), *tab* (secciones paralelas persistentes), *modal/overlay* (interrupción temporal), y flujos anidados que las combinan.
- **Patrón Coordinator/Router:** extrae la decisión de "a dónde ir" fuera de la pantalla. La pantalla emite un evento ("usuario pidió el detalle"); el coordinador decide el destino. Desacopla pantallas entre sí y hace la navegación testeable.
- **Deep navigation y deep links:** un destino debe ser alcanzable por URL/intención externa reconstruyendo la pila intermedia; la navegación por estado (una ruta declarativa derivada del estado) facilita esto frente a la navegación imperativa.
- **Neutralidad:** existen componentes de navegación de primera parte en cada plataforma y en los frameworks cross-platform (p. ej. navegación por grafo declarativo o por rutas tipadas); todos implementan las mismas primitivas. Elegir por integración con el patrón de estado, no por moda.
- **Tipado de rutas:** rutas y argumentos tipados evitan errores de destino/argumento en tiempo de compilación en lugar de en runtime.

## 5. Gestión de estado

El estado es la causa raíz de la mayoría de los bugs de UI. Domesticarlo es arquitectura, no detalle.

- **State holders:** un objeto (ViewModel, presenter, store) posee el estado de una pantalla o flujo y sobrevive a recomposiciones/redibujos de la vista. La vista es una función del estado, no su dueña.
- **Flujo unidireccional (UDF):** el estado fluye hacia la UI; los eventos fluyen de vuelta como intenciones; el estado se recalcula en un solo lugar. Predecible y depurable.
- **Estado inmutable:** representar el estado como valores inmutables evita mutaciones concurrentes y hace el render determinista.
- **Reactividad:** streams observables (p. ej. flujos asíncronos, publishers reactivos o librerías Rx) propagan cambios sin polling. Cuidar la cancelación ligada al ciclo de vida para no filtrar trabajo ni actualizar vistas muertas.
- **Alcance del estado:** distinguir estado de UI efímero (scroll, foco), estado de pantalla (datos cargados), estado de sesión/app (usuario, tema) y estado persistente. Cada uno vive en el scope correcto; subir estado más de lo necesario crea acoplamiento.

## 6. Inyección de dependencias

La DI existe para que las clases reciban sus colaboradores en vez de construirlos, habilitando sustitución (tests, variantes) y respetando la inversión de dependencias de la sección 2.

| Enfoque | Cuándo | Trade-off |
|---------|--------|-----------|
| **Manual / constructor injection** | Apps pequeñas-medianas; máxima claridad | Verboso al cablear grafos grandes, pero explícito y sin magia |
| **Service locator** | Acceso global simple | Oculta dependencias; dificulta el testeo; usar con cautela |
| **Contenedor / framework de DI** (p. ej. contenedores por code-gen o por registro en runtime) | Grafos grandes, muchos scopes | Menos boilerplate y scopes gestionados; añade complejidad de build y una capa "mágica" que hay que entender |

Principios independientes de la herramienta: **inyectar por constructor siempre que se pueda; depender de abstracciones, no de concreciones; alinear el ciclo de vida de la dependencia con su scope** (singleton de app, por sesión, por pantalla). La correctitud del cableado y de los scopes es materia de revisión de certero.

## 7. Ciclo de vida y supervivencia del estado

El entorno móvil es hostil: el sistema puede rotar la pantalla, enviar la app a segundo plano, o **matar el proceso** para recuperar memoria y recrearlo después. La arquitectura debe asumir que cualquier cosa en memoria puede desaparecer.

- **Rotación / cambio de configuración:** la vista se reconstruye; el state holder debe sobrevivir a ese evento para no perder datos ya cargados.
- **Background / foreground:** liberar recursos costosos (cámara, sensores, sockets) al ir a segundo plano; reanudar al volver. Pausar trabajo que no debe correr oculto.
- **Muerte del proceso:** al ser recreada, la app debe **restaurar el estado esencial** (identidad de pantalla, entrada del usuario, posición) desde un mecanismo de *saved state* persistido, no desde memoria.
- **Jerarquía de persistencia:** memoria (efímero) → estado guardado ligero (sobrevive muerte del proceso, tamaño acotado) → almacenamiento local/BD (fuente de verdad durable). No abusar del estado guardado para datos grandes.
- **Regla de oro:** el estado que el usuario notaría perder debe ser **reconstruible o persistido**. Probar apagando el proceso, no solo rotando.

## 8. Greenfield, en construcción y brownfield

La misma arquitectura se aplica distinto según la madurez del código:

- **Greenfield:** instaurar desde el día uno el esqueleto de capas, la separación dominio/framework y el patrón de presentación elegido. Poner las fronteras de módulo antes de que el código las borre. Evitar sobre-ingeniería: profundidad proporcional a la complejidad real prevista.
- **En construcción:** madurar de forma incremental. Extraer casos de uso a medida que la lógica crece, modularizar cuando el build o los equipos lo pidan, endurecer la gestión de estado donde aparezcan bugs de ciclo de vida. Refactor continuo guiado por dolor real, no por dogma.
- **Brownfield / rescate:** no reescribir de golpe. Encapsular lo legado tras interfaces, introducir una capa de dominio limpia en el borde nuevo, aplicar el patrón "estrangulador" migrando pantalla por pantalla, y blindar cada extracción con pruebas de caracterización antes de mover código.

## 9. Fronteras y modelo tiered

Palma es **T1** en la arquitectura de la app: define y construye patrones de presentación, capas, módulos, navegación, estado, DI y supervivencia del ciclo de vida.

- **Arquitectura de sistema → eneida.** Los límites de servicio, contratos macro, topología distribuida y decisiones cross-cutting del ecosistema los decide eneida; palma los recibe y los materializa correctamente dentro de la app. Ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).
- **Correctitud → certero.** La corrección de bugs de lógica, concurrencia, invariantes y el cableado de DI se revisa con certero; palma construye, certero verifica correctitud.
- **Diseño → uxuifull.** La UX/UI la define uxuifull; palma la implementa con fidelidad, respetando accesibilidad y adaptación tratadas en [ui-adaptive-y-accesibilidad.md](ui-adaptive-y-accesibilidad.md).
- **T2/T3 en la frontera:** cuando una decisión toca simultáneamente arquitectura de sistema, correctitud crítica o diseño, palma no decide en solitario: eleva y coordina con el dueño de esa disciplina, documentando el trade-off. Palma manda dentro de las paredes de la app; los cimientos del terreno se acuerdan con quien los posee.
