# IA on-device — integración de inferencia en el cliente mobile

Este satélite cubre **cómo palma integra y opera la inferencia de modelos en el propio dispositivo**: empaquetado del modelo, runtime de inferencia, aceleración por hardware, tamaño/memoria, formato de consumo y privacidad de los datos que nunca salen del teléfono.

## Frontera rectora (léela primero)

La propiedad del modelo **no es de palma**. **sysuniversal-ai es dueño del modelo, del serving y del MLOps**: decide *qué* modelo se usa, lo entrena, lo evalúa, define su calidad/exactitud, su arquitectura, su régimen de cuantización objetivo y su ciclo de vida. **palma INTEGRA la inferencia on-device en el cliente mobile**: recibe el artefacto del modelo (o la especificación de descarga) y lo hace ejecutar de forma correcta, estable, eficiente y privada dentro de la app.

- palma **no decide el modelo ni su calidad** — la integra y la opera en el dispositivo.
- El **rendimiento** de la inferencia (latencia, energía, memoria, budgets) respeta y reporta a [performance-mobile.md](performance-mobile.md) y a peakformance.
- La **privacidad** de los datos on-device se coordina con destroyer/sello.
- La coordinación de artefactos, contratos y formatos con la plataforma vive en [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md).

Regla mental: *sysuniversal-ai responde "¿es el modelo correcto y suficientemente bueno?"; palma responde "¿corre bien, rápido, dentro del budget y sin filtrar datos en este dispositivo?".*

## 1. Por qué on-device (y cuándo no)

| Motivo | Beneficio on-device | Contraparte |
|---|---|---|
| **Latencia** | Sin round-trip de red; respuesta inmediata (UI/AR/cámara en vivo) | Limitada por CPU/NPU del equipo de gama baja |
| **Privacidad** | El dato sensible (foto, voz, texto) no sale del dispositivo | Requiere manejar el modelo/datos localmente con cuidado |
| **Offline** | Funciona sin conectividad | El modelo debe caber y actualizarse por otra vía |
| **Costo** | Cero costo de inferencia por invocación en servidor | Costo de tamaño de app / descarga / batería |

**Enfoque híbrido** (lo más común y recomendable): on-device para la ruta rápida/privada/offline y *fallback* a cloud (propiedad de sysuniversal-ai) cuando el dispositivo no alcanza, el modelo es demasiado grande, o se requiere un modelo mayor. palma implementa el **enrutamiento** (on-device vs cloud) según capacidad del equipo, disponibilidad de red, tamaño de entrada y política; sysuniversal-ai define *qué* modelo atiende cada ruta.

## 2. Runtimes de inferencia (neutralidad)

palma es neutral respecto al runtime; selecciona por plataforma, formato entregado por sysuniversal-ai y aceleración disponible. Ejemplos frecuentes:

| Runtime (p. ej.) | Ámbito típico | Notas de integración |
|---|---|---|
| Core ML | iOS/Apple | Consume `.mlmodel`/`.mlpackage`; Neural Engine/GPU/CPU |
| TensorFlow Lite / LiteRT | Android/multiplataforma | `.tflite`; delegados NNAPI/GPU/NPU |
| ML Kit | Tareas de visión/texto de alto nivel | APIs listas (OCR, rostros, traducción) sobre modelos empaquetados |
| ONNX Runtime | Multiplataforma, portabilidad de formato | `.onnx`; execution providers por hardware |
| MediaPipe | Pipelines de percepción (manos, pose, segmentación) | Grafos + modelos; buena base para cámara en vivo |

El **runtime es una decisión de integración de palma**; el **formato y el modelo** vienen de sysuniversal-ai. Cuando el formato entregado no encaja con el runtime óptimo del dispositivo, palma lo negocia con sysuniversal-ai (ver [interoperabilidad-y-aliados.md](interoperabilidad-y-aliados.md)) — no re-entrena ni re-cuantiza por su cuenta sin acuerdo.

