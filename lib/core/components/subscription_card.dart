import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vezu/core/components/app_surface_card.dart';

enum SubscriptionPlan { free, monthly, yearly }

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    super.key,
    required this.currentPlan,
    required this.onUpgrade,
  });

  final SubscriptionPlan currentPlan;
  final ValueChanged<SubscriptionPlan> onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextPlan = _nextPlan(currentPlan);
    final planColor = _planColor(theme, currentPlan);

    return AppSurfaceCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shadows: const [
        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
      ],
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: planColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.stars_rounded, color: planColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'profileSubscriptionCurrent'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _planLabel(context, currentPlan),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (nextPlan != null) ...[
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: () => onUpgrade(nextPlan),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: planColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.arrow_circle_up_rounded, size: 18),
              label: Text(
                'profileSubscriptionUpgrade'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  SubscriptionPlan? _nextPlan(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return SubscriptionPlan.monthly;
      case SubscriptionPlan.monthly:
        return SubscriptionPlan.yearly;
      case SubscriptionPlan.yearly:
        return null;
    }
  }

  static String _planLabel(BuildContext context, SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'profileSubscriptionFree'.tr();
      case SubscriptionPlan.monthly:
        return 'profileSubscriptionMonthly'.tr();
      case SubscriptionPlan.yearly:
        return 'profileSubscriptionYearly'.tr();
    }
  }

  Color _planColor(ThemeData theme, SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return theme.colorScheme.primary;
      case SubscriptionPlan.monthly:
        return Colors.teal;
      case SubscriptionPlan.yearly:
        return Colors.deepPurple;
    }
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (plan) {
      SubscriptionPlan.free => theme.colorScheme.primary,
      SubscriptionPlan.monthly => Colors.teal,
      SubscriptionPlan.yearly => Colors.deepPurple,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            SubscriptionCard._planLabel(context, plan),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
