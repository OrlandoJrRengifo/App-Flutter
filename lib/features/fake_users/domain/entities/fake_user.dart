class FakeUser {
  final String? id;       
  final String authId;    
  final String email;
  final String name;

  FakeUser({
    this.id,
    required this.authId,
    required this.email,
    required this.name,
  });

  factory FakeUser.fromJson(Map<String, dynamic> json) {
    return FakeUser(
      id: json['id'] as String?,
      authId: json['auth_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_id': authId,
      'email': email,
      'name': name,
    };
  }
}
