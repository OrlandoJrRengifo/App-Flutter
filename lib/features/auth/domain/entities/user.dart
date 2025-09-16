class User {
  final String? id;        // 👈 ahora opcional
  final String email;
  final String name;
  final String? password;
  final String? avatarUrl;

  User({
    this.id,               // 👈 opcional en constructor
    required this.email,
    required this.name,
    this.password,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],               // UUID (string)
      email: json['email'],
      name: json['name'],
      password: json['password'],   // puede venir null
      avatarUrl: json['avatarUrl'], // puede venir null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,     // 👈 solo si existe
      'email': email,
      'name': name,
      if (password != null) 'password': password,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}
