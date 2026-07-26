import 'package:flutter/material.dart';
import '../../models/employee.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tmobile_app/services/session_service.dart';
import 'package:easy_localization/easy_localization.dart';



class EmployeeMessagePopup extends StatefulWidget {
  final Employee employee;
  final String assignedBy;

  const EmployeeMessagePopup({
    super.key,
    required this.employee,
    this.assignedBy = "Admin",
  });

  @override
  State<EmployeeMessagePopup> createState() => _EmployeeMessagePopupState();
}

class _EmployeeMessagePopupState extends State<EmployeeMessagePopup> {
  final TextEditingController customWorkController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool _isAssigning = false;
  bool _isRinging = false;

  final List<String> presetWorkTypes = [
    "Bring File",
    "Prepare Tea",
    "Cleaning",
    "Urgent Meeting",
    "Come Now",
  ];

  String? selectedWorkType;
  TaskPriority selectedPriority = TaskPriority.normal;

  @override
  void dispose() {
    customWorkController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Color priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.veryUrgent:
        return Colors.red.shade700;
      case TaskPriority.urgent:
        return Colors.orange.shade700;
      case TaskPriority.normal:
        return Colors.blue.shade600;
    }
  }

  Task? get _pendingTask {
    final tasks = TaskService.instance.tasksForEmployee(widget.employee.name);
    for (final t in tasks) {
      if (!t.seenByEmployee) return t;
    }
    return null;
  }

  Future<void> assignTask() async {
    if (_isAssigning) return;

    final workType = (selectedWorkType == "custom")
        ? customWorkController.text.trim()
        : selectedWorkType;

    if (workType == null || workType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("please_choose_work_type").tr()),
      );
      return;
    }

    setState(() => _isAssigning = true);

    try {
      final adminName = await SessionService.getUserName();
      final adminId = await SessionService.getUserId();

      await TaskService.instance.assignTask(
        employee: widget.employee,
        workType: workType,
        priority: selectedPriority,
        note: noteController.text.trim(),
        assignedBy: widget.assignedBy,
        assignedById: adminId, // ← New
        assignedByName: adminName,
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "task_assigned_success".tr(namedArgs: {
              'workType': workType,
              'employee': widget.employee.name,
            }),
          ),
        ),
      );
    } catch (e) {
      debugPrint("assignTask FAILED for ${widget.employee.name}: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("failed_to_assign_task".tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  Future<void> ringAgain(Task task) async {
    if (_isRinging) return;
    setState(() => _isRinging = true);

    try {
      await TaskService.instance.ringAgain(task);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ring_again_success".tr(namedArgs: {
              'employee': widget.employee.name,
              'workType': task.workType,
            }),
          ),
        ),
      );
    } catch (e) {
      debugPrint("ringAgain FAILED for ${widget.employee.name}: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("failed_to_ring".tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) setState(() => _isRinging = false);
    }
  }

  Future<void> _ringEmployeeOnly() async {
    if (_isRinging) return; // guard duplicate taps
    setState(() => _isRinging = true);
    try {
      // ✅ Logged-in admin ko naam nikaalne
      final adminName = await SessionService.getUserName() ?? "Admin";

      await Supabase.instance.client.functions.invoke(
        'notify-task',
        body: {
          'employee_id': widget.employee.employeeId,
          'type': 'ring_only',
          'title': '🔔 $adminName is calling you', // ✅ dynamic admin name
          'body': 'Please come to the office now',
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ring_success".tr(namedArgs: {'name': widget.employee.name})),
        ),
      );
    } catch (e) {
      debugPrint("[Ring] Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("failed_to_ring_connection").tr()),
      );
    } finally {
      if (mounted) setState(() => _isRinging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TaskService.instance,
      builder: (context, _) {
        final pending = _pendingTask;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER (same for both cases)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            widget.employee.name.isNotEmpty
                                ? widget.employee.name[0]
                                : "?",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.employee.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.employee.designation} • ${widget.employee.department}",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              Text(
                                widget.employee.room,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (pending != null)
                    ..._buildPendingSection(pending)
                  else
                    ..._buildAssignFormSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shown when the employee already has an unseen task pending.
  List<Widget> _buildPendingSection(Task task) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  "waiting_for_response".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              task.workType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
                "priority_label".tr(namedArgs: {'priority': task.priority.labelTr}),
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (task.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(task.note, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _isRinging ? null : () => ringAgain(task),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.notifications_active, color: Colors.white),
          label: Text(
            _isRinging ? "ringing...".tr() : "ring_again".tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }

  /// Shown when there's no pending task — normal assign form.
  List<Widget> _buildAssignFormSection() {
    return [
      Text(
        "work_type".tr(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          buildWorkCard(
            image: "assets/images/folder.png",
            title: "bring_file".tr(),
            selected: selectedWorkType == "Bring File",
            onTap: () => setState(() => selectedWorkType = "Bring File"),
          ),
          buildWorkCard(
            image: "assets/images/tea.png",
            title: "prepare_tea".tr(),
            selected: selectedWorkType == "Prepare Tea",
            onTap: () => setState(() => selectedWorkType = "Prepare Tea"),
          ),
          buildWorkCard(
            image: "assets/images/cleaning.png",
            title: "cleaning".tr(),
            selected: selectedWorkType == "Cleaning",
            onTap: () => setState(() => selectedWorkType = "Cleaning"),
          ),
          buildWorkCard(
            image: "assets/images/meetingg.png",
            title: "urgent_meeting".tr(),
            selected: selectedWorkType == "Urgent Meeting",
            onTap: () => setState(() => selectedWorkType = "Urgent Meeting"),
          ),
          buildWorkCard(
            image: "assets/images/manrun.png",
            title: "come_now".tr(),
            selected: selectedWorkType == "Come Now",
            onTap: () => setState(() => selectedWorkType = "Come Now"),
          ),
        ],
      ),
      if (selectedWorkType == "custom") ...[
        const SizedBox(height: 12),
        TextField(
          controller: customWorkController,
          decoration: InputDecoration(
            hintText: "type_work_here".tr(),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
      const SizedBox(height: 22),
      Text(
        "priority".tr(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        children: TaskPriority.values.map((p) {
          final isSelected = selectedPriority == p;
          return ChoiceChip(
            label: Text(p.labelTr),
            selected: isSelected,
            selectedColor: priorityColor(p).withOpacity(.2),
            labelStyle: TextStyle(
              color: isSelected ? priorityColor(p) : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => setState(() => selectedPriority = p),
          );
        }).toList(),
      ),
      const SizedBox(height: 22),
      Text(
        "note_optional".tr(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: noteController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "extra_detail_hint".tr(),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 22),
      SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _isAssigning ? null : assignTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.notifications_active, color: Colors.white),
          label:  Text(
            "assign_task".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton.icon(
          onPressed: _isRinging ? null : _ringEmployeeOnly,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: _isRinging
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Icon(Icons.notifications_none, color: AppColors.primary),
          label: Text(
            _isRinging ? "ringing...".tr() : "just_ring".tr(namedArgs: {'name': widget.employee.name}),
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }

  Widget buildWorkCard({
    required String image,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 95,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(image, width: 42, height: 42),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
