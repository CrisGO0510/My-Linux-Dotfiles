# Vue 3 + Quasar Component Templates

## 🎯 Separated Files Component (Preferred for Complex Components)

### Component Structure
```
components/
└── BaseButton/
    ├── BaseButton.vue      # Main component registration
    ├── BaseButton.html     # Template logic
    ├── BaseButton.ts       # Script logic
    └── BaseButton.scss     # Component styles
```

### BaseButton.vue (Main File)
```vue
<template src="./BaseButton.html"></template>
<script setup lang="ts" src="./BaseButton.ts"></script>
<style scoped lang="scss" src="./BaseButton.scss"></style>
```

### BaseButton.html (Template)
```html
<q-btn
  :class="buttonClasses"
  :disable="loading || disabled"
  :loading="loading"
  :color="quasarColor"
  :size="size"
  @click="handleClick"
>
  <q-icon 
    v-if="icon" 
    :name="icon" 
    :left="iconPosition === 'left'"
    :right="iconPosition === 'right'"
  />
  
  <slot>{{ label }}</slot>
</q-btn>
```

### BaseButton.ts (Script)
```typescript
interface Props {
  variant?: 'primary' | 'secondary' | 'danger' | 'success'
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl'
  loading?: boolean
  disabled?: boolean
  label?: string
  icon?: string
  iconPosition?: 'left' | 'right'
}

interface Emits {
  click: [event: MouseEvent]
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  disabled: false,
  iconPosition: 'left',
})

const emit = defineEmits<Emits>()

// Computed properties
const buttonClasses = computed(() => [
  'base-button',
  `base-button--${props.variant}`,
  `base-button--${props.size}`,
])

const quasarColor = computed(() => {
  const colorMap = {
    primary: 'primary',
    secondary: 'grey-6',
    danger: 'negative',
    success: 'positive',
  }
  return colorMap[props.variant]
})

// Methods
const handleClick = (event: MouseEvent) => {
  if (!props.loading && !props.disabled) {
    emit('click', event)
  }
}
```

### BaseButton.scss (Styles)
```scss
.base-button {
  @apply transition-all duration-200 ease-in-out;
  
  &--primary {
    // Custom primary styles if needed beyond Quasar's
  }
  
  &--secondary {
    // Custom secondary styles
  }
  
  &--danger {
    // Custom danger styles
  }
  
  &--success {
    // Custom success styles
  }
  
  // Size variations
  &--xs {
    @apply text-xs;
  }
  
  &--sm {
    @apply text-sm;
  }
  
  &--md {
    @apply text-base;
  }
  
  &--lg {
    @apply text-lg;
  }
  
  &--xl {
    @apply text-xl;
  }
}
```

---

## 🎯 Single File Component (For Simple Components)

### SimpleCard.vue
```vue
<template>
  <q-card :class="cardClasses">
    <q-card-section v-if="title || $slots.header">
      <slot name="header">
        <div class="text-h6">{{ title }}</div>
      </slot>
    </q-card-section>
    
    <q-card-section>
      <slot />
    </q-card-section>
    
    <q-card-actions v-if="$slots.actions" align="right">
      <slot name="actions" />
    </q-card-actions>
  </q-card>
</template>

<script setup lang="ts">
interface Props {
  title?: string
  variant?: 'default' | 'bordered' | 'elevated'
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
})

const cardClasses = computed(() => [
  'simple-card',
  `simple-card--${props.variant}`,
])
</script>

<style scoped>
.simple-card {
  &--bordered {
    border: 1px solid var(--q-color-grey-3);
  }
  
  &--elevated {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
}
</style>
```

---

## 🗂️ Pinia Store Template

