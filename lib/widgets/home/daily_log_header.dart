import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyLogHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrevDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;
  final VoidCallback onJumpToDate;

  const DailyLogHeader({
    super.key,
    required this.selectedDate,
    required this.onPrevDay,
    required this.onNextDay,
    required this.onToday,
    required this.onJumpToDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: onPrevDay,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: onNextDay,
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: onToday,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF818CF8).withOpacity(0.1),
                  foregroundColor: const Color(0xFF818CF8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Today',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(
                height: 24,
                child: VerticalDivider(color: Colors.white24, width: 32),
              ),
              ElevatedButton.icon(
                onPressed: onJumpToDate,
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Jump to date',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
