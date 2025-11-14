import 'package:collection/collection.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class WardrobePayloadBuilder {
  const WardrobePayloadBuilder._();

  static List<Map<String, dynamic>> build(List<ClothingItem> items) {
    return items
        .map(
          (item) => _WardrobeDescriptor.fromItem(item).toMap(),
        )
        .toList(growable: false);
  }
}

class _WardrobeDescriptor {
  _WardrobeDescriptor({
    required this.id,
    required this.category,
    required this.type,
    required this.slot,
    required this.primaryColor,
    required this.palette,
    required this.layer,
    required this.style,
    required this.season,
    required this.usage,
    required this.cut,
    required this.length,
    required this.keywords,
  });

  factory _WardrobeDescriptor.fromItem(ClothingItem item) {
    final metadata = item.metadata;
    final palette = metadata.colorPalette.take(2).map((e) => e.toLowerCase()).toList();

    final keywordSet = <String>{
      metadata.genderFit,
      metadata.pattern,
      metadata.fabric,
      metadata.ageGroup,
      ...metadata.details.take(2),
      ...metadata.usage.take(2),
    }..removeWhere((value) => value.trim().isEmpty || value == 'unknown');

    return _WardrobeDescriptor(
      id: item.id,
      category: item.category,
      type: item.type,
      slot: _resolveSlot(item.category, metadata.layer, item.type),
      primaryColor: palette.firstOrNull ?? 'neutral',
      palette: palette,
      layer: metadata.layer,
      style: metadata.style,
      season: metadata.season,
      usage: metadata.usage.take(2).toList(),
      cut: metadata.cut,
      length: metadata.length,
      keywords: keywordSet.toList(growable: false),
    );
  }

  final String id;
  final String category;
  final String type;
  final String slot;
  final String primaryColor;
  final List<String> palette;
  final String layer;
  final String style;
  final String season;
  final List<String> usage;
  final String cut;
  final String length;
  final List<String> keywords;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'slot': slot,
      'primary_color': primaryColor,
      'palette': palette,
      'layer': layer,
      'style': style,
      'season': season,
      'usage': usage,
      'cut': cut,
      'length': length,
      'keywords': keywords,
    };
  }
}

String _resolveSlot(String category, String layer, String type) {
  final normalizedCategory = category.toLowerCase();
  final normalizedType = type.toLowerCase();
  final normalizedLayer = layer.toLowerCase();

  if (normalizedType.contains('dress')) {
    return 'dress';
  }
  if (normalizedCategory.contains('outer') ||
      normalizedLayer == 'outer' ||
      normalizedType.contains('coat') ||
      normalizedType.contains('jacket') ||
      normalizedType.contains('hoodie')) {
    return 'outer';
  }
  if (normalizedCategory.contains('top') ||
      normalizedLayer == 'base' && !normalizedType.contains('pants')) {
    return 'top';
  }
  if (normalizedCategory.contains('bottom') ||
      normalizedType.contains('pants') ||
      normalizedType.contains('skirt') ||
      normalizedType.contains('shorts')) {
    return 'bottom';
  }
  if (normalizedCategory.contains('shoe') ||
      normalizedType.contains('boot') ||
      normalizedType.contains('sneaker')) {
    return 'shoes';
  }
  if (normalizedCategory.contains('bag')) {
    return 'bag';
  }
  return 'accent';
}

