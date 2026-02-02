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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLight ? Colors.white.withOpacity(0.1) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isLight ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'monospace',
          color: isLight ? Colors.white70 : const Color(0xFF818CF8),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
