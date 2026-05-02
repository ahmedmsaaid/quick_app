import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickSingleImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw ImagePickerException('Failed to pick image: $e');
    }
  }

  Future<List<File>> pickMultipleImages({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
    int? limit,
  }) async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFiles.isEmpty) return [];

      var files = pickedFiles.map((xFile) => File(xFile.path)).toList();

      if (limit != null && files.length > limit) {
        files = files.sublist(0, limit);
      }

      return files;
    } catch (e) {
      throw ImagePickerException('Failed to pick images: $e');
    }
  }

  Future<File?> pickImageFromCamera({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
  }) async {
    return pickSingleImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }
}

class ImagePickerException implements Exception {
  final String message;

  ImagePickerException(this.message);

  @override
  String toString() => message;
}
