import 'package:flutter/material.dart';
import './constants/app_colors.dart';
import '../services/task_service.dart';
import 'home_screen.dart';
import 'admin/admin_profile_screen.dart';
import 'admin/admin_screen.dart';
import 'History/history_screen.dart';
import 'notification/notification_home_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = "/";
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const NotificationHomeScreen(),
    const HistoryScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    context.locale;

    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final alertCount = TaskService.instance.unseenForAdmin;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary,
            title: Text(
              currentIndex == 0
                  ? 'officer_dashboard'.tr()
                  : currentIndex == 1
                  ? 'notifications'.tr()
                  : currentIndex == 2
                  ? 'history'.tr()
                  : 'admin_portal'.tr(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                tooltip: "admin_profile".tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminProfileScreen()),
                  );
                },
              ),
            ],
          ),
          body: screens[currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color.fromARGB(255, 226, 227, 229),
            currentIndex: currentIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.primaryDark,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: (index) => setState(() => currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: "dashboard".tr(),
              ),
              BottomNavigationBarItem(
                icon: _badgedIcon(Icons.notifications, alertCount),
                label: "notifications".tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "history".tr(),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: "admin".tr(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badgedIcon(IconData icon, int count) {
    if (count == 0) return Icon(icon);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
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
