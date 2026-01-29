class TodoEntry {
  TodoEntry({
    required this.title,
    required this.time,
    required this.completed,
    required this.dueDate,
    required this.assignedTo,
    required this.status,
    required this.description,
  });

  final String title;
  final String time;
  final bool completed;
  final DateTime dueDate;
  final String assignedTo;
  final String status;
  final String description;
}
