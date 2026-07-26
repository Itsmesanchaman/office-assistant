import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(employee.name.isNotEmpty ? employee.name[0] : "?"),
        ),
        title: Text(employee.name),
        subtitle: Text(
          "${employee.designation} • ${employee.department} • ${employee.room}"
          "${employee.mobileNo.isNotEmpty ? '\n${employee.mobileNo}' : ''}",
        ),
        isThreeLine: employee.mobileNo.isNotEmpty,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
