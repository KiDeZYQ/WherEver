/// User model
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final int subscriptionLevel; // 1=free, 2=premium
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.phone,
    this.avatar,
    this.subscriptionLevel = 1,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      subscriptionLevel: json['subscriptionLevel'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'subscriptionLevel': subscriptionLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if user is premium
  bool get isPremium => subscriptionLevel >= 2;

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    int? subscriptionLevel,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      subscriptionLevel: subscriptionLevel ?? this.subscriptionLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
