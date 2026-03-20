---
name: angular21
description: >
  Angular 21 modern patterns with signals-first approach, modular architecture, Angular Material, and optimized generic components.
  Trigger: When writing Angular 21 code - signals, components, modules, Material UI, control flow.
license: Apache-2.0
metadata:
  author: CrisGO0510
  version: "1.0"
---

## When to Use

- Creating Angular 21 components with signals
- Building modular screen structures (default approach)
- Implementing Angular Material components
- Designing generic/reusable components
- Using modern control flow (@if, @for, @switch)
- Setting up reactive state with signals
- Optimizing component performance

## Critical Patterns

### 🚫 No Magic Strings - Always Use Enums

**NEVER use magic strings anywhere in the code. ALL values must be defined in enums for scalability:**

```typescript
// ✅ GOOD - Enums with labels for frontend text
export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
  PENDING_VERIFICATION = 'pending_verification'
}

export enum ApiEndpoints {
  USERS = '/api/users',
  USERS_SEARCH = '/api/users/search',
  USERS_BULK_DELETE = '/api/users/bulk-delete',
  AUTH_LOGIN = '/api/auth/login',
  AUTH_LOGOUT = '/api/auth/logout'
}

export enum LocalStorageKeys {
  USER_TOKEN = 'user_token',
  USER_PREFERENCES = 'user_preferences',
  THEME = 'app_theme',
  LANGUAGE = 'app_language'
}

export enum ComponentClasses {
  CARD_ACTIVE = 'card-active',
  CARD_INACTIVE = 'card-inactive',
  LOADING_OVERLAY = 'loading-overlay',
  ERROR_STATE = 'error-state'
}

export enum SnackbarMessages {
  USER_CREATED_SUCCESS = 'User created successfully',
  USER_UPDATED_SUCCESS = 'User updated successfully',
  USER_DELETED_SUCCESS = 'User deleted successfully',
  OPERATION_FAILED = 'Operation failed. Please try again.',
  LOADING_ERROR = 'Failed to load data'
}

export enum FormValidationMessages {
  REQUIRED = 'This field is required',
  EMAIL_INVALID = 'Please enter a valid email address',
  PASSWORD_TOO_SHORT = 'Password must be at least 8 characters',
  PASSWORDS_DONT_MATCH = 'Passwords do not match'
}

// ❌ AVOID - Magic strings scattered throughout code
@Component({
  template: `
    @if (user.status === 'active') { // BAD - magic string
      <span class="status-active">Active</span> // BAD - magic class
    }
  `
})
export class BadComponent {
  saveUser() {
    this.http.post('/api/users', user).subscribe(); // BAD - magic URL
    localStorage.setItem('current_user', data); // BAD - magic key
    this.snackBar.open('User saved!', 'Close'); // BAD - magic text
  }
}

// ✅ GOOD - Using enums everywhere
@Component({
  template: `
    @if (user.status === UserStatus.ACTIVE) {
      <span [class]="ComponentClasses.STATUS_ACTIVE">
        {{ getStatusLabel(user.status) }}
      </span>
    }
  `
})
export class GoodComponent {
  UserStatus = UserStatus; // Expose enum to template
  ComponentClasses = ComponentClasses; // Expose enum to template
  
  saveUser() {
    this.http.post(ApiEndpoints.USERS, user).subscribe();
    localStorage.setItem(LocalStorageKeys.CURRENT_USER, data);
    this.snackBar.open(SnackbarMessages.USER_CREATED_SUCCESS, 'Close');
  }
  
  getStatusLabel(status: UserStatus): string {
    return UserStatusLabels[status];
  }
}
```

### 🏷️ Enum Labels Pattern

**Create label mappings for all enums that display text:**

