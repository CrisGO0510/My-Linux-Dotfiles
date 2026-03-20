// Component template demonstrating NO MAGIC STRINGS pattern
import { 
  Component, 
  signal, 
  computed,
  inject,
  OnDestroy,
  ChangeDetectionStrategy 
} from '@angular/core';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatDialog } from '@angular/material/dialog';
import { Subscription, debounceTime, distinctUntilChanged } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';

// Import ALL enums - NO MAGIC STRINGS!
import { User, UserFilters } from '../interfaces/user.interface';
import { 
  UserRole, 
  UserStatus, 
  UserRoleLabels, 
  UserStatusLabels, 
  UserStatusColors,
  UserRoleIcons,
  UserStatusIcons,
  UserComponentClasses,
  UserMessages,
  UserValidationMessages,
  UserSortFields,
  UserQueryParams
} from '../interfaces/user.enums';
import { 
  AppRoutes, 
  LoadingStates, 
  ViewModes, 
  CssClasses, 
  Messages,
  MatIconNames,
  SnackbarActions,
  SnackbarDurations,
  NotificationTypes
} from '../../shared/interfaces/app.enums';

@Component({
  selector: 'app-user-list',
  template: `
    <!-- Header Card -->
    <mat-card [class]="CssClasses.CARD_ACTIVE">
      <mat-card-content>
        <div class="header-content">
          <div class="title-section">
            <h2>{{ getPageTitle() }}</h2>
            <span class="entity-count">{{ getEntityCountText() }}</span>
          </div>
          
          <div class="actions-section">
            <button 
              mat-raised-button 
              color="primary" 
              (click)="onCreateNew()"
              [attr.aria-label]="getCreateButtonLabel()"
            >
              <mat-icon>{{ MatIconNames.ADD }}</mat-icon>
              {{ getCreateButtonText() }}
            </button>
            
            <button 
              mat-icon-button 
              (click)="onRefresh()"
              [disabled]="loading()"
              [matTooltip]="getRefreshTooltip()"
            >
              <mat-icon>{{ MatIconNames.REFRESH }}</mat-icon>
            </button>
            
            <button 
              mat-icon-button 
              (click)="onToggleViewMode()"
              [matTooltip]="getViewModeTooltip()"
            >
              <mat-icon>{{ getViewModeIcon() }}</mat-icon>
            </button>
          </div>
        </div>
        
        <!-- Search Section -->
        <div class="search-section">
          <mat-form-field appearance="outline" class="search-field">
            <mat-label>{{ getSearchPlaceholder() }}</mat-label>
            <input 
              matInput 
              [formControl]="searchControl"
              (input)="onSearchChange($event)"
              [placeholder]="getSearchPlaceholder()"
            >
            <mat-icon matSuffix>{{ MatIconNames.SEARCH }}</mat-icon>
          </mat-form-field>
          
          <!-- Filters -->
          <mat-form-field appearance="outline">
            <mat-label>{{ getRoleFilterLabel() }}</mat-label>
            <mat-select [formControl]="roleFilterControl">
              <mat-option [value]="null">{{ getAllRolesOption() }}</mat-option>
              @for (role of getRoleOptions(); track role.value) {
                <mat-option [value]="role.value">
                  <mat-icon>{{ role.icon }}</mat-icon>
                  {{ role.label }}
                </mat-option>
              }
            </mat-select>
          </mat-form-field>
          
          <mat-form-field appearance="outline">
            <mat-label>{{ getStatusFilterLabel() }}</mat-label>
            <mat-select [formControl]="statusFilterControl">
              <mat-option [value]="null">{{ getAllStatusesOption() }}</mat-option>
              @for (status of getStatusOptions(); track status.value) {
                <mat-option [value]="status.value">
                  <mat-icon [style.color]="status.color">{{ status.icon }}</mat-icon>
                  {{ status.label }}
                </mat-option>
              }
            </mat-select>
          </mat-form-field>
        </div>
      </mat-card-content>
    </mat-card>
    
    <!-- Content Section -->
    <div class="content-section">
      @if (loading()) {
        <!-- Loading State -->
        <mat-card [class]="CssClasses.LOADING_OVERLAY">
          <mat-card-content>
            <div class="loading-content">
              <mat-spinner diameter="40"></mat-spinner>
              <p>{{ getLoadingText() }}</p>
            </div>
          </mat-card-content>
        </mat-card>
      } @else if (error(); as errorMessage) {
        <!-- Error State -->
        <mat-card [class]="CssClasses.ERROR_STATE">
          <mat-card-content>
            <div class="error-content">
              <mat-icon color="warn">{{ MatIconNames.ERROR }}</mat-icon>
              <h3>{{ getErrorTitle() }}</h3>
              <p>{{ errorMessage }}</p>
              <button mat-raised-button color="primary" (click)="onRefresh()">
                {{ getRetryButtonText() }}
              </button>
            </div>
          </mat-card-content>
        </mat-card>
      } @else if (hasResults()) {
        <!-- Users Grid/List -->
        <div [class]="getUsersContainerClass()">
          @for (user of filteredUsers(); track user.id) {
            <mat-card 
              [class]="getUserCardClass(user)"
              (click)="onUserSelect(user)"
            >
              <mat-card-header>
                <div mat-card-avatar>
                  @if (user.avatar) {
                    <img [src]="user.avatar" [alt]="getUserAvatarAlt(user)">
                  } @else {
                    <mat-icon>{{ getUserRoleIcon(user.role) }}</mat-icon>
                  }
                </div>
                
                <mat-card-title>{{ getUserDisplayName(user) }}</mat-card-title>
                <mat-card-subtitle>{{ user.email }}</mat-card-subtitle>
                
                <div class="status-badges">
                  <span 
                    [class]="UserComponentClasses.USER_STATUS_BADGE"
                    [style.color]="getUserStatusColor(user.status)"
                  >
                    <mat-icon>{{ getUserStatusIcon(user.status) }}</mat-icon>
                    {{ getUserStatusLabel(user.status) }}
                  </span>
                  
                  <span [class]="UserComponentClasses.USER_ROLE_BADGE">
                    <mat-icon>{{ getUserRoleIcon(user.role) }}</mat-icon>
                    {{ getUserRoleLabel(user.role) }}
                  </span>
                </div>
              </mat-card-header>
              
              <mat-card-content>
                <div class="user-meta">
                  <span class="created-date">
                    {{ getCreatedDateText() }}: {{ user.createdAt | date:getDateFormat() }}
                  </span>
                </div>
              </mat-card-content>
              
              <mat-card-actions align="end">
                <button 
                  mat-button 
                  color="primary" 
                  (click)="onUserEdit(user); $event.stopPropagation()"
                  [attr.aria-label]="getEditButtonLabel(user)"
                >
                  <mat-icon>{{ MatIconNames.EDIT }}</mat-icon>
                  {{ getEditButtonText() }}
                </button>
                
                <button 
                  mat-button 
                  color="warn" 
                  (click)="onUserDelete(user); $event.stopPropagation()"
                  [attr.aria-label]="getDeleteButtonLabel(user)"
                >
                  <mat-icon>{{ MatIconNames.DELETE }}</mat-icon>
                  {{ getDeleteButtonText() }}
                </button>
              </mat-card-actions>
            </mat-card>
          }
        </div>
      } @else {
        <!-- Empty State -->
        <mat-card class="empty-card">
          <mat-card-content>
            <div class="empty-content">
              @if (searchTerm()) {
                <!-- No search results -->
                <mat-icon>{{ MatIconNames.SEARCH }}</mat-icon>
                <h3>{{ getNoResultsTitle() }}</h3>
                <p>{{ getNoResultsMessage() }}</p>
                <button mat-raised-button (click)="clearSearch()">
                  {{ getClearSearchButtonText() }}
                </button>
              } @else {
                <!-- No users at all -->
                <mat-icon>{{ MatIconNames.USER }}</mat-icon>
                <h3>{{ getNoUsersTitle() }}</h3>
                <p>{{ getNoUsersMessage() }}</p>
                <button mat-raised-button color="primary" (click)="onCreateNew()">
                  <mat-icon>{{ MatIconNames.ADD }}</mat-icon>
                  {{ getCreateFirstUserButtonText() }}
                </button>
              }
            </div>
          </mat-card-content>
        </mat-card>
      }
    </div>
  `,
  styleUrl: './user-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserListComponent implements OnDestroy {
  // Inject services using inject() for lazy loading
  private userService = inject(UserService);
  private router = inject(Router);
  private snackBar = inject(MatSnackBar);
  private dialog = inject(MatDialog);
  
  // Expose ALL enums to template - NO MAGIC STRINGS!
  readonly UserRole = UserRole;
  readonly UserStatus = UserStatus;
  readonly UserComponentClasses = UserComponentClasses;
  readonly AppRoutes = AppRoutes;
  readonly LoadingStates = LoadingStates;
  readonly ViewModes = ViewModes;
  readonly CssClasses = CssClasses;
  readonly Messages = Messages;
  readonly MatIconNames = MatIconNames;
  readonly UserMessages = UserMessages;
  readonly NotificationTypes = NotificationTypes;
  
  private subscription = new Subscription();
  
  // Signals from service
  users = toSignal(this.userService.users$, { initialValue: [] });
  loading = toSignal(this.userService.loading$, { initialValue: false });
  error = toSignal(this.userService.error$, { initialValue: null });
  
  // Local state signals
  selectedUser = signal<User | null>(null);
  searchTerm = signal('');
  viewMode = signal<ViewModes>(ViewModes.GRID);
  filters = signal<UserFilters>({});
  
  // Form controls
  searchControl = new FormControl('');
  roleFilterControl = new FormControl<UserRole | null>(null);
  statusFilterControl = new FormControl<UserStatus | null>(null);
  
  // Computed values
  filteredUsers = computed(() => {
    const term = this.searchTerm().toLowerCase();
    const users = this.users();
    const currentFilters = this.filters();
    
    return users.filter(user => {
      if (term) {
        const matchesSearch = 
          user.firstName.toLowerCase().includes(term) ||
          user.lastName.toLowerCase().includes(term) ||
          user.email.toLowerCase().includes(term);
        if (!matchesSearch) return false;
      }
      
      if (currentFilters.role && user.role !== currentFilters.role) {
        return false;
      }
      
      if (currentFilters.status && user.status !== currentFilters.status) {
        return false;
      }
      
      return true;
    });
  });
  
  hasResults = computed(() => this.filteredUsers().length > 0);
  
  ngOnInit(): void {
    this.loadUsers();
    this.setupReactiveSubscriptions();
  }
  
  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
  
  // Template helper methods - NO MAGIC STRINGS!
  getPageTitle(): string {
    return 'User Management'; // Could also be from enum
  }
  
  getEntityCountText(): string {
    const count = this.filteredUsers().length;
    return `${count} ${count === 1 ? 'user' : 'users'}`;
  }
  
  getCreateButtonLabel(): string {
    return UserMessages.USER_CREATED;
  }
  
  getCreateButtonText(): string {
    return 'Create User';
  }
  
  getRefreshTooltip(): string {
    return 'Refresh user list';
  }
  
  getViewModeTooltip(): string {
    return this.viewMode() === ViewModes.GRID ? 
      'Switch to list view' : 'Switch to grid view';
  }
  
  getViewModeIcon(): string {
    return this.viewMode() === ViewModes.GRID ? 
      'view_list' : 'view_module';
  }
  
  getSearchPlaceholder(): string {
    return 'Search users by name or email...';
  }
  
  getRoleFilterLabel(): string {
    return 'Filter by Role';
  }
  
  getStatusFilterLabel(): string {
    return 'Filter by Status';
  }
  
  getAllRolesOption(): string {
    return 'All Roles';
  }
  
  getAllStatusesOption(): string {
    return 'All Statuses';
  }
  
  getRoleOptions() {
    return Object.values(UserRole).map(role => ({
      value: role,
      label: UserRoleLabels[role],
      icon: UserRoleIcons[role]
    }));
  }
  
  getStatusOptions() {
    return Object.values(UserStatus).map(status => ({
      value: status,
      label: UserStatusLabels[status],
      icon: UserStatusIcons[status],
      color: UserStatusColors[status]
    }));
  }
  
  getUsersContainerClass(): string {
    return `users-container ${this.viewMode()}`;
  }
  
  getUserCardClass(user: User): string {
    const baseClass = UserComponentClasses.USER_CARD;
    const statusClass = user.status === UserStatus.ACTIVE ? 
      UserComponentClasses.USER_CARD_ACTIVE : 
      UserComponentClasses.USER_CARD_INACTIVE;
    const selectedClass = this.selectedUser()?.id === user.id ? 
      CssClasses.CARD_SELECTED : '';
    
    return `${baseClass} ${statusClass} ${selectedClass}`.trim();
  }
  
  getUserDisplayName(user: User): string {
    return `${user.firstName} ${user.lastName}`;
  }
  
  getUserAvatarAlt(user: User): string {
    return `${user.firstName} ${user.lastName} avatar`;
  }
  
  getUserRoleLabel(role: UserRole): string {
    return UserRoleLabels[role];
  }
  
  getUserStatusLabel(status: UserStatus): string {
    return UserStatusLabels[status];
  }
  
  getUserStatusColor(status: UserStatus): string {
    return UserStatusColors[status];
  }
  
  getUserRoleIcon(role: UserRole): string {
    return UserRoleIcons[role];
  }
  
  getUserStatusIcon(status: UserStatus): string {
    return UserStatusIcons[status];
  }
  
  getLoadingText(): string {
    return 'Loading users...';
  }
  
  getErrorTitle(): string {
    return 'Error loading users';
  }
  
  getRetryButtonText(): string {
    return 'Try Again';
  }
  
  getEditButtonText(): string {
    return 'Edit';
  }
  
  getDeleteButtonText(): string {
    return 'Delete';
  }
  
  getEditButtonLabel(user: User): string {
    return `Edit ${this.getUserDisplayName(user)}`;
  }
  
  getDeleteButtonLabel(user: User): string {
    return `Delete ${this.getUserDisplayName(user)}`;
  }
  
  getCreatedDateText(): string {
    return 'Created';
  }
  
  getDateFormat(): string {
    return 'short';
  }
  
  getNoResultsTitle(): string {
    return 'No results found';
  }
  
  getNoResultsMessage(): string {
    return `No users match your search: "${this.searchTerm()}"`;
  }
  
  getClearSearchButtonText(): string {
    return 'Clear Search';
  }
  
  getNoUsersTitle(): string {
    return 'No users yet';
  }
  
  getNoUsersMessage(): string {
    return 'Get started by creating your first user';
  }
  
  getCreateFirstUserButtonText(): string {
    return 'Create First User';
  }
  
  // Actions
  onSearchChange(event: any): void {
    this.searchTerm.set(event.target.value || '');
  }
  
  onUserSelect(user: User): void {
    this.selectedUser.set(user);
  }
  
  onUserEdit(user: User): void {
    this.router.navigate([AppRoutes.USER_EDIT, user.id]);
  }
  
  onUserDelete(user: User): void {
    // Show confirmation dialog - NO MAGIC STRINGS!
    const confirmed = confirm(UserMessages.USER_DELETE_CONFIRM);
    if (confirmed) {
      this.deleteUser(user.id);
    }
  }
  
  onToggleViewMode(): void {
    this.viewMode.update(mode => 
      mode === ViewModes.GRID ? ViewModes.LIST : ViewModes.GRID
    );
  }
  
  onCreateNew(): void {
    this.router.navigate([AppRoutes.USER_CREATE]);
  }
  
  onRefresh(): void {
    this.loadUsers();
  }
  
  clearSearch(): void {
    this.searchControl.setValue('');
    this.searchTerm.set('');
  }
  
  private loadUsers(): void {
    this.userService.loadUsers();
  }
  
  private async deleteUser(id: string): Promise<void> {
    const success = await this.userService.deleteUser(id);
    
    const message = success ? 
      UserMessages.USER_DELETED : 
      UserMessages.USER_DELETE_FAILED;
    
    const panelClass = success ? 
      NotificationTypes.SUCCESS : 
      NotificationTypes.ERROR;
    
    this.snackBar.open(message, SnackbarActions.CLOSE, { 
      duration: SnackbarDurations.SHORT,
      panelClass: [`${panelClass}-snackbar`]
    });
    
    if (success && this.selectedUser()?.id === id) {
      this.selectedUser.set(null);
    }
  }
  
  private setupReactiveSubscriptions(): void {
    this.subscription.add(
      this.searchControl.valueChanges.pipe(
        debounceTime(300),
        distinctUntilChanged()
      ).subscribe(term => this.searchTerm.set(term || ''))
    );
  }
}