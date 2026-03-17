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
- **File Separation PREFERRED** - Split components into .vue, .ts, .html, .scss files
- **Single Responsibility** - One concern per component
- **Props Interface** - Always define TypeScript interfaces for props
- **Emits Definition** - Explicit emit declarations
- **Slot Strategy** - Named slots for maximum flexibility

### 🏗️ **Project Structure**
```
src/
├── components/           # Reusable UI components
│   ├── base/            # Generic components
│   │   ├── BaseButton/  # Separated component files
│   │   │   ├── BaseButton.vue      # Main component file
│   │   │   ├── BaseButton.html     # Template logic
│   │   │   ├── BaseButton.ts       # Script logic  
│   │   │   └── BaseButton.scss     # Component styles
│   │   └── BaseInput/   
│   ├── layout/          # Layout components (AppHeader, AppSidebar)
│   └── feature/         # Feature-specific components
├── composables/         # Reusable composition functions
├── stores/              # Pinia stores
├── pages/               # Page components (router views)
├── layouts/             # Quasar layouts
└── types/               # TypeScript type definitions
```

**Component File Organization Options:**
1. **Separated Files** (Preferred for complex components):
   - `Component.vue` - Main component registration
   - `Component.html` - Template logic
   - `Component.ts` - Script logic
   - `Component.scss` - Component styles

2. **Single File** (For simple components):
   - `Component.vue` - All-in-one SFC

### 🔄 **State Management with Pinia**
- **Store per Feature** - Separate stores for different domains
- **Composition Store Style** - Use `setup()` syntax
- **Persistence Strategy** - Use pinia-plugin-persistedstate
- **Computed vs Getters** - Prefer computed for derived state

### 📁 **File Organization Strategy**
- **Separated Files** for complex components (>50 lines total, multiple responsibilities)
  - Better separation of concerns
  - Easier collaboration (designers work on .html, developers on .ts)
  - Cleaner code review process
  - Better IDE support for large files
  
- **Single File Components** for simple components (<50 lines total)
  - Quick prototyping
  - Simple UI components
  - When template, script, and styles are tightly coupled

### 📱 **Quasar Best Practices**
- **Platform Detection** - Use `$q.platform` for conditional logic
- **Responsive Grid** - Leverage Quasar's 12-column grid system
- **Icon Strategy** - Use Quasar's icon sets (Material Icons recommended)
- **Theme Customization** - Override SASS variables in quasar.variables.sass

## Code Examples

### 🧩 **Separated Files Component Pattern (Preferred)**

**Structure:**
```
components/BaseButton/
├── BaseButton.vue      # Main component registration
├── BaseButton.html     # Template logic  
├── BaseButton.ts       # Script logic
└── BaseButton.scss     # Component styles
```

**BaseButton.vue (Main File):**
```vue
<template src="./BaseButton.html"></template>
<script setup lang="ts" src="./BaseButton.ts"></script>
<style scoped lang="scss" src="./BaseButton.scss"></style>
```

**BaseButton.html (Template):**
```html
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
```

**BaseButton.ts (Script):**
```typescript
interface Props {
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  disabled?: boolean
  label?: string
  icon?: string
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

const quasarColor = computed(() => {
  const colorMap = {
    primary: 'primary',
    secondary: 'grey-6', 
    danger: 'negative'
  }
  return colorMap[props.variant]
})

const handleClick = (event: MouseEvent) => {
  if (!props.loading && !props.disabled) {
    emit('click', event)
  }
}
```

**BaseButton.scss (Styles):**
```scss
.base-button {
  @apply transition-all duration-200 ease-in-out;

  &--primary {
    // Custom primary styles if needed
  }

  &--secondary {
    // Custom secondary styles  
  }

  &--sm {
    @apply px-3 py-1 text-sm;
  }

  &--md {
    @apply px-4 py-2 text-base;
  }
}
```

### 🧩 **Single File Component (For Simple Cases)**
```vue
<template>
  <q-card class="simple-card">
    <q-card-section>
      <slot />
    </q-card-section>
  </q-card>
</template>

<script setup lang="ts">
interface Props {
  variant?: 'default' | 'bordered'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
})
</script>

<style scoped>
.simple-card {
  /* Simple styles */
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

# Component creation helper
mkdir -p src/components/MyComponent
touch src/components/MyComponent/MyComponent.{vue,html,ts,scss}

# Type checking
npm run type-check

# Lint and format
npm run lint
npm run format

# File organization helper (create separated component)
create-component() {
  local name=$1
  local path="src/components/$name"
  mkdir -p "$path"
  
  # Main .vue file
  cat > "$path/$name.vue" << EOF
<template src="./$name.html"></template>
<script setup lang="ts" src="./$name.ts"></script>
<style scoped lang="scss" src="./$name.scss"></style>
EOF
  
  # Template file
  cat > "$path/$name.html" << EOF
<div class="${name,,}">
  <!-- Your template here -->
  <slot />
</div>
EOF
  
  # Script file
  cat > "$path/$name.ts" << EOF
interface Props {
  // Define your props here
}

const props = withDefaults(defineProps<Props>(), {
  // defaults here
})
EOF
  
  # Style file
  cat > "$path/$name.scss" << EOF
.${name,,} {
  // Your styles here
}
EOF
  
  echo "Created component: $path"
}
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