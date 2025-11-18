import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vezu/core/base/base_gpt_service.dart';
import 'package:vezu/core/utils/app_constants.dart';

class GptService implements BaseGptService {
  GptService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _endpoint = 'https://api.openai.com/v1/responses';
  static const _model = 'gpt-4o';

  @override
  Future<Map<String, dynamic>> analyzeClothingItem({
    required String imageUrl,
    required String category,
    required String type,
    String languageCode = 'en',
  }) async {
    final apiKey = AppConstants.gptApiKey;
    if (apiKey.isEmpty) {
      debugPrint('[GptService] GPT API key is empty.');
      throw Exception('GPT API key is not configured.');
    }

    debugPrint(
      '[GptService] Using GPT API key with length ${apiKey.length}.',
    );

    // Load localized prompt
    final prompt = await _getClothingAnalysisPrompt(
      languageCode: languageCode,
      imageUrl: imageUrl,
      category: category,
      type: type,
    );

    final payload = {
      'model': _model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text': prompt,
            },
            {
              'type': 'input_image',
              'image_url': imageUrl,
            },
          ],
        },
      ],
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      debugPrint(
        '[GptService] Response status: ${response.statusCode}, data: ${data ?? 'null'}',
      );
      if (data == null) {
        throw Exception('Empty response from GPT service.');
      }

      final text = _extractTextContent(data);
      if (text == null || text.isEmpty) {
        throw Exception('Unable to parse GPT response content.');
      }

      final sanitizedText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final decoded = jsonDecode(sanitizedText);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('GPT response is not a valid JSON object.');
      }

      return decoded;
    } on DioException catch (error, stackTrace) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      debugPrint(
        '[GptService] DioException status: $statusCode, data: $responseData, message: ${error.message}',
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<String> generateCombination({
    required String prompt,
    required List<Map<String, dynamic>> wardrobeItems,
  }) async {
    final apiKey = AppConstants.gptApiKey;
    if (apiKey.isEmpty) {
      throw Exception('GPT API key is not configured.');
    }

    final combinedPrompt = '''
$prompt
''';

    final payload = {
      'model': _model,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text': combinedPrompt,
            },
          ],
        },
      ],
      'temperature': 0.7,
    };

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _endpoint,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Empty response from GPT service.');
      }

      final text = _extractTextContent(data);
      if (text == null || text.isEmpty) {
        throw Exception('Unable to parse GPT response content.');
      }

      return text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
    } on DioException catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  String? _extractTextContent(Map<String, dynamic> data) {
    final outputText = data['output_text'];
    if (outputText is String && outputText.isNotEmpty) {
      return outputText;
    }

    final output = data['output'];
    if (output is List) {
      for (final item in output) {
        if (item is Map<String, dynamic>) {
          final content = item['content'];
          if (content is List) {
            for (final part in content) {
              if (part is Map<String, dynamic>) {
                final text = part['text'];
                if (text is String && text.isNotEmpty) {
                  return text;
                }
              }
            }
          }
        }
      }
    }

    return null;
  }

  /// Load localized clothing analysis prompt
  Future<String> _getClothingAnalysisPrompt({
    required String languageCode,
    required String imageUrl,
    required String category,
    required String type,
  }) async {
    final translations = await _loadTranslations(languageCode);
    final promptTemplate = translations['gptClothingAnalysisPrompt'] as String? ?? '';
    
    // Replace placeholders
    return promptTemplate
        .replaceAll('{imageUrl}', imageUrl)
        .replaceAll('{category}', category)
        .replaceAll('{type}', type);
  }

  /// Load translations from JSON file
  Future<Map<String, dynamic>> _loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[GptService] Error loading translations for $languageCode: $e');
      // Fallback to English
      final jsonString = await rootBundle.loadString(
        'assets/translations/en.json',
      );
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
  }
}

