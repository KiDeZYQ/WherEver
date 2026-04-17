---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary', 'step-03-success', 'step-04-journeys', 'step-05-domain-skipped', 'step-06-innovation-skipped', 'step-07-project-type', 'step-08-scoping']
inputDocuments: ['_bmad-output/project-context.md']
workflowType: 'prd'
project_name: 'WherEver'
classification:
  projectType: 'mobile_app'
  domain: 'personal_productivity'
  complexity: 'medium'
  projectContext: 'greenfield'
---

## Executive Summary

WherEver 是一款 Android 平台的位置智能提醒 App，通过**位置触发 + 地图直连导航**改变人获取任务的方式——不再是"人找任务"，而是**"任务主动找到人"**。

现有提醒工具（Google Reminders、Todoist、Any.do）的共同缺陷是**被动且死板**：闹钟只能在预设时间响起、地理位置提醒几乎空白或不可靠、Android 后台被系统杀死后通知完全失效。WherEver 的核心创新在于：基于地理围栏（Geofencing）的**双重触发引擎**——**进入时（Arrive）、离开时（Leave）**，配合金融 App 质感的卡片式 UI 和动效语言系统，让提醒在最恰当的时刻和地点主动弹出。

目标用户是**都市通勤者（18-35 岁）**和**家庭事务管理者（25-45 岁）**，他们日常在多个地点之间切换，事项太多靠脑子记压力巨大——最怕漏掉重要事情被老婆/同事说。

根因洞察：用户需要的不是"提醒功能"，而是一个**"永远不会让我漏掉、永远不会让我尴尬"的信任系统**。WherEver 所有设计决策都围绕"信任感"这一核心情绪。

商业模式为免费增值（Freemium），MVP 聚焦 Arrive/Leave 触发 + 表单/命令词创建 + 卡片 UI + 动效 + 地图导航，验证核心假设：用户是否愿意为可靠的位置触发提醒付费。

### What Makes This Special

- **双重触发引擎**：Arrive / Leave 两种触发模式，简单但可靠
- **地图直连导航**：卡片点击直接唤起高德/百度地图，从"告诉你去哪"升级到"带你去那"
- **动效语言系统**：触发（pop+震动）/确认（渐隐）/推迟（轻推）三态动效，让用户无需读文字就知道发生了什么
- **金融 App 质感 UI**：深色主题 + 圆角卡片，差异化于 Todoist 列表式界面，传递信任感和品质感
- **Android 后台专门优化**：AlarmManager + Foreground Service + 厂商推送通道保障位置围栏持久存活，解决系统杀进程痛点

### Project Classification

| 维度 | 值 |
|------|-----|
| **Project Type** | Mobile App（Android） |
| **Domain** | 个人效率 / 位置情境感知 |
| **Complexity** | Medium（Android 后台位置服务、Geofencing 电池优化、各版本权限管理） |
| **Context** | Greenfield（新项目，无现有代码库） |

## Success Criteria

### User Success

| 指标 | 目标 |
|------|------|
| 位置权限授予率 | ≥ 70%（首次请求） |
| 触发精度 | 95% 的触发在预期地点 200m 半径内 |
| 提醒完成率 | ≥ 55% |
| 位置触发通知点击率 | ≥ 65% |
| 用户信任度 NPS | ≥ 40 |

**用户成功定义：** 用户不再需要想着"我待会儿要记得做什么"——系统在任何时刻都知道他该在哪里、该做什么，并在正确的时机弹出提醒。

### Business Success

| 指标 | 目标（上线 6 个月） |
|------|-------------------|
| 日活跃用户（DAU） | 50,000 |
| 付费转化率 | Free → Premium ≥ 3% |
| 付费用户数 | 5,000 |
| 季度收入环比增长 | ≥ 15% |
| 订阅续费率 | ≥ 75% |

### Technical Success

| 指标 | 目标 |
|------|------|
| Android 后台存活率（7 日） | ≥ 80% |
| 位置围栏电池消耗 | 低于竞品 20% |
| 推送到达率 | ≥ 95% |

---

## User Journeys

### Journey 1: 都市通勤者 — 小明（Success Path）

**人物：** 小明，28岁，互联网公司产品经理，每天通勤经过家→公司→健身房→超市

**Opening Scene：**
小明昨晚加班到很晚，今天早上闹钟响了三次才起床。出门时老婆发微信说"记得今天下班买鸡蛋"。他匆忙出门，根本没记住这回事。

