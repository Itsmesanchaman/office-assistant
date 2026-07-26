import 'package:flutter/material.dart';

enum EmployeeStatus { available, onLeave, busy }

extension EmployeeStatusX on EmployeeStatus {
  String get value => switch (this) {
        EmployeeStatus.available => 'available',
        EmployeeStatus.onLeave => 'on_leave',
        EmployeeStatus.busy => 'busy',
      };

  // Translation key return garne
  String get label => switch (this) {
        EmployeeStatus.available => 'available',
        EmployeeStatus.onLeave => 'on_leave',
        EmployeeStatus.busy => 'busy',
      };

  Color get color => switch (this) {
        EmployeeStatus.available => Colors.green,
        EmployeeStatus.onLeave => Colors.orange,
        EmployeeStatus.busy => Colors.red,
      };
}