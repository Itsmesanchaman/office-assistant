import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'task_details_screen.dart';
import 'package:tmobile_app/services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/screens/constants/app_enum.dart';
import 'package:easy_localization/easy_localization.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  final Employee employee;
  const EmployeeDashboardScreen({super.key, required this.employee});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  String filter = "All";
  EmployeeStatus _currentStatus = EmployeeStatus.available;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unseen = TaskService.instance.unseenForEmployee(
        widget.employee.name,
      );
      if (unseen > 0) {
        HapticFeedback.vibrate();
        SystemSound.play(SystemSoundType.alert);
      }
      TaskService.instance.markSeenByEmployee(widget.employee.name);
    });
  }

  Future<void> _loadCurrentStatus() async {
    final userId = await SessionService.getUserId();
    if (userId == null) return;

    try {
      final res = await Supabase.instance.client
          .from('employees')
          .select('status')
          .eq('employee_id', userId)
          .maybeSingle(); // Changed to maybeSingle for safety

      if (res != null && mounted) {
        setState(() {
          _currentStatus = EmployeeStatus.values.firstWhere(
            (e) => e.value == res['status'],
            orElse: () => EmployeeStatus.available,
          );
        });
      }
    } catch (e) {
      debugPrint("Failed to load status: $e");
      // Keep default status if loading fails
    }
  }

  Future<void> _showStatusDropdown() async {
    final selected = await showDialog<EmployeeStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("update_your_status".tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EmployeeStatus.values.map((status) {
            final isSelected = status == _currentStatus;
            return ListTile(
              leading: Icon(Icons.circle, color: status.color),
              title: Text(status.label.tr()),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Navigator.pop(context, status),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && selected != _currentStatus) {
      await updateMyStatus(selected);
    }
  }

  Future<void> updateMyStatus(EmployeeStatus status) async {
    setState(() => _currentStatus = status);

    try {
      final userId = await SessionService.getUserId();
      if (userId == null) return;

      await Supabase.instance.client
          .from('employees')
          .update({
            'status': status.value,
            'status_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('employee_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("status_updated_to".tr(args: [status.label.tr()])),
            backgroundColor: status.color,
          ),
        );
      }
    } catch (e) {
      debugPrint("Status update failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("failed_to_update_status".tr())));
      }
    }
  }

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
        return AppColors.nepalRed;
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
        final allTasks = TaskService.instance.tasksForEmployee(
          widget.employee.name,
        );

        final counts = {
          TaskStatus.pending: allTasks
              .where((t) => t.status == TaskStatus.pending)
              .length,
          TaskStatus.busy: allTasks
              .where((t) => t.status == TaskStatus.busy)
              .length,
          TaskStatus.done: allTasks
              .where((t) => t.status == TaskStatus.done)
              .length,
        };

        final visibleTasks = filter == "All"
            ? allTasks
            : allTasks.where((t) => t.status == filter).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Hello + Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "hello".tr(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.employee.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Right Side: Status Chips
                  GestureDetector(
                    onTap: () => _showStatusDropdown(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _currentStatus.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _currentStatus.color.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 14,
                            color: _currentStatus.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentStatus.label.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _currentStatus.color,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tasks Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.assignment, color: AppColors.primary, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "you_have".tr(),
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Text(
                            "assigned_tasks".tr(
                              args: [allTasks.length.toString()],
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(
                      "all".tr(args: [allTasks.length.toString()]),
                      "All",
                    ),

                    _filterChip(
                      "pending".tr(
                        args: [counts[TaskStatus.pending].toString()],
                      ),
                      TaskStatus.pending,
                    ),

                    _filterChip(
                      "busy".tr(args: [counts[TaskStatus.busy].toString()]),
                      TaskStatus.busy,
                    ),

                    _filterChip(
                      "done".tr(args: [counts[TaskStatus.done].toString()]),
                      TaskStatus.done,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (visibleTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "no_tasks_here".tr(),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                ...visibleTasks.map((task) => _taskTile(context, task)),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary.withOpacity(.2),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => filter = value),
    );
  }

  Widget _taskTile(BuildContext context, Task task) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        TaskService.instance.markSeenByEmployee(task.employee.name);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: priorityColor(task.priority), width: 5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      WorkType.labelTr(task.workType),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(task.status).withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                      TaskStatus.labelTr(task.status),
                    style: TextStyle(
                      color: statusColor(task.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "from".tr(args: [task.assignedBy]),
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "${task.assignedAt.hour}:${task.assignedAt.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  task.priority.labelTr,
                  style: TextStyle(
                    color: priorityColor(task.priority),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
