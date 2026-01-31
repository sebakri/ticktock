class TimeBlock {
  String name;
  final DateTime startTime;
  final DateTime endTime;

  TimeBlock({
    this.name = 'Session',
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}
