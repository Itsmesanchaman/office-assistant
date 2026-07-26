bool isEmployeeOnline(DateTime? lastSeen, {int thresholdSeconds = 60}) {
  if (lastSeen == null) return false;
  final diff = DateTime.now().toUtc().difference(lastSeen.toUtc());
  return diff.inSeconds <= thresholdSeconds;
}