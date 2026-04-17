import 'package:get/get.dart';
import '../models/subscription_level.dart';
import '../models/subscription_config.dart';

/// Service for managing subscription level checks
class SubscriptionService extends GetxService {
  /// Get current user's subscription level
  /// This would be integrated with AuthController/User model
  SubscriptionLevel getCurrentLevel(int subscriptionValue) {
    return SubscriptionLevelExtension.fromInt(subscriptionValue);
  }

  /// Check if user can perform action based on subscription
  SubscriptionCheckResult checkPermission({
    required SubscriptionLevel level,
    required String featureName,
    required int currentUsage,
  }) {
    final feature = SubscriptionConfig.getFeature(featureName);
    if (feature == null) {
      return SubscriptionCheckResult(
        allowed: false,
        reason: 'Unknown feature: $featureName',
      );
    }

    if (!feature.isAvailable(level)) {
      return SubscriptionCheckResult(
        allowed: false,
        reason: '${feature.name} is available for Premium users only',
        requiresUpgrade: true,
      );
    }

    if (feature.isLimitReached(level, currentUsage)) {
      final limit = feature.getLimit(level);
      final limitStr = limit == null ? 'unlimited' : '$limit';
      return SubscriptionCheckResult(
        allowed: false,
        reason: 'You\'ve reached your ${feature.name} limit ($limitStr). Upgrade to Premium for more.',
        requiresUpgrade: level == SubscriptionLevel.free,
        currentLimit: limit,
      );
    }

    return SubscriptionCheckResult(allowed: true);
  }

  /// Check if reminder can be created
  SubscriptionCheckResult canCreateReminder({
    required SubscriptionLevel level,
    required int currentReminderCount,
  }) {
    return checkPermission(
      level: level,
      featureName: 'Reminders',
      currentUsage: currentReminderCount,
    );
  }

  /// Check if geofence can be created
  SubscriptionCheckResult canCreateGeofence({
    required SubscriptionLevel level,
    required int currentGeofenceCount,
  }) {
    return checkPermission(
      level: level,
      featureName: 'Geofences',
      currentUsage: currentGeofenceCount,
    );
  }

  /// Check if data export is allowed
  SubscriptionCheckResult canExportData(SubscriptionLevel level) {
    return checkPermission(
      level: level,
      featureName: 'Data Export',
      currentUsage: 0,
    );
  }

  /// Get subscription tier comparison for display
  List<SubscriptionTierInfo> getSubscriptionTiers() {
    return [
      SubscriptionTierInfo(
        level: SubscriptionLevel.free,
        name: 'Free',
        price: '\$0',
        features: [
          'Up to 3 reminders',
          'Up to 3 geofences',
          '7-day notification history',
          'Basic support',
        ],
      ),
      SubscriptionTierInfo(
        level: SubscriptionLevel.premium,
        name: 'Premium',
        price: '\$4.99/month',
        features: [
          'Unlimited reminders',
          'Unlimited geofences',
          '90-day notification history',
          'Data export',
          'Priority support',
        ],
      ),
    ];
  }
}

/// Result of a subscription permission check
class SubscriptionCheckResult {
  final bool allowed;
  final String? reason;
  final bool requiresUpgrade;
  final int? currentLimit;

  SubscriptionCheckResult({
    required this.allowed,
    this.reason,
    this.requiresUpgrade = false,
    this.currentLimit,
  });
}

/// Info about a subscription tier for display
class SubscriptionTierInfo {
  final SubscriptionLevel level;
  final String name;
  final String price;
  final List<String> features;

  SubscriptionTierInfo({
    required this.level,
    required this.name,
    required this.price,
    required this.features,
  });
}
