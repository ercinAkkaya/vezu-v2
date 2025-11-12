import "package:flutter/material.dart";

class PrimaryFilledButton extends StatelessWidget {
  const PrimaryFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.minHeight = 52,
    this.minWidth,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double minHeight;
  final double? minWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final labelWidget = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : Text(label);

    final buttonStyle = FilledButton.styleFrom(
      minimumSize: Size(minWidth ?? double.infinity, minHeight),
    );

    if (icon != null || isLoading) {
      return FilledButton.icon(
        onPressed: effectiveOnPressed,
        icon: icon ?? const SizedBox(width: 0, height: 0),
        label: labelWidget,
        style: buttonStyle,
      );
    }

    return FilledButton(
      onPressed: effectiveOnPressed,
      style: buttonStyle,
      child: labelWidget,
    );
  }
}
