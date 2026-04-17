---
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories', 'step-04-final-validation']
inputDocuments: ['_bmad-output/planning-artifacts/prd.md', '_bmad-output/planning-artifacts/architecture.md', '_bmad-output/project-context.md']
project_name: 'WherEver'
status: 'complete'
---

# WherEver - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for WherEver, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**Reminder Creation (FR1-FR8):**
FR1: Users can create reminders using simple voice commands or structured form input
FR2: System accepts basic command patterns like "remind me to [action] when I arrive at [location]"
FR3: System parses command and displays structured reminder confirmation card before saving
FR4: Users can edit reminder details (trigger type, location, repeat rule) before confirming
FR5: Users can set two trigger modes: Arrive (entering location) or Leave (exiting location)
FR6: Users can specify reminder location by selecting point on map or searching address
FR7: Users can set custom geofence radius for each reminder (minimum 100m)
FR8: Users can set repeat rules: one-time, daily, weekly, until confirmed

**Trigger Engine (FR9-FR13):**
FR9: System triggers reminder notifications when user enters configured geofence (Arrive)
FR10: System triggers reminder notifications when user exits configured geofence (Leave)
FR11: System maintains geofence monitoring while app is in background
FR12: System handles Android system killing background processes and restores geofences automatically
FR13: System accurately triggers within 200m of configured location for 95% of triggers

**Notification & User Interaction (FR14-FR20):**
FR14: System sends push notification with interactive action buttons (Confirm / Defer)
FR15: Notification displays reminder content, location, and trigger type
FR16: System plays trigger animation (pop + vibration) when notification is presented
FR17: System plays completion animation (slide up + fade + success vibration) when user confirms
FR18: System plays defer animation (shake + quiet shrink) when user defers, no vibration
FR19: Users can defer reminder by set time intervals (15min / 30min / 1hr / tomorrow)
FR20: Users can skip current occurrence without affecting repeat rule

**Map & Navigation Integration (FR21-FR23):**
FR21: Reminder card displays selected location on embedded mini-map
FR22: Users can tap navigation button on reminder card to launch default map app (Amap/Google Maps)
FR23: System uses user's preferred default map app for navigation

**User Account & Subscription (FR24-FR30):**
FR24: System supports guest mode (local-only storage, no account required)
FR25: System supports account creation and login
FR26: Free tier users can have maximum 5 active reminders
FR27: Free tier users can create geofences with max 100m radius
FR28: Premium users have unlimited reminders and geofences
FR29: Premium users can sync reminder data across devices (Phase 2)
FR30: System displays relevant ads in Free tier

**Permission & System Integration (FR31-FR36):**
FR31: System guides users through location permission grant with clear explanation of why permission is needed
FR32: System detects when background location permission is missing and guides user to enable it
FR33: System detects battery optimization interference and guides user to whitelist the app
FR34: System detects power management restrictions from device manufacturers (Huawei/MiUI/OPPO) and provides manufacturer-specific guidance
FR35: System registers for boot completion broadcast to restore geofences after device restart
FR36: System maintains foreground service to ensure geofence monitoring continuity

**Data Management & History (FR37-FR39):**
FR37: System stores all reminder data locally on device
FR38: System maintains reminder history for 7 days (Free) / 30 days (Premium)
FR39: Premium users can export reminder history as CSV or JSON (Phase 2)

### NonFunctional Requirements

NFR1: Android后台存活率 ≥ 80%（7日）
NFR2: 位置围栏电池消耗低于竞品20%
NFR3: 推送到达率 ≥ 95%
NFR4: 触发精度：95%在预期地点200m半径内
NFR5: 隐私合规：Android 13+通知权限、《个人信息保护法》
NFR6: 兼容Android 6.0+，targetSdk 34
NFR7: JWT Access Token 15min，Refresh Token 7day
NFR8: 数据库表名单数小写，列名小写蛇形
NFR9: API路径小写复数，JSON字段camelCase
NFR10: Flutter文件小写下划线，类名大驼峰

### Additional Requirements

**Project Initialization:**
- Flutter项目初始化：`flutter create --org com.wherEver --project-name wher_ever --platforms android wher_ever`
- Spring Cloud Alibaba多模块Maven项目起步（通过Spring Initializr创建）

**Infrastructure:**
- Nacos注册/配置中心集成
- Redis GEO + PostGIS地理围栏计算
- Docker + docker-compose部署

**Push Notifications:**
- 极光/个推（国内）+ FCM（海外）推送通道

**Maps:**
- 高德地图（国内）+ Google Maps（海外）双地图支持

**Database:**
- MyBatis-Plus + PostgreSQL数据库访问
- 位置数据AES-256本地加密

**Authentication:**
- JWT + Redis黑名单无状态认证
- BCrypt密码加密

**Microservices Structure:**
- wher-ever-gateway (API网关)
- wher-ever-user (用户服务)
- wher-ever-reminder (提醒服务)
- wher-ever-notification (推送服务)
- wher-ever-ai (AI服务)
- wher-ever-geo (地理围栏服务)
- wher-ever-common (公共模块)

### UX Design Requirements

注：未找到独立UX设计文档。Epic和Story基于PRD功能需求和用户旅程构建。

