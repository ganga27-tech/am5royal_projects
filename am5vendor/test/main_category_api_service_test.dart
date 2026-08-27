import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:am5vendor/core/utils/image_upload_helper.dart';

void main() {
  group('ImageUploadHelper', () {
    test('isImageFile detects common image extensions', () {
      expect(ImageUploadHelper.isImageFile(XFile('photo.jpg')), isTrue);
      expect(ImageUploadHelper.isImageFile(XFile('photo.png')), isTrue);
      expect(ImageUploadHelper.isImageFile(XFile('document.pdf')), isFalse);
    });
  });
}
