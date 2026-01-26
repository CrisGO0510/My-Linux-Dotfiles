---
name: vue3-quasar
description: >
  Vue.js 3 + Quasar Framework patterns with Composition API, Pinia state management, and Tailwind CSS.
  Trigger: When developing Vue.js 3 applications with Quasar Framework, Composition API, Pinia, or building SPA/PWA/mobile apps.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Building Vue.js 3 applications with Quasar Framework
- Creating reusable, scalable, and decoupled components
- Implementing Composition API patterns
- Setting up Pinia for state management with persistence
- Developing SPA, PWA, or mobile applications with Quasar
- Applying responsive design with Tailwind CSS
- Implementing accessibility best practices

## Critical Patterns

### 🎯 **Component Architecture**
- **Composition API FIRST** - No Options API unless legacy
- **Single Responsibility** - One concern per component
- **Props Interface** - Always define TypeScript interfaces for props
- **Emits Definition** - Explicit emit declarations
- **Slot Strategy** - Named slots for maximum flexibility

### 🏗️ **Project Structure**
```
src/
├── components/           # Reusable UI components
│   ├── base/            # Generic components (BaseButton, BaseInput)
│   ├── layout/          # Layout components (AppHeader, AppSidebar)
│   └── feature/         # Feature-specific components
├── composables/         # Reusable composition functions
├── stores/              # Pinia stores
├── pages/               # Page components (router views)
├── layouts/             # Quasar layouts
└── types/               # TypeScript type definitions
```

### 🔄 **State Management with Pinia**
- **Store per Feature** - Separate stores for different domains
- **Composition Store Style** - Use `setup()` syntax
- **Persistence Strategy** - Use pinia-plugin-persistedstate
- **Computed vs Getters** - Prefer computed for derived state

### 📱 **Quasar Best Practices**
- **Platform Detection** - Use `$q.platform` for conditional logic
- **Responsive Grid** - Leverage Quasar's 12-column grid system
- **Icon Strategy** - Use Quasar's icon sets (Material Icons recommended)
- **Theme Customization** - Override SASS variables in quasar.variables.sass

## Code Examples

### 🧩 **Reusable Component Pattern**
```vue
<template>
  <q-btn
    :class="buttonClasses"
    :disable="loading || disabled"
    :loading="loading"
    @click="handleClick"
  >
    <slot>{{ label }}</slot>
  </q-btn>
</template>

<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  label?: string
}

interface Emits {
  click: [event: MouseEvent]
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
})

const emit = defineEmits<Emits>()

const buttonClasses = computed(() => [
  'base-button',
  `base-button--${props.variant}`,
  `base-button--${props.size}`,
])

const handleClick = (event: MouseEvent) => {
  if (!props.loading && !props.disabled) {
    emit('click', event)
  }
}
</script>

<style scoped>
.base-button {
  @apply transition-all duration-200 ease-in-out;
}

.base-button--primary {
  @apply bg-primary text-white hover:bg-primary-dark;
}

.base-button--secondary {
  @apply bg-gray-200 text-gray-800 hover:bg-gray-300;
}

.base-button--sm {
  @apply px-3 py-1 text-sm;
}

.base-button--md {
  @apply px-4 py-2 text-base;
}
</style>
```

### 🗂️ **Pinia Store Pattern**
```typescript
// stores/userStore.ts
export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  const preferences = ref<UserPreferences>({
    theme: 'auto',
    language: 'en',
  })

  // Getters (computed)
  const isAuthenticated = computed(() => !!user.value)
  const displayName = computed(() => 
    user.value ? `${user.value.firstName} ${user.value.lastName}` : 'Guest'
  )

  // Actions
  const login = async (credentials: LoginCredentials) => {
    try {
      const response = await authAPI.login(credentials)
      user.value = response.user
      return { success: true }
    } catch (error) {
      console.error('Login failed:', error)
      return { success: false, error }
    }
  }

  const updatePreferences = (newPreferences: Partial<UserPreferences>) => {
    preferences.value = { ...preferences.value, ...newPreferences }
  }

  return {
    // State
    user: readonly(user),
    preferences,
    // Getters
    isAuthenticated,
    displayName,
    // Actions
    login,
    updatePreferences,
  }
}, {
  persist: {
    key: 'user-store',
    paths: ['user', 'preferences'],
  },
})
```

