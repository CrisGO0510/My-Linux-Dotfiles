---
name: angular
description: >
  Angular 20+ complete development guide with signals-first approach, modular architecture,
  Angular Material, and modern patterns. Covers components, DI, forms, HTTP, routing, SSR,
  testing, directives, and tooling. Includes work-specific conventions (enums, module-first,
  Material integration, project structure).
  Trigger: When writing Angular code - components, signals, modules, Material UI, forms,
  HTTP, routing, SSR, testing, directives, or any Angular development task.
license: Apache-2.0
metadata:
  author: CrisGO0510
  version: "2.0"
---

## When to Use

- Creating Angular components with signals
- Building modular screen structures
- Implementing Angular Material components
- Designing generic/reusable components
- Using modern control flow (@if, @for, @switch)
- Setting up reactive state with signals
- Configuring routing, guards, resolvers
- Building forms (Signal Forms or Reactive Forms)
- HTTP data fetching (httpResource, resource, HttpClient)
- Server-side rendering and hydration
- Writing tests with Vitest
- Creating custom directives
- Project setup and CLI tooling

---

# WORK CONVENTIONS (PRIORITY)

These conventions OVERRIDE general Angular patterns. Always follow these when writing code for this project.

## No Magic Strings - Always Use Enums

**NEVER use magic strings anywhere in the code. ALL values must be defined in enums for scalability.**

See [assets/no-magic-strings-component.ts](assets/no-magic-strings-component.ts) for full example.

```typescript
// GOOD - Enums with labels for frontend text
export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
}

export enum ApiEndpoints {
  USERS = '/api/users',
  AUTH_LOGIN = '/api/auth/login',
}

export enum LocalStorageKeys {
  USER_TOKEN = 'user_token',
  THEME = 'app_theme',
}

export enum SnackbarMessages {
  USER_CREATED_SUCCESS = 'User created successfully',
  OPERATION_FAILED = 'Operation failed. Please try again.',
}

export enum ValidationMessages {
  REQUIRED = 'This field is required',
  EMAIL_INVALID = 'Please enter a valid email address',
}

// BAD - Magic strings scattered throughout code
this.http.post('/api/users', user);           // BAD
localStorage.setItem('current_user', data);   // BAD
this.snackBar.open('User saved!', 'Close');   // BAD
```

### Enum Labels Pattern

Create label mappings for all enums that display text:

```typescript
export const UserRoleLabels: Record<UserRole, string> = {
  [UserRole.ADMIN]: 'Administrator',
  [UserRole.USER]: 'User',
  [UserRole.MODERATOR]: 'Moderator',
};

export const UserStatusColors: Record<UserStatus, 'primary' | 'accent' | 'warn'> = {
  [UserStatus.ACTIVE]: 'primary',
  [UserStatus.INACTIVE]: 'accent',
  [UserStatus.SUSPENDED]: 'warn',
};
```

See [assets/user.enums.ts](assets/user.enums.ts) and [assets/app.enums.ts](assets/app.enums.ts) for complete enum examples.

## Module-First Architecture

**Default to NgModules unless explicitly requested standalone.**

```typescript
@NgModule({
  declarations: [UserListComponent, UserCardComponent, UserFormComponent],
  imports: [CommonModule, UserRoutingModule, MatCardModule, MatButtonModule],
  providers: [UserService]
})
export class UserModule {}
```

## Project Structure with Interfaces Directory

**ALWAYS organize interfaces, enums, and types in a separate `interfaces/` directory:**

```
src/app/
├── features/
│   └── users/
│       ├── components/
│       ├── pages/
│       ├── services/
│       ├── interfaces/           <-- CRITICAL
│       │   ├── user.interface.ts
│       │   ├── user-filters.interface.ts
│       │   └── user.enums.ts
│       └── user.module.ts
├── shared/
│   ├── components/
│   ├── services/
│   └── interfaces/               <-- Global types
│       ├── api-response.interface.ts
│       ├── common.interfaces.ts
│       └── app.enums.ts
└── core/
```

