class User {
  // cpf,nome_completo,data_nascimento,telefone
  String cpf;
  String nome;
  DateTime dataNascimento;
  String telefone;

  User({
    required this.cpf,
    required this.nome,
    required this.dataNascimento,
    required this.telefone,
  });

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'nome_completo': nome,
      'data_nascimento': dataNascimento.toIso8601String().split(
        'T',
      )[0], // yyyy-mm-dd
      'telefone': telefone,
    };
  }

  // fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      cpf: json['cpf'],
      nome: json['nome_completo'],
      dataNascimento: DateTime.parse(
        json['data_nascimento'],
      ), // handles yyyy-mm-dd
      telefone: json['telefone'],
    );
  }
}
