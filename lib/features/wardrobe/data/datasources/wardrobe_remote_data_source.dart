import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vezu/core/base/base_firebase_storage_service.dart';
import 'package:vezu/core/base/base_gpt_service.dart';

import 'package:vezu/features/wardrobe/data/models/clothing_item_model.dart';

abstract class WardrobeRemoteDataSource {
  Future<WardrobeRemoteResult> uploadAndAnalyzeClothing({
    required File imageFile,
    required String uid,
    required String category,
    required String type,
    String languageCode = 'en',
  });
  Stream<List<ClothingItemModel>> watchWardrobeItems(String uid);
  Future<void> deleteClothingItem({
    required String uid,
    required String itemId,
    required String imageUrl,
  });
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  WardrobeRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required BaseFirebaseStorageService storageService,
    required BaseGptService gptService,
  })  : _firestore = firestore,
        _storageService = storageService,
        _gptService = gptService;

  final FirebaseFirestore _firestore;
  final BaseFirebaseStorageService _storageService;
  final BaseGptService _gptService;

  @override
  Future<WardrobeRemoteResult> uploadAndAnalyzeClothing({
    required File imageFile,
    required String uid,
    required String category,
    required String type,
    String languageCode = 'en',
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('clothes_metadata')
        .doc();

    final itemId = docRef.id;
    final storagePath = 'users/$uid/clothes/$itemId.jpg';

    final imageUrl = await _storageService.uploadFile(
      file: imageFile,
      destinationPath: storagePath,
    );

    final metadataMap = await _gptService.analyzeClothingItem(
      imageUrl: imageUrl,
      category: category,
      type: type,
      languageCode: languageCode,
    );

    final sanitizedMetadata = Map<String, dynamic>.from(metadataMap)
      ..['category'] = category
      ..['type'] = type
      ..['imageUrl'] = imageUrl;

    await docRef.set({
      ...sanitizedMetadata,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(uid).update({
      'totalClothes': FieldValue.increment(1),
    }).catchError((_) async {
      await _firestore.collection('users').doc(uid).set(
        {'totalClothes': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    });

    sanitizedMetadata.remove('imageUrl');

    return WardrobeRemoteResult(
      itemId: itemId,
      imageUrl: imageUrl,
      metadataMap: sanitizedMetadata,
    );
  }

  @override
  Stream<List<ClothingItemModel>> watchWardrobeItems(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('clothes_metadata')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ClothingItemModel.fromDocument)
              .toList(growable: false),
        );
  }

  @override
  Future<void> deleteClothingItem({
    required String uid,
    required String itemId,
    required String imageUrl,
  }) async {
    await _storageService.deleteFile(imageUrl);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('clothes_metadata')
        .doc(itemId)
        .delete();
    await _firestore.collection('users').doc(uid).update({
      'totalClothes': FieldValue.increment(-1),
    }).catchError((_) async {
      await _firestore.collection('users').doc(uid).set(
        {'totalClothes': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
    });
  }
}

class WardrobeRemoteResult {
  WardrobeRemoteResult({
    required this.itemId,
    required this.imageUrl,
    required this.metadataMap,
  });

  final String itemId;
  final String imageUrl;
  final Map<String, dynamic> metadataMap;
}

