import 'dart:convert';

/// User model representing a user in the system
class User {
  final String id;
  final String name;
  final String email;
  final String telefone;
  final String cpf;
  final String birthDate;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.birthDate,
  });

  // fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? json['nome'] ?? 'User',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      cpf: json['cpf'] ?? '',
      birthDate: json['birth_date'] ?? '',
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
      'birth_date': birthDate,
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
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  // For persistent storage
  String toJsonString() => jsonEncode(toJson());

  // From persistent storage
  static User? fromJsonString(String? jsonString) {
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
