# WherEver Naming Conventions

## 1. Package Naming

### Java/Kotlin
- Base package: `com.wherEver`
- Examples:
  - `com.wherEver.common.entity`
  - `com.wherEver.user.service`
  - `com.wherEver.notification.controller`

### Flutter/Dart
- Library prefix: `wher_ever`
- Examples:
  - `wher_ever_user`
  - `wher_ever_notification`
  - `wher_ever_location`

## 2. Module Naming

### Maven/Gradle Modules (Backend)
- Pattern: `wher-ever-{module}`
- Examples:
  - `wher-ever-common`
  - `wher-ever-api`
  - `wher-ever-user`
  - `wher-ever-notification`
  - `wher-ever-location`

### Flutter Packages
- Pattern: `wher_ever_{module}`
- Examples:
  - `wher_ever_user`
  - `wher_ever_notification`

## 3. Database Naming

### Tables
- Prefix: `we_`
- Pattern: `we_{entity_name}`
- Examples:
  - `we_user`
  - `we_reminder`
  - `we_trigger_log`

### Columns
- Pattern: `snake_case`
- Examples:
  - `user_id`
  - `create_time`
  - `subscription_level`

## 4. API Path Naming

### REST API
- Prefix: `/api/v1/`
- Pattern: `/api/v1/{resource}/{action}`
- Examples:
  - `/api/v1/user/register`
  - `/api/v1/reminder/create`
  - `/api/v1/reminder/list`

## 5. Variable Naming

### Java/Kotlin
| Type | Convention | Example |
|------|------------|---------|
| Local variable | camelCase | `userName`, `maxRetryCount` |
| Method | camelCase | `getUserById()`, `createReminder()` |
| Constant | SCREAMING_SNAKE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Class | PascalCase | `UserService`, `ReminderController` |
| Enum | PascalCase value, SCREAMING_SNAKE | `FREE`, `PREMIUM` |

### Flutter/Dart
| Type | Convention | Example |
|------|------------|---------|
| Variable | camelCase | `userName`, `maxRetryCount` |
| Method | camelCase | `getUserById()`, `createReminder()` |
| Constant | camelCase | `maxRetryCount`, `defaultPageSize` |
| Class | PascalCase | `UserService`, `ReminderController` |
| Enum | PascalCase | `free`, `premium` |

## 6. File Naming

### Backend
| Type | Convention | Example |
|------|------------|---------|
| Java class | PascalCase + suffix | `UserService.java`, `ReminderController.java` |
| Entity | PascalCase | `User.java`, `Reminder.java` |
| DTO | PascalCase + suffix | `UserDTO.java`, `LoginRequest.java` |
| Config | PascalCase | `AppConfig.java`, `RedisConfig.java` |

### Frontend
| Type | Convention | Example |
|------|------------|---------|
| Page | PascalCase | `HomePage.dart`, `ReminderPage.dart` |
| Widget | PascalCase | `ReminderCard.dart`, `LocationPicker.dart` |
| Service | snake_case | `user_service.dart`, `notification_service.dart` |
| Model | PascalCase | `User.dart`, `Reminder.dart` |

## 7. Commit Message Convention

Format: `<type>(<scope>): <subject>`

### Type
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (no logic change)
- `refactor`: Refactoring
- `perf`: Performance improvement
- `test`: Tests
- `chore`: Build/tooling

### Scope
- `user`: User module
- `notification`: Notification module
- `location`: Location module
- `api`: API gateway
- `common`: Common module

### Examples
```
feat(user): add user registration endpoint
fix(notification): resolve push notification delay
docs(location): update geofence API documentation
refactor(api): simplify route configuration
```
