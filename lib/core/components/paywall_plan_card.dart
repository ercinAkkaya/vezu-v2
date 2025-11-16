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

    final isOnDarkBackground = !isActive;

    final gradientColors = isActive
        ? [
            Colors.white,
            const Color(0xFFF4F4F4),
          ]
        : isPromoted
            ? const [Color(0xFF1E1E1E), Color(0xFF131313)]
            : const [Color(0xFF161616), Color(0xFF0F0F0F)];

    final highlightGradient = LinearGradient(
      colors: isActive
          ? [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.8),
            ]
          : [
              Colors.white.withOpacity(0.16),
              Colors.white.withOpacity(0.08),
            ],
    );

    final titleColor = isActive ? Colors.black : Colors.white;

    final descriptionColor = isActive
        ? Colors.black.withOpacity(0.7)
        : Colors.white.withOpacity(0.68);

    final priceColor = isActive ? Colors.black : Colors.white;

    final billingColor = isActive
        ? Colors.black.withOpacity(0.6)
        : Colors.white.withOpacity(0.7);

    final savingsColor = isActive
        ? Colors.black.withOpacity(0.75)
        : Colors.white.withOpacity(0.8);

    final footerNoteColor = isActive
        ? Colors.black.withOpacity(0.6)
        : Colors.white.withOpacity(0.55);

    final borderColor = isActive
        ? Colors.black.withOpacity(0.12)
        : Colors.white.withOpacity(0.08);

    final shadowColor = isActive
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.45);

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
      child: SingleChildScrollView(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: descriptionColor,
                ),
              ),
            ],
            const SizedBox(height: 12),
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
            const SizedBox(height: 10),
            for (var i = 0; i < featureItems.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i == featureItems.length - 1 ? 0 : 8,
                ),
                child: featureItems[i],
              ),
            const SizedBox(height: 8),
            PrimaryFilledButton(
              label: ctaLabel,
              onPressed: onSubscribe,
              minHeight: 46,
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

