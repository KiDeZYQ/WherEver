---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
workflowType: 'architecture'
lastStep: 8
status: 'complete'
completedAt: '2026-04-15'
inputDocuments: ['_bmad-output/planning-artifacts/prd.md', '_bmad-output/project-context.md']
project_name: 'WherEver'
user_name: 'KiDe'
date: '2026-04-15'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements (39 FRs, 7 categories):**
- Reminder Creation: 命令词/表单创建，支持 Arrive/Leave 触发，围栏半径可自定义，重复规则
- Trigger Engine: Geofencing，进入/离开双模式，后台持久化，系统杀进程后自动恢复，200m 精度 95%
- Notification & User Interaction: 推送通知 + 交互按钮（确认/推迟），三种动效（pop/渐隐/轻推）
- Map & Navigation: 卡片内置迷你地图，点击唤起高德/百度/Google 地图导航
- User Account & Subscription: 游客模式 + 账户体系，Free（5提醒/限100m围栏）vs Premium（无限）
- Permission & System Integration: 位置权限引导，电池优化白名单引导，华为/小米/OPPO 厂商特殊适配
- Data Management: 本地 SQLite 存储（Free），历史 7 天（Free）/30 天（Premium）

**Non-Functional Requirements:**
- Android 后台存活率 ≥ 80%（7日）
- 位置围栏电池消耗低于竞品 20%
- 推送到达率 ≥ 95%
- 触发精度：95% 在预期地点 200m 半径内
- 隐私合规：Android 13+ 通知权限、《个人信息保护法》

**Scale & Complexity:**
- Primary domain: Mobile App (Android) + Backend API (Spring Cloud Alibaba 微服务)
- Complexity level: Medium-High
  - 主要复杂度来源：Android 各厂商后台管理差异 + 国内厂商推送通道集成
  - 次要复杂度：Flutter 跨平台 + 地图 SDK 多源集成 + 订阅支付系统 + Spring Cloud Alibaba 服务治理
- Estimated architectural components: 15-18（因微服务拆分增加）

### Technical Constraints & Dependencies

**硬性约束：**
- 必须兼容 Android 6.0+（国内存量设备），targetSdk 34（Android 14）
- 国内 Android 无法依赖 FCM，需要极光/个推等厂商通道
- 高德地图（国内）+ Google Maps（海外）的双地图支持
- Android 10+ 必须使用 ACCESS_BACKGROUND_LOCATION 权限
- 位置数据必须本地加密存储以符合《个人信息保护法》

**依赖关系：**
- Flutter：Google 主推，Dart 语言，性能接近 Native
- Spring Cloud Alibaba：Nacos（注册/配置）+ Sentinel（熔断限流）+ Seata（分布式事务）+ Spring AI Alibaba（AI 能力）
- PostgreSQL + Redis：用户数据 + 会话缓存
- 极光/个推：国内 Android 推送通道

### Cross-Cutting Concerns Identified

1. **后台服务持久化**：AlarmManager + Foreground Service + 厂商自启动 + 电池白名单，四层保障
2. **位置精度与电池平衡**：融合定位（GPS+WiFi+基站），动态调整采样频率
3. **多厂商适配层**：华为/小米/OPPO/vivo 每个都有自己后台管理逻辑，需要单独适配
4. **订阅支付**：Flutter in-app purchase + 支付宝/微信支付（国内）
5. **地图导航统一接口**：高德/百度/Google 三套 SDK 统一封装
6. **异步事件驱动**：通过 MQ 解耦服务间调用，避免同步阻塞

## Starter Template Evaluation

### Primary Technology Domain

**移动端 App（Android）+ 后端微服务**，基于 Flutter + Spring Cloud Alibaba 技术栈

### 技术选型确认

