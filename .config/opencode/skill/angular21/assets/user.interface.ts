// users/interfaces/user.interface.ts
export interface User {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  avatar?: string;
  active: boolean;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserDto {
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  role: UserRole;
}

export interface UpdateUserDto {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  role?: UserRole;
  active?: boolean;
}

export interface UserListResponse {
  users: User[];
  total: number;
  page: number;
  limit: number;
}

export interface UserFilters {
  role?: UserRole;
  status?: UserStatus;
  search?: string;
  dateFrom?: Date;
  dateTo?: Date;
}

// Type aliases for better readability
export type UserId = string;
export type UserEmail = string;
export type UserSortField = 'firstName' | 'lastName' | 'email' | 'createdAt' | 'role';
export type SortDirection = 'asc' | 'desc';