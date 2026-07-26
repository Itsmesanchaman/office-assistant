import 'package:flutter/material.dart';
import 'package:tmobile_app/screens/dashboard/message_pop.dart';
import '../constants/app_colors.dart';
import '../../models/employee.dart';
import '../../services/task_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tmobile_app/utils/number_helper.dart';
import 'package:tmobile_app/screens/constants/app_enum.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;

  const EmployeeCard({super.key, required this.employee});

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final badgeCount = TaskService.instance.unseenForEmployee(
          widget.employee.name,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),

                // Employee Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employee.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Designation + Department
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${"designation".tr()}: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: widget.employee.designation),
                            const TextSpan(text: "   •   "),
                            TextSpan(
                              text: "${"department".tr()}: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(text: widget.employee.department),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (widget.employee.room.isNotEmpty ||
                          widget.employee.mobileNo.isNotEmpty)
                        Row(
                          children: [
                            if (widget.employee.room.isNotEmpty)
                              Text(widget.employee.room),
                            if (widget.employee.room.isNotEmpty &&
                                widget.employee.mobileNo.isNotEmpty)
                              const Text("   •   "),
                            if (widget.employee.mobileNo.isNotEmpty)
                              Text(widget.employee.mobileNo),
                          ],
                        ),
                    ],
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bell Icon with Nepali Number Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications,
                            color: const Color.fromARGB(255, 95, 122, 153),
                            size: 30,
                          ),
                          onPressed: () {
                            if (widget.employee.isEffectiveOffline) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.wifi_off,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text("employee_offline".tr()),
                                    ],
                                  ),
                                  content: Text(
                                    "employee_offline_cannot_assign".tr(
                                      namedArgs: {"name": widget.employee.name},
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("ok".tr()),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              builder: (_) => EmployeeMessagePopup(
                                employee: widget.employee,
                              ),
                            );
                          },
                        ),
                        if (badgeCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                NumberHelper.toLocalized(
                                  context,
                                  badgeCount,
                                ), // ← Nepali Number
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Small Status Indicator
                    _buildSmallStatusIndicator(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallStatusIndicator() {
  final bool offline = widget.employee.isEffectiveOffline;

  
  final String label;
  final Color color;

  if (offline) {
    label = "offline".tr();
    color = Colors.grey;
  } else {
    final statusEnum = EmployeeStatus.values.firstWhere(
      (s) => s.value == widget.employee.status,
      orElse: () => EmployeeStatus.available,
    );
    label = statusEnum.label.tr();
    color = statusEnum.color;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}
}
