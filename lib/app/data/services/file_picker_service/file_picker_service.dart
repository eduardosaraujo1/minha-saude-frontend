import 'dart:io';

abstract class FilePickerService {
  /// Opens a file picker dialog and allows the user to select a PDF file.
  Future<File?> getPdfFile();
}
