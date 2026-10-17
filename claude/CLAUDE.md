# CLAUDE.md (global)

## Git
- **NUNCA hagas commits.** Solo el usuario hace commits. Puedes hacer staging, mostrar diffs, redactar mensajes de commit propuestos, etc., pero no ejecutes `git commit` (ni `git push`) a menos que el usuario lo pida explícitamente para esa acción concreta.
- Al generar un CLAUDE.md con `/init`, incluye siempre esta regla de "solo el usuario hace commits".

## Búsqueda
- **Usa siempre `rg` (ripgrep) en vez de `grep`.** Aplica a cualquier búsqueda en la shell, incluidos pipes (`... | rg patrón`) y scripts nuevos que escribas. Para listar archivos por nombre, `rg --files -g '<glob>'`.
- **Usa `fd` en vez de `find`** para buscar archivos por nombre, extensión o tipo. `fd` omite por defecto los archivos ocultos y lo ignorado por git: agrega `-H` para incluir ocultos (p.ej. `.config/`) y `-I` para incluir lo ignorado. Recurre a `find` solo cuando necesites un filtro que `fd` no tiene (`-newer <archivo>`, `-perm`, `-links`, `-inum`, `-xdev`).

## Comentarios
- **No agregues comentarios innecesarios.** No escribas comentarios que repiten lo que el código ya dice; el código debe ser autoexplicativo.
- **Un comentario solo se justifica si explica algo que no se deduce de la línea:** una razón, un gotcha del entorno o una decisión con alternativa descartada. Copia la densidad de las líneas vecinas: si las de alrededor no llevan comentario, la nueva tampoco.
- **Tampoco dejes comentarios `TODO`/`FIXME`** en el código. Lo pendiente se rastrea fuera del código (tickets, PR, etc.), no como comentario.
- No agregues comentarios solo para narrar los cambios que hiciste.

## Delegación

La delegación es obligatoria, no una sugerencia. Tú coordinas desde el modelo de la sesión; el trabajo lo hacen los agentes. "La parte es chica" no es excusa cuando se cumple un disparador.

- `explorador` (Sonnet): buscar archivos, símbolos y usos; leer y resumir código que no conoces.
- `ejecutor` (Sonnet): correr tests y builds y reportar fallos; cambios mecánicos ya especificados.
- `implementador` (Sonnet): implementar algo cuyo diseño ya está decidido.
- `impacto` (Opus): determinar qué otros módulos afecta un cambio.
- `arquitecto` (Opus): decisiones de diseño con trade-offs reales; convoca un consejo técnico y devuelve una recomendación.

Disparadores (se comprueban antes de cada acción; si uno aplica, se lanza el agente ANTES de hacer nada tú):

1. **`impacto`, sin excepción por tamaño.** Antes de editar código compartido: `core/**`, `shared/**`, `infrastructure/api/**`, un tipo de dominio que use más de un feature, o un composable, store o componente compartido. Incluye agregar una constante de una línea. Y otra vez sobre el diff al terminar, antes de dejar en stage.
2. **`explorador`** en cuanto una pregunta necesite más de una búsqueda (`rg`/`fd`) o leer más de un archivo que no conoces: recorrer un feature, contar usos, comparar patrones entre módulos, verificar un documento contra el repo. Tú solo haces una búsqueda puntual de un dato que ya sabes dónde está.
3. **`ejecutor`** para toda verificación: `lint`, `type-check`, `test -- --run`, `prettier`, `git apply --check`; y para cambios mecánicos ya especificados (reemplazos repetidos, renombres).
4. **`implementador`** cuando el diseño está decidido y el cambio pasa de un archivo o de un bloque grande: reescribir un documento completo, un feature, varias secciones acordadas.
5. **`arquitecto`** cuando hay más de una forma razonable y equivocarse sale caro (p.ej. enum vs `as const`, dónde van las constantes, cómo manejar errores o notificaciones). No lo decidas solo ni presentes opciones sin haberlo consultado.

Lo que sí haces tú: un `Edit` puntual sobre un archivo ya leído, una búsqueda de un dato concreto, responderme, y lo que necesite ida y vuelta conmigo. Los agentes independientes se lanzan en paralelo; mientras uno corre, no dupliques su trabajo ni predigas su resultado.

Reglas:

- **Impacto antes y después.** Antes de tocar código compartido (composables, stores, componentes base, utilidades, constantes, tipos de dominio) lanza `impacto` con el cambio propuesto. Al terminar una implementación que tocó código compartido, lánzalo otra vez sobre el diff.
- **El encargo es todo lo que el agente sabe.** No ve esta conversación: incluye el objetivo, los archivos relevantes, las decisiones ya tomadas y qué debe devolver.
- **Revisa el diff de `implementador` y `ejecutor`**, no te fíes del resumen.
- Lo que necesite ida y vuelta conmigo lo haces tú; ningún agente puede preguntarme nada.
- No pases `model` al invocar un agente salvo que yo lo pida.
