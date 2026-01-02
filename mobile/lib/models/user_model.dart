class UserModel {
  final int? userId;
  final String name;
  final String email;
  final String? passwordHash;
  final String? avatarUrl;
  final String? role;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.userId,
    required this.name,
    required this.email,
    this.passwordHash,
    this.avatarUrl,
    this.role,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int?,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'avatar_url': avatarUrl,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? userId,
    String? name,
    String? email,
    String? passwordHash,
    String? avatarUrl,
    String? role,
    int? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



