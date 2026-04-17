import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guest_session.dart';

/// Service for managing guest session storage
class GuestSessionStorage {
  static const String _keyGuestSession = 'guest_session';
  static const String _keyGuestReminders = 'guest_reminders';
  static const String _keyReminderCount = 'guest_reminder_count';

  final SharedPreferences _prefs;

  GuestSessionStorage(this._prefs);

  /// Save guest session
  Future<bool> saveSession(GuestSession session) async {
    return await _prefs.setString(_keyGuestSession, jsonEncode(session.toJson()));
  }

  /// Load guest session
  GuestSession? loadSession() {
    final jsonStr = _prefs.getString(_keyGuestSession);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GuestSession.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Clear guest session
  Future<bool> clearSession() async {
    await _prefs.remove(_keyGuestSession);
    await _prefs.remove(_keyGuestReminders);
    await _prefs.remove(_keyReminderCount);
    return true;
  }

  /// Get current reminder count for guest
  int getReminderCount() {
    return _prefs.getInt(_keyReminderCount) ?? 0;
  }

  /// Increment reminder count
  Future<int> incrementReminderCount() async {
    final count = getReminderCount() + 1;
    await _prefs.setInt(_keyReminderCount, count);
    return count;
  }

  /// Decrement reminder count
  Future<int> decrementReminderCount() async {
    final count = getReminderCount() - 1;
    await _prefs.setInt(_keyReminderCount, count < 0 ? 0 : count);
    return count;
  }

  /// Reset reminder count (when upgrading)
  Future<void> resetReminderCount() async {
    await _prefs.setInt(_keyReminderCount, 0);
  }

  /// Get guest reminders data
  String? getGuestRemindersData() {
    return _prefs.getString(_keyGuestReminders);
  }

  /// Save guest reminders data
  Future<bool> saveGuestRemindersData(String data) async {
    return await _prefs.setString(_keyGuestReminders, data);
  }
}
