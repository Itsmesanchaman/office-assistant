import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmobile_app/widgets/dashboard_background.dart';
import '../constants/app_colors.dart';
import 'login_screen.dart';
import 'employee_login_screen.dart';


class RoleSelectionScreen extends StatelessWidget {
  static const String routeName = "/role";

  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png", height: 90),
                const SizedBox(height: 20),
                const Text(
                  "तपाईं को रूपमा लगइन गर्नुहोस्",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Continue as",
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                _RoleCard(
                  icon: Icons.admin_panel_settings,
                  title: "Admin",
                  subtitle:
                      "प्रशासक — manage employees, assign work, view reports",
                  onTap: () => context.push(LoginScreen.routeName),
                ),
                const SizedBox(height: 18),
                _RoleCard(
                  icon: Icons.badge,
                  title: "General User",
                  subtitle: "कर्मचारी — view and update your assigned tasks",
                  onTap: () => context.push(EmployeeLoginScreen.routeName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.92),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(.12),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
