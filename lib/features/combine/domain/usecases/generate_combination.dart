import 'package:equatable/equatable.dart';
import 'package:vezu/features/combine/domain/entities/combination_plan.dart';
import 'package:vezu/features/combine/domain/entities/combination_preference.dart';
import 'package:vezu/features/combine/domain/repositories/combination_repository.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class GenerateCombinationUseCase {
  const GenerateCombinationUseCase(this._repository);

  final CombinationRepository _repository;

  Future<CombinationPlan> call(GenerateCombinationParams params) {
    return _repository.generateCombination(
      preference: params.preference,
      wardrobeItems: params.wardrobeItems,
      languageCode: params.languageCode,
    );
  }
}

class GenerateCombinationParams extends Equatable {
  const GenerateCombinationParams({
    required this.preference,
    required this.wardrobeItems,
    this.languageCode = 'en',
  });

  final CombinationPreference preference;
  final List<ClothingItem> wardrobeItems;
  final String languageCode;

  @override
  List<Object?> get props => [preference, wardrobeItems, languageCode];
}

