/// Guest Session Model
/// Represents a temporary guest user session
class GuestSession {
  /// Unique session ID (UUID v4)
  final String sessionId;

  /// Session creation timestamp
  final DateTime createdAt;

  /// Session expiry timestamp
  final DateTime expiresAt;

  /// Whether the guest has upgraded to a full account
  final bool isUpgraded;

  /// Original guest session ID before upgrade (if upgraded)
  final String? originalSessionId;

  GuestSession({
    required this.sessionId,
    required this.createdAt,
    required this.expiresAt,
    this.isUpgraded = false,
    this.originalSessionId,
  });

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if session is valid (not expired and not upgraded)
  bool get isValid => !isExpired && !isUpgraded;

  /// Create from JSON map
  factory GuestSession.fromJson(Map<String, dynamic> json) {
    return GuestSession(
      sessionId: json['sessionId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isUpgraded: json['isUpgraded'] as bool? ?? false,
      originalSessionId: json['originalSessionId'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isUpgraded': isUpgraded,
      'originalSessionId': originalSessionId,
    };
  }

  /// Create a new guest session with default 7-day expiry
  factory GuestSession.create() {
    final now = DateTime.now();
    return GuestSession(
      sessionId: _generateUuid(),
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );
  }

  /// Create an upgraded session from a guest session
  GuestSession upgrade() {
    return GuestSession(
      sessionId: _generateUuid(),
      createdAt: DateTime.now(),
      expiresAt: expiresAt, // Keep same expiry
      isUpgraded: true,
      originalSessionId: sessionId,
    );
  }

  /// Generate UUID v4
  static String _generateUuid() {
    // UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final random = DateTime.now().microsecondsSinceEpoch;
    final hexRandom = random.toRadixString(16).padLeft(8, '0');
    final timeLow = hexRandom.substring(0, 8);
    final timeMid = hexRandom.substring(0, 4);
    final timeHighAndVersion = '4${hexRandom.substring(0, 3)}';
    final clockSeqAndReserved = (random % 16).toRadixString(16);
    final clockSeqLow = hexRandom.substring(0, 1);
    final node = hexRandom.padLeft(12, '0').substring(0, 12);

    return '$timeLow-$timeMid-$timeHighAndVersion-$clockSeqAndReserved$clockSeqLow-$node';
  }

  @override
  String toString() {
    return 'GuestSession(sessionId: $sessionId, createdAt: $createdAt, expiresAt: $expiresAt, isUpgraded: $isUpgraded)';
  }
}
