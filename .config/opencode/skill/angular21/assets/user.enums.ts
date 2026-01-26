// users/interfaces/user.enums.ts - NO MAGIC STRINGS ANYWHERE!
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
  PENDING_VERIFICATION = 'pending_verification',
  LOCKED = 'locked'
}

export enum UserActionType {
  CREATE = 'create',
  UPDATE = 'update',
  DELETE = 'delete',
  SUSPEND = 'suspend',
  ACTIVATE = 'activate',
  CHANGE_ROLE = 'change_role',
  RESET_PASSWORD = 'reset_password',
  UNLOCK = 'unlock'
}

export enum UserSortFields {
  FIRST_NAME = 'firstName',
  LAST_NAME = 'lastName',
  EMAIL = 'email',
  ROLE = 'role',
  STATUS = 'status',
  CREATED_AT = 'createdAt',
  UPDATED_AT = 'updatedAt',
  LAST_LOGIN = 'lastLogin'
}

// Label mappings for frontend display - NO MAGIC STRINGS!
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
  [UserStatus.PENDING_VERIFICATION]: 'Pending Verification',
  [UserStatus.LOCKED]: 'Locked'
};

export const UserActionLabels: Record<UserActionType, string> = {
  [UserActionType.CREATE]: 'Create User',
  [UserActionType.UPDATE]: 'Update User',
  [UserActionType.DELETE]: 'Delete User',
  [UserActionType.SUSPEND]: 'Suspend User',
  [UserActionType.ACTIVATE]: 'Activate User',
  [UserActionType.CHANGE_ROLE]: 'Change Role',
  [UserActionType.RESET_PASSWORD]: 'Reset Password',
  [UserActionType.UNLOCK]: 'Unlock User'
};

export const UserSortFieldLabels: Record<UserSortFields, string> = {
  [UserSortFields.FIRST_NAME]: 'First Name',
  [UserSortFields.LAST_NAME]: 'Last Name',
  [UserSortFields.EMAIL]: 'Email',
  [UserSortFields.ROLE]: 'Role',
  [UserSortFields.STATUS]: 'Status',
  [UserSortFields.CREATED_AT]: 'Created Date',
  [UserSortFields.UPDATED_AT]: 'Updated Date',
  [UserSortFields.LAST_LOGIN]: 'Last Login'
};

// Colors and styling mappings - NO MAGIC STRINGS!
export const UserStatusColors: Record<UserStatus, 'primary' | 'accent' | 'warn'> = {
  [UserStatus.ACTIVE]: 'primary',
  [UserStatus.INACTIVE]: 'accent',
  [UserStatus.SUSPENDED]: 'warn',
  [UserStatus.PENDING_VERIFICATION]: 'accent',
  [UserStatus.LOCKED]: 'warn'
};

export const UserRoleColors: Record<UserRole, 'primary' | 'accent' | 'warn'> = {
  [UserRole.ADMIN]: 'warn',
  [UserRole.USER]: 'primary',
  [UserRole.MODERATOR]: 'accent',
  [UserRole.GUEST]: 'accent'
};

// Icon mappings - NO MAGIC STRINGS!
export const UserRoleIcons: Record<UserRole, string> = {
  [UserRole.ADMIN]: 'admin_panel_settings',
  [UserRole.USER]: 'person',
  [UserRole.MODERATOR]: 'verified_user',
  [UserRole.GUEST]: 'person_outline'
};

export const UserStatusIcons: Record<UserStatus, string> = {
  [UserStatus.ACTIVE]: 'check_circle',
  [UserStatus.INACTIVE]: 'remove_circle_outline',
  [UserStatus.SUSPENDED]: 'block',
  [UserStatus.PENDING_VERIFICATION]: 'schedule',
  [UserStatus.LOCKED]: 'lock'
};

