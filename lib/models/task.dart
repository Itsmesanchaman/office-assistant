import '../models/employee.dart';
import 'package:easy_localization/easy_localization.dart';

enum TaskPriority { normal, urgent, veryUrgent }


extension TaskPriorityLabel on TaskPriority {
  String get labelKey {
    switch (this) {
      case TaskPriority.normal:
        return "priority_normal";
      case TaskPriority.urgent:
        return "priority_urgent";
      case TaskPriority.veryUrgent:
        return "priority_very_urgent";
    }
  }

  String get labelTr => labelKey.tr();   // ← label.tr() होइन, labelKey.tr()

  String get name => toString().split('.').last;

  static TaskPriority fromString(String? value) {
    if (value == null || value.isEmpty) return TaskPriority.normal;

    final input = value.trim().toLowerCase();

    if (input.contains("very") || input == "veryurgent" || input == "very_urgent") {
      return TaskPriority.veryUrgent;
    } else if (input == "urgent") {
      return TaskPriority.urgent;
    } else {
      return TaskPriority.normal;
    }
  }
}

class TaskStatus {
  static const String pending = "Pending";
  static const String accepted = "Accept";
  static const String busy = "Busy";
  static const String done = "Done";

  static const List<String> all = [pending, accepted, busy, done];

   static String labelKey(String status) {
    switch (status.trim().toLowerCase()) {
      case "pending":
        return "pending";
      case "accept":
      case "accepted":
        return "accepted";
      case "busy":
        return "busy";
      case "done":
        return "done";
      default:
        return status;
    }
  }

  static String labelTr(String status) => labelKey(status).tr();
}

class WorkType {
  static String labelKey(String workType) {
    switch (workType.trim().toLowerCase()) {
      case "bring file":
        return "bring_file";

      case "prepare tea":
        return "prepare_tea";

      case "cleaning":
        return "cleaning";

      case "urgent meeting":
        return "urgent_meeting";

      case "come now":
        return "come_now";

      default:
        return workType;
    }
  }

  static String labelTr(String workType) =>
      labelKey(workType).tr();
}

class Task {
  final String id;
  final Employee employee;
  String workType;
  TaskPriority priority;
  String status;
  String note;
  final String assignedBy;
  final DateTime assignedAt;
  DateTime updatedAt;
  final String? assignedById;
  final String? assignedByName;

  bool seenByEmployee;
  bool seenByAdmin;

  Task({
    required this.id,
    required this.employee,
    required this.workType,
    required this.priority,
    this.status = TaskStatus.pending,
    this.note = "",
    this.assignedBy = "Admin",
    DateTime? assignedAt,
    DateTime? updatedAt,
    this.assignedById,
    this.assignedByName,
    this.seenByEmployee = false,
    this.seenByAdmin = true,
  })  : assignedAt = assignedAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'employee': employee.toMap(),
        'work_type': workType,
        'priority': priority.name,           // ← important
        'status': status,
        'note': note,
        'assigned_by': assignedBy,
        'assigned_at': assignedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'seen_by_employee': seenByEmployee,
        'seen_by_admin': seenByAdmin,
        'assigned_by_id': assignedById,
        'assigned_by_name': assignedByName,
      };

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      employee: Employee.fromMap(Map<String, dynamic>.from(map['employee'] as Map)),
      workType: (map['work_type'] as String?) ?? '',
      priority: TaskPriorityLabel.fromString(map['priority'] as String?),
      status: (map['status'] as String?) ?? TaskStatus.pending,
      note: (map['note'] as String?) ?? '',
      assignedBy: (map['assigned_by'] as String?) ?? 'Admin',
      assignedAt: DateTime.tryParse(map['assigned_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
      seenByEmployee: (map['seen_by_employee'] as bool?) ?? false,
      seenByAdmin: (map['seen_by_admin'] as bool?) ?? true,
      assignedById: map['assigned_by_id'] as String?,
      assignedByName: map['assigned_by_name'] as String?,
    );
  }
}