# WherEver Project

Location-based reminder app with Flutter frontend and Spring Cloud Alibaba backend.

## Project Structure

```text
WherEver/
+-- wher_ever/                    # Flutter App
|   +-- lib/
|   |   +-- models/                # Data models
|   |   +-- pages/                 # UI pages
|   |   |   +-- auth/              # Authentication pages
|   |   |   +-- home/              # Home feature pages
|   |   +-- services/              # Business services
|   |   +-- widgets/               # Reusable widgets
|   +-- pubspec.yaml
|
+-- wher_ever_backend/             # Spring Cloud Backend
|   +-- wher-ever-common/          # Common entities, DTOs
|   +-- wher-ever-api/             # API Gateway skeleton
|   +-- wher-ever-user/            # User Service (8081)
|   +-- wher-ever-notification/    # Reminder Service (8082)
|   +-- wher-ever-location/        # Location Service skeleton
|
+-- wher_ever_docker/              # Docker Compose
    +-- mysql/                     # MySQL 8.0
    +-- redis/                     # Redis 7
    +-- nacos/                     # Nacos 2.2.3
    +-- rocketmq/                  # RocketMQ 5.1.0
```

---

## Quick Start (快速启动)

### 1. Start Infrastructure (Docker)

**PS**: Windows 下需先启动 Docker Desktop。

```bash
cd wher_ever_docker
docker-compose up -d
```

Services:

- MySQL: `localhost:3306` (`root/root123456`)
- Redis: `localhost:6379`
- Nacos: `localhost:8848`
- RocketMQ NameServer: `localhost:9876`
- RocketMQ Broker: `localhost:10911`
- RocketMQ Dashboard: `localhost:8080`

Verify middleware:

```bash
cd wher_ever_docker
docker-compose ps
docker exec wher-ever-mysql mysql -uroot -proot123456 -e "USE wher_ever; SHOW TABLES;"
docker exec wher-ever-redis redis-cli ping
curl.exe http://localhost:8080/cluster/list.query
```

Expected results:

- All containers are `Up`.
- MySQL contains `sys_user`, `reminder`, and `trigger_log`.
- Redis returns `PONG`.
- RocketMQ Dashboard returns JSON with `"status":0`.

### 2. Start Backend Services

```bash
cd wher_ever_backend

# Compile all modules first
mvn clean install -DskipTests
```

Run the two services currently used by the Flutter app in separate terminals:

```bash
cd wher_ever_backend
mvn spring-boot:run -pl wher-ever-user          # Port 8081
```

```bash
cd wher_ever_backend
mvn spring-boot:run -pl wher-ever-notification  # Port 8082
```

Notes:

- `wher-ever-api` and `wher-ever-location` are currently skeleton modules. They can be built, but they are not required for the current Flutter app flow.
- The Flutter app currently talks directly to `wher-ever-user` and `wher-ever-notification`, not through the API Gateway.
- The backend has been verified with MySQL tables created by `wher_ever_docker/mysql/init/01-init.sql`.

### 3. Verify Backend APIs

PowerShell 中建议使用 `curl.exe`，避免和 PowerShell 的 `curl` alias 混淆。

Register:

```bash
curl.exe -X POST http://localhost:8081/api/users/register -H "Content-Type: application/json" -d "{\"username\":\"demo_user\",\"email\":\"demo_user@example.com\",\"password\":\"Pass123456\"}"
```

Login:

```bash
curl.exe -X POST http://localhost:8081/api/users/login -H "Content-Type: application/json" -d "{\"username\":\"demo_user\",\"password\":\"Pass123456\"}"
```

Create reminder. Replace `<USER_ID>` with `data.user.id` returned by register/login:

```bash
curl.exe -X POST http://localhost:8082/api/reminders -H "Content-Type: application/json" -d "{\"userId\":<USER_ID>,\"title\":\"Buy milk\",\"content\":\"Near the store\",\"locationName\":\"Test Location\",\"latitude\":31.2304,\"longitude\":121.4737,\"fenceRadius\":100,\"triggerType\":1,\"status\":1}"
```

List reminders:

```bash
curl.exe "http://localhost:8082/api/reminders?userId=<USER_ID>"
```

