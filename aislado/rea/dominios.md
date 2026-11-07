# Dominios de análisis

## Nativo (PE / ELF / Mach-O)

- Entry points, TLS callbacks, exports/imports, delay-load
- Hardening flags (ASLR, NX, CFG, stack canary…) — presencia ≠ enforcement
- Packers/overlays: inventario antes de “está todo cifrado”
- Go/Rust metadata cuando exista (buildinfo, cargo-auditable)
- Guías: `references/native-and-artifacts.md`

## Managed

- .NET assemblies: tipos, métodos, recursos; NativeAOT → tratar capa nativa
- JVM/ART vía DEX en APK
- IL2CPP: `global-metadata.dat` + binario opcional

## Mobile

- APK: firma (identidad, no trust), manifest, DEX, native `.so`
- IPA/Mach-O + recursos Apple (plist, assets)
- `references/android-applications.md`

## JavaScript / Electron

- ASAR / árboles extraídos; module graph; feature trace
- Fuses Electron (`EnableNodeCliInspectArguments`, etc.)
- `references/javascript-applications.md`

## Web / capturas

- HAR/SAZ/mitmproxy/qlog — lectura de capturas, no “inventar” live
- Orígenes API ≠ origin de la página; declarar `allowed_origins`
- `references/runtime-observation.md`

## Firmware / embedded / signal / packets

- Extracción a directorio nuevo elegido por el caller
- Decoders/sigrok/tshark solo con tools aportados y alcance
- No asumir hardware scan

## WASM / modelos / EVM / pyc / BEAM

- Inventario e interfaces inferidas; no ejecución implícita
- Model artifacts: metadata ≠ comportamiento del modelo

## Malware / IR (autorizado)

- Contención primero; no “detonar” en host de producción
- IOC con contexto; no filtrar muestras sensibles
- Separar familia probable (inferencia) de comportamientos observados
