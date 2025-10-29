class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  // final DateTime createdAt; // 您的 API JSON 中不包含此项，暂时注释

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    // required this.createdAt,
  });

  // Factory constructor to parse JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // 我们的 API 返回 'user_id'，但Dart习惯用'id'
      id: json['user_id'] ?? json['id'], 
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      // createdAt: DateTime.parse(json['created_at']),
    );
  }
}

