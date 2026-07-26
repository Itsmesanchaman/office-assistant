import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class EmployeeNotificationsScreen extends StatelessWidget {
  final Employee employee;
  const EmployeeNotificationsScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final myTasks = TaskService.instance.tasksForEmployee(employee.name);
        final newest = myTasks.where((t) => !t.seenByEmployee).toList();

        if (myTasks.isEmpty) {
          return _emptyState();
        }

        if (newest.length == 1 && myTasks.first.id == newest.first.id) {
          return _ringBellAlert(context, newest.first);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myTasks.length,
          itemBuilder: (context, index) {
            final task = myTasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: task.seenByEmployee
                      ? Colors.grey.shade200
                      : AppColors.primary.withOpacity(.15),
                  child: Icon(
                    Icons.notifications,
                    color: task.seenByEmployee
                        ? Colors.grey
                        : AppColors.primary,
                  ),
                ),
                title: Text(
                  WorkType.labelTr(task.workType),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${"you_have_task_from".tr(namedArgs: {'department': task.employee.department})}\n"
                  "${task.assignedAt.hour}:${task.assignedAt.minute.toString().padLeft(2, '0')} • "
                  "${task.assignedAt.day}/${task.assignedAt.month}/${task.assignedAt.year}",
                ),
                isThreeLine: true,
                onTap: () {
                  TaskService.instance.markSeenByEmployee(employee.name);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailsScreen(task: task),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "no_notifications_yet".tr(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _ringBellAlert(BuildContext context, Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.notifications_active, size: 110, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            "new_task_assigned".tr(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Text(
            "you_have_new_task_from".tr(
              namedArgs: {'department': task.employee.department},
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          Text(
            "${task.assignedAt.hour}:${task.assignedAt.minute.toString().padLeft(2, '0')}  •  ${task.assignedAt.day}/${task.assignedAt.month}/${task.assignedAt.year}",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                TaskService.instance.markSeenByEmployee(task.employee.name);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailsScreen(task: task),
                  ),
                );
              },
              child: Text(
                "view_task".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
