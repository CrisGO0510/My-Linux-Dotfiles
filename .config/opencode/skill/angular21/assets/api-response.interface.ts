// shared/interfaces/api-response.interface.ts
export interface ApiResponse<T = any> {
  success: boolean;
  data: T;
  message?: string;
  errors?: string[];
  timestamp: Date;
}

export interface PaginatedResponse<T = any> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

export interface ValidationError {
  field: string;
  message: string;
  value?: any;
}

// Generic response wrappers
export type ApiSuccess<T> = ApiResponse<T> & { success: true };
export type ApiFailure = ApiResponse<null> & { success: false; errors: string[] };

// Pagination parameters
export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortDirection?: 'asc' | 'desc';
}

// Search parameters
export interface SearchParams {
  query?: string;
  filters?: Record<string, any>;
}

// Combined query parameters
export interface QueryParams extends PaginationParams, SearchParams {
  includeInactive?: boolean;
}