**Rising Action：**
- 下午 6 点，小明刚走出公司大楼
- 口袋里的手机突然震动，屏幕弹出一张精致的卡片
- 卡片上写着："到家乐福了吗？记得买鸡蛋 ✅确认 ⏰推迟"
- 卡片底部有一个蓝色导航按钮，点击直接跳到高德地图开始导航

**Climax：**
小明低头看着卡片，心想"这玩意儿怎么知道我要买鸡蛋？哦对，昨晚老婆提了一嘴，我对着手机说了句'明天提醒我买鸡蛋'就忘了..."

他点了确认，卡片向上滑出渐隐。20分钟后，他已经在超市门口，手机又震动了一下："离开时提醒我锁门 ✅确认 ⏰推迟"

**Resolution：**
小明提着鸡蛋出门，走到车边手机又震动。他一边锁车一边想：这个 App 好像真的记住了，比我老婆还靠谱。

---

### Journey 2: 都市通勤者 — 小明（Edge Case）

**Opening Scene：**
小明设置了"到健身房提醒我带泳裤"，但他到了健身房后发现手机没震动。

**Rising Action：**
- 小明站在健身房门口，围栏显示 200m 半径，应该触发才对
- 他掏出手机一看——WherEver 的卡片显示"围栏触发中"，但没有弹出提醒
- 他点开 WherEver，发现是因为手机开了"极度省电模式"，后台位置被限制了
- App 自动弹出一个引导："检测到省电模式正在限制位置权限，这会影响提醒可靠性。要不要允许后台位置访问？"

**Climax：**
小明点了"去设置"，跳转 Android 设置页面，找到了那个被隐藏的省电白名单开关。他打开后，App 卡片立刻显示"位置权限已恢复"，并补充说明"下次到达健身房时会正常触发"。

**Resolution：**
第二天，小明真的收到了提醒。他第一次意识到——这个 App 在主动保护他的信任，而不是悄悄失效。

---

### Journey 3: 家庭事务管理者 — 小红

**人物：** 小红，32岁，有两个孩子的妈妈

**Opening Scene：**
小红每天要记住很多事情：接孩子、买菜、先生交代的事情...她习惯了脑子里同时跑 20 件事。但最近老公开始抱怨她漏掉了一些事情，她很委屈——"我真的不是不上心，是真的记不住那么多"。

**Rising Action：**
- 老公在家庭群里发了一条："周六带爸妈去西湖，记得预约餐厅"
- 小红看到了，但当时正在喂老二吃饭，放下手机就忘了
- 周五晚上，老公问"餐厅约好了吗？"——小红愣住，又漏了

**Climax：**
周六早上，小红送完老大上学，手机收到一条提醒：
"今天下午 1 点：带爸妈去西湖，记得预约餐厅 ⏰还没出发？点击导航"

小红愣住了——她完全不记得自己什么时候说过要预约。但 App 记住了。她点了导航，一路顺畅。

**Resolution：**
到餐厅时她又收到一条："到餐厅了，记得确认包厢 ✅ ⏰推迟"

小红点了确认，第一次觉得——原来记忆外包出去，不是自己不够好，而是每个人都有自己的极限。

---

## Mobile App Specific Requirements

### 技术架构

| 组件 | 技术选型 | 说明 |
|------|---------|------|
| **前端框架** | Flutter | 跨平台 Android/iOS，Google 主推，Dart 语言，性能接近 Native |
| **后端** | Java + Spring Boot | RESTful API，微服务架构 |
| **数据库** | PostgreSQL（用户/订阅）+ Redis（会话/缓存） | |
| **推送** | FCM（海外）+ 厂商通道（华为/小米/OPPO 国内） | 保障国内 Android 后台存活 |
| **地图 SDK** | 高德地图（国内）+ Google Maps（海外） | 用户可选择默认导航 App |
| **位置服务** | Android Geofencing API + 融合定位（提升精度） | |
| **存储** | 本地 SQLite（免费）+ 云端同步（Premium，Phase 2） | |

### Device Permissions

