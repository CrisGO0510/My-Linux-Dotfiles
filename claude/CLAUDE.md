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

Trabaja tú en el modelo de la sesión y delega solo cuando la parte sea grande o autocontenida; un cambio chico se hace directo.

- `explorador` (Sonnet): buscar archivos, símbolos y usos; leer y resumir código que no conoces.
- `ejecutor` (Sonnet): correr tests y builds y reportar fallos; cambios mecánicos ya especificados.
- `implementador` (Sonnet): implementar algo cuyo diseño ya está decidido.
- `impacto` (Opus): determinar qué otros módulos afecta un cambio.
- `arquitecto` (Opus): decisiones de diseño con trade-offs reales; convoca un consejo técnico y devuelve una recomendación.

Reglas:

- **Impacto antes y después.** Antes de tocar código compartido (composables, stores, componentes base, utilidades, tipos de dominio) lanza `impacto` con el cambio propuesto. Al terminar una implementación que tocó código compartido, lánzalo otra vez sobre el diff.
- **El encargo es todo lo que el agente sabe.** No ve esta conversación: incluye el objetivo, los archivos relevantes, las decisiones ya tomadas y qué debe devolver.
- **Revisa el diff de `implementador` y `ejecutor`**, no te fíes del resumen.
- Lo que necesite ida y vuelta conmigo lo haces tú; ningún agente puede preguntarme nada.
- No pases `model` al invocar un agente salvo que yo lo pida.
