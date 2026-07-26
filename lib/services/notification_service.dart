import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Task assign channel (naya sound)
 // Task assign channel (naya custom sound)
static const String _channelId = 'task_channel_v2';
static const String _channelName = 'Task Notifications';
static const String _channelDescription =
    'Task assigned notifications';

// Status update channel — admin le employee ko status update paudaa
// Custom sound specify nagarne → Android default system sound use huncha
static const String _statusUpdateChannelId = 'task_status_channel_default';
static const String _statusUpdateChannelName = 'Task Status Updates';
static const String _statusUpdateChannelDescription =
    'Employee task status update notifications';

  // Silent channel for ring again
  static const String _silentChannelId = 'task_channel_silent_02';
  static const String _silentChannelName = 'Task Reminders (Silent)';

  // Ring loop state
  static AudioPlayer? _ringPlayer;
  static bool _isLooping = false;
  static const int _ringNotificationId = 999;

  /// Initialize Notification Service
  static Future<void> init() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await _plugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.id == _ringNotificationId) {
        _stopRingLoop();
      }
    },
    onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
  );

  // Task assign / ring channel — naya custom sound
  const channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('task_ring'),
  );

  // Status update channel — sound field NAI nadine, Android default sound aafai use huncha
  const statusUpdateChannel = AndroidNotificationChannel(
    _statusUpdateChannelId,
    _statusUpdateChannelName,
    description: _statusUpdateChannelDescription,
    importance: Importance.max,
    playSound: true,
    // sound: (omit — default system sound)
  );

  // Silent channel for ring again
  const silentChannel = AndroidNotificationChannel(
    _silentChannelId,
    _silentChannelName,
    description: 'Ring again reminders — sound handled manually',
    importance: Importance.max,
    playSound: false,
  );

  final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _plugin.resolvePlatformSpecificImplementation
          <AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    await androidPlugin.createNotificationChannel(channel);
    await androidPlugin.createNotificationChannel(statusUpdateChannel);
    await androidPlugin.createNotificationChannel(silentChannel);
  }

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'ring_again') {
      handleRingAgain(message.data);
    } else {
      showNotification(
        title: message.notification?.title ?? 'New Task',
        body: message.notification?.body ?? '',
      );
    }
  });
}

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  /// Normal task notification (client-side triggered, foreground fallback)
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('task_ring'),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> handleRingAgain(Map<String, dynamic> data) async {
    debugPrint("🔔 handleRingAgain CALLED with data: $data");

    const silentDetails = AndroidNotificationDetails(
      _silentChannelId,
      _silentChannelName,
      channelDescription: 'Ring again reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      ongoing: true,
      autoCancel: false,
    );

    await _plugin.show(
      id: _ringNotificationId,
      title: data['title'] ?? '🔔 Reminder',
      body: data['body'] ?? 'Task pending',
      notificationDetails: const NotificationDetails(android: silentDetails),
    );

    debugPrint("🔔 Notification shown, starting ring loop...");
    await _playRingLoop(times: 4);
  }

  static Future<void> _playRingLoop({int times = 4}) async {
    if (_isLooping) {
      debugPrint("⚠️ Already looping, skipping new loop");
      return;
    }

    _isLooping = true;
    _ringPlayer?.dispose();
    _ringPlayer = AudioPlayer();

    for (int i = 0; i < times; i++) {
      if (!_isLooping) {
        debugPrint("⛔ Loop stopped by user tap");
        break;
      }

      debugPrint("🔊 Playing ring ${i + 1}/$times");
      try {
        await _ringPlayer!.play(AssetSource('sounds/task_ring.mp3'));
        debugPrint("✅ Ring ${i + 1} played successfully");
      } catch (e) {
        debugPrint("❌ AudioPlayer error: $e");
      }

      await Future.delayed(const Duration(milliseconds: 1800));
    }

    _isLooping = false;
    debugPrint("🔔 Ring loop finished");
  }

  static void _stopRingLoop() {
    _isLooping = false;
    _ringPlayer?.stop();
    debugPrint("🛑 Ring stopped by user tap");
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    if (response.id == _ringNotificationId) {
      _stopRingLoop();
    }
  }
}
