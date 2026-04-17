---
epic: 1
story_id: 1.2
story_key: 1-2-spring-cloud-alibaba多模块项目初始化
title: Spring Cloud Alibaba多模块项目初始化
status: in-progress
created: 2026-04-16
---

# Story 1.2: Spring Cloud Alibaba多模块项目初始化

**Epic:** Epic 1 - 项目脚手架与基础设施搭建
**Story ID:** 1.2
**Status:** in-progress

## User Story

As a developer,
I want a Spring Cloud Alibaba backend project scaffolded with correct modules,
So that I can implement the WherEver backend services.

## Acceptance Criteria

**Given** Java 17+ 和 Maven 已配置
**When** 创建Spring Cloud Alibaba多模块项目
**Then** 项目结构包含: wher-ever-common, wher-ever-api, wher-ever-user, wher-ever-notification, wher-ever-location
**And** 父pom管理版本依赖
**And** 各模块依赖关系正确
**And** mvn compile 执行成功

## Technical Notes

- 使用Spring Cloud Alibaba 2023.x版本
- Spring Boot 3.2.x
- Java 17
- 模块说明:
  - wher-ever-common: 公共工具类、实体、DTO
  - wher-ever-api: API网关
  - wher-ever-user: 用户服务
  - wher-ever-notification: 通知服务
  - wher-ever-location: 位置/地理围栏服务

## Dependencies

- Story 1.1 (Flutter项目初始化) - 无依赖关系

## Implementation Progress

- [x] 创建项目目录结构 - ✅ 完成
- [x] 创建父pom.xml - ✅ 完成 (Spring Boot 3.2.5, Spring Cloud Alibaba 2023.0.3.2)
- [x] 创建各模块pom.xml - ✅ 完成 (5个模块)
- [x] 添加基础依赖 - ✅ 完成 (MyBatis Plus, Nacos, Redis, JWT等)
- [x] 验证mvn compile - ✅ 完成 (BUILD SUCCESS, 2分37秒)

## Dev Agent Record

### Implementation Notes

**项目结构:**
```
wher_ever_backend/
├── pom.xml (父POM)
├── wher-ever-common/         # 公共模块
├── wher-ever-api/            # API网关
├── wher-ever-user/           # 用户服务
├── wher-ever-notification/    # 通知服务
└── wher-ever-location/       # 位置/围栏服务
```

**技术栈:**
- Spring Boot: 3.2.5
- Spring Cloud: 2023.0.4
- Spring Cloud Alibaba: 2023.0.3.2
- Java: 17
- MyBatis Plus: 3.5.7

**编译结果:**
- wher-ever-common: SUCCESS
- wher-ever-api: SUCCESS
- wher-ever-user: SUCCESS
- wher-ever-notification: SUCCESS
- wher-ever-location: SUCCESS

### Files Created

- `wher_ever_backend/pom.xml` - 父POM
- `wher_ever_backend/wher-ever-common/pom.xml`
- `wher_ever_backend/wher-ever-api/pom.xml`
- `wher_ever_backend/wher-ever-user/pom.xml`
- `wher_ever_backend/wher-ever-notification/pom.xml`
- `wher_ever_backend/wher-ever-location/pom.xml`
- 各模块Java源文件 (Application类、BaseEntity、ApiResponse等)
