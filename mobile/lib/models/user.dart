class User {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String preferredLanguage;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.preferredLanguage,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'ru',
      role: json['role'] as String? ?? 'user',
    );
  }
}
