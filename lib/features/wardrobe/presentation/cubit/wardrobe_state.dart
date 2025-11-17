part of "wardrobe_cubit.dart";

class WardrobeState extends Equatable {
  const WardrobeState({
    this.isProcessing = false,
    this.isAnalyzing = false,
    this.isLoadingWardrobe = false,
    this.selectedImagePath,
    this.shouldShowPreview = false,
    this.permissionDenied = false,
    this.snackbarMessageKey,
    this.analysisErrorKey,
    this.selectedCategoryKey,
    this.selectedTypeKey,
    this.lastAddedItem,
    this.activeFilterKey,
    this.searchQuery = '',
    this.wardrobeItems = const <ClothingItem>[],
    this.visibleItems = const <ClothingItem>[],
    this.shouldShowPaywall = false,
  });

  final bool isProcessing;
  final bool isAnalyzing;
  final bool isLoadingWardrobe;
  final String? selectedImagePath;
  final bool shouldShowPreview;
  final bool permissionDenied;
  final String? snackbarMessageKey;
  final String? analysisErrorKey;
  final String? selectedCategoryKey;
  final String? selectedTypeKey;
  final ClothingItem? lastAddedItem;
  final String? activeFilterKey;
  final String searchQuery;
  final List<ClothingItem> wardrobeItems;
  final List<ClothingItem> visibleItems;
  final bool shouldShowPaywall;

  WardrobeState copyWith({
    bool? isProcessing,
    bool? isAnalyzing,
    bool? isLoadingWardrobe,
    String? selectedImagePath,
    bool clearSelectedImage = false,
    bool? shouldShowPreview,
    bool? permissionDenied,
    String? snackbarMessageKey,
    bool resetSnackbar = false,
    String? analysisErrorKey,
    bool resetAnalysisError = false,
    String? selectedCategoryKey,
    bool clearSelectedCategory = false,
    String? selectedTypeKey,
    bool clearSelectedType = false,
    ClothingItem? lastAddedItem,
    bool resetLastAdded = false,
    String? activeFilterKey,
    bool clearActiveFilter = false,
    String? searchQuery,
    List<ClothingItem>? wardrobeItems,
    List<ClothingItem>? visibleItems,
    bool? shouldShowPaywall,
    bool resetPaywall = false,
  }) {
    return WardrobeState(
      isProcessing: isProcessing ?? this.isProcessing,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isLoadingWardrobe: isLoadingWardrobe ?? this.isLoadingWardrobe,
      selectedImagePath: clearSelectedImage
          ? null
          : selectedImagePath ?? this.selectedImagePath,
      shouldShowPreview: shouldShowPreview ?? this.shouldShowPreview,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      snackbarMessageKey:
          resetSnackbar ? null : snackbarMessageKey ?? this.snackbarMessageKey,
      analysisErrorKey: resetAnalysisError
          ? null
          : analysisErrorKey ?? this.analysisErrorKey,
      selectedCategoryKey: clearSelectedCategory
          ? null
          : selectedCategoryKey ?? this.selectedCategoryKey,
      selectedTypeKey:
          clearSelectedType ? null : selectedTypeKey ?? this.selectedTypeKey,
      lastAddedItem:
          resetLastAdded ? null : lastAddedItem ?? this.lastAddedItem,
      activeFilterKey:
          clearActiveFilter ? null : activeFilterKey ?? this.activeFilterKey,
      searchQuery: searchQuery ?? this.searchQuery,
      wardrobeItems: wardrobeItems ?? this.wardrobeItems,
      visibleItems: visibleItems ?? this.visibleItems,
      shouldShowPaywall: resetPaywall ? false : (shouldShowPaywall ?? this.shouldShowPaywall),
    );
  }

  @override
  List<Object?> get props => [
        isProcessing,
        isAnalyzing,
    isLoadingWardrobe,
        selectedImagePath,
        shouldShowPreview,
        permissionDenied,
        snackbarMessageKey,
        analysisErrorKey,
        selectedCategoryKey,
        selectedTypeKey,
        lastAddedItem,
    activeFilterKey,
    searchQuery,
        wardrobeItems,
    visibleItems,
    shouldShowPaywall,
  ];
}