### stores/userStore.ts
```typescript
import { defineStore } from 'pinia'
import { ref, computed, readonly } from 'vue'

export interface User {
  id: string
  email: string
  firstName: string
  lastName: string
  avatar?: string
  role: 'admin' | 'user' | 'moderator'
}

export interface UserPreferences {
  theme: 'light' | 'dark' | 'auto'
  language: string
  notifications: boolean
}

export const useUserStore = defineStore('user', () => {
  // State
  const user = ref<User | null>(null)
  const preferences = ref<UserPreferences>({
    theme: 'auto',
    language: 'en',
    notifications: true,
  })
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Getters (computed)
  const isAuthenticated = computed(() => !!user.value)
  const displayName = computed(() => 
    user.value ? `${user.value.firstName} ${user.value.lastName}` : 'Guest'
  )
  const isAdmin = computed(() => user.value?.role === 'admin')

  // Actions
  const login = async (credentials: { email: string; password: string }) => {
    try {
      loading.value = true
      error.value = null
      
      const response = await authAPI.login(credentials)
      user.value = response.user
      
      return { success: true }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Login failed'
      error.value = message
      return { success: false, error: message }
    } finally {
      loading.value = false
    }
  }

  const logout = async () => {
    try {
      await authAPI.logout()
    } finally {
      user.value = null
      error.value = null
    }
  }

  const updateProfile = async (profileData: Partial<User>) => {
    if (!user.value) throw new Error('User not authenticated')
    
    try {
      loading.value = true
      const updatedUser = await userAPI.updateProfile(user.value.id, profileData)
      user.value = { ...user.value, ...updatedUser }
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Update failed'
      throw err
    } finally {
      loading.value = false
    }
  }

  const updatePreferences = (newPreferences: Partial<UserPreferences>) => {
    preferences.value = { ...preferences.value, ...newPreferences }
  }

  return {
    // State (readonly to prevent external mutations)
    user: readonly(user),
    preferences,
    loading: readonly(loading),
    error: readonly(error),
    
    // Getters
    isAuthenticated,
    displayName,
    isAdmin,
    
    // Actions
    login,
    logout,
    updateProfile,
    updatePreferences,
  }
}, {
  persist: {
    key: 'user-store',
    paths: ['user', 'preferences'],
    storage: localStorage,
  },
})
```

---

## 🎨 Advanced Composable Template

### composables/useApi.ts
```typescript
import { ref, computed, readonly, unref, watch, type MaybeRef } from 'vue'

export interface ApiOptions {
  immediate?: boolean
  resetOnExecute?: boolean
  shallow?: boolean
  onSuccess?: (data: any) => void
  onError?: (error: Error) => void
}

export interface ApiState<T> {
  data: T | null
  loading: boolean
  error: string | null
}

export function useApi<T = any>(
  url: MaybeRef<string>,
  options: ApiOptions = {}
) {
  const {
    immediate = true,
    resetOnExecute = true,
    shallow = false,
    onSuccess,
    onError,
  } = options

  // State
  const data = ref<T | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Computed
  const isReady = computed(() => !loading.value && !error.value)
  const isError = computed(() => !!error.value)

  // Methods
  const execute = async (params?: Record<string, any>) => {
    try {
      if (resetOnExecute) {
        data.value = null
        error.value = null
      }
      
      loading.value = true
      
      const response = await $fetch<T>(unref(url), {
        query: params,
      })
      
      data.value = response
      onSuccess?.(response)
      
      return response
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Request failed'
      error.value = errorMessage
      onError?.(err instanceof Error ? err : new Error(errorMessage))
      throw err
    } finally {
      loading.value = false
    }
  }

  const refresh = () => execute()
  const clear = () => {
    data.value = null
    error.value = null
    loading.value = false
  }

  // Auto-execute
  if (immediate) {
    execute()
  }

  // Watch URL changes
  watch(
    () => unref(url),
    () => execute(),
    { immediate: false }
  )

  return {
    // State (readonly)
    data: readonly(data),
    loading: readonly(loading),
    error: readonly(error),
    
    // Computed
    isReady,
    isError,
    
    // Methods
    execute,
    refresh,
    clear,
  }
}
```

---

## 📱 Page Component Template

### pages/UsersPage/UsersPage.vue
```vue
<template src="./UsersPage.html"></template>
<script setup lang="ts" src="./UsersPage.ts"></script>
<style scoped lang="scss" src="./UsersPage.scss"></style>
```

