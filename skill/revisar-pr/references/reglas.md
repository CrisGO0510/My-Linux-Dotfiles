# Catálogo de reglas — core_web_bac / core_web_csj

Cada regla tiene: id, severidad, fuente, qué revisar, cómo confirmarlo y qué sugerir. Las reglas
mecánicas ya vienen detectadas por `pre-scan.py`; aquí solo se indica cómo confirmar cada hallazgo.
Las reglas de criterio se aplican leyendo completo cada archivo tocado bajo `src/`.

Severidades: 🔴 bloqueante (rompe una regla dura) · 🟡 mejora (convención blanda) · ℹ️ informativo · ⚠️ funcional grave.

## Reglas mecánicas (confirmar contexto antes de reportar)

| ID | Sev | Fuente | Confirmar | Sugerencia |
|---|---|---|---|---|
| `NO-MASK` | 🔴 | CLAUDE.md global | `mask` restringe lo que se escribe (prop de `q-input`/`GenericInput`, `mask:` en config de filtros). No cuenta si es texto o el nombre de otra cosa. | Reemplazar por reglas de `useFormRules` (`only_number`, `min_length`, `max_length`, `pattern`). |
| `NO-STYLE` | 🔴 | CLAUDE.md bac | Cualquier `<style>` en `.vue`. | Solo clases utilitarias de Quasar. |
| `NO-ANY` | 🔴 | CODING_STANDARDS, eslint | `any` explícito. ESLint lo bloquea; si está, el PR no pasa `lint-scan`. | Tipo específico o `unknown` con narrowing. |
| `NO-TS-COMMENT` | 🔴 | eslint.config | `@ts-ignore` / `@ts-expect-error` / `@ts-nocheck`. | Corregir el tipo. |
| `LAYER-DEPS` | 🔴 | documentation.md §2 | Import que viola la regla de dependencia (domain → nada; application → domain; infrastructure → domain/application; presentation → application/domain). En csj hay mappers que importan `useDateFormat` de presentation: es deuda conocida, se reporta igual. | Mover la lógica a la capa correcta. |
| `ENDPOINTS-CENTRAL` | 🔴 | INFRASTRUCTURE_LAYER, CLAUDE.md | URL o `/api/...` fuera de `infrastructure/api/endpoints.ts`. | Agregar la constante en `ENDPOINTS` y usarla. |
| `DI-INJECT` | 🔴 | CLAUDE.md, documentation.md §8 | `new XRepositoryImpl(...)` o `new XUseCase(...)` en presentation. | `inject(XUseCaseKey)` en el composable; la instancia se crea en el provider del feature. |
| `HTTP-CLIENT` | 🔴 | CLAUDE.md csj | `import axios` fuera de `infrastructure/api/`. | Recibir el `HttpClient` por constructor. |
| `SFC-TYPES` | 🔴 | CLAUDE.md bac | `interface`/`type` declarado dentro del `<script>` de un `.vue`. | Mover a `types/<kebab-case>.ts` del feature. |
| `ERROR-HANDLING` (mecánica) | 🔴 | patrón del repo | `catch {}` vacío o con solo un comentario; `try/finally` sin `catch`. | Ver la regla de criterio más abajo. |
| `NO-CONSOLE` | 🟡 | eslint.config | `console.*` fuera de tests. | Quitar o usar `useNotification`. |
| `NO-TODO` | 🟡 | CLAUDE.md global | `TODO`/`FIXME` en comentarios. | Lo pendiente va en el ticket, no en el código. |
| `ALIAS-IMPORTS` | 🟡 | CODING_STANDARDS | `from '../../...'`. | Usar `@/…` o los alias por capa. |
| `PROPS-TYPED` | 🟡 | PRESENTATION_LAYER | `defineProps([...])` / `defineEmits([...])` sin genérico. | `defineProps<{...}>()` con tipo del archivo de `types/`. |
| `NAMING` | 🟡 | CODING_STANDARDS, documentation.md §10 | Archivo nuevo que no sigue el patrón de su carpeta (`I*Repository.ts`, `*UseCase.ts`, `*RepositoryImpl.ts`, `*Mapper.ts`, `use*.ts`, `*Store.ts`, `kebab-case.ts`, `PascalCase.vue`). | Renombrar. |
| `DOMAIN-NO-DTO` | 🟡 | documentation.md §10 | Sufijo `DTO` en `domain/`. Los `dto/` de application son re-exports. | Nombrar `XRequest` / `XResponse`. |
| `TEST-AAA` | 🟡 | CLAUDE.md | La unidad es el bloque `it`: cuenta si un `it` nuevo o tocado por el diff no tiene `// Arrange` / `// Act` / `// Assert`. Los `it` no tocados sin AAA van a deuda previa. | Añadir los tres marcadores en cada `it`. |
| `FEATURE-SLICE` | 🟡 | CLAUDE.md, documentation.md §11 | Feature **nuevo** al que le falta alguna de las 5 carpetas (`domain/feature/<f>`, `application/features/<f>`, `infrastructure/features/<f>`, `core/providers/features/<f>`, `presentation/features/<f>`). Legítimo si es solo-presentación y reutiliza use cases de otro feature: en ese caso no reportar. | Completar el slice. |