```typescript
// users/interfaces/user.enums.ts
export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator',
  GUEST = 'guest'
}

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive', 
  SUSPENDED = 'suspended',
  PENDING_VERIFICATION = 'pending_verification'
}

export enum UserActionType {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  SUSPEND = 'suspend',
  ACTIVATE = 'activate'
}

// Label mappings for frontend display
export const UserRoleLabels: Record<UserRole, string> = {
  [UserRole.ADMIN]: 'Administrator',
  [UserRole.USER]: 'User',
  [UserRole.MODERATOR]: 'Moderator',
  [UserRole.GUEST]: 'Guest'
};

export const UserStatusLabels: Record<UserStatus, string> = {
  [UserStatus.ACTIVE]: 'Active',
  [UserStatus.INACTIVE]: 'Inactive',
  [UserStatus.SUSPENDED]: 'Suspended',
  [UserStatus.PENDING_VERIFICATION]: 'Pending Verification'
};

export const UserActionLabels: Record<UserActionType, string> = {
  [UserActionType.CREATE]: 'Create User',
  [UserActionType.UPDATE]: 'Update User',
  [UserActionType.DELETE]: 'Delete User',
  [UserActionType.SUSPEND]: 'Suspend User',
  [UserActionType.ACTIVATE]: 'Activate User'
};

// Colors and styling mappings
export const UserStatusColors: Record<UserStatus, 'primary' | 'accent' | 'warn'> = {
  [UserStatus.ACTIVE]: 'primary',
  [UserStatus.INACTIVE]: 'accent',
  [UserStatus.SUSPENDED]: 'warn',
  [UserStatus.PENDING_VERIFICATION]: 'accent'
};

export const UserRoleIcons: Record<UserRole, string> = {
  [UserRole.ADMIN]: 'admin_panel_settings',
  [UserRole.USER]: 'person',
  [UserRole.MODERATOR]: 'verified_user',
  [UserRole.GUEST]: 'person_outline'
};
```

### 🌐 Global App Enums

**Create shared enums for application-wide constants:**

```typescript
// shared/interfaces/app.enums.ts
export enum AppRoutes {
  HOME = '/',
  USERS = '/users',
  USER_CREATE = '/users/create',
  USER_EDIT = '/users/edit',
  SETTINGS = '/settings',
  PROFILE = '/profile',
  LOGIN = '/auth/login',
  LOGOUT = '/auth/logout'
}

export enum ApiEndpoints {
  BASE_URL = '/api',
  USERS = '/api/users',
  USERS_SEARCH = '/api/users/search',
  USERS_BULK_DELETE = '/api/users/bulk-delete',
  AUTH_LOGIN = '/api/auth/login',
  AUTH_LOGOUT = '/api/auth/logout',
  AUTH_REFRESH = '/api/auth/refresh',
  UPLOAD_FILE = '/api/files/upload'
}

export enum LocalStorageKeys {
  ACCESS_TOKEN = 'access_token',
  REFRESH_TOKEN = 'refresh_token',
  USER_PREFERENCES = 'user_preferences',
  THEME = 'app_theme',
  LANGUAGE = 'app_language',
  SIDEBAR_STATE = 'sidebar_state'
}

export enum SessionStorageKeys {
  FORM_DATA = 'temp_form_data',
  SEARCH_FILTERS = 'search_filters',
  CURRENT_PAGE = 'current_page'
}

export enum HttpStatusCodes {
  OK = 200,
  CREATED = 201,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  INTERNAL_SERVER_ERROR = 500
}

export enum LoadingStates {
  IDLE = 'idle',
  LOADING = 'loading',
  SUCCESS = 'success',
  ERROR = 'error'
}

export enum ViewModes {
  GRID = 'grid',
  LIST = 'list',
  TABLE = 'table',
  CARD = 'card'
}

export enum SortDirections {
  ASC = 'asc',
  DESC = 'desc'
}

export enum ComponentStates {
  COLLAPSED = 'collapsed',
  EXPANDED = 'expanded',
  LOADING = 'loading',
  DISABLED = 'disabled'
}

export enum NotificationTypes {
  SUCCESS = 'success',
  ERROR = 'error',
  WARNING = 'warning',
  INFO = 'info'
}

// CSS Classes as enums
export enum CssClasses {
  CARD_ACTIVE = 'card-active',
  CARD_INACTIVE = 'card-inactive',
  LOADING_OVERLAY = 'loading-overlay',
  ERROR_STATE = 'error-state',
  SUCCESS_STATE = 'success-state',
  HIDDEN = 'hidden',
  VISIBLE = 'visible'
}

// Form field names as enums
export enum UserFormFields {
  FIRST_NAME = 'firstName',
  LAST_NAME = 'lastName',
  EMAIL = 'email',
  PHONE = 'phone',
  ROLE = 'role',
  ACTIVE = 'active'
}

// Validation messages
export enum ValidationMessages {
  REQUIRED = 'This field is required',
  EMAIL_INVALID = 'Please enter a valid email address',
  PHONE_INVALID = 'Please enter a valid phone number',
  PASSWORD_TOO_SHORT = 'Password must be at least 8 characters',
  PASSWORDS_DONT_MATCH = 'Passwords do not match',
  NAME_TOO_SHORT = 'Name must be at least 2 characters',
  INVALID_CHARACTERS = 'Invalid characters detected'
}

// Success/Error messages
export enum Messages {
  USER_CREATED_SUCCESS = 'User created successfully',
  USER_UPDATED_SUCCESS = 'User updated successfully',
  USER_DELETED_SUCCESS = 'User deleted successfully',
  OPERATION_FAILED = 'Operation failed. Please try again.',
  LOADING_ERROR = 'Failed to load data',
  UNAUTHORIZED_ACCESS = 'You do not have permission to perform this action',
  SESSION_EXPIRED = 'Your session has expired. Please log in again.',
  NETWORK_ERROR = 'Network error. Please check your connection.'
}
```

