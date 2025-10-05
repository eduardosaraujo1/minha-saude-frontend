import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';

import 'file_system_service.dart';

class FileSystemServiceImpl implements FileSystemService {
  static const String path_prefix = "documents/";

  @override
  Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return File(result.files.single.path!);
  }

  @override
  Future<Result<void, Exception>> clearDocuments() {
    // TODO: implement clearDocuments
    throw UnimplementedError();
  }

  @override
  Future<Result<File, Exception>> getDocument(String uuid) {
    // TODO: implement getDocument
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> storeDocument(String uuid) {
    // TODO: implement storeDocument
    // getApplicationDocumentsDirectory()
    throw UnimplementedError();
  }
}
