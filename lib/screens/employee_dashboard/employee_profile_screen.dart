import 'package:flutter/material.dart';
import 'package:tmobile_app/screens/auth/role_selection_screen.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import 'package:go_router/go_router.dart';
import 'package:tmobile_app/services/session_service.dart';
import '../../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/services/presence_service.dart';

class _LanguageToggle extends StatefulWidget {
  const _LanguageToggle();

  @override
  State<_LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<_LanguageToggle> {
  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);

    final userId = await SessionService.getUserId();
    final role = await SessionService.getUserRole();
    if (userId != null) {
      final table = role == 'admin' ? 'admins' : 'employees';
      try {
        await Supabase.instance.client
            .from(table)
            .update({'preferred_language': locale.languageCode})
            .eq('id', userId);
      } catch (e) {
        debugPrint('Language preference save failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            backgroundColor: AppColors.accent.withOpacity(.2),
            child: const Icon(Icons.language, color: Colors.brown),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'language'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'select_language_subtitle'.tr(),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangOption(
                  label: "EN",
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () => _changeLanguage(context, const Locale('en')),
                ),
                _LangOption(
                  label: "ने",
                  isSelected: currentLocale.languageCode == 'ne',
                  onTap: () => _changeLanguage(context, const Locale('ne')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small Language Option Button
class _LangOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class EmployeeProfileScreen extends StatefulWidget {
  final Employee employee;
  const EmployeeProfileScreen({super.key, required this.employee});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  // ... your existing logout and _editMobileNumber functions remain same ...

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('logout'.tr()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final userId = await SessionService.getUserId();
    final role = await SessionService.getUserRole();

    if (userId != null) {
      await PresenceService.stop(userId);
    }

    if (userId != null && role != null) {
      await AuthService.signOut(userId: userId, role: role);
    } else {
      await SessionService.clearSession();
    }

    if (context.mounted) {
      context.go(RoleSelectionScreen.routeName);
    }
  }

  void _editMobileNumber() {
    // ... your existing _editMobileNumber code (same) ...
    // Just change texts to .tr() where possible
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.primary.withOpacity(.15),
            child: Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            widget.employee.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${widget.employee.designation} • ${widget.employee.department}",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Language Toggle
          const _LanguageToggle(),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                _infoTile(
                  Icons.phone,
                  "mobile_number".tr(),
                  widget.employee.mobileNo,
                  trailing: IconButton(
                    icon: Icon(Icons.edit, size: 18, color: AppColors.primary),
                    tooltip: "change_mobile".tr(),
                    onPressed: _editMobileNumber,
                  ),
                ),
                const Divider(),
                _infoTile(
                  Icons.meeting_room,
                  "room_no".tr(),
                  widget.employee.room,
                ),
                const Divider(),
                _infoTile(Icons.email, "email".tr(), widget.employee.email),
                const Divider(),
                _infoTile(
                  Icons.badge,
                  "employee_id".tr(),
                  widget.employee.employeeId,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: Text(
                "logout".tr(),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            "profile_note".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  value.isEmpty ? "—" : value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
