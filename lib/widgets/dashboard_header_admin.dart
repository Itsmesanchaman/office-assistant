import 'package:flutter/material.dart';

class DashboardHeaderAdmin extends StatelessWidget {
  const DashboardHeaderAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: const [
        Text(
          "Good Morning 👋",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 4),

        Text("Officer Dashboard", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
