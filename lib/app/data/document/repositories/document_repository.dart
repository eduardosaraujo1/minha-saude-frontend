import 'package:minha_saude_frontend/app/data/document/models/document.dart';
import 'package:multiple_result/multiple_result.dart';

class DocumentRepository {
  // CREATE

  // READ
  // TODO: quando a escala do app justificar, implementar paginação via scroll infinito
  Future<Result<List<Document>, Exception>> listDocuments() async {
    // Simulação de leitura de documentos
    await Future.delayed(const Duration(seconds: 1));
    final List<Document> documentos = [
      Document(
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Exame de Sangue',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-01-15'),
        dataAdicao: DateTime.parse('2024-01-16'),
      ),
      Document(
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Exame de Sangue',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-01-15'),
        dataAdicao: DateTime.parse('2024-01-16'),
      ),
      Document(
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Receita pro Zoladex',
        tipo: 'Receita Médica',
        medico: 'Dra. Maria Santos',
        dataDocumento: DateTime.parse('2024-02-10'),
        dataAdicao: DateTime.parse('2024-02-11'),
      ),
      Document(
        paciente: 'Ana Beatriz Rocha',
        titulo: 'Tomografia do Abdômen',
        tipo: 'Exame de Imagem',
        medico: 'Dr. João Oliveira',
        dataDocumento: DateTime.parse('2024-03-05'),
        dataAdicao: DateTime.parse('2024-03-06'),
      ),
      Document(
        paciente: 'Daniel Ferreira',
        titulo: 'Eletrocardiograma',
        tipo: 'Exame Cardiológico',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-01-20'),
        dataAdicao: DateTime.parse('2024-01-21'),
      ),
      Document(
        paciente: 'Daniel Ferreira',
        titulo: 'Receita para Omeprazol',
        tipo: 'Receita Médica',
        medico: 'Dra. Ana Costa',
        dataDocumento: DateTime.parse('2024-02-15'),
        dataAdicao: DateTime.parse('2024-02-16'),
      ),
      Document(
        paciente: 'Daniel Ferreira',
        titulo: 'Resultado de Biópsia',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Paulo Mendes',
        dataDocumento: DateTime.parse('2024-03-10'),
        dataAdicao: DateTime.parse('2024-03-11'),
      ),
      Document(
        paciente: 'Jaqueline Souza',
        titulo: 'Consulta de Rotina',
        tipo: 'Consulta',
        medico: 'Dra. Maria Santos',
        dataDocumento: DateTime.parse('2024-01-25'),
        dataAdicao: DateTime.parse('2024-01-26'),
      ),
      Document(
        paciente: 'Jaqueline Souza',
        titulo: 'Exame de Urina',
        tipo: 'Exame Laboratorial',
        medico: 'Dr. Carlos Silva',
        dataDocumento: DateTime.parse('2024-02-20'),
        dataAdicao: DateTime.parse('2024-02-21'),
      ),
      Document(
        paciente: 'Jaqueline Souza',
        titulo: 'Ultrassom Renal',
        tipo: 'Exame de Imagem',
        medico: 'Dr. João Oliveira',
        dataDocumento: DateTime.parse('2024-03-15'),
        dataAdicao: DateTime.parse('2024-03-16'),
      ),
      Document(
        paciente: 'Marcos Lima',
        titulo: 'Raio-x do Joelho',
        tipo: 'Exame de Imagem',
        medico: 'Dr. Paulo Mendes',
        dataDocumento: DateTime.parse('2024-01-30'),
        dataAdicao: DateTime.parse('2024-01-31'),
      ),
      Document(
        paciente: 'Marcos Lima',
        titulo: 'Receita para Dipirona',
        tipo: 'Receita Médica',
        medico: 'Dra. Ana Costa',
        dataDocumento: DateTime.parse('2024-02-25'),
        dataAdicao: DateTime.parse('2024-02-26'),
      ),
      Document(
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
