import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import 'package:easy_localization/easy_localization.dart';

class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({super.key});

  Color statusColor(String status) {
    switch (status) {
      case "Accept":
        return Colors.green;
      case "Busy":
        return Colors.blue;
      case "Done":
        return Colors.grey.shade700;
      case "Pending":
      default:
        return Colors.orange;
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
      case "Accept":
        return Icons.check_circle;
      case "Busy":
        return Icons.directions_walk;
      case "Done":
        return Icons.done_all;
      case "Pending":
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final log = TaskService.instance.activityLog;

        if (log.isEmpty) {
          return Center(
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
                  "no_status_updates_yet".tr(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: log.length,
          itemBuilder: (context, index) {
            final entry = log[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor(entry.status).withOpacity(.15),
                  child: Icon(
                    statusIcon(entry.status),
                    color: statusColor(entry.status),
                  ),
                ),
                title: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: entry.employeeName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " marked task '${entry.workType}' as "),
                      TextSpan(
                        text: entry.status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor(entry.status),
                        ),
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
                subtitle: Text(
                  "${entry.time.hour}:${entry.time.minute.toString().padLeft(2, '0')}  •  ${entry.time.day}/${entry.time.month}/${entry.time.year}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
