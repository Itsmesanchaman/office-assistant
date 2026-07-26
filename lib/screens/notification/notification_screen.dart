import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedFilter = "All";

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

  IconData statusIcon(String status) {
    switch (status) {
      case TaskStatus.accepted:
        return Icons.check_circle;
      case TaskStatus.busy:
        return Icons.access_time;
      case TaskStatus.done:
        return Icons.done_all;
      case TaskStatus.pending:
      default:
        return Icons.schedule;
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

  String getInitials(String name) {
    final parts = name.split(" ");
    if (parts.length >= 2) return "${parts[0][0]}${parts[1][0]}";
    return name.isNotEmpty ? name[0] : "?";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final allTasks = TaskService.instance.tasks;

        final filtered = selectedFilter == "All"
            ? allTasks
            : allTasks.where((e) => e.status == selectedFilter).toList();

        return Column(
          children: [
            const SizedBox(height: 12),

            // FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:  EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  filterChip("all".tr()),
                  filterChip(TaskStatus.pending),
                  filterChip(TaskStatus.accepted),
                  filterChip(TaskStatus.busy),
                  filterChip(TaskStatus.done),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "no_tasks_assigned".tr(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              left: BorderSide(
                                color: priorityColor(task.priority),
                                width: 5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: AppColors.primary
                                        .withOpacity(.15),
                                    child: Text(
                                      getInitials(task.employee.name),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.employee.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "${task.employee.designation} • ${task.employee.room}",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  statusBadge(task.status),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      task.workType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor(
                                        task.priority,
                                      ).withOpacity(.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      task.priority.labelTr,
                                      style: TextStyle(
                                        color: priorityColor(task.priority),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (task.note.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    task.note,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "assigned_updated_time".tr(namedArgs: {
                                    'assignedHour': task.assignedAt.hour.toString(),
                                    'assignedMin': task.assignedAt.minute.toString().padLeft(2, '0'),
                                    'updatedHour': task.updatedAt.hour.toString(),
                                    'updatedMin': task.updatedAt.minute.toString().padLeft(2, '0'),
                                  }),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget filterChip(String text) {
    bool selected = selectedFilter == text;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: selected,
        onSelected: (_) => setState(() => selectedFilter = text),
      ),
    );
  }

  Widget statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor(status).withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon(status), size: 14, color: statusColor(status)),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
