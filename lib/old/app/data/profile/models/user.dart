class User {
  final String name;
  final String email;
  final String telefone;
  final String cpf;
  final String birthDate;
  final LoginType? loginType;

  const User({
    required this.name,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.birthDate,
    this.loginType = LoginType.email,
  });

  // fromJson
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? json['nome'] ?? 'User',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      cpf: json['cpf'] ?? '',
      birthDate: json['birth_date'] ?? '',
      loginType: json['login_type'] != null
          ? LoginType.values.firstWhere(
              (e) => e.toString() == 'LoginType.${json['login_type']}',
              orElse: () => LoginType.email,
            )
          : LoginType.email,
    );
  }

  // toJson
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'birth_date': birthDate,
      'login_type': loginType.toString().split('.').last,
    };
  }

  // Create a copy with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? telefone,
    String? cpf,
    String? birthDate,
    LoginType? loginType,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      loginType: loginType,
    );
  }
}

enum LoginType { google, email }
