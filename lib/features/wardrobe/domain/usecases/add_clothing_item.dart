import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/repositories/wardrobe_repository.dart';

class AddClothingItemUseCase {
  const AddClothingItemUseCase(this._repository);

  final WardrobeRepository _repository;

  Future<ClothingItem> call(AddClothingItemParams params) {
    return _repository.addClothingItem(
      imageFile: params.imageFile,
      uid: params.uid,
      category: params.category,
      type: params.type,
    );
  }
}

class AddClothingItemParams extends Equatable {
  const AddClothingItemParams({
    required this.imageFile,
    required this.uid,
    required this.category,
    required this.type,
  });

  final File imageFile;
  final String uid;
  final String category;
  final String type;

  @override
  List<Object?> get props => [imageFile.path, uid, category, type];
}