| 权限 | 用途 | 申请时机 |
|------|------|---------|
| **ACCESS_FINE_LOCATION** | 精确定位，围栏触发 | 首次创建位置提醒时 |
| **ACCESS_COARSE_LOCATION** | 模糊定位，节省电量 | 降级兜底 |
| **ACCESS_BACKGROUND_LOCATION** | 后台位置访问（Android 10+） | 引导用户开启，需显式说明"保障提醒可靠触发" |
| **FOREGROUND_SERVICE** | 前台服务，保活 | 系统自动申请 |
| **FOREGROUND_SERVICE_LOCATION** | 位置前台服务（Android 14+） | 后台围栏监控必需 |
| **POST_NOTIFICATIONS** | 通知权限（Android 13+） | 首次打开 App 时 |
| **RECEIVE_BOOT_COMPLETED** | 开机自启 | 首次安装时 |
| **REQUEST_IGNORE_BATTERY_OPTIMIZATIONS** | 电池优化白名单 | 后台存活关键，引导用户授权 |

### Android 后台存活策略

核心挑战：Android 各厂商（华为/小米/OPPO/vivo）有自己的后台管理机制，FCM 在国内极不可靠。

**解决方案：**

1. **Foreground Service + 厂商通道双保险**
   - FCM 作为海外主力
   - 国内使用个推/极光等厂商通道
2. **电池优化引导**
   - 首次创建位置提醒时，检测是否在电池白名单
   - 引导文案："为了确保您设置的所有提醒都能准时触发，请允许 WherEver 在后台运行"
3. **华为/小米/OPPO 特殊适配**
   - 各厂商推送 SDK 集成
   - 自启动权限引导
   - 省电模式白名单

### 隐私与合规

| 要求 | 说明 |
|------|------|
| **隐私政策** | 必须明确说明位置数据的收集目的（围栏触发）、存储方式（本地加密）、保留期限 |
| **Google Play 数据安全** | 位置数据标注为"位置"类型，需说明用途 |
| **Android 13+ 通知权限** | POST_NOTIFICATIONS 运行时申请，需说明"发送提醒通知" |
| **国内合规** | 《个人信息保护法》合规，隐私政策需在 App 内展示 |

---

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** Experience MVP — 验证"用户是否愿意为可靠的位置触发提醒付费"

**核心逻辑：** WherEver 的价值不在于功能数量，而在于触发可靠性+地图导航的体验是否足够好。选择这个方向是因为：竞品的最大痛点不是功能缺失，而是"不可靠"——所以 MVP 不需要很多功能，但需要每个功能都做到值得信任。

**MVP 精简说明（基于架构审查建议）：**
- 移除 Departure 触发（Phase 2）—— 需要复杂的情境感知计算，增加技术风险
- 移除云端同步（Phase 2）—— 本地存储优先，简化 MVP 复杂度
- 用简单命令词替代 LLM 对话（Phase 1）—— 离线可用、实现简单、测试性好

**MVP 团队规模（最低）：**

| 角色 | 人数 | 职责 |
|------|------|------|
| Flutter 开发者 | 1-2人 | App 开发（含位置围栏、通知、地图集成） |
| Java 后端 | 1人 | 订阅系统、用户认证、推送通道 |
| UI/UX 设计师 | 0.5人 | 金融 App 质感 UI |
| 产品 | 你自己 | PRD + 验收 |

### MVP Feature Set (Phase 1)

**Must-Have 功能清单：**

| 功能 | 描述 | 优先级理由 |
|------|------|-----------|
| **Arrive/Leave 触发** | Geofencing，进入时/离开时触发通知 | 核心差异化，可靠-simple-first |
| 命令词创建 | 简单语音命令 + 表单创建（离线可用） | 快速创建，降低门槛 |
| 地图直连 | 卡片点击唤起高德/百度 | 核心价值，从"告诉"到"带去" |
| 金融 App 卡片 UI | 深色主题 + 圆角卡片 | 信任感建立 |
| 动效语言 | 触发（pop）/确认（渐隐）/推迟（轻推） | 体验完整性 |
| 权限引导 | 后台位置/电池白名单引导 | Android 存活关键 |
| Free/Premium 订阅 | 本地存储，5个提醒限制 | 商业化基础 |
| FCM + 国内厂商通道 | 推送保障 | 国内 Android 存活必需 |

**MVP 明确排除：**

- Departure 触发（Phase 2）
- 云端同步（Phase 2）
- LLM 对话式创建（Phase 2，替代为命令词）
- Widget（Phase 3）
- iOS 版本（Android 先验证）

### Post-MVP Features

**Phase 2（Growth）：**

| 功能 | 说明 |
|------|------|
| Departure 触发 | 日历+天气+交通，提前预警带伞/防迟到 |
| LLM 对话式创建 | 多轮对话，智能纠错 |
| 约饭/会议轻分享 | 分享给赴约对象，双方同收提醒 |
| 云端同步 | Premium 用户跨设备同步 |
| 自定义围栏库 | 保存常用地点为模板 |
| 历史数据分析 | 热力图、响应率统计 |

