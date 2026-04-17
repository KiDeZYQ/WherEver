import '../models/auth_user.dart';
import 'guest_session_manager.dart' show GuestSessionManager, kGuestMaxReminders;

/// Authentication service
/// Manages user authentication state including guest sessions
class AuthService {
  final GuestSessionManager _guestSessionManager;
  AuthUser? _currentUser;
  AuthState _state = AuthState.initializing;

  AuthService(this._guestSessionManager);

  /// Get current authentication state
  AuthState get state => _state;

  /// Get current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Check if user is guest
  bool get isGuest => _state == AuthState.guest;

  /// Check if user is authenticated (non-guest)
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Initialize authentication
  /// This should be called on app startup
  Future<void> initialize() async {
    _state = AuthState.initializing;

    // Initialize guest session
    final guestSession = await _guestSessionManager.initialize();

    if (guestSession.isValid) {
      _currentUser = AuthUser.guest(guestSession.sessionId);
      _state = AuthState.guest;
    } else if (guestSession.isUpgraded) {
      // Load registered user session (placeholder for future)
      // For now, treat as authenticated
      _currentUser = AuthUser(
        id: guestSession.sessionId,
        isGuest: false,
        createdAt: guestSession.createdAt,
      );
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
  }

  /// Check if user can perform an action
  /// Returns error message if action is not allowed, null otherwise
  String? checkPermission(String action) {
    switch (action) {
      case 'create_reminder':
        if (isGuest) {
          if (_guestSessionManager.canCreateReminder) {
            return null;
          }
          return 'Guest users can only create up to $kGuestMaxReminders reminders. Please register to create more.';
        }
        return null;

      case 'export_data':
        if (isGuest) {
          return 'Please register to export your data.';
        }
        return null;

      default:
        return null;
    }
  }

  /// Get remaining reminder slots
  int getRemainingReminderSlots() {
    return _guestSessionManager.remainingReminderSlots;
  }

  /// Register a new user (placeholder)
  Future<AuthUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    // TODO: Implement actual registration API call
    // For now, simulate successful registration
    await Future.delayed(const Duration(milliseconds: 500));

    final user = AuthUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    // Upgrade guest session to registered user
    await _guestSessionManager.upgradeToRegisteredUser();

    _currentUser = user;
    _state = AuthState.authenticated;

    return user;
  }

  /// Login (placeholder)
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    // TODO: Implement actual login API call
    await Future.delayed(const Duration(milliseconds: 500));

    final user = AuthUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _state = AuthState.authenticated;

    return user;
  }

  /// Logout
  Future<void> logout() async {
    // TODO: Call logout API if needed
    await _guestSessionManager.clearGuestSession();
    _currentUser = null;
    _state = AuthState.unauthenticated;
  }

  /// Guest creates reminder (record the action)
  Future<void> onGuestReminderCreated() async {
    await _guestSessionManager.onReminderCreated();
  }

  /// Guest deletes reminder (record the action)
  Future<void> onGuestReminderDeleted() async {
    await _guestSessionManager.onReminderDeleted();
  }

  /// Get guest session expiry info
  String? getSessionExpiryInfo() {
    return _guestSessionManager.getSessionExpiryInfo();
  }
}
