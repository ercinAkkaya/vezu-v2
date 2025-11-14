import 'package:flutter/material.dart';
import 'package:vezu/core/components/app_surface_card.dart';
import 'package:vezu/core/components/primary_filled_button.dart';

class PaywallFeatureData {
  const PaywallFeatureData({
    required this.label,
    this.isComingSoon = false,
    this.isHighlighted = false,
  });

  final String label;
  final bool isComingSoon;
  final bool isHighlighted;
}

class PaywallPlanCard extends StatelessWidget {
  const PaywallPlanCard({
    super.key,
    required this.title,
    required this.priceLabel,
    required this.billingLabel,
    required this.features,
    required this.onSubscribe,
    required this.ctaLabel,
    this.description,
    this.badgeLabel,
    this.isPromoted = false,
    this.isActive = false,
    this.savingsLabel,
    this.footerNote,
  });

  final String title;
  final String priceLabel;
  final String billingLabel;
  final List<PaywallFeatureData> features;
  final VoidCallback onSubscribe;
  final String ctaLabel;
  final String? description;
  final String? badgeLabel;
  final bool isPromoted;
  final bool isActive;
  final String? savingsLabel;
  final String? footerNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isOnDarkBackground = !isActive && isPromoted;

    final gradientColors = isActive
        ? [
            Colors.white,
            const Color(0xFFEFF3FF),
          ]
        : isPromoted
            ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
            : [
                theme.colorScheme.surface.withOpacity(0.94),
                theme.colorScheme.surface.withOpacity(0.98),
              ];

    final highlightGradient = LinearGradient(
      colors: isActive
          ? [
              theme.colorScheme.primary.withOpacity(0.85),
              theme.colorScheme.primary,
            ]
          : isPromoted
              ? const [Color(0xFF5A62FF), Color(0xFF6DD5FA)]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.78),
                ],
    );

    final titleColor = isActive
        ? theme.colorScheme.primary
        : isOnDarkBackground
            ? Colors.white
            : theme.colorScheme.onSurface;

    final descriptionColor = isOnDarkBackground
        ? Colors.white.withOpacity(0.72)
        : theme.colorScheme.onSecondary.withOpacity(0.9);

    final priceColor = isActive
        ? theme.colorScheme.primary
        : isOnDarkBackground
            ? Colors.white
            : theme.colorScheme.primary;

    final billingColor = isOnDarkBackground
        ? Colors.white.withOpacity(0.7)
        : theme.colorScheme.onSecondary;

    final savingsColor = isOnDarkBackground
        ? const Color(0xFF9CC5FF)
        : theme.colorScheme.primary;

    final footerNoteColor = isOnDarkBackground
        ? Colors.white.withOpacity(0.6)
        : theme.colorScheme.onSecondary;

    final borderColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.22)
        : Colors.white.withOpacity(isPromoted ? 0.06 : 0.24);

    final shadowColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.24)
        : Colors.black.withOpacity(isPromoted ? 0.3 : 0.15);

    final blurRadius = isActive ? 32.0 : isPromoted ? 45.0 : 32.0;

    final featureItems = features
        .map(
          (feature) => _PaywallFeatureItem(
            data: feature,
            isOnDarkBackground: isOnDarkBackground,
          ),
        )
        .toList();

    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      borderRadius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      borderColor: borderColor,
      elevation: isActive ? 0.32 : isPromoted ? 0.28 : 0.18,
      shadows: [
        BoxShadow(
          color: shadowColor,
          blurRadius: blurRadius,
          offset: const Offset(0, 22),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeLabel != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: highlightGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Text(
                  badgeLabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 10),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: descriptionColor,
              ),
            ),
          ],
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: priceLabel,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: priceColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                TextSpan(
                  text: ' $billingLabel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: billingColor,
                  ),
                ),
              ],
            ),
          ),
          if (savingsLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              savingsLabel!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: savingsColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (var i = 0; i < featureItems.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == featureItems.length - 1 ? 0 : 10),
              child: featureItems[i],
            ),
          const SizedBox(height: 10),
          PrimaryFilledButton(
            label: ctaLabel,
            onPressed: onSubscribe,
            minHeight: 50,
          ),
          if (footerNote != null) ...[
            const SizedBox(height: 12),
            Text(
              footerNote!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: footerNoteColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaywallFeatureItem extends StatelessWidget {
  const _PaywallFeatureItem({
    required this.data,
    required this.isOnDarkBackground,
  });

  final PaywallFeatureData data;
  final bool isOnDarkBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComingSoon = data.isComingSoon;
    final isHighlighted = data.isHighlighted;

    final textColor = isOnDarkBackground
        ? Colors.white.withOpacity(isComingSoon ? 0.78 : 0.94)
        : theme.colorScheme.onSurface.withOpacity(isComingSoon ? 0.74 : 0.9);

    final indicatorColor = isComingSoon
        ? const Color(0xFF52CFFE)
        : isHighlighted
            ? const Color(0xFFFFB86C)
            : isOnDarkBackground
                ? Colors.white
                : theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                indicatorColor.withOpacity(0.92),
                indicatorColor.withOpacity(0.72),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: indicatorColor.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            isComingSoon ? Icons.av_timer_rounded : Icons.check_rounded,
            size: 16,
            color: isOnDarkBackground ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            data.label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

