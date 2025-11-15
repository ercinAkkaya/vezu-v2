import 'package:vezu/features/combine/domain/entities/combination_plan.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

abstract class CombinationRepository {
  Future<CombinationPlan> generateCombination({
    required CombinationPreference preference,
    required List<ClothingItem> wardrobeItems,
  });
}

