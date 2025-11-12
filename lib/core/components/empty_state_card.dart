import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:vezu/core/components/app_surface_card.dart";
import "package:vezu/core/components/primary_filled_button.dart";

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({super.key, required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.add, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            'homeEmptyStateTitle'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'homeEmptyStateSubtitle'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 20),
          PrimaryFilledButton(
            onPressed: onAction,
            label: 'homeEmptyStateCta'.tr(),
          ),
        ],
      ),
    );
  }
}
