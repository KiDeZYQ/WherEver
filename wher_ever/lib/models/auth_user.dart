/// Authentication state enumeration
enum AuthState {
  /// Initial state, checking session
  initializing,

  /// User is authenticated as a guest
  guest,

  /// User is authenticated as a registered user
  authenticated,

  /// No session available
  unauthenticated,
}

/// Authentication user model
class AuthUser {
  final String id;
  final String? username;
  final String? email;
  final bool isGuest;
  final DateTime? createdAt;

  AuthUser({
    required this.id,
    this.username,
    this.email,
    this.isGuest = false,
    this.createdAt,
  });

  factory AuthUser.guest(String sessionId) {
    return AuthUser(
      id: sessionId,
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isGuest': isGuest,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