### pages/UsersPage/UsersPage.html
```html
<q-page class="users-page">
  <!-- Header -->
  <div class="users-page__header">
    <div class="row items-center justify-between">
      <h1 class="text-h4 text-weight-bold q-ma-none">
        Users Management
      </h1>
      
      <q-btn
        color="primary"
        icon="person_add"
        label="Add User"
        @click="showCreateDialog = true"
      />
    </div>

    <!-- Filters -->
    <div class="row q-gutter-md q-mt-md">
      <q-input
        v-model="searchQuery"
        outlined
        dense
        placeholder="Search users..."
        class="col-md-4 col-12"
      >
        <template #prepend>
          <q-icon name="search" />
        </template>
      </q-input>
      
      <q-select
        v-model="selectedRole"
        :options="roleOptions"
        outlined
        dense
        label="Filter by role"
        clearable
        class="col-md-3 col-12"
      />
    </div>
  </div>

  <!-- Content -->
  <div class="users-page__content">
    <!-- Loading State -->
    <div v-if="loading" class="flex flex-center q-pt-xl">
      <q-spinner-grid size="50px" />
    </div>
    
    <!-- Error State -->
    <q-banner v-else-if="error" type="negative" icon="error" class="q-ma-md">
      {{ error }}
      <template #action>
        <q-btn flat label="Retry" @click="refresh" />
      </template>
    </q-banner>
    
    <!-- Data Table -->
    <q-table
      v-else
      :rows="filteredUsers"
      :columns="columns"
      row-key="id"
      :pagination="pagination"
      :loading="loading"
      class="users-page__table"
      @request="onRequest"
    >
      <!-- Custom columns -->
      <template #body-cell-avatar="props">
        <q-td :props="props">
          <q-avatar>
            <img v-if="props.row.avatar" :src="props.row.avatar" />
            <q-icon v-else name="person" />
          </q-avatar>
        </q-td>
      </template>
      
      <template #body-cell-actions="props">
        <q-td :props="props">
          <q-btn-group flat>
            <q-btn
              flat
              icon="edit"
              size="sm"
              @click="editUser(props.row)"
            />
            <q-btn
              flat
              icon="delete"
              size="sm"
              color="negative"
              @click="confirmDelete(props.row)"
            />
          </q-btn-group>
        </q-td>
      </template>
    </q-table>
  </div>

  <!-- Create/Edit Dialog -->
  <user-form-dialog
    v-model="showCreateDialog"
    :user="selectedUser"
    @created="onUserCreated"
    @updated="onUserUpdated"
  />

  <!-- Delete Confirmation -->
  <q-dialog v-model="showDeleteDialog">
    <q-card>
      <q-card-section>
        <div class="text-h6">Confirm Delete</div>
        <p>Are you sure you want to delete {{ userToDelete?.firstName }} {{ userToDelete?.lastName }}?</p>
      </q-card-section>
      
      <q-card-actions align="right">
        <q-btn flat label="Cancel" @click="showDeleteDialog = false" />
        <q-btn
          color="negative"
          label="Delete"
          :loading="deleteLoading"
          @click="deleteUser"
        />
      </q-card-actions>
    </q-card>
  </q-dialog>
</q-page>
```

