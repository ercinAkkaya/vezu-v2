import 'package:equatable/equatable.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/repositories/wardrobe_repository.dart';

class WatchWardrobeItemsUseCase {
  const WatchWardrobeItemsUseCase(this._repository);

  final WardrobeRepository _repository;

  Stream<List<ClothingItem>> call(WatchWardrobeItemsParams params) {
    return _repository.watchWardrobeItems(uid: params.uid);
  }
}

class WatchWardrobeItemsParams extends Equatable {
  const WatchWardrobeItemsParams({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

