import 'dart:io';

import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';

class FakeServerFileStorage {
  FakeServerFileStorage();

  void initialize() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    _documentsPath = '${appDocDir.path}/server/documents';
  }

  // Each document is stored through path_provider's application documents directory
  // In this file path + document_uuid.pdf
  String? _documentsPath;

  String get documentsPath {
    if (_documentsPath == null) {
      throw Exception(
        'FakeServerFileStorage not initialized. Call initialize() first.',
      );
    }
    return _documentsPath!;
  }

  set documentsPath(String? value) {
    _documentsPath = value;
  }

  Future<Result<void, Exception>> put(String uuid, File file) async {
    try {
      final serverFile = File('$documentsPath/$uuid.pdf');
      await serverFile.create(recursive: true);
      await file.copy(serverFile.path);
      return Success(null);
    } catch (e) {
      return Error(Exception('Error saving document file: $e'));
    }
  }

  Future<Result<void, Exception>> delete(String uuid) async {
    try {
      final file = File('$documentsPath/$uuid.pdf');
      if (await file.exists()) {
        await file.delete();
        return Success(null);
      } else {
        return Error(
          Exception('Document file not found on fake server storage'),
        );
      }
    } catch (e) {
      return Error(Exception('Error deleting document file: $e'));
    }
  }

  Future<Result<File, Exception>> get(String uuid) async {
    try {
      final file = File('$documentsPath/$uuid.pdf');
      if (await file.exists()) {
        return Success(file);
      } else {
        return Error(
          Exception('Document file not found on fake server storage'),
        );
      }
    } catch (e) {
      return Error(Exception('Error accessing document file: $e'));
    }
  }
}
