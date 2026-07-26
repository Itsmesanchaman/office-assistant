import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SessionWatchdogService {
  SessionWatchdogService._internal();
  static final SessionWatchdogService instance =
      SessionWatchdogService._internal();

  StreamSubscription? _sub;
  bool _triggered = false;


  void startWatching(String employeeId, VoidCallback onRemoved) {
    stopWatching();
    _triggered = false;

    _sub = Supabase.instance.client
        .from('employees')
        .stream(primaryKey: ['id']) 
        .eq('employee_id', employeeId)
        .listen((rows) {
          if (rows.isEmpty && !_triggered) {
            _triggered = true;
            onRemoved();
          }
        });
  }

  void stopWatching() {
    _sub?.cancel();
    _sub = null;
  }
}