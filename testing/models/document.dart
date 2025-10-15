import 'package:faker/faker.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';

Document randomDocument({isDeleted = false}) {
  return Document(
    uuid: faker.guid.guid(),
    titulo: faker.lorem.words(2).join(' '),
    dataDocumento: faker.date.dateTime(minYear: 2000, maxYear: 2024),
    medico: faker.person.name(),
    createdAt: DateTime.now(),
    paciente: faker.person.name(),
    tipo: faker.lorem.word(),
    deletedAt: isDeleted ? DateTime.now() : null,
  );
}

Document arbitraryDocument() {
  return Document(
    uuid: 'arbitrary-uuid',
    titulo: 'Arbitrary Title',
    dataDocumento: DateTime(2023, 5, 20),
    medico: 'Dr. Arbitrary',
    paciente: 'Jane Doe',
    tipo: 'Tipo B',
    createdAt: DateTime(2023, 5, 20),
  );
}
