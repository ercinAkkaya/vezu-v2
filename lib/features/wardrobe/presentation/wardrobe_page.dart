import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/services/image_picker_service.dart';
import 'package:vezu/core/services/permission_service.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/wardrobe/domain/usecases/add_clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/usecases/watch_wardrobe_items.dart';
import 'package:vezu/features/wardrobe/presentation/cubit/wardrobe_cubit.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_header.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_item_grid.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_preview_sheet.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_top_bar.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_upload_sheet.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WardrobeCubit(
        imagePickerService: ImagePickerService(),
        permissionService: PermissionService(),
        addClothingItemUseCase: context.read<AddClothingItemUseCase>(),
        watchWardrobeItemsUseCase: context.read<WatchWardrobeItemsUseCase>(),
      ),
      child: const _WardrobeView(),
    );
  }
}

class _WardrobeView extends StatefulWidget {
  const _WardrobeView();

  @override
  State<_WardrobeView> createState() => _WardrobeViewState();
}

class _WardrobeViewState extends State<_WardrobeView> {
  final TextEditingController _searchController = TextEditingController();
  String? _previousSelectedImagePath;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthCubit>().state.user?.id;
      context.read<WardrobeCubit>().initialize(uid);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WardrobeCubit, WardrobeState>(
      listenWhen: (previous, current) =>
          previous.permissionDenied != current.permissionDenied ||
          previous.snackbarMessageKey != current.snackbarMessageKey ||
          previous.shouldShowPreview != current.shouldShowPreview ||
          previous.selectedImagePath != current.selectedImagePath,
      listener: _handleStateUpdates,
      builder: (context, state) {
        final uid = context.watch<AuthCubit>().state.user?.id;
        context.read<WardrobeCubit>().initialize(uid);

        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: state.searchQuery.length),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth * 0.06;
                final verticalPadding = constraints.maxHeight * 0.02;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding.clamp(16, 32),
                    vertical: verticalPadding.clamp(12, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WardrobeTopBar(
                        itemCount: state.visibleItems.length,
                        isProcessing: state.isProcessing,
                        onAddPressed: () => _showAddItemSheet(context),
                        searchController: _searchController,
                      ),
                      const SizedBox(height: 16),
                      WardrobeHeader(
                        activeFilterKey: state.activeFilterKey,
                        onFilterChanged:
                            context.read<WardrobeCubit>().setCategoryFilter,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: WardrobeItemGrid(
                          visibleItems: state.visibleItems,
                          isLoading: state.isLoadingWardrobe,
                          searchQuery: state.searchQuery,
                          activeFilterKey: state.activeFilterKey,
                          isProcessing: state.isProcessing,
                          onAddPressed: () => _showAddItemSheet(context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleStateUpdates(BuildContext context, WardrobeState state) {
    final cubit = context.read<WardrobeCubit>();

    if (state.permissionDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('wardrobeAddPermissionDenied'.tr()),
          action: SnackBarAction(
            label: 'wardrobeAddOpenSettings'.tr(),
            onPressed: () => cubit.openSettings(),
          ),
        ),
      );
      cubit.clearPermissionDenied();
    }

    if (state.snackbarMessageKey != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.snackbarMessageKey!.tr())),
      );
      cubit.clearSnackbarMessage();
    }

    if (_previousSelectedImagePath != null && state.selectedImagePath == null) {
      Navigator.of(context).maybePop();
    }

    _previousSelectedImagePath = state.selectedImagePath;

    if (state.shouldShowPreview && state.selectedImagePath != null) {
      _showPreviewSheet(context);
      cubit.previewShown();
    }
  }

  void _showAddItemSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => WardrobeUploadSheet(
        onGalleryTap: () {
          Navigator.of(sheetContext).pop();
          context.read<WardrobeCubit>().pickItem();
        },
      ),
    );
  }

  void _showPreviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => WardrobePreviewSheet(
        onChangeImage: () {
          Navigator.of(sheetContext).pop();
          context.read<WardrobeCubit>().pickItem();
        },
        onClearImage: () {
          Navigator.of(sheetContext).pop();
          context.read<WardrobeCubit>().clearSelectedImage();
        },
        onAnalyze: () {
          final uid = context.read<AuthCubit>().state.user?.id;
          context.read<WardrobeCubit>().startAnalysis(uid: uid);
        },
      ),
    );
  }

  void _handleSearch() {
    context.read<WardrobeCubit>().updateSearchQuery(_searchController.text);
  }
}

