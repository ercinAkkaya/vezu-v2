import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/features/combine/domain/entities/combination_plan.dart';
import 'package:vezu/features/wardrobe/domain/entities/clothing_item.dart';

class CombinationResultView extends StatelessWidget {
  const CombinationResultView({
    super.key,
    required this.plan,
    required this.wardrobeMap,
  });

  final CombinationPlan plan;
  final Map<String, ClothingItem> wardrobeMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlanHeroCard(plan: plan),
        const SizedBox(height: 18),
          _PlanInsightRow(plan: plan),
        const SizedBox(height: 24),
        ...plan.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _CombinationItemCard(
              item: item,
              clothingItem: wardrobeMap[item.wardrobeItemId],
            ),
          ),
        ),
        if (plan.stylingNotes.isNotEmpty)
          _InsightListSection(
            title: 'combineStylingNotes'.tr(),
            items: plan.stylingNotes,
          ),
        if (plan.accessories.isNotEmpty)
          _InsightListSection(
            title: 'combineAccessoryNotes'.tr(),
            items: plan.accessories,
          ),
        if (plan.warnings.isNotEmpty)
          _InsightListSection(
            title: 'combineWarnings'.tr(),
            items: plan.warnings,
            accentIcon: Icons.warning_amber_rounded,
          ),
      ],
    );
  }
}

class _PlanHeroCard extends StatelessWidget {
  const _PlanHeroCard({required this.plan});

  final CombinationPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppSurfaceCard(
      borderRadius: 32,
      padding: const EdgeInsets.all(26),
      gradient: const LinearGradient(
        colors: [Color(0xFF151515), Color(0xFF080808)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.theme,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            plan.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.82),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanInsightRow extends StatelessWidget {
  const _PlanInsightRow({required this.plan});

  final CombinationPlan plan;

  @override
  Widget build(BuildContext context) {
    final accessoriesLabel = plan.accessories.isEmpty
        ? 'combineAccessoryNone'.tr()
        : 'combineAccessorySingle'
            .tr(args: [plan.accessories.take(1).join(', ')]);
    final warningLabel =
        plan.warnings.isEmpty ? 'combineWarningNone'.tr() : plan.warnings.first;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _PlanInsightChip(
          icon: Icons.auto_awesome_outlined,
          label: plan.mood,
        ),
        _PlanInsightChip(
          icon: Icons.diamond_outlined,
          label: accessoriesLabel,
        ),
        _PlanInsightChip(
          icon: Icons.warning_amber_outlined,
          label: warningLabel,
        ),
      ],
    );
  }
}

class _PlanInsightChip extends StatelessWidget {
  const _PlanInsightChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InsightListSection extends StatelessWidget {
  const _InsightListSection({
    required this.title,
    required this.items,
    this.accentIcon,
  });

  final String title;
  final List<String> items;
  final IconData? accentIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: AppSurfaceCard(
        borderRadius: 28,
        padding: const EdgeInsets.all(22),
        backgroundColor: Colors.white.withOpacity(0.03),
        borderColor: Colors.white.withOpacity(0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (accentIcon != null) ...[
                  Icon(accentIcon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CombinationItemCard extends StatelessWidget {
  const _CombinationItemCard({
    required this.item,
    required this.clothingItem,
  });

  final CombinationPlanItem item;
  final ClothingItem? clothingItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = clothingItem?.imageUrl;
    final category = clothingItem?.category ?? item.slot;
    return AppSurfaceCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(18),
      backgroundColor: Colors.white.withOpacity(0.02),
      borderColor: Colors.white.withOpacity(0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemPreview(imageUrl: imageUrl),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nickname,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _CategoryPill(label: category),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.pairingReason,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.78),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.stylingTip,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                if (item.accent != null && item.accent!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'combineAccentLabel'.tr(args: [item.accent!]),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white.withOpacity(0.5),
          size: 24,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.network(
        imageUrl!,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white.withOpacity(0.9),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

