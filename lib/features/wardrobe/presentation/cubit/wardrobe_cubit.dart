import "dart:async";
import "dart:io";

import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:vezu/core/base/base_image_picker_service.dart";
import "package:vezu/core/base/base_permission_service.dart";
import "package:vezu/core/services/subscription_service.dart";
import "package:vezu/features/auth/presentation/cubit/auth_cubit.dart";
import "package:vezu/features/wardrobe/domain/entities/clothing_item.dart";
import "package:vezu/features/wardrobe/domain/errors/wardrobe_failure.dart";
import "package:vezu/features/wardrobe/domain/usecases/add_clothing_item.dart";
import "package:vezu/features/wardrobe/domain/usecases/delete_clothing_item.dart";
import "package:vezu/features/wardrobe/domain/usecases/watch_wardrobe_items.dart";

part "wardrobe_state.dart";

class WardrobeCubit extends Cubit<WardrobeState> {
  WardrobeCubit({
    required BaseImagePickerService imagePickerService,
    required BasePermissionService permissionService,
    required AddClothingItemUseCase addClothingItemUseCase,
    required WatchWardrobeItemsUseCase watchWardrobeItemsUseCase,
    required AuthCubit authCubit,
    required DeleteClothingItemUseCase deleteClothingItemUseCase,
  })  : _imagePickerService = imagePickerService,
        _permissionService = permissionService,
        _addClothingItemUseCase = addClothingItemUseCase,
        _watchWardrobeItemsUseCase = watchWardrobeItemsUseCase,
        _deleteClothingItemUseCase = deleteClothingItemUseCase,
        _authCubit = authCubit,
        super(const WardrobeState());

  final BaseImagePickerService _imagePickerService;
  final BasePermissionService _permissionService;
  final AddClothingItemUseCase _addClothingItemUseCase;
  final WatchWardrobeItemsUseCase _watchWardrobeItemsUseCase;
  final DeleteClothingItemUseCase _deleteClothingItemUseCase;
  final AuthCubit _authCubit;

  StreamSubscription<List<ClothingItem>>? _wardrobeSubscription;
  String? _currentUserId;

  Future<void> deleteItem(ClothingItem item) async {
    final uid = _currentUserId;
    if (uid == null) {
      return;
    }
    try {
      await _deleteClothingItemUseCase(
        DeleteClothingItemParams(
          uid: uid,
          itemId: item.id,
          imageUrl: item.imageUrl,
        ),
      );
      _authCubit.decrementTotalClothes();
      final updatedItems = List<ClothingItem>.from(state.wardrobeItems)
        ..removeWhere((element) => element.id == item.id);
      final updatedVisible = List<ClothingItem>.from(state.visibleItems)
        ..removeWhere((element) => element.id == item.id);
      emit(
        state.copyWith(
          wardrobeItems: updatedItems,
          visibleItems: updatedVisible,
        ),
      );
    } on WardrobeFailure catch (error) {
      emit(
        state.copyWith(
          snackbarMessageKey: error.message,
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          snackbarMessageKey: error.toString(),
        ),
      );
    }
  }

  void initialize(String? uid) {
    if (uid == null || uid.isEmpty) {
      // User logged out - cleanup
      _currentUserId = null;
      _wardrobeSubscription?.cancel();
      _wardrobeSubscription = null;
      emit(
        state.copyWith(
          isLoadingWardrobe: false,
          clearActiveFilter: true,
          searchQuery: '',
          wardrobeItems: const <ClothingItem>[],
          visibleItems: const <ClothingItem>[],
        ),
      );
      return;
    }
    if (_currentUserId == uid) {
      return;
    }
    _currentUserId = uid;
    _wardrobeSubscription?.cancel();
    emit(
      state.copyWith(
        isLoadingWardrobe: true,
        clearActiveFilter: true,
        searchQuery: '',
        wardrobeItems: const <ClothingItem>[],
        visibleItems: const <ClothingItem>[],
      ),
    );

    _wardrobeSubscription = _watchWardrobeItemsUseCase(
      WatchWardrobeItemsParams(uid: uid),
    ).listen(
      (items) {
        final filtered = _applyFilters(
          items: items,
          categoryKey: state.activeFilterKey,
          searchQuery: state.searchQuery,
        );
        emit(
          state.copyWith(
            isLoadingWardrobe: false,
            wardrobeItems: items,
            visibleItems: filtered,
            resetSnackbar: true,
          ),
        );
      },
      onError: (error, stackTrace) {
        emit(
          state.copyWith(
            isLoadingWardrobe: false,
            snackbarMessageKey: 'wardrobeLoadError',
          ),
        );
      },
    );
  }

  void setCategoryFilter(String? categoryKey) {
    final filtered = _applyFilters(
      items: state.wardrobeItems,
      categoryKey: categoryKey,
      searchQuery: state.searchQuery,
    );
    emit(
      state.copyWith(
        activeFilterKey: categoryKey,
        clearActiveFilter: categoryKey == null,
        visibleItems: filtered,
      ),
    );
  }

  void updateSearchQuery(String query) {
    final filtered = _applyFilters(
      items: state.wardrobeItems,
      categoryKey: state.activeFilterKey,
      searchQuery: query,
    );
    emit(
      state.copyWith(
        searchQuery: query,
        visibleItems: filtered,
      ),
    );
  }

