import 'package:faker/faker.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';

/// Generates a valid CPF for testing purposes
String generateValidCpf() {
  final random = faker.randomGenerator;

  // Generate first 9 digits, ensuring they're not all the same
  String cpf;
  do {
    cpf = List.generate(9, (_) => random.integer(10)).join();
  } while (RegExp(r'^(.)\1*$').hasMatch(cpf));

  // Calculate first verification digit
  int calcularDigito(String base) {
    int soma = 0;
    for (int i = 0; i < base.length; i++) {
      soma += int.parse(base[i]) * (base.length + 1 - i);
    }
    int resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  final digito1 = calcularDigito(cpf);
  final digito2 = calcularDigito(cpf + digito1.toString());

  return cpf + digito1.toString() + digito2.toString();
}

Profile randomProfile() {
  var dateTime = faker.date.dateTime(minYear: 1950, maxYear: 2023);
  return Profile(
    id: faker.guid.guid(),
    email: faker.internet.email(),
    cpf: generateValidCpf(),
    nome: faker.person.name(),
    telefone: faker.randomGenerator.fromPattern(['##9########']),
    dataNascimento: DateTime(dateTime.year, dateTime.month, dateTime.day),
    metodoAutenticacao: AuthMethod
        .values[faker.randomGenerator.integer(AuthMethod.values.length)],
  );
}

Profile arbitraryProfile() {
  return Profile(
    id: 'arbitrary-id',
    email: 'arbitrary-email@example.com',
    cpf: '12345678909',
    nome: 'Arbitrary Name',
    telefone: '11987654321',
    dataNascimento: DateTime(1990, 1, 1),
    metodoAutenticacao: AuthMethod.values[0],
  );
}
