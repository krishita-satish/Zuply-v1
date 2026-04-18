/// Represents a Zuply platform user (donor, recipient, or delivery agent).
class ZuplyUser {
  final int? id;
  final String email;
  final String name;
  final String role; // 'donor', 'recipient', 'agent'
  final String? token;

  ZuplyUser({
    this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

  factory ZuplyUser.fromJson(Map<String, dynamic> json, {String? token}) {
    return ZuplyUser(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      role: json['role'] ?? 'donor',
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
  };
}