## Reglas de criterio

### `MAGIC-VALUES` 🔴 — CLAUDE.md global, bac y csj

Literales con significado inline en templates o lógica: tamaños, límites, estados, claves, breakpoints,
nombres de ruta, formatos de fecha, códigos, `rowsPerPage`, timeouts.

- **Solo se reporta si el literal aparece 2 o más veces** (en el diff o en el árbol del proyecto).
  Confirmar con grep del valor exacto (`grep -rn "'ACTIVO'" src` en local; `git grep -n "'ACTIVO'" <ref> -- src` en modo PR).
- **Un literal usado una sola vez no se reporta.**
- Severidad: 🔴 si el PR mismo repite el literal (2+ en el diff) o si ya existe una constante y no se usó;
  🟡 si la repetición es solo contra código previo del repo que tampoco tiene constante (deuda transversal,
  p. ej. `limit: 10` en cientos de archivos). Si aplican ambos criterios, prevalece 🔴: el PR está agregando
  ocurrencias nuevas y es el momento de extraer la constante.
- **Un hallazgo por literal**, siempre: la primera `ruta:línea` como ancla y las demás ocurrencias del diff
  listadas en la misma línea (`también :55, useX.ts:203`). Así el contador de la cabecera no se infla.
  Un conjunto de valores del mismo enum (`'PORTAL_RAMA'`/`'PORTAL_BANCO'`) es **un** hallazgo, porque es un solo fix.
- Líneas que aparecen como `+` solo por movimiento o re-indentación no cuentan como ocurrencias nuevas del PR
  (comparar con `baseRef`); solo las realmente nuevas deciden entre 🔴 y 🟡.
- La exclusión de "textos de UI" no cubre el mismo literal usado como valor de comparación: en
  `x === 'Activo' ? 'Activo' : 'Inactivo'`, el `=== 'Activo'` sí es hallazgo y el label no.
- No cuentan: textos de UI (labels, placeholders, títulos, mensajes), clases de Quasar, `0`, `1`, `-1`, `''`, `true/false`.
- Antes de sugerir "crear constante", buscar la existente en `core/constants/` (`status.ts`, `regexs.ts`),
  `presentation/shared/constants/` (`files.ts`, `options.ts`), `infrastructure/api/endpoints.ts` y los enums del feature.
  Si la constante existe en **otro feature**: sugerir reutilizarla si es un enum de dominio compartido
  (`domain/feature/<otro>/enums`), o moverla a `shared`/`core/constants` si es transversal. Nunca duplicarla.
- Sugerencia: nombre de la constante existente o ruta donde crearla.

### `ERROR-HANDLING` 🔴 — patrón real del repo

Patrón canónico aceptado en composables (el de `closing-schedule`, `notification-templates`, `portal-schedules`): solo se
notifica el `ValidationError`; lo HTTP ya lo notificó el interceptor y el use case lo convierte en `undefined`.

```ts
try {
  loader.show()
  const result = await xUseCase?.execute(data)
  if (!result) return
  ...
} catch (e) {
  if (e instanceof ValidationError) error(e.message)
} finally {
  loader.hide()
}
```

