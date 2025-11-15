import 'package:flutter/material.dart';

enum PaywallBillingCycle {
  monthly,
  yearly,
}

class PaywallBillingToggle extends StatelessWidget {
  const PaywallBillingToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    this.monthlyLabel = 'Aylık',
    this.yearlyLabel = 'Yıllık',
    this.highlightLabel,
  });

  final PaywallBillingCycle selected;
  final ValueChanged<PaywallBillingCycle> onChanged;
  final String monthlyLabel;
  final String yearlyLabel;
  final String? highlightLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface.withOpacity(0.6);
    final borderColor = theme.colorScheme.outline.withOpacity(0.18);
    final textStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: borderColor, width: 0.7),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / 2;

          return SizedBox(
            height: 48,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: selected == PaywallBillingCycle.monthly
                      ? 0
                      : segmentWidth,
                  child: Container(
                    width: segmentWidth,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selected == PaywallBillingCycle.monthly
                            ? [
                                theme.colorScheme.primary.withOpacity(0.85),
                                theme.colorScheme.primary,
                              ]
                            : [
                                const Color(0xFF5A62FF),
                                const Color(0xFF52CFFE),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    _ToggleSegment(
                      width: segmentWidth,
                      isSelected: selected == PaywallBillingCycle.monthly,
                      onTap: () => onChanged(PaywallBillingCycle.monthly),
                      label: monthlyLabel,
                      textStyle: textStyle,
                    ),
                    _ToggleSegment(
                      width: segmentWidth,
                      isSelected: selected == PaywallBillingCycle.yearly,
                      onTap: () => onChanged(PaywallBillingCycle.yearly),
                      label: yearlyLabel,
                      textStyle: textStyle,
                      highlightLabel: highlightLabel,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.width,
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.textStyle,
    this.highlightLabel,
  });

  final double width;
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final TextStyle? textStyle;
  final String? highlightLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor =
        isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final secondaryColor = isSelected
        ? theme.colorScheme.onPrimary.withOpacity(0.72)
        : theme.colorScheme.primary;

    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: textStyle?.copyWith(color: foregroundColor),
              ),
              if (highlightLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: AnimatedOpacity(
                    opacity: isSelected ? 1 : 0.9,
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      highlightLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

