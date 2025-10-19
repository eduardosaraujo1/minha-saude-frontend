import 'package:faker/faker.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';

const b0001 = 1;
const b0010 = 2;
const b0100 = 4;
const b1000 = 8;

/// Generates a random Document instance with some fields possibly set to null.
/// The [isDeleted] parameter determines if the document is marked as deleted.
Document randomDocument({bool isDeleted = false}) {
  // Generate a random number to determine which values should be null
  // There are 4 fields that can be null: paciente, medico, tipo, dataDocumento
  // This gives us 16 combinations (2^4), between 0b0000 and 0b1111 (0 to 15)
  final random = faker.randomGenerator.integer(16);

  // Use bitwise operations to decide which fields to set to null
  var paciente = (random & b0001) != 0 ? null : faker.person.name();
  var medico = (random & b0010) != 0 ? null : faker.person.name();
  var tipo = (random & b0100) != 0 ? null : faker.lorem.word();
  var dataDocumento = (random & b1000) != 0
      ? null
      : faker.date.dateTime(minYear: 2000, maxYear: 2024);

  return Document(
    uuid: faker.guid.guid(),
    titulo: faker.lorem.words(2).join(' '),
    dataDocumento: dataDocumento != null
        ? DateTime(dataDocumento.year, dataDocumento.month, dataDocumento.day)
        : null,
    paciente: paciente,
    medico: medico,
    tipo: tipo,
    createdAt: DateTime.now(),
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
