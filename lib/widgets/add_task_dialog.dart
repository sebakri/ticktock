import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shortcut_badge.dart';

class AddTaskDialog extends StatefulWidget {
  final List<Color> palette;
  final List<String> existingTitles;
  final Function(String title, String description, Color color, List<String> tags) onSave;

  const AddTaskDialog({
    super.key,
    required this.palette,
    required this.existingTitles,
    required this.onSave,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  late Color _selectedColor;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.palette.first;
    _nameController.addListener(_validate);
  }

  void _validate() {
    final title = _nameController.text.trim().toLowerCase();
    String? newError;

    if (title.isNotEmpty && widget.existingTitles.contains(title)) {
      newError = 'A task with this name already exists';
    }

    setState(() {
      _errorMessage = newError;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_validate);
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    void handleSave() {
      if (_nameController.text.trim().isEmpty || _errorMessage != null) return;
      
      final tags = _tagsController.text
          .split(RegExp(r'[\s,]+'))
          .where((t) => t.isNotEmpty)
          .map((t) => t.startsWith('#') ? t.substring(1) : t)
          .toList();

      widget.onSave(_nameController.text.trim(), _descController.text.trim(),
          _selectedColor, tags);
      Navigator.pop(context);
    }

    return Focus(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, meta: true): handleSave,
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(context),
        },
        child: Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: onSurface.withOpacity(0.05)),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Task',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: onSurface.withOpacity(0.3),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'TASK NAME',
                  style: TextStyle(
                    color: onSurface.withOpacity(0.25),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(_nameController, 'e.g. Design System', onSurface,
                    autofocus: true),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 14, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'DESCRIPTION (OPTIONAL)',
                  style: TextStyle(
                    color: onSurface.withOpacity(0.25),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                    _descController, 'What is this task about?', onSurface,
                    maxLines: 3),
                const SizedBox(height: 24),
                Text(
                  'TAGS (OPTIONAL)',
                  style: TextStyle(
                    color: onSurface.withOpacity(0.25),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                    _tagsController, 'e.g. #work #private', onSurface),
                const SizedBox(height: 24),
                Text(
                  'COLOR',
                  style: TextStyle(
                    color: onSurface.withOpacity(0.25),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.palette.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: onSurface, width: 2)
                              : Border.all(color: Colors.transparent),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      label: 'Cancel',
                      shortcut: 'Esc',
                      onPressed: () => Navigator.pop(context),
                      onSurface: onSurface,
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      label: 'Add Task',
                      shortcut: '⌘↵',
                      onPressed: _nameController.text.trim().isEmpty ||
                              _errorMessage != null
                          ? null
                          : handleSave,
                      isPrimary: true,
                      onSurface: onSurface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required String shortcut,
    required VoidCallback? onPressed,
    required Color onSurface,
    IconData? icon,
    Color? color,
    bool isPrimary = false,
  }) {
    final themeColor = color ?? onSurface;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? const Color(0xFF4F46E5) : onSurface.withOpacity(0.03),
        foregroundColor: isPrimary ? Colors.white : onSurface.withOpacity(0.7),
        disabledBackgroundColor: onSurface.withOpacity(0.05),
        disabledForegroundColor: onSurface.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : onSurface.withOpacity(0.05),
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600)),
          const SizedBox(width: 10),
          ShortcutBadge(label: shortcut, isLight: true, fontSize: 10),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, Color onSurface,
      {int maxLines = 1, bool autofocus = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      autofocus: autofocus,
      style: TextStyle(fontSize: 15, color: onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: onSurface.withOpacity(0.15)),
        filled: true,
        fillColor: onSurface.withOpacity(0.03),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: onSurface.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
      ),
    );
  }
}