Reportar en composables:
- 🔴 `await xUseCase?.execute(...)` en un composable **sin `try/catch`** alrededor (ni en el llamador directo).
- 🔴 `catch` que no notifica ni relanza: no llama `error(...)`, `notify`, `throw`, ni `handleError`.
- 🔴 Loader/`loading = true` antes del `await` que **no se apaga** si hay error (no está en `finally` ni en el `catch`).
- 🟡 Loader que sí se apaga en todos los caminos pero fuera de `finally`: no sigue el patrón canónico.

Patrón canónico en use cases (161 de 206 en csj, 311 de 361 en bac): validar y llamar al servicio/repositorio dentro
del `try`, relanzar solo `ValidationError` y dejar que lo demás termine en `undefined`. El error HTTP ya lo notificó el
interceptor y el composable corta con `if (!res) return`.

```ts
async execute(payload: XPayload): Promise<XResponse | void> {
  try {
    const validator = validate(payload)
    validator.field('id', 'ID').required().string()
    validator.validate()
    return await this.repository.x(payload)
  } catch (error) {
    if (error instanceof ValidationError) throw error
  }
}
```

Reportar en use cases:
- 🔴 Use case nuevo, o cuyo `execute` toca el diff, **sin `try/catch`**: el error HTTP llega al composable y cambia su
  flujo respecto al resto de la app (p. ej. su `catch` cierra el modal donde antes `if (!res) return` lo dejaba abierto).
  Si el diff **quita** el `try/catch` de un use case existente, comparar con `baseRef` y reportarlo igual.
  Sugerencia: el patrón canónico.
- 🔴 `catch` de use case que relanza otras clases además de `ValidationError` (`|| error instanceof DomainError`,
  `ApplicationError`, etc.): no es el patrón. Sugerencia: relanzar solo `ValidationError`.
- 🟡 `catch` que devuelve un valor de relleno (`null`, `[]`, `{}`) en vez de dejar `undefined`: el composable no puede
  distinguir el fallo de una respuesta vacía.

No reportar: el patrón canónico del use case (retorno `| void` incluido); `catch` que relanza; `catch` de composable que notifica
el `ValidationError` con `error(e.message)`; `catch` que hace fallback documentado y **además** notifica.
No se exige `useErrorHandler` (existe pero las features no lo usan).

### `COMPOSABLE-SCOPE` 🔴 — regla del usuario

**En un composable, fuera de `export const useX = () => { ... }` solo quedan los `import`.** Nada de
declaraciones a nivel de módulo: constantes, mapas, `Record`s de configuración, helpers, arrays de nombres de
filtro. Todo va dentro de la función. No es negociable y no depende del tamaño ni de que el valor sea un
literal puro.

Reportar cualquier `const` / `let` / `var` / `function` declarado entre los imports y el `export const useX`.

- **No renombrar al moverlos.** Las constantes conservan sus MAYÚSCULAS (`FILTER_NAMES`, `COLUMN_SORT_FIELDS`)
  dentro de la función; no pasarlas a camelCase por estar en un scope de función.
- **Cuidado con el orden**: al moverlas dentro hay que declararlas antes de su primer uso. Un `FILTER_NAMES`
  que alimenta un `reactive([...])` del cuerpo del composable va al principio de la función, no al final.
- Lo que se **comparte entre archivos** sigue en `constants/` y se importa: esta regla es sobre lo declarado
  *en* el archivo del composable, y no contradice `MAGIC-VALUES`.
- Aplica a **todos** los composables: de feature, de `shared/composables/` y los colocados junto a un
  componente (`useXComponent.ts`).
- Si el composable ya existía y las constantes fuera del export vienen de `baseRef`, va a 📎 Deuda previa.

### `SFC-CLEAN` 🔴 — CLAUDE.md bac

En `.vue` solo se permite: imports, `defineProps/defineEmits/defineExpose`, `withDefaults`, destructuring del composable.
Reportar funciones, `computed`, `watch`, `ref` con lógica, `onMounted`, llamadas a use cases o stores dentro del SFC.
También cuenta la lógica en el `<template>`: comparaciones con valores de negocio (`estado === FEATURE_STATUS.ACTIVE`),
normalizaciones, ternarios anidados o importar constantes en el SFC solo para usarlas en el template → exponer un
`computed` (`stateLabel`) desde el composable.
Sugerencia: mover al composable `use<Feature><Accion>.ts`.

