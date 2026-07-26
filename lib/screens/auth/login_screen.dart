import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmobile_app/screens/officer_dashboard.dart';
import 'package:tmobile_app/widgets/dashboard_background.dart';
import '../../services/auth_service.dart';
import '../constants/app_colors.dart';
import 'forgot_password_screen.dart';
import 'package:tmobile_app/services/session_service.dart';
import 'package:tmobile_app/services/presence_service.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/login";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errMsg = " ";

  bool _obscurePassword = true;

  bool _rememberMee = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final adminData = await AuthService.loginAdmin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (adminData == null) {
        throw Exception('Invalid email or password');
      }

      // Session save
      await SessionService.saveSession(
        userId: adminData['id'].toString(),
        role: 'admin',
        name: adminData['name'],
        rememberMe: _rememberMee
      );

      await PresenceService.start(adminData['id'].toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
          duration: Duration(seconds: 1),
        ),
      );

      context.go(DashboardScreen.routeName);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
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
                          color: Color.fromARGB(
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
                                    "उदयपुरगढी गाउँपालिका",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  const Text(
                                    "Office Management System",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.primary_login,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Please enter your email";
                                        }

                                        if (!value.contains('@')) {
                                          return "Enter a valid email";
                                        }

                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        prefixIcon: const Icon(Icons.email),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  //Password
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter your password";
                                        }

                                        if (value.length < 6) {
                                          return "Password must be at least 6 characters";
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
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
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
                                        _rememberMee = !_rememberMee;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMee,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMee = value ?? false;
                                            });
                                          },
                                        ),
                                        const Text(
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
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text("Forgot password?"),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
