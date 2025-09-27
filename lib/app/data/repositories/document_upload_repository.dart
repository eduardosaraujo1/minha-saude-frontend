import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:minha_saude_frontend/app/data/services/document_scanner.dart';
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
  final DocumentScanner _docScanner;

  DocumentUploadRepository(this._docScanner);

  /// Scans a document using the device camera and document scanner
  /// Returns a [File] with the path to the scanned PDF file
  Future<Result<File, Exception>> scanDocument() async {
    try {
      // Use the scanner to get a PDF document
      final file = await _docScanner.scanPdf();

      if (file == null) {
        return Result.error(
          Exception('Nenhum documento foi escaneado. Tente novamente.'),
        );
      }

      return Result.success(file);
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