### `VALIDATION-RULES` 🔴 — CLAUDE.md global

- Input de formulario sin `rules` de `useFormRules` cuando el campo tiene restricciones (requerido, longitud, numérico).
- Regex inventada inline (`/^.../`) para validar: usar `REGEXS` de `core/constants/regexs.ts` **solo si ya existe la entrada**;
  si no existe, mirar cómo lo resuelve otro módulo antes de proponer agregarla.
- Closure de validación inline en el composable o la vista (`(val) => Number(val) > x || 'mensaje'`, comparaciones con
  `dayjs`, rangos): es una regla que falta en `useFormRules`; agregarla ahí y usarla. 🔴.
- Validación manual en el composable que **duplica** reglas ya declaradas en el formulario (`if (!x.trim()) …`,
  `.length < 10` cuando el campo ya tiene `is_required`/`min_length`): apoyarse en `formRef.validate()`. 🔴.
- Validación resuelta con máscara (cae también en `NO-MASK`).
- Una regex inline que **transforma** (`.replace(/^\[|\]$/g, '')`) no es validación: no se reporta aquí; si la misma
  regex existe en `REGEXS`, va como `MAGIC-VALUES`.

### `DI-WIRING` 🔴 — CLAUDE.md, documentation.md §8

Para cada `XUseCase` nuevo, verificar en el árbol (grep):
1. Existe `XUseCaseKey` (`core/providers/injectionKeys.ts` o `core/providers/features/<f>/<f>InjectionKeys.ts`).
2. Existe `app.provide(XUseCaseKey, new XUseCase(...))` en el provider del feature y ese `setup<F>Providers` se llama en `appProvider.ts`.
3. El composable hace `inject(XUseCaseKey)` y contempla `undefined` (`?.execute` o guard).

Para cada ruta nueva: el router del feature está incluido en `presentation/router/index.ts`.

### `TABLE-SORT` 🔴 — global (CLAUDE.md global, bac y csj)

Toda tabla/listado nuevo debe permitir ordenar en sus columnas de datos:
1. En el composable de lista, cada columna de datos lleva `sortable: true` (no las de acciones/checkbox).
2. El composable expone `updateSort(sortBy, sortOrder)` junto a `updatePage`/`updatePerPage`, y mete `sortBy`/`sortOrder`
   en los filtros antes de recargar. En **csj** viene de `useTablePagination(...)`; en **bac** no existe ese composable y
   `updateSort` se define en el propio composable de lista (ver cualquier `use<Feature>List.ts` existente).
3. En la vista, `<TableList>` enlaza `@update-sort="updateSort"` además de `@update-page` y `@update-rows-per-page`.

Falta cualquiera de los tres → hallazgo.

### `NO-MAPPER` 🟡 — global (CLAUDE.md global, bac y csj)

Mapper nuevo creado para renombrar campos, formatear fechas/horas o derivar etiquetas → hallazgo.
Lo correcto: modelar el tipo de dominio igual al contrato del backend y devolver la respuesta tal cual;
formato/derivación para pantalla va en el composable con `useDateFormat`/`useTimeFormat`.
Aceptable: transformación que el backend no puede entregar resuelta, o feature que ya tenía mapper (mantener el patrón).

### `COMMENTS` 🟡 — CLAUDE.md global y bac

Reportar: comentarios que repiten lo que dice el código, cabeceras de sección (`// Components`, `// Props`, `// Logic view`),
código comentado, comentarios en inglés. No reportar JSDoc breve en APIs compartidas.

### `SHARED-REUSE` 🟡 — CLAUDE.md

Componente nuevo que duplica uno de `presentation/shared/components`: `GenericInput`, `GenericSelector`, `GenericDateInput`,
`TableList`, `FiltersComponent`, `AlertModal`, `ModalComponent`, botones, `UploadFileComponent`. Sugerir el compartido.

### `USE-CASE-SHAPE` 🟡 — APPLICATION_LAYER, documentation.md §5

Use case con más de un método público, sin `execute()`, o con lógica de UI (notificaciones de pantalla, navegación).
Dependencias por constructor, tipadas con la interfaz `I*Repository`.

### `REPO-SHAPE` 🟡 — INFRASTRUCTURE_LAYER

