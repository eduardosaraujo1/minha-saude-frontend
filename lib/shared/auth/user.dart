class User {
  final String id;
  final String name;
  final String email;
  final String telefone;
  final String cpf;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.telefone,
    required this.cpf,
  });

  // fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? json['nome'] ?? 'User',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      cpf: json['cpf'] ?? '',
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
    };
  }
}
