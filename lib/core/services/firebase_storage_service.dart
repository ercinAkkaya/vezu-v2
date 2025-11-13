import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:vezu/core/base/base_firebase_storage_service.dart';

class FirebaseStorageService implements BaseFirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadFile({
    required File file,
    required String destinationPath,
  }) async {
    final ref = _storage.ref(destinationPath);
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final uploadTask = await ref.putFile(file, metadata);
    if (uploadTask.state != TaskState.success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        message: 'Upload failed for $destinationPath',
      );
    }
    return ref.getDownloadURL();
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    final ref = _storage.refFromURL(fileUrl);
    await ref.delete();
  }
}