export const UserActionIcons: Record<UserActionType, string> = {
  [UserActionType.CREATE]: 'add',
  [UserActionType.UPDATE]: 'edit',
  [UserActionType.DELETE]: 'delete',
  [UserActionType.SUSPEND]: 'block',
  [UserActionType.ACTIVATE]: 'check_circle',
  [UserActionType.CHANGE_ROLE]: 'swap_horiz',
  [UserActionType.RESET_PASSWORD]: 'lock_reset',
  [UserActionType.UNLOCK]: 'lock_open'
};

// CSS Classes for user components - NO MAGIC STRINGS!
export enum UserComponentClasses {
  USER_CARD = 'user-card',
  USER_CARD_ACTIVE = 'user-card-active',
  USER_CARD_INACTIVE = 'user-card-inactive',
  USER_CARD_SUSPENDED = 'user-card-suspended',
  USER_LIST_ITEM = 'user-list-item',
  USER_AVATAR = 'user-avatar',
  USER_STATUS_BADGE = 'user-status-badge',
  USER_ROLE_BADGE = 'user-role-badge',
  USER_ACTIONS = 'user-actions',
  USER_GRID = 'users-grid',
  USER_LIST = 'users-list'
}

// Form validation patterns - NO MAGIC STRINGS!
export enum UserValidationPatterns {
  EMAIL = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
  PHONE = '^[+]?[1-9]?[0-9]{7,15}$',
  NAME = '^[a-zA-ZÀ-ÿ\\u0100-\\u017f\\s]{2,50}$',
  USERNAME = '^[a-zA-Z0-9_]{3,20}$',
  PASSWORD = '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$'
}

// User-specific validation messages - NO MAGIC STRINGS!
export enum UserValidationMessages {
  FIRST_NAME_REQUIRED = 'First name is required',
  LAST_NAME_REQUIRED = 'Last name is required',
  EMAIL_REQUIRED = 'Email is required',
  EMAIL_INVALID = 'Please enter a valid email address',
  PHONE_INVALID = 'Please enter a valid phone number',
  ROLE_REQUIRED = 'Role is required',
  PASSWORD_REQUIRED = 'Password is required',
  PASSWORD_TOO_WEAK = 'Password must contain uppercase, lowercase, number and special character',
  PASSWORD_CONFIRM_REQUIRED = 'Password confirmation is required',
  PASSWORDS_DONT_MATCH = 'Passwords do not match',
  NAME_INVALID_CHARACTERS = 'Name contains invalid characters',
  USERNAME_TAKEN = 'Username is already taken',
  EMAIL_TAKEN = 'Email is already registered'
}

// User-specific messages - NO MAGIC STRINGS!
export enum UserMessages {
  USER_CREATED = 'User created successfully',
  USER_UPDATED = 'User updated successfully',
  USER_DELETED = 'User deleted successfully',
  USER_SUSPENDED = 'User suspended successfully',
  USER_ACTIVATED = 'User activated successfully',
  USER_ROLE_CHANGED = 'User role changed successfully',
  USER_PASSWORD_RESET = 'Password reset email sent successfully',
  USER_UNLOCKED = 'User unlocked successfully',
  USER_NOT_FOUND = 'User not found',
  USER_CREATION_FAILED = 'Failed to create user',
  USER_UPDATE_FAILED = 'Failed to update user',
  USER_DELETE_FAILED = 'Failed to delete user',
  USER_SUSPEND_FAILED = 'Failed to suspend user',
  USER_ACTIVATE_FAILED = 'Failed to activate user',
  USER_BULK_DELETE_CONFIRM = 'Are you sure you want to delete the selected users?',
  USER_DELETE_CONFIRM = 'Are you sure you want to delete this user?',
  USER_SUSPEND_CONFIRM = 'Are you sure you want to suspend this user?'
}

// API query parameter keys for users - NO MAGIC STRINGS!
export enum UserQueryParams {
  ROLE = 'role',
  STATUS = 'status',
  SEARCH = 'search',
  SORT_BY = 'sortBy',
  SORT_DIRECTION = 'sortDirection',
  PAGE = 'page',
  LIMIT = 'limit',
  INCLUDE_INACTIVE = 'includeInactive',
  DATE_FROM = 'dateFrom',
  DATE_TO = 'dateTo'
}