Repositorio que no usa `ENDPOINTS`, no recibe el `HttpClient` por constructor, o no declara `implements I*Repository`.
Si el PR se declara maquetación y el repositorio devuelve un mock de `fake-api/`, reportar 🟡 recordando que falta la
integración (endpoint en `ENDPOINTS` + `this.axios`), no como error.

### `ENTITY-IMMUTABLE` 🟡 — DOMAIN_LAYER

Entidad de dominio (`class` en `domain/**/entities`) con propiedades sin `readonly`.

### `STATE-SCOPE` 🟡 — CLAUDE.md csj

Store de Pinia nuevo para estado de una sola pantalla. Pinia es para estado transversal; el de pantalla va en el composable.

### `TESTS-MISSING` 🟡 — CLAUDE.md

Use case o composable nuevo sin test en `__tests__/` o `__test__/` junto al código. Los componentes no requieren test.

### `ESPAÑOL` 🟡 — CLAUDE.md

Textos de UI, mensajes de error o comentarios en inglés. Nombres de código (variables, funciones) van en inglés y no cuentan.

### `TRANSVERSAL` 🔀 — obligatoria, no cuenta en los contadores

Todo cambio del diff que toque un archivo compartido **se reporta**, aunque no incumpla ninguna regla del
catálogo. El revisor lee el PR como "feature X" y estos cambios se le pasan; el valor aquí no es cazar
infracciones sino avisar del radio de impacto.

Cuentan como transversales: `core/`, `presentation/shared/`, `domain/shared/`, `infrastructure/api/`
(salvo `endpoints.ts`, ver abajo) y cualquier composable/componente de otro feature que el PR modifique.

**No cuentan** (cableado de rutina de un feature nuevo, es esperado): `core/providers/appProvider.ts`,
`core/providers/injectionKeys.ts`, `presentation/router/index.ts`, las entradas nuevas de
`infrastructure/api/endpoints.ts` y `LOOKUPS`, y el menú nuevo en `useDrawer.ts`.

Separar en dos grupos, porque el riesgo es muy distinto:

- **Cambian comportamiento existente** → tabla `Archivo | Qué cambia | A quién afecta`. Aquí va lo que altera
  código que ya corría: modificar un `catch` de `ErrorHandler`, el flujo de un composable compartido, cómo
  renderiza `DrawerComponent`, cambiar la firma de un `I*Repository` existente, corregir un texto de `ErrorUI`.
  En "A quién afecta" dar el alcance real ("toda petición HTTP", "todo módulo con clave transaccional"),
  no el nombre del archivo otra vez.
- **Aditivos** → una línea separada por `·`. Regla nueva en `useFormRules`, icono, mime, valor nuevo en una
  union de tipos, constante nueva, tipo nuevo exportado. Casi nunca rompen nada.

Un refactor que no cambia el resultado (extraer una plantilla a un helper) se menciona como "refactor puro"
**solo si se verificó** que produce lo mismo; si no se verificó, va como cambio de comportamiento.

Comprobaciones antes de escribir la sección:
- ¿El cambio existe en el repo hermano (`core_web_bac` / `core_web_csj`)? Si el PR es una migración, decir si
  el cambio viene del original o es propio. Un arreglo que el original no tiene suele significar que allá el
  bug sigue vivo: vale la pena decirlo.
- ¿El arreglo cubre todos los casos equivalentes? (p. ej. un helper que sólo contempla `ArrayBuffer` deja fuera
  `responseType: 'blob'`). Si queda a medias, decirlo.
- Sugerir que estos cambios queden en la descripción del PR.

### `PR-TEMPLATE` ℹ️ — pull_request_template.md (solo modo PR)

Con `description` de `meta.json`: sin id/enlace de HU, checklist de "Validación técnica" sin marcar,
sección "Pruebas realizadas" vacía. Informativo, no bloquea.

### `FUNCIONAL-GRAVE` ⚠️ — solo lo evidente

Reportar únicamente si es obvio y grave: condición siempre falsa/verdadera, constante de `ENDPOINTS` equivocada para
la operación, `await` faltante que rompe el flujo, código inalcanzable, variable usada antes de asignarse.
Nada especulativo ("podría fallar si…"). La funcionalidad se da por probada.
