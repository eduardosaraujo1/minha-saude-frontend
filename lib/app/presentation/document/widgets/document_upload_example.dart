import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_upload_repository.dart';

/// Example widget showing how to use the DocumentUploadRepository
class DocumentUploadExample extends StatefulWidget {
  const DocumentUploadExample({super.key});

  @override
  State<DocumentUploadExample> createState() => _DocumentUploadExampleState();
}

class _DocumentUploadExampleState extends State<DocumentUploadExample> {
  final DocumentUploadRepository _uploadRepository =
      GetIt.I<DocumentUploadRepository>();

  String _status = 'Nenhuma ação realizada';
  bool _isLoading = false;

  Future<void> _scanDocument() async {
    setState(() {
      _isLoading = true;
      _status = 'Escaneando documento...';
    });

    try {
      final result = await _uploadRepository.scanDocument(maxPages: 4);

      if (result.isSuccess()) {
        final documentFile = result.getOrThrow();
        setState(() {
          _status =
              'Documento escaneado com sucesso!\n'
              'Nome: ${documentFile.name}\n'
              'Tamanho: ${(documentFile.size / 1024).toStringAsFixed(1)} KB\n'
              'Caminho: ${documentFile.path}';
        });
      } else {
        final error = result.tryGetError()!;
        setState(() {
          _status = 'Erro ao escanear: ${error.toString()}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Erro inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDocument() async {
    setState(() {
      _isLoading = true;
      _status = 'Selecionando arquivo...';
    });

    try {
      final result = await _uploadRepository.uploadDocumentFromFile(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result.isSuccess()) {
        final documentFile = result.getOrThrow();
        setState(() {
          _status =
              'Arquivo selecionado com sucesso!\n'
              'Nome: ${documentFile.name}\n'
              'Tamanho: ${(documentFile.size / 1024).toStringAsFixed(1)} KB\n'
              'Tipo: ${documentFile.mimeType ?? 'Desconhecido'}\n'
              'Caminho: ${documentFile.path}';
        });
      } else {
        final error = result.tryGetError()!;
        setState(() {
          _status = 'Erro ao selecionar arquivo: ${error.toString()}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Erro inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de Upload de Documentos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _scanDocument,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt),
              label: const Text('Escanear Documento'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickDocument,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload),
              label: const Text('Selecionar Arquivo'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