## 3. Integración del modelo: empaquetado, versionado y actualización

- **Empaquetado**: modelo *bundled* en el binario (disponible offline desde la instalación, pero infla el tamaño de la app) vs **descarga diferida** post-instalación (app liviana, requiere red la primera vez).
- **Versionado del modelo**: cada artefacto lleva versión propia (independiente de la versión de la app). palma mantiene una **matriz de compatibilidad** app ↔ modelo (qué versiones de app soportan qué versión de modelo, y el contrato de entrada/salida).
- **Descarga/actualización**: coordinada con el ciclo de **release/OTA** (ver [release-engineering-y-tiendas.md](release-engineering-y-tiendas.md)). Buenas prácticas de integración:
  - Descarga en segundo plano, reanudable, con verificación de **integridad** (hash/firma) antes de activar el modelo.
  - **Atomicidad**: activar el nuevo modelo solo cuando la descarga y validación estén completas; conservar el anterior como fallback.
  - **Rollback** de modelo sin necesidad de actualizar la app.
  - Respetar red medida/Wi-Fi, batería y políticas de datos del usuario.

```text
[app instalada] --(consulta versión de modelo)--> [catálogo de sysuniversal-ai]
      | descarga v N+1 (background, reanudable)
      | verifica hash/firma
      | valida contrato I/O + smoke test on-device
      v
[activa v N+1]  (v N queda como fallback para rollback)
```

## 4. Aceleración y delegación (con fallback CPU)

palma configura el **delegado/acelerador** apropiado y **siempre define un fallback CPU** correcto:

| Acelerador | Plataforma | Consideraciones |
|---|---|---|
| Neural Engine (Core ML) | Apple | Máxima eficiencia; no todas las ops están soportadas |
| NNAPI | Android | Disponibilidad y calidad varían por fabricante/versión |
| GPU (delegado GPU) | Ambas | Bueno para modelos de visión; costo de energía |
| NPU/DSP del SoC | Android (vendor) | Máximo rendimiento/eficiencia; fragmentación |
| **CPU** | Ambas | **Fallback obligatorio** cuando el delegado falla o no soporta una op |

Reglas de integración: detectar capacidad en runtime, degradar con gracia (delegado → CPU), y **medir** cada ruta. Nunca asumir que un delegado existe o produce el mismo resultado numérico; validar salida y rendimiento por gama de dispositivo. Los budgets (latencia p95, energía, térmico) los fija peakformance vía [performance-mobile.md](performance-mobile.md).

## 5. Tamaño y memoria del modelo en el dispositivo (craft)

El modelo compite con el resto de la app por **almacenamiento, RAM y presupuesto de arranque**:

- **Tamaño de descarga/instalación**: el modelo bundled suma al tamaño de la app en tienda (impacto en conversión). Preferir descarga diferida para modelos grandes.
- **Memoria en ejecución**: cargar el modelo bajo demanda, liberar cuando no se usa, evitar múltiples instancias del intérprete, reusar buffers de entrada/salida.
- **Memory mapping** del artefacto cuando el runtime lo permite (menor RAM residente).
- **Presión de memoria**: responder a avisos del SO liberando el modelo; recargar perezosamente.

Estas metas cuantitativas (MB de app, RAM máxima, tiempo de carga del modelo) las gobierna [performance-mobile.md](performance-mobile.md); palma las implementa en el cliente.

## 6. Cuantización y formatos — desde la integración

**El diseño y el entrenamiento del modelo, incluida la decisión de cuantización, son de sysuniversal-ai.** palma trata la cuantización/formato desde el **punto de vista de integración**:

