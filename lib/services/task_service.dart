import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import '../models/task.dart';
import 'package:tmobile_app/services/session_service.dart';

/// One entry in the admin's activity feed: "X marked task Y as Z".
class ActivityEntry {
  final String taskId;
  final String employeeName;
  final String workType;
  final String status;
  final DateTime time;

  ActivityEntry({
    required this.taskId,
    required this.employeeName,
    required this.workType,
    required this.status,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
    'task_id': taskId,
    'employee_name': employeeName,
    'work_type': workType,
    'status': status,
    'time': time.toIso8601String(),
  };

  factory ActivityEntry.fromMap(Map<String, dynamic> map) => ActivityEntry(
    taskId: (map['task_id'] as String?) ?? '',
    employeeName: (map['employee_name'] as String?) ?? '',
    workType: (map['work_type'] as String?) ?? '',
    status: (map['status'] as String?) ?? '',
    time: DateTime.tryParse((map['time'] as String?) ?? '') ?? DateTime.now(),
  );
}

class TaskService extends ChangeNotifier {
  TaskService._internal();
  static final TaskService instance = TaskService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  List<Task> _tasks = [];
  List<ActivityEntry> _activityLog = [];

  StreamSubscription? _tasksSub;
  StreamSubscription? _logSub;
  bool _initialized = false;

  List<Task> get tasks => List.unmodifiable(_tasks.reversed);
  List<ActivityEntry> get activityLog =>
      List.unmodifiable(_activityLog.reversed);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _tasksSub = _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('assigned_at')
        .listen((rows) {
          _tasks = rows.map((row) => Task.fromMap(row)).toList();
          notifyListeners();
        });

    _logSub = _client
        .from('activity_log')
        .stream(primaryKey: ['id'])
        .order('time')
        .listen((rows) {
          _activityLog = rows.map((row) => ActivityEntry.fromMap(row)).toList();
          notifyListeners();
        });
  }

  Future<Task> assignTask({
    required Employee employee,
    required String workType,
    required TaskPriority priority,
    String note = "",
    dynamic assignedBy, // old parameter (if needed)
    String? assignedById, // ← New
    String? assignedByName,
  }) async {
    final adminId = assignedById ?? await SessionService.getUserId();
    final adminName =
        assignedByName ?? await SessionService.getUserName() ?? "Admin";

    final now = DateTime.now();
    final id =
        "TK${now.year % 100}${now.month.toString().padLeft(2, '0')}"
        "${now.millisecondsSinceEpoch % 1000000}";
    final task = Task(
      id: id,
      employee: employee,
      workType: workType,
      priority: priority,
      note: note,
      assignedBy: assignedBy,
      assignedById: adminId,
      assignedByName: adminName,
    );

    await _client.from('tasks').upsert(task.toMap());
    await _client
        .from('activity_log')
        .insert(
          ActivityEntry(
            taskId: task.id,
            employeeName: employee.name,
            workType: workType,
            status: "Assigned",
            time: DateTime.now(),
          ).toMap(),
        );

    _ringDevice();

    return task;
  }

  Future<void> ringAgain(Task task) async {
    await _client.functions.invoke(
      'notify-task',
      body: {
        'type': 'RING_AGAIN',
        'record': {
          'employee': {'employee_id': task.employee.employeeId},
          'work_type': task.workType,
          'priority': task.priority.labelTr,
        },
      },
    );
  }

  void _ringDevice() {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
  }

  /// Employee updates a task's status.
  Future<void> updateStatus(String taskId, String newStatus) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);

    await _client
        .from('tasks')
        .update({
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
          'seen_by_admin': false,
        })
        .eq('id', taskId);

    await _client
        .from('activity_log')
        .insert(
          ActivityEntry(
            taskId: task.id,
            employeeName: task.employee.name,
            workType: task.workType,
            status: newStatus,
            time: DateTime.now(),
          ).toMap(),
        );
  }

  Future<void> markSeenByEmployee(String employeeName) async {
    final ids = _tasks
        .where((t) => t.employee.name == employeeName && !t.seenByEmployee)
        .map((t) => t.id)
        .toList();
    if (ids.isEmpty) return;
    await _client
        .from('tasks')
        .update({'seen_by_employee': true})
        .inFilter('id', ids);
  }

  /// Clears the admin's "task updated" badge.
  Future<void> markAllSeenByAdmin() async {
    final ids = _tasks.where((t) => !t.seenByAdmin).map((t) => t.id).toList();
    if (ids.isEmpty) return;
    await _client
        .from('tasks')
        .update({'seen_by_admin': true})
        .inFilter('id', ids);
  }

  // ---------- Counters used by overview cards ----------

  int get totalTasks => _tasks.length;
  int get pendingCount =>
      _tasks.where((t) => t.status == TaskStatus.pending).length;
  int get busyCount => _tasks.where((t) => t.status == TaskStatus.busy).length;
  int get acceptedCount =>
      _tasks.where((t) => t.status == TaskStatus.accepted).length;
  int get doneCount => _tasks.where((t) => t.status == TaskStatus.done).length;

  /// Ringbell badge count for a given employee (unseen assigned tasks).
  int unseenForEmployee(String employeeName) => _tasks
      .where((t) => t.employee.name == employeeName && !t.seenByEmployee)
      .length;

  /// Admin's "task updates" badge count (status changes not yet reviewed).
  int get unseenForAdmin => _tasks.where((t) => !t.seenByAdmin).length;

  List<Task> tasksForEmployee(String employeeName) => _tasks
      .where((t) => t.employee.name == employeeName)
      .toList()
      .reversed
      .toList();

  // ---------- Reports: Daily / Monthly / Datewise / Taskwise ----------

  List<Task> reportForToday() {
    final now = DateTime.now();
    return _tasks
        .where(
          (t) =>
              t.assignedAt.year == now.year &&
              t.assignedAt.month == now.month &&
              t.assignedAt.day == now.day,
        )
        .toList()
        .reversed
        .toList();
  }

  List<Task> reportForMonth(int year, int month) {
    return _tasks
        .where((t) => t.assignedAt.year == year && t.assignedAt.month == month)
        .toList()
        .reversed
        .toList();
  }

  List<Task> reportForDate(DateTime date) {
    return _tasks
        .where(
          (t) =>
              t.assignedAt.year == date.year &&
              t.assignedAt.month == date.month &&
              t.assignedAt.day == date.day,
        )
        .toList()
        .reversed
        .toList();
  }

  Map<String, List<Task>> reportByTaskType() {
    final Map<String, List<Task>> grouped = {};
    for (final t in _tasks) {
      grouped.putIfAbsent(t.workType, () => []).add(t);
    }
    return grouped;
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    _logSub?.cancel();
    super.dispose();
  }
}
