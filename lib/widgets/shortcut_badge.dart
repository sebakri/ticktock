import 'package:flutter/material.dart';

class ShortcutBadge extends StatelessWidget {
  final String label;
  final double fontSize;
  final bool isLight;

  const ShortcutBadge({
    super.key,
    required this.label,
    this.fontSize = 12,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isLight
        ? theme.colorScheme.onSurface.withOpacity(isDark ? 0.1 : 0.05)
        : theme.colorScheme.surface;

    final textColor = isLight
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.primary;

    final borderColor = isLight
        ? theme.colorScheme.onSurface.withOpacity(0.1)
        : theme.colorScheme.onSurface.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'monospace',
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
