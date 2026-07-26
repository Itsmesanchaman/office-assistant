import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class EmployeeService extends ChangeNotifier {
  EmployeeService._internal();
  static final EmployeeService instance = EmployeeService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  List<Employee> _employees = [];
  bool _isTestAccount = false;
  List<Employee> get employees => List.unmodifiable(_employees);

  StreamSubscription? _subscription;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Load initial data
    await _loadEmployees();

    // Realtime Subscription for live updates (especially status changes)
    _subscription = _client
        .from('employees')
        .stream(primaryKey: ['employee_id'])
        .listen(
          (rows) {
            _employees = rows.map((row) => Employee.fromMap(row)).toList()
              ..sort((a, b) => a.employeeId.compareTo(b.employeeId));

            notifyListeners(); // This will refresh all listening UIs (EmployeeCard, etc.)
          },
          onError: (error) {
            debugPrint("Realtime subscription error: $error");
          },
        );
  }

  Future<void> _loadEmployees() async {
    try {
      final existing = await _client.from('employees').select();

      _employees =
          (existing as List).map((row) => Employee.fromMap(row)).toList()
            ..sort((a, b) => a.employeeId.compareTo(b.employeeId));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading employees: $e");
    }
  }

  String nextEmployeeId() {
    int n = _employees.length + 1;
    String id = "EMP${n.toString().padLeft(3, '0')}";
    while (_employees.any((e) => e.employeeId == id)) {
      n++;
      id = "EMP${n.toString().padLeft(3, '0')}";
    }
    return id;
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      final employeeMap = employee.toMap();
      employeeMap['is_test_data'] = _isTestAccount;

      await _client.from('employees').upsert(employee.toMap());
    } catch (e) {
      debugPrint('ERROR adding employee: $e');
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    await _client.from('employees').upsert(employee.toMap());
  }

  Future<void> removeEmployee(Employee employee) async {
    await _client
        .from('employees')
        .delete()
        .eq('employee_id', employee.employeeId);
  }

  Future<Employee?> login(String mobileNo, String password) async {
    try {
      final res = await _client.functions.invoke(
        'login_employee',
        body: {'mobile_no': mobileNo.trim(), 'password': password},
      );

      dynamic body = res.data;
      if (body is String) {
        body = jsonDecode(body);
      }

      if (body['employee'] != null) {
        return Employee.fromMap(Map<String, dynamic>.from(body['employee']));
      }
      return null;
    } catch (e) {
      debugPrint("Login ERROR: $e");
      return null;
    }
  }

  Employee? getEmployeeById(String employeeId) {
    try {
      return _employees.firstWhere((e) => e.employeeId == employeeId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
