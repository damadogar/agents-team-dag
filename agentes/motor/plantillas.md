# plantillas.md — Plantillas de entregables del desarrollador

> Copia y rellena. El entregable real es **código**; estas plantillas estructuran
> cómo lo presentas. Cada entrega cierra con "Cómo correr/probar", "Riesgos" y
> "Escalamientos/Delegaciones".

## 1. Respuesta estándar del desarrollador (formato al implementar)

```
## 1. Encargo entendido
- Qué me ordenaron implementar: ...
- Diseño/decisiones recibidas (de eneida/orquestador): ...
- Supuestos de implementación [SUPUESTO]: ...
- Dudas/defectos de diseño a ESCALAR (si los hay): ...

## 2. Plan de implementación
- Archivos a crear/modificar (lista exacta): ...
- Orden de los cambios: ...
- Decisiones de implementación (algoritmo/estructura/librería) + por qué: ...

## 3. Código / cambios
- <el código real, por archivo>

## 4. Pruebas propias
- Qué cubrí (unit/integration), incl. errores y casos borde: ...
- (Estrategia global, regresión y no funcional → amado)

## 5. Cómo correr / probar
- Comandos de build/run/test, migraciones, variables/config: ...

## 6. Riesgos y escalamientos
- Riesgos técnicos y mitigación: ...
- A eneida/orquestador (diseño/arquitectura/tecnología): ...
- A amado (pruebas/defectos/no funcional): ...
```

## 2. Borrador de ADR (lo gobierna y aprueba `eneida`)

> Motor redacta el borrador con el contexto y opciones backend; el estado final,
> la aprobación y el registro en el repo de decisiones son de `eneida`.

```
# ADR-NNN (BORRADOR para eneida): <título de la decisión>
- Estado: Propuesto (pendiente de gobierno de eneida)
- Fecha: AAAA-MM-DD   Autor del borrador: Motor

## Contexto
<fuerzas, requisitos, restricciones, atributos de calidad en juego>

## Opciones consideradas
1. <Opción A> — pros / contras
2. <Opción B> — pros / contras
3. <Opción C> — pros / contras

## Decisión
<opción elegida y por qué, ligada a los atributos de calidad>

## Consecuencias
- Positivas: ...
- Negativas / costos: ...
- Riesgos y mitigaciones: ...
- Reversibilidad: <fácil | media | difícil>
```

## 3. Matriz de trade-offs (puntuada)

```
Criterio (peso)            | Opción A | Opción B | Opción C
---------------------------|----------|----------|---------
Ajuste al problema (0.25)  |   4      |   5      |   3
Escalabilidad (0.20)       |   5      |   3      |   4
Costo/TCO (0.20)           |   3      |   4      |   5
Operabilidad (0.15)        |   4      |   3      |   5
Madurez del equipo (0.10)  |   5      |   2      |   4
Time-to-market (0.10)      |   5      |   3      |   4
---------------------------|----------|----------|---------
Total ponderado            |  ...     |  ...     |  ...
Recomendación: <opción> porque <razón ligada a atributos críticos>
```

## 4. Ficha de implementación de un servicio

> Cómo vas a **construir** el servicio cuyo diseño/límites te dio el arquitecto.

```
# Servicio: <nombre>   (bounded context definido por el arquitecto)
- API (contrato a implementar): <link OpenAPI/Proto/AsyncAPI>
- Eventos publicados / consumidos: ...
- Datos: motor, esquema clave, acceso (repos/queries); migraciones
- Dependencias (síncronas/asíncronas) + resiliencia que implemento (timeout/retry/CB)
- Consistencia por operación e idempotencia: <cómo lo implemento>
- Seguridad en código: authn/authz, validación, datos sensibles, multi-tenancy
- Empaquetado/despliegue: runtime, Dockerfile/IaC, config, rollback
- Observabilidad: métricas RED, logs, trazas que instrumento
- Pruebas propias: qué cubro (unit/integration)
- Escalamientos al arquitecto / riesgos: ...
```

## 5. Propuesta de implementación (cambios grandes — para revisión del arquitecto)

> Para cambios grandes describes **cómo lo implementarías**; la aprobación de
> alcance/arquitectura es del arquitecto/orquestador.

```
# Propuesta de implementación: <título>
- Resumen (1 párrafo) · Qué pide el encargo · Qué NO incluye
- Cómo lo construyo (módulos, archivos, secuencia) · Alternativas de implementación
- Impacto: datos/migración, API/compatibilidad, seguridad, rendimiento
- Plan de despliegue y rollback · Riesgos y mitigaciones · Pruebas propias
- Dudas/decisiones de diseño a escalar al arquitecto
```

## 6. Checklist de "listo para producción" (production readiness)

> Las filas marcadas (QA→amado) las **verifica/ejecuta `amado`**; Motor entrega el
> backend en estado testeable y corrige lo que amado reporte.

```
Datos            [ ] migración reversible  [ ] backups+restore probado  [ ] índices
API              [ ] contrato versionado  [ ] idempotencia  [ ] paginación  [ ] errores RFC9457
Resiliencia      [ ] timeouts  [ ] retries+jitter  [ ] circuit breaker  [ ] backpressure
Seguridad        [ ] authn/authz  [ ] anti-BOLA  [ ] input validation  [ ] secretos en vault  [ ] TLS
Observabilidad   [ ] logs estructurados  [ ] métricas RED  [ ] trazas  [ ] alertas+runbook
Despliegue       [ ] CI verde (lint/SAST/SCA)  [ ] estrategia canary/BG  [ ] rollback probado
Operación        [ ] on-call/runbook  [ ] dashboards  [ ] feature flags/kill-switch
Costo            [ ] estimación TCO  [ ] tagging  [ ] right-sizing
Docs             [ ] README/contrato actualizados  [ ] borrador de ADR (→ eneida)
Verificación     [ ] AC cubiertos por pruebas (QA→amado)  [ ] casos de error/borde (QA→amado)
(QA→amado)       [ ] load/performance test  [ ] regresión  [ ] no funcional/seguridad-DAST
```

## 7. Plan de ejecución backend de una migración / modernización por fases

> La **estrategia** de modernización y el due diligence los define `eneida`; esta
> plantilla es para **ejecutar la parte backend**. Los tests de caracterización y
> de regresión los lidera `amado`.

```
Fase 0 — Descubrimiento backend: inventario, dependencias, métricas base, riesgos
Fase 1 — Estabilizar: observabilidad, red de seguridad de pruebas (con amado), quick wins
Fase 2 — Estrangular (Strangler Fig): nuevas capacidades fuera, fachada/anti-corruption
Fase 3 — Migrar por dominio: extraer/portar incrementalmente, expand/contract en datos
Fase 4 — Decomisionar legacy: cortar tráfico, archivar datos, eliminar
Para cada fase: entregables, criterios de salida, rollback, métricas
```

## 8. Plantilla de postmortem técnico (blameless)

> El postmortem como proceso de calidad/SRE puede liderarlo `amado`/operación;
> Motor aporta la **causa raíz técnica backend** y ejecuta las acciones de código/
> infraestructura.

```
# Incidente <id> — <título>   Severidad: SEV-n   Fecha: ...
- Impacto (usuarios/negocio, duración) · Detección (cómo/cuándo, MTTD)
- Timeline (UTC) · Causa raíz / contribuyentes (5 whys)
- Qué funcionó / qué no · Acciones correctivas (dueño + fecha) · MTTR
```
