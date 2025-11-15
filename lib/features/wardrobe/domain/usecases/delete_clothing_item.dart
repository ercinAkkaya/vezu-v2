import 'package:equatable/equatable.dart';
import 'package:vezu/features/wardrobe/domain/repositories/wardrobe_repository.dart';

class DeleteClothingItemUseCase {
  const DeleteClothingItemUseCase(this._repository);

  final WardrobeRepository _repository;

  Future<void> call(DeleteClothingItemParams params) {
    return _repository.deleteClothingItem(
      uid: params.uid,
      itemId: params.itemId,
      imageUrl: params.imageUrl,
    );
  }
}

class DeleteClothingItemParams extends Equatable {
  const DeleteClothingItemParams({
    required this.uid,
    required this.itemId,
    required this.imageUrl,
  });

  final String uid;
  final String itemId;
  final String imageUrl;

  @override
  List<Object?> get props => [uid, itemId, imageUrl];
}

