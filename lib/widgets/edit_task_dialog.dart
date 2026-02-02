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
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Task',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                const Text('Task Name',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField(_nameController, 'UI Design for Dashboard',
                    autofocus: true),
                const SizedBox(height: 16),
                const Text('Description (optional)',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField(_descController, 'Wireframing new layout concepts',
                    maxLines: 3),
                const SizedBox(height: 16),
                const Text('Color',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widget.palette.map((color) {
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 18, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Text('Cancel', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          ShortcutBadge(label: 'Esc', isLight: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Text('Save Changes',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                          ShortcutBadge(label: '⌘↵', isLight: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: handleDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                              _showDeleteConfirm
                                  ? Icons.warning_amber_rounded
                                  : Icons.delete_outline,
                              size: 18),
                          const SizedBox(width: 8),
                          Text(
                              _showDeleteConfirm
                                  ? 'Are you sure? (Confirm)'
                                  : 'Delete Task',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 12),
                          const ShortcutBadge(label: '⌘⌫', isLight: true),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: widget.onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                        foregroundColor: const Color(0xFF4F46E5),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow, size: 18),
                          SizedBox(width: 8),
                          Text('Start Tracking', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 12),
                          ShortcutBadge(label: '⌘S', isLight: true),
                        ],
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


  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, bool autofocus = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
