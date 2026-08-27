import 'package:image_picker/image_picker.dart';

/// Helpers for picking files to upload.
class ImageUploadHelper {
  ImageUploadHelper._();

  static Future<XFile?> pickImage(
    ImagePicker picker,
    ImageSource source,
  ) async {
    return picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
  }

  static bool isImageFile(XFile file) {
    final mime = file.mimeType?.toLowerCase() ?? '';
    if (mime.startsWith('image/')) return true;

    final path = file.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.heic') ||
        path.endsWith('.heif');
  }
}
