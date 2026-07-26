import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/screens/auth/login_screen.dart';
import 'package:tmobile_app/screens/officer_dashboard.dart';
import 'models/employee.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/auth/employee_login_screen.dart';
import 'screens/employee_dashboard/employee_shell_screen.dart';
import 'services/supabase_config.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tmobile_app/services/presence_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'ring_again') {
    await NotificationService.handleRingAgain(message.data);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await Firebase.initializeApp();
  await NotificationService.init();

  String? initError;
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    initError = e.toString();
  }

  await PresenceService.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ne')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child:  MyApp(initError: initError),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? initError;
  MyApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _SupabaseSetupErrorScreen(error: initError!),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'officer Assistance',
      theme: ThemeData(
        primaryColor: const Color(0xFF1565C0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          secondary: const Color(0xFFFFA000),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F7FC),
        fontFamily: 'Roboto',
      ),
      routerConfig: _router,
    );
  }

  final _router = GoRouter(
    initialLocation: SplashScreen.routeName,
    routes: [
      GoRoute(
        name: SplashScreen.routeName,
        path: SplashScreen.routeName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: RoleSelectionScreen.routeName,
        path: RoleSelectionScreen.routeName,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        name: LoginScreen.routeName,
        path: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: EmployeeLoginScreen.routeName,
        path: EmployeeLoginScreen.routeName,
        builder: (context, state) => const EmployeeLoginScreen(),
      ),
      GoRoute(
        name: EmployeeShellScreen.routeName,
        path: EmployeeShellScreen.routeName,
        builder: (context, state) =>
            EmployeeShellScreen(employee: state.extra as Employee),
      ),
      GoRoute(
        name: DashboardScreen.routeName,
        path: DashboardScreen.routeName,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
}

class _SupabaseSetupErrorScreen extends StatelessWidget {
  final String error;
  const _SupabaseSetupErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cloud_off, size: 60, color: Color(0xFF1565C0)),
              const SizedBox(height: 20),
              const Text(
                "Supabase isn't configured yet",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