See [assets/user.interface.ts](assets/user.interface.ts), [assets/api-response.interface.ts](assets/api-response.interface.ts), and [assets/common.interfaces.ts](assets/common.interfaces.ts) for interface examples.

## Angular Material Integration

Always use Material components with proper theming and signals:

```typescript
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
        <button mat-raised-button color="primary" (click)="onEdit()">Edit</button>
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

## Screen Component Structure

See [assets/screen-component.ts](assets/screen-component.ts) and [assets/screen-component.html](assets/screen-component.html) for the standard screen component pattern with:
- `inject()` for DI (never constructor injection)
- Service signals converted with `toSignal`
- Local state signals
- Form controls for complex RxJS operations
- Computed values for derived state
- Proper subscription management with `Subscription` + `ngOnDestroy`

## Service Pattern

See [assets/entity.service.ts](assets/entity.service.ts) for the standard service pattern with:
- Private writable signals + public readonly signals
- Observable versions via `toObservable` for complex RxJS
- Computed values for derived state
- Async methods with proper error handling

---

# CORE PATTERNS

## Signals

Signals are Angular's reactive primitive for state management.

### signal() - Writable State

```typescript
const count = signal(0);
count.set(5);
count.update(c => c + 1);
const user = signal<User | null>(null);
```

### computed() - Derived State

```typescript
const fullName = computed(() => `${firstName()} ${lastName()}`);
const filteredItems = computed(() => {
  const query = filter().toLowerCase();
  return items().filter(item => item.name.toLowerCase().includes(query));
});
```

### linkedSignal() - Dependent State with Reset

```typescript
const options = signal(['A', 'B', 'C']);
const selected = linkedSignal(() => options()[0]);
// Resets to first option when options change
```

### effect() - Side Effects

```typescript
constructor() {
  effect(() => console.log('User changed:', this.user()));
  effect((onCleanup) => {
    const timer = setInterval(() => {}, 1000);
    onCleanup(() => clearInterval(timer));
  });
}
```

### RxJS Interop

```typescript
// Observable to Signal
users = toSignal(this.http.get<User[]>('/api/users'), { initialValue: [] });

// Signal to Observable (for RxJS operators)
results = toSignal(
  toObservable(this.query).pipe(
    debounceTime(300),
    switchMap(q => this.http.get<Result[]>(`/api/search?q=${q}`))
  ),
  { initialValue: [] }
);
```

For advanced signal patterns (resource(), Signal Store, testing), see [references/signal-patterns.md](references/signal-patterns.md).

## Components

Components are standalone by default in v20+ - do NOT set `standalone: true`. **But in this project, prefer modules (see Work Conventions).**

### Signal Inputs/Outputs

```typescript
@Component({
  selector: 'app-user-card',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    'class': 'user-card',
    '[class.active]': 'isActive()',
    '(click)': 'handleClick()',
  },
  template: `
    <h2>{{ name() }}</h2>
    @if (showEmail()) { <p>{{ email() }}</p> }
  `,
})
export class UserCard {
  name = input.required<string>();
  email = input<string>('');
  showEmail = input(false);
  isActive = input(false, { transform: booleanAttribute });
  avatarUrl = computed(() => `https://api.example.com/avatar/${this.name()}`);
  selected = output<string>();

  handleClick() { this.selected.emit(this.name()); }
}
```

### Host Bindings

Use the `host` object - do NOT use `@HostBinding`/`@HostListener`:

```typescript
host: {
  'role': 'button',
  '[class.primary]': 'variant() === "primary"',
  '[attr.aria-disabled]': 'disabled()',
  '(click)': 'onClick($event)',
  '(keydown.enter)': 'onClick($event)',
}
```

### Modern Control Flow

Use `@if`, `@for`, `@switch` - do NOT use `*ngIf`, `*ngFor`, `*ngSwitch`:

```html
@if (users().length > 0) {
  @for (user of users(); track user.id) {
    <app-user-card [user]="user" />
  }
} @else {
  <p>No users found</p>
}

