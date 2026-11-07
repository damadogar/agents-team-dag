# Hardening y controles por superficie

## Nativo (PE/ELF/Mach-O)

- Strip symbols; builds release; control de PDB/dSYM distribution
- Flags de hardening del linker (ASLR, NX, CFG donde aplique) — necesarios pero
  insuficientes ante RE
- Minimizar exports; cuidar TLS callbacks y load config como superficie
- Integridad de secciones críticas + respuesta ante patch
- Evitar strings de alto valor en claro (URLs admin, flags de licencia)

## .NET / managed

- Confiar poco en ofuscadores solos; asumir decompilación
- No dejar lógica de licencia solo en IL
- Considerar NativeAOT / server-side para IP sensible
- Proteger configs y embedded resources

## Electron / JS

- ASAR no es seguridad
- Mover secretos fuera del renderer; contextIsolation, sandbox
- Ofuscación JS = fricción menor; asume unpack
- Validar fuses; desactivar inspect en producción
- Integrity de updates (firma)

## Mobile

- Attestation + server authority
- Root/jailbreak signals con degradación controlada
- No almacenar claves de largo plazo en el device
- Cuidado con logging en release builds

## Modelos / IP en dispositivo

- Asume extracción de pesos si están on-device
- Watermarking, rate limits server-side, términos legales — no solo crypto

## CI/CD (proceso)

- Secrets scanning; no embeber prod keys en artefactos públicos
- Separar builds internos con símbolos de builds customer
- SBOM interno; least privilege en signing keys
