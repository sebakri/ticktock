class TimeBlock {
  int? id;
  int? taskId;
  String name;
  final DateTime startTime;
  final DateTime endTime;

  TimeBlock({
    this.id,
    this.taskId,
    this.name = 'Session',
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'name': name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }

  factory TimeBlock.fromMap(Map<String, dynamic> map) {
    return TimeBlock(
      id: map['id'],
      taskId: map['task_id'],
      name: map['name'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
    );
  }
}
