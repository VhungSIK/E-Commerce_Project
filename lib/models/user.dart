// lib/models/user.dart

class User {
  final int userId;
  final String username;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final String avatarUrl;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatarUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'user', 
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}
