import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

import 'package:tmobile_app/services/supabase_config.dart';

class PresenceService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'presence_channel',
      'Presence Tracking',
      description: 'Tracks online/Offline status',
      importance: Importance.low,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'presence_channel',
        initialNotificationTitle: 'Office Assistant',
        initialNotificationContent: 'Tracking online status',
        foregroundServiceNotificationId: 999,
      ),
      iosConfiguration: IosConfiguration(),
    );
  }

  /// Login success vayepachi call garne
  static Future<void> start(String employeeId) async {
    // ✅ SharedPreferences ma save garne — event race हुँदैन
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('presence_employee_id', employeeId);


    String? deviceDebugId = prefs.getString('device_debug_id');
    if (deviceDebugId == null) {
      deviceDebugId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('device_debug_id', deviceDebugId);
    }

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) service.startService();
  }

  /// Logout garda call garne
  static Future<void> stop(String employeeId) async {
    try {
      await Supabase.instance.client
          .from('employees')
          .update({'last_seen': DateTime.now().toUtc().toIso8601String()})
          .eq('employee_id', employeeId);
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('presence_employee_id');

    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  Future<void> updateHeartbeat() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString('presence_employee_id');
    final deviceDebugId = prefs.getString('device_debug_id') ?? 'unknown';

    print('🔄 Heartbeat check, employeeId: $employeeId, device: $deviceDebugId');
    if (employeeId == null) return;

    try {
      await Supabase.instance.client
          .from('employees')
          .update({'last_seen': DateTime.now().toUtc().toIso8601String(),
          'last_seen_device': deviceDebugId,
          })
          .eq('employee_id', employeeId);
      print('✅ Heartbeat from device: $deviceDebugId');
    } catch (e) {
      print('❌ Heartbeat error: $e');
    }
  }

  await updateHeartbeat();

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    await updateHeartbeat();
  });
}
