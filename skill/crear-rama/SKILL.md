---
name: crear-rama
description: Use when the user asks to create a branch for a new HU/feature in a Linktic repo (core_web_bac, core_web_csj) — e.g. "crea la rama para la HU 487691", "nueva rama del sprint 7.3", "/crear-rama". Creates the branch with the long local name and maps its upstream to the short remote name.
---

# Crear rama de HU (Linktic)

La rama **local** y la rama **remota** no se llaman igual, a propósito:

| | Formato | Ejemplo |
|---|---|---|
| Local | `<tipo>/<sprint>/<idFeature>/<idHU>-<códigoHU>` | `feat/7.2/474143/487691-HU0001` |
| Remota (upstream) | `<tipo>/<idHU>-<códigoHU>` | `feat/487691-HU0001` |

El nombre local conserva sprint e idFeature (convención del equipo, útil para ubicarse entre ramas);
el remoto se queda corto porque es lo que se ve en el PR de Azure DevOps.

`<tipo>` es el de Conventional Commits (`feat`, `fix`, …). Los ids salen de Azure DevOps,
proyecto `419 - DEPOSITOS JUDICIALES`. El `<códigoHU>` es el de la HU (`HU0001`), no lleva guion.

## Flujo

1. **Reunir los datos**: tipo, sprint, idFeature, idHU, códigoHU. Si falta alguno, preguntarlo —
   no inventarlos ni deducirlos del nombre de otra rama.

2. **Partir de `develop` al día**:
   ```bash
   git fetch origin
   git switch -c <rama-local> origin/develop
   ```
   Si el usuario ya está sobre una rama con trabajo hecho, no recrearla: saltar al paso 3.

3. **Mapear el upstream** (todo local al repo, no `--global`):
   ```bash
   B=$(git branch --show-current)
   git config "branch.$B.remote" origin
   git config "branch.$B.merge" refs/heads/<rama-remota>
   git config push.default upstream
   ```

4. **Verificar sin empujar nada**:
   ```bash
   git push --dry-run --no-verify
   ```
   Debe imprimir `<rama-local> -> <rama-remota>`. El `--no-verify` es **solo** para el dry-run:
   el hook `pre-push` corre `type-check` + `build-only` y tarda varios minutos.

5. **No hacer push.** Solo el usuario empuja; decirle que ya puede hacer `git push` a secas.

## Detalles que importan

- `push.default=upstream` es lo que permite empujar a una rama de nombre distinto. Con el `simple`
  por defecto, `git push` aborta cuando los nombres no coinciden.
- Es config **por repositorio** y afecta a todas sus ramas: una rama sin upstream configurado
  fallará al hacer push en vez de crear una remota con su nombre largo. Es una red de seguridad, no un bug.
- **No usar `remote.origin.push`** como refspec fijo: obliga a que cualquier `git push` del repo
  empuje esa rama, incluso estando parado en otra. Rompe más de lo que arregla.
- Cambiar el destino remoto de una rama ya mapeada: repetir solo `git config "branch.$B.merge"`.

## Comandos

```bash
git config --get-regexp "^branch\..*\.(remote|merge)$"   # ver los mapeos del repo
git rev-parse --abbrev-ref '@{upstream}'                 # upstream de la rama actual
git push --dry-run --no-verify                           # a dónde iría el push
```

## Prohibido

- `git commit`, `git push` o `git push --force` sin que el usuario lo pida para esa acción concreta.
- `--global` en cualquiera de estos `git config`.
- `--no-verify` en un push real.
