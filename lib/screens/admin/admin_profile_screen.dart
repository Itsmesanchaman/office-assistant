import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'live_monitoring_screen.dart';
import 'package:tmobile_app/services/session_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/screens/auth/role_selection_screen.dart';
import 'package:tmobile_app/services/presence_service.dart';

class AdminProfileScreen extends StatelessWidget {
  AdminProfileScreen({super.key});

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> logout(BuildContext context) async {
    // Confirmation dialog dekhaune
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

    // FCM token clear garne DB baata
    if (userId != null) {
      final table = role == 'admin' ? 'admins' : 'employees';
      try {
        await supabase.from(table).update({'fcm_token': null}).eq('id', userId);
      } catch (e) {
        debugPrint('FCM token clear failed: $e');
        // fail vaye pani logout chai continue garne
      }
    }

    if (userId != null && role == 'employee') {
  await PresenceService.stop(userId);
}

    await SessionService.clearSession();

    if (context.mounted) {
      context.go(RoleSelectionScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('admin_profile'.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.primary.withOpacity(.15),
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'admin'.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Udayapurgadhi Rural Municipality",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 28),

                      _ProfileAction(
                        icon: Icons.map,
                        title: 'live_monitoring'.tr(),
                        subtitle: 'live_monitoring_subtitle'.tr(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LiveMonitoringScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      // === Language Toggle ===
                      _LanguageToggle(),
                    ],
                  ),
                ),
              ),

              // Bottom Logout Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    logout(context);
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: Text(
                    'logout'.tr(),
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
            ],
          ),
        ),
      ),
    );
  }
}

// === Naya widget: Language Toggle ===
class _LanguageToggle extends StatefulWidget {
  @override
  State<_LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<_LanguageToggle> {
  Future<void> _changeLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);

    // Supabase ma pani preferred_language save garne (notification translation ko lagi)
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
          // Toggle-style buttons: English / नेपाली
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              child: Icon(icon, color: Colors.brown),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
