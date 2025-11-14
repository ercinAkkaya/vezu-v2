import 'package:equatable/equatable.dart';

class CombinationPlan extends Equatable {
  const CombinationPlan({
    required this.theme,
    required this.mood,
    required this.summary,
    required this.stylingNotes,
    required this.accessories,
    required this.warnings,
    required this.items,
  });

  final String theme;
  final String mood;
  final String summary;
  final List<String> stylingNotes;
  final List<String> accessories;
  final List<String> warnings;
  final List<CombinationPlanItem> items;

  @override
  List<Object?> get props => [
        theme,
        mood,
        summary,
        stylingNotes,
        accessories,
        warnings,
        items,
      ];
}

class CombinationPlanItem extends Equatable {
  const CombinationPlanItem({
    required this.wardrobeItemId,
    required this.slot,
    required this.nickname,
    required this.pairingReason,
    required this.stylingTip,
    this.accent,
  });

  final String wardrobeItemId;
  final String slot;
  final String nickname;
  final String pairingReason;
  final String stylingTip;
  final String? accent;

  @override
  List<Object?> get props => [
        wardrobeItemId,
        slot,
        nickname,
        pairingReason,
        stylingTip,
        accent,
      ];
}

