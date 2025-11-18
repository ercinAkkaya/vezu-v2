import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';

class CombinationPromptBuilder {
  const CombinationPromptBuilder._();

  static Future<String> buildPrompt({
    required CombinationPreference preference,
    required List<Map<String, dynamic>> wardrobePayload,
    String languageCode = 'en',
  }) async {
    final translations = await _loadTranslations(languageCode);
    
    final preferenceJson = jsonEncode(preference.toMap());
    final wardrobeJson = jsonEncode(wardrobePayload);
    final customPrompt = preference.customPrompt.trim();
    
    // Get localized prompt parts
    final systemPrompt = translations['gptCombinationSystemPrompt'] as String? ?? '';
    final userBrief = (translations['gptCombinationUserBrief'] as String? ?? '')
        .replaceAll('{preferenceJson}', preferenceJson);
    final extraPromptTemplate = translations['gptCombinationUserExtraPrompt'] as String? ?? '';
    final customPromptSection = customPrompt.isEmpty
        ? ''
        : extraPromptTemplate.replaceAll('{customPrompt}', customPrompt);
    final wardrobeIndex = (translations['gptCombinationWardrobeIndex'] as String? ?? '')
        .replaceAll('{wardrobeJson}', wardrobeJson);
    final directive = translations['gptCombinationDirective'] as String? ?? '';
    final outputContract = translations['gptCombinationOutputContract'] as String? ?? '';
    final rules = translations['gptCombinationRules'] as String? ?? '';

    return '''
$systemPrompt
$userBrief$customPromptSection
$wardrobeIndex
$directive
$outputContract
$rules
''';
  }

  /// Load translations from JSON file
  static Future<Map<String, dynamic>> _loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[CombinationPromptBuilder] Error loading translations for $languageCode: $e');
      // Fallback to English
      final jsonString = await rootBundle.loadString(
        'assets/translations/en.json',
      );
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
  }
}
