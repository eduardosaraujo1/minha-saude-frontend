class UserDto {
  // cpf,nome_completo,data_nascimento,telefone
  String cpf;
  String nomeCompleto;
  DateTime dataNascimento;
  String telefone;

  UserDto({
    required this.cpf,
    required this.nomeCompleto,
    required this.dataNascimento,
    required this.telefone,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'nome_completo': nomeCompleto,
      'data_nascimento': dataNascimento.toIso8601String().split(
        'T',
      )[0], // yyyy-mm-dd
      'telefone': telefone,
    };
  }

  // fromJson
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      cpf: json['cpf'],
      nomeCompleto: json['nome_completo'],
      dataNascimento: DateTime.parse(
        json['data_nascimento'],
      ), // handles yyyy-mm-dd
      telefone: json['telefone'],
    );
  }
}
