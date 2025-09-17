class User {
  final String? id;
  final String email;
  final String name;
  final String? password;

  User({this.id, required this.email, required this.name, this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?, 
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
}
