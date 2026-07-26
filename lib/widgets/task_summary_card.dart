import 'package:flutter/material.dart';

class TaskSummaryCard extends StatelessWidget {
  const TaskSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            buildSummaryRow(
              Icons.check_circle,
              Colors.green,
              "Completed",
              "120",
            ),

            const Divider(),

            buildSummaryRow(Icons.pending, Colors.orange, "Pending", "15"),

            const Divider(),

            buildSummaryRow(
              Icons.directions_walk,
              Colors.blue,
              "On The Way",
              "7",
            ),

            const Divider(),

            buildSummaryRow(Icons.cancel, Colors.red, "Busy", "3"),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryRow(
    IconData icon,
    Color color,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Icon(icon, color: color),

      title: Text(title),

      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
