// shared/interfaces/common.interfaces.ts
export interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
  active?: boolean;
}

export interface NamedEntity extends BaseEntity {
  name: string;
  description?: string;
}

export interface TimestampedEntity {
  createdAt: Date;
  updatedAt: Date;
  deletedAt?: Date;
}

export interface AuditableEntity extends TimestampedEntity {
  createdBy?: string;
  updatedBy?: string;
  deletedBy?: string;
}

// Generic table column interface
export interface TableColumn<T = any> {
  key: keyof T | string;
  header: string;
  sortable?: boolean;
  filterable?: boolean;
  width?: string;
  template?: any; // TemplateRef in actual implementation
  cellClass?: string;
  headerClass?: string;
}

// Form field configuration
export interface FormFieldConfig {
  name: string;
  label: string;
  type: FormFieldType;
  required?: boolean;
  placeholder?: string;
  options?: SelectOption[];
  validation?: ValidationRule[];
}

export interface SelectOption {
  value: any;
  label: string;
  disabled?: boolean;
  group?: string;
}

export interface ValidationRule {
  type: 'required' | 'email' | 'minLength' | 'maxLength' | 'pattern' | 'custom';
  value?: any;
  message: string;
}

export type FormFieldType = 
  | 'text' 
  | 'email' 
  | 'password' 
  | 'number' 
  | 'select' 
  | 'multiselect' 
  | 'checkbox' 
  | 'radio' 
  | 'textarea' 
  | 'date' 
  | 'datetime'
  | 'file';

// Navigation and menu interfaces
export interface MenuItem {
  label: string;
  icon?: string;
  route?: string;
  action?: () => void;
  children?: MenuItem[];
  disabled?: boolean;
  visible?: boolean;
  permissions?: string[];
}

export interface BreadcrumbItem {
  label: string;
  route?: string;
  icon?: string;
}

// Modal and dialog interfaces
export interface ModalConfig {
  title?: string;
  message?: string;
  confirmText?: string;
  cancelText?: string;
  width?: string;
  height?: string;
  disableClose?: boolean;
}

export interface ConfirmDialogData {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  type?: 'info' | 'warning' | 'danger';
}

// Notification interfaces
export interface NotificationOptions {
  type: 'success' | 'error' | 'warning' | 'info';
  title?: string;
  message: string;
  duration?: number;
  action?: NotificationAction;
}

export interface NotificationAction {
  label: string;
  action: () => void;
}

// Loading state interface
export interface LoadingState {
  loading: boolean;
  error: string | null;
  lastUpdated?: Date;
}