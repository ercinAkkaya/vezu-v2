import 'dart:convert';

import 'package:vezu/core/base/base_gpt_service.dart';
import 'package:vezu/features/combine/data/utils/combination_prompt_builder.dart';
import 'package:vezu/features/combine/data/utils/wardrobe_payload_builder.dart';
import 'package:vezu/features/combine/domain/entities/combination_plan.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';
import 'package:vezu/features/combine/domain/repositories/combination_repository.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class CombinationRepositoryImpl implements CombinationRepository {
  CombinationRepositoryImpl({required BaseGptService gptService})
      : _gptService = gptService;

  final BaseGptService _gptService;

  @override
  Future<CombinationPlan> generateCombination({
    required CombinationPreference preference,
    required List<ClothingItem> wardrobeItems,
  }) async {
    final wardrobePayload = WardrobePayloadBuilder.build(wardrobeItems);

    final prompt = CombinationPromptBuilder.buildPrompt(
      preference: preference,
      wardrobePayload: wardrobePayload,
    );

    final responseText = await _gptService.generateCombination(
      prompt: prompt,
      wardrobeItems: wardrobePayload,
    );

    final decoded = jsonDecode(responseText);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid combination plan response.');
    }

    return _mapPlan(decoded);
  }

  CombinationPlan _mapPlan(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = itemsJson is List
        ? itemsJson
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => CombinationPlanItem(
                wardrobeItemId: item['wardrobe_item_id']?.toString() ?? '',
                slot: item['slot']?.toString() ?? 'accent',
                nickname: item['nickname']?.toString() ?? 'Unnamed piece',
                pairingReason: item['pairing_reason']?.toString() ?? '',
                stylingTip: item['styling_tip']?.toString() ?? '',
                accent: item['accent']?.toString(),
              ),
            )
            .where((item) => item.wardrobeItemId.isNotEmpty)
            .toList()
        : <CombinationPlanItem>[];

    if (items.isEmpty) {
      throw Exception('Combination plan did not reference wardrobe items.');
    }

    return CombinationPlan(
      theme: json['theme']?.toString() ?? 'Yeni Kombin',
      mood: json['mood']?.toString() ?? 'modern',
      summary: json['summary']?.toString() ?? '',
      stylingNotes: _mapStringList(json['styling_notes']),
      accessories: _mapStringList(json['accessories']),
      warnings: _mapStringList(json['warnings']),
      items: items,
    );
  }

  List<String> _mapStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().map((e) => e.trim()).toList();
    }
    return const [];
  }
}

