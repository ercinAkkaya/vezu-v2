import 'package:equatable/equatable.dart';

class ClothingMetadata extends Equatable {
  const ClothingMetadata({
    required this.genderFit,
    required this.colorPalette,
    required this.colorTone,
    required this.fabric,
    required this.pattern,
    required this.style,
    required this.season,
    required this.usage,
    required this.cut,
    required this.length,
    required this.layer,
    required this.ageGroup,
    required this.details,
  });

  final String genderFit;
  final List<String> colorPalette;
  final String colorTone;
  final String fabric;
  final String pattern;
  final String style;
  final String season;
  final List<String> usage;
  final String cut;
  final String length;
  final String layer;
  final String ageGroup;
  final List<String> details;

  @override
  List<Object?> get props => [
        genderFit,
        colorPalette,
        colorTone,
        fabric,
        pattern,
        style,
        season,
        usage,
        cut,
        length,
        layer,
        ageGroup,
        details,
      ];
}