| 层级 | 技术选型 | 状态 |
|------|---------|------|
| 移动端 | Flutter | ✅ 已明确 |
| 后端框架 | Spring Cloud Alibaba + Spring AI Alibaba | ✅ 已明确 |
| 数据库 | PostgreSQL + Redis | ✅ 已明确 |
| 地图 | 高德（国内）+ Google Maps（海外） | ✅ 已明确 |
| 推送 | 极光/个推（国内）+ FCM（海外） | ✅ 已明确 |

### Flutter 起步方式

**初始化命令：**

```bash
flutter create --org com.wherEver --project-name wher_ever --platforms android wher_ever
```

**核心依赖（需在 pubspec.yaml 中添加）：**

| 依赖 | 用途 |
|------|------|
| `flutter_local_notifications` | 通知系统 |
| `google_maps_flutter` | Google 地图 |
| `amap_flutter_map` | 高德地图 |
| `geolocator` | 定位服务 |
| `sqflite` | 本地 SQLite 存储 |
| `jmessage` 或 `jpush` | 极光推送 |
| `getui` | 个推通道 |
| `get` | 状态管理 + 路由 + 依赖注入（一体化） |
| `dio` | HTTP 客户端 |
| `encrypt` | 数据加密 |

### Spring Cloud Alibaba 起步方式

