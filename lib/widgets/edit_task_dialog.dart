import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import 'shortcut_badge.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final List<Color> palette;
  final Function(String, String, Color) onSave;
  final VoidCallback onDelete;
  final VoidCallback onStart;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.palette,
    required this.onSave,
    required this.onDelete,
    required this.onStart,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late Color _selectedColor;
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _selectedColor = widget.task.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    void handleSave() {
      if (_nameController.text.trim().isEmpty) return;
      widget.onSave(
          _nameController.text, _descController.text, _selectedColor);
      Navigator.pop(context);
    }

    void handleDelete() {
      if (_showDeleteConfirm) {
        widget.onDelete();
      } else {
        setState(() => _showDeleteConfirm = true);
        // Reset after 3 seconds if not confirmed
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _showDeleteConfirm) {
            setState(() => _showDeleteConfirm = false);
          }
        });
      }
    }

    return Focus(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, meta: true): handleSave,
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.pop(context),
          const SingleActivator(LogicalKeyboardKey.backspace, meta: true):
              handleDelete,
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
              widget.onStart,
        },
        child: Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: onSurface.withOpacity(0.05)),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Task',
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
                _buildTextField(_nameController, 'UI Design for Dashboard',
                    onSurface,
                    autofocus: true),
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
                    _descController, 'Wireframing new layout concepts', onSurface,
                    maxLines: 3),
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
                // Row 1: Workflow Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      label: 'Cancel',
                      shortcut: 'Esc',
                      onPressed: () => Navigator.pop(context),
                      onSurface: onSurface,
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      label: 'Save',
                      shortcut: '⌘↵',
                      onPressed: handleSave,
                      isPrimary: true,
                      onSurface: onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: onSurface.withOpacity(0.05)),
                const SizedBox(height: 24),
                // Row 2: Task Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: _showDeleteConfirm ? 'Confirm' : 'Delete',
                        icon: _showDeleteConfirm
                            ? Icons.warning_amber_rounded
                            : Icons.delete_outline,
                        shortcut: '⌘⌫',
                        onPressed: handleDelete,
                        color: Colors.redAccent,
                        onSurface: onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Start',
                        icon: Icons.play_arrow_rounded,
                        shortcut: '⌘S',
                        onPressed: widget.onStart,
                        color: const Color(0xFF4F46E5),
                        onSurface: onSurface,
                      ),
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
    required VoidCallback onPressed,
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
            isPrimary ? const Color(0xFF4F46E5) : themeColor.withOpacity(0.05),
        foregroundColor: isPrimary ? Colors.white : themeColor.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : themeColor.withOpacity(0.1),
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
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