Expected result: all responses return `code: 200`, and the reminder list contains the reminder you created.

### 4. Start Flutter App

```bash
cd wher_ever
flutter pub get
flutter run
```

Device/network notes:

- Android emulator: current code uses `http://10.0.2.2:8081` and `http://10.0.2.2:8082`, which is correct for emulator-to-host access.
- Windows desktop or Chrome web: `10.0.2.2` will not point to your host backend. Change `wher_ever/lib/services/api_service.dart` to use `http://localhost:8081` and `http://localhost:8082`, or add environment-based configuration before running on these targets.
- Physical phone: use your computer LAN IP, for example `http://192.168.x.x:8081`, and make sure the firewall allows access.

### 5. App Verification Flow

Use this flow to verify the app after middleware and backend are running:

1. Launch the Flutter app.
2. Use guest mode or the mocked login/register UI to enter the home screen.
3. Create a manual reminder with title and location.
4. Open the reminder list and confirm the reminder appears.
5. If you are using a real backend user id, confirm persistence through:

```bash
curl.exe "http://localhost:8082/api/reminders?userId=<USER_ID>"
```

Current limitation:

- The Flutter auth controller still uses mocked login/register responses, so UI login/register does not yet call `8081`.
- Backend auth APIs are working and can be verified with curl.
- Connecting Flutter login/register to the backend is a separate integration task.

---

## Docker Configuration (Docker 配置详解)

### Directory Structure (目录结构)

```text
wher_ever_docker/
+-- docker-compose.yml          # 主编排文件，定义所有容器
+-- README.md                   # Docker 环境说明文档
+-- mysql/
|   +-- conf/my.cnf             # MySQL 配置文件
|   +-- init/01-init.sql        # 数据库初始化脚本
|   +-- data/                   # MySQL 数据持久化目录
+-- redis/
|   +-- conf/redis.conf         # Redis 配置文件
|   +-- data/                   # Redis 数据持久化目录
+-- nacos/
|   +-- application.properties  # Nacos 配置
|   +-- data/                   # Nacos 数据持久化
|   +-- logs/                   # Nacos 日志
+-- rocketmq/
    +-- conf/broker.conf        # RocketMQ Broker 配置
    +-- store/                  # 消息存储目录
    +-- logs/                   # RocketMQ 日志
```

### Services (服务详情)

| 服务 | 镜像 | 端口 | 用途 |
|------|------|------|------|
| `mysql` | mysql:8.0 | 3306 | 关系型数据库 |
| `redis` | redis:7-alpine | 6379 | KV 缓存 |
| `nacos` | nacos/nacos-server:v2.2.3 | 8848, 9848 | 服务注册/配置中心 |
| `rocketmq` | apache/rocketmq:5.1.0 | 9876 | 消息队列 NameServer |
| `rocketmq-broker` | apache/rocketmq:5.1.0 | 10911 | 消息队列 Broker |
| `rocketmq-dashboard` | apacherocketmq/rocketmq-dashboard | 8080 | RocketMQ 管理界面 |

### Docker Commands (Docker 命令)

```bash
# 进入 Docker 配置目录
cd wher_ever_docker

# 启动所有服务(后台运行)
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看所有服务日志
docker-compose logs -f

# 查看某个服务日志
docker-compose logs mysql
docker-compose logs -f rocketmq
docker-compose logs -f rocketmq-dashboard

# 停止所有服务
docker-compose down

# 完全清除(删除数据 volume/持久化数据，谨慎使用)
docker-compose down -v

# 重启某个服务
docker-compose restart mysql
docker-compose restart rocketmq-dashboard
```

### Web Console Verification (Web 控制台验证)

| 服务 | 访问地址 | 凭据 | 验证方法 |
|------|----------|------|----------|
| Nacos | `http://localhost:8848/nacos` | `nacos / nacos` | 登录后显示服务列表或配置列表 |
| RocketMQ Dashboard | `http://localhost:8080` | 无 | 打开 Dashboard 页面并查看集群状态 |
| MySQL | `localhost:3306` | `root / root123456` | 可以连接并查询数据库 |

### Middleware Health Checks (中间件健康检查)

MySQL:

