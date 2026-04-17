import 'subscription_level.dart';

/// Subscription configuration with all features and limits
class SubscriptionConfig {
  /// All subscription features
  static const List<SubscriptionFeature> features = [
    SubscriptionFeature(
      name: 'Reminders',
      description: 'Number of reminders you can create',
      freeLimit: 3,
      premiumLimit: null, // unlimited
    ),
    SubscriptionFeature(
      name: 'Geofences',
      description: 'Number of location geofences',
      freeLimit: 3,
      premiumLimit: null, // unlimited
    ),
    SubscriptionFeature(
      name: 'Notification History',
      description: 'Days to keep notification history',
      freeLimit: 7,
      premiumLimit: 90,
    ),
    SubscriptionFeature(
      name: 'Data Export',
      description: 'Export your data to file',
      freeLimit: 0,
      premiumLimit: 1,
      premiumOnly: true,
    ),
    SubscriptionFeature(
      name: 'Priority Support',
      description: 'Get priority customer support',
      freeLimit: 0,
      premiumLimit: 1,
      premiumOnly: true,
    ),
  ];

  /// Get feature by name
  static SubscriptionFeature? getFeature(String name) {
    try {
      return features.firstWhere((f) => f.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Check if user can create more reminders
  static bool canCreateReminder(SubscriptionLevel level, int currentCount) {
    final feature = getFeature('Reminders');
    if (feature == null) return true;
    return !feature.isLimitReached(level, currentCount);
  }

  /// Check if user can create more geofences
  static bool canCreateGeofence(SubscriptionLevel level, int currentCount) {
    final feature = getFeature('Geofences');
    if (feature == null) return true;
    return !feature.isLimitReached(level, currentCount);
  }

  /// Check if user can export data
  static bool canExportData(SubscriptionLevel level) {
    final feature = getFeature('Data Export');
    if (feature == null) return false;
    return feature.isAvailable(level);
  }

  /// Get remaining reminders
  static int getRemainingReminders(SubscriptionLevel level, int currentCount) {
    final limit = level == SubscriptionLevel.premium
        ? null // unlimited
        : getFeature('Reminders')?.freeLimit;

    if (limit == null) return -1; // unlimited
    return limit - currentCount;
  }
}
