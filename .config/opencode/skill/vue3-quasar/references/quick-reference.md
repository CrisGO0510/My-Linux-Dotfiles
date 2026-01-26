# Vue 3 + Quasar Quick Reference

## Essential Patterns for Job Interview Success

### 🎯 Key Concepts to Master

1. **Composition API** - Replacement for Options API
2. **Reactivity System** - ref, reactive, computed, watch
3. **Component Communication** - Props, emits, provide/inject
4. **State Management** - Pinia stores with persistence
5. **Quasar Components** - Layout system, responsive design
6. **Performance** - Lazy loading, code splitting, PWA features

### 🚀 Common Interview Questions & Answers

**Q: What's the difference between ref and reactive?**
```typescript
// ref - for primitives and single values
const count = ref(0)
const user = ref<User | null>(null)

// reactive - for objects (avoid for primitives)
const state = reactive({
  items: [],
  loading: false,
})
```

**Q: How do you handle component communication?**
```vue
<!-- Parent to Child: Props -->
<ChildComponent :data="parentData" />

<!-- Child to Parent: Emits -->
<ChildComponent @update="handleUpdate" />

<!-- Deep component tree: Provide/Inject -->
provide('theme', themeValue)
const theme = inject('theme')
```

**Q: How do you persist state with Pinia?**
```typescript
export const useStore = defineStore('store', () => {
  // Store logic
}, {
  persist: {
    key: 'my-store',
    paths: ['user', 'preferences'], // Only persist specific state
    storage: localStorage, // or sessionStorage
  },
})
```

### 📱 Quasar Essential Components

```vue
<!-- Layout Structure -->
<q-layout view="lHh Lpr lFf">
  <q-header>
    <q-toolbar>
      <q-btn flat round icon="menu" @click="drawer = !drawer" />
      <q-toolbar-title>App</q-toolbar-title>
    </q-toolbar>
  </q-header>
  
  <q-drawer v-model="drawer" bordered>
    <q-list>
      <q-item clickable>
        <q-item-section>Menu Item</q-item-section>
      </q-item>
    </q-list>
  </q-drawer>
  
  <q-page-container>
    <router-view />
  </q-page-container>
</q-layout>

<!-- Responsive Grid -->
<div class="row q-gutter-md">
  <div class="col-12 col-md-6 col-lg-4">
    <q-card>
      <q-card-section>Content</q-card-section>
    </q-card>
  </div>
</div>

<!-- Forms -->
<q-form @submit="onSubmit" class="q-gutter-md">
  <q-input
    v-model="form.email"
    type="email"
    label="Email"
    :rules="[val => !!val || 'Required']"
  />
  <q-btn type="submit" color="primary">Submit</q-btn>
</q-form>
```

### 🎨 Tailwind Integration

```vue
<template>
  <!-- Mix Quasar and Tailwind classes -->
  <q-card class="shadow-lg hover:shadow-xl transition-shadow">
    <q-card-section class="bg-gradient-to-r from-blue-500 to-purple-600">
      <h2 class="text-white text-xl font-bold">Card Title</h2>
    </q-card-section>
  </q-card>
</template>

<style scoped>
/* Custom Tailwind utilities */
@apply flex items-center justify-between;

/* Responsive design */
.mobile-only {
  @apply block md:hidden;
}

.desktop-only {
  @apply hidden md:block;
}
</style>
```

### 📊 Performance Best Practices

```vue
<script setup lang="ts">
// 1. Lazy loading components
const LazyComponent = defineAsyncComponent(
  () => import('./components/HeavyComponent.vue')
)

// 2. Computed for expensive operations
const expensiveComputation = computed(() => {
  return heavyCalculation(props.data)
})

// 3. Watch with deep option carefully
watch(() => props.data, (newVal) => {
  // Handle changes
}, { deep: true }) // Use sparingly

// 4. Memoization for complex data
const memoizedData = computed(() => {
  return useMemo(() => processData(rawData.value), [rawData.value])
})
</script>
```

### 🔐 Authentication Pattern

```typescript
// stores/authStore.ts
export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  
  const isAuthenticated = computed(() => !!user.value && !!token.value)
  
  const login = async (credentials: LoginData) => {
    const response = await authAPI.login(credentials)
    user.value = response.user
    token.value = response.token
    
    // Set axios default header
    axios.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
  }
  
  const logout = () => {
    user.value = null
    token.value = null
    delete axios.defaults.headers.common['Authorization']
    router.push('/login')
  }
  
  return { user, isAuthenticated, login, logout }
}, {
  persist: {
    key: 'auth',
    paths: ['user', 'token'],
  },
})
```

### 📱 PWA Setup

```typescript
// quasar.config.js
module.exports = {
  build: {
    pwa: {
      workbox: {
        navigateFallback: 'index.html',
        runtimeCaching: [{
          urlPattern: /^https:\/\/api\.mysite\.com\/.*$/,
          handler: 'StaleWhileRevalidate',
          options: {
            cacheName: 'api-cache',
          },
        }],
      },
      manifest: {
        name: 'My App',
        short_name: 'MyApp',
        theme_color: '#1976d2',
        background_color: '#ffffff',
        display: 'standalone',
      },
    },
  },
}
```

### 🧪 Testing Patterns

```typescript
// Component test
import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'

describe('MyComponent', () => {
  it('renders correctly', () => {
    const wrapper = mount(MyComponent, {
      props: { title: 'Test' },
    })
    
    expect(wrapper.find('h1').text()).toBe('Test')
  })
  
  it('emits event on click', async () => {
    const wrapper = mount(MyComponent)
    await wrapper.find('button').trigger('click')
    
    expect(wrapper.emitted('click')).toBeTruthy()
  })
})

// Store test
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from '@/stores/user'

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
  
  it('handles login correctly', async () => {
    const store = useUserStore()
    
    await store.login({ email: 'test@test.com', password: 'password' })
    
    expect(store.isAuthenticated).toBe(true)
    expect(store.user).toBeTruthy()
  })
})
```