# Criptografía — Destroyer

Selección de algoritmos, ciclo de vida de llaves, certificados, **migración
post-cuántica (PQC)** y *crypto-agility*. Principio: **nunca inventes cripto**
(*don't roll your own*); usa primitivas estándar bien implementadas y vigentes.

---

## 1. Reglas de oro
- **No diseñes algoritmos ni protocolos propios.** Usa estándares revisados.
- **Algoritmos vigentes, parámetros correctos** (tamaños de clave, modos, IV/nonce
  únicos). La mayoría de fallos cripto son de **uso**, no del algoritmo.
- **Cripto-agilidad:** diseña para **poder cambiar** de algoritmo sin rediseñar el
  sistema (abstrae la primitiva, versiona los datos cifrados).
- **La seguridad está en la llave, no en el secreto del algoritmo** (anti-obscurity).

## 2. Selección por caso de uso (referencia, verifica vigencia)
| Necesidad | Opción vigente | Evitar |
|---|---|---|
| Cifrado simétrico | AES-256 (GCM/otros AEAD), ChaCha20-Poly1305 | DES/3DES, RC4, modos sin autenticación (ECB) |
| Hash | SHA-256/384/512, SHA-3 | MD5, SHA-1 |
| Hash de contraseñas | Argon2id, scrypt, bcrypt (con coste adecuado) | hash simple, sin sal |
| Firma/asimétrico clásico | RSA-3072+, ECDSA/EdDSA (curvas seguras) | RSA-1024, curvas débiles |
| Intercambio de claves | ECDH (curvas seguras), DH de tamaño adecuado | parámetros débiles |
| Transporte | TLS 1.3 (o 1.2 bien configurado) | SSL, TLS ≤1.1, cifras obsoletas |
| AEAD (cifrado autenticado) | siempre preferir AEAD | cifrar sin integridad |

## 3. Gestión del ciclo de vida de llaves (lo más crítico)
- **Generación:** fuente aleatoria robusta (CSPRNG/HSM); nunca claves predecibles.
- **Almacenamiento:** HSM/KMS; **nunca** en código, repos, logs ni en claro.
- **Distribución:** canales seguros; *envelope encryption* (DEK cifrada por KEK).
- **Rotación:** periódica y ante sospecha de compromiso; soporta re-cifrado.
- **Revocación y destrucción:** procedimiento claro; *crypto-shredding* (destruir
  la llave para inutilizar el dato cifrado).
- **Separación de funciones:** quien custodia la llave ≠ quien usa el dato; doble
  control para llaves raíz.
- **Jerarquía:** root/KEK/DEK con mínimo privilegio por nivel.

## 4. Cifrado en tránsito y en reposo
- **Tránsito:** TLS 1.3 preferido; configuración fuerte (sin cifras/protocolos
  obsoletos); mTLS interno donde aplique; HSTS en web.
- **Reposo:** a nivel de volumen/DB (TDE) y, para datos muy sensibles, **a nivel de
  campo/aplicación** con llaves gestionadas por KMS/HSM.
- **En uso (avanzado):** enclaves/*confidential computing*, MPC, homomórfico —
  según caso y madurez.

## 5. Certificados y PKI
- **Gestión del ciclo de vida:** emisión, renovación **automatizada** (evita
  caducidades sorpresa), revocación (CRL/OCSP).
- **Inventario de certificados** y de su caducidad; alertas tempranas.
- **CA confiables**, protección de la CA privada (si la hay) en HSM.
- **Pinning** donde el riesgo lo justifique (móvil, M2M).

## 6. Criptografía post-cuántica (PQC) — relevante ya
- **Amenaza:** un computador cuántico capaz romperá RSA/ECC clásicos; además
  **"harvest now, decrypt later"** — datos cifrados hoy con valor a largo plazo ya
  están en riesgo si se interceptan y almacenan.
- **Estándares NIST:** **FIPS 203 (ML-KEM / Kyber)** para encapsulado de claves,
  **FIPS 204 (ML-DSA / Dilithium)** y **FIPS 205 (SLH-DSA / SPHINCS+)** para firma.
- **Estrategia recomendada:**
  - **Inventario criptográfico** (CBOM): dónde y qué algoritmos/llaves se usan.
  - **Priorizar** datos de larga vida y sistemas difíciles de actualizar.
  - **Modo híbrido** (clásico + PQC) durante la transición.
  - **Crypto-agility** como prerrequisito: poder cambiar primitivas sin rediseñar.
- Empezar la **planificación ahora** es [RECOMENDACIÓN FUERTE] para datos sensibles
  con horizonte largo; la urgencia se calibra al valor/longevidad del dato.

## 7. Errores frecuentes (hallazgos típicos)
- Reutilización de IV/nonce; cifrar sin autenticar (no AEAD).
- Llaves hardcodeadas o en variables de entorno commiteadas.
- Hash de contraseñas débil o sin sal; "cifrar" cuando se necesitaba *hash*.
- Algoritmos/protocolos obsoletos por compatibilidad sin plan de salida.
- No rotar; no inventariar certificados (caducidades que tumban servicios).
- Cripto propia "casera".

## 8. Checklist criptografía
```
- [ ] Algoritmos vigentes y AEAD; sin primitivas obsoletas
- [ ] Uso correcto (IV/nonce únicos, parámetros, sal en contraseñas)
- [ ] Llaves en HSM/KMS; nunca en código/logs; rotación y revocación
- [ ] Envelope encryption + jerarquía de llaves con mínimo privilegio
- [ ] TLS 1.3/1.2 fuerte en tránsito; cifrado en reposo según sensibilidad
- [ ] PKI con renovación automatizada e inventario de certificados
- [ ] Crypto-agility: se puede cambiar de algoritmo sin rediseñar
- [ ] Inventario criptográfico (CBOM) y plan de migración PQC para datos de larga vida
- [ ] Sin cripto propia; sin security by obscurity
```
