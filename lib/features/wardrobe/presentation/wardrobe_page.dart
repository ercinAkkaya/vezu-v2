import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/components/outlined_button.dart';
import 'package:vezu/core/components/primary_filled_button.dart';
import 'package:vezu/core/services/image_picker_service.dart';
import 'package:vezu/core/services/permission_service.dart';

import 'cubit/wardrobe_cubit.dart';

class WardrobePage extends StatelessWidget {
  const WardrobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WardrobeCubit(
        imagePickerService: ImagePickerService(),
        permissionService: PermissionService(),
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
  @override
  Widget build(BuildContext context) {
    final categories = <String>[
      'tabAll'.tr(),
      'tabTops'.tr(),
      'tabBottoms'.tr(),
      'tabShoes'.tr(),
      'tabAccessories'.tr(),
    ];

    return BlocConsumer<WardrobeCubit, WardrobeState>(
      listenWhen: (previous, current) =>
          previous.permissionDenied != current.permissionDenied ||
          previous.snackbarMessageKey != current.snackbarMessageKey ||
          previous.shouldShowPreview != current.shouldShowPreview,
      listener: (context, state) {
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

        if (state.shouldShowPreview && state.selectedImagePath != null) {
          _showPreviewSheet(context, state);
          cubit.previewShown();
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'wardrobeTitle'.tr(),
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'wardrobeItemsCount'.tr(namedArgs: {'count': '0'}),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryFilledButton(
                                onPressed: () {},
                                label: 'createCombination'.tr(),
                                icon: const Icon(Icons.auto_fix_high_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SecondaryOutlinedButton(
                                onPressed: state.isProcessing
                                    ? null
                                    : () => _showAddItemSheet(context),
                                label: 'wardrobeAddItem'.tr(),
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'searchHint'.tr(),
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) => FilterChip(
                              label: Text(categories[index]),
                              selected: index == 0,
                              onSelected: (_) {},
                            ),
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                          ),
                        ),
                        SizedBox(height: verticalPadding * 2),
                        Center(
                          child: Text(
                            'comingSoon'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddItemSheet(BuildContext context) {
    final cubit = context.read<WardrobeCubit>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'wardrobeAddSheetTitle'.tr(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'wardrobeAddSheetSubtitle'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryFilledButton(
              onPressed: context.read<WardrobeCubit>().state.isProcessing
                  ? null
                  : () {
                      Navigator.of(sheetContext).pop();
                      cubit.pickItem();
                    },
              label: 'wardrobeAddGallery'.tr(),
              icon: const Icon(Icons.photo_library_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreviewSheet(BuildContext context, WardrobeState state) {
    final cubit = context.read<WardrobeCubit>();
    final path = state.selectedImagePath;
    if (path == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<WardrobeCubit, WardrobeState>(
            builder: (context, sheetState) {
              final imagePath = sheetState.selectedImagePath;
              if (imagePath == null) {
                return const SizedBox.shrink();
              }

              final theme = Theme.of(context);
              final mediaQuery = MediaQuery.of(context);

              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.92,
                minChildSize: 0.85,
                maxChildSize: 0.95,
                builder: (context, controller) => Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 40,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    child: ListView(
                      controller: controller,
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        24 + mediaQuery.padding.bottom,
                      ),
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'wardrobePreviewTitle'.tr(),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'wardrobePreviewSubtitle'.tr(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                cubit.clearSelectedImage();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SecondaryOutlinedButton(
                          onPressed: sheetState.isProcessing
                              ? null
                              : () {
                                  Navigator.of(sheetContext).pop();
                                  cubit.pickItem();
                                },
                          label: 'wardrobePreviewChange'.tr(),
                          icon: const Icon(Icons.photo_library_outlined),
                        ),
                        const SizedBox(height: 12),
                        PrimaryFilledButton(
                          onPressed: sheetState.isAnalyzing
                              ? null
                              : () => cubit.startAnalysis(),
                          label: sheetState.isAnalyzing
                              ? 'wardrobeAnalyzeProcessing'.tr()
                              : 'wardrobeAnalyzeButton'.tr(),
                          icon: sheetState.isAnalyzing
                              ? null
                              : const Icon(Icons.auto_graph_rounded),
                          isLoading: sheetState.isAnalyzing,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