### 🎨 **Composable Pattern**
```typescript
// composables/useApi.ts
export function useApi<T>(
  url: MaybeRef<string>,
  options: ApiOptions = {}
) {
  const { immediate = true } = options
  
  const data = ref<T | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const execute = async () => {
    try {
      loading.value = true
      error.value = null
      
      const response = await $fetch<T>(unref(url))
      data.value = response
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unknown error'
    } finally {
      loading.value = false
    }
  }

  if (immediate) {
    execute()
  }

  // Watch URL changes
  watch(() => unref(url), execute, { immediate: false })

  return {
    data: readonly(data),
    loading: readonly(loading),
    error: readonly(error),
    execute,
    refresh: execute,
  }
}
```

### 📱 **Responsive Quasar Layout**
```vue
<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="menu"
          aria-label="Menu"
          @click="toggleLeftDrawer"
          class="q-mr-sm"
        />
        
        <q-toolbar-title class="text-weight-bold">
          {{ $route.meta.title || 'App' }}
        </q-toolbar-title>

        <q-space />

        <!-- Desktop actions -->
        <div v-if="!$q.platform.is.mobile" class="q-gutter-sm">
          <base-button variant="secondary" size="sm">
            Settings
          </base-button>
        </div>

        <!-- Mobile menu -->
        <q-btn
          v-else
          flat
          dense
          round
          icon="more_vert"
          @click="toggleRightDrawer"
        />
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      :width="280"
      class="bg-grey-1"
    >
      <navigation-menu />
    </q-drawer>

    <q-page-container>
      <router-view v-slot="{ Component, route }">
        <transition
          :name="route.meta.transition || 'fade'"
          mode="out-in"
        >
          <component :is="Component" :key="route.path" />
        </transition>
      </router-view>
    </q-page-container>
  </q-layout>
</template>

<script setup lang="ts">
const leftDrawerOpen = ref(false)
const rightDrawerOpen = ref(false)

const toggleLeftDrawer = () => {
  leftDrawerOpen.value = !leftDrawerOpen.value
}

const toggleRightDrawer = () => {
  rightDrawerOpen.value = !rightDrawerOpen.value
}
</script>
```

## Commands

### 🚀 **Project Setup**
```bash
# Create new Quasar project with Vue 3 + TypeScript
npm create quasar@latest my-app

# Add Pinia
npm install pinia pinia-plugin-persistedstate

# Add Tailwind CSS (if not using Quasar's classes exclusively)
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Development server
npm run dev

# Build for production
npm run build

# PWA build
quasar build -m pwa

# Mobile build (requires Cordova)
quasar build -m cordova -T android
```

### 🔧 **Development Tools**
```bash
# Add TypeScript support
npm install -D typescript @types/node

# ESLint + Prettier
npm install -D @typescript-eslint/eslint-plugin @typescript-eslint/parser prettier eslint-config-prettier

# Testing
npm install -D @vue/test-utils vitest jsdom

# Type checking
npm run type-check

# Lint and format
npm run lint
npm run format
```

### 📱 **Quasar CLI Commands**
```bash
# Add platform
quasar mode add pwa
quasar mode add cordova

# Generate component
quasar new component MyComponent
quasar new page MyPage
quasar new layout MyLayout

# Inspect webpack config
quasar inspect --cmd dev
quasar inspect --cmd build
```

## Resources

- **Templates**: See [assets/](assets/) for component templates and store patterns
- **Documentation**: See [references/](references/) for Vue 3 and Quasar specific guides
- **Quasar Documentation**: https://quasar.dev/
- **Vue 3 Composition API**: https://vuejs.org/guide/extras/composition-api-faq.html
- **Pinia Documentation**: https://pinia.vuejs.org/