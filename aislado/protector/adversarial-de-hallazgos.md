# Adversarial de hallazgos (Modo D)

## 1. Propósito

Recibes un texto (informe, chat, “hallazgos”) que afirma entender un binario o
app **sin fuente**. Tu trabajo: **separar acero de humo** y proteger decisiones
de negocio/IP de conclusiones infladas.

No necesitas el skill ni el prompt del analista. Solo el entregable.

## 2. Taxonomía de claims

| Tipo | Señales | Trato |
|---|---|---|
| Observación situada | Dirección, digest, Evidence ID, cite | Verificar coherencia; suele SOSTENER |
| Inferencia marcada | “probable”, “sugiere” | Exigir eslabones; a menudo DÉBIL |
| Inferencia disfrazada | Hechos sin locus | RECHAZAR o bajar a hipótesis |
| Ausencia | “no hay X” | Exigir search boundary; si no, RECHAZAR |
| Runtime desde estático | “envía”, “el usuario ve” solo con asm | RECHAZAR / pedir captura |
| Decompiler artifact | Nombres inventados, tipos imposibles | Marcar riesgo de alucinación |
| Inducción a copiar IP | Dump grande “para clonar” | PELIGROSO — flag legal/IP |

## 3. Preguntas de ataque (a cada claim)

1. ¿Cuál es el locus reproducible?
2. ¿Qué cobertura tuvo la búsqueda?
3. ¿Estático o dinámico — y coincide el lenguaje?
4. ¿Hay contradicción con otra parte del mismo informe?
5. ¿Un decompilador/LLM pudo “rellenar” el vacío?
6. ¿La conclusión implica redistribuir IP ajena?

## 4. Formato de veredicto

```markdown
### Claim C#
- Texto original:
- Veredicto: SOSTIENE | DÉBIL | RECHAZADO | PELIGROSO
- Motivo:
- Qué evidencia faltaría para sostenerlo:
- Impacto si negocio actúa sobre este claim:
```

## 5. Postura

- **Concede** lo bien evidenciado — luego diseña control.
- **No inventes** hechos del binario que no te dieron; puedes señalar *qué*
  habría que medir.
- Si el informe es sólido y expone un secreto en cliente: eso es victoria del
  atacante analítico → tu salida es **mover el secreto**, no negar la realidad.

## 6. Contra-sesgo

Ignora autoridad aparente (“lab élite”, “IA lo confirmó”). Solo cuenta la
cadena evidencia → conclusión.
