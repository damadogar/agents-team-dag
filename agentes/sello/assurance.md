# Capa de aseguramiento (assurance) — Sello

Un skill es **guía** para el modelo; por sí solo no tiene enforcement. Esta capa
añade **garantías verificables** alrededor del skill, en dos niveles:

| Nivel | Qué hace | Dónde vive | Bloquea? |
|---|---|---|---|
| **1. Hooks (runtime)** | Vigila acciones y salidas en cada sesión de Cursor | `~/.cursor/` (no se sincroniza: es config de máquina) | Sí (ask) / audita |
| **2. Evals (regresión)** | Verifica el comportamiento del agente entre versiones | `~/.destroyer/evals/` (se sincroniza) | No (gate manual) |

---

## Nivel 1 — Hooks de Cursor

Configurados en `~/.cursor/hooks.json`, con scripts en `~/.cursor/hooks/`. Escritos
en **Node.js** (sin dependencias; `node` debe estar en el `PATH`).

### a) `destroyer-guard.js` — evento `beforeShellExecution`
Aplica la **línea roja (§0) en la capa de acción**. Si un comando coincide con:
- **herramienta ofensiva** (nmap, sqlmap, nuclei, hydra, metasploit, crackmapexec…), o
- **posible exfiltración** (lee `.env`/llaves/credenciales **y** envía a un destino remoto),

devuelve `permission: ask` con un mensaje que exige confirmar **autorización + RoE**.
Es **ask-only** (nunca deniega en duro) y **fail-open** (si algo falla, permite):
no rompe flujos normales, solo añade un gate de confirmación en patrones de alto riesgo.

### b) `destroyer-audit.js` — evento `afterAgentResponse`
**Observa y audita** (no bloquea). Cuando la respuesta parece trabajo de seguridad,
verifica invariantes y registra avisos en `~/.cursor/destroyer/audit.log`:
- **secretos en la salida** (AWS key, clave privada, JWT, tokens, `clave=valor`),
- **afirma ejecución ofensiva** sin mencionar autorización/RoE (§0),
- **hallazgos sin "riesgo residual"** (principio 14),
- **hallazgos sin remediación/retest** (principio 13),
- **CVE citada sin verificación/fecha** (regla de vigencia).

Revisa el log periódicamente: es el "caja negra" de qué tan bien se respeta la doctrina.

### Probar / activar
- Cursor recarga `hooks.json` al guardar; si no, reinicia Cursor.
- Verlos activos: pestaña **Hooks** (o canal de salida **Hooks**).
- Prueba manual (PowerShell): el pipe de la consola puede mancillar acentos; en uso
  real Cursor pasa UTF-8 limpio por stdin. Para una prueba fiel, fuerza UTF-8:
  `[Console]::OutputEncoding=[System.Text.Encoding]::UTF8`.

### Desactivar
- Quita la entrada en `~/.cursor/hooks.json` (o el archivo), o pon `failClosed:false`
  (ya está) para que nunca interrumpa. Borra `~/.cursor/destroyer/audit.log` cuando quieras.

> Nota: los hooks son **globales** (corren en todas las sesiones de Cursor, no solo
> con el skill activo). Son baratos y silenciosos salvo en patrones de riesgo; el
> auditor solo escribe cuando detecta contenido de seguridad con un problema.

---

## Nivel 2 — Evals de regresión

10 casos adversariales (E01–E10) en [evals/casos.md](evals/casos.md), con rúbrica
y tabla de resultados en [evals/README.md](evals/README.md). Cubren: anti-inyección,
ofensiva no autorizada, piso mínimo, vigencia, neutralidad, presión de autoridad,
hallazgo→fix→retest, no reproducir secretos, encontrar-y-corregir e irreversibles.

**Úsalos** antes de promover cambios en la doctrina (§0/§0 bis/§6 bis/principios/modos)
o al cambiar de modelo. Cuatro casos son **críticos** (E01, E02, E08, E10): un fallo
ahí bloquea la promoción.

---

## Límite honesto
Esta capa eleva la robustez de "muy buena guía" a "guía + red de seguridad
verificable", pero **no** convierte al skill en software con garantías formales:
los hooks cubren acciones de shell y salidas de texto (no todo el espacio de
comportamiento), y los evals son una muestra, no una prueba exhaustiva. Aun así,
cierran los modos de fallo de mayor impacto (manipulación, exfiltración, falta de
autorización, hallazgos sin cierre) y permiten **detectar regresiones**.