- **Consumir** el artefacto en el formato entregado (p. ej. FP16, INT8, formatos empaquetados propios del runtime) y confirmar que el runtime/delegado del dispositivo **lo soporta**.
- **Verificar en dispositivo** que el modelo cuantizado corre en el acelerador previsto (algunos delegados solo aceleran ciertos tipos) y que el fallback CPU también funciona.
- **Reportar** a sysuniversal-ai los trade-offs observados *en el cliente* (latencia/energía/memoria por tipo de dato y por dispositivo) como insumo; **la decisión de cambiar la cuantización es de sysuniversal-ai**.
- palma **no re-cuantiza ni recorta el modelo** para "que quepa" sin acuerdo explícito: eso alteraría la calidad, que es propiedad de sysuniversal-ai.

## 7. Privacidad de datos on-device (con destroyer/sello)

Uno de los mayores valores del on-device es que **el dato sensible no viaja**. palma lo preserva:

- Mantener entradas sensibles (imágenes, audio, texto, biometría derivada) **en memoria/almacenamiento local cifrado**; no enviarlas a telemetría ni a logs.
- La **telemetría de inferencia** debe ser agregada/anónima (latencias, tasa de fallback), nunca el contenido de la entrada/salida.
- Si el modelo se descarga, proteger el artefacto según su clasificación (algunos modelos son propiedad intelectual sensible).
- En el enfoque híbrido, ser explícito con el usuario sobre **cuándo** una entrada se envía a cloud vs se procesa localmente.

La **política** de privacidad, clasificación de datos y controles la define **destroyer/sello**; palma implementa y evidencia el cumplimiento en el cliente.

## 8. Casos de uso on-device

| Caso | Ejemplos de tarea | Notas de integración |
|---|---|---|
| **Visión** | Clasificación, detección/segmentación, OCR, escaneo de documentos, AR | Cámara en vivo exige pipeline de baja latencia; procesar frames en hilo dedicado |
| **Texto/NLP** | Autocompletar, clasificación de intención, traducción, redacción asistida | Tokenización on-device; cuidar memoria de vocabularios |
| **Audio** | Wake word, ASR, comandos de voz, diarización | Streaming en tiempo real; presupuesto de energía crítico |
| **LLMs pequeños on-device** | Asistentes, resumen, extracción sin cloud | Modelos compactos/cuantizados; gran presión de RAM y térmica; casi siempre **híbrido** con fallback a cloud (sysuniversal-ai) |

En todos los casos: palma integra el runtime, el hilo de ejecución, el manejo de buffers y el fallback; sysuniversal-ai provee y valida el modelo.

## Greenfield, en construcción y brownfield

- **Greenfield**: definir desde el inicio, con sysuniversal-ai, el contrato del artefacto (formato, versión, I/O), la estrategia bundled/diferida y los budgets con peakformance; diseñar el enrutamiento híbrido y el fallback CPU antes de escribir la primera integración.
- **En construcción**: introducir el runtime detrás de una **abstracción** (interfaz de inferencia) para poder cambiar runtime/formato sin tocar el resto de la app; instrumentar latencia/energía por dispositivo desde el día uno.
- **Brownfield**: auditar una integración existente — ¿hay fallback CPU?, ¿se verifica integridad del modelo descargado?, ¿se libera memoria bajo presión?, ¿se filtran datos sensibles a logs/telemetría?, ¿la versión del modelo está desacoplada de la app? Corregir por prioridad de riesgo (privacidad > correctitud > rendimiento > tamaño).

## Cierre tiered (quién decide qué)

- **T1 — palma integra**: runtime de inferencia, empaquetado/descarga/versionado del modelo en el cliente, aceleración + fallback CPU, gestión de memoria, enrutamiento híbrido on-device/cloud, no-fuga de datos en el cliente.
- **Modelo / serving / MLOps / calidad / cuantización → sysuniversal-ai** (dueño: decide, entrena, evalúa y entrega el modelo).
- **Performance / budgets de inferencia → peakformance** (vía [performance-mobile.md](performance-mobile.md)).
- **Privacidad / clasificación de datos / controles → destroyer/sello**.

palma no decide el modelo ni su calidad: **lo integra y lo opera con excelencia en el dispositivo**, dentro de los budgets y bajo las políticas de privacidad de sus aliados.
