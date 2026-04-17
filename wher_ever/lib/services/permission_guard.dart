import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/subscription_level.dart';
import '../pages/auth/auth_controller.dart';
import 'subscription_service.dart';
import '../widgets/subscription_dialog.dart';

/// Permission guard for checking user permissions
/// Integrates with AuthController and SubscriptionService
class PermissionGuard {
  final AuthController _authController;
  final SubscriptionService _subscriptionService;

  PermissionGuard({
    AuthController? authController,
    SubscriptionService? subscriptionService,
  })  : _authController = authController ?? Get.find<AuthController>(),
        _subscriptionService = subscriptionService ?? Get.find<SubscriptionService>();

  /// Get current user's subscription level
  SubscriptionLevel get currentLevel {
    final user = _authController.currentUser.value;
    if (user == null) return SubscriptionLevel.free;
    return SubscriptionLevelExtension.fromInt(user.subscriptionLevel);
  }

  /// Check if user is guest (not logged in)
  bool get isGuest => !_authController.isLoggedIn.value;

  /// Check if user is premium
  bool get isPremium => currentLevel == SubscriptionLevel.premium;

  /// Check if user can perform action with feature name
  PermissionResult check(String featureName, int currentUsage) {
    // Guest users have limited permissions
    if (isGuest) {
      return PermissionResult(
        allowed: false,
        reason: 'Please login to access this feature',
        requiresLogin: true,
      );
    }

    // Premium users have full access
    if (isPremium) {
      return PermissionResult(allowed: true);
    }

    // Check permission for free users
    final result = _subscriptionService.checkPermission(
      level: currentLevel,
      featureName: featureName,
      currentUsage: currentUsage,
    );

    return PermissionResult(
      allowed: result.allowed,
      reason: result.reason,
      requiresUpgrade: result.requiresUpgrade,
    );
  }

  /// Check if user can create reminder
  PermissionResult canCreateReminder(int currentReminderCount) {
    return check('Reminders', currentReminderCount);
  }

  /// Check if user can create geofence
  PermissionResult canCreateGeofence(int currentGeofenceCount) {
    return check('Geofences', currentGeofenceCount);
  }

  /// Check if user can export data
  PermissionResult canExportData() {
    return check('Data Export', 0);
  }

  /// Check location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Show appropriate dialog based on permission result
  Future<bool> showPermissionDialog(
    BuildContext context,
    PermissionResult result,
  ) async {
    if (result.allowed) {
      return true;
    }

    if (result.requiresLogin) {
      // Redirect to login
      Get.toNamed('/login');
      return false;
    }

    if (result.requiresUpgrade) {
      // Show upgrade dialog
      await showUpgradeRequiredDialog(
        context,
        featureName: 'this feature',
        message: result.reason,
      );
      return false;
    }

    // Show generic permission denied message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.reason ?? 'Permission denied'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}

/// Result of a permission check
class PermissionResult {
  final bool allowed;
  final String? reason;
  final bool requiresLogin;
  final bool requiresUpgrade;

  PermissionResult({
    required this.allowed,
    this.reason,
    this.requiresLogin = false,
    this.requiresUpgrade = false,
  });
}
