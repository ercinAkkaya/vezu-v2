import 'package:equatable/equatable.dart';

class CombinationPreference extends Equatable {
  const CombinationPreference({
    required this.occasion,
    required this.dressCode,
    required this.weather,
    required this.vibe,
    required this.includeAccessories,
    required this.allowBoldColors,
  });

  final String occasion;
  final String dressCode;
  final String weather;
  final String vibe;
  final bool includeAccessories;
  final bool allowBoldColors;

  CombinationPreference copyWith({
    String? occasion,
    String? dressCode,
    String? weather,
    String? vibe,
    bool? includeAccessories,
    bool? allowBoldColors,
  }) {
    return CombinationPreference(
      occasion: occasion ?? this.occasion,
      dressCode: dressCode ?? this.dressCode,
      weather: weather ?? this.weather,
      vibe: vibe ?? this.vibe,
      includeAccessories: includeAccessories ?? this.includeAccessories,
      allowBoldColors: allowBoldColors ?? this.allowBoldColors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'occasion': occasion,
      'dress_code': dressCode,
      'weather': weather,
      'vibe': vibe,
      'include_accessories': includeAccessories,
      'allow_bold_colors': allowBoldColors,
    };
  }

  @override
  List<Object?> get props => [
        occasion,
        dressCode,
        weather,
        vibe,
        includeAccessories,
        allowBoldColors,
      ];
}

