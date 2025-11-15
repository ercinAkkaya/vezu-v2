import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

class CombinationSectionHeader extends StatelessWidget {
  const CombinationSectionHeader({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    this.optionalLabelKey,
  });

  final String titleKey;
  final String subtitleKey;
  final String? optionalLabelKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titleKey.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (optionalLabelKey != null)
              Text(
                optionalLabelKey!.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitleKey.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}