  Future<void> pickItem() async {
    if (state.isProcessing) return;
    emit(
      state.copyWith(
        isProcessing: true,
        resetSnackbar: true,
        resetAnalysisError: true,
        resetLastAdded: true,
      ),
    );

    final granted = await _permissionService.requestPhotos();
    if (!granted) {
      emit(
        state.copyWith(
          isProcessing: false,
          permissionDenied: true,
          resetSnackbar: true,
        ),
      );
      return;
    }

    final file = await _imagePickerService.pickImageFromGallery();
    emit(state.copyWith(isProcessing: false));

    if (file == null) {
      emit(
        state.copyWith(
          snackbarMessageKey: 'wardrobeAddCancelled',
          shouldShowPreview: false,
        ),
      );
      return;
    }

    emit(state.copyWith(selectedImagePath: file.path, shouldShowPreview: true));
    emit(
      state.copyWith(
        clearSelectedCategory: true,
        clearSelectedType: true,
      ),
    );
  }

  void selectCategory(String? categoryKey) {
    emit(
      state.copyWith(
        selectedCategoryKey: categoryKey,
        clearSelectedCategory: categoryKey == null,
        clearSelectedType:
            categoryKey == null || categoryKey != state.selectedCategoryKey,
        resetAnalysisError: true,
        resetSnackbar: true,
      ),
    );
  }

  void selectType(String? typeKey) {
    emit(
      state.copyWith(
        selectedTypeKey: typeKey,
        clearSelectedType: typeKey == null,
        resetAnalysisError: true,
        resetSnackbar: true,
      ),
    );
  }

  Future<void> startAnalysis({required String? uid, String languageCode = 'en'}) async {
    if (state.selectedImagePath == null || state.isAnalyzing) return;

    if (uid == null || uid.isEmpty) {
      emit(
        state.copyWith(
          analysisErrorKey: 'wardrobeAnalyzeNoUser',
          resetSnackbar: true,
        ),
      );
      return;
    }

    final category = state.selectedCategoryKey;
    final type = state.selectedTypeKey;

    if (category == null || type == null) {
      emit(
        state.copyWith(
          analysisErrorKey: 'wardrobeAnalyzeMissingSelection',
          resetSnackbar: true,
        ),
      );
      return;
    }

    // Limit kontrolü yap
    final subscriptionService = SubscriptionService.instance();
    final currentClothesCount = state.wardrobeItems.length;
    final canUpload = await subscriptionService.canUploadClothes(
      userId: uid,
      currentClothesCount: currentClothesCount,
    );

    if (!canUpload) {
      emit(
        state.copyWith(
          isAnalyzing: false,
          shouldShowPaywall: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isAnalyzing: true,
        resetSnackbar: true,
        resetAnalysisError: true,
        resetPaywall: true,
      ),
    );

    try {
      final file = File(state.selectedImagePath!);
      final result = await _addClothingItemUseCase(
        AddClothingItemParams(
          imageFile: file,
          uid: uid,
          category: category,
          type: type,
          languageCode: languageCode,
        ),
      );

      emit(
        state.copyWith(
          isAnalyzing: false,
          snackbarMessageKey: 'wardrobeAnalyzeSuccess',
          clearSelectedImage: true,
          shouldShowPreview: false,
          lastAddedItem: result,
          clearSelectedCategory: true,
          clearSelectedType: true,
        ),
      );
      _authCubit.incrementTotalClothes();
    } on WardrobeFailure {
      emit(
        state.copyWith(
          isAnalyzing: false,
          analysisErrorKey: 'wardrobeAnalyzeError',
          snackbarMessageKey: 'wardrobeAnalyzeError',
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          isAnalyzing: false,
          analysisErrorKey: 'wardrobeAnalyzeError',
          snackbarMessageKey: 'wardrobeAnalyzeError',
        ),
      );
    }
  }

  void clearAnalysisError() {
    emit(state.copyWith(resetAnalysisError: true));
  }

  void clearSelectedImage() {
    emit(
      state.copyWith(
        clearSelectedImage: true,
        shouldShowPreview: false,
        clearSelectedCategory: true,
        clearSelectedType: true,
      ),
    );
  }

  void previewShown() {
    emit(state.copyWith(shouldShowPreview: false));
  }

  void clearPermissionDenied() {
    emit(state.copyWith(permissionDenied: false));
  }

  void clearSnackbarMessage() {
    emit(state.copyWith(resetSnackbar: true));
  }

  void clearPaywall() {
    emit(state.copyWith(resetPaywall: true));
  }

  Future<void> openSettings() {
    return _permissionService.openAppSettings();
  }

  List<ClothingItem> _applyFilters({
    required List<ClothingItem> items,
    String? categoryKey,
    String? searchQuery,
  }) {
    final query = (searchQuery ?? '').trim().toLowerCase();

    return items.where((item) {
      final matchesCategory =
          categoryKey == null || item.category == categoryKey;

      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final searchable = <String>[
        item.type,
        item.metadata.genderFit,
        item.metadata.colorTone,
        item.metadata.fabric,
        item.metadata.pattern,
        item.metadata.style,
        item.metadata.season,
        item.metadata.cut,
        item.metadata.length,
        item.metadata.layer,
        item.metadata.ageGroup,
        ...item.metadata.colorPalette,
        ...item.metadata.usage,
        ...item.metadata.details,
      ]
          .where((element) => element.isNotEmpty)
          .join(' ')
          .toLowerCase();

      return searchable.contains(query);
    }).toList(growable: false);
  }

  @override
  Future<void> close() {
    _wardrobeSubscription?.cancel();
    return super.close();
  }
}
