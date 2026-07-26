class Employee {
  String name;
  String department;
  String designation;
  String mobileNo;
  String email;
  String password;
  String room;
  final String employeeId;
  final String? status;
  final bool? isOnline;
  final DateTime? lastSeen;

  Employee({
    required this.name,
    required this.designation,
    required this.room,
    required this.employeeId,
    this.department = "General",
    this.mobileNo = "",
    this.email = "",
    this.password = "",
    this.status,
    this.isOnline,
    this.lastSeen,
  });

  /// Supabase/Postgres uses snake_case column names.
  Map<String, dynamic> toMap() => {
    'employee_id': employeeId,
    'name': name,
    'department': department,
    'designation': designation,
    'mobile_no': mobileNo,
    'email': email,
    'password': password,
    'room': room,
  };

  factory Employee.fromMap(Map<String, dynamic> map) => Employee(
    employeeId: (map['employee_id'] as String?) ?? '',
    name: (map['name'] as String?) ?? '',
    department: (map['department'] as String?) ?? 'General',
    designation: (map['designation'] as String?) ?? '',
    mobileNo: (map['mobile_no'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    password: (map['password'] as String?) ?? '',
    room: (map['room'] as String?) ?? '',
    status: map['status'],
    isOnline: map['is_online'] as bool?,
    lastSeen: map['last_seen'] != null
        ? DateTime.tryParse(map['last_seen'] as String)
        : null,
  );

  bool get isEffectiveOffline {
    if (lastSeen == null) return true;
    return DateTime.now().toUtc().difference(lastSeen!.toUtc()).inMinutes > 3;
  }
}
