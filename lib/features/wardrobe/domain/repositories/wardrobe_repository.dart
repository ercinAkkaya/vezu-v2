import 'dart:io';

import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

abstract class WardrobeRepository {
  Future<ClothingItem> addClothingItem({
    required File imageFile,
    required String uid,
    required String category,
    required String type,
  });
  Stream<List<ClothingItem>> watchWardrobeItems({required String uid});
  Future<void> deleteClothingItem({
    required String uid,
    required String itemId,
    required String imageUrl,
  });
}

