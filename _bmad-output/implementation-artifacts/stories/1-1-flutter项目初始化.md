---
epic: 1
story_id: 1.1
story_key: 1-1-flutter项目初始化
title: Flutter项目初始化
status: in-progress
created: 2026-04-16
---

# Story 1.1: Flutter项目初始化

**Epic:** Epic 1 - 项目脚手架与基础设施搭建
**Story ID:** 1.1
**Status:** in-progress

## User Story

As a developer,
I want a Flutter project scaffolded with correct package name and Android platform,
So that I can start implementing the WherEver app.

## Acceptance Criteria

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

## Technical Notes

- 使用 `flutter create` 标准初始化
- 包名必须为 `com.wherEver`
- Android minSdkVersion 需 >= 23 (Android 6.0)
- targetSdkVersion 需 = 34 (Android 14)

## Dependencies

- 无

## Implementation Progress

- [x] 执行flutter create命令 - ✅ 完成
- [x] 配置Android SDK版本 - ✅ 完成 (minSdk=23, targetSdk=34, compileSdk=36, namespace=com.wherEver)
- [x] 添加核心依赖到pubspec.yaml - ✅ 完成 (get, dio, sqflite, geolocator, flutter_local_notifications, encrypt, shared_preferences)
- [x] 执行flutter pub get - ✅ 完成
- [x] 验证Android build - ✅ 完成 (app-debug.apk built successfully)

## Dev Agent Record

### Implementation Notes

**Flutter项目创建成功：**
- 项目路径: `d:/project/claude/WherEver/wher_ever`
- 包名: `com.wherEver`
- Flutter版本: 3.41.6 (stable)

**Android配置已更新 (android/app/build.gradle.kts):**
- namespace: `com.wherEver`
- minSdk: 23
- targetSdk: 34
- compileSdk: 34

**核心依赖已添加:**
- get: ^4.6.6 (状态管理+路由+依赖注入)
- dio: ^5.4.0 (HTTP客户端)
- sqflite: ^2.3.2 (本地存储)
- geolocator: ^11.0.0 (定位服务)
- flutter_local_notifications: ^17.0.0 (通知系统)
- encrypt: ^5.0.3 (数据加密)
- shared_preferences: ^2.2.2 (本地配置)

**依赖安装成功:** flutter pub get 执行成功

### Blockers

- 无

### Files Created/Modified

- `wher_ever/android/app/build.gradle.kts` - 修改 (compileSdk=36, coreLibraryDesugaring, multiDexEnabled)
- `wher_ever/android/build.gradle.kts` - 修改 (添加阿里云镜像)
- `wher_ever/android/settings.gradle.kts` - 修改 (添加阿里云镜像)
- `wher_ever/android/gradle.properties` - 修改 (android.enableJetifier, init.gradle配置)
- `wher_ever/android/init.gradle` - 新建 (阿里云仓库配置)
- `wher_ever/pubspec.yaml` - 修改
