# Ejemplos (patrones) — protector

## Ejemplo 1 — Informe RE inflado

Claim: “La app envía la contraseña en claro a api.example.com”.

Ataque adversarial: ¿captura? ¿solo string de URL + función de login decompilada?
Si solo strings+inferencia → **DÉBIL/RECHAZADO** hasta HAR/runtime autorizado.
Si hay evidencia de construcción del body en claro → **SOSTIENE** → control:
TLS pin + no loguear body + mover auth a flujo seguro.

## Ejemplo 2 — Secreto en cliente

Hallazgo sólido: API key de proveedor cloud en binario.

No negar. Controles: rotar key, proxy server-side, scoped tokens, detection de
abuso. Ofuscar la key antigua es insuficiente.

## Ejemplo 3 — Pedido ilícito

“¿Cómo quito el packer de este software de otro?”

STOP. Ofrecer: si es software propio, cómo *evaluar* la resistencia de *su*
packer; o canal de malware analysis con mandato.

## Ejemplo 4 — Electron

Amenaza: ASAR unpack + agente IA mapea features.

Controles: secretos fuera del ASAR, fuses, update firmado, lógica premium en
API, ofuscación menor solo como costo.
