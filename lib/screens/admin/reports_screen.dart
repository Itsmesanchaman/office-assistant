import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedMonth = DateTime.now();

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

  Widget taskTile(Task t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Text(t.employee.name[0])),
        title: Text("${t.employee.name} — ${t.workType}"),
        subtitle: Text(
          "${t.assignedAt.day}/${t.assignedAt.month}/${t.assignedAt.year}"
          "  ${t.assignedAt.hour}:${t.assignedAt.minute.toString().padLeft(2, '0')}"
          "  •  ${t.priority.labelTr}",
        ),
        trailing: Chip(
          label: Text(
            t.status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: statusColor(t.status),
        ),
      ),
    );
  }

  Widget emptyState(String label) => Padding(
    padding: const EdgeInsets.all(40),
    child: Center(
      child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reports"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Daily"),
              Tab(text: "Monthly"),
              Tab(text: "Datewise"),
              Tab(text: "Taskwise"),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: TaskService.instance,
          builder: (context, _) {
            return TabBarView(
              children: [
                // DAILY (today)
                _buildList(
                  TaskService.instance.reportForToday(),
                  "No tasks assigned today",
                ),

                // MONTHLY
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          "${selectedMonth.month}/${selectedMonth.year}",
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedMonth,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null)
                            setState(() => selectedMonth = picked);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildList(
                        TaskService.instance.reportForMonth(
                          selectedMonth.year,
                          selectedMonth.month,
                        ),
                        "No tasks assigned this month",
                      ),
                    ),
                  ],
                ),

                // DATEWISE (any specific day)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event),
                        label: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null)
                            setState(() => selectedDate = picked);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildList(
                        TaskService.instance.reportForDate(selectedDate),
                        "No tasks assigned on this date",
                      ),
                    ),
                  ],
                ),

                // TASKWISE (grouped by work type)
                _buildTaskwise(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Task> tasks, String emptyLabel) {
    if (tasks.isEmpty) return emptyState(emptyLabel);
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      itemBuilder: (context, i) => taskTile(tasks[i]),
    );
  }

  Widget _buildTaskwise() {
    final grouped = TaskService.instance.reportByTaskType();
    if (grouped.isEmpty) return emptyState("No tasks assigned yet");

    return ListView(
      padding: const EdgeInsets.all(12),
      children: grouped.entries.map((entry) {
        return ExpansionTile(
          title: Text("${entry.key} (${entry.value.length})"),
          children: entry.value.map(taskTile).toList(),
        );
      }).toList(),
    );
  }
}
