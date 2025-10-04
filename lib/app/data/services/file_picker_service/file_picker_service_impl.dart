import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'file_picker_service.dart';

class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<File?> getPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return File(result.files.single.path!);
  }
}
