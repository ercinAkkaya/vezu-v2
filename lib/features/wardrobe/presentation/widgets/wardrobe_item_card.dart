import 'package:flutter/material.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class WardrobeItemCard extends StatelessWidget {
  const WardrobeItemCard({super.key, required this.item});

  final ClothingItem item;

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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface.withOpacity(0.95),
            theme.colorScheme.surfaceVariant.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.06),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
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
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.45),
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
                      if ((metadata.genderFit).isNotEmpty)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: _Badge(
                            text: metadata.genderFit,
                            color: theme.colorScheme.surface.withOpacity(0.7),
                            foreground: theme.colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.type.replaceAll('_', ' '),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (metadata.season.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                metadata.season,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (subtitleParts.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitleParts.join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondary.withOpacity(0.85),
                        ),
                      ),
                    ],
                    if (infoChips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: infoChips
                            .take(4)
                            .map(
                              (value) => _InfoChip(
                                label: value,
                                theme: theme,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
  const _InfoChip({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.secondary.withOpacity(0.85),
        border: Border.all(
          color: theme.colorScheme.onSecondary.withOpacity(0.08),
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
          color: theme.colorScheme.onSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