**UI/UX Constraints from PRD:**
- 金融App质感UI：深色主题 + 圆角卡片
- 动效语言系统：触发(pop+震动)/确认(渐隐)/推迟(轻推)三态
- 卡片式界面，差异化于Todoist列表式界面
- 传递信任感和品质感

### FR Coverage Map

| FR ID | 描述 | Epic归属 |
|-------|------|---------|
| FR1 | 命令词/表单创建提醒 | Epic 3 |
| FR2 | 命令模式解析 | Epic 3 |
| FR3 | 解析后确认卡片 | Epic 3 |
| FR4 | 编辑提醒详情 | Epic 3 |
| FR5 | Arrive/Leave双模式 | Epic 3 |
| FR6 | 地图选点或地址搜索 | Epic 3 |
| FR7 | 自定义围栏半径 | Epic 3 |
| FR8 | 重复规则设置 | Epic 3 |
| FR9 | 进入围栏触发(Arrive) | Epic 4 |
| FR10 | 离开围栏触发(Leave) | Epic 4 |
| FR11 | 后台保持围栏监控 | Epic 4 |
| FR12 | 系统杀进程后自动恢复 | Epic 4 |
| FR13 | 200m精度95%触发 | Epic 4 |
| FR14 | 推送通知+交互按钮 | Epic 5 |
| FR15 | 通知显示内容/位置/类型 | Epic 5 |
| FR16 | 触发动效(pop+震动) | Epic 5 |
| FR17 | 确认动效(渐隐+成功震动) | Epic 5 |
| FR18 | 推迟动效(轻推，无震动) | Epic 5 |
| FR19 | 推迟时间选项 | Epic 5 |
| FR20 | 跳过当前occurrence | Epic 5 |
| FR21 | 卡片内置迷你地图 | Epic 6 |
| FR22 | 唤起地图导航 | Epic 6 |
| FR23 | 使用默认地图应用 | Epic 6 |
| FR24 | 游客模式 | Epic 2 |
| FR25 | 账户创建与登录 | Epic 2 |
| FR26 | Free最多5个提醒 | Epic 2 |
| FR27 | Free围栏最大100m | Epic 2 |
| FR28 | Premium无限 | Epic 2 |
| FR29 | Premium跨设备同步(Phase2) | Epic 2 |
| FR30 | Free层显示广告 | Epic 2 |
| FR31 | 位置权限引导 | Epic 4 |
| FR32 | 后台位置权限缺失引导 | Epic 4 |
| FR33 | 电池优化白名单引导 | Epic 4 |
| FR34 | 厂商特殊适配引导 | Epic 4 |
| FR35 | 开机自启注册 | Epic 4 |
| FR36 | 前台服务保活 | Epic 4 |
| FR37 | 本地SQLite存储 | Epic 7 |
| FR38 | 历史保留7天/30天 | Epic 7 |
| FR39 | Premium导出历史(Phase2) | Epic 7 |

## Epic List

### Epic 1: 项目脚手架与基础设施搭建
**用户成果：** 开发环境就绪，为后续所有功能奠定基础
**FR覆盖：** 无直接FR覆盖（技术基础设施，为所有Epic提供支撑）
**内容：** Flutter项目初始化 + Spring Cloud Alibaba多模块搭建 + Nacos/Redis/PostgreSQL配置 + Docker环境

### Epic 2: 用户账户与订阅系统
**用户成果：** 用户可以注册账号、登录、管理订阅层级
**FR覆盖：** FR24, FR25, FR26, FR27, FR28, FR29, FR30
**内容：** 游客模式、账户注册登录、Free/Premium层级限制、订阅状态管理

### Epic 3: 提醒创建与管理
**用户成果：** 用户可以创建、编辑、删除位置提醒
**FR覆盖：** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8
**内容：** 命令词解析 + 表单创建 + 地图选点 + 围栏半径设置 + 重复规则

### Epic 4: 地理围栏触发引擎
**用户成果：** 提醒可以在正确的位置和时间可靠触发
**FR覆盖：** FR9, FR10, FR11, FR12, FR13, FR31, FR32, FR33, FR34, FR35, FR36
**内容：** Geofencing双模式触发（Arrive/Leave）+ Android后台保活 + 厂商权限引导 + 开机自启恢复

### Epic 5: 通知与用户交互
**用户成果：** 用户收到精美动效提醒并可进行确认/推迟操作
**FR覆盖：** FR14, FR15, FR16, FR17, FR18, FR19, FR20
**内容：** 推送通知 + 交互按钮 + 三态动效（pop/渐隐/轻推）+ 推迟选项

### Epic 6: 地图与导航集成
**用户成果：** 用户可在App内预览位置并一键导航
**FR覆盖：** FR21, FR22, FR23
**内容：** 卡片迷你地图 + 高德/百度/Google地图唤起 + 导航按钮

### Epic 7: 数据管理与历史
**用户成果：** 用户可以查看和管理提醒历史
**FR覆盖：** FR37, FR38, FR39
**内容：** 本地SQLite存储 + 历史记录保留策略（7天Free/30天Premium）+ 隐私合规

<!-- Epic 1 Stories -->