```bash
docker exec wher-ever-mysql mysql -uroot -proot123456 -e "SELECT 1;"
docker exec wher-ever-mysql mysql -uroot -proot123456 -e "USE wher_ever; SHOW TABLES;"
```

Redis:

```bash
docker exec wher-ever-redis redis-cli ping
```

Nacos:

```bash
curl.exe http://localhost:8848/nacos
```

RocketMQ Dashboard:

```bash
curl.exe http://localhost:8080/cluster/list.query
docker-compose logs rocketmq-dashboard
```

RocketMQ NameServer:

```bash
docker exec wher-ever-rocketmq sh mqadmin clusterList -n rocketmq:9876
```

RocketMQ Broker:

```bash
docker exec wher-ever-rocketmq-broker sh mqadmin brokerStatus -n rocketmq:9876 -b broker-auto
```

### Configuration Files (配置文件详解)

#### 1. docker-compose.yml

核心容器编排文件，定义所有服务的启动参数、网络配置、数据卷挂载等。

**MySQL 部分关键配置:**

```yaml
environment:
  MYSQL_ROOT_PASSWORD: root123456
  MYSQL_DATABASE: wher_ever
command: --default-authentication-plugin=mysql_native_password --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

**Nacos 部分关键配置:**

```yaml
environment:
  MODE: standalone
  NACOS_AUTH_ENABLE: false
```

**RocketMQ Dashboard 部分关键配置:**

```yaml
environment:
  ROCKETMQ_CONFIG_NAMESRVADDR: rocketmq:9876
  ROCKETMQ_CONFIG_VIPCHANNELENABLED: "false"
  JAVA_OPTS: >-
    -Drocketmq.config.namesrvAddr=rocketmq:9876
    -Drocketmq.config.isVIPChannel=false
```

`JAVA_OPTS` 用于显式关闭 RocketMQ VIP Channel，避免 Dashboard 访问 Broker 时连接 `10909` 失败。

#### 2. mysql/conf/my.cnf

MySQL 服务运行参数配置。

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `character-set-server` | utf8mb4 | 支持 emoji 等四字节字符 |
| `collation-server` | utf8mb4_unicode_ci | 排序规则 |
| `innodb_buffer_pool_size` | 256M | InnoDB 缓存池大小 |
| `max_connections` | 1000 | 最大连接数 |
| `default-time-zone` | +08:00 | 中国时区 |
| `lower_case_table_names` | 1 | 表名大小写不敏感 |

#### 3. mysql/init/01-init.sql

容器首次启动时自动执行的建库建表 SQL。

| 表名 | 用途 |
|------|------|
| `sys_user` | 用户表，包含用户名、邮箱、密码、订阅级别 |
| `reminder` | 提醒表，包含标题、位置、触发类型、状态 |
| `trigger_log` | 触发日志表，记录到达/离开事件 |

#### 4. redis/conf/redis.conf

Redis 服务运行参数配置。

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `bind` | 0.0.0.0 | 允许外部访问 |
| `protected-mode` | no | 关闭保护模式 |
| `maxmemory` | 256mb | 最大内存 256MB |
| `maxmemory-policy` | allkeys-lru | 内存满时淘汰最少使用的 key |
| `appendonly` | yes | 开启 AOF 持久化 |
| `appendfsync` | everysec | 每秒异步刷盘 |

#### 5. rocketmq/conf/broker.conf

RocketMQ Broker 消息存储配置。

| 配置项 | 说明 |
|--------|------|
| `brokerClusterName` | 集群名称 DefaultCluster |
| `brokerName` | Broker 名称 broker-auto |
| `listenPort` | Broker 监听端口 10911 |
| `flushDiskType` | ASYNC_FLUSH 异步刷盘，性能更好 |

注意：不要把 `brokerIP1` 写死成 Docker 内网 IP。容器重建后 IP 会变化，可能导致 Dashboard 或客户端连接旧地址失败。

#### 6. nacos/application.properties

Nacos 应用配置。本项目用于本地开发，Docker Compose 中通过环境变量控制单机模式。

```properties
spring.application.name=wher-ever
server.port=8848
```

### Infrastructure Architecture (基础设施架构)

```text
+---------------------------------------------------------+
|                    Docker Network                       |
|                    wher-ever-net                        |
+---------------------------------------------------------+
       |              |              |              |
       v              v              v              v
  +---------+    +---------+    +---------+    +-----------+
  |  MySQL  |    |  Redis  |    |  Nacos  |    | RocketMQ  |
  |  :3306  |    |  :6379  |    |  :8848  |    | :9876     |
  +---------+    +---------+    +---------+    | :10911    |
                                                +-----------+
                                                      |
                                                      v
                                             +----------------+
                                             | MQ Dashboard   |
                                             | :8080          |
                                             +----------------+
