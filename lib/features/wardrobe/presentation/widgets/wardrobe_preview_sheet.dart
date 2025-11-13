import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vezu/core/components/primary_filled_button.dart';
import 'package:vezu/core/components/outlined_button.dart';
import 'package:vezu/features/wardrobe/data/constants/wardrobe_constants.dart';
import 'package:vezu/features/wardrobe/presentation/cubit/wardrobe_cubit.dart';

class WardrobePreviewSheet extends StatelessWidget {
  const WardrobePreviewSheet({
    super.key,
    required this.onChangeImage,
    required this.onClearImage,
    required this.onAnalyze,
  });

  final VoidCallback onChangeImage;
  final VoidCallback onClearImage;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return BlocBuilder<WardrobeCubit, WardrobeState>(
      builder: (context, state) {
        final imagePath = state.selectedImagePath;
        if (imagePath == null) return const SizedBox.shrink();

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.92,
          minChildSize: 0.85,
          maxChildSize: 0.95,
          builder: (context, controller) => Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
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
                        onPressed: onClearImage,
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
                    onPressed: state.isProcessing ? null : onChangeImage,
                    label: 'wardrobePreviewChange'.tr(),
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                  const SizedBox(height: 20),
                  _CategorySelectors(state: state),
                  if (state.analysisErrorKey != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.analysisErrorKey!.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'wardrobeAnalyzeHelper'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondary.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryFilledButton(
                    onPressed: state.isAnalyzing ||
                            state.selectedCategoryKey == null ||
                            state.selectedTypeKey == null
                        ? null
                        : onAnalyze,
                    label: state.isAnalyzing
                        ? 'wardrobeAnalyzeProcessing'.tr()
                        : 'wardrobeAnalyzeButton'.tr(),
                    icon: state.isAnalyzing
                        ? null
                        : const Icon(Icons.auto_graph_rounded),
                    isLoading: state.isAnalyzing,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategorySelectors extends StatelessWidget {
  const _CategorySelectors({required this.state});

  final WardrobeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<WardrobeCubit>();

    final categoryItems = WardrobeFilters.filterOptions
        .where((option) => option.categoryKey != null)
        .map(
          (option) => DropdownMenuItem<String>(
            value: option.categoryKey,
            child: Text(option.labelKey.tr()),
          ),
        )
        .toList();

    final selectedCategory = state.selectedCategoryKey;
    final availableTypes =
        selectedCategory != null ? WardrobeCategoryTypes.values[selectedCategory] ?? [] : [];

    final selectedType = availableTypes.contains(state.selectedTypeKey)
        ? state.selectedTypeKey
        : null;

    final typeItems = availableTypes
        .map(
          (key) => DropdownMenuItem<String>(
            value: key,
            child: Text(
              WardrobeTypeLabels.map.containsKey(key)
                  ? WardrobeTypeLabels.map[key]!.tr()
                  : key,
            ),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'wardrobeSelectCategory'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          onChanged: state.isAnalyzing ? null : (value) => cubit.selectCategory(value),
          decoration: InputDecoration(
            hintText: 'wardrobeSelectCategoryHint'.tr(),
          ),
          items: categoryItems,
        ),
        const SizedBox(height: 20),
        Text(
          'wardrobeSelectType'.tr(),
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedType,
          onChanged: selectedCategory == null || state.isAnalyzing
              ? null
              : (value) => cubit.selectType(value),
          decoration: InputDecoration(
            hintText: selectedCategory == null
                ? 'wardrobeSelectTypeDisabled'.tr()
                : 'wardrobeSelectTypeHint'.tr(),
          ),
          items: typeItems,
        ),
      ],
    );
  }
}

