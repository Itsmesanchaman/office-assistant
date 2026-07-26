class TaskHistory {
  final String employeeName;
  final String destination;
  final String task;
  final String time;
  final String status;
  final String? assignedById;
  final String? assignedByName;

  TaskHistory({
    required this.employeeName,
    required this.destination,
    required this.task,
    required this.time,
    required this.status,
    this.assignedById,
    this.assignedByName,
  });
}
