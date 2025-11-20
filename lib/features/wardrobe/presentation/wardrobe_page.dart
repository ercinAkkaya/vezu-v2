import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/models/subscription_plan_limits.dart';
import 'package:vezu/core/navigation/app_router.dart';
import 'package:vezu/core/services/image_picker_service.dart';
import 'package:vezu/core/services/permission_service.dart';
import 'package:vezu/core/services/subscription_service.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vezu/features/wardrobe/domain/usecases/add_clothing_item.dart';
import 'package:vezu/features/wardrobe/domain/usecases/watch_wardrobe_items.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';
import 'package:vezu/features/wardrobe/presentation/cubit/wardrobe_cubit.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_header.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_item_grid.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_preview_sheet.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_top_bar.dart';
import 'package:vezu/features/wardrobe/presentation/widgets/wardrobe_upload_sheet.dart';

import 'package:vezu/features/wardrobe/domain/usecases/delete_clothing_item.dart';

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
        authCubit: context.read<AuthCubit>(),
        deleteClothingItemUseCase: context.read<DeleteClothingItemUseCase>(),
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
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthCubit>().state.user?.id;
      _lastUserId = uid;
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
          previous.selectedImagePath != current.selectedImagePath ||
          previous.shouldShowPaywall != current.shouldShowPaywall,
      listener: _handleStateUpdates,
      builder: (context, state) {
        // Check if user has logged out
        final currentUserId = context.watch<AuthCubit>().state.user?.id;
        if (_lastUserId != currentUserId) {
          _lastUserId = currentUserId;
          // User changed (logged out or switched account)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<WardrobeCubit>().initialize(currentUserId);
            }
          });
        }

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
                          onDeletePressed: (item) => _confirmDelete(context, item),
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

    if (state.shouldShowPaywall) {
      _showLimitExceededMessage(context, isClothes: true);
      // Snackbar gösterildikten sonra paywall'ı aç
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          Navigator.of(context).pushNamed(AppRoutes.subscription);
          cubit.clearPaywall();
        }
      });
    }
  }

  Future<void> _showLimitExceededMessage(BuildContext context, {required bool isClothes}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final subscriptionService = SubscriptionService.instance();
      final subscriptionInfo = await subscriptionService.getUserSubscriptionInfo(userId);
      final limits = subscriptionInfo['limits'] as SubscriptionPlanLimits;
      final currentCount = isClothes
          ? subscriptionInfo['totalClothes'] as int
          : subscriptionInfo['monthlyCombinationsUsed'] as int;
      final maxCount = isClothes
          ? limits.maxClothes
          : limits.maxCombinationsPerMonth;

      final message = isClothes
          ? 'Kıyafet ekleme limitinize ulaştınız ($currentCount/$maxCount). Daha fazla kıyafet eklemek için planınızı yükseltin.'
          : 'Aylık kombin limitinize ulaştınız ($currentCount/$maxCount). Daha fazla kombin oluşturmak için planınızı yükseltin.';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Yükselt',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.subscription);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda basit mesaj göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isClothes
                ? 'Kıyafet ekleme limitinize ulaştınız. Planınızı yükseltin.'
                : 'Aylık kombin limitinize ulaştınız. Planınızı yükseltin.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
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

  Future<void> _confirmDelete(BuildContext context, ClothingItem item) async {
    final theme = Theme.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('wardrobeDeleteTitle'.tr()),
        content: Text('wardrobeDeleteMessage'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('commonClose'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('wardrobeDeleteConfirm'.tr()),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      await context.read<WardrobeCubit>().deleteItem(item);
    }
  }

  void _showPreviewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<WardrobeCubit>(),
        child: WardrobePreviewSheet(
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
            context.read<WardrobeCubit>().startAnalysis(
              uid: uid,
              languageCode: context.locale.languageCode,
            );
          },
        ),
      ),
    );
  }

  void _handleSearch() {
    context.read<WardrobeCubit>().updateSearchQuery(_searchController.text);
  }
}