## Epic 1: 项目脚手架与基础设施搭建

**Epic目标：** 开发环境就绪，为后续所有功能奠定基础

**FR覆盖：** 无直接FR（技术基础设施，为所有Epic提供支撑）

### Story 1.1: Flutter项目初始化

As a developer,
I want a Flutter project scaffolded with correct package name and Android platform,
So that I can start implementing the WherEver app.

**Acceptance Criteria:**

**Given** Flutter SDK 3.x和Android SDK已配置
**When** 执行 `flutter create --org com.wherEver --project-name wher_ever --platforms android wher_ever`
**Then** 项目在 `wher_ever/` 目录创建成功
**And** 包名为 `com.wherEver`
**And** Android minSdkVersion >= 23 (Android 6.0)
**And** targetSdkVersion = 34 (Android 14)

**Given** 项目创建完成
**When** 添加核心依赖（flutter_local_notifications, geolocator, sqflite, get, dio, google_maps_flutter, amap_flutter_map）
**Then** `pubspec.yaml` 包含所有依赖
**And** `flutter pub get` 执行成功
**And** Android build正常编译

### Story 1.2: Spring Cloud Alibaba多模块项目初始化

As a backend developer,
I want a multi-module Maven project with all microservice modules,
So that I can implement the WherEver backend services.

**Acceptance Criteria:**

**Given** JDK 17+和Maven 3.8+已安装
**When** 通过Spring Initializr创建父项目 `wher-ever`
**Then** 父POM包含 `<packaging>pom</packaging>`
**And** 包含7个子模块：common, gateway, user, reminder, notification, ai, geo

**Given** 父项目结构创建完成
**When** 配置每个子模块的基础依赖（Spring Boot 3.2+, Spring Cloud Alibaba 2023.x）
**Then** `wher-ever-common` 包含公共实体、工具类、Result封装
**And** `wher-ever-gateway` 配置好Nacos + Gateway路由
**And** 各服务POM正确继承父POM

### Story 1.3: Docker开发环境配置

As a developer,
I want Docker Compose configuration for all backend infrastructure,
So that I can run the full backend stack locally.

**Acceptance Criteria:**

**Given** Docker Desktop已安装并运行
**When** 执行 `docker-compose -f docker-compose.yml up -d`
**Then** PostgreSQL容器运行在5432端口
**And** Redis容器运行在6379端口
**And** Nacos容器运行在8848端口
**And** 所有服务可正常启动和连接

**Given** docker-compose配置完成
**When** 配置PostgreSQL初始化脚本
**Then** 创建 `wher_ever` 数据库
**And** 启用PostGIS扩展（用于地理围栏计算）

### Story 1.4: 项目统一命名规范配置

As a developer,
I want project-wide naming conventions configured,
So that all code follows consistent standards.

**Acceptance Criteria:**

**Given** Flutter和Spring项目初始化完成
**When** 配置Flutter GetX路由和Dio网络层
**Then** 路由使用小写复数路径（如 `/api/v1/reminders`）
**And** API响应字段使用camelCase

**Given** 后端项目初始化完成
**When** 配置MyBatis-Plus
**Then** 开启 `map-underscore-to-camel-case: true`
**And** 数据库表名使用小写单数（如 `user`, `reminder`, `geofence`）
**And** 列名使用snake_case（如 `user_id`, `created_at`）

<!-- Epic 2 Stories -->

## Epic 2: 用户账户与订阅系统

**Epic目标：** 用户可以注册账号、登录、管理订阅层级

**FR覆盖：** FR24, FR25, FR26, FR27, FR28, FR29, FR30

### Story 2.1: 游客模式支持

As a guest user,
I want to use the app without creating an account,
So that I can try the app functionality immediately without commitment.

**Acceptance Criteria:**

**Given** 用户首次打开App
**When** 用户不登录直接使用
**Then** 所有功能可用（本地模式）
**And** 提醒数据存储在本地SQLite
**And** 提醒限制为最多5个（Free层级）
**And** 围栏半径限制为最大100m

**Given** 游客用户使用App
**When** 用户创建第6个提醒
**Then** 系统提示"免费用户最多5个提醒，请升级Premium"
**And** 显示升级入口

### Story 2.2: 用户注册与登录

As a user,
I want to create an account and login,
So that I can sync my reminders across devices and access Premium features.

**Acceptance Criteria:**

**Given** 用户在App注册页面
**When** 用户输入有效手机号/邮箱和密码（至少8位）
**Then** 系统创建账户并返回JWT Access Token（15min）和Refresh Token（7day）
**And** 用户自动登录状态

**Given** 用户在App登录页面
**When** 用户输入正确的手机号/邮箱和密码
**Then** 系统验证成功并返回JWT Token
**And** Dio拦截器自动保存Token到本地存储
**And** 跳转至首页

**Given** 用户登录后
**When** Refresh Token过期（7天）
**Then** 用户被要求重新登录
**And** 原有本地数据保留

### Story 2.3: JWT认证与Token管理

As a user,
I want secure authentication with JWT tokens,
So that my account is protected and I can stay logged in conveniently.

**Acceptance Criteria:**

