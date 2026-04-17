---
epic: 2
story_id: 2.4
story_key: 2-4-free-premium订阅层级管理
title: Free-Premium订阅层级管理
status: in-progress
created: 2026-04-16
---

# Story 2.4: Free-Premium订阅层级管理

**Epic:** Epic 2 - 用户账户与订阅系统
**Story ID:** 2.4
**Status:** in-progress

## User Story

As a user,
I want to understand the differences between Free and Premium tiers,
So that I can decide if I should upgrade my subscription.

## Acceptance Criteria

**Given** 用户已登录
**When** 查看订阅信息
**Then** 显示当前订阅层级
**And** 显示各层级的功能和限制

**Given** Free用户
**When** 创建超过3个提醒
**Then** 提示需要升级
**And** 限制创建行为

**Given** Premium用户
**When** 使用应用
**Then** 享受无限提醒
**And** 享受高级功能

## Technical Notes

### Subscription Levels

| Feature | Free | Premium |
|---------|------|---------|
| Max reminders | 3 | Unlimited |
| Max geofences | 3 | Unlimited |
| Notification history | 7 days | 90 days |
| Data export | No | Yes |
| Priority support | No | Yes |
| Price | Free | $4.99/month |

## Dependencies

- Story 2.2 (用户注册与登录)
- Story 2.3 (JWT认证与Token管理)

## Implementation Progress

- [x] 创建订阅层级枚举 - ✅ 完成 (SubscriptionLevel enum)
- [x] 创建订阅功能配置 - ✅ 完成 (SubscriptionConfig, SubscriptionFeature)
- [x] 实现层级检查服务 - ✅ 完成 (SubscriptionService)
- [x] 实现升级提示UI - ✅ 完成 (SubscriptionDialog, showUpgradeRequiredDialog)
- [x] 验证订阅层级功能 - ✅ 完成 (flutter analyze 通过, 2 issues)

## Dev Agent Record

### Implementation Notes

**订阅层级:**
| 功能 | Free | Premium |
|------|------|---------|
| Reminders | 3 | Unlimited |
| Geofences | 3 | Unlimited |
| Notification History | 7 days | 90 days |
| Data Export | No | Yes |
| Priority Support | No | Yes |
| Price | Free | $4.99/month |

**核心组件:**
- `SubscriptionLevel` - 订阅层级枚举 (free, premium)
- `SubscriptionFeature` - 功能配置模型
- `SubscriptionConfig` - 功能限制配置
- `SubscriptionService` - 订阅检查服务
- `SubscriptionDialog` - 订阅选择对话框
- `showUpgradeRequiredDialog` - 升级提示对话框

**验证结果:**
- flutter analyze: 2 issues (1 warning, 1 info - 已接受)

### Files Created

- `lib/models/subscription_level.dart`
- `lib/models/subscription_config.dart`
- `lib/services/subscription_service.dart`
- `lib/widgets/subscription_dialog.dart`
