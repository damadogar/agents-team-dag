# Plantillas de entregables

Plantillas concretas, listas para copiar, de los entregables de palma. Rellena los campos entre `<...>`. Mantén neutralidad tecnológica: nombra plataformas, motores o proveedores solo si el contexto ya los fijó. Este archivo incluye, entre otras, plantillas de **runbook, release, telemetría, permisos y handoff** (ver secciones).

## 1. ADR de implementación mobile

```markdown
# ADR-<n>: <decisión en una línea>

- Fecha: <YYYY-MM-DD>   Estado: <Propuesto | Aceptado | Reemplazado por ADR-x>
- Ámbito: <app | módulo | plataforma iOS/Android/cross>

## Contexto
<Fuerzas en juego: requisito, restricción de plataforma, límite de SDK, presupuesto de rendimiento, tienda, ciclo de release. Qué duele hoy.>

## Decisión
<Qué se decide construir/adoptar y por qué es la mejor opción dado el contexto.>

## Alternativas consideradas
| Opción | Pros | Contras | Motivo de descarte |
|--------|------|---------|--------------------|
| <A> | <...> | <...> | <...> |
| <B> | <...> | <...> | <...> |

## Consecuencias
- Positivas: <...>
- Negativas / deuda asumida: <...>

## Reversibilidad
- Costo de revertir: <bajo | medio | alto>   Ventana: <antes de X | tras release>
- Mecanismo de vuelta atrás: <feature flag | kill switch | OTA | rollback de release>
- Puntos sin retorno: <migración de datos local, cambio de esquema persistido, API pública>
```

## 2. Matriz de decisión: Nativo vs Cross-platform vs Híbrido

Pondera cada criterio (peso 1-5 según prioridad del proyecto) y puntúa cada opción 1-5. Total = Σ(peso × puntuación).

```markdown
| Criterio | Peso | Nativo | Cross-platform | Híbrido (web-shell) |
|----------------------------------|:----:|:------:|:--------------:|:-------------------:|
| Acceso a APIs de plataforma      |      |        |                |                     |
| Rendimiento / fluidez UI         |      |        |                |                     |
| Fidelidad look & feel nativo     |      |        |                |                     |
| Velocidad de desarrollo          |      |        |                |                     |
| Reutilización de código          |      |        |                |                     |
| Tamaño y disponibilidad de equipo|      |        |                |                     |
| Costo de mantenimiento 2 SO      |      |        |                |                     |
| Madurez del ecosistema/librerías |      |        |                |                     |
| Time-to-market                   |      |        |                |                     |
| Riesgo de dependencia del framework|    |        |                |                     |
| **Total ponderado**              |      |        |                |                     |

Recomendación: <opción> — justificación: <2-3 líneas atadas a los pesos>.
Condiciones que invalidarían la decisión: <p.ej. si aparece requisito de X nativo>.
```

## 3. Plan de release mobile

```markdown
# Release <appId> <versionName> (<versionCode/build>)

## Versionado
- versionName: <semver visible>   versionCode/build: <entero monótono>
- Regla de incremento: <patch fix | minor feature | major ruptura>

## Firma (signing)
- Origen de claves: <keystore/cert gestionado por baluarte | almacén seguro>
- Verificación: <fingerprint esperado>   Rotación: <política>

## Variantes / flavors
| Variante | Ambiente | Endpoint | Flags activos |
|----------|----------|----------|---------------|
| <debug>  | <dev>    | <...>    | <...>         |
| <release>| <prod>   | <...>    | <...>         |

## Phased rollout (staged)
| Fase | % usuarios | Duración mínima | Puerta de avance |
|------|-----------|-----------------|------------------|
| 1    | <1-5%>    | <24 h>          | crash-free ≥ objetivo, sin picos ANR |
| 2    | <10-20%>  | <24-48 h>       | métricas estables, sin bugs P1 |
| 3    | <50%>     | <24 h>          | sin regresión de negocio |
| 4    | 100%      | —               | firma verde de release owner |

## OTA (si aplica)
- Alcance: <solo assets/JS-bundle, nunca binario nativo>
- Compatibilidad: <bundle ↔ rango de versionCode>   Firma del bundle: <sí>

## Criterios de HALT (detener rollout)
- crash-free < <umbral>%   |   ANR > <umbral>%   |   bug P1/P0 confirmado
- caída de métrica de negocio > <X>%   |   rechazo o alerta de tienda
Al gatillar HALT → ejecutar `runbook` (rollback).
```

