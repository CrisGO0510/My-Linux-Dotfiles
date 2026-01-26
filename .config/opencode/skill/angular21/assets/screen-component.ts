// Screen component template with signals and proper injection
import { 
  Component, 
  signal, 
  computed, 
  effect,
  inject,
  OnDestroy,
  ChangeDetectionStrategy 
} from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatDialog } from '@angular/material/dialog';
import { Subscription, debounceTime, distinctUntilChanged, switchMap, catchError, of, tap, finalize } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';

// Import interfaces from dedicated directory
import { User, UserFilters } from '../interfaces/user.interface';
import { UserRole, UserStatus } from '../interfaces/user.enums';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  styleUrl: './user-list.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserListComponent implements OnDestroy {
  // Use inject() for lazy loading - services only load when needed
  private userService = inject(UserService);
  private router = inject(Router);
  private snackBar = inject(MatSnackBar);
  private dialog = inject(MatDialog);
  
  // Subscription for complex RxJS operations
  private subscription = new Subscription();
  
  // Convert service observables to signals using toSignal()
  users = toSignal(this.userService.users$, { initialValue: [] });
  loading = toSignal(this.userService.loading$, { initialValue: false });
  error = toSignal(this.userService.error$, { initialValue: null });
  
  // Local state signals
  selectedUser = signal<User | null>(null);
  searchTerm = signal('');
  viewMode = signal<'grid' | 'list'>('grid');
  filters = signal<UserFilters>({});
  
  // Form controls for complex reactive operations
  searchControl = new FormControl('');
  roleFilterControl = new FormControl<UserRole | null>(null);
  statusFilterControl = new FormControl<UserStatus | null>(null);
  
  // Computed values
  filteredUsers = computed(() => {
    const term = this.searchTerm().toLowerCase();
    const users = this.users();
    const currentFilters = this.filters();
    
    return users.filter(user => {
      // Search term filter
      if (term) {
        const matchesSearch = 
          user.firstName.toLowerCase().includes(term) ||
          user.lastName.toLowerCase().includes(term) ||
          user.email.toLowerCase().includes(term);
        if (!matchesSearch) return false;
      }
      
      // Role filter
      if (currentFilters.role && user.role !== currentFilters.role) {
        return false;
      }
      
      // Status filter
      if (currentFilters.status && user.active !== (currentFilters.status === UserStatus.ACTIVE)) {
        return false;
      }
      
      return true;
    });
  });
  
  activeUsers = computed(() => 
    this.filteredUsers().filter(user => user.active)
  );
  
  hasResults = computed(() => this.filteredUsers().length > 0);
  
  selectedUserDetails = computed(() => {
    const selected = this.selectedUser();
    return selected ? {
      fullName: `${selected.firstName} ${selected.lastName}`,
      roleLabel: this.getRoleLabel(selected.role),
      statusLabel: selected.active ? 'Active' : 'Inactive'
    } : null;
  });
  
  ngOnInit(): void {
    this.loadUsers();
    this.setupReactiveSubscriptions();
  }
  
  ngOnDestroy(): void {
    // CRITICAL: Always cleanup subscriptions to prevent memory leaks
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
        confirmText: 'Delete',
        cancelText: 'Cancel',
        type: 'danger'
      }
    });
    
    // Use subscription for dialog result
    this.subscription.add(
      dialogRef.afterClosed().subscribe(confirmed => {
        if (confirmed) {
          this.deleteUser(user.id);
        }
      })
    );
  }
  
  onToggleViewMode(): void {
    this.viewMode.update(mode => mode === 'grid' ? 'list' : 'grid');
  }
  
  onCreateNew(): void {
    this.router.navigate(['/users', 'create']);
  }
  
  onRefresh(): void {
    this.loadUsers();
  }
  
  onApplyFilters(): void {
    const newFilters: UserFilters = {
      role: this.roleFilterControl.value || undefined,
      status: this.statusFilterControl.value || undefined,
      search: this.searchTerm()
    };
    this.filters.set(newFilters);
  }
  
  onClearFilters(): void {
    this.filters.set({});
    this.roleFilterControl.setValue(null);
    this.statusFilterControl.setValue(null);
    this.searchControl.setValue('');
    this.searchTerm.set('');
  }
  
  private loadUsers(): void {
    this.userService.loadUsers();
  }
  
  private async deleteUser(id: string): Promise<void> {
    const success = await this.userService.deleteUser(id);
    
    if (success) {
      this.snackBar.open('User deleted successfully', 'Close', { 
        duration: 3000,
        panelClass: ['success-snackbar']
      });
      
      // Clear selection if deleted user was selected
      if (this.selectedUser()?.id === id) {
        this.selectedUser.set(null);
      }
    } else {
      this.snackBar.open('Failed to delete user', 'Close', { 
        duration: 5000,
        panelClass: ['error-snackbar']
      });
    }
  }
  
  private setupReactiveSubscriptions(): void {
    // Search with debounce - complex RxJS logic requires manual subscription
    this.subscription.add(
      this.searchControl.valueChanges.pipe(
        debounceTime(300),
        distinctUntilChanged(),
        tap(term => this.searchTerm.set(term || ''))
      ).subscribe()
    );
    
    // Complex filter combination with server-side search
    this.subscription.add(
      this.roleFilterControl.valueChanges.pipe(
        distinctUntilChanged(),
        switchMap(role => 
          this.userService.searchUsersByRole(role).pipe(
            catchError(error => {
              console.error('Role filter error:', error);
              this.snackBar.open('Failed to apply role filter', 'Close', { 
                duration: 3000 
              });
              return of([]);
            })
          )
        )
      ).subscribe(users => {
        // Update local filtered results if needed
        console.log('Role filter results:', users);
      })
    );
    
    // Status filter with loading indication
    this.subscription.add(
      this.statusFilterControl.valueChanges.pipe(
        distinctUntilChanged(),
        tap(() => this.loading.set ? this.loading.set(true) : null),
        switchMap(status => 
          this.userService.getUsersByStatus(status).pipe(
            finalize(() => this.loading.set ? this.loading.set(false) : null),
            catchError(error => {
              console.error('Status filter error:', error);
              this.snackBar.open('Failed to apply status filter', 'Close', { 
                duration: 3000 
              });
              return of([]);
            })
          )
        )
      ).subscribe()
    );
  }
  
  private getRoleLabel(role: UserRole): string {
    const roleLabels = {
      [UserRole.ADMIN]: 'Administrator',
      [UserRole.USER]: 'User',
      [UserRole.MODERATOR]: 'Moderator',
      [UserRole.GUEST]: 'Guest'
    };
    return roleLabels[role] || role;
  }
}