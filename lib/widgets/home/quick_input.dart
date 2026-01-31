import 'package:flutter/material.dart';

class QuickInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isTracking;
  final VoidCallback onToggleTracking;

  const QuickInput({
    super.key,
    required this.controller,
    required this.isTracking,
    required this.onToggleTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'What are you working on?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onToggleTracking,
            icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
            label: Text(isTracking ? 'Stop' : 'Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isTracking ? Colors.redAccent : const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
