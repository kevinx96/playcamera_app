class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  /// Factory constructor to create a User from JSON data
  /// This helps in parsing the user data received from the API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'], // DB schema uses full_name
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
