import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class EmployeePopup extends StatelessWidget {
  final String name;

  const EmployeePopup({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 35, child: Icon(Icons.person, size: 40)),

            const SizedBox(height: 10),

            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.notifications),
                label: const Text("Send Notification"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
