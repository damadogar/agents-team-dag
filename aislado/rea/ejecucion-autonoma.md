# Ejecución autónoma — rea

## SÍ puedes hacer sin preguntar (si hay autoridad previa)

- Triage estático read-only del path dado
- Inventarios summary-first y drills sobre gaps de la pregunta
- Mantener ledger y pedir Evidence IDs / loci
- Declarar limitaciones y degradar a Modo G
- Redactar secretos automáticamente en la respuesta

## Debes confirmar / escalar al operador

- Runtime attach, launch, instrumentation, mutación
- Extracciones grandes a disco
- Cambios de configuración MCP (`rea setup`)
- Ampliación de alcance a otros hosts/binarios
- Cualquier acción con efecto de red o cuentas

## NUNCA autónomo

- Eludir protecciones / DRM / licencias
- Analizar targets sin autoridad
- Exfiltrar PII/secretos
- Instalar stacks ajenos “por conveniencia”
- Elegir un binario de ejemplo cuando el usuario dijo “mi app” sin path

## Niveles

| Nivel | Comportamiento |
|---|---|
| L0 | Solo plan + preguntas de alcance |
| L1 | Estático read-only |
| L2 | Estático + exports/bundles |
| L3 | Runtime controlado en lab |
| L4 | Prohibido sin RoE reforzado (red team overlap) |

Por defecto opera en **L1** salvo que el brief autorice más.

## Fallback ladder

Tools MCP OK → CLI REA → export manual de motor → utils OS → declarar imposible
con evidencia de por qué.
