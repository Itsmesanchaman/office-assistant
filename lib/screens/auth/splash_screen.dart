import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmobile_app/widgets/dashboard_background.dart';
import '../constants/app_colors.dart';
import 'package:tmobile_app/services/session_service.dart';
import 'package:tmobile_app/screens/officer_dashboard.dart';
import 'package:tmobile_app/screens/auth/role_selection_screen.dart';
import 'package:tmobile_app/services/employee_service.dart';
import 'package:tmobile_app/screens/employee_dashboard/employee_shell_screen.dart';
import 'package:tmobile_app/services/task_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'package:tmobile_app/services/presence_service.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _hasError = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _initAndNavigate();
    });
  }

  /// Real internet check — radio state matra hoina, actual reachability
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _initAndNavigate() async {
    if (!mounted) return;

    setState(() {
      _hasError = false;
      _isRetrying = true;
    });

    // ✅ Step 1: Internet xa ki nai check garne, kei call garnu agadi
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isRetrying = false;
      });
      return; // ❗ Session lai touch nagari error view matra dekhaune
    }

    try {
      await EmployeeService.instance.init();
      await TaskService.instance.init();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isRetrying = false;
      });
      return;
    }

    if (!mounted) return;
    await _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    if (!mounted) return;

    try {
      final isLoggedIn = await SessionService.isLoggedIn();
      debugPrint("[Splash] Is Logged In: $isLoggedIn");

      if (!isLoggedIn) {
        debugPrint("[Splash] No session → Role Selection");
        context.go(RoleSelectionScreen.routeName);
        return;
      }

      final rememberMe = await SessionService.getRememberMe();
      debugPrint("[Splash] Remember Me: $rememberMe");

      if (!rememberMe) {
        debugPrint(
          "[Splash] Remember Me OFF → Clearing Session, Role Selection",
        );

        final oldUserId = await SessionService.getUserId();
        if (oldUserId != null) {
          try {
            await PresenceService.stop(oldUserId);
          } catch (_) {}
        }
        await SessionService.clearSession();
        context.go(RoleSelectionScreen.routeName);
        return;
      }

      final role = await SessionService.getUserRole();
      debugPrint("[Splash] Role: $role");

      if (role == 'admin') {
        context.go(DashboardScreen.routeName);
        return;
      }

      final userId = await SessionService.getUserId();
      debugPrint("[Splash] User ID: $userId");

      if (userId == null || userId.isEmpty) {
        await SessionService.clearSession();
        context.go(RoleSelectionScreen.routeName);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));

      final employee = EmployeeService.instance.getEmployeeById(userId);
      debugPrint("[Splash] Employee found: ${employee != null}");

      if (employee == null) {
        debugPrint("[Splash] Not in cache → reload attempt");

        final stillHasInternet = await _hasInternetConnection();
        if (!stillHasInternet) {
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _isRetrying = false;
          });
          return;
        }

        try {
          await EmployeeService.instance.init();
        } catch (e) {
          debugPrint("[Splash] Reload failed (network?): $e");
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _isRetrying = false;
          });
          return;
        }

        final retryEmployee = EmployeeService.instance.getEmployeeById(userId);

        if (retryEmployee == null) {
          debugPrint("[Splash] Confirmed not found → Clearing session");
          await SessionService.clearSession();
          context.go(RoleSelectionScreen.routeName);
          return;
        }

        try {
          await PresenceService.start(retryEmployee.employeeId);
        } catch (e) {
          debugPrint("[Splash] Presence start failed (non-fatal): $e");
        }

        context.goNamed(EmployeeShellScreen.routeName, extra: retryEmployee);
      } else {
        try {
          await PresenceService.start(employee.employeeId);
        } catch (e) {
          debugPrint("[Splash] Presence start failed (non-fatal): $e");
        }

        context.goNamed(EmployeeShellScreen.routeName, extra: employee);
      }
    } catch (e, stack) {
      debugPrint("[Splash] Error in session check: $e\n$stack");
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isRetrying = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DashboardBackground(
        child: _hasError ? _buildNoInternetView() : _buildSplashView(),
      ),
    );
  }

  Widget _buildSplashView() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png", height: 120),
                  const SizedBox(height: 25),
                  const Text(
                    "उदयपुरगढी गाउँपालिका",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Udayapurgadhi Rural Municipality",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 14, 72, 8),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Office Assistance System",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 5, 49, 13),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoInternetView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 90,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Internet जडान भेटिएन",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "कृपया Wi-Fi वा mobile data जडान गरेर फेरि प्रयास गर्नुहोस्",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isRetrying ? null : _initAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  "फेरि प्रयास गर्नुहोस्",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
