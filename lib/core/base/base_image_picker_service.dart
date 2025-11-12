import 'dart:io';

abstract class BaseImagePickerService {
  Future<File?> pickImageFromGallery();
  Future<File?> pickImageFromCamera();
}
