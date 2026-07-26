import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedStatus = 'all_status';
  String selectedDate = 'all_time';

  String _dateBucket(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'today'.tr();
    if (diff == 1) return 'yesterday'.tr();
    if (diff <= 7) return 'last_week'.tr();
    return 'older'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final allTasks = TaskService.instance.tasks;

        final filteredItems = allTasks.where((t) {
          bool statusMatch =
              selectedStatus == "All Status" || t.status == selectedStatus;
          bool dateMatch =
              selectedDate == "All Time" ||
              _dateBucket(t.assignedAt) == selectedDate;
          return statusMatch && dateMatch;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          body: Column(
            children: [
              const SizedBox(height: 16),

              /// FILTER BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterButton(),
                      const SizedBox(width: 8),
                      _buildDateFilterButton(),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text('export_feature_comming_soon'.tr()),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label:  Text('export'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// HISTORY LIST
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_history_found'.tr(),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final t = filteredItems[index];
                          return HistoryCard(
                            name: t.employee.name,
                            message:
                                t.workType +
                                (t.note.isNotEmpty ? " — ${t.note}" : ""),
                            status: t.status,
                            time:
                                "${t.assignedAt.hour}:${t.assignedAt.minute.toString().padLeft(2, '0')} | ${t.assignedAt.day}/${t.assignedAt.month}",
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) => setState(() => selectedStatus = value),
      itemBuilder: (BuildContext context) => [
         PopupMenuItem(value: "All Status", child: Text('all_status'.tr())),
        ...TaskStatus.all.map((s) => PopupMenuItem(value: s, child: Text(s))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              selectedStatus,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (String value) => setState(() => selectedDate = value),
      itemBuilder: (BuildContext context) => [
         PopupMenuItem(value: "All Time", child: Text('all_time'.tr())),
         PopupMenuItem(value: "Today", child: Text('today'.tr())),
         PopupMenuItem(value: "Yesterday", child: Text('yesterday'.tr())),
         PopupMenuItem(value: "Last Week", child: Text('last_week'.tr())),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Text(
              selectedDate,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String name;
  final String message;
  final String status;
  final String time;

  const HistoryCard({
    super.key,
    required this.name,
    required this.message,
    required this.status,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status) {
      case TaskStatus.done:
        statusColor = Colors.grey;
        break;
      case TaskStatus.busy:
        statusColor = Colors.orange;
        break;
      case TaskStatus.accepted:
        statusColor = Colors.green;
        break;
      case TaskStatus.pending:
      default:
        statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            radius: 24,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
