import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vezu/features/wardrobe/data/models/clothing_metadata_model.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class ClothingItemModel extends ClothingItem {
  const ClothingItemModel({
    required super.id,
    required super.imageUrl,
    required super.category,
    required super.type,
    required super.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory ClothingItemModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    final metadataModel = ClothingMetadataModel.fromMap(data);

    return ClothingItemModel(
      id: snapshot.id,
      imageUrl: (data['imageUrl'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      metadata: metadataModel,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  final DateTime? createdAt;
  final DateTime? updatedAt;
}