## 4. Runbook mobile

```markdown
# Runbook: <release | incidente> <appId> <versión>

## Pre-requisitos
- Accesos: <consola de tienda, panel de flags/OTA, dashboards de telemetría>
- Owner de guardia: <rol>   Escalamiento: <a quién, cuándo>

## Procedimiento de release
1. Verificar firma y variante correcta del artefacto.
2. Publicar en fase 1 (<%>). Registrar hora y build.
3. Observar dashboards <crash-free / ANR / negocio> por <ventana>.
4. Avanzar de fase solo si se cumplen las puertas del `release`.

## Rollback / mitigación (de menor a mayor impacto)
1. **Feature flag / kill switch**: desactivar `<flag>` → efecto inmediato, sin publicar.
2. **OTA**: revertir bundle a `<versión previa>` (solo capa no nativa).
3. **Halt de rollout**: detener despliegue por fases en la tienda.
4. **Despublicar / promover build anterior**: última opción; los usuarios ya actualizados NO revierten binario → depende de flags.
> Regla: el binario nativo no se "desinstala" solo; toda ruta de vuelta atrás real vive en flags/OTA/servidor.

## Respuesta a rechazo de tienda
1. Leer motivo exacto y política citada.
2. Clasificar: <metadata | permisos | privacidad | contenido | técnico>.
3. Corregir causa raíz; documentar en `permisos`/ADR si cambia comportamiento.
4. Reenviar con notas para el revisor. Si es urgente, solicitar revisión acelerada.
5. Si bloquea a usuarios en producción → mitigar por servidor/flags mientras se aprueba.
```

## 5. Reporte de auditoría de app

Madurez por dimensión (1 inexistente · 2 inicial · 3 definido · 4 gestionado · 5 optimizado).

```markdown
# Auditoría mobile — <appId>   Fecha: <YYYY-MM-DD>

| Dimensión | Nivel (1-5) | Evidencia | Brecha principal |
|-----------|:-----------:|-----------|------------------|
| Arquitectura y modularidad |   |   |   |
| Rendimiento (arranque, UI, batería) |   |   |   |
| Estabilidad (crash-free / ANR) |   |   |   |
| Ciclo de release y firma |   |   |   |
| Permisos y privacidad |   |   |   |
| Telemetría y observabilidad |   |   |   |
| Offline / sincronización |   |   |   |
| Seguridad (almacenamiento, transporte, secretos) |   |   |   |
| Accesibilidad |   |   |   |
| Testing y CI mobile |   |   |   |

## Hallazgos
| ID | Severidad | Dimensión | Descripción | Recomendación | Reversibilidad del fix |
|----|-----------|-----------|-------------|---------------|------------------------|
| H1 | <Crítica/Alta/Media/Baja> | <...> | <...> | <...> | <...> |

Resumen ejecutivo: <3-5 líneas: madurez global, riesgos top, orden sugerido>.
```

## 6. Contrato de handoff

```markdown
# Handoff <id>

1. Origen / Destino: <palma> → <agente/rol destino>
2. Objetivo: <resultado esperado, medible>
3. Contexto: <por qué, restricciones, decisiones previas (ADR-x)>
4. Insumos: <artefactos, ramas, credenciales, specs, accesos entregados>
5. Criterios de aceptación: <lista verificable de "hecho">
6. Dependencias ajenas: <qué necesita de terceros para no bloquearse>
7. Reversibilidad: <cómo se revierte lo entregado; punto sin retorno>
8. Verificación: <cómo el receptor confirma que quedó bien: prueba/checklist>
```

## 7. Checklist de permisos y privacidad

```markdown
| Permiso | Propósito (feature concreta) | Purpose string (texto al usuario) | Degradación si se niega | Etiqueta de datos (tipo · uso · compartido) |
|---------|------------------------------|-----------------------------------|-------------------------|---------------------------------------------|
| <cámara> | <escanear documento> | "<Usamos la cámara para...>" | <flujo alterno / manual> | <foto · funcionalidad · no> |
| <ubicación> | <...> | "<...>" | <...> | <...> |
| <notificaciones> | <...> | "<...>" | <...> | <...> |
```

