import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:multiple_result/multiple_result.dart';

/// Model representing a scanned/picked document file
class DocumentFile {
  final String path;
  final String name;
  final int size;
  final String? mimeType;

  DocumentFile({
    required this.path,
    required this.name,
    required this.size,
    this.mimeType,
  });
}

class DocumentUploadRepository {
  final FlutterDocScanner _docScanner;

  DocumentUploadRepository({FlutterDocScanner? docScanner})
    : _docScanner = docScanner ?? FlutterDocScanner();

  /// Scans a document using the device camera and document scanner
  /// Returns a [DocumentFile] with the path to the scanned PDF file
  Future<Result<DocumentFile, Exception>> scanDocument({
    int maxPages = 40,
  }) async {
    try {
      // Use the scanner to get a PDF document
      final scannedDocument = await _docScanner.getScannedDocumentAsPdf(
        page: maxPages,
      );

      if (scannedDocument == null) {
        return Result.error(
          Exception('Nenhum documento foi escaneado. Tente novamente.'),
        );
      }

      // The scannedDocument can be either a Map or a String depending on method used
      String filePath;
      if (scannedDocument is Map) {
        filePath = scannedDocument['pdfUri'] ?? scannedDocument.toString();
      } else {
        filePath = scannedDocument.toString();
      }

      final File file = File(filePath);

      // Note: Some scanner packages store files in temporary locations
      // that may take time to become available. Let's add a brief check with retry.
      bool fileExists = await file.exists();
      if (!fileExists) {
        // Wait a moment and retry once
        await Future.delayed(const Duration(milliseconds: 500));
        fileExists = await file.exists();
      }

      if (!fileExists) {
        return Result.error(
          Exception(
            'Arquivo escaneado não foi encontrado no caminho: $filePath',
          ),
        );
      }

      final stat = await file.stat();

      final documentFile = DocumentFile(
        path: filePath,
        name:
            'documento_escaneado_${DateTime.now().millisecondsSinceEpoch}.pdf',
        size: stat.size,
        mimeType: 'application/pdf',
      );

      return Result.success(documentFile);
    } on PlatformException catch (e) {
      return Result.error(
        Exception(
          'Erro ao escanear documento: ${e.message ?? 'Erro desconhecido'}',
        ),
      );
    } catch (e) {
      return Result.error(
        Exception('Erro inesperado ao escanear documento: $e'),
      );
    }
  }

  /// Uploads a document from the device's file system using file picker
  /// Returns a [DocumentFile] with the path to the selected file
  Future<Result<DocumentFile, Exception>> uploadDocumentFromFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions ?? ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        return Result.error(Exception('Nenhum arquivo foi selecionado.'));
      }

      final file = result.files.first;

      if (file.path == null) {
        return Result.error(Exception('Caminho do arquivo não disponível.'));
      }

      // Verify file exists
      final fileObj = File(file.path!);
      if (!await fileObj.exists()) {
        return Result.error(
          Exception('Arquivo selecionado não foi encontrado.'),
        );
      }

      final documentFile = DocumentFile(
        path: file.path!,
        name: file.name,
        size: file.size,
        mimeType: _getMimeTypeFromExtension(file.extension),
      );

      return Result.success(documentFile);
    } catch (e) {
      return Result.error(Exception('Erro ao selecionar arquivo: $e'));
    }
  }

  /// Helper method to determine MIME type from file extension
  String? _getMimeTypeFromExtension(String? extension) {
    if (extension == null) return null;

    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
