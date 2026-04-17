/// Result of parsing a voice command
class VoiceCommandParseResult {
  final String title;
  final String? content;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int? triggerType; // 1=arrive, 2=leave, 3=both
  final int? repeatType; // 0=none, 1=daily, 2=weekly, 3=monthly, 4=yearly
  final String? rawText;

  VoiceCommandParseResult({
    required this.title,
    this.content,
    this.locationName,
    this.latitude,
    this.longitude,
    this.triggerType,
    this.repeatType,
    this.rawText,
  });

  bool get hasLocation => locationName != null || (latitude != null && longitude != null);
  bool get hasRepeat => repeatType != null && repeatType != 0;
}

/// Service for parsing voice commands into reminder data
class VoiceCommandParser {
  // Chinese keywords
  static const List<String> _arriveKeywords = ['到达', '抵达', '进入', '靠近'];
  static const List<String> _leaveKeywords = ['离开', '出去', '走出', '远离'];
  static const List<String> _bothKeywords = ['进出', '出入'];
  static const List<String> _dailyKeywords = ['每天', '日日', '天天'];
  static const List<String> _weeklyKeywords = ['每周', '每周', '星期', '周'];
  static const List<String> _monthlyKeywords = ['每月', '月月'];
  static const List<String> _locationKeywords = ['在', '到', '位于'];

  /// Parse voice command text into reminder data
  VoiceCommandParseResult parse(String text) {
    String title = text;
    String? content;
    String? locationName;
    double? latitude;
    double? longitude;
    int? triggerType;
    int? repeatType = 0;

    // Detect trigger type
    if (_containsAny(text, _bothKeywords)) {
      triggerType = 3; // both
    } else if (_containsAny(text, _leaveKeywords)) {
      triggerType = 2; // leave
    } else if (_containsAny(text, _arriveKeywords)) {
      triggerType = 1; // arrive
    }

    // Detect repeat type
    if (_containsAny(text, _dailyKeywords)) {
      repeatType = 1; // daily
    } else if (_containsAny(text, _weeklyKeywords)) {
      repeatType = 2; // weekly
    } else if (_containsAny(text, _monthlyKeywords)) {
      repeatType = 3; // monthly
    }

    // Extract location (simple implementation)
    for (final keyword in _locationKeywords) {
      final index = text.indexOf(keyword);
      if (index != -1 && index < text.length - 1) {
        locationName = text.substring(index + keyword.length).trim();
        // Remove location part from title
        title = text.substring(0, index).trim();
        break;
      }
    }

    // Clean up title
    title = _cleanTitle(title);

    return VoiceCommandParseResult(
      title: title.isEmpty ? text : title,
      content: content,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      triggerType: triggerType,
      repeatType: repeatType,
      rawText: text,
    );
  }

  /// Check if text contains any of the keywords
  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Clean up title by removing extra whitespace and punctuation
  String _cleanTitle(String title) {
    // Remove common command words
    final commandWords = [
      '提醒我',
      '提醒',
      '叫我',
      '设置',
      '创建',
      '新建',
      '记得',
      '记住',
    ];

    String cleaned = title;
    for (final word in commandWords) {
      cleaned = cleaned.replaceAll(word, '');
    }

    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove trailing punctuation
    cleaned = cleaned.replaceAll(RegExp(r'[，。、！？]$'), '');

    return cleaned.trim();
  }
}
