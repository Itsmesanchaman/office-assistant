import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskHistoryScreen extends StatelessWidget {
  final String taskTitle;

  const TaskHistoryScreen({super.key, required this.taskTitle});

  Color statusColor(String status) {
    switch (status) {
      case TaskStatus.accepted:
        return Colors.green;
      case TaskStatus.busy:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.grey;
      case TaskStatus.pending:
      default:
        return Colors.red;
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
        final filteredTasks = TaskService.instance.tasks
            .where((t) => t.workType.toLowerCase() == taskTitle.toLowerCase())
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(taskTitle)),
          body: filteredTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 70, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No '$taskTitle' tasks assigned yet",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(child: Text(task.employee.name[0])),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.employee.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(task.employee.designation),
                                  Text(
                                    "${task.assignedAt.hour}:${task.assignedAt.minute.toString().padLeft(2, '0')}",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Chip(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  label: Text(
                                    task.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: statusColor(task.status),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.priority.labelTr,
                                  style: TextStyle(
                                    color: priorityColor(task.priority),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
