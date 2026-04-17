import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/reminder.dart';
import 'auth_service.dart';
import 'token_storage.dart';

/// Service for exporting and importing reminder data
class DataExportService extends GetxService {
  final Dio _dio = Get.find<Dio>();
  final AuthService _authService = Get.find<AuthService>();
  final TokenStorage _tokenStorage = TokenStorage();

  /// Export all reminders to JSON string
  Future<String> exportToJson(List<Reminder> reminders) async {
    final data = reminders.map((r) => r.toJson()).toList();
    return jsonEncode({
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'reminders': data,
    });
  }

  /// Export reminders to file (returns file path)
  Future<String?> exportToFile(List<Reminder> reminders) async {
    try {
      final json = await exportToJson(reminders);
      final fileName = 'wher_ever_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      // In a real app, use path_provider and file I/O
      // For now, return the JSON
      return json;
    } catch (e) {
      return null;
    }
  }

  /// Import reminders from JSON string
  Future<List<Reminder>?> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final remindersList = data['reminders'] as List<dynamic>;
      return remindersList
          .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Sync reminders to cloud (mock)
  Future<bool> syncToCloud(List<Reminder> reminders) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return false;

      // Mock API call
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restore reminders from cloud (mock)
  Future<List<Reminder>?> restoreFromCloud() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return null;

      // Mock API call - would GET /api/users/{userId}/reminders
      await Future.delayed(const Duration(milliseconds: 500));
      return null; // No data to restore
    } catch (e) {
      return null;
    }
  }

  /// Upload reminder to cloud
  Future<bool> uploadReminder(Reminder reminder) async {
    try {
      await _dio.post('/api/reminders', data: reminder.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete reminder from cloud
  Future<bool> deleteFromCloud(String reminderId) async {
    try {
      await _dio.delete('/api/reminders/$reminderId');
      return true;
    } catch (e) {
      return false;
    }
  }
}
