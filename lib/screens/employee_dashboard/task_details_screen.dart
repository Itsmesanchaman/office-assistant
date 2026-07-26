import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskDetailsScreen extends StatelessWidget {
  static const String routeName = "/task-details";
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  Color statusColor(String status) {
    switch (status) {
      case TaskStatus.accepted:
        return Colors.green;
      case TaskStatus.busy:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.grey.shade700;
      case TaskStatus.pending:
      default:
        return Colors.orange;
    }
  }

  Color priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.veryUrgent:
        return Colors.red.shade700;
      case TaskPriority.urgent:
        return Colors.orange.shade700;
      case TaskPriority.normal:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: const Text("Task Details"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accent.withOpacity(.2),
                        child: const Icon(Icons.folder, color: Colors.brown),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        task.workType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _infoRow("Task ID", task.id),
                _infoRow("Assigned By", task.assignedBy),
                _infoRow("Department", task.employee.department),
                _infoRow(
                  "Assigned On",
                  "${task.assignedAt.day}/${task.assignedAt.month}/${task.assignedAt.year}  ${task.assignedAt.hour}:${task.assignedAt.minute.toString().padLeft(2, '0')}",
                ),

                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  task.note.isNotEmpty
                      ? task.note
                      : "No additional description was given for this task.",
                  style: TextStyle(color: Colors.grey.shade700),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Priority",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  task.priority.labelTr,
                  style: TextStyle(
                    color: priorityColor(task.priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(task.status).withOpacity(.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor(task.status)),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: statusColor(task.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  "Update Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.6,
                  children: [
                    _statusButton(TaskStatus.accepted, Colors.green),
                    _statusButton(TaskStatus.busy, Colors.blue),
                    _statusButton(TaskStatus.pending, Colors.orange),
                    _statusButton(TaskStatus.done, Colors.grey.shade700),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          const Text(":  "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String status, Color color) {
    final isCurrent = task.status == status;
    final isDone = task.status == TaskStatus.done;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrent ? color : color.withOpacity(.85),
        disabledBackgroundColor: Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: isCurrent ? 4 : 1,
      ),
      onPressed: (isDone && !isCurrent)
          ? null
          : () => TaskService.instance.updateStatus(task.id, status),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
