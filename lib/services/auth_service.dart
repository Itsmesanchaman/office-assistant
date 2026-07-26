import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import 'notification_service.dart';
import 'session_service.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static bool get isLoggedIn => _isLoggedIn;

  static SupabaseClient get _client => Supabase.instance.client;

  /// Login admin using email and password - validates against admins table
  static Future<Map<String, dynamic>?> loginAdmin(
    String email,
    String password,
  ) async {
    final result = await _client
        .from('admins')
        .select()
        .eq('email', email.trim())
        .eq('password', password.trim())
        .maybeSingle();

    if (result != null) {
      _isLoggedIn = true;

      final fcmToken = await NotificationService.getToken();
      if (fcmToken != null) {
        await _client
            .from('admins')
            .update({'fcm_token': fcmToken})
            .eq('email', email.trim());
      }

      return result; // admin ko full data return garne
    }
    return null;
  }

  /// Login employee using mobile number
  static Future<Employee?> loginEmployee(String mobileNo) async {
    try {
      final response = await _client
          .from('employees')
          .select()
          .eq('mobile_no', mobileNo)
          .maybeSingle();

      if (response != null) {
        final fcmToken = await NotificationService.getToken();
        if (fcmToken != null) {
          await _client
              .from('employees')
              .update({'fcm_token': fcmToken})
              .eq('mobile_no', mobileNo);
        }

        _isLoggedIn = true;
        return Employee.fromMap(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sign out current user - clears local session + FCM token from DB
  static Future<void> signOut({
    required String userId,
    required String role, // 'admin' or 'employee'
  }) async {
    try {
      final table = role == 'admin' ? 'admins' : 'employees';
      final idColumn = role == 'admin' ? 'id' : 'id'; // dubai table ma 'id' bhaye theek

      await _client.from(table).update({'fcm_token': null}).eq(idColumn, userId);
    } catch (e) {
      print('FCM token clear error: $e');
      // fail vaye pani logout continue garne
    }

    await SessionService.clearSession();
    _isLoggedIn = false;
  }

  /// Get current user
  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _isLoggedIn;
  }
}