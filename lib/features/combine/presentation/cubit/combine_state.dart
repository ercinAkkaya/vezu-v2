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
      customPrompt: '',
    ),
    this.plan,
    this.isGenerating = false,
    this.isSavingPlan = false,
    this.hasSavedPlan = false,
    this.errorMessage,
    this.shouldShowPaywall = false,
  });

  final bool isWardrobeLoading;
  final List<ClothingItem> wardrobeItems;
  final CombinationPreference preference;
  final CombinationPlan? plan;
  final bool isGenerating;
  final bool isSavingPlan;
  final bool hasSavedPlan;
  final String? errorMessage;
  final bool shouldShowPaywall;

  CombineState copyWith({
    bool? isWardrobeLoading,
    List<ClothingItem>? wardrobeItems,
    CombinationPreference? preference,
    CombinationPlan? plan,
    bool? isGenerating,
    bool? isSavingPlan,
    bool? hasSavedPlan,
    String? errorMessage,
    bool resetError = false,
    bool? shouldShowPaywall,
    bool resetPaywall = false,
  }) {
    return CombineState(
      isWardrobeLoading: isWardrobeLoading ?? this.isWardrobeLoading,
      wardrobeItems: wardrobeItems ?? this.wardrobeItems,
      preference: preference ?? this.preference,
      plan: plan ?? this.plan,
      isGenerating: isGenerating ?? this.isGenerating,
      isSavingPlan: isSavingPlan ?? this.isSavingPlan,
      hasSavedPlan: hasSavedPlan ?? this.hasSavedPlan,
      errorMessage: resetError ? null : (errorMessage ?? this.errorMessage),
      shouldShowPaywall: resetPaywall ? false : (shouldShowPaywall ?? this.shouldShowPaywall),
    );
  }

  @override
  List<Object?> get props => [
    isWardrobeLoading,
    wardrobeItems,
    preference,
    plan,
    isGenerating,
    isSavingPlan,
    hasSavedPlan,
    errorMessage,
    shouldShowPaywall,
  ];
}