**Given** 用户登录成功
**When** 每次API请求
**Then** Dio拦截器自动在Header注入 `Authorization: Bearer {accessToken}`
**And** 401响应时自动使用Refresh Token刷新

**Given** Refresh Token失效或过期
**When** API返回401
**Then** 清除本地Token
**And** 跳转登录页面
**And** 提示"登录已过期，请重新登录"

**Given** 用户主动注销
**When** 用户点击退出登录
**Then** Token加入Redis黑名单
**And** 清除本地Token和缓存
**And** 跳转登录页面

### Story 2.4: Free/Premium订阅层级管理

As a user,
I want to understand and manage my subscription tier,
So that I know what features are available to me.

**Acceptance Criteria:**

**Given** 用户是Free层级（未订阅）
**When** 用户尝试创建第6个提醒
**Then** 提示升级Premium
**And** 显示Free vs Premium功能对比

**Given** 用户是Free层级
**When** 用户尝试设置围栏半径大于100m
**Then** 提示"免费用户围栏最大100m，请升级Premium"
**And** 自动将半径限制为100m

**Given** 用户订阅Premium成功
**When** 订阅状态变更生效
**Then** 提醒数量限制解除
**And** 围栏半径限制解除
**And** 用户界面显示Premium标识

### Story 2.5: 用户权限限制实施

As a system,
I want to enforce subscription tier limits,
So that Free users are incentivized to upgrade while Premium users enjoy unlimited access.

**Acceptance Criteria:**

**Given** 数据库中用户订阅等级为FREE
**When** 创建提醒时检查用户层级
**Then** 如果已有5个活跃提醒，返回错误码40026"免费用户最多5个提醒"
**And** 禁止创建第6个

**Given** 数据库中用户订阅等级为FREE
**When** 设置围栏半径时
**Then** 如果半径>100m，自动限制为100m
**And** 提示用户升级后可设置更大范围

**Given** 用户订阅状态为PREMIUM
**When** 创建提醒或设置围栏
**Then** 无数量和半径限制
**And** 允许创建任意数量提醒

<!-- Epic 3 Stories -->

## Epic 3: 提醒创建与管理

**Epic目标：** 用户可以创建、编辑、删除位置提醒

**FR覆盖：** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8

### Story 3.1: 命令词创建提醒

As a user,
I want to create reminders using voice commands,
So that I can quickly capture reminders without typing.

**Acceptance Criteria:**

**Given** 用户在App首页
**When** 用户点击麦克风图标并说"提醒我到家乐福买鸡蛋"
**Then** 系统解析命令并显示确认卡片
**And** 卡片显示："动作：买鸡蛋"，"位置：家乐福"，"触发：到达"
**And** 围栏半径默认100m

**Given** 解析结果显示确认卡片
**When** 用户确认信息正确并点击保存
**Then** 提醒创建成功
**And** 跳转至提醒列表显示新提醒

**Given** 命令词解析失败
**When** 用户说出无法解析的命令
**Then** 提示"抱歉，我没有理解，请尝试说'提醒我...到...'"
**And** 显示命令词示例

### Story 3.2: 表单创建提醒

As a user,
I want to create reminders using a form,
So that I can precisely specify all reminder details.

**Acceptance Criteria:**

**Given** 用户在创建提醒页面
**When** 用户填写表单：动作="买牛奶"，位置="超市"，触发类型="到达"，半径=200m，重复="每天"
**Then** 系统验证必填字段（动作、位置）
**And** 保存提醒到本地SQLite

**Given** 表单创建成功
**When** 用户返回提醒列表
**Then** 新提醒显示在列表顶部
**And** 显示下次触发条件（"每天到达超市时"）

**Given** 用户编辑已有提醒
**When** 用户修改任意字段后保存
**Then** 提醒更新成功
**And** 围栏服务同步更新

### Story 3.3: 地图选点设置位置

As a user,
I want to select a location by tapping on a map,
So that I can precisely choose the exact spot for my reminder.

**Acceptance Criteria:**

**Given** 用户在创建/编辑提醒页面
**When** 用户点击"选择位置"
**Then** 全屏地图打开
**And** 显示当前用户位置
**And** 用户可缩放/拖动地图

**Given** 用户在地图上长按
**When** 用户长按任意位置
**Then** 该位置显示红色标记
**And** 下方显示地址信息（通过逆地理编码获取）
**And** 显示围栏范围预览圆（可调节半径）

**Given** 位置已选择
**When** 用户点击"确认"
**Then** 位置信息保存到提醒
**And** 返回创建页面，地址显示在位置字段

### Story 3.4: 地址搜索选择位置

As a user,
I want to search for an address to set reminder location,
So that I can set reminders for places I know the name of but don't need to find on map.

**Acceptance Criteria:**

**Given** 用户在创建/编辑提醒页面
**When** 用户点击位置字段的搜索图标
**Then** 搜索页面打开，显示搜索框
**And** 显示搜索历史（如果有）

**Given** 用户输入"北京朝阳大悦城"
**When** 用户点击搜索
**Then** 显示搜索结果列表
**And** 每个结果显示名称、地址、距离

**Given** 用户选择搜索结果
**When** 用户点击某个结果
**Then** 位置保存到提醒
**And** 返回创建页面，地址显示在位置字段

