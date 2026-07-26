import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../services/employee_service.dart';
import '../../services/task_service.dart';
import '../dashboard/message_pop.dart';
import 'package:easy_localization/easy_localization.dart';

class AssignColleagueScreen extends StatelessWidget {
  final Employee employee;
  const AssignColleagueScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TaskService.instance,
        EmployeeService.instance,
      ]),
      builder: (context, _) {
        final colleagues = EmployeeService.instance.employees
            .where((e) => e.name != employee.name)
            .toList();

        return colleagues.isEmpty
            ? Center(
                child: Text(
                  "no_colleagues_to_assign".tr(),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "tap_map_icon_for_live_status".tr(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...colleagues.map((colleague) {
                    final pendingCount = TaskService.instance
                        .tasksForEmployee(colleague.name)
                        .where((t) => t.assignedBy == employee.name)
                        .length;

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
                            backgroundColor: AppColors.primary.withOpacity(.15),
                            child: Text(
                              colleague.name.isNotEmpty
                                  ? colleague.name[0]
                                  : "?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  colleague.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${colleague.designation} • ${colleague.department}",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  colleague.room,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                                if (pendingCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "tasks_sent_by_you".tr(
                                      namedArgs: {
                                        "count": pendingCount.toString(),
                                      },
                                    ),
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.notifications_active,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            tooltip: "assign_task".tr(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => EmployeeMessagePopup(
                                  employee: colleague,
                                  assignedBy: employee.name,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
      },
    );
  }
}