**ALWAYS prefer signals over traditional reactive forms:**

```typescript
// ✅ GOOD - Signals-first with inject()
export class UserComponent {
  // Use inject() instead of constructor injection for lazy loading
  private userService = inject(UserService);
  
  // State signals
  user = signal<User | null>(null);
  loading = signal(false);
  error = signal<string | null>(null);
  
  // Computed signals
  fullName = computed(() => {
    const u = this.user();
    return u ? `${u.firstName} ${u.lastName}` : '';
  });
  
  // Effects for side effects
  constructor() {
    effect(() => {
      console.log('User changed:', this.user());
    });
  }
}

// ❌ AVOID - Constructor injection loads service immediately
export class UserComponent {
  constructor(private userService: UserService) {} // Loads on component creation
  
  user$ = new BehaviorSubject<User | null>(null);
  loading$ = new BehaviorSubject(false);
}
```

### 📡 Observable to Signal Conversion

**Use toSignal() for reactive data or manual subscription management:**

```typescript
// ✅ GOOD - toSignal() for simple reactive data
export class UserComponent {
  private userService = inject(UserService);
  private route = inject(ActivatedRoute);
  
  // Convert observables to signals
  users = toSignal(this.userService.users$, { initialValue: [] });
  currentUserId = toSignal(this.route.params.pipe(map(p => p['id'])), { initialValue: null });
  
  // Computed from signals
  currentUser = computed(() => {
    const id = this.currentUserId();
    return this.users().find(u => u.id === id) ?? null;
  });
}

// ✅ GOOD - Manual subscription for complex RxJS logic
export class UserComponent implements OnDestroy {
  private userService = inject(UserService);
  private subscription = new Subscription();
  
  // Local signals for state
  searchResults = signal<User[]>([]);
  loading = signal(false);
  
  ngOnInit(): void {
    // Complex RxJS logic that can't be easily converted to signals
    this.subscription.add(
      this.searchControl.valueChanges.pipe(
        debounceTime(300),
        distinctUntilChanged(),
        switchMap(term => 
          this.userService.searchUsers(term).pipe(
            tap(() => this.loading.set(true)),
            catchError(error => {
              console.error('Search error:', error);
              return of([]);
            }),
            finalize(() => this.loading.set(false))
          )
        )
      ).subscribe(results => this.searchResults.set(results))
    );
  }
  
  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
}

// ❌ AVOID - Memory leaks without proper cleanup
export class UserComponent {
  ngOnInit(): void {
    this.userService.users$.subscribe(users => {
      // No cleanup = memory leak
      this.users = users;
    });
  }
}
```