### Story 3.5: Arrive/Leave双触发模式

As a user,
I want to choose between Arrival and Departure triggers,
So that I can set reminders for both entering and leaving places.

**Acceptance Criteria:**

**Given** 用户在创建/编辑提醒页面
**When** 用户选择触发类型为"到达(Arrive)"
**Then** 提醒在用户进入围栏时触发
**And** 通知显示"到达[地点]时提醒：[动作]"

**Given** 用户选择触发类型为"离开(Leave)"
**When** 用户离开围栏区域时
**Then** 提醒在用户离开围栏时触发
**And** 通知显示"离开[地点]时提醒：[动作]"

**Given** 提醒已创建，触发类型为Arrive
**When** 用户修改为Leave
**Then** 围栏触发逻辑更新
**And** 历史触发记录保留

### Story 3.6: 自定义围栏半径

As a user,
I want to customize geofence radius,
So that I can set appropriate trigger boundaries for different locations.

**Acceptance Criteria:**

**Given** 用户在创建/编辑提醒页面
**When** 用户调节围栏半径滑块
**Then** 地图上实时显示围栏范围圆
**And** 半径范围显示：100m - 5000m（Premium），100m - 100m（Free用户限制）

**Given** Free用户
**When** 用户尝试设置半径大于100m
**Then** 滑块最大只能到100m
**And** 提示"免费用户最大100m，升级Premium解锁更大范围"

**Given** Premium用户
**When** 用户设置半径为2000m
**Then** 围栏范围保存成功
**And** 地图围栏圆更新为2000m

### Story 3.7: 重复规则设置

As a user,
I want to set repeat rules for reminders,
So that I can manage recurring tasks like "每天上班提醒带伞".

**Acceptance Criteria:**

**Given** 用户在创建/编辑提醒页面
**When** 用户选择重复规则
**Then** 显示选项：一次性 / 每天 / 每周 / 直到确认

**Given** 用户选择"一次性"
**When** 触发并确认后
**Then** 提醒自动标记为已完成
**And** 不再重复触发

**Given** 用户选择"每天"
**When** 每天进入/离开该地点时
**Then** 提醒重复触发
**And** 触发记录保存在历史中

**Given** 用户选择"直到确认"
**When** 触发后用户未确认
**Then** 每天重复提醒
**And** 用户确认后停止重复

### Story 3.8: 提醒确认卡片编辑

As a user,
I want to review and edit reminder details before saving,
So that I can correct any parsing mistakes and ensure accuracy.

**Acceptance Criteria:**

**Given** 命令词解析完成或表单填写完成
**When** 显示确认卡片
**Then** 卡片包含所有可编辑字段：动作、位置、触发类型、半径、重复规则

**Given** 显示确认卡片
**When** 用户修改任意字段
**Then** 卡片实时更新
**And** 地图围栏范围同步更新

**Given** 确认卡片信息正确
**When** 用户点击"确认创建"
**Then** 提醒保存到数据库
**And** 围栏注册到Geofencing服务
**And** 跳转至提醒列表

**Given** 确认卡片信息需要修改
**When** 用户点击"编辑"
**Then** 返回表单编辑模式
**And** 保留已填写的信息

<!-- Epic 4 Stories -->

## Epic 4: 地理围栏触发引擎

**Epic目标：** 提醒可以在正确的位置和时间可靠触发

**FR覆盖：** FR9, FR10, FR11, FR12, FR13, FR31, FR32, FR33, FR34, FR35, FR36

**相关NFR：**
- NFR1: Android后台存活率 ≥ 80%（7日）
- NFR2: 位置围栏电池消耗低于竞品20%
- NFR3: 推送到达率 ≥ 95%
- NFR4: 触发精度：95%在预期地点200m半径内

### Story 4.1: Geofencing双模式触发

As a user,
I want reminders to trigger when I arrive at or leave a location,
So that I get reminded at the right moment.

**Acceptance Criteria:**

**Given** 用户创建了Arrive触发类型的提醒，围栏半径200m
**When** 用户设备进入围栏区域
**Then** Geofencing API触发过渡（ENTER transition）
**And** 系统发送本地通知
**And** 通知显示"到达[地点]：提醒内容"

**Given** 用户创建了Leave触发类型的提醒
**When** 用户设备离开围栏区域
**Then** Geofencing API触发过渡（EXIT transition）
**And** 系统发送本地通知
**And** 通知显示"离开[地点]：提醒内容"

**Given** 多个围栏同时触发
**When** 用户同时进入/离开多个围栏
**Then** 按时间顺序依次发送通知
**And** 每个围栏触发独立通知

### Story 4.2: 后台围栏持续监控

As a user,
I want geofence monitoring to continue when app is in background,
So that my reminders trigger even when I'm not using the app.

**Acceptance Criteria:**

**Given** 用户创建了位置提醒
**When** 用户按Home键将App切到后台
**Then** Geofencing API继续监控
**And** Android后台位置服务保持活跃

**Given** App在后台运行
**When** 用户进入围栏
**Then** 系统发送通知
**And** 用户点击通知可打开App并看到详情

