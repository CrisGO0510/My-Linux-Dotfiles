---
name: vue3-quasar
description: >
  Vue.js 3 + Quasar Framework patterns with Composition API, Pinia state management.
  Trigger: When developing Vue.js 3 applications with Quasar Framework, Composition API, Pinia, or building SPA/PWA/mobile apps.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "2.0"
---

## When to Use

- Building Vue.js 3 applications with Quasar Framework
- Creating reusable, scalable, and decoupled components
- Implementing Composition API patterns
- Setting up Pinia for state management with persistence
- Developing SPA, PWA, or mobile applications with Quasar

## Critical Patterns

### Component Architecture
- **Composition API FIRST** — No Options API unless legacy
- **SFC (Single File Component)** — Template, script, and style in one `.vue` file
- **Composable for logic** — Extract complex logic to `useXxx()` composables in separate `.ts` files
- **Single Responsibility** — One concern per component. If a component grows, split into smaller child components, not separate file types
- **Props Interface** — Always define TypeScript interfaces for props
- **Emits Definition** — Explicit emit declarations
- **Slot Strategy** — Named slots for maximum flexibility

### Component File Organization

**Every component lives in its own directory:**

```
ComponentName/
├── ComponentName.vue       # SFC: template + script setup + scoped styles
├── ComponentName.ts        # Composable: useComponentName() with all logic
└── ComponentName.scss      # Styles (optional, only if complex styles)
```

**The `.vue` file** contains the template inline, imports the composable, and optionally uses `<style scoped lang="scss" src="./ComponentName.scss">` for styles.

**The `.ts` file** exports a `useComponentName()` composable with all reactive state, computed properties, and functions. The `.vue` file destructures and uses them.

**Why SFC instead of separated `.html`:**
- `<script setup>` does NOT support `src` attribute (Vue compiler limitation)
- `eslint-plugin-vue` cannot connect external `.html` templates with `<script setup>` bindings (reports false "unused variable" errors)
- SFC guarantees full Composition API support, type inference, and tooling compatibility

**When to split into child components (not more files):**
- Template exceeds ~100 lines
- A section has its own state/logic independent from the parent
- A piece of UI is reused elsewhere

### Project Structure
```
src/
├── components/           # Reusable UI components
│   ├── base/            # Generic components (BaseButton/, BaseInput/)
│   ├── layout/          # Layout components (AppHeader/, AppSidebar/)
│   └── feature/         # Feature-specific components
├── composables/         # Shared composition functions (cross-module)
├── modules/             # Domain modules
│   └── <module>/
│       ├── components/  # Module-specific UI components
│       ├── composables/ # Module-specific composables
│       ├── use-cases/   # Business operations (one function per file)
│       ├── views/       # Route-level components (NOT pages/)
│       ├── repositories/# Port interfaces + adapters
│       ├── stores/      # Pinia stores
│       └── types/       # TypeScript types/entities
├── views/               # Global route-level components
├── stores/              # Global Pinia store setup
├── layouts/             # Quasar layouts
└── core/                # Infrastructure (database, repositories, types)
```

### Application Flow (Hexagonal)

```
Vue SFC (.vue template)
    ↓ destructures
Composable (useXxx.ts) — UI state, form handling
    ↓ calls
Pinia Store — global reactive state, coordinates use cases
    ↓ calls
Use Case (function) — one business operation, one responsibility
    ↓ depends on
Repository Port (interface) — data access contract
    ↓ implemented by
Adapter (SQLite, API, etc.) — concrete implementation
```

**Rules:**
- **Use cases are functions**, not classes — receive repository port as argument, return an async function
- **Stores never call repositories directly** — always through use cases
- **Composables handle UI logic only** — form state, validation UX, no business rules
- **Each use case = one file, one operation** (e.g., `createProfile.ts`, `updateProfile.ts`)

### State Management with Pinia
- **Store per Feature** — Separate stores for different domains
- **Composition Store Style** — Use `setup()` syntax with `defineStore`
- **Stores coordinate use cases** — instantiate use cases with repository, expose actions
- **Computed vs Getters** — Prefer computed for derived state

### Constants & Configuration
- **NO magic strings or magic numbers — ever.** No literal with meaning (sizes, limits, keys, statuses, endpoints, breakpoints) may appear inline in templates or logic. Extract it to a named constant.
- **Reuse existing constants first** — before creating a new one, `grep` for the raw value and for likely names (e.g. `*_SIZE`, `FILE_SIZES`, status enums). Only add a new constant if none exists.
- **Example** — file/upload sizes belong in a shared table (e.g. `FILE_SIZES.MB_5.value`), not `5242880` inline on a `:max-file-size` prop.
- **Where they live** — feature-specific constants near the feature; cross-cutting ones in a shared `types/`/`constants/` module.

### Quasar Best Practices
- **Platform Detection** — Use `$q.platform` for conditional logic
- **Responsive Grid** — Leverage Quasar's 12-column grid system
- **Icon Strategy** — Use Quasar's icon sets (Material Icons recommended)
- **Theme Customization** — Override SASS variables in `quasar.variables.scss`
- **Auto-imports** — Quasar components don't need manual imports in templates

## Code Examples

### SFC + Composable Pattern

**Structure:**
```
components/BaseButton/
├── BaseButton.vue       # SFC with template + script setup
└── BaseButton.ts        # useBaseButton() composable
```

