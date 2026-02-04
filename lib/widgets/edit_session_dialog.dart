import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/time_block.dart';
import 'shortcut_badge.dart';

class EditSessionDialog extends StatefulWidget {
  final TimeBlock block;
  final Function(String name, DateTime startTime, DateTime endTime) onSave;

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
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.block.name);
    _startTime = widget.block.startTime;
    _endTime = widget.block.endTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        _endTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final initialTime = TimeOfDay.fromDateTime(isStart ? _startTime : _endTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            picked.hour,
            picked.minute,
          );
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(minutes: 30));
          }
        } else {
          final newEndTime = DateTime(
            _endTime.year,
            _endTime.month,
            _endTime.day,
            picked.hour,
            picked.minute,
          );
          if (newEndTime.isBefore(_startTime)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End time cannot be before start time')),
            );
            return;
          }
          _endTime = newEndTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final dateFormat = DateFormat('EEEE, MMMM d, y');
    final timeFormat = DateFormat('HH:mm');

    void handleSave() {
      if (_nameController.text.trim().isEmpty) return;
      widget.onSave(_nameController.text, _startTime, _endTime);
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Session',
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
                    'SESSION NAME',
                    style: TextStyle(
                      color: onSurface.withOpacity(0.25),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_nameController, 'Morning Session', onSurface,
                      autofocus: true),
                  const SizedBox(height: 24),
                  Text(
                    'DATE',
                    style: TextStyle(
                      color: onSurface.withOpacity(0.25),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPickerTile(
                    icon: Icons.calendar_today_rounded,
                    label: dateFormat.format(_startTime),
                    onTap: _pickDate,
                    onSurface: onSurface,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 350) {
                        return Column(
                          children: [
                            _buildTimePickerSection('START TIME', timeFormat.format(_startTime), () => _pickTime(true), onSurface),
                            const SizedBox(height: 24),
                            _buildTimePickerSection('END TIME', timeFormat.format(_endTime), () => _pickTime(false), onSurface),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _buildTimePickerSection('START TIME', timeFormat.format(_startTime), () => _pickTime(true), onSurface),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimePickerSection('END TIME', timeFormat.format(_endTime), () => _pickTime(false), onSurface),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.end,
                      children: [
                        _buildActionButton(
                          label: 'Cancel',
                          shortcut: 'Esc',
                          onPressed: () => Navigator.pop(context),
                          onSurface: onSurface,
                        ),
                        _buildActionButton(
                          label: 'Save Changes',
                          shortcut: '⌘↵',
                          onPressed: handleSave,
                          isPrimary: true,
                          onSurface: onSurface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerSection(String title, String label, VoidCallback onTap, Color onSurface) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: onSurface.withOpacity(0.25),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildPickerTile(
          icon: Icons.access_time_rounded,
          label: label,
          onTap: onTap,
          onSurface: onSurface,
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color onSurface,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: onSurface.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onSurface.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: onSurface.withOpacity(0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: onSurface.withOpacity(0.2)),
          ],
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          ShortcutBadge(label: shortcut, isLight: true, fontSize: 10),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, Color onSurface,
      {bool autofocus = false}) {
    return TextField(
      controller: controller,
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
