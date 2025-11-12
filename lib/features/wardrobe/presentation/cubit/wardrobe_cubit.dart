import "package:bloc/bloc.dart";
import "package:equatable/equatable.dart";
import "package:vezu/core/base/base_image_picker_service.dart";
import "package:vezu/core/base/base_permission_service.dart";

part "wardrobe_state.dart";

class WardrobeCubit extends Cubit<WardrobeState> {
  WardrobeCubit({
    required BaseImagePickerService imagePickerService,
    required BasePermissionService permissionService,
  }) : _imagePickerService = imagePickerService,
       _permissionService = permissionService,
       super(const WardrobeState());

  final BaseImagePickerService _imagePickerService;
  final BasePermissionService _permissionService;

  Future<void> pickItem() async {
    if (state.isProcessing) return;
    emit(state.copyWith(isProcessing: true, resetSnackbar: true));

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
  }

  Future<void> startAnalysis() async {
    if (state.selectedImagePath == null || state.isAnalyzing) return;
    emit(state.copyWith(isAnalyzing: true, resetSnackbar: true));
    await Future<void>.delayed(const Duration(seconds: 2));
    emit(state.copyWith(isAnalyzing: false, snackbarMessageKey: 'comingSoon'));
  }

  void clearSelectedImage() {
    emit(state.copyWith(selectedImagePath: null, shouldShowPreview: false));
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

  Future<void> openSettings() {
    return _permissionService.openAppSettings();
  }
}
