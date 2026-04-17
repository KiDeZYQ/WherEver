# WherEver Project

Location-based reminder app with Flutter frontend and Spring Cloud Alibaba backend.

## Project Structure

```
WherEver/
├── wher_ever/              # Flutter App
│   ├── lib/
│   │   ├── models/         # Data models
│   │   ├── pages/          # UI pages
│   │   │   ├── auth/       # Authentication pages
│   │   │   └── home/       # Home feature pages
│   │   └── services/        # Business services
│   └── pubspec.yaml
│
├── wher_ever_backend/       # Spring Cloud Backend
│   ├── wher-ever-common/    # Common entities, DTOs
│   ├── wher-ever-api/       # API Gateway
│   ├── wher-ever-user/      # User Service (8081)
│   ├── wher-ever-notification/ # Reminder Service (8082)
│   └── wher-ever-location/   # Location Service (8083)
│
└── wher_ever_docker/        # Docker Compose
    ├── mysql/               # MySQL 8.0
    ├── redis/               # Redis 7
    ├── nacos/               # Nacos 2.2.3
    └── rocketmq/            # RocketMQ 5.1.0
```

## Quick Start

### 1. Start Infrastructure (Docker)

```bash
cd wher_ever_docker
docker-compose up -d
```

Services:
- MySQL: localhost:3306 (root/root123456)
- Redis: localhost:6379
- Nacos: localhost:8848
- RocketMQ Dashboard: localhost:8080

### 2. Start Backend Services

```bash
cd wher_ever_backend
mvn clean install -DskipTests
mvn spring-boot:run -pl wher-ever-user      # Port 8081
mvn spring-boot:run -pl wher-ever-notification  # Port 8082
```

### 3. Start Flutter App

```bash
cd wher_ever
flutter run
```

## API Endpoints

### User Service (8081)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/users/register | Register |
| POST | /api/users/login | Login |
| GET | /api/users/{id} | Get user |
| PUT | /api/users/{id}/subscription | Update subscription |

### Reminder Service (8082)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/reminders | Create reminder |
| PUT | /api/reminders/{id} | Update reminder |
| DELETE | /api/reminders/{id} | Delete reminder |
| GET | /api/reminders/{id} | Get reminder |
| GET | /api/reminders?userId= | List user's reminders |

## Features

- [x] User authentication (JWT)
- [x] Guest session mode
- [x] Voice command reminder creation
- [x] Manual reminder creation
- [x] Reminder list/detail/edit/delete
- [x] Location search
- [x] Geofence monitoring
- [x] Push notifications
- [x] Data export/import
- [x] Settings page

## Tech Stack

### Frontend
- Flutter 3.x
- GetX (state management)
- Dio (HTTP client)
- speech_to_text (voice)
- geolocator (location)
- flutter_local_notifications

### Backend
- Spring Boot 3.2.5
- Spring Cloud Alibaba 2023.0.3.2
- MyBatis Plus
- JWT
- MySQL 8.0
- Redis 7
- Nacos 2.2.3
- RocketMQ 5.1.0

## Build APK

```bash
cd wher_ever
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`
