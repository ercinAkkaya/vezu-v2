part of "wardrobe_cubit.dart";

class WardrobeState extends Equatable {
  const WardrobeState({
    this.isProcessing = false,
    this.isAnalyzing = false,
    this.selectedImagePath,
    this.shouldShowPreview = false,
    this.permissionDenied = false,
    this.snackbarMessageKey,
    this.wardrobeItems = const [],
  });

  final bool isProcessing;
  final bool isAnalyzing;
  final String? selectedImagePath;
  final bool shouldShowPreview;
  final bool permissionDenied;
  final String? snackbarMessageKey;
  final List<String> wardrobeItems;

  WardrobeState copyWith({
    bool? isProcessing,
    bool? isAnalyzing,
    String? selectedImagePath,
    bool? shouldShowPreview,
    bool? permissionDenied,
    String? snackbarMessageKey,
    bool resetSnackbar = false,
    List<String>? wardrobeItems,
  }) {
    return WardrobeState(
      isProcessing: isProcessing ?? this.isProcessing,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      shouldShowPreview: shouldShowPreview ?? this.shouldShowPreview,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      snackbarMessageKey: resetSnackbar
          ? null
          : snackbarMessageKey ?? this.snackbarMessageKey,
      wardrobeItems: wardrobeItems ?? this.wardrobeItems,
    );
  }

  @override
  List<Object?> get props => [
    isProcessing,
    isAnalyzing,
    selectedImagePath,
    shouldShowPreview,
    permissionDenied,
    snackbarMessageKey,
    wardrobeItems,
  ];
}
