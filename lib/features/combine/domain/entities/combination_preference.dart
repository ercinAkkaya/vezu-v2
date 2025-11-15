import 'package:equatable/equatable.dart';

class CombinationPreference extends Equatable {
  const CombinationPreference({
    required this.occasion,
    required this.dressCode,
    required this.weather,
    required this.vibe,
    required this.includeAccessories,
    required this.allowBoldColors,
    this.customPrompt = '',
    this.weatherTone,
  });

  final String occasion;
  final String dressCode;
  final String weather;
  final String vibe;
  final bool includeAccessories;
  final bool allowBoldColors;
  final String customPrompt;
  final String? weatherTone;

  CombinationPreference copyWith({
    String? occasion,
    String? dressCode,
    String? weather,
    String? vibe,
    bool? includeAccessories,
    bool? allowBoldColors,
    String? customPrompt,
    String? weatherTone,
  }) {
    return CombinationPreference(
      occasion: occasion ?? this.occasion,
      dressCode: dressCode ?? this.dressCode,
      weather: weather ?? this.weather,
      vibe: vibe ?? this.vibe,
      includeAccessories: includeAccessories ?? this.includeAccessories,
      allowBoldColors: allowBoldColors ?? this.allowBoldColors,
      customPrompt: customPrompt ?? this.customPrompt,
      weatherTone: weatherTone ?? this.weatherTone,
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
      'custom_prompt': customPrompt,
      'weather_tone': weatherTone,
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
    customPrompt,
    weatherTone,
  ];
}