### pages/UsersPage/UsersPage.ts
```typescript
// Types
interface User {
  id: string
  firstName: string
  lastName: string
  email: string
  role: string
  avatar?: string
  createdAt: string
}

// Page metadata
definePageMeta({
  title: 'Users Management',
  requiresAuth: true,
  requiredRole: 'admin',
})

// Composables and stores
const userStore = useUserStore()
const { $q } = useQuasar()

// State
const searchQuery = ref('')
const selectedRole = ref<string | null>(null)
const showCreateDialog = ref(false)
const showDeleteDialog = ref(false)
const selectedUser = ref<User | null>(null)
const userToDelete = ref<User | null>(null)
const deleteLoading = ref(false)

// API
const {
  data: users,
  loading,
  error,
  refresh
} = useApi<User[]>('/api/users')

// Table configuration
const columns = [
  {
    name: 'avatar',
    label: '',
    field: 'avatar',
    align: 'center' as const,
    sortable: false,
  },
  {
    name: 'name',
    required: true,
    label: 'Name',
    field: (row: User) => `${row.firstName} ${row.lastName}`,
    align: 'left' as const,
    sortable: true,
  },
  {
    name: 'email',
    label: 'Email',
    field: 'email',
    align: 'left' as const,
    sortable: true,
  },
  {
    name: 'role',
    label: 'Role',
    field: 'role',
    align: 'left' as const,
    sortable: true,
  },
  {
    name: 'actions',
    label: 'Actions',
    field: '',
    align: 'center' as const,
    sortable: false,
  },
]

const pagination = ref({
  sortBy: 'name',
  descending: false,
  page: 1,
  rowsPerPage: 25,
})

// Computed
const roleOptions = computed(() => [
  { label: 'All Roles', value: null },
  { label: 'Admin', value: 'admin' },
  { label: 'User', value: 'user' },
  { label: 'Moderator', value: 'moderator' },
])

const filteredUsers = computed(() => {
  let filtered = users.value || []

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(user =>
      user.firstName.toLowerCase().includes(query) ||
      user.lastName.toLowerCase().includes(query) ||
      user.email.toLowerCase().includes(query)
    )
  }

  // Role filter
  if (selectedRole.value) {
    filtered = filtered.filter(user => user.role === selectedRole.value)
  }

  return filtered
})

// Methods
const onRequest = (props: any) => {
  const { page, rowsPerPage, sortBy, descending } = props.pagination
  
  pagination.value.page = page
  pagination.value.rowsPerPage = rowsPerPage
  pagination.value.sortBy = sortBy
  pagination.value.descending = descending
  
  // Implement server-side pagination/sorting if needed
}

const editUser = (user: User) => {
  selectedUser.value = user
  showCreateDialog.value = true
}

const confirmDelete = (user: User) => {
  userToDelete.value = user
  showDeleteDialog.value = true
}

const deleteUser = async () => {
  if (!userToDelete.value) return
  
  try {
    deleteLoading.value = true
    await $fetch(`/api/users/${userToDelete.value.id}`, {
      method: 'DELETE'
    })
    
    $q.notify({
      type: 'positive',
      message: 'User deleted successfully',
    })
    
    refresh()
    showDeleteDialog.value = false
    userToDelete.value = null
  } catch (error) {
    $q.notify({
      type: 'negative',
      message: 'Failed to delete user',
    })
  } finally {
    deleteLoading.value = false
  }
}

const onUserCreated = () => {
  refresh()
  showCreateDialog.value = false
  selectedUser.value = null
  
  $q.notify({
    type: 'positive',
    message: 'User created successfully',
  })
}

const onUserUpdated = () => {
  refresh()
  showCreateDialog.value = false
  selectedUser.value = null
  
  $q.notify({
    type: 'positive',
    message: 'User updated successfully',
  })
}

// Cleanup
onUnmounted(() => {
  selectedUser.value = null
  userToDelete.value = null
})
```

### pages/UsersPage/UsersPage.scss
```scss
.users-page {
  padding: 1.5rem;

  &__header {
    margin-bottom: 2rem;
    
    .q-btn {
      @apply font-medium;
    }
  }

  &__content {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  &__table {
    .q-table__top {
      padding: 1rem;
      border-bottom: 1px solid #e0e0e0;
    }
    
    .q-table thead th {
      font-weight: 600;
      background-color: #fafafa;
    }
    
    .q-table tbody tr:hover {
      background-color: #f5f5f5;
    }
  }
}

// Mobile responsive
@media (max-width: 768px) {
  .users-page {
    padding: 1rem;
    
    &__table {
      .q-table--horizontal-separator .q-td {
        border-bottom: 1px solid #e0e0e0;
      }
    }
  }
}
```