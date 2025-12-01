class UserModel {
  final int? userId;
  final String firebaseUid;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  UserModel({
    this.userId,
    required this.firebaseUid,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int?,
      firebaseUid: json['firebase_uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? userId,
    String? firebaseUid,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}



