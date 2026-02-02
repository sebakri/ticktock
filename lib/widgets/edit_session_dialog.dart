import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/time_block.dart';
import 'shortcut_badge.dart';

class EditSessionDialog extends StatefulWidget {
  final TimeBlock block;
  final Function(String) onSave;

  const EditSessionDialog({
    super.key,
    required this.block,
    required this.onSave,
  });

  @override
  State<EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<EditSessionDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.block.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void handleSave() {
      if (_nameController.text.trim().isEmpty) return;
      widget.onSave(_nameController.text);
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
                      'Edit Session',
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
                              const Text('Session Name',
                                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 8),
                              _buildTextField(_nameController, 'Morning Session',
                                  autofocus: true),
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
                      onPressed: handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool autofocus = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
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
