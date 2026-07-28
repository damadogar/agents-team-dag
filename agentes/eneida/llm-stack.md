# Selección y uso de LLMs (actualización continua)

El panorama de modelos cambia a diario. La habilidad clave de Eneida
**no es memorizar el "mejor modelo"**, sino aplicar un **método de selección**
y **verificar el estado actual** antes de recomendar.

---

## 1. Método de selección (lo permanente)

1. **Define la tarea y sus restricciones**: dificultad, horizonte (one-shot vs
   agente largo), contexto requerido, latencia, costo, privacidad/self-host.
2. **Enruta por tarea (model routing)**:
   - **Alto riesgo / largo horizonte** (diseño, refactor de repos, debugging
     profundo) → el modelo frontera más capaz disponible.
   - **Rutina / volumen / autocompletado** → modelo rápido y económico.
   - **Privacidad / air-gapped** → mejor modelo open-source self-hostable.
3. **Verifica leaderboards y benchmarks ACTUALES** con búsqueda web antes de
   afirmar nada (SWE-bench Verified/Pro, Terminal-Bench, Arena/Elo, etc.).
4. **Valida en tu propio código**: corre la lista corta sobre 30–100 tareas
   representativas del proyecto. El harness/agente cambia los resultados.
5. **Mide costo total**: $/MTok in/out × volumen esperado, no solo el precio
   nominal.

---

## 2. Benchmarks útiles (qué mide cada uno)

- **SWE-bench Verified / Pro** — resolver issues reales en repos (capacidad de
  ingeniería real).
- **Terminal-Bench** — interacción agéntica en terminal.
- **LMArena / Elo** — preferencia humana general y de código.
- **GPQA / ARC-AGI** — razonamiento difícil / abstracto.
- **Contexto efectivo** — no solo el tamaño anunciado: prueba recuperación
  real ("needle in haystack").

> Trata todo número como **caduco**: cítalo con su fecha y revalida.

---

## 3. Snapshot de referencia (caduca — re-verificar)

> Foto de mediados de 2026 solo como punto de partida. **No la uses como verdad
> fija**: ejecuta la búsqueda del método §1 para datos vigentes.

- **Tareas de ingeniería más duras / largo horizonte**: modelos frontera tope
  de gama (líderes recientes en SWE-bench Pro). Mejor capacidad, mayor costo.
- **Producción general (mejor relación capacidad/costo)**: modelo frontera de
  gama media de Anthropic/OpenAI.
- **Agente de terminal / orquestación de herramientas**: modelos fuertes con
  harness tipo CLI de OpenAI.
- **Velocidad / volumen / bajo costo**: modelos "Flash" de Google.
- **Open-source / sensible a costo o privacidad**: familias DeepSeek, Qwen,
  Kimi, GLM, MiniMax, Llama (auto-hospedables).

Nombres y puntajes concretos cambian semana a semana; **no los fijes en
piedra**.

---

## 4. Buenas prácticas de uso de LLMs en el proyecto

- **Contexto curado**: dale al modelo los archivos y requisitos correctos;
  evita ruido. Usa RAG/index para repos grandes.
- **Prompts como contratos**: objetivo, restricciones, formato de salida,
  criterios de aceptación.
- **Verificación humana + automática**: tests, linters y análisis estático
  sobre la salida del modelo (la IA amplifica errores existentes — DORA 2025).
- **Plataforma interna sólida**: el ROI de la IA depende de plataformas y
  workflows robustos, no del modelo aislado.
- **Seguridad**: nunca envíes secretos/PII a modelos sin control; respeta
  políticas de datos y residencia.
- **Trazabilidad**: registra qué modelo/versión generó qué, para reproducir.

---

## 5. Rutina de actualización (diaria/rutinaria/de ejecución)

- **Diaria/ligera**: ante una recomendación de modelo, hacer una búsqueda
  rápida del leaderboard vigente.
- **Rutinaria (p. ej. mensual)**: re-evaluar la lista corta contra el código
  del proyecto y actualizar la guía de routing.
- **De ejecución**: al iniciar una tarea, elegir el modelo por su tipo (§1) y
  declarar la elección y el porqué.

---

## 6. Referencias

- SWE-bench: https://www.swebench.com/
- LMArena: https://lmarena.ai/
- Artificial Analysis (intel/velocidad/precio): https://artificialanalysis.ai/
- Anthropic / OpenAI / Google DeepMind — model cards oficiales.
