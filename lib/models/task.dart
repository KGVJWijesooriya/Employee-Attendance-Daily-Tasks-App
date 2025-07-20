class Task {
  final String name;
  final DateTime dueDate;
  final String priority;
  String status;

  Task({
    required this.name,
    required this.dueDate,
    required this.priority,
    this.status = 'Not Started',
  });
}
