import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:vezu/features/combination/presentation/components/combination_selectable_pill.dart";

class CombinationSeasonSelector extends StatelessWidget {
  const CombinationSeasonSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "combinationSeasonTitle".tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "combinationSeasonSubtitle".tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options
              .map(
                (key) => CombinationSelectablePill(
                  label: key.tr(),
                  isSelected: selected == key,
                  onTap: () => onChanged(key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

