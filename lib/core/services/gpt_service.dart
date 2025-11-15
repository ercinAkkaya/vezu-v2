import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  }) async {
    final apiKey = AppConstants.gptApiKey;
    if (apiKey.isEmpty) {
      debugPrint('[GptService] GPT API key is empty.');
      throw Exception('GPT API key is not configured.');
    }

    debugPrint(
      '[GptService] Using GPT API key with length ${apiKey.length}.',
    );

    final prompt = '''
You are a vision model and MUST analyze the clothing item in the provided image strictly following these rules.

Input parameters:
- Image URL: $imageUrl (treat as public, do NOT refuse to access)
- category: $category  // do not change this value
- type: $type          // do not change this value

Output requirements:
- Respond with a single JSON object. Do not include explanations or markdown fences.
- The JSON object MUST contain exactly these keys (all lowercase, snake_case):
  {
    "category": "",                // string, use provided category value
    "type": "",                    // string, use provided type value
    "gender_fit": "",              // string: one of ["male", "female", "unisex", "kids", "baby"] or "unknown"
    "color_palette": [],           // array of 1-3 strings with basic color names (e.g., ["navy", "white"]); use lowercase
    "color_tone": "",              // string: one of ["warm", "cool", "neutral"]
    "fabric": "",                  // string: e.g., "cotton", "denim", "wool", or "unknown"
    "pattern": "",                 // string: e.g., "solid", "striped", "plaid", "print", "graphic", "patterned", "unknown"
    "style": "",                   // string: e.g., "casual", "formal", "sporty", "business", "streetwear", "evening", "unknown"
    "season": "",                  // string: one of ["spring", "summer", "fall", "winter", "all_season"]
    "usage": [],                   // array of 1-3 strings describing occasions (e.g., ["daily wear", "office"]); use lowercase
    "cut": "",                     // string describing cut, e.g., "slim", "relaxed", "tapered", "fit-and-flare", "unknown"
    "length": "",                  // string describing length (e.g., "full", "mid", "mini", "knee", "ankle", "cropped", "unknown")
    "layer": "",                   // string: one of ["base", "mid", "outer"]
    "age_group": "",               // string: one of ["adult", "teen", "child", "toddler", "baby", "unknown"]
    "details": []                  // array of strings for notable details (e.g., ["cargo pockets", "pleats"]); 0-5 items
  }

Behavior rules:
1. Category and type MUST exactly match the provided values.
2. If uncertain about any field, fill with a sensible default ("unknown" or [] as appropriate) rather than omitting it.
3. NEVER mention inability to access the image; assume it is accessible.
4. Do NOT output markdown fences like ```json.
5. Ensure the output is valid JSON (keys in double quotes, strings in double quotes, no trailing commas).

Return ONLY the JSON object.
''';

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
}

