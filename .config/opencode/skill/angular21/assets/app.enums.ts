// shared/interfaces/app.enums.ts - Global application enums
export enum AppRoutes {
  HOME = '/',
  USERS = '/users',
  USER_CREATE = '/users/create',
  USER_EDIT = '/users/edit',
  USER_DETAIL = '/users/detail',
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
  USERS_BULK_UPDATE_ROLE = '/api/users/bulk-update-role',
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
  SIDEBAR_STATE = 'sidebar_state',
  CURRENT_USER = 'current_user'
}

export enum SessionStorageKeys {
  FORM_DATA = 'temp_form_data',
  SEARCH_FILTERS = 'search_filters',
  CURRENT_PAGE = 'current_page',
  TABLE_STATE = 'table_state'
}

export enum HttpStatusCodes {
  OK = 200,
  CREATED = 201,
  NO_CONTENT = 204,
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  CONFLICT = 409,
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
  DISABLED = 'disabled',
  ACTIVE = 'active',
  INACTIVE = 'inactive'
}

export enum NotificationTypes {
  SUCCESS = 'success',
  ERROR = 'error',
  WARNING = 'warning',
  INFO = 'info'
}

// CSS Classes as enums - NO MAGIC STRINGS!
export enum CssClasses {
  CARD_ACTIVE = 'card-active',
  CARD_INACTIVE = 'card-inactive',
  CARD_SELECTED = 'card-selected',
  LOADING_OVERLAY = 'loading-overlay',
  ERROR_STATE = 'error-state',
  SUCCESS_STATE = 'success-state',
  WARNING_STATE = 'warning-state',
  HIDDEN = 'hidden',
  VISIBLE = 'visible',
  DISABLED = 'disabled',
  FADE_IN = 'fade-in',
  FADE_OUT = 'fade-out'
}

// Form field names as enums
export enum UserFormFields {
  FIRST_NAME = 'firstName',
  LAST_NAME = 'lastName',
  EMAIL = 'email',
  PHONE = 'phone',
  ROLE = 'role',
  STATUS = 'status',
  ACTIVE = 'active',
  PASSWORD = 'password',
  CONFIRM_PASSWORD = 'confirmPassword'
}

export enum CommonFormFields {
  ID = 'id',
  NAME = 'name',
  DESCRIPTION = 'description',
  CREATED_AT = 'createdAt',
  UPDATED_AT = 'updatedAt',
  ACTIVE = 'active'
}

// Validation messages - NO MAGIC STRINGS!
export enum ValidationMessages {
  REQUIRED = 'This field is required',
  EMAIL_INVALID = 'Please enter a valid email address',
  PHONE_INVALID = 'Please enter a valid phone number',
  PASSWORD_TOO_SHORT = 'Password must be at least 8 characters',
  PASSWORD_TOO_WEAK = 'Password must contain uppercase, lowercase, number and special character',
  PASSWORDS_DONT_MATCH = 'Passwords do not match',
  NAME_TOO_SHORT = 'Name must be at least 2 characters',
  NAME_TOO_LONG = 'Name cannot exceed 50 characters',
  INVALID_CHARACTERS = 'Invalid characters detected',
  MIN_LENGTH = 'Minimum length not met',
  MAX_LENGTH = 'Maximum length exceeded',
  PATTERN_MISMATCH = 'Format is incorrect'
}

// Success/Error messages - NO MAGIC STRINGS!
export enum Messages {
  USER_CREATED_SUCCESS = 'User created successfully',
  USER_UPDATED_SUCCESS = 'User updated successfully',
  USER_DELETED_SUCCESS = 'User deleted successfully',
  USERS_BULK_DELETED_SUCCESS = 'Users deleted successfully',
  ROLE_UPDATED_SUCCESS = 'User role updated successfully',
  OPERATION_FAILED = 'Operation failed. Please try again.',
  OPERATION_SUCCESS = 'Operation completed successfully',
  LOADING_ERROR = 'Failed to load data',
  SAVE_ERROR = 'Failed to save changes',
  DELETE_ERROR = 'Failed to delete item',
  UNAUTHORIZED_ACCESS = 'You do not have permission to perform this action',
  SESSION_EXPIRED = 'Your session has expired. Please log in again.',
  NETWORK_ERROR = 'Network error. Please check your connection.',
  VALIDATION_FAILED = 'Please correct the errors and try again',
  CONFIRM_DELETE = 'Are you sure you want to delete this item?',
  CHANGES_NOT_SAVED = 'You have unsaved changes. Are you sure you want to leave?'
}

// Dialog/Modal configuration
export enum DialogActions {
  CONFIRM = 'confirm',
  CANCEL = 'cancel',
  DELETE = 'delete',
  SAVE = 'save',
  CLOSE = 'close'
}

export enum DialogTexts {
  CONFIRM = 'Confirm',
  CANCEL = 'Cancel',
  DELETE = 'Delete',
  SAVE = 'Save',
  CLOSE = 'Close',
  YES = 'Yes',
  NO = 'No',
  OK = 'OK'
}

// Table/Grid configuration
export enum TableActions {
  EDIT = 'edit',
  DELETE = 'delete',
  VIEW = 'view',
  DUPLICATE = 'duplicate',
  ACTIVATE = 'activate',
  DEACTIVATE = 'deactivate'
}

export enum MatIconNames {
  EDIT = 'edit',
  DELETE = 'delete',
  ADD = 'add',
  SAVE = 'save',
  CANCEL = 'cancel',
  SEARCH = 'search',
  FILTER = 'filter_list',
  SORT = 'sort',
  REFRESH = 'refresh',
  SETTINGS = 'settings',
  USER = 'person',
  ADMIN = 'admin_panel_settings',
  VISIBILITY_ON = 'visibility',
  VISIBILITY_OFF = 'visibility_off',
  MENU = 'menu',
  CLOSE = 'close',
  ARROW_BACK = 'arrow_back',
  ARROW_FORWARD = 'arrow_forward',
  CHECK = 'check',
  WARNING = 'warning',
  ERROR = 'error',
  INFO = 'info'
}

// Snackbar/Toast configuration
export enum SnackbarActions {
  CLOSE = 'Close',
  UNDO = 'Undo',
  RETRY = 'Retry',
  VIEW = 'View'
}

export enum SnackbarDurations {
  SHORT = 3000,
  MEDIUM = 5000,
  LONG = 8000,
  INDEFINITE = 0
}

// Date/Time formats
export enum DateFormats {
  SHORT = 'short',
  MEDIUM = 'medium',
  LONG = 'long',
  DATE_ONLY = 'yyyy-MM-dd',
  TIME_ONLY = 'HH:mm:ss',
  DATETIME = 'yyyy-MM-dd HH:mm:ss'
}

// File/Upload related
export enum FileTypes {
  IMAGE_JPEG = 'image/jpeg',
  IMAGE_PNG = 'image/png',
  IMAGE_GIF = 'image/gif',
  PDF = 'application/pdf',
  TEXT = 'text/plain',
  CSV = 'text/csv'
}

export enum FileSizeLimits {
  IMAGE_MAX = 5242880, // 5MB
  DOCUMENT_MAX = 10485760, // 10MB
  AVATAR_MAX = 1048576 // 1MB
}

// Query parameter names
export enum QueryParams {
  PAGE = 'page',
  LIMIT = 'limit',
  SORT_BY = 'sortBy',
  SORT_DIRECTION = 'sortDirection',
  SEARCH = 'search',
  FILTER = 'filter',
  STATUS = 'status',
  ROLE = 'role'
}