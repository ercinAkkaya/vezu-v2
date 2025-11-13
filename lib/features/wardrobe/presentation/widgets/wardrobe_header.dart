import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/features/wardrobe/data/constants/wardrobe_constants.dart';

typedef WardrobeFilterCallback = void Function(String? categoryKey);

class WardrobeHeader extends StatelessWidget {
  const WardrobeHeader({
    super.key,
    required this.activeFilterKey,
    required this.onFilterChanged,
  });

  final String? activeFilterKey;
  final WardrobeFilterCallback onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WardrobeFilters.filterOptions.length,
        itemBuilder: (context, index) {
          final option = WardrobeFilters.filterOptions[index];
          final isSelected =
              activeFilterKey == option.categoryKey ||
                  (option.categoryKey == null && activeFilterKey == null);

          return FilterChip(
            label: Text(option.labelKey.tr()),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            selected: isSelected,
            onSelected: (_) {
              if (option.categoryKey == null) {
                onFilterChanged(null);
              } else if (isSelected) {
                onFilterChanged(null);
              } else {
                onFilterChanged(option.categoryKey);
              }
            },
            backgroundColor: theme.colorScheme.surfaceVariant,
            selectedColor: theme.colorScheme.primary,
            checkmarkColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
      ),
    );
  }
}