**BaseButton.ts (Composable):**
```typescript
import { computed } from 'vue';

interface Props {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  label?: string
  icon?: string
}

interface Emits {
  (e: 'click', event: MouseEvent): void
}

export function useBaseButton(props: Props, emit: Emits) {
  const buttonClasses = computed(() => [
    'base-button',
    `base-button--${props.variant}`,
    `base-button--${props.size}`,
  ]);

  const quasarColor = computed(() => {
    const colorMap = {
      primary: 'primary',
      secondary: 'grey-6',
      danger: 'negative',
    } as const;
    return colorMap[props.variant ?? 'primary'];
  });

  function handleClick(event: MouseEvent) {
    if (!props.loading && !props.disabled) {
      emit('click', event);
    }
  }

  return { buttonClasses, quasarColor, handleClick };
}
```

**BaseButton.vue (SFC):**
```vue
<template>
  <q-btn
    :class="buttonClasses"
    :disable="loading || disabled"
    :loading="loading"
    :color="quasarColor"
    @click="handleClick"
  >
    <q-icon v-if="icon" :name="icon" />
    <slot>{{ label }}</slot>
  </q-btn>
</template>

<script setup lang="ts">
import { useBaseButton } from './BaseButton';

interface Props {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  label?: string
  icon?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
});

const emit = defineEmits<{
  click: [event: MouseEvent]
}>();

const { buttonClasses, quasarColor, handleClick } = useBaseButton(props, emit);
</script>

<style scoped lang="scss">
.base-button {
  transition: all 0.2s ease-in-out;
}
</style>
```

### Page with Composable (no props/emits)

**OnboardingPage.ts:**
```typescript
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

export function useOnboardingPage() {
  const router = useRouter();
  const name = ref('');
  const saving = ref(false);

  const isValid = computed(() => name.value.trim().length > 0);

  async function handleSubmit() {
    if (!isValid.value) return;
    saving.value = true;
    try {
      // save logic
      await router.push('/');
    } finally {
      saving.value = false;
    }
  }

  return { name, saving, isValid, handleSubmit };
}
```

**OnboardingPage.vue:**
```vue
<template>
  <div class="onboarding-page q-pa-lg">
    <q-input v-model="name" label="Tu nombre" />
    <q-btn label="Comenzar" :loading="saving" @click="handleSubmit" />
  </div>
</template>

<script setup lang="ts">
import { useOnboardingPage } from './OnboardingPage';

const { name, saving, handleSubmit } = useOnboardingPage();
</script>

<style scoped lang="scss">
.onboarding-page {
  min-height: 100vh;
}
</style>
```

### Use Case Pattern

```typescript
// use-cases/createProfile.ts
import type { UserProfileRepository } from '../repositories/profile.repository.port';
import type { UserProfile } from '../types/profile.types';

export function createProfile(repository: UserProfileRepository) {
  return async (data: Omit<UserProfile, 'id' | 'createdAt' | 'updatedAt'>): Promise<UserProfile> => {
    const existing = await repository.get();
    if (existing) {
      throw new Error('Profile already exists. Use updateProfile instead.');
    }
    return repository.save(data);
  };
}
```

**Key points:**
- One file, one operation
- Receives repository port (interface) as argument — never the concrete adapter
- Returns an async function — the actual operation
- Contains business validations and rules
- Pure function, no framework dependencies

### Pinia Store Pattern (with Use Cases)
```typescript
import { ProfileSQLiteRepository } from '../repositories/profile.sqlite-repository';
import { getProfile } from '../use-cases/getProfile';
import { createProfile } from '../use-cases/createProfile';
import { updateProfile } from '../use-cases/updateProfile';

export const useProfileStore = defineStore('profile', () => {
  const repository = new ProfileSQLiteRepository();

  // Wire use cases with repository
  const get = getProfile(repository);
  const create = createProfile(repository);
  const update = updateProfile(repository);

  const profile = ref<UserProfile | null>(null);
  const hasProfile = computed(() => profile.value !== null);

  async function loadProfile() {
    profile.value = await get();
  }

  async function saveProfile(data: Omit<UserProfile, 'id' | 'createdAt' | 'updatedAt'>) {
    profile.value = profile.value ? await update(data) : await create(data);
  }

  return { profile, hasProfile, loadProfile, saveProfile };
});
```

**Key points:**
- Store instantiates the repository and wires it into use cases
- Store actions delegate to use cases, never call repository directly
- Store manages reactive state only

### Shared Composable Pattern
```typescript
// composables/useApi.ts
export function useApi<T>(url: MaybeRef<string>) {
  const data = ref<T | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  async function execute() {
    loading.value = true;
    error.value = null;
    try {
      data.value = await $fetch<T>(unref(url));
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unknown error';
    } finally {
      loading.value = false;
    }
  }

  return {
    data: readonly(data),
    loading: readonly(loading),
    error: readonly(error),
    execute,
  };
}
```

## Commands

```bash
# Development
quasar dev                              # SPA dev server
quasar dev -m capacitor -T android      # Android dev
quasar dev -m capacitor -T ios          # iOS dev

# Build
quasar build                            # SPA production build
quasar build -m capacitor -T android    # Android build
quasar build -m pwa                     # PWA build

# Utilities
quasar new component MyComponent        # Generate component
quasar new page MyPage                  # Generate page
quasar new layout MyLayout              # Generate layout
```

## Resources

- **Quasar Documentation**: https://quasar.dev/
- **Vue 3 Composition API**: https://vuejs.org/guide/extras/composition-api-faq.html
- **Pinia Documentation**: https://pinia.vuejs.org/
