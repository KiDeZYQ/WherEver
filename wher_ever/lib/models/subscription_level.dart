/// Subscription level enumeration
enum SubscriptionLevel {
  free,
  premium,
}

/// Extension methods for SubscriptionLevel
extension SubscriptionLevelExtension on SubscriptionLevel {
  /// Get display name
  String get displayName {
    switch (this) {
      case SubscriptionLevel.free:
        return 'Free';
      case SubscriptionLevel.premium:
        return 'Premium';
    }
  }

  /// Get price string
  String get priceString {
    switch (this) {
      case SubscriptionLevel.free:
        return 'Free';
      case SubscriptionLevel.premium:
        return '\$4.99/month';
    }
  }

  /// Check if this level is premium or higher
  bool get isPremium => this == SubscriptionLevel.premium;

  /// Parse from integer value
  static SubscriptionLevel fromInt(int value) {
    switch (value) {
      case 1:
        return SubscriptionLevel.free;
      case 2:
        return SubscriptionLevel.premium;
      default:
        return SubscriptionLevel.free;
    }
  }
}

/// Subscription feature model
class SubscriptionFeature {
  final String name;
  final String description;
  final int freeLimit;
  final int? premiumLimit; // null means unlimited
  final bool premiumOnly;

  const SubscriptionFeature({
    required this.name,
    required this.description,
    required this.freeLimit,
    this.premiumLimit,
    this.premiumOnly = false,
  });

  /// Check if feature is available for given level
  bool isAvailable(SubscriptionLevel level) {
    if (premiumOnly && level != SubscriptionLevel.premium) {
      return false;
    }
    return true;
  }

  /// Check if limit is reached for given level
  bool isLimitReached(SubscriptionLevel level, int currentUsage) {
    if (!isAvailable(level)) return true;

    final limit = level == SubscriptionLevel.premium ? premiumLimit : freeLimit;
    if (limit == null) return false; // unlimited
    return currentUsage >= limit;
  }

  /// Get limit for given level
  int? getLimit(SubscriptionLevel level) {
    return level == SubscriptionLevel.premium ? premiumLimit : freeLimit;
  }

  /// Check if unlimited
  bool get isUnlimited {
    return premiumLimit == null;
  }
}