```

### Data Persistence (数据持久化)

数据存储在 Docker 配置目录下：

- `mysql/data/` - MySQL 数据文件
- `redis/data/` - Redis 数据文件
- `nacos/data/` - Nacos 数据
- `nacos/logs/` - Nacos 日志
- `rocketmq/store/` - RocketMQ 消息存储
- `rocketmq/logs/` - RocketMQ 日志

### Reset Environment (重置环境)

```bash
cd wher_ever_docker
docker-compose down -v
docker-compose up -d
```

---

## Backend Configuration (后端配置)

### User Service (8081)

Config file:

```text
wher_ever_backend/wher-ever-user/src/main/resources/application.yml
```

Important settings:

```yaml
server:
  port: 8081

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/wher_ever?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: root
    password: root123456
  cloud:
    nacos:
      discovery:
        enabled: false
```

### Notification Service (8082)

Config file:

```text
wher_ever_backend/wher-ever-notification/src/main/resources/application.yml
```

Important settings:

```yaml
server:
  port: 8082

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/wher_ever?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: root
    password: root123456
  cloud:
    nacos:
      discovery:
        enabled: false
```

---

## API Endpoints

### User Service (8081)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/users/register` | Register |
| POST | `/api/users/login` | Login |
| GET | `/api/users/{id}` | Get user |
| GET | `/api/users/username/{username}` | Get user by username |
| PUT | `/api/users/{id}/subscription?level=1` | Update subscription |

### Reminder Service (8082)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/reminders` | Create reminder |
| PUT | `/api/reminders/{id}` | Update reminder |
| DELETE | `/api/reminders/{id}` | Delete reminder |
| GET | `/api/reminders/{id}` | Get reminder |
| GET | `/api/reminders?userId=<USER_ID>` | List user's reminders |
| GET | `/api/reminders/active?userId=<USER_ID>` | List active reminders |

---

## Frontend Notes (前端说明)

### API Base URLs

Current API URLs are configured in:

```text
wher_ever/lib/services/api_service.dart
```

Default values:

```dart
static const String userServiceUrl = 'http://10.0.2.2:8081';
static const String notificationServiceUrl = 'http://10.0.2.2:8082';
```

Use these addresses by target:

| Target | User Service | Notification Service |
|--------|--------------|----------------------|
| Android Emulator | `http://10.0.2.2:8081` | `http://10.0.2.2:8082` |
| Windows Desktop | `http://localhost:8081` | `http://localhost:8082` |
| Chrome / Edge | `http://localhost:8081` | `http://localhost:8082` |
| Physical Phone | `http://<PC_LAN_IP>:8081` | `http://<PC_LAN_IP>:8082` |

### Current Auth Limitation

The Flutter auth controller currently uses mocked login/register responses. Backend auth APIs are available and verified, but the Flutter UI login/register flow still needs to be wired to `8081`.

---

## Features

- [x] User authentication backend APIs
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

## Useful Commands (常用命令)

### Docker

```bash
cd wher_ever_docker
docker-compose up -d
docker-compose ps
docker-compose logs -f
docker-compose down
docker-compose down -v
```

### Backend

```bash
cd wher_ever_backend
mvn clean install -DskipTests
mvn spring-boot:run -pl wher-ever-user
mvn spring-boot:run -pl wher-ever-notification
```

### Flutter

```bash
cd wher_ever
flutter pub get
flutter analyze
flutter run
```

### Build APK

```bash
cd wher_ever
flutter build apk --debug
```

APK:

```text
wher_ever/build/app/outputs/flutter-apk/app-debug.apk
```
