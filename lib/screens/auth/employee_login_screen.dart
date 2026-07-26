import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmobile_app/widgets/dashboard_background.dart';
import '../constants/app_colors.dart';
import '../../services/employee_service.dart';
import '../employee_dashboard/employee_shell_screen.dart';
import 'package:tmobile_app/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/services/session_service.dart';
import 'package:tmobile_app/services/presence_service.dart';

class EmployeeLoginScreen extends StatefulWidget {
  static const String routeName = "/employee-login";
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  bool _rememberMe = false;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    final employee = await EmployeeService.instance.login(
      _mobileController.text.trim(),
      _passwordController.text.trim(),
    );

    if (employee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid mobile number or password")),
      );
      return;
    }

    await SessionService.saveSession(
      userId: employee.employeeId,
      role: 'employee',
      name: employee.name,
      rememberMe: _rememberMe
    );

    await PresenceService.start(employee.employeeId);
    // ✅ FCM token nikalne ra Supabase ma save garne
    try {
      final token = await NotificationService.getToken();
      print("FCM TOKEN: $token"); // debug ko lagi, pachi hatauna sakinxa

      if (token != null) {
        await Supabase.instance.client
            .from('employees')
            .update({'fcm_token': token})
            .eq('employee_id', employee.employeeId);
      }
    } catch (e) {
      print("ERROR saving FCM token: $e");
    }

    if (context.mounted) {
      context.go(EmployeeShellScreen.routeName, extra: employee);
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          color: const Color.fromARGB(
                            255,
                            235,
                            237,
                            235,
                          ).withOpacity(0.5),
                          elevation: 20,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Welcome Back!",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Please login to continue",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _mobileController,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Please enter your mobile number";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Mobile Number",
                                        prefixIcon: const Icon(Icons.phone),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter your password";
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),


                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _rememberMe = !_rememberMe;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Remember Me",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.primary_login,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: login,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.login,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  Text(
                                    "Ask your Admin if you don't know your login details.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