### 📦 Module-First Architecture

**Default to modules unless explicitly requested standalone:**

```typescript
// ✅ GOOD - Module structure
@NgModule({
  declarations: [
    UserListComponent,
    UserCardComponent,
    UserFormComponent
  ],
  imports: [
    CommonModule,
    UserRoutingModule,
    MatCardModule,
    MatButtonModule,
    MatInputModule
  ],
  providers: [UserService]
})
export class UserModule {}
```

### 📁 Project Structure with Interfaces Directory

**ALWAYS organize interfaces, enums, and types in separate directory:**

```
src/
├── app/
│   ├── features/
│   │   └── users/
│   │       ├── components/
│   │       ├── pages/
│   │       ├── services/
│   │       ├── interfaces/           👈 CRITICAL - All types here
│   │       │   ├── user.interface.ts
│   │       │   ├── user-filters.interface.ts
│   │       │   └── user.enums.ts
│   │       └── user.module.ts
│   ├── shared/
│   │   ├── components/
│   │   ├── services/
│   │   └── interfaces/               👈 CRITICAL - Global types here
│   │       ├── api-response.interface.ts
│   │       ├── common.interfaces.ts
│   │       └── app.enums.ts
│   └── core/
└── ...
```

```typescript
// ✅ GOOD - Interfaces in dedicated directory
// users/interfaces/user.interface.ts
export interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  active: boolean;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserDto {
  firstName: string;
  lastName: string;
  email: string;
  role: UserRole;
}

export interface UpdateUserDto {
  firstName?: string;
  lastName?: string;
  email?: string;
  role?: UserRole;
  active?: boolean;
}

// users/interfaces/user.enums.ts
export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  MODERATOR = 'moderator'
}

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended'
}

// users/interfaces/user-filters.interface.ts
export interface UserFilters {
  role?: UserRole;
  status?: UserStatus;
  search?: string;
  dateFrom?: Date;
  dateTo?: Date;
}

export type UserSortField = 'firstName' | 'lastName' | 'email' | 'createdAt';
export type SortDirection = 'asc' | 'desc';
```

### 🎨 Angular Material Integration

**Always use Material components with proper theming:**

```typescript
// ✅ GOOD - Material with signals
@Component({
  template: `
    <mat-card class="user-card">
      <mat-card-header>
        <mat-card-title>{{ fullName() }}</mat-card-title>
      </mat-card-header>
      <mat-card-content>
        @if (loading()) {
          <mat-spinner diameter="40"></mat-spinner>
        } @else if (error()) {
          <mat-error>{{ error() }}</mat-error>
        } @else {
          <p>{{ user()?.email }}</p>
        }
      </mat-card-content>
      <mat-card-actions>
        <button mat-raised-button color="primary" (click)="onEdit()">
          Edit
        </button>
      </mat-card-actions>
    </mat-card>
  `
})
export class UserCardComponent {
  user = input.required<User>();
  loading = input(false);
  error = input<string | null>(null);
  
  fullName = computed(() => {
    const u = this.user();
    return `${u.firstName} ${u.lastName}`;
  });
}
```

### 🔄 Modern Control Flow

**Use new control flow syntax (@if, @for, @switch):**

```typescript
@Component({
  template: `
    <!-- ✅ GOOD - Modern control flow -->
    @if (users().length > 0) {
      <div class="users-grid">
        @for (user of users(); track user.id) {
          <app-user-card [user]="user" />
        }
      </div>
    } @else {
      <mat-card class="empty-state">
        <mat-card-content>
          <p>No users found</p>
        </mat-card-content>
      </mat-card>
    }
    
    @switch (status()) {
      @case ('loading') {
        <mat-spinner></mat-spinner>
      }
      @case ('error') {
        <mat-error>Something went wrong</mat-error>
      }
      @case ('success') {
        <app-user-list [users]="users()" />
      }
    }
  `
})
export class UsersComponent {
  users = signal<User[]>([]);
  status = signal<'loading' | 'error' | 'success'>('loading');
}
```

