// lib/utils/file_picker_helper.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FilePickerHelper {
  /// Opens a file picker and returns a PDF file, or null if cancelled.
  static Future<File?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final path = result.files.single.path;
    if (path == null) return null;

    return File(path);
  }
}
