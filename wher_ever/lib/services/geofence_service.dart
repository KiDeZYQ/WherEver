import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/reminder.dart';
import 'location_service.dart';
import 'notification_service.dart';

/// Service for monitoring geofences and triggering reminders
class GeofenceService extends GetxService {
  final LocationService _locationService = Get.find<LocationService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  final Map<String, _GeofenceMonitor> _monitoredGeofences = {};

  /// Start monitoring a reminder's geofence
  Future<void> startMonitoring(Reminder reminder) async {
    if (!reminder.hasLocation) return;

    final fenceId = reminder.id;

    // Stop existing monitor if any
    await stopMonitoring(fenceId);

    final monitor = _GeofenceMonitor(
      reminder: reminder,
      onTrigger: (triggerType) => _onGeofenceTriggered(reminder, triggerType),
    );

    _monitoredGeofences[fenceId] = monitor;
    await monitor.start(_locationService);
  }

  /// Stop monitoring a specific reminder
  Future<void> stopMonitoring(String reminderId) async {
    final monitor = _monitoredGeofences.remove(reminderId);
    if (monitor != null) {
      await monitor.stop();
    }
  }

  /// Stop monitoring all geofences
  Future<void> stopAllMonitoring() async {
    for (final monitor in _monitoredGeofences.values) {
      await monitor.stop();
    }
    _monitoredGeofences.clear();
  }

  /// Handle geofence trigger event
  void _onGeofenceTriggered(Reminder reminder, int triggerType) {
    _notificationService.showGeofenceNotification(
      title: reminder.title,
      body: triggerType == 1
          ? 'You have arrived at ${reminder.locationName}'
          : 'You have left ${reminder.locationName}',
      payload: reminder.id,
    );
  }

  /// Check if a reminder is being monitored
  bool isMonitoring(String reminderId) {
    return _monitoredGeofences.containsKey(reminderId);
  }

  /// Get count of monitored geofences
  int get monitoredCount => _monitoredGeofences.length;
}

/// Internal class for monitoring a single geofence
class _GeofenceMonitor {
  final Reminder reminder;
  final Function(int) onTrigger;
  StreamSubscription<Position>? _positionSubscription;

  bool _isInside = false;
  DateTime? _lastTriggerTime;
  static const _minTriggerInterval = Duration(minutes: 1);

  _GeofenceMonitor({
    required this.reminder,
    required this.onTrigger,
  });

  Future<void> start(LocationService locationService) async {
    // Get initial position
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      _checkPosition(position);
    }

    // Start listening for position updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((position) {
      _checkPosition(position);
    });
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _checkPosition(Position position) {
    if (reminder.latitude == null || reminder.longitude == null) return;

    final distance = Geolocator.distanceBetween(
      reminder.latitude!,
      reminder.longitude!,
      position.latitude,
      position.longitude,
    );

    final isInsideFence = distance <= reminder.fenceRadius;

    // Check if we crossed the boundary
    if (isInsideFence && !_isInside) {
      // Entered the fence
      _isInside = true;
      _maybeTrigger(1); // triggerType 1 = arrive
    } else if (!isInsideFence && _isInside) {
      // Exited the fence
      _isInside = false;
      _maybeTrigger(2); // triggerType 2 = leave
    }
  }

  void _maybeTrigger(int triggerType) {
    // Check if trigger type matches reminder's trigger setting
    final reminderTriggerType = reminder.triggerType.value;
    if (reminderTriggerType != 3 && reminderTriggerType != triggerType) {
      return; // Neither "both" nor matching trigger type
    }

    // Rate limit triggers
    final now = DateTime.now();
    if (_lastTriggerTime != null &&
        now.difference(_lastTriggerTime!) < _minTriggerInterval) {
      return;
    }

    _lastTriggerTime = now;
    onTrigger(triggerType);
  }
}
