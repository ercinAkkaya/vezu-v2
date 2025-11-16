import 'package:flutter/material.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class WardrobeItemCard extends StatelessWidget {
  const WardrobeItemCard({
    super.key,
    required this.item,
    this.onDelete,
  });

  final ClothingItem item;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = item.metadata;

    final subtitleParts = <String>[
      if (metadata.style.isNotEmpty) metadata.style,
      if (metadata.season.isNotEmpty) metadata.season,
      if (metadata.colorTone.isNotEmpty) metadata.colorTone,
    ];

    final infoChips = <String>[
      ...metadata.colorPalette,
      if (metadata.fabric.isNotEmpty) metadata.fabric,
      if (metadata.pattern.isNotEmpty) metadata.pattern,
      ...metadata.details,
    ].where((value) => value.isNotEmpty).toList();

    const maxVisibleChips = 3;
    final visibleChips = infoChips.take(maxVisibleChips).toList();
    final overflowCount = infoChips.length - visibleChips.length;

    return GestureDetector(
      onTap: () => _showImagePreview(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.08),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    color: theme.colorScheme.surface,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.colorScheme.outline,
                    size: 32,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.4, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: onDelete != null ? 60 : 14,
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _Badge(
                      text: item.category.replaceAll('_', ' '),
                      color: Colors.white.withOpacity(0.85),
                      foreground: Colors.black87,
                    ),
                  ),
                  if (metadata.genderFit.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _Badge(
                        text: metadata.genderFit,
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        foreground: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: 14,
                right: 14,
                child: _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  onPressed: onDelete!,
                ),
              ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.type.replaceAll('_', ' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                  if (visibleChips.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ...visibleChips.map(
                          (value) => _InfoChip(
                            label: value,
                            theme: theme,
                            isOverlay: true,
                          ),
                        ),
                        if (overflowCount > 0)
                          _InfoChip(
                            label: '+$overflowCount',
                            theme: theme,
                            isOverlay: true,
                            isOverflow: true,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Container(
                  color: theme.colorScheme.surface,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder:
                            (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.black.withOpacity(0.45),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    required this.foreground,
  });

  final String text;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: foreground.withOpacity(0.08),
          width: 0.6,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.theme,
    this.isOverflow = false,
    this.isOverlay = false,
  });

  final String label;
  final ThemeData theme;
  final bool isOverflow;
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isOverlay
            ? Colors.white.withOpacity(isOverflow ? 0.25 : 0.22)
            : theme.colorScheme.secondary.withOpacity(0.9),
        border: Border.all(
          color: isOverlay
              ? Colors.white.withOpacity(0.4)
              : theme.colorScheme.onSecondary.withOpacity(isOverflow ? 0.1 : 0.18),
        ),
        boxShadow: isOverlay
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isOverlay
              ? Colors.white
              : isOverflow
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

