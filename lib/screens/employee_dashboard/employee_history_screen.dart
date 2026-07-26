import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:easy_localization/easy_localization.dart';

class EmployeeHistoryScreen extends StatelessWidget {
  final Employee employee;
  const EmployeeHistoryScreen({super.key, required this.employee});

  Color statusColor(String status) {
    switch (status) {
      case TaskStatus.accepted:
      case TaskStatus.busy:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.grey.shade700;
      case TaskStatus.pending:
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final myTasks = TaskService.instance.tasksForEmployee(employee.name);

        if (myTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "no_history_yet".tr(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myTasks.length,
          itemBuilder: (context, index) {
            final t = myTasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(Icons.task_alt, color: AppColors.primary),
                title: Text(WorkType.labelTr(t.workType)),
                subtitle: Text(
                  "${t.assignedAt.day}/${t.assignedAt.month}/${t.assignedAt.year}  ${t.assignedAt.hour}:${t.assignedAt.minute.toString().padLeft(2, '0')}",
                ),
                trailing: Chip(
                  label: Text(
                      TaskStatus.labelTr(t.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: statusColor(t.status),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