**Given** App在后台且收到触发通知
**When** 通知发送成功
**Then** 推送服务记录触发日志
**And** 更新提醒的lastTriggeredAt时间

### Story 4.3: 系统杀进程后围栏自动恢复

As a user,
I want geofences to automatically restore after system kills the app,
So that I never miss a reminder even if my phone is running low on memory.

**Acceptance Criteria:**

**Given** 用户创建了多个位置提醒
**When** Android系统因内存压力杀死App进程
**Then** 下次用户解锁手机或系统资源释放时
**And** App通过BroadcastReceiver收到BOOT_COMPLETED广播
**And** 自动重新注册所有活跃围栏到Geofencing API

**Given** App重启并恢复围栏
**When** 用户进入某个已恢复的围栏
**Then** 提醒正常触发
**And** 用户感受不到App曾被杀死

**Given** App重启并恢复围栏
**When** 恢复过程中发生错误
**Then** App记录错误日志
**And** 下次机会重试恢复
**And** 不影响用户正常使用

### Story 4.4: 融合定位提升触发精度

As a user,
I want accurate location triggering within 200m radius 95% of the time,
So that my reminders fire at the right place, not too early or too late.

**Acceptance Criteria:**

**Given** 用户创建了围栏半径200m的提醒
**When** 用户在围栏边界附近移动
**Then** 融合定位（GPS + WiFi + 基站）提升定位精度
**And** 95%的触发发生在实际进入/离开围栏时

**Given** GPS信号弱（如室内）
**When** 系统需要判断是否触发围栏
**Then** 自动切换到WiFi定位或基站定位
**And** 保持围栏监控不中断

**Given** 定位精度评估
**When** 每月数据分析
**Then** 触发精度需达到95%在200m半径内
**And** 如未达标，调整定位策略或围栏参数

### Story 4.5: 位置权限引导

As a user,
I want clear guidance when location permission is needed,
So that I understand why the app needs location access and how to grant it.

**Acceptance Criteria:**

**Given** 用户首次创建位置提醒
**When** App检测到位置权限未授权
**Then** 显示权限引导对话框
**And** 说明"位置权限用于在您到达/离开指定地点时发送提醒"
**And** 显示"允许"和"稍后再说"按钮

**Given** 用户点击"允许"
**When** 系统权限对话框弹出
**Then** 用户授予ACCESS_FINE_LOCATION权限
**And** App保存权限状态
**And** 继续创建提醒流程

**Given** 用户点击"稍后再说"
**When** 用户之后再次创建位置提醒
**Then** 再次显示权限引导
**And** 提醒功能无法正常使用

### Story 4.6: 后台位置权限引导

As a user,
I want to be guided to enable background location access,
So that reminders can trigger even when the app is closed.

**Acceptance Criteria:**

**Given** 用户已授予前台位置权限
**When** 用户创建位置提醒
**Then** App检测ACCESS_BACKGROUND_LOCATION是否授权
**And** 如果未授权，显示引导："后台位置访问可确保提醒在App关闭时也正常触发"

**Given** 用户需要授予后台位置权限
**When** 用户点击引导中的"去设置"
**Then** 跳转到系统设置页面的位置权限页面
**And** 用户手动开启"允许后台使用位置"

**Given** 用户开启了后台位置权限
**When** 用户返回App
**Then** App检测到权限已授权
**And** 显示"位置权限已恢复"提示
**And** 提醒功能正常

### Story 4.7: 电池优化白名单引导

As a user,
I want to be guided to whitelist the app from battery optimization,
So that my reminders work reliably without being killed by the system.

**Acceptance Criteria:**

**Given** 用户创建了位置提醒
**When** App检测到设备在电池优化白名单之外
**Then** 显示引导对话框："为了确保所有提醒准时触发，请允许WherEver在后台运行"
**And** 显示"去设置"和"暂不设置"按钮

**Given** 用户点击"去设置"
**When** 系统电池优化设置页面打开
**Then** 用户将WherEver加入白名单
**And** 返回App后检测到白名单状态已更新
**And** 显示"已允许后台运行"

**Given** 用户跳过电池优化设置
**When** 提醒触发失败（因电池优化被限制）
**Then** App下次打开时提示："上次提醒因省电模式未触发"
**And** 再次提供设置入口

### Story 4.8: 厂商特殊适配引导

As a user,
I want manufacturer-specific guidance for Huawei/MiUI/OPPO devices,
So that my reminders work on any Android phone regardless of manufacturer.

**Acceptance Criteria:**

**Given** 用户使用华为设备
**When** App检测到EMUUI系统
**Then** 显示华为特有的后台管理引导
**And** 引导用户进入"设置 > 电池 > 应用启动管理"
**And** 关闭WherEver的"自动管理"

**Given** 用户使用小米设备
**When** App检测到MIUI系统
**Then** 显示小米特有的省电策略引导
**And** 引导用户进入"设置 > 电池 > 省电策略"
**And** 选择"无限制"

**Given** 用户使用OPPO设备
**When** App检测到ColorOS系统
**Then** 显示OPPO特有的后台限制引导
**And** 引导用户开启"允许后台活动"

