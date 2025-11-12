import 'dart:io';

abstract class BaseFirebaseStorageService {
  Future<String> uploadFile({
    required File file,
    required String destinationPath,
  });
  Future<void> deleteFile(String fileUrl);
}
