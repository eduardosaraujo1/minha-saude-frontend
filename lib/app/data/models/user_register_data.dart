class UserRegisterData {
  // cpf,nome_completo,data_nascimento,telefone
  String cpf;
  String nome;
  DateTime dataNascimento;
  String telefone;

  UserRegisterData({
    required this.cpf,
    required this.nome,
    required this.dataNascimento,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      'cpf': cpf,
      'nome_completo': nome,
      'data_nascimento': dataNascimento.toIso8601String().split(
        'T',
      )[0], // yyyy-mm-dd
      'telefone': telefone,
    };
  }

  static UserRegisterData fromMap(Map<String, dynamic> map) {
    return UserRegisterData(
      cpf: map['cpf'],
      nome: map['nome_completo'],
      dataNascimento: DateTime.parse(
        map['data_nascimento'],
      ), // handles yyyy-mm-dd
      telefone: map['telefone'],
    );
  }
}