@switch (status()) {
  @case ('loading') { <mat-spinner /> }
  @case ('error') { <mat-error>Error</mat-error> }
  @case ('success') { <app-content [data]="data()" /> }
}
```

### Performance

Always use `ChangeDetectionStrategy.OnPush` with signals. Always use `track` in `@for`.

For advanced patterns (content projection, view queries, dynamic components), see [references/component-patterns.md](references/component-patterns.md).

## Dependency Injection

### Using inject()

Prefer `inject()` over constructor injection:

```typescript
export class UserList {
  private http = inject(HttpClient);
  private userService = inject(UserService);
}
```

### Provider Scopes

```typescript
// Root singleton
@Injectable({ providedIn: 'root' })
export class Auth {}

// Component level (instance per component)
@Component({ providers: [EditorState] })
export class Editor {}

// Route level
{ path: 'admin', providers: [AdminService], children: [...] }
```

### Injection Tokens

```typescript
export const API_URL = new InjectionToken<string>('API_URL');
export const WINDOW = new InjectionToken<Window>('Window', {
  providedIn: 'root',
  factory: () => window,
});
```

For advanced DI patterns (multi providers, environment injectors, abstract tokens), see [references/di-patterns.md](references/di-patterns.md).

## HTTP & Data Fetching

### httpResource() - Signal-Based HTTP

```typescript
userId = signal('123');
userResource = httpResource<User>(() => `/api/users/${this.userId()}`);
// userResource.value(), .isLoading(), .error(), .reload()
```

### resource() - Generic Async

```typescript
searchResource = resource({
  params: () => ({ q: this.query() }),
  loader: async ({ params, abortSignal }) => {
    const response = await fetch(`/api/search?q=${params.q}`, { signal: abortSignal });
    return response.json();
  },
});
```

### HttpClient - Traditional

```typescript
private http = inject(HttpClient);
users = toSignal(this.http.get<User[]>('/api/users'), { initialValue: [] });
```

### Functional Interceptors

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(Auth).token();
  if (token) {
    req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
  }
  return next(req);
};

// Register in app.config.ts
provideHttpClient(withInterceptors([authInterceptor, errorInterceptor]))
```

For advanced HTTP patterns (caching, pagination, file upload), see [references/http-patterns.md](references/http-patterns.md).

## Forms

### Signal Forms (Experimental - Angular v21)

```typescript
import { form, FormField, required, email } from '@angular/forms/signals';

loginModel = signal<LoginData>({ email: '', password: '' });
loginForm = form(this.loginModel, (schemaPath) => {
  required(schemaPath.email, { message: 'Email is required' });
  email(schemaPath.email, { message: 'Enter a valid email' });
  required(schemaPath.password, { message: 'Password is required' });
});
```

For Reactive Forms (production-stable), see [references/form-patterns.md](references/form-patterns.md).
For custom FormValueControl with Material, see [references/formvalueControl-patterns.md](references/formvalueControl-patterns.md).

## Routing

### Basic Setup with Lazy Loading

```typescript
export const routes: Routes = [
  { path: '', redirectTo: '/home', pathMatch: 'full' },
  { path: 'home', component: Home },
  { path: 'admin', loadChildren: () => import('./admin/admin.routes').then(m => m.adminRoutes) },
  { path: 'settings', loadComponent: () => import('./settings.component').then(m => m.Settings) },
  { path: '**', component: NotFound },
];

// Enable signal inputs for route params
provideRouter(routes, withComponentInputBinding())
```

### Route Parameters as Signal Inputs

```typescript
// Route: users/:id
export class UserDetail {
  id = input.required<string>();
  userId = computed(() => parseInt(this.id(), 10));
}
```

### Functional Guards

```typescript
export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(Auth);
  const router = inject(Router);
  return auth.isAuthenticated() ? true : router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url },
  });
};
```

For advanced routing (nested routes, resolvers, preloading, animations), see [references/routing-patterns.md](references/routing-patterns.md).

## SSR & Hydration

### Server Routes

