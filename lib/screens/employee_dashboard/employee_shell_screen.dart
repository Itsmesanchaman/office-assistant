import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmobile_app/screens/auth/employee_login_screen.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../services/task_service.dart';
import '../../services/session_service.dart';
import '../../services/session_watchdog_service.dart';
import '../admin/live_monitoring_screen.dart';
import 'assign_colleague_screen.dart';
import 'employee_dashboard_screen.dart';
import 'employee_history_screen.dart';
import 'employee_notifications_screen.dart';
import 'employee_profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class EmployeeShellScreen extends StatefulWidget {
  static const String routeName = "/employee-home";
  final Employee employee;

  const EmployeeShellScreen({super.key, required this.employee});

  @override
  State<EmployeeShellScreen> createState() => _EmployeeShellScreenState();
}

class _EmployeeShellScreenState extends State<EmployeeShellScreen> {
  int currentIndex = 0;
  bool _isLoggingOut = false; // ✅ naya

  @override
  void initState() {
    super.initState();

    // ✅ Aphno employee row delete vayo ki nai watch garne
    SessionWatchdogService.instance.startWatching(
      widget.employee.employeeId,
      _handleRemoved,
    );
  }

  Future<void> _handleRemoved() async {
    if (!mounted) return;
    setState(() => _isLoggingOut = true);

    // User le message dekhna paos vanera thodo pause
    await Future.delayed(const Duration(seconds: 2));

    await SessionService.clearSession();

    if (!mounted) return;
    context.go(EmployeeLoginScreen.routeName);
  }

  @override
  void dispose() {
    SessionWatchdogService.instance.stopWatching();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    final screens = [
      EmployeeDashboardScreen(employee: widget.employee),
      AssignColleagueScreen(employee: widget.employee),
      EmployeeHistoryScreen(employee: widget.employee),
      EmployeeNotificationsScreen(employee: widget.employee),
      EmployeeProfileScreen(employee: widget.employee),
    ];

    final titles = [
      "home".tr(),
      "assign_task".tr(),
      "history".tr(),
      "notifications".tr(),
      "my_profile".tr(),
    ];

    return Stack(
      children: [
        AnimatedBuilder(
          animation: TaskService.instance,
          builder: (context, _) {
            final badgeCount = TaskService.instance.unseenForEmployee(
              widget.employee.name,
            );

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.primary,
                automaticallyImplyLeading: false,
                title: Text(titles[currentIndex]),
                actions: [
                  if (currentIndex == 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: _badgedBell(badgeCount),
                        onPressed: () => setState(() => currentIndex = 3),
                      ),
                    ),
                  if (currentIndex == 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.map),
                        tooltip: "live_monitoring".tr(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveMonitoringScreen(
                                assignedByFilter: widget.employee.name,
                                title: "my_assigned_tasks_live".tr(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              body: screens[currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: currentIndex,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: Colors.grey,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                onTap: (index) => setState(() => currentIndex = index),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "home".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.send),
                    label: "assign".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: "history".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: _badgedBell(badgeCount),
                    label: "alerts".tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "profile".tr(),
                  ),
                ],
              ),
            );
          },
        ),

        // ✅ Logout overlay — full screen, back button block garne
        if (_isLoggingOut)
          PopScope(
            canPop: false,
            child: Container(
              color: Colors.black.withOpacity(0.85),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.person_off_rounded,
                      color: Colors.white70,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "user_not_found".tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "account_deleted_logging_out".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _badgedBell(int count) {
    if (count == 0) return const Icon(Icons.notifications);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications),
        Positioned(
          right: -6,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              "$count",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
