/// Reminder model
class Reminder {
  final String id;
  final String userId;
  final String title;
  final String? content;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int fenceRadius; // in meters
  final TriggerType triggerType;
  final ReminderStatus status;
  final RepeatRule? repeatRule;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool deleted;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    this.locationName,
    this.latitude,
    this.longitude,
    this.fenceRadius = 100,
    this.triggerType = TriggerType.arrive,
    this.status = ReminderStatus.enabled,
    this.repeatRule,
    required this.createdAt,
    required this.updatedAt,
    this.deleted = false,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      fenceRadius: json['fenceRadius'] as int? ?? 100,
      triggerType: TriggerType.fromInt(json['triggerType'] as int? ?? 1),
      status: ReminderStatus.fromInt(json['status'] as int? ?? 1),
      repeatRule: json['repeatRule'] != null
          ? RepeatRule.fromJson(json['repeatRule'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'fenceRadius': fenceRadius,
      'triggerType': triggerType.value,
      'status': status.value,
      'repeatRule': repeatRule?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': deleted,
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? locationName,
    double? latitude,
    double? longitude,
    int? fenceRadius,
    TriggerType? triggerType,
    ReminderStatus? status,
    RepeatRule? repeatRule,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fenceRadius: fenceRadius ?? this.fenceRadius,
      triggerType: triggerType ?? this.triggerType,
      status: status ?? this.status,
      repeatRule: repeatRule ?? this.repeatRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  /// Check if reminder has location
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if reminder is repeating
  bool get isRepeating => repeatRule != null;
}

/// Trigger type enumeration
enum TriggerType {
  arrive(1, 'Arrive'),
  leave(2, 'Leave'),
  both(3, 'Both');

  final int value;
  final String label;

  const TriggerType(this.value, this.label);

  static TriggerType fromInt(int value) {
    return TriggerType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TriggerType.arrive,
    );
  }
}

/// Reminder status enumeration
enum ReminderStatus {
  disabled(0, 'Disabled'),
  enabled(1, 'Enabled');

  final int value;
  final String label;

  const ReminderStatus(this.value, this.label);

  static ReminderStatus fromInt(int value) {
    return ReminderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReminderStatus.enabled,
    );
  }
}

/// Repeat rule model
class RepeatRule {
  final RepeatType type;
  final List<int>? daysOfWeek; // 1=Monday, 7=Sunday
  final int? dayOfMonth;
  final DateTime? startDate;
  final DateTime? endDate;

  RepeatRule({
    required this.type,
    this.daysOfWeek,
    this.dayOfMonth,
    this.startDate,
    this.endDate,
  });

  factory RepeatRule.fromJson(Map<String, dynamic> json) {
    return RepeatRule(
      type: RepeatType.fromInt(json['type'] as int),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.cast<int>(),
      dayOfMonth: json['dayOfMonth'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}

/// Repeat type enumeration
enum RepeatType {
  none(0, 'No repeat'),
  daily(1, 'Daily'),
  weekly(2, 'Weekly'),
  monthly(3, 'Monthly'),
  yearly(4, 'Yearly');

  final int value;
  final String label;

  const RepeatType(this.value, this.label);

  static RepeatType fromInt(int value) {
    return RepeatType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RepeatType.none,
    );
  }
}
