part of 'combine_cubit.dart';

class CombineState extends Equatable {
  const CombineState({
    this.isWardrobeLoading = true,
    this.wardrobeItems = const [],
    this.preference = const CombinationPreference(
      occasion: '',
      dressCode: '',
      weather: '',
      vibe: '',
      includeAccessories: true,
      allowBoldColors: false,
    ),
    this.plan,
    this.isGenerating = false,
    this.errorMessage,
  });

  final bool isWardrobeLoading;
  final List<ClothingItem> wardrobeItems;
  final CombinationPreference preference;
  final CombinationPlan? plan;
  final bool isGenerating;
  final String? errorMessage;

  CombineState copyWith({
    bool? isWardrobeLoading,
    List<ClothingItem>? wardrobeItems,
    CombinationPreference? preference,
    CombinationPlan? plan,
    bool? isGenerating,
    String? errorMessage,
    bool resetError = false,
  }) {
    return CombineState(
      isWardrobeLoading: isWardrobeLoading ?? this.isWardrobeLoading,
      wardrobeItems: wardrobeItems ?? this.wardrobeItems,
      preference: preference ?? this.preference,
      plan: plan ?? this.plan,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isWardrobeLoading,
        wardrobeItems,
        preference,
        plan,
        isGenerating,
        errorMessage,
      ];
}

