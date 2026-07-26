import 'package:flutter/material.dart';

class EmployeeTaskCard extends StatelessWidget {
  final String title;
  final String assignedBy;
  final String status;
  final IconData icon;

  const EmployeeTaskCard({
    super.key,
    required this.title,
    required this.assignedBy,
    required this.status,
    required this.icon,
  });

  Color getStatusColor() {
    switch (status) {
      case "Pending":
        return Colors.orange;

      case "On The Way":
        return Colors.blue;

      case "Completed":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text("Assigned by: $assignedBy"),

        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

          decoration: BoxDecoration(
            color: getStatusColor().withOpacity(.15),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Text(
            status,
            style: TextStyle(
              color: getStatusColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
