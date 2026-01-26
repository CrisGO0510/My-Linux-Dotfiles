// Service template with signals pattern
import { Injectable, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';

// Import interfaces from dedicated directory
import { User, CreateUserDto, UpdateUserDto, UserFilters } from '../interfaces/user.interface';
import { UserRole, UserStatus } from '../interfaces/user.enums';
import { ApiResponse, PaginatedResponse, QueryParams } from '../../shared/interfaces/api-response.interface';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private readonly apiUrl = '/api/users';
  
  // Private signals for internal state
  private _users = signal<User[]>([]);
  private _loading = signal(false);
  private _error = signal<string | null>(null);
  private _selectedUserId = signal<string | null>(null);
  private _filters = signal<UserFilters>({});
  
  // Public readonly signals
  readonly users = this._users.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();
  readonly selectedUserId = this._selectedUserId.asReadonly();
  readonly filters = this._filters.asReadonly();
  
  // Computed values
  readonly activeUsers = computed(() => 
    this._users().filter(user => user.active && user.role !== UserRole.GUEST)
  );
  
  readonly adminUsers = computed(() =>
    this._users().filter(user => user.role === UserRole.ADMIN)
  );
  
  readonly usersCount = computed(() => this._users().length);
  
  readonly filteredUsers = computed(() => {
    const users = this._users();
    const filters = this._filters();
    
    return users.filter(user => {
      if (filters.role && user.role !== filters.role) return false;
      if (filters.search) {
        const searchTerm = filters.search.toLowerCase();
        const matchesSearch = 
          user.firstName.toLowerCase().includes(searchTerm) ||
          user.lastName.toLowerCase().includes(searchTerm) ||
          user.email.toLowerCase().includes(searchTerm);
        if (!matchesSearch) return false;
      }
      if (filters.dateFrom && new Date(user.createdAt) < filters.dateFrom) return false;
      if (filters.dateTo && new Date(user.createdAt) > filters.dateTo) return false;
      
      return true;
    });
  });
  
  readonly selectedUser = computed(() => {
    const id = this._selectedUserId();
    return id ? this._users().find(u => u.id === id) ?? null : null;
  });
  
  constructor(private http: HttpClient) {}
  
  // Load all users
  async loadUsers(params?: QueryParams): Promise<void> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const response = await this.http.get<ApiResponse<PaginatedResponse<User>>>(
        this.apiUrl, 
        { params: params as any }
      ).toPromise();
      
      if (response?.success && response.data) {
        this._users.set(response.data.items || []);
      }
    } catch (error) {
      this._error.set('Failed to load users');
      console.error('Load users error:', error);
    } finally {
      this._loading.set(false);
    }
  }
  
  // Get user by ID
  async getUser(id: string): Promise<User | null> {
    try {
      const response = await this.http.get<ApiResponse<User>>(`${this.apiUrl}/${id}`).toPromise();
      return response?.success ? response.data : null;
    } catch (error) {
      this._error.set('Failed to load user');
      console.error('Get user error:', error);
      return null;
    }
  }
  
  // Create new user
  async createUser(dto: CreateUserDto): Promise<User | null> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const response = await this.http.post<ApiResponse<User>>(this.apiUrl, dto).toPromise();
      if (response?.success && response.data) {
        this._users.update(users => [...users, response.data]);
        return response.data;
      }
      return null;
    } catch (error) {
      this._error.set('Failed to create user');
      console.error('Create user error:', error);
      return null;
    } finally {
      this._loading.set(false);
    }
  }
  
  // Update user
  async updateUser(id: string, dto: UpdateUserDto): Promise<User | null> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const response = await this.http.put<ApiResponse<User>>(`${this.apiUrl}/${id}`, dto).toPromise();
      if (response?.success && response.data) {
        this._users.update(users =>
          users.map(u => u.id === id ? response.data : u)
        );
        return response.data;
      }
      return null;
    } catch (error) {
      this._error.set('Failed to update user');
      console.error('Update user error:', error);
      return null;
    } finally {
      this._loading.set(false);
    }
  }
  
  // Delete user
  async deleteUser(id: string): Promise<boolean> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const response = await this.http.delete<ApiResponse<void>>(`${this.apiUrl}/${id}`).toPromise();
      if (response?.success) {
        this._users.update(users => users.filter(u => u.id !== id));
        
        // Clear selection if deleted user was selected
        if (this._selectedUserId() === id) {
          this._selectedUserId.set(null);
        }
        
        return true;
      }
      return false;
    } catch (error) {
      this._error.set('Failed to delete user');
      console.error('Delete user error:', error);
      return false;
    } finally {
      this._loading.set(false);
    }
  }
  
  // Update filters
  updateFilters(filters: Partial<UserFilters>): void {
    this._filters.update(current => ({ ...current, ...filters }));
  }
  
  // Clear filters
  clearFilters(): void {
    this._filters.set({});
  }
  
  // Select user
  selectUser(id: string | null): void {
    this._selectedUserId.set(id);
  }
  
  // Clear error
  clearError(): void {
    this._error.set(null);
  }
  
  // Optimistic updates for better UX
  optimisticUpdate(id: string, updates: Partial<User>): void {
    this._users.update(users =>
      users.map(user =>
        user.id === id ? { ...user, ...updates } : user
      )
    );
  }
  
  // Bulk operations
  async bulkDelete(ids: string[]): Promise<boolean> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const response = await this.http.post<ApiResponse<void>>(`${this.apiUrl}/bulk-delete`, { ids }).toPromise();
      if (response?.success) {
        this._users.update(users => users.filter(u => !ids.includes(u.id)));
        
        // Clear selection if selected user was deleted
        if (this._selectedUserId() && ids.includes(this._selectedUserId()!)) {
          this._selectedUserId.set(null);
        }
        
        return true;
      }
      return false;
    } catch (error) {
      this._error.set('Failed to delete users');
      console.error('Bulk delete error:', error);
      return false;
    } finally {
      this._loading.set(false);
    }
  }
  
  // Bulk update user roles
  async bulkUpdateRole(ids: string[], role: UserRole): Promise<boolean> {
    this._loading.set(true);
    this._error.set(null);
    
    try {
      const response = await this.http.put<ApiResponse<User[]>>(
        `${this.apiUrl}/bulk-update-role`, 
        { ids, role }
      ).toPromise();
      
      if (response?.success && response.data) {
        this._users.update(users =>
          users.map(user =>
            ids.includes(user.id) ? { ...user, role } : user
          )
        );
        return true;
      }
      return false;
    } catch (error) {
      this._error.set('Failed to update user roles');
      console.error('Bulk update role error:', error);
      return false;
    } finally {
      this._loading.set(false);
    }
  }
}