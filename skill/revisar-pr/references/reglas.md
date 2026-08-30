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
| `SFC-TYPES` | 🔴 | CLAUDE.md bac | `interface`/`type` declarado dentro del `<script>` de un `.vue`. | Mover a `types/*.types.ts` del feature. |
| `ERROR-HANDLING` (mecánica) | 🔴 | patrón del repo | `catch {}` vacío o con solo un comentario; `try/finally` sin `catch`. | Ver la regla de criterio más abajo. |
| `NO-CONSOLE` | 🟡 | eslint.config | `console.*` fuera de tests. | Quitar o usar `useNotification`. |
| `NO-TODO` | 🟡 | CLAUDE.md global | `TODO`/`FIXME` en comentarios. | Lo pendiente va en el ticket, no en el código. |
| `ALIAS-IMPORTS` | 🟡 | CODING_STANDARDS | `from '../../...'`. | Usar `@/…` o los alias por capa. |
| `PROPS-TYPED` | 🟡 | PRESENTATION_LAYER | `defineProps([...])` / `defineEmits([...])` sin genérico. | `defineProps<{...}>()` con tipo del `*.types.ts`. |
| `NAMING` | 🟡 | CODING_STANDARDS, documentation.md §10 | Archivo nuevo que no sigue el patrón de su carpeta (`I*Repository.ts`, `*UseCase.ts`, `*RepositoryImpl.ts`, `*Mapper.ts`, `use*.ts`, `*Store.ts`, `kebab-case.types.ts`, `PascalCase.vue`). | Renombrar. |
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

Patrón canónico aceptado en composables:

```ts
try {
  loader.show()
  const result = await xUseCase?.execute(data)
  ...
} catch (e) {
  if (e instanceof Error) error(e.message)
} finally {
  loader.hide()
}
```

Reportar:
- 🔴 `await xUseCase?.execute(...)` en un composable **sin `try/catch`** alrededor (ni en el llamador directo).
- 🔴 `catch` que no notifica ni relanza: no llama `error(...)`, `notify`, `throw`, ni `handleError`.
- 🔴 Loader/`loading = true` antes del `await` que **no se apaga** si hay error (no está en `finally` ni en el `catch`).
- 🟡 Loader que sí se apaga en todos los caminos pero fuera de `finally`: no sigue el patrón canónico.
- 🔴 Use case que envuelve el repositorio en `try/catch` y devuelve `null`/`[]`/`undefined` tragando el error,
  incluido el patrón `catch (e) { if (e instanceof ValidationError) throw e }` sin `else throw` (existe en ~40 use cases
  del repo; sigue siendo hallazgo: el retorno queda `| void` y el composable nunca se entera del fallo).

No reportar: `catch` que relanza; `catch` que notifica con `error(e.message)`; `catch` que hace fallback documentado
y **además** notifica. No se exige `useErrorHandler` (existe pero las features no lo usan).

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

### `PR-TEMPLATE` ℹ️ — pull_request_template.md (solo modo PR)

Con `description` de `meta.json`: sin id/enlace de HU, checklist de "Validación técnica" sin marcar,
sección "Pruebas realizadas" vacía. Informativo, no bloquea.

### `FUNCIONAL-GRAVE` ⚠️ — solo lo evidente

Reportar únicamente si es obvio y grave: condición siempre falsa/verdadera, constante de `ENDPOINTS` equivocada para
la operación, `await` faltante que rompe el flujo, código inalcanzable, variable usada antes de asignarse.
Nada especulativo ("podría fallar si…"). La funcionalidad se da por probada.
