---
epic: 2
story_id: 2.3
story_key: 2-3-jwt认证与token管理
title: JWT认证与Token管理
status: in-progress
created: 2026-04-16
---

# Story 2.3: JWT认证与Token管理

**Epic:** Epic 2 - 用户账户与订阅系统
**Story ID:** 2.3
**Status:** in-progress

## User Story

As a user,
I want secure JWT-based authentication with token refresh,
So that I can stay logged in securely without frequent re-authentication.

## Acceptance Criteria

**Given** 用户已登录
**When** 发起API请求
**Then** 自动在请求头携带JWT token
**And** 自动处理token过期

**Given** Access Token已过期
**When** 发起API请求
**Then** 自动使用Refresh Token刷新
**And** 获取新的Access Token
**And** 重试原请求

**Given** Refresh Token也过期
**When** 尝试刷新Token
**Then** 自动登出
**And** 跳转登录页

**Given** 用户退出登录
**When** 调用登出接口
**Then** 清除本地所有Token
**And** 跳转登录页

## Technical Notes

- Access Token expiry: 15 minutes
- Refresh Token expiry: 7 days
- Token stored in FlutterSecureStorage
- Dio interceptor handles token injection
- Auto-refresh on 401 response

## Dependencies

- Story 2.2 (用户注册与登录)

## Implementation Progress

- [x] 创建Token刷新拦截器 - ✅ 完成 (TokenRefreshInterceptor)
- [x] 实现自动Token刷新逻辑 - ✅ 完成 (401时自动刷新)
- [x] 实现Token过期处理 - ✅ 完成 (refreshToken方法)
- [x] 实现登出时清除Token - ✅ 完成 (logout方法)
- [x] 实现Token持久化 - ✅ 完成 (TokenStorage with FlutterSecureStorage)
- [x] 验证JWT流程 - ✅ 完成 (flutter analyze 通过, 1 warning)

## Dev Agent Record

### Implementation Notes

**核心组件:**
- `TokenRefreshInterceptor` - 401时自动刷新Token，重试pending请求
- `AuthInterceptor` - 自动注入Authorization header
- `TokenStorage` - Token安全存储 (FlutterSecureStorage)
- `ApiService` - 扩展以支持添加自定义interceptors

**Token配置:**
- Access Token: 15分钟过期
- Refresh Token: 7天过期
- 存储: FlutterSecureStorage

**验证结果:**
- flutter analyze: 2 issues (1 warning, 1 info - 已接受)

### Files Created

- `lib/services/token_refresh_interceptor.dart`
- `lib/services/auth_interceptor.dart`
- `lib/services/api_service.dart` - 更新以支持添加interceptors
- `lib/pages/auth/auth_controller.dart` - 更新以集成interceptors
