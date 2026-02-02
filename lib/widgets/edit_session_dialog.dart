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

              backgroundColor: const Color(0xFF0F172A),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(24),

                side: BorderSide(color: Colors.white.withOpacity(0.05)),

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

                        const Text(

                          'Edit Session',

                          style: TextStyle(

                            fontSize: 24,

                            fontWeight: FontWeight.bold,

                            letterSpacing: -0.5,

                          ),

                        ),

                        IconButton(

                          icon: const Icon(Icons.close, size: 20),

                          color: Colors.white30,

                          onPressed: () => Navigator.pop(context),

                        ),

                      ],

                    ),

                    const SizedBox(height: 24),

                    const Text(

                      'SESSION NAME',

                      style: TextStyle(

                        color: Colors.white24,

                        fontSize: 11,

                        fontWeight: FontWeight.bold,

                        letterSpacing: 1.2,

                      ),

                    ),

                    const SizedBox(height: 12),

                    _buildTextField(_nameController, 'Morning Session',

                        autofocus: true),

                                    const SizedBox(height: 48),

                                    Row(

                                      mainAxisAlignment: MainAxisAlignment.end,

                                      children: [

                                        _buildActionButton(

                                          label: 'Cancel',

                                          shortcut: 'Esc',

                                          onPressed: () => Navigator.pop(context),

                                        ),

                                        const SizedBox(width: 16),

                                        _buildActionButton(

                                          label: 'Save Changes',

                                          shortcut: '⌘↵',

                                          onPressed: handleSave,

                                          isPrimary: true,

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

                        IconData? icon,

                        Color? color,

                        bool isPrimary = false,

                      }) {

                        final themeColor = color ?? Colors.white;

                        return ElevatedButton(

                          onPressed: onPressed,

                          style: ElevatedButton.styleFrom(

                            backgroundColor:

                                isPrimary ? const Color(0xFF4F46E5) : themeColor.withOpacity(0.03),

                            foregroundColor: isPrimary ? Colors.white : themeColor.withOpacity(0.7),

                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(12),

                              side: BorderSide(

                                color: isPrimary ? Colors.transparent : themeColor.withOpacity(0.05),

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

                    

    

      Widget _buildTextField(TextEditingController controller, String hint,

          {bool autofocus = false}) {

        return TextField(

          controller: controller,

          autofocus: autofocus,

          style: const TextStyle(fontSize: 15, color: Colors.white),

          decoration: InputDecoration(

            hintText: hint,

            hintStyle: TextStyle(color: Colors.white.withOpacity(0.15)),

            filled: true,

            fillColor: Colors.white.withOpacity(0.03),

            contentPadding:

                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            enabledBorder: OutlineInputBorder(

              borderRadius: BorderRadius.circular(12),

              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),

            ),

            focusedBorder: OutlineInputBorder(

              borderRadius: BorderRadius.circular(12),

              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),

            ),

          ),

        );

      }

    }

    
