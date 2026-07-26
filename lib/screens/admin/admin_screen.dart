import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tmobile_app/widgets/employee_card.dart';
import '../../services/employee_service.dart';
import '../../services/task_service.dart';
import '../constants/app_colors.dart';
import '../../widgets/overview_card.dart';
import '../../widgets/quick_action_card.dart';
import 'add_employee_screen.dart';
import 'edit_employee_screen.dart';
import 'reports_screen.dart';
import 'package:tmobile_app/utils/number_helper.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        TaskService.instance,
        EmployeeService.instance,
      ]),
      builder: (context, _) {
        final ts = TaskService.instance;

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// HEADER
              Text(
                'welcome_admin'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'manage_employees_tasks'.tr(),
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              /// OVERVIEW CARDS — live counts
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
                children: [
                  OverviewCard(
                    icon: Icons.groups,
                    value: NumberHelper.toLocalized(
                      context,
                      EmployeeService.instance.employees.length,
                    ),
                    title: 'employees'.tr(),
                    subtitle: 'active_staff'.tr(),
                    color: AppColors.primary,
                  ),
                  OverviewCard(
                    icon: Icons.assignment,
                    value: NumberHelper.toLocalized(context, ts.totalTasks),
                    title: 'tasks'.tr(),
                    subtitle: 'assigned_tasks'.tr(),
                    color: Colors.green,
                  ),
                  OverviewCard(
                    icon: Icons.check_circle,
                    value: NumberHelper.toLocalized(context, ts.doneCount),
                    title: 'completed'.tr(),
                    subtitle: 'finished_tasks'.tr(),
                    color: Colors.orange,
                  ),
                  OverviewCard(
                    icon: Icons.notifications_active,
                    value: NumberHelper.toLocalized(context, ts.unseenForAdmin),
                    title: 'alerts'.tr(),
                    subtitle: 'task_updates'.tr(),
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// TASK SUMMARY — live counts
              Text(
                'task_summary'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                        ),
                        title: Text('done'.tr()),
                        trailing: Text(
                          NumberHelper.toLocalized(context, ts.doneCount),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.pending, color: Colors.red),
                        title: Text('pending'.tr()),
                        trailing: Text(
                          NumberHelper.toLocalized(context, ts.pendingCount),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.directions_walk,
                          color: Colors.orange,
                        ),
                        title: Text('busy'.tr()),
                        trailing: Text(
                          NumberHelper.toLocalized(context, ts.busyCount),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.thumb_up,
                          color: Colors.green,
                        ),
                        title: Text('accepted'.tr()),
                        trailing: Text(
                          NumberHelper.toLocalized(context, ts.acceptedCount),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// EMPLOYEE MANAGEMENT
              Text(
                'employee_management'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _searchQuery = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: "search_employees_hint".tr(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = "";
                          }),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ...(() {
                final filtered = EmployeeService.instance.employees.where((e) {
                  if (_searchQuery.isEmpty) return true;
                  return e.name.toLowerCase().contains(_searchQuery) ||
                      e.department.toLowerCase().contains(_searchQuery) ||
                      e.designation.toLowerCase().contains(_searchQuery) ||
                      e.room.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "no_employees_match".tr(
                            namedArgs: {'query': _searchQuery},
                          ),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ];
                }

                return filtered
                    .map(
                      (employee) => EmployeeCard(
                        employee: employee,
                        onEdit: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditEmployeeScreen(employee: employee),
                            ),
                          );
                        },
                        onDelete: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('delete_employee'.tr()),
                              content: Text("delete_confirmation".tr()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('cancel'.tr()),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      await EmployeeService.instance
                                          .removeEmployee(employee);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "could_not_delete_employee".tr(
                                              namedArgs: {
                                                'error': e.toString(),
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text('delete'.tr()),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                    .toList();
              })(),

              const SizedBox(height: 30),

              /// QUICK ACTIONS
              Text(
                "quick_actions".tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.person_add,
                      title: 'add_employee'.tr(),
                      color: AppColors.primary,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEmployeeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.description,
                      title: 'reports'.tr(),
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
