import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/core/components/primary_filled_button.dart';

class WardrobeUploadSheet extends StatelessWidget {
  const WardrobeUploadSheet({
    super.key,
    required this.onGalleryTap,
  });

  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'wardrobeAddSheetTitle'.tr(),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'wardrobeAddSheetSubtitle'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondary,
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
            onPressed: onGalleryTap,
            label: 'wardrobeAddGallery'.tr(),
            icon: const Icon(Icons.photo_library_rounded),
          ),
        ],
      ),
    );
  }

  static Widget emptyState({
    required bool isProcessing,
    required VoidCallback onAddPressed,
  }) {
    return _EmptyWardrobePlaceholder(
      onAddPressed: isProcessing ? null : onAddPressed,
    );
  }
}

class _EmptyWardrobePlaceholder extends StatelessWidget {
  const _EmptyWardrobePlaceholder({this.onAddPressed});

  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.checkroom_outlined,
          size: 52,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'wardrobeEmptyTitle'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'wardrobeEmptySubtitle'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        PrimaryFilledButton(
          onPressed: onAddPressed,
          label: 'wardrobeAddItem'.tr(),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

