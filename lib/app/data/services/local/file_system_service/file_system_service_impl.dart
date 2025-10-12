import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:path_provider/path_provider.dart';

import 'file_system_service.dart';

class FileSystemServiceImpl implements FileSystemService {
  static const String documentsPathPrefix = "documents/";

  final _log = Logger("FileSystemServiceImpl");

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
  Future<Result<void, Exception>> clearDocuments() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final documentsDir = Directory('${cacheDir.path}/$documentsPathPrefix');

      if (await documentsDir.exists()) {
        await documentsDir.delete(recursive: true);
      }

      return const Success(null);
    } on Exception catch (e) {
      return Error(e);
    } catch (e) {
      return Error(Exception('Failed to clear documents: $e'));
    }
  }

  @override
  Future<Result<File?, Exception>> getDocument(String uuid) async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final filePath = '${cacheDir.path}/$documentsPathPrefix$uuid.pdf';
      final file = File(filePath);

      if (!await file.exists()) {
        _log.warning('Document with UUID $uuid not found');
        return Success(null);
      }

      return Success(file);
    } on Exception catch (e) {
      return Error(e);
    } catch (e) {
      return Error(Exception('Failed to get document: $e'));
    }
  }

  @override
  Future<Result<File, Exception>> storeDocument(
    String uuid,
    Uint8List bytes,
  ) async {
    try {
      final sanitizedUuid = uuid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      final cacheDir = await getApplicationCacheDirectory();
      final documentsDir = Directory('${cacheDir.path}/$documentsPathPrefix');

      // Ensure the documents directory exists
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final filePath = '${documentsDir.path}$sanitizedUuid.pdf';
      final oldFilePath = '${documentsDir.path}${sanitizedUuid}_old.pdf';
      final file = File(filePath);
      final oldFile = File(oldFilePath);

      // If there's already an _old file, delete it
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      // If the target file exists, rename it to _old
      bool hadExistingFile = false;
      if (await file.exists()) {
        await file.rename(oldFilePath);
        hadExistingFile = true;
      }

      try {
        // Write the new file
        await file.writeAsBytes(bytes);

        // If successful and we had an old file, delete it
        if (hadExistingFile && await oldFile.exists()) {
          await oldFile.delete();
        }

        return Success(file);
      } catch (e) {
        // If writing failed and we renamed an old file, restore it
        if (hadExistingFile && await oldFile.exists()) {
          await oldFile.rename(filePath);
        }
        rethrow;
      }
    } on Exception catch (e) {
      return Error(e);
    } catch (e) {
      return Error(Exception('Failed to store document: $e'));
    }
  }

  @override
  Future<File> writeTempFile(Uint8List bytes, String filepath) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$filepath');
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }
}
