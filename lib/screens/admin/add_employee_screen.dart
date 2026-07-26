import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../services/employee_service.dart';
import 'package:easy_localization/easy_localization.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    departmentController.dispose();
    designationController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    roomController.dispose();
    super.dispose();
  }

  bool _saving = false;

  Future<void> saveEmployee() async {
    if (nameController.text.trim().isEmpty ||
        designationController.text.trim().isEmpty ||
        roomController.text.trim().isEmpty ||
        mobileController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
            "fill_required_fields").tr()
          ),
      );
      return;
    }

    final employee = Employee(
      employeeId: EmployeeService.instance.nextEmployeeId(),
      name: nameController.text.trim(),
      department: departmentController.text.trim().isEmpty
          ? "General"
          : departmentController.text.trim(),
      designation: designationController.text.trim(),
      mobileNo: mobileController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      room: roomController.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await EmployeeService.instance.addEmployee(employee);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("could_not_save_employee".tr(namedArgs: {'error': e.toString()}))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("add_employee").tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration:  InputDecoration(
                  labelText: "employee_name".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: departmentController,
                decoration:  InputDecoration(
                  labelText: "department".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: designationController,
                decoration:  InputDecoration(
                  labelText: "designation".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: roomController,
                decoration:  InputDecoration(
                  labelText: "room_number".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "login_credentials".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration:  InputDecoration(
                  labelText: "mobile_no_login".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:  InputDecoration(
                  labelText: "email_optional".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "password".tr(),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _saving ? null : saveEmployee,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      :  Text(
                          "add_employee".tr(),
                          style: TextStyle(color: Colors.white),
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
