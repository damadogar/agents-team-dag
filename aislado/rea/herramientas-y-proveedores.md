# Herramientas y proveedores — selección neutral

## 1. Principio

La herramienta es un **medio de evidencia**, no una identidad. Eliges por:

- Formato del target
- Pregunta (pseudocódigo vs inventory vs runtime)
- Licencia disponible del operador
- Host OS (p. ej. Hopper no en Windows; Ghidra Windows experimental en REA)

## 2. Mapa rápido

| Necesidad | Opciones típicas |
|---|---|
| Decompilación nativa profunda | Ghidra, IDA (+Hex-Rays), Hopper, Kuna |
| Android DEX/Smali | JADX / tools Android del puente |
| Electron / JS | Análisis JS/ASAR (a menudo sin motor nativo) |
| .NET managed | Inspectors managed / dnSpy-class (según stack del operador) |
| Firmware | Binwalk/Unblob + motores nativos sobre extractos |
| Runtime | Debuggers / Frida-class / browser CDP — solo con autoridad |
| Puente agente↔motores | MCP/CLI **REA** (`rea-agents`) u otro bridge equivalente |

## 3. Puente REA (cuando el operador lo tiene)

- Setup: `npx rea-agents setup` (humano aprueba cambios)
- Doctor: `npx rea-agents doctor --json` / por provider
- No instala Java/Ghidra/IDA por ti
- Variables típicas: `GHIDRA_INSTALL_DIR`, `JAVA_HOME`, `REA_IDA_MCP_CONFIG`, etc.

Si tools faltan: [references/connection-and-recovery.md](references/connection-and-recovery.md).

## 4. Criterios de selección

1. ¿El tool responde la pregunta con el tipo de evidencia correcto?
2. ¿Es read-only o tiene side-effects (attach, extract, mutate)?
3. ¿El resultado trae provenance (digest, address, limitations)?
4. ¿Hay alternativa más barata en tokens/tiempo?

## 5. Sin romanticizar

- Ghidra gratis ≠ siempre suficiente (licencia IDA puede ser necesaria en el lab del cliente).
- IDA no “gana” automáticamente en malware obfuscado.
- Strings+PE headers a veces bastan para triage — úsalos.

## 6. Higiene

- Paths absolutos
- Trabajar fuera del árbol del target cuando uses `npx`
- Backups antes de tocar configs del agente
- No guardar credenciales de transporte en el informe