```typescript
export const serverRoutes: ServerRoute[] = [
  { path: '', renderMode: RenderMode.Prerender },
  { path: 'products/:id', renderMode: RenderMode.Server },
  { path: 'dashboard', renderMode: RenderMode.Client },
];
```

### Incremental Hydration

```html
@defer (hydrate on viewport) { <app-comments /> }
@defer (hydrate on interaction) { <app-chart /> }
@defer (hydrate never) { <app-static-footer /> }
```

### Browser-Only Code

```typescript
constructor() {
  afterNextRender(() => { this.initChart(); }); // SSR-safe
}
```

For advanced SSR patterns, see [references/ssr-patterns.md](references/ssr-patterns.md).

## Testing (Vitest)

### Setup

```bash
npm install -D vitest jsdom
ng test        # Run tests
ng test --watch
```

### Component Test

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('Counter', () => {
  let fixture: ComponentFixture<Counter>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [Counter] }).compileComponents();
    fixture = TestBed.createComponent(Counter);
    fixture.detectChanges();
  });

  it('should increment', () => {
    fixture.componentInstance.increment();
    expect(fixture.componentInstance.count()).toBe(1);
  });
});
```

### Mock Services

```typescript
const mockAuth = {
  user: signal<User | null>(null),
  isAuthenticated: computed(() => mockAuth.user() !== null),
  login: vi.fn(),
};

beforeEach(async () => {
  await TestBed.configureTestingModule({
    imports: [ProtectedPage],
    providers: [{ provide: AuthService, useValue: mockAuth }],
  }).compileComponents();
});
```

### Testing HTTP Resources

```typescript
providers: [provideHttpClient(), provideHttpClientTesting()]
// then: httpMock.expectOne('/api/users/1').flush(mockData);
```

For advanced testing (harnesses, router testing, forms, directives), see [references/testing-patterns.md](references/testing-patterns.md).
For Vitest migration from Jasmine, see [references/vitest-migration.md](references/vitest-migration.md).

## Directives

### Attribute Directive

```typescript
@Directive({
  selector: '[appHighlight]',
})
export class Highlight {
  private el = inject(ElementRef<HTMLElement>);
  color = input('yellow', { alias: 'appHighlight' });

  constructor() {
    effect(() => { this.el.nativeElement.style.backgroundColor = this.color(); });
  }
}
```

### Host Directives (Composition)

```typescript
@Component({
  selector: 'app-custom-button',
  hostDirectives: [
    Focusable,
    { directive: Disableable, inputs: ['disabled'] },
  ],
  template: `<ng-content />`,
})
export class CustomButton {}
```

For advanced directive patterns (portals, lazy render, DOM manipulation), see [references/directive-patterns.md](references/directive-patterns.md).

## CLI & Tooling

### Common Commands

```bash
ng new my-app --style=scss --routing
ng g c features/user-profile
ng g s services/auth
ng g d directives/highlight
ng g guard guards/auth
ng serve --port 4201 --open
ng build -c production
ng test --code-coverage
ng lint --fix
ng add @angular/material
ng update @angular/core @angular/cli
```

For advanced tooling (custom schematics, build optimization, CI/CD), see [references/tooling-patterns.md](references/tooling-patterns.md).

## Assets

- [assets/screen-component.ts](assets/screen-component.ts) - Standard screen component
- [assets/screen-component.html](assets/screen-component.html) - Screen component template
- [assets/entity.service.ts](assets/entity.service.ts) - Standard service pattern
- [assets/generic-card.component.ts](assets/generic-card.component.ts) - Generic card component
- [assets/user.interface.ts](assets/user.interface.ts) - User interface example
- [assets/user.enums.ts](assets/user.enums.ts) - User enums with labels
- [assets/app.enums.ts](assets/app.enums.ts) - Global app enums
- [assets/api-response.interface.ts](assets/api-response.interface.ts) - API response interface
- [assets/common.interfaces.ts](assets/common.interfaces.ts) - Common shared interfaces
- [assets/no-magic-strings-component.ts](assets/no-magic-strings-component.ts) - No magic strings example
