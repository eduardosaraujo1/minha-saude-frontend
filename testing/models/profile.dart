import 'package:faker/faker.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';

Profile randomProfile() {
  return Profile(
    id: faker.guid.guid(),
    email: faker.internet.email(),
    cpf: faker.randomGenerator.fromPattern(['###########']),
    nome: faker.person.name(),
    telefone: faker.phoneNumber.us(),
    dataNascimento: faker.date.dateTime(minYear: 1950, maxYear: 2023),
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
    telefone: '123-456-7890',
    dataNascimento: DateTime(1990, 1, 1),
    metodoAutenticacao: AuthMethod.values[0],
  );
}
