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
│   │   │   └── home/      # Home feature pages
│   │   ├── services/       # Business services
│   │   └── widgets/        # Reusable widgets
│   └── pubspec.yaml
│
├── wher_ever_backend/       # Spring Cloud Backend
│   ├── wher-ever-common/    # Common entities, DTOs
│   ├── wher-ever-api/       # API Gateway
│   ├── wher-ever-user/      # User Service (8081)
│   ├── wher-ever-notification/ # Reminder Service (8082)
│   └── wher-ever-location/  # Location Service (8083)
│
└── wher_ever_docker/       # Docker Compose
    ├── mysql/               # MySQL 8.0
    ├── redis/               # Redis 7
    ├── nacos/               # Nacos 2.2.3
    └── rocketmq/            # RocketMQ 5.1.0
```

---

## Quick Start (快速启动)

### 1. Start Infrastructure (Docker)

**PS**: windows下需先启动docker desktop

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

# Compile all modules first
mvn clean install -DskipTests

# Run each service in separate terminals (or use & to run in background)
mvn spring-boot:run -pl wher-ever-user          # Port 8081
mvn spring-boot:run -pl wher-ever-notification   # Port 8082
```

### 3. Start Flutter App

```bash
cd wher_ever
flutter run
```

---

## Docker Configuration (Docker 配置详解)

### Directory Structure (目录结构)

```
wher_ever_docker/
├── docker-compose.yml          # 主编排文件，定义所有容器
├── README.md                  # 说明文档
├── mysql/
│   ├── conf/my.cnf           # MySQL 配置文件
│   ├── init/01-init.sql     # 数据库初始化脚本
│   └── data/                # MySQL 数据持久化目录
├── redis/
│   ├── conf/redis.conf       # Redis 配置文件
│   └── data/                # Redis 数据持久化目录
├── nacos/
│   ├── application.properties # Nacos 配置
│   ├── data/                # Nacos 数据持久化
│   └── logs/                # Nacos 日志
└── rocketmq/
    ├── conf/broker.conf     # RocketMQ Broker 配置
    ├── store/               # 消息存储目录
    └── logs/                # RocketMQ 日志
```

### Services (服务详情)

| 服务 | 镜像 | 端口 | 用途 |
|------|------|------|------|
| `mysql` | mysql:8.0 | 3306 | 关系型数据库 |
| `redis` | redis:7-alpine | 6379 | KV缓存 |
| `nacos` | nacos/nacos-server:v2.2.3 | 8848 | 服务注册/配置中心 |
| `rocketmq` | apache/rocketmq:5.1.0 | 9876 | 消息队列nameserver |
| `rocketmq-broker` | apache/rocketmq:5.1.0 | 10911 | 消息队列broker |
| `rocketmq-dashboard` | apacherocketmq/rocketmq-dashboard | 8080 | RocketMQ管理界面 |

### Docker Commands (Docker 命令)

```bash
# 进入 Docker 配置目录
cd wher_ever_docker

# 启动所有服务(后台运行)
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看某个服务日志
docker-compose logs mysql
docker-compose logs -f rocketmq    # 实时跟踪日志

# 停止所有服务
docker-compose down

# 完全清除(删除数据 volume)
docker-compose down -v

# 重启某个服务
docker-compose restart mysql
```

### Configuration Files (配置文件详解)

#### 1. docker-compose.yml

核心容器编排文件，定义所有服务的启动参数、网络配置、数据卷挂载等。

**MySQL 部分关键配置:**
```yaml
environment:
  MYSQL_ROOT_PASSWORD: root123456   # root密码
  MYSQL_DATABASE: wher_ever         # 自动创建的数据库
command: --character-set-server=utf8mb4  # 支持emoji等四字节字符
```

**Nacos 部分关键配置:**
```yaml
environment:
  MODE: standalone                  # 单机模式
  NACOS_AUTH_ENABLE: false         # 关闭认证(开发环境)
```

#### 2. mysql/conf/my.cnf

MySQL 服务运行参数配置。

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `character-set-server` | utf8mb4 | 支持emoji等四字节字符 |
| `collation-server` | utf8mb4_unicode_ci | 排序规则 |
| `innodb_buffer_pool_size` | 256M | InnoDB缓存池大小 |
| `max_connections` | 1000 | 最大连接数 |
| `default-time-zone` | +08:00 | 中国时区 |
| `lower_case_table_names` | 1 | 表名大小写不敏感 |

#### 3. mysql/init/01-init.sql

容器首次启动时自动执行的建库建表SQL。

| 表名 | 用途 |
|------|------|
| `sys_user` | 用户表 (用户名/邮箱/密码/订阅级别) |
| `reminder` | 提醒表 (标题/位置/触发类型/状态) |
| `trigger_log` | 触发日志表 (记录到达/离开事件) |

#### 4. redis/conf/redis.conf

Redis 服务运行参数配置。

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `bind` | 0.0.0.0 | 允许外部访问 |
| `protected-mode` | no | 关闭保护模式 |
| `maxmemory` | 256mb | 最大内存256MB |
| `maxmemory-policy` | allkeys-lru | 内存满时淘汰最少使用的key |
| `appendonly` | yes | 开启AOF持久化 |
| `appendfsync` | everysec | 每秒异步刷盘 |

#### 5. rocketmq/conf/broker.conf

RocketMQ Broker 消息存储配置。

| 配置项 | 说明 |
|--------|------|
| `brokerClusterName` | 集群名称 DefaultCluster |
| `brokerIP1` | Broker监听地址(容器内用rocketmq) |
| `listenPort` | Broker监听端口 10911 |
| `flushDiskType` | ASYNC_FLUSH 异步刷盘(性能更好) |

#### 6. nacos/application.properties

Nacos 应用配置 (本项目用于本地开发，实际未连接外部MySQL)。

```properties
spring.application.name=wher-ever
server.port=8848
```

### Infrastructure Architecture (基础设施架构)

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                         │
│                   wher-ever-net                           │
└─────────────────────────────────────────────────────────┘
         │              │              │              │
         ▼              ▼              ▼              ▼
    ┌─────────┐   ┌─────────┐  ┌─────────┐  ┌─────────┐
    │  MySQL  │   │  Redis  │  │  Nacos  │  │ RocketMQ│
    │  :3306  │   │  :6379  │  │  :8848  │  │ :9876   │
    └─────────┘   └─────────┘  └─────────┘  │ :10911  │
                                             └─────────┘
                                                  │
                                                  ▼
                                         ┌─────────────┐
                                         │  Dashboard   │
                                         │   :8080      │
                                         └─────────────┘
```

---

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

---

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

---

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

---

## Build APK

```bash
cd wher_ever
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`
