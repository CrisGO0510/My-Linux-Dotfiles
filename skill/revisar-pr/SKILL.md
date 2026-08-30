---
name: revisar-pr
description: Use when the user asks to review a pull request or their current branch for project conventions in core_web_bac or core_web_csj (Linktic) — e.g. "revisa el PR 216105", "revisa mi rama", "/revisar-pr". Reviews conventions only, not functionality.
---

# Revisar PR (convenciones Linktic)

Revisión de convenciones sobre el diff de un PR de Azure DevOps o de la rama local en `core_web_bac` / `core_web_csj`.
La funcionalidad se da por probada: solo se reporta si es evidente y grave (`FUNCIONAL-GRAVE`).

Directorio del skill: `~/.claude/skills/revisar-pr` (`SCRIPTS=~/.claude/skills/revisar-pr/scripts`).
Directorio de trabajo: el scratchpad de la sesión (`OUT=<scratchpad>/revisar-pr`).

## Flujo (en orden)

1. **Argumento**: número → modo PR; vacío → rama local contra `develop`; `--base <rama>` cambia la base local.
   Ejecutar desde el repo a revisar (`cd` al clone correcto si el usuario nombra el otro proyecto).

2. **Diff**: `$SCRIPTS/pr-diff.sh [<id>] [--base <rama>] --out $OUT`.
   Deja `meta.json` (proyecto, modo, ramas, `ref`, `baseRef`, descripción del PR), `files.txt`, `diff.patch`.
   Mostrar al usuario la línea de resumen que imprime. Si falla, mostrar el error y parar.

3. **Pre-scan**: `$SCRIPTS/pre-scan.py --out $OUT` → `ruta:línea [ID] fragmento`. Son candidatos, no hallazgos.
   Solo analiza **líneas añadidas** del diff (más nombres de archivos nuevos, tests tocados y `catch` de archivos
   tocados); lo que ya existía en el archivo no aparece aquí.

4. **Reglas**: leer `references/reglas.md` completo.

5. **Lectura dirigida**: para cada archivo de `files.txt` bajo `src/` (estado A o M), leer el archivo completo con
   `$SCRIPTS/show-file.sh --out $OUT <ruta>` (en modo PR lee de la rama origen, nunca del working tree)
   y aplicar las reglas de criterio. Excepción: archivos de cableado (`appProvider.ts`, `injectionKeys.ts`,
   `router/index.ts`, `endpoints.ts`) con hunks de pocas líneas se revisan por su hunk en `diff.patch`.
   Para consultas al árbol del proyecto:
   - modo local: `grep -rn <patrón> src`
   - modo PR: `REF=$(jq -r .ref $OUT/meta.json)`; `git grep -n <patrón> "$REF" -- src`; para leer un archivo
     no tocado por el PR usar `$SCRIPTS/show-file.sh` o `git show "${REF}:<ruta>"` — **siempre con llaves**:
     en zsh `$REF:src/...` se interpreta como modificador de historial incluso entre comillas. Igual con `baseRef`.

   Si hay más de 40 archivos en `src/`, priorizar: composables, use cases, repositorios, `.vue`, y decir cuáles quedaron sin leer.

6. **Confirmar** cada candidato del pre-scan con su contexto; descartar falsos positivos en silencio.

   **Alcance**: un hallazgo cuenta como del PR solo si está en líneas añadidas o modificadas por el diff
   (o es consecuencia directa de ellas: cableado faltante, test faltante para código nuevo). Lo que ya estaba
   en `baseRef` dentro de un archivo tocado (un `<style>` viejo, comentarios previos, un bug evidente en una función
   no tocada) va a la sección **📎 Deuda previa**, en una línea por hallazgo, sin contar en la cabecera. Comparar con
   `git show "$(jq -r .baseRef $OUT/meta.json):<ruta>"` cuando haya duda de si una línea es nueva.

7. **Reporte** como texto en el chat (formato abajo). No escribir ningún archivo de reporte.

## Prohibido

- Modificar archivos del proyecto, hacer `git checkout`, `commit`, `push`, o comentar en Azure DevOps.
- Reportar `MAGIC-VALUES` para un literal que aparece una sola vez.
- Especular sobre bugs: `FUNCIONAL-GRAVE` es solo para lo evidente.
- Correr `lint`, `type-check` o tests: ya lo hace el pipeline.

## Formato del reporte

```
# Revisión PR #<id> — <título> (<proyecto>)          ← en local: "# Revisión rama <rama> (<proyecto>)"
<origen> → <destino> · <N> archivos · +<a>/−<b>

🔴 <n> bloqueantes · 🟡 <n> mejoras · ℹ️ <n> informativo · ⚠️ <n> funcional grave

## 🔴 Bloqueantes
### <ID> — <nombre corto> (<fuente>)
- <ruta>:<línea>
  `<fragmento>` → <sugerencia de una línea>

## 🟡 Mejoras
(igual)

## ℹ️ Informativo
- PR-TEMPLATE: <qué falta>

## 📎 Deuda previa (fuera del diff, no cuenta)
- <ruta>:<línea> <ID> — <una línea>

## ✅ Sin hallazgos
<IDs revisados sin hallazgos, separados por " · ">
```

- Los contadores de la cabecera cuentan hallazgos (líneas `- ruta:línea`), no reglas.
- Un mismo fragmento no se reporta bajo dos reglas: va bajo la más específica (p. ej. lógica en template que
  además compara un literal → `SFC-CLEAN`, y la constante se menciona en la sugerencia).
- En "📎 Deuda previa" se admite el id `OBS` para observaciones fuera del catálogo (código muerto, cobertura
  faltante de un composable existente que el PR modifica). Nunca en las secciones que cuentan.
- Agrupar por regla, dentro de cada regla por archivo. Omitir secciones vacías.
- `ruta:línea` siempre relativa al repo (clickable). Fragmento corto, sin repetir el archivo entero.
- En "✅ Sin hallazgos" listar solo las reglas que aplicaban al diff y se revisaron sin hallazgos; omitir las que
  no aplican (sin tabla nueva → `TABLE-SORT` no se lista; sin use case nuevo → `DI-WIRING` no se lista).
- Si no hay ningún hallazgo, decirlo en una línea y listar las reglas revisadas.

## Errores comunes

| Situación | Qué hacer |
|---|---|
| `pr-diff.sh` falla por `az` | Mostrar el error; sugerir `az login` / `az devops login`. No intentar otra vía. |
| PR de otro repo | El script lo detecta; decirle al usuario en qué clone ejecutarlo. |
| Rama local sin cambios (`0 archivos`) | Decirlo y parar; probablemente está en `develop`. |
| `mask` en `shared/components` | Es la definición del prop, no un uso: no es hallazgo. |
| Test existente al que solo se tocó una línea y no tiene AAA | Reportar `TEST-AAA` como 🟡 aclarando que es deuda previa. |
