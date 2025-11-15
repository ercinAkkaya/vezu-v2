import "package:flutter/material.dart";

class CombinationSelectablePill extends StatelessWidget {
  const CombinationSelectablePill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary.withOpacity(0.9)
        : Colors.black.withOpacity(0.12);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.95),
                    theme.colorScheme.primaryContainer.withOpacity(0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : theme.colorScheme.surfaceVariant.withOpacity(0.55),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.4 : 1.1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 12),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.85),
            letterSpacing: -0.05,
          ),
        ),
      ),
    );
  }
}