### 🧩 Generic Components Pattern

**Create reusable, type-safe generic components:**

```typescript
// ✅ GOOD - Generic table component
@Component({
  selector: 'app-data-table',
  template: `
    <mat-table [dataSource]="dataSource()" class="mat-elevation-z8">
      @for (column of columns(); track column.key) {
        <ng-container [matColumnDef]="column.key">
          <mat-header-cell *matHeaderCellDef>
            {{ column.header }}
          </mat-header-cell>
          <mat-cell *matCellDef="let element">
            @if (column.template) {
              <ng-container 
                *ngTemplateOutlet="column.template; context: { $implicit: element }"
              ></ng-container>
            } @else {
              {{ getValueByPath(element, column.key) }}
            }
          </mat-cell>
        </ng-container>
      }
      <mat-header-row *matHeaderRowDef="displayedColumns()"></mat-header-row>
      <mat-row *matRowDef="let row; columns: displayedColumns()"></mat-row>
    </mat-table>
  `
})
export class DataTableComponent<T = any> {
  data = input.required<T[]>();
  columns = input.required<TableColumn<T>[]>();
  loading = input(false);
  
  dataSource = computed(() => this.data());
  displayedColumns = computed(() => this.columns().map(col => col.key));
  
  getValueByPath(obj: T, path: string): any {
    return path.split('.').reduce((o, p) => o?.[p], obj);
  }
}

interface TableColumn<T> {
  key: string;
  header: string;
  template?: TemplateRef<{ $implicit: T }>;
}
```

### ⚡ Performance Optimizations

**Always use OnPush with signals:**

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (data(); as items) {
      @for (item of items; track item.id) {
        <app-item [item]="item" />
      }
    }
  `
})
export class OptimizedListComponent {
  data = input.required<Item[]>();
  
  // Memoized computed values
  itemCount = computed(() => this.data().length);
  hasItems = computed(() => this.data().length > 0);
}
```

## Code Examples

### Service with Signals

```typescript
@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);
  
  private _users = signal<User[]>([]);
  private _loading = signal(false);
  private _error = signal<string | null>(null);
  
  // Public readonly signals
  readonly users = this._users.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();
  
  // Observable versions for complex RxJS operations
  readonly users$ = toObservable(this.users);
  readonly loading$ = toObservable(this.loading);
  readonly error$ = toObservable(this.error);
  
  // Computed values
  readonly activeUsers = computed(() => 
    this._users().filter(user => user.active)
  );
  
  async loadUsers(): Promise<void> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const users = await this.http.get<User[]>('/api/users').toPromise();
      this._users.set(users || []);
    } catch (error) {
      this._error.set('Failed to load users');
    } finally {
      this._loading.set(false);
    }
  }
  
  // Method that returns observable for complex RxJS operations
  searchUsers(term: string): Observable<User[]> {
    return this.http.get<User[]>(`/api/users/search`, {
      params: { q: term }
    }).pipe(
      catchError(error => {
        console.error('Search error:', error);
        return of([]);
      })
    );
  }
  
  addUser(user: User): void {
    this._users.update(users => [...users, user]);
  }
  
  updateUser(id: string, updates: Partial<User>): void {
    this._users.update(users =>
      users.map(user => 
        user.id === id ? { ...user, ...updates } : user
      )
    );
  }
}
```

### Screen Component Structure

