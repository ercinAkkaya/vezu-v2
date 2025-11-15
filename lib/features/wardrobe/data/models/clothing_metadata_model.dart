import 'package:vezu/features/wardrobe/domain/entities/clothing_metadata.dart';

class ClothingMetadataModel extends ClothingMetadata {
  const ClothingMetadataModel({
    required super.genderFit,
    required super.colorPalette,
    required super.colorTone,
    required super.fabric,
    required super.pattern,
    required super.style,
    required super.season,
    required super.usage,
    required super.cut,
    required super.length,
    required super.layer,
    required super.ageGroup,
    required super.details,
  });

  factory ClothingMetadataModel.fromMap(Map<String, dynamic> map) {
    return ClothingMetadataModel(
      genderFit: _asString(map['gender_fit']),
      colorPalette: _asStringList(map['color_palette']),
      colorTone: _asString(map['color_tone']),
      fabric: _asString(map['fabric']),
      pattern: _asString(map['pattern']),
      style: _asString(map['style']),
      season: _asString(map['season']),
      usage: _asStringList(map['usage']),
      cut: _asString(map['cut']),
      length: _asString(map['length']),
      layer: _asString(map['layer']),
      ageGroup: _asString(map['age_group']),
      details: _asStringList(map['details']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gender_fit': genderFit,
      'color_palette': colorPalette,
      'color_tone': colorTone,
      'fabric': fabric,
      'pattern': pattern,
      'style': style,
      'season': season,
      'usage': usage,
      'cut': cut,
      'length': length,
      'layer': layer,
      'age_group': ageGroup,
      'details': details,
    };
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static List<String> _asStringList(dynamic value) {
    if (value == null) {
      return const [];
    }
    if (value is List) {
      return value
          .where((element) => element != null)
          .map((element) => element.toString())
          .toList(growable: false);
    }
    return [value.toString()];
  }
}

