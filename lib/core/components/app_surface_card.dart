import "package:flutter/material.dart";

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = 28,
    this.shadows,
    this.elevation = 0.12,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius);

    final effectiveShadows = shadows ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(elevation * 1.2),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ];

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null
            ? backgroundColor ?? theme.colorScheme.surface.withOpacity(0.95)
            : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outline.withOpacity(0.18),
          width: borderWidth,
        ),
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
