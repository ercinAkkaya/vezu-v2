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

    final isCompact = visibleChips.isEmpty && subtitleParts.isEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isCompact ? 10 : 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
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
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.outline,
                      size: 32,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.38),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _Badge(
                    text: item.category.replaceAll('_', ' '),
                    color: theme.colorScheme.primary.withOpacity(0.85),
                    foreground: theme.colorScheme.onPrimary,
                  ),
                ),
                if (metadata.genderFit.isNotEmpty)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Badge(
                          text: metadata.genderFit,
                          color: theme.colorScheme.surface.withOpacity(0.75),
                          foreground: theme.colorScheme.onSurface,
                        ),
                        if (onDelete != null) ...[
                          const SizedBox(height: 8),
                          _ActionButton(
                            icon: Icons.delete_outline_rounded,
                            onPressed: onDelete!,
                          ),
                        ],
                      ],
                    ),
                  ),
                if (metadata.genderFit.isEmpty && onDelete != null)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      onPressed: onDelete!,
                    ),
                  ),
                if (!isCompact)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.type.replaceAll('_', ' '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: Colors.white,
                              ),
                            ),
                            if (subtitleParts.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitleParts.join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!isCompact)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ...visibleChips.map(
                        (value) => _InfoChip(
                          label: value,
                          theme: theme,
                        ),
                      ),
                      if (overflowCount > 0)
                        _InfoChip(
                          label: '+$overflowCount',
                          theme: theme,
                          isOverflow: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
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
  });

  final String label;
  final ThemeData theme;
  final bool isOverflow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isOverflow
            ? theme.colorScheme.primary.withOpacity(0.12)
            : theme.colorScheme.secondary.withOpacity(0.9),
        border: Border.all(
          color: theme.colorScheme.onSecondary.withOpacity(isOverflow ? 0.1 : 0.18),
        ),
        boxShadow: [
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
          color: isOverflow
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

