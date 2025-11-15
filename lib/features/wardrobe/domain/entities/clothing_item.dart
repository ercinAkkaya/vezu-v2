import 'package:equatable/equatable.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_metadata.dart';

class ClothingItem extends Equatable {
  const ClothingItem({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.type,
    required this.metadata,
  });

  final String id;
  final String imageUrl;
  final String category;
  final String type;
  final ClothingMetadata metadata;

  @override
  List<Object?> get props => [id, imageUrl, category, type, metadata];
}