**Given** 厂商引导完成后
**When** 用户返回App
**Then** App验证权限状态
**And** 提示用户是否设置成功

### Story 4.9: 前台服务保活

As a system,
I want to maintain a foreground service for geofence monitoring,
So that Android does not kill the location monitoring process.

**Acceptance Criteria:**

**Given** 用户创建了位置提醒
**When** 围栏注册成功
**Then** 启动Foreground Service（前台服务）
**And** 显示持续通知："WherEver正在监控位置提醒"

**Given** 前台服务运行中
**When** 用户查看通知栏
**Then** 看到"位置监控中"的通知
**And** 点击通知显示App主页面

**Given** 前台服务运行中
**When** 系统尝试回收内存
**Then** 前台服务优先级更高，不易被杀死
**And** 如果服务被迫停止，BOOT_COMPLETED时自动恢复

**Given** 用户关闭App（滑动退出）
**When** 前台服务仍在运行
**Then** 围栏监控继续
**And** 用户仍能收到提醒通知

### Story 4.10: 围栏触发与推送协同

As a user,
I want geofence triggers to reliably send notifications,
So that I always receive my reminders regardless of app state.

**Acceptance Criteria:**

**Given** 围栏触发（进入/离开）
**When** Geofencing API报告触发事件
**Then** 后端推送服务（极光/个推/FCM）收到触发消息
**And** 通过推送通道发送通知到设备

**Given** 推送服务发送通知
**When** 设备在线
**Then** 推送到达率 ≥ 95%
**And** 通知显示在状态栏

**Given** 推送通知发送失败
**When** 推送服务检测到发送异常
**Then** 记录错误日志
**And** 触发本地通知兜底（即使推送失败，本地围栏触发仍可发送本地通知）

<!-- Epic 5 Stories -->

## Epic 5: 通知与用户交互

**Epic目标：** 用户收到精美动效提醒并可进行确认/推迟操作

**FR覆盖：** FR14, FR15, FR16, FR17, FR18, FR19, FR20

**相关UX约束：**
- 动效语言系统：触发(pop+震动)/确认(渐隐)/推迟(轻推)三态
- 金融App质感UI：深色主题 + 圆角卡片

### Story 5.1: 推送通知显示

As a user,
I want to receive push notifications when reminders trigger,
So that I am alerted even when I'm not looking at my phone.

**Acceptance Criteria:**

**Given** 围栏触发（进入/离开）
**When** 通知发送到用户设备
**Then** 通知显示在状态栏
**And** 通知内容包含：地点名称、提醒动作、触发类型（到达/离开）
**And** 通知样式为卡片式，带圆角和深色背景

**Given** 通知显示在状态栏
**When** 用户下拉通知栏
**Then** 显示完整通知内容
**And** 显示"确认"和"推迟"两个交互按钮

**Given** 通知带有交互按钮
**When** 用户点击"确认"按钮
**Then** 发送确认回调到后端
**And** 卡片执行确认动效（向上滑出渐隐）
**And** 震动反馈（短振动）

### Story 5.2: 触发动效（Pop + 震动）

As a user,
I want to see and feel a distinctive trigger animation,
So that I immediately know a location reminder has fired.

**Acceptance Criteria:**

**Given** 提醒触发
**When** 通知弹出
**Then** 卡片执行pop动效（从底部快速上弹，带弹性）
**And** 伴随短促震动（100ms）
**And** 动效时长约300ms

**Given** 卡片pop动画执行中
**When** 用户点击卡片
**Then** 动画被打断
**And** 打开App显示提醒详情

**Given** 卡片pop动画执行完成
**When** 用户不操作
**Then** 卡片保持显示在屏幕
**And** 等待用户操作（确认/推迟/滑走）

### Story 5.3: 确认动效（渐隐 + 成功震动）

As a user,
I want to see a satisfying confirmation animation when I complete a reminder,
So that I feel rewarded for completing tasks.

**Acceptance Criteria:**

**Given** 用户点击"确认"按钮
**When** 确认动作触发
**Then** 卡片执行向上滑出动效
**And** 同时执行渐隐动画（透明度从1到0）
**And** 伴随成功震动反馈（双短振动，约50ms间隔）

**Given** 确认动画执行中
**When** 动画完成
**Then** 卡片从屏幕消失
**And** 后端记录该提醒为已完成
**And** 更新历史记录

**Given** 重复性提醒（每天/每周）
**When** 用户确认后
**Then** 提醒的下次触发时间更新
**And** 卡片消失但提醒仍保留在列表

### Story 5.4: 推迟动效（轻推 + 无震动）

As a user,
I want to defer a reminder with a subtle animation,
So that I can snooze the reminder without disruptive feedback.

**Acceptance Criteria:**

**Given** 用户点击"推迟"按钮
**When** 推迟动作触发
**Then** 卡片执行轻推动效（向左/右快速抖动2-3次）
**And** 执行完毕后卡片渐隐消失
**And** **无震动反馈**（与确认动效区分）

**Given** 推迟动画执行完成
**When** 用户再次进入App
**Then** 显示"已推迟"提示
**And** 下次触发时间按推迟时长更新

**Given** 用户选择推迟时长
**When** 用户点击"推迟"按钮旁边的下拉箭头
**Then** 显示推迟选项：15分钟、30分钟、1小时、明天