```typescript
// user-list.component.ts
@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  styleUrl: './user-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserListComponent implements OnDestroy {
  // Use inject() for lazy loading
  private userService = inject(UserService);
  private router = inject(Router);
  private snackBar = inject(MatSnackBar);
  private subscription = new Subscription();
  
  // Service signals converted with toSignal
  users = toSignal(this.userService.users$, { initialValue: [] });
  loading = toSignal(this.userService.loading$, { initialValue: false });
  error = toSignal(this.userService.error$, { initialValue: null });
  
  // Local state signals
  selectedUser = signal<User | null>(null);
  searchTerm = signal('');
  viewMode = signal<'grid' | 'list'>('grid');
  
  // Form controls for complex RxJS operations
  searchControl = new FormControl('');
  filterControl = new FormControl(null);
  
  // Computed values
  filteredUsers = computed(() => {
    const term = this.searchTerm().toLowerCase();
    const users = this.users();
    
    if (!term) return users;
    
    return users.filter(user => 
      user.firstName.toLowerCase().includes(term) ||
      user.lastName.toLowerCase().includes(term) ||
      user.email.toLowerCase().includes(term)
    );
  });
  
  hasResults = computed(() => this.filteredUsers().length > 0);
  
  ngOnInit(): void {
    this.loadUsers();
    this.setupSearchSubscription();
    this.setupFilterSubscription();
  }
  
  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
  
  // Actions
  onSearch(term: string): void {
    this.searchTerm.set(term);
  }
  
  onSelectUser(user: User): void {
    this.selectedUser.set(user);
  }
  
  onEditUser(user: User): void {
    this.router.navigate(['/users', user.id, 'edit']);
  }
  
  onDeleteUser(user: User): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      data: {
        title: 'Delete User',
        message: `Are you sure you want to delete ${user.firstName} ${user.lastName}?`,
        type: 'danger'
      }
    });
    
    this.subscription.add(
      dialogRef.afterClosed().subscribe(confirmed => {
        if (confirmed) {
          this.deleteUser(user.id);
        }
      })
    );
  }
  
  private loadUsers(): void {
    this.userService.loadUsers();
  }
  
  private setupSearchSubscription(): void {
    this.subscription.add(
      this.searchControl.valueChanges.pipe(
        debounceTime(300),
        distinctUntilChanged(),
        tap(term => this.searchTerm.set(term || ''))
      ).subscribe()
    );
  }
  
  private setupFilterSubscription(): void {
    this.subscription.add(
      this.filterControl.valueChanges.pipe(
        distinctUntilChanged(),
        switchMap(filter => 
          this.userService.loadUsersWithFilter(filter).pipe(
            catchError(error => {
              this.snackBar.open('Failed to apply filter', 'Close', { duration: 3000 });
              return of([]);
            })
          )
        )
      ).subscribe()
    );
  }
  
  private async deleteUser(id: string): Promise<void> {
    const success = await this.userService.deleteUser(id);
    if (success) {
      this.snackBar.open('User deleted successfully', 'Close', { duration: 3000 });
    } else {
      this.snackBar.open('Failed to delete user', 'Close', { duration: 3000 });
    }
  }
}
```

## Commands

```bash
# Create new module with proper structure
ng generate module features/users --routing
ng generate component features/users/pages/user-list
ng generate component features/users/components/user-card
ng generate service features/users/services/user

# Create interfaces directory and files
mkdir src/app/features/users/interfaces
touch src/app/features/users/interfaces/user.interface.ts
touch src/app/features/users/interfaces/user.enums.ts
touch src/app/features/users/interfaces/user-filters.interface.ts

# Create shared interfaces directory
mkdir src/app/shared/interfaces
touch src/app/shared/interfaces/api-response.interface.ts
touch src/app/shared/interfaces/common.interfaces.ts
touch src/app/shared/interfaces/app.enums.ts

# Generate generic components
ng generate component shared/components/data-table
ng generate component shared/components/confirm-dialog
ng generate component shared/components/loading-spinner

# Add Angular Material
ng add @angular/material
ng generate @angular/material:nav shell
ng generate @angular/material:dashboard dashboard

# Build and serve
ng build --configuration production
ng serve --open
ng test --watch=false
ng e2e

# Code quality
ng lint
ng lint --fix
npm run format
```

## Resources

- **Templates**: See [assets/](assets/) for component templates
- **Material Components**: Always use Material Design patterns
- **Signals Guide**: Prefer signals over observables for local state
- **Performance**: OnPush + signals = optimal performance