Reglas: pedir el permiso en contexto (no en el arranque), justo antes de usarlo. Todo permiso debe tener degradación definida. La app nunca queda inutilizable por una negativa salvo que el permiso sea el núcleo del servicio. La etiqueta de datos debe coincidir con lo que el código realmente recolecta.

## 8. Especificación de telemetría

```markdown
# Telemetría — <appId>

## Objetivos de salud
- Crash-free sessions ≥ <99.x>%   |   Crash-free users ≥ <99.x>%
- ANR / freeze rate ≤ <umbral>%   |   Cold start p90 ≤ <ms>

## Eventos
| Evento | Disparador | Propiedades | Tipo |
|--------|-----------|-------------|------|
| app_open | arranque | source, cold_start_ms | ciclo de vida |
| <feature>_completed | <acción exitosa> | duration_ms, result | negocio |
| <feature>_failed | <error de flujo> | error_code, retry | negocio |

Convención: nombres `snake_case`, verbo en pasado; sin PII en propiedades; muestreo declarado por evento de alto volumen.

## Dashboards
| Dashboard | Métricas | Audiencia | Alerta |
|-----------|----------|-----------|--------|
| Estabilidad | crash-free, ANR, top crashes | equipo | crash-free < objetivo |
| Adopción | funnel <feature>, retención | producto | caída > X% |
| Release | métricas por versionCode | release owner | regresión post-rollout |
```

## 9. Plan de sincronización offline

```markdown
# Sync offline — <feature/dominio>

## Estrategia
- Modelo: <offline-first | cache-then-network | read-only cache>
- Almacén local: <BD embebida / cola de mutaciones>   Cifrado: <sí/no>
- Disparadores de sync: <al reconectar | periódico | push | manual>

## Resolución de conflictos
| Escenario | Política | Razón |
|-----------|----------|-------|
| Edición concurrente mismo registro | <last-write-wins / merge por campo / gana servidor> | <...> |
| Borrado local vs edición remota | <...> | <...> |
| Reloj de cliente no confiable | <usar versión/vector del servidor> | evitar LWW por hora local |

## Casos límite
- Cola de mutaciones tras reinstalación / cambio de dispositivo.
- Reintentos idempotentes (clave de idempotencia por mutación).
- Datos parciales / paginación interrumpida.
- Migración de esquema local entre versiones de app.
- Límite de tamaño de caché y política de expulsión.

## Verificación
- Prueba en avión → editar → reconectar → estado convergente y sin duplicados.
```

## 10. Solicitud de handoff a otro agente

Elige destino según la frontera. Rellena y envía.

```markdown
# Solicitud de handoff: palma → <destino>

- Destino: <eneida | motor | uxuifull | peakformance | destroyer | amado | baluarte | farola | sysuniversal-ai | andulfo | certero | tompo | docpower>
- Motivo (frontera): <ver guía abajo>
- Objetivo: <qué necesito que decida/haga>
- Contexto: <estado actual, ADR relacionados, restricción de plataforma>
- Insumos entregados: <specs, ramas, dashboards, accesos>
- Criterio de aceptación de la respuesta: <qué recibo de vuelta y en qué forma>
- Reversibilidad / riesgo: <impacto si su respuesta cambia mi implementación>
```

Guía de frontera:
- **eneida** — decisión de arquitectura de sistema, contratos/eventos, límites de servicio.
- **motor** — implementación del backend/API que la app consume.
- **uxuifull** — diseño UX/UI, flujos, tokens, accesibilidad visual antes de implementar.
- **peakformance** — metas y presupuestos de rendimiento, diagnóstico profundo de perf.
- **destroyer** — decisión y auditoría de seguridad (secretos, transporte, almacenamiento).
- **amado** — estrategia de pruebas, casos, automatización y evidencia de QA.
- **baluarte** — pipeline de build/entrega, firma gestionada, infraestructura de release y OTA.
- **farola** — UI web / responsive / PWA, y la UI web dentro del híbrido (WebView).
- **sysuniversal-ai** — modelo/serving de IA para integrar la inferencia (on-device o remota).
- **andulfo** — plano de datos (esquema, motor, HA/DR y backup de datos) que el cliente consume.
- **certero** — correctitud del código, code review y debugging de un bug de lógica.
- **tompo** — prioridad/valor de negocio, modelo de monetización y decisión de alcance del producto.
- **docpower** — forma/estructura de la documentación (runbooks, guías de release); palma es SME del contenido.
