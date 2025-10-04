import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/share.dart';
import 'package:minha_saude_frontend/app/domain/models/document/document.dart';
import 'package:multiple_result/multiple_result.dart';

class ShareRepository extends ChangeNotifier {
  final List<Share> _shares = [];
  final List<Document> _sharedDocuments = [
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
  ];

  // CREATE
  // In the future, include list of Documents
  Future<Result<void, Exception>> createShare(List<Share> shares) async {
    try {
      // Append shares to the _share array
      for (var newShare in shares) {
        _shares.add(newShare);
      }

      return Success(null);
    } catch (e) {
      return Error(Exception('Failed to create share'));
    } finally {
      notifyListeners();
    }
  }

  // READ
  Future<Result<Share?, Exception>> getShareById(String id) async {
    // Simulate fetching share from a data source
    await Future.delayed(const Duration(seconds: 1));
    try {
      final share = _shares.firstWhere((doc) => doc.id == id);
      return Result.success(share);
    } catch (e) {
      return Result.error(
        Exception('Compartilhamento não encontrado. Tente fechar a página.'),
      );
    }
  }

  Future<Result<List<Share>, Exception>> listShares() async {
    try {
      // Simulate fetching shares from a data source
      return Success(_shares);
    } catch (e) {
      return Error(Exception('Failed to fetch shares'));
    }
  }

  Future<Result<List<Document>, Exception>> listSharedDocuments(
    String shareId,
  ) async {
    try {
      // Simulate fetching documents from a data source
      // Note that shared documents is not a constant value usually, it's just mocked that way.
      return Success(_sharedDocuments);
    } catch (e) {
      return Error(Exception('Failed to fetch shared documents'));
    }
  }

  // UPDATE

  // DELETE
}
