import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vezu/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:vezu/features/wardrobe/data/models/clothing_metadata_model.dart';
import 'package:vezu/features/wardrobe/data/models/clothing_item_model.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/errors/wardrobe_failure.dart';
import 'package:vezu/features/wardrobe/domain/repositories/wardrobe_repository.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  WardrobeRepositoryImpl({
    required WardrobeRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final WardrobeRemoteDataSource _remoteDataSource;

  @override
  Future<ClothingItem> addClothingItem({
    required File imageFile,
    required String uid,
    required String category,
    required String type,
  }) async {
    if (!imageFile.existsSync()) {
      throw WardrobeFailure('Selected image file not found.');
    }

    try {
      final result = await _remoteDataSource.uploadAndAnalyzeClothing(
        imageFile: imageFile,
        uid: uid,
        category: category,
        type: type,
      );

      final metadataModel = ClothingMetadataModel.fromMap(result.metadataMap);

      return ClothingItem(
        id: result.itemId,
        imageUrl: result.imageUrl,
        category: category,
        type: type,
        metadata: metadataModel,
      );
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WardrobeFailure(error.message ?? 'Firebase error.'),
        stackTrace,
      );
    } on Exception catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WardrobeFailure(error.toString()),
        stackTrace,
      );
    }
  }

  @override
  Stream<List<ClothingItem>> watchWardrobeItems({required String uid}) {
    try {
      return _remoteDataSource.watchWardrobeItems(uid).map(
            (items) => items
                .map<ClothingItem>(
                  (model) => ClothingItem(
                    id: model.id,
                    imageUrl: model.imageUrl,
                    category: model.category,
                    type: model.type,
                    metadata: model.metadata,
                  ),
                )
                .toList(growable: false),
          );
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WardrobeFailure(error.message ?? 'Firebase error.'),
        stackTrace,
      );
    } on Exception catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WardrobeFailure(error.toString()),
        stackTrace,
      );
    }
  }

  @override
  Future<void> deleteClothingItem({
    required String uid,
    required String itemId,
    required String imageUrl,
  }) async {
    try {
      await _remoteDataSource.deleteClothingItem(
        uid: uid,
        itemId: itemId,
        imageUrl: imageUrl,
      );
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WardrobeFailure(error.message ?? 'Firebase error.'),
        stackTrace,
      );
    } on Exception catch (error, stackTrace) {
      Error.throwWithStackTrace(
        WardrobeFailure(error.toString()),
        stackTrace,
      );
    }
  }
}