**Phase 3（Expansion）：**

| 功能 | 说明 |
|------|------|
| AI 智能调度 | 学习用户行为，自动调整提醒时机 |
| 预测性提醒 | 结合历史提前预判 |
| Widget | 主屏小部件 |
| Apple Watch 同步 | 可穿戴设备整合 |
| 家庭位置共享 | 轻度家庭场景 |

### Risk Mitigation Strategy

| 风险类型 | 风险 | 缓解方案 |
|---------|------|---------|
| **技术风险** | Android 后台被杀，位置触发失效 | 华为/小米/OPPO 厂商通道集成 + 电池白名单引导 + Foreground Service |
| **技术风险** | 定位精度不足（200m 内 95%） | 融合定位（GPS + WiFi + 基站），测试阶段专项优化 |
| **技术风险** | 命令词解析错误率高 | 预设常用命令模板，覆盖 80% 场景 |
| **市场风险** | 用户不信任位置权限 | 权限引导 UI + 隐私政策透明 + "从不后台偷跑"承诺 |
| **资源风险** | 团队人少，进度慢 | MVP 聚焦 8 个核心功能，拒绝 scope creep |
| **商业风险** | 免费用户不转化付费 | 5 个提醒限制 + Premium 无限围栏形成对比 |

---

## Functional Requirements

### 1. Reminder Creation

- FR1: Users can create reminders using simple voice commands or structured form input
- FR2: System accepts basic command patterns like "remind me to [action] when I arrive at [location]"
- FR3: System parses command and displays structured reminder confirmation card before saving
- FR4: Users can edit reminder details (trigger type, location, repeat rule) before confirming
- FR5: Users can set two trigger modes: Arrive (entering location) or Leave (exiting location)
- FR6: Users can specify reminder location by selecting point on map or searching address
- FR7: Users can set custom geofence radius for each reminder (minimum 100m)
- FR8: Users can set repeat rules: one-time, daily, weekly, until confirmed

### 2. Trigger Engine

- FR9: System triggers reminder notifications when user enters configured geofence (Arrive)
- FR10: System triggers reminder notifications when user exits configured geofence (Leave)
- FR11: System maintains geofence monitoring while app is in background
- FR12: System handles Android system killing background processes and restores geofences automatically
- FR13: System accurately triggers within 200m of configured location for 95% of triggers

### 3. Notification & User Interaction

- FR14: System sends push notification with interactive action buttons (Confirm / Defer)
- FR15: Notification displays reminder content, location, and trigger type
- FR16: System plays trigger animation (pop + vibration) when notification is presented
- FR17: System plays completion animation (slide up + fade + success vibration) when user confirms
- FR18: System plays defer animation (shake + quiet shrink) when user defers, no vibration
- FR19: Users can defer reminder by set time intervals (15min / 30min / 1hr / tomorrow)
- FR20: Users can skip current occurrence without affecting repeat rule

### 4. Map & Navigation Integration

- FR21: Reminder card displays selected location on embedded mini-map
- FR22: Users can tap navigation button on reminder card to launch default map app (Amap/Google Maps)
- FR23: System uses user's preferred default map app for navigation

### 5. User Account & Subscription

- FR24: System supports guest mode (local-only storage, no account required)
- FR25: System supports account creation and login
- FR26: Free tier users can have maximum 5 active reminders
- FR27: Free tier users can create geofences with max 100m radius
- FR28: Premium users have unlimited reminders and geofences
- FR29: Premium users can sync reminder data across devices (Phase 2)
- FR30: System displays relevant ads in Free tier

### 6. Permission & System Integration

- FR31: System guides users through location permission grant with clear explanation of why permission is needed
- FR32: System detects when background location permission is missing and guides user to enable it
- FR33: System detects battery optimization interference and guides user to whitelist the app
- FR34: System detects power management restrictions from device manufacturers (Huawei/MiUI/OPPO) and provides manufacturer-specific guidance
- FR35: System registers for boot completion broadcast to restore geofences after device restart
- FR36: System maintains foreground service to ensure geofence monitoring continuity

### 7. Data Management & History

- FR37: System stores all reminder data locally on device
- FR38: System maintains reminder history for 7 days (Free) / 30 days (Premium)
- FR39: Premium users can export reminder history as CSV or JSON (Phase 2)
