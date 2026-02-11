import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;

  const TimePickerDialog({
    super.key,
    required this.initialTime,
    this.title = 'Select Time',
  });

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: onSurface.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnitColumn('Hour', _hour, 23, (val) => setState(() => _hour = val)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: onSurface.withOpacity(0.2),
                    ),
                  ),
                ),
                _buildUnitColumn('Minute', _minute, 59, (val) => setState(() => _minute = val)),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: onSurface.withOpacity(0.5))),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, TimeOfDay(hour: _hour, minute: _minute)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitColumn(String label, int value, int max, Function(int) onChanged) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChanged((value + 1) % (max + 1)),
          icon: Icon(Icons.keyboard_arrow_up_rounded, color: onSurface.withOpacity(0.3)),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
        ),
        IconButton(
          onPressed: () => onChanged((value - 1 + (max + 1)) % (max + 1)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: onSurface.withOpacity(0.3)),
        ),
      ],
    );
  }
}
