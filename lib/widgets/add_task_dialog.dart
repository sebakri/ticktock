import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shortcut_badge.dart';

class AddTaskDialog extends StatefulWidget {
  final List<Color> palette;
  final List<String> existingTitles;
  final Function(String, String, Color) onSave;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void handleSave() {
      if (_nameController.text.trim().isEmpty || _errorMessage != null) return;
      widget.onSave(_nameController.text.trim(),
          _descController.text.trim(), _selectedColor);
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
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Task',
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
                _buildTextField(_nameController, 'e.g. Design System'),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Description (optional)',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                _buildTextField(_descController, 'What is this task about?',
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
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Text('Cancel', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 12),
                          ShortcutBadge(label: 'Esc', isLight: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: _nameController.text.trim().isEmpty ||
                              _errorMessage != null
                          ? null
                          : handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white10,
                        disabledForegroundColor: Colors.white24,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Text('Add Task',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                          ShortcutBadge(label: '⌘↵', isLight: true),
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

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
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
        autofocus: controller == _nameController,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