### Story 5.5: 推迟时间选项

As a user,
I want to choose different defer durations,
So that I can snooze reminders for an appropriate time.

**Acceptance Criteria:**

**Given** 用户点击"推迟"按钮
**When** 用户选择"15分钟"
**Then** 提醒在15分钟后重新触发
**And** 卡片执行推迟动效（轻推+渐隐）

**Given** 用户选择"30分钟"
**When** 推迟时间设置成功
**Then** 提醒在30分钟后重新触发
**And** 系统更新该提醒的nextTriggerAt字段

**Given** 用户选择"1小时"
**When** 推迟时间设置成功
**Then** 提醒在1小时后重新触发

**Given** 用户选择"明天"
**When** 推迟时间设置成功
**Then** 提醒在明天同一时间触发
**And** 如果是Leave触发，明天到达该地点时再次提醒

### Story 5.6: 跳过当前Occurrence

As a user,
I want to skip the current occurrence without affecting the repeat rule,
So that I can bypass one instance of a recurring reminder.

**Acceptance Criteria:**

**Given** 用户有一个每天触发的重复提醒
**When** 提醒触发但用户不想现在处理
**Then** 用户可选择"跳过这次"
**And** 提醒的重复规则保持不变
**And** 下次仍按原计划触发

**Given** 用户选择"跳过这次"
**When** 跳过操作完成
**Then** 卡片执行渐隐动画（不带震动）
**And** 后端记录跳过事件
**And** 提醒的下次触发时间正常更新

**Given** 一次性提醒
**When** 用户跳过
**Then** 提醒标记为已完成
**And** 不再重复触发

### Story 5.7: 通知显示位置和触发类型

As a user,
I want notifications to clearly show location and trigger type,
So that I immediately understand which reminder fired.

**Acceptance Criteria:**

**Given** 提醒触发（Arrive类型）
**When** 通知显示
**Then** 通知标题显示"到达：[地点名称]"
**And** 通知内容显示"[提醒动作]"
**And** 触发类型图标显示为"进入"图标

**Given** 提醒触发（Leave类型）
**When** 通知显示
**Then** 通知标题显示"离开：[地点名称]"
**And** 触发类型图标显示为"离开"图标

**Given** 通知显示
**When** 用户在通知上看到地点和动作信息
**Then** 信息准确反映创建提醒时的设置
**And** 地点名称通过逆地理编码获取

<!-- Epic 6 Stories -->

## Epic 6: 地图与导航集成

**Epic目标：** 用户可在App内预览位置并一键导航

**FR覆盖：** FR21, FR22, FR23

### Story 6.1: 卡片内置迷你地图

As a user,
I want to see a mini-map on the reminder card,
So that I can visually verify the reminder location before navigating.

**Acceptance Criteria:**

**Given** 用户创建了位置提醒
**When** 用户在提醒列表查看提醒卡片
**Then** 卡片顶部显示迷你地图
**And** 地图中心为提醒位置（红色标记）
**And** 显示围栏范围圆（半透明蓝色圆）

**Given** 提醒卡片显示迷你地图
**When** 用户点击卡片展开详情
**Then** 地图区域放大，显示更详细的周围环境
**And** 用户可进一步缩放查看

**Given** 提醒卡片显示迷你地图
**When** 地图加载中
**Then** 显示地图加载占位符
**And** 加载完成后平滑过渡显示地图

### Story 6.2: 唤起外部地图导航

As a user,
I want to tap a button to launch the default map app for navigation,
So that I can start navigating to my reminder location with one tap.

**Acceptance Criteria:**

**Given** 用户查看提醒详情
**When** 用户点击"导航"按钮
**Then** 显示地图选择对话框：高德地图、百度地图、Google地图
**And** 记住用户上次选择作为默认

**Given** 用户选择了高德地图
**When** 高德地图已安装
**Then** 唤起高德地图并开始导航到提醒位置
**And** 传入目的地经纬度

**Given** 用户选择了百度地图
**When** 百度地图已安装
**Then** 唤起百度地图并开始导航
**And** 传入目的地经纬度

**Given** 用户选择了Google地图
**When** Google地图已安装
**Then** 唤起Google地图并开始导航
**And** 传入目的地经纬度

### Story 6.3: 使用默认地图应用

As a user,
I want the app to use my preferred map app for navigation,
So that I don't have to choose every time.

**Acceptance Criteria:**

**Given** 用户首次使用导航功能
**When** 用户点击导航按钮
**Then** 显示地图选择对话框
**And** 用户选择默认地图应用
**And** 记住该选择

**Given** 用户已设置默认地图应用
**When** 用户再次点击导航按钮
**Then** 直接唤起默认地图应用
**And** 不再显示选择对话框

**Given** 用户想更换默认地图应用
**When** 用户在设置页面修改默认地图
**Then** 更新用户偏好设置
**And** 下次导航使用新的默认应用

**Given** 默认地图应用未安装
**When** 用户点击导航
**Then** 显示对话框提示"检测到未安装[地图名]，是否跳转到应用商店下载？"
**And** 用户确认后跳转应用商店
