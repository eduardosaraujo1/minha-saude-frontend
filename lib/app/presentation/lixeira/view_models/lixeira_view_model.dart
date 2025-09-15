import 'dart:collection';

import 'package:minha_saude_frontend/app/data/document/models/document.dart';

class LixeiraViewModel {
  final _deletedDocuments = [
    // Exemplos de documentos deletados
    Document(
      id: '1',
      paciente: 'João Silva',
      titulo: 'Exame de Sangue',
      tipo: 'Exame',
      medico: 'Dra. Maria',
      dataDocumento: DateTime(2023, 5, 20),
      dataAdicao: DateTime(2023, 5, 21),
      deletedAt: DateTime(2024, 6, 1),
    ),
    Document(
      id: '2',
      paciente: 'Ana Souza',
      titulo: 'Receita Médica',
      tipo: 'Receita',
      medico: 'Dr. Carlos',
      dataDocumento: DateTime(2023, 4, 15),
      dataAdicao: DateTime(2023, 4, 16),
      deletedAt: DateTime(2024, 6, 2),
    ),
  ];

  List<Document> get deletedDocuments =>
      UnmodifiableListView(_deletedDocuments);
}
