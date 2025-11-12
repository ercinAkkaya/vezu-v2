import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:vezu/core/base/base_image_picker_service.dart';

class ImagePickerService implements BaseImagePickerService {
  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<File?> pickImageFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    return File(image.path);
  }

  @override
  Future<File?> pickImageFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) {
      return null;
    }

    return File(image.path);
  }
}
