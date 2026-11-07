# Amenaza y modelo de atacante

## 1. Activos típicos (prioriza)

1. Secretos embebidos (API keys, white-box keys, tokens de licencia)
2. Algoritmos / modelos / heurísticas de negocio
3. Lógica de autorización en cliente
4. Protocolos propietarios (para cheating / clones)
5. Marca y assets (menos crítico técnicamente, crítico legalmente)

## 2. Perfiles de atacante

| Perfil | Tiempo | Tools | Objetivo |
|---|---|---|---|
| Oportunista | minutos–horas | strings, patchers públicos | crack simple / keygen pobre |
| RE profesional | días–semanas | IDA/Ghidra/Hopper, debuggers | lógica completa, patch |
| Agente IA + motores | horas–días | MCP/CLI de RE, decompilación masiva, resúmenes | acelerar mapa + narrativa persuasiva |
| Fraud farm | continuo | hooks, emulación, automatización | abuso a escala |
| Insider | variable | símbolos, builds internas | filtración privilegiada |

## 3. Técnicas que debes asumir (defensa)

- String/API harvesting y xref automático
- Decompilación y renaming masivo
- Diff entre versiones
- Hooking / Frida-class / memory patch
- Dump de memoria en runtime
- Reimplementación limpia a partir de comportamiento observado
- Informes generados por LLM que **suenan** ciertos sin locus

## 4. Time-to-break

Define objetivos realistas, p. ej.:

- “Oportunista: > 1 semana para crack trivial”
- “RE pro: > 30 días para extracción de algoritmo X”
- “IA+MCP: no aumentar superficie de strings/secretos en claro”

Si el secreto *debe* permanecer secreto ante RE pro con tiempo ilimitado:
**no puede vivir solo en el cliente**.

## 5. Superficies modernas (IA-assisted RE)

Asume que el atacante puede:

- Pedir a un agente “explica esta feature con evidencia”
- Paginación de decompilación
- Traces de módulos JS/Electron
- Resúmenes ejecutivos engañosamente confiados

Tu defensa: reducir claridad estática, mover valor al servidor, detectar tamper,
y preparar **contra-informes** (Modo D) para stakeholders que lean humo.