**项目初始化：** 通过 [Spring Initializr](https://start.spring.io/) 创建多模块 Maven 项目

**推荐微服务拆分：**

```
wher-ever
├── wher-ever-gateway        # API 网关（Nacos + Gateway）
├── wher-ever-user          # 用户服务（注册/登录/订阅）
├── wher-ever-reminder      # 提醒服务（CRUD + 围栏管理）
├── wher-ever-notification  # 推送服务（极光/个推/FCM 协调）
├── wher-ever-ai            # AI 服务（Spring AI Alibaba 命令词解析）
├── wher-ever-common        # 公共模块（实体/工具类/Feign 客户端）
└── wher-ever-geo           # 地理围栏服务（空间索引 + 触发计算）[新增]
```

**核心依赖：**

| 组件 | 依赖 |
|------|------|
| Nacos 注册/配置 | `spring-cloud-starter-alibaba-nacos-discovery` + `spring-cloud-starter-alibaba-nacos-config` |
| Sentinel 熔断限流 | `spring-cloud-starter-alibaba-sentinel` |
| Seata 分布式事务 | `spring-cloud-starter-alibaba-seata` |
| Spring AI Alibaba | `spring-ai-alibaba-starter` |
| API 网关 | `spring-cloud-starter-gateway` |
| PostgreSQL | `mybatis-plus-boot-starter` + `postgresql` |
| Redis | `spring-boot-starter-data-redis` |
| **消息队列** | **RocketMQ / Apache Pulsar**（解耦 AI/通知异步调用）|
| **空间索引** | **Redis GEO + PostGIS**（地理围栏计算）|

### 结论

技术栈已由用户明确，采用标准起步方式：
- Flutter：`flutter create` 标准初始化
- Spring Cloud Alibaba：Spring Initializr 多模块项目

**Note:** 项目初始化应作为第一个实施故事（Story）执行。

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Flutter 状态管理、路由、依赖注入方案
- 后端数据库访问层
- 微服务间通信方式
- 认证授权方案

**Important Decisions (Shape Architecture):**
- 容器化部署方案
- API 风格
- 本地数据结构

**Deferred Decisions (Post-MVP):**
- Kubernetes 迁移
- iOS 版本支持
- AI 预测层（Pro 版本）

### Frontend Architecture（Flutter）

| 决策项 | 选择 | 理由 |
|--------|------|------|
| **状态管理** | GetX | 路由+状态+依赖注入一体化，MVP 开发效率最高 |
| **网络层** | Dio | Flutter 标配，支持拦截器/超时/重试，社区最成熟 |
| **路由** | GetX 路由 | 与 GetX 状态管理统一体系，减少学习成本 |
| **本地存储** | sqflite | 轻量 SQLite，Flutter 官方维护，MVP 够用 |

### Backend Architecture（Spring Cloud Alibaba）

| 决策项 | 选择 | 理由 |
|--------|------|------|
| **数据库访问** | MyBatis-Plus | SQL 掌控度强，复杂查询灵活，与 Spring Boot 集成好 |
| **服务通信** | OpenFeign + MQ | 同步调用用 Feign，异步事件用 MQ 解耦 |
| **API 风格** | REST | 移动端场景固定，REST 最简单直接 |
| **认证方案** | JWT + Redis 黑名单 | 无状态 JWT 适合微服务，Redis 黑名单实现 Token 注销 |
| **容器化** | Docker + docker-compose | MVP 阶段快速部署，简化环境配置 |
| **地理围栏计算** | Redis GEO + PostGIS | 空间索引加速附近地点查询，支撑 200m 精度 95% NFR |

### Authentication & Security

| 决策项 | 选择 | 说明 |
|--------|------|------|
| **Token 类型** | JWT Access Token + Refresh Token | Access Token 15min，Refresh Token 7day |
| **Token 存储** | Redis 黑名单 | 用于 Token 即时注销 |
| **密码加密** | BCrypt | Spring Security 标准 |
| **数据传输** | HTTPS | 全站强制 HTTPS |
| **位置数据加密** | AES-256 | 本地 SQLite 数据加密 |

### API & Communication Patterns

**移动端 API 设计：**

```
/api/v1/auth          # 认证相关
/api/v1/users         # 用户信息
/api/v1/reminders     # 提醒 CRUD
/api/v1/geofences     # 围栏管理
/api/v1/notifications  # 通知记录
```

**服务间通信：**
- 使用 OpenFeign 声明式调用（同步场景：用户验证、紧急推送）
- 使用 MQ 异步解耦（异步场景：AI 命令词解析、批量通知触发）
- 通过 Nacos 进行服务发现
- Sentinel 实现熔断限流保护

### Infrastructure & Deployment

**MVP 阶段部署架构：**

```
┌─────────────────────────────────────┐
│           Nginx (反向代理)            │
└─────────────────────────────────────┘
                  │
┌─────────────────────────────────────┐
│       Docker Compose Stack          │
│  ├── wher-ever-gateway             │
│  ├── wher-ever-user                │
│  ├── wher-ever-reminder            │
│  ├── wher-ever-notification         │
│  ├── wher-ever-ai                  │
│  ├── wher-ever-geo                 │
│  ├── nacos-server                  │
│  ├── rocketmq / pulsar            │
│  ├── PostgreSQL (+ PostGIS)        │
│  └── Redis                         │
└─────────────────────────────────────┘
```

**Note:** 后续可迁移至阿里云 ACK（Kubernetes）实现弹性扩缩容。

### Decision Impact Analysis

**Implementation Sequence:**
1. 项目脚手架搭建（Flutter + Spring Cloud Alibaba 多模块）
2. 微服务基础设施（Nacos + Gateway + OpenFeign + MQ）
3. 用户服务（注册/登录/JWT）
4. 提醒服务（CRUD + 围栏管理）
5. 地理围栏服务（空间索引 + 触发计算）
6. 推送服务（极光/个推集成）
7. AI 服务（命令词解析）
8. App UI + 动效 + 地图集成

**Cross-Component Dependencies:**
- 用户服务是最底层依赖，所有服务依赖它做认证
- 提醒服务与推送服务通过 MQ 异步解耦（不直接同步调用）
- AI 服务通过 MQ 异步接收解析任务，结果回调通知服务
- 地理围栏服务（wher-ever-geo）独立，提供空间计算能力

## Implementation Patterns & Consistency Rules

### Critical Conflict Points Identified

**6 大潜在冲突领域**，AI Agent 若不统一规范则会产生冲突：
1. 数据库命名
2. API 命名与响应格式
3. JSON 字段命名
4. Flutter 项目结构
5. 状态与错误处理模式
6. 微服务内部结构

### Naming Conventions（命名规范）

**数据库命名：**

| 对象 | 规范 | 示例 |
|------|------|------|
| 表名 | 小写单数 | `user`, `reminder`, `geofence` |
| 列名 | 小写蛇形 | `user_id`, `created_at`, `reminder_text` |
| 外键 | `表名单数_id` | `user_id`, `geofence_id` |
| 索引 | `idx_表名_列名` | `idx_reminder_user_id` |

**API 命名：**

| 对象 | 规范 | 示例 |
|------|------|------|
| 端点路径 | 小写复数 | `/api/v1/users`, `/api/v1/reminders` |
| 路径参数 | 小写 | `/api/v1/reminders/{id}` |
| HTTP 方法 | GET/POST/PUT/DELETE | GET 查询、POST 创建、PUT 更新、DELETE 删除 |

**JSON 字段命名：**

| 规范 | 示例 |
|------|------|
| camelCase | `reminderText`, `createdAt`, `userId`, `geofenceRadius` |

**Flutter 代码命名：**

| 对象 | 规范 | 示例 |
|------|------|------|
| 文件名 | 小写下划线 | `user_controller.dart`, `reminder_service.dart` |
| 类名 | 大驼峰 | `UserController`, `ReminderService` |
| 变量名 | 小驼峰 | `userId`, `reminderList` |
| 常量 | 全大写下划线 | `MAX_RETRY_COUNT`, `API_BASE_URL` |

### API Response Format（API 响应格式）

**成功响应：**

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**错误响应：**

```json
{
  "code": 40001,
  "message": "Reminder not found",
  "data": null
}
```

**分页响应：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```

**HTTP 状态码规范：**
- `200` — 成功
- `201` — 创建成功
- `400` — 请求参数错误
- `401` — 未认证
- `403` — 无权限
- `404` — 资源不存在
- `500` — 服务器内部错误

### Data Transfer Format（数据交换格式）

**后端 → 前端 JSON 字段：camelCase**
**前端 → 后端 JSON 字段：camelCase**
**数据库字段：snake_case**

MyBatis-Plus 配置开启驼峰自动映射：
```yaml
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true
```

### Flutter Project Structure（Flutter 项目结构）

```
lib/
├── main.dart
├── app/
│   ├── routes/          # GetX 路由配置
│   ├── bindings/         # 依赖注入 bindings
│   └── theme/            # 主题配置
├── core/
│   ├── constants/        # 常量
│   ├── utils/            # 工具类
│   ├── network/          # Dio 配置 + 拦截器
│   └── storage/          # 本地存储
├── data/
│   ├── models/           # 数据模型
│   ├── providers/        # API 调用
│   └── repositories/     # 仓储实现
├── modules/
│   ├── auth/             # 认证模块
│   ├── home/             # 首页模块
│   ├── reminder/         # 提醒模块
│   └── settings/          # 设置模块
└── widgets/               # 公共组件
```

### State Management Patterns（状态管理模式）

**GetX 状态类规范：**

```dart
class ReminderController extends GetxController {
  // 状态
  final reminders = <Reminder>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  // 动作
  Future<void> fetchReminders() async { ... }
  Future<void> createReminder(Reminder reminder) async { ... }
}
```

**Loading/Error/Success 三态处理：**

```dart
// View 层
Obx(() {
  if (controller.isLoading.value) {
    return LoadingWidget();
  }
  if (controller.error.value != null) {
    return ErrorWidget(message: controller.error.value!);
  }
  return ReminderListView(reminders: controller.reminders);
})
```

### Error Handling Patterns（错误处理模式）

**后端统一异常处理：**

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    public Result<?> handle(ReminderNotFoundException e) {
        return Result.error(40401, "Reminder not found");
    }
}
```

**Flutter Dio 拦截器统一处理：**

```dart
class DioInterceptors extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token 过期，跳转登录
    }
    handler.next(err);
  }
}
```

### Enforcement Guidelines（强制执行指南）

**所有 AI Agent 必须遵守：**
1. 数据库表名单数小写，列名小写蛇形
2. API 路径小写复数，JSON 字段 camelCase
3. Flutter 文件小写下划线，类名大驼峰
4. API 统一响应 `{ code, message, data }` 包装
5. GetX 状态类遵循 `isLoading` + `error` + `Rxn<T>` 模式
6. 所有 API 调用通过 Dio 拦截器统一处理 Token 和错误

**Pattern Enforcement：**
- 通过代码审查验证模式遵循
- 违反模式在 PR 中指出并要求修正

## Project Structure & Boundaries

### Flutter App 项目结构

```
wher_ever/                          # Flutter 移动端
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── routes/
│   │   │   ├── app_pages.dart     # GetX 路由页面定义
│   │   │   └── app_routes.dart    # 路由常量
│   │   ├── bindings/
│   │   │   ├── initial_binding.dart
│   │   │   └── home_binding.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       └── app_theme.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── utils/
│   │   │   ├── crypto_util.dart
│   │   │   └── location_util.dart
│   │   ├── network/
│   │   │   ├── api_client.dart      # Dio 单例
│   │   │   ├── api_interceptor.dart
│   │   │   └── result.dart         # 统一响应封装
│   │   └── storage/
│   │       └── local_storage.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── reminder_model.dart
│   │   │   └── geofence_model.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── reminder_provider.dart
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       └── reminder_repository.dart
│   ├── modules/
│   │   ├── auth/
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart
│   │   │   ├── views/
│   │   │   │   ├── login_view.dart
│   │   │   │   └── register_view.dart
│   │   │   └── bindings/
│   │   │       └── auth_binding.dart
│   │   ├── home/
│   │   │   ├── controllers/
│   │   │   │   └── home_controller.dart
│   │   │   └── views/
│   │   │       └── home_view.dart
│   │   ├── reminder/
│   │   │   ├── controllers/
│   │   │   │   └── reminder_controller.dart
│   │   │   ├── views/
│   │   │   │   ├── reminder_list_view.dart
│   │   │   │   └── reminder_create_view.dart
│   │   │   ├── bindings/
│   │   │   └── reminder_binding.dart
│   │   └── settings/
│   │       ├── controllers/
│   │       │   └── settings_controller.dart
│   │       └── views/
│   │           └── settings_view.dart
│   └── widgets/
│       ├── reminder_card.dart
│       ├── loading_widget.dart
│       └── error_widget.dart
├── android/
├── pubspec.yaml
└── test/
```

### Spring Cloud Alibaba 后端项目结构

```
wher-ever/                          # 后端父项目
├── pom.xml                         # 父 POM
├── docker/
│   └── docker-compose.yml
├── nacos/
│   └── config.yaml                 # Nacos 配置
├── wher-ever-common/               # 公共模块
│   ├── pom.xml
│   └── src/main/java/com/wherEver/common/
│       ├── result/                 # 统一响应 Result
│       ├── constant/               # 通用常量
│       ├── exception/              # 全局异常
│       ├── util/                   # 通用工具
│       └── model/                  # 通用实体（DO/DTO/VO）
├── wher-ever-gateway/              # API 网关
│   ├── pom.xml
│   └── src/main/java/com/wherEver/gateway/
│       ├── GatewayApplication.java
│       ├── config/
│       │   └── GatewayConfig.java
│       └── filter/
│           └── AuthFilter.java
├── wher-ever-user/                 # 用户服务
│   ├── pom.xml
│   └── src/main/java/com/wherEver/user/
│       ├── UserApplication.java
│       ├── controller/
│       │   └── UserController.java
│       ├── service/
│       │   ├── UserService.java
│       │   └── UserServiceImpl.java
│       ├── repository/
│       │   └── UserMapper.java
│       ├── model/
│       │   ├── entity/User.java
│       │   ├── dto/LoginDTO.java
│       │   └── vo/UserVO.java
│       └── config/
│           └── SecurityConfig.java
├── wher-ever-reminder/             # 提醒服务
│   ├── pom.xml
│   └── src/main/java/com/wherEver/reminder/
│       ├── ReminderApplication.java
│       ├── controller/
│       │   └── ReminderController.java
│       ├── service/
│       │   ├── ReminderService.java
│       │   └── ReminderServiceImpl.java
│       ├── repository/
│       │   └── ReminderMapper.java
│       ├── model/
│       │   ├── entity/Reminder.java
│       │   ├── dto/CreateReminderDTO.java
│       │   └── vo/ReminderVO.java
│       └── config/
│           └── MyBatisConfig.java
├── wher-ever-notification/          # 推送服务
│   ├── pom.xml
│   └── src/main/java/com/wherEver/notification/
│       ├── NotificationApplication.java
│       ├── controller/
│       │   └── NotificationController.java
│       ├── service/
│       │   ├── NotificationService.java
│       │   └── impl/
│       │       ├── JiguangService.java   # 极光
│       │       ├── GetuiService.java     # 个推
│       │       └── FCMService.java      # FCM
│       └── model/
│           └── NotificationRecord.java
├── wher-ever-ai/                   # AI 服务
│   ├── pom.xml
│   └── src/main/java/com/wherEver/ai/
│       ├── AiApplication.java
│       ├── controller/
│       │   └── AiController.java
│       └── service/
│           ├── CommandParserService.java  # 命令词解析
│           └── impl/
│               └── SpringAIService.java
└── wher-ever-geo/                   # 地理围栏服务 [新增]
    ├── pom.xml
    └── src/main/java/com/wherEver/geo/
        ├── GeoApplication.java
        ├── controller/
        │   └── GeoController.java
        ├── service/
        │   ├── GeofenceService.java
        │   └── impl/
        │       └── GeofenceServiceImpl.java
        ├── repository/
        │   └── GeofenceRepository.java
        └── model/
            ├── entity/Geofence.java
            └── dto/NearbyGeofenceDTO.java
```

### Requirements to Structure Mapping

| 功能需求 | 所在模块/服务 |
|---------|--------------|
| 用户注册/登录/JWT | `wher-ever-user` |
| 提醒 CRUD | `wher-ever-reminder` |
| 围栏管理 | `wher-ever-reminder` |
| **空间索引 + 触发计算** | `wher-ever-geo` |
| 推送通知 | `wher-ever-notification` |
| 命令词解析 | `wher-ever-ai` |
| API 网关路由 | `wher-ever-gateway` |
| Flutter 端状态管理 | `modules/reminder/` |
| Flutter 端地图集成 | `modules/reminder/` |
| Flutter 端本地存储 | `core/storage/` |

### Integration Boundaries

**Flutter ↔ 后端：**
- Flutter 通过 Dio 调用 `wher-ever-gateway` 暴露的 REST API
- Token 在 Dio 拦截器中自动注入 Header

**后端微服务内部（同步）：**
- `reminder` 服务通过 OpenFeign 调用 `user` 服务验证 Token（同步，需低延迟）
- `geo` 服务通过 OpenFeign 调用 `user` 服务验证用户身份

**后端微服务内部（异步，MQ 解耦）：**
- `reminder` 服务创建提醒 → MQ → `notification` 服务异步消费 → 推送
- `reminder` 服务创建提醒 → MQ → `ai` 服务异步消费 → 命令词解析结果回写
- `geo` 服务围栏触发 → MQ → `notification` 服务异步消费 → 推送

**MQ 主题设计：**

| Topic | 生产者 | 消费者 | 用途 |
|-------|--------|--------|------|
| `reminder-create` | reminder | notification, ai | 创建提醒触发解析和通知 |
| `reminder-trigger` | geo | notification | 围栏触发时发送推送 |
| `ai-parse-result` | ai | reminder | AI 解析结果回写 |
