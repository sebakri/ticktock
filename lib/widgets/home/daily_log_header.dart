import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../shortcut_badge.dart';

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

        final theme = Theme.of(context);

        final onSurface = theme.colorScheme.onSurface;

    

        return Padding(

          padding: const EdgeInsets.symmetric(vertical: 8),

          child: Row(

            children: [

              // 1. Prev Day

              _buildNavButton(Icons.chevron_left_rounded, onPrevDay, onSurface),

              const SizedBox(width: 12),

              // 2. Date Display

              Expanded(

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      DateFormat('EEEE').format(selectedDate),

                      style: TextStyle(

                        color: onSurface.withOpacity(0.3),

                        fontSize: 11,

                        fontWeight: FontWeight.bold,

                        letterSpacing: 0.5,

                      ),

                    ),

                    Text(

                      DateFormat('MMMM dd, yyyy').format(selectedDate),

                      style: TextStyle(

                        color: onSurface,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ],

                ),

              ),

              // 3. Next Day

              _buildNavButton(Icons.chevron_right_rounded, onNextDay, onSurface),

              const SizedBox(width: 24),

              // 4. Today Button

              _buildActionButton(

                label: 'Today',

                shortcut: '⌘T',

                onPressed: onToday,

                color: const Color(0xFF4F46E5),

                onSurface: onSurface,

              ),

              const SizedBox(width: 12),

              // 5. Jump Button

              _buildActionButton(

                label: 'Jump',

                shortcut: '⌘D',

                onPressed: onJumpToDate,

                icon: Icons.calendar_today_rounded,

                color: const Color(0xFF4F46E5),

                onSurface: onSurface,

              ),

            ],

          ),

        );

      }

    

      Widget _buildNavButton(

          IconData icon, VoidCallback onPressed, Color onSurface) {

        return Container(

          decoration: BoxDecoration(

            color: onSurface.withOpacity(0.03),

            borderRadius: BorderRadius.circular(8),

            border: Border.all(color: onSurface.withOpacity(0.05)),

          ),

          child: IconButton(

            icon: Icon(icon, size: 20, color: onSurface.withOpacity(0.7)),

            onPressed: onPressed,

            visualDensity: VisualDensity.compact,

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

      }) {

        final themeColor = color ?? onSurface;

        final isIndigo = color != null;

    

        return TextButton(

          onPressed: onPressed,

          style: TextButton.styleFrom(

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

            backgroundColor: isIndigo

                ? themeColor.withOpacity(0.1)

                : onSurface.withOpacity(0.03),

            shape: RoundedRectangleBorder(

              borderRadius: BorderRadius.circular(10),

              side: BorderSide(

                color: isIndigo

                    ? themeColor.withOpacity(0.2)

                    : onSurface.withOpacity(0.05),

              ),

            ),

          ),

          child: Row(

            mainAxisSize: MainAxisSize.min,

            children: [

              if (icon != null) ...[

                Icon(icon, size: 14, color: isIndigo ? themeColor : onSurface.withOpacity(0.6)),

                const SizedBox(width: 6),

              ],

              Text(

                label,

                style: TextStyle(

                  color: isIndigo ? themeColor : onSurface.withOpacity(0.7),

                  fontSize: 13,

                  fontWeight: FontWeight.w600,

                ),

              ),

              const SizedBox(width: 8),

              ShortcutBadge(label: shortcut, isLight: true, fontSize: 10),

            ],

          ),

        );

      }

            }

            

  