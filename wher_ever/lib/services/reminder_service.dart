import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../models/reminder.dart';
import 'auth_service.dart';

/// Service for creating and managing reminders
class ReminderService extends GetxService {
  final Dio _dio = Get.find<Dio>();
  final AuthService _authService = Get.find<AuthService>();

  /// Get reminders for current user
  Future<List<Reminder>> getReminders() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _dio.get('/api/reminders', queryParameters: {
        'userId': userId,
      });
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Reminder.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Create a new reminder
  Future<Reminder?> createReminder({
    required String title,
    String? content,
    String? locationName,
    double? latitude,
    double? longitude,
    int fenceRadius = 100,
    int triggerType = 1,
    int? repeatType,
  }) async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return null;

    final now = DateTime.now();
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      content: content,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      fenceRadius: fenceRadius,
      triggerType: TriggerType.fromInt(triggerType),
      status: ReminderStatus.enabled,
      repeatRule: repeatType != null && repeatType != 0
          ? RepeatRule(type: RepeatType.fromInt(repeatType))
          : null,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _dio.post('/api/reminders', data: reminder.toJson());
      return reminder;
    } catch (e) {
      return null;
    }
  }

  /// Update an existing reminder
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      await _dio.put('/api/reminders/${reminder.id}', data: reminder.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a reminder (soft delete)
  Future<bool> deleteReminder(String reminderId) async {
    try {
      await _dio.delete('/api/reminders/$reminderId');
      return true;
    } catch (e) {
      return false;
    }
  }
}
