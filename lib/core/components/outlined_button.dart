import "package:flutter/material.dart";

class SecondaryOutlinedButton extends StatelessWidget {
  const SecondaryOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.minHeight = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: Size.fromHeight(minHeight),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
        style: buttonStyle,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(label),
    );
  }
}
