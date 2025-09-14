import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:multiple_result/multiple_result.dart';

class DocumentRepository {
  // CREATE

  // READ
  Future<Result<Document, Exception>> getDocumentById(String id) async {
    // Simulação de busca de documento por ID
    final documentsResult = await listDocuments();
    if (documentsResult.isError()) {
      return Result.error(Exception('Erro ao buscar documento'));
    }

    try {
      final document = documentsResult.getOrThrow().firstWhere(
        (doc) => doc.id == id,
      );
      return Result.success(document);
    } catch (e) {
      return Result.error(
        Exception('Documento não encontrado. Tente fechar a página.'),
      );
    }
  }

  // TODO: quando a escala do app justificar, implementar paginação via scroll infinito
  Future<Result<List<Document>, Exception>> listDocuments() async {
    // Simulação de leitura de documentos
    await Future.delayed(const Duration(milliseconds: 100));
    final List<Document> documentos = [
      Document(
        id: 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Exame de Sangue',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-01-15'),
        dataAdicao: DateTime.parse('2024-01-16'),
      ),
      Document(
        id: 'b2c3d4e5-f6a7-8901-2345-67890abcdef0',
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Exame de Sangue',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-01-15'),
        dataAdicao: DateTime.parse('2024-01-16'),
      ),
      Document(
        id: 'c3d4e5f6-a7b8-9012-3456-7890abcdef01',
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Receita pro Zoladex',
        tipo: 'Receita Médica',
        medico: 'Dra. Maria Santos',
        dataDocumento: DateTime.parse('2024-02-10'),
        dataAdicao: DateTime.parse('2024-02-11'),
      ),
      Document(
        id: 'd4e5f6a7-b8c9-0123-4567-890abcdef012',
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Tomografia do Abdômen',
        tipo: 'Exame de Imagem',
        medico: 'Dr. João Oliveira',
        dataDocumento: DateTime.parse('2024-03-05'),
        dataAdicao: DateTime.parse('2024-03-06'),
      ),
      Document(
        id: 'e5f6a7b8-c9d0-1234-5678-90abcdef0123',
        paciente: 'Daniel Ferreira',
        titulo: 'Eletrocardiograma',
        tipo: 'Exame Cardiológico',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-01-20'),
        dataAdicao: DateTime.parse('2024-01-21'),
      ),
      Document(
        id: 'f6a7b8c9-d0e1-2345-6789-0abcdef01234',
        paciente: 'Daniel Ferreira',
        titulo: 'Receita para Omeprazol',
        tipo: 'Receita Médica',
        medico: 'Dra. Ana Costa',
        dataDocumento: DateTime.parse('2024-02-15'),
        dataAdicao: DateTime.parse('2024-02-16'),
      ),
      Document(
        id: 'a7b8c9d0-e1f2-3456-7890-1bcdef012345',
        paciente: 'Daniel Ferreira',
        titulo: 'Resultado de Biópsia',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Paulo Mendes',
        dataDocumento: DateTime.parse('2024-03-10'),
        dataAdicao: DateTime.parse('2024-03-11'),
      ),
      Document(
        id: 'b8c9d0e1-f2a3-4567-8901-2cdef0123456',
        paciente: 'Jaqueline Souza',
        titulo: 'Consulta de Rotina',
        tipo: 'Consulta',
        medico: 'Dra. Maria Santos',
        dataDocumento: DateTime.parse('2024-01-25'),
        dataAdicao: DateTime.parse('2024-01-26'),
      ),
      Document(
        id: 'c9d0e1f2-a3b4-5678-9012-3def01234567',
        paciente: 'Jaqueline Souza',
        titulo: 'Exame de Urina',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-02-20'),
        dataAdicao: DateTime.parse('2024-02-21'),
      ),
      Document(
        id: 'd0e1f2a3-b4c5-6789-0123-4ef012345678',
        paciente: 'Jaqueline Souza',
        titulo: 'Ultrassom Renal',
        tipo: 'Exame de Imagem',
        medico: 'Dr. João Oliveira',
        dataDocumento: DateTime.parse('2024-03-15'),
        dataAdicao: DateTime.parse('2024-03-16'),
      ),
      Document(
        id: 'e1f2a3b4-c5d6-7890-1234-5f0123456789',
        paciente: 'Marcos Lima',
        titulo: 'Raio-x do Joelho',
        tipo: 'Exame de Imagem',
        medico: 'Dr. Paulo Mendes',
        dataDocumento: DateTime.parse('2024-01-30'),
        dataAdicao: DateTime.parse('2024-01-31'),
      ),
      Document(
        id: 'f2a3b4c5-d6e7-8901-2345-60123456789a',
        paciente: 'Marcos Lima',
        titulo: 'Receita para Dipirona',
        tipo: 'Receita Médica',
        medico: 'Dra. Ana Costa',
        dataDocumento: DateTime.parse('2024-02-25'),
        dataAdicao: DateTime.parse('2024-02-26'),
      ),
      Document(
        id: 'a3b4c5d6-e7f8-9012-3456-7123456789ab',
        paciente: 'Marcos Lima',
        titulo: 'Tomografia Craniana',
        tipo: 'Exame de Imagem',
        medico: 'Dr. João Oliveira',
        dataDocumento: DateTime.parse('2024-03-20'),
        dataAdicao: DateTime.parse('2024-03-21'),
      ),
    ];
    return Result.success(documentos);
  }

  // UPDATE

  // DELETE
}
