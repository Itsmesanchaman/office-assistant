import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../services/employee_service.dart';

class EditEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  late TextEditingController nameController;
  late TextEditingController departmentController;
  late TextEditingController designationController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController roomController;
  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employee.name);
    departmentController = TextEditingController(
      text: widget.employee.department,
    );
    designationController = TextEditingController(
      text: widget.employee.designation,
    );
    mobileController = TextEditingController(text: widget.employee.mobileNo);
    emailController = TextEditingController(text: widget.employee.email);
    passwordController = TextEditingController(text: widget.employee.password);
    roomController = TextEditingController(text: widget.employee.room);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Edit Employee"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Employee Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: designationController,
                decoration: const InputDecoration(
                  labelText: "Designation",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(
                  labelText: "Room Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Login credentials",
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
                decoration: const InputDecoration(
                  labelText: "Mobile No",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _saving
                      ? null
                      : () async {
                          widget.employee.name = nameController.text.trim();
                          widget.employee.department = departmentController.text
                              .trim();
                          widget.employee.designation = designationController
                              .text
                              .trim();
                          widget.employee.mobileNo = mobileController.text
                              .trim();
                          widget.employee.email = emailController.text.trim();
                          widget.employee.password = passwordController.text
                              .trim();
                          widget.employee.room = roomController.text.trim();

                          setState(() => _saving = true);
                          try {
                            await EmployeeService.instance.updateEmployee(
                              widget.employee,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _saving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Could not update employee: $e"),
                              ),
                            );
                          }
                        },
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Update",
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
