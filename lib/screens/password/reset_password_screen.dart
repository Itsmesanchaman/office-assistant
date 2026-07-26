import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/screens/auth/login_screen.dart';
import '../constants/app_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newPassword = passwordController.text.trim();

      await _supabase
          .from('admins')
          .update({'password': newPassword})
          .eq('email', widget.email);

      if (!mounted) return;

      _showMessage("Your password has been changed", isError: false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage("Something went wrong. Please try again.");
      debugPrint("Reset password error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Reset Password"),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
        
            child: Card(
              elevation: 4,
        
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
        
              child: Padding(
                padding: const EdgeInsets.all(20),
        
                child: Form(
                  key: _formKey,
        
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: AppColors.primary,
                      ),
        
                      const SizedBox(height: 20),
        
                      const Text(
                        "Create New Password",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
        
                      const SizedBox(height: 8),
        
                      Text(
                        widget.email,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
        
                      const SizedBox(height: 20),
        
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        enabled: !_isLoading,
        
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter password";
                          }
        
                          if (value.length < 6) {
                            return "Minimum 6 characters";
                          }
        
                          return null;
                        },
        
                        decoration: InputDecoration(
                          labelText: "New Password",
        
                          prefixIcon: const Icon(Icons.lock),
        
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
        
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 16),
        
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        enabled: !_isLoading,
        
                        validator: (value) {
                          if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
        
                          return null;
                        },
        
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
        
                          prefixIcon: const Icon(Icons.lock),
        
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
        
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 24),
        
                      SizedBox(
                        width: double.infinity,
                        height: 50,
        
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
        
                          onPressed: _isLoading ? null : _updatePassword,
        
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Update Password",
                                  style: TextStyle(fontSize: 16,
                                  color: Colors.white
                                  ),
                                ),
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
    );
  }
}