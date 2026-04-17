import '../models/guest_session.dart';
import 'guest_session_storage.dart';

/// Maximum number of reminders a guest user can create
const int kGuestMaxReminders = 3;

/// Guest session manager
/// Handles guest session lifecycle and access control
class GuestSessionManager {
  final GuestSessionStorage _storage;
  GuestSession? _currentSession;

  GuestSessionManager(this._storage);

  /// Initialize and get or create guest session
  Future<GuestSession> initialize() async {
    // Try to load existing session
    final existingSession = _storage.loadSession();

    if (existingSession != null) {
      if (existingSession.isValid) {
        // Valid existing session
        _currentSession = existingSession;
        return _currentSession!;
      } else if (existingSession.isUpgraded) {
        // Already upgraded, clear and create new
        await _storage.clearSession();
      }
      // Expired or upgraded, create new session
    }

    // Create new guest session
    _currentSession = GuestSession.create();
    await _storage.saveSession(_currentSession!);
    return _currentSession!;
  }

  /// Get current guest session
  GuestSession? get currentSession => _currentSession;

  /// Check if user is a guest
  bool get isGuest => _currentSession != null && _currentSession!.isValid;

  /// Check if user can create more reminders
  bool get canCreateReminder {
    if (!isGuest) return true; // Registered users have no limit
    return _storage.getReminderCount() < kGuestMaxReminders;
  }

  /// Get remaining reminder slots for guest
  int get remainingReminderSlots {
    if (!isGuest) return -1; // Unlimited for registered users
    return kGuestMaxReminders - _storage.getReminderCount();
  }

  /// Check and update session validity
  Future<bool> validateSession() async {
    if (_currentSession == null) return false;

    if (_currentSession!.isExpired) {
      // Session expired, create new one
      await clearGuestSession();
      await initialize();
      return false;
    }

    if (_currentSession!.isUpgraded) {
      return false;
    }

    return true;
  }

  /// Record a reminder creation
  Future<void> onReminderCreated() async {
    await _storage.incrementReminderCount();
  }

  /// Record a reminder deletion
  Future<void> onReminderDeleted() async {
    await _storage.decrementReminderCount();
  }

  /// Upgrade guest to registered user
  /// Returns the upgraded session data for migration
  Future<Map<String, dynamic>> upgradeToRegisteredUser() async {
    if (_currentSession == null) {
      throw Exception('No guest session to upgrade');
    }

    // Create upgraded session
    final upgradedSession = _currentSession!.upgrade();

    // Save upgraded session and clear guest data
    await _storage.saveSession(upgradedSession);

    // Get guest reminders for migration
    final guestRemindersData = _storage.getGuestRemindersData();

    // Clear guest reminder count (user now has no local limit)
    await _storage.resetReminderCount();

    // Update current session
    _currentSession = upgradedSession;

    return {
      'upgradedSession': upgradedSession,
      'guestRemindersData': guestRemindersData,
      'originalSessionId': _currentSession!.originalSessionId,
    };
  }

  /// Clear guest session (logout for guest)
  Future<void> clearGuestSession() async {
    await _storage.clearSession();
    _currentSession = null;
  }

  /// Get session expiry info
  String? getSessionExpiryInfo() {
    if (_currentSession == null) return null;

    final expiresAt = _currentSession!.expiresAt;
    final remaining = expiresAt.difference(DateTime.now());

    if (remaining.isNegative) {
      return 'Expired';
    } else if (remaining.inDays > 0) {
      return 'Expires in ${remaining.inDays} days';
    } else if (remaining.inHours > 0) {
      return 'Expires in ${remaining.inHours} hours';
    } else {
      return 'Expires in ${remaining.inMinutes} minutes';
    }
  }
}
