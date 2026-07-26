import 'package:flutter/material.dart';

class AppColors {
  // Single unified blue theme across the whole app (splash, login, and dashboard)
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color background = Color(0xFFF3F7FC);
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF0B2540);
  static const Color muted = Color(0xFF6B7A8A);

  static const Color success = Color(0xFF1FA18A);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFE03E3E);

  // These used to be a separate green theme for splash/login; now point to
  // the same blue palette so the whole app is visually consistent.
  static const Color primary_login = Color(0xFF1565C0);
  static const Color primaryDark_login = Color(0xFF0D47A1);

  static const Color secondary = Color(0xFF42A5F5); // Lighter blue accent

  static const Color accent = Color(
    0xFFFFA000,
  ); // Amber, pairs with the blue theme

  static const Color nepalRed = Color(0xFFC62828);

  static const Color background_login = Color(0xFFF3F7FC);

  static const Color card = Colors.white;

  static const Color textDark = Color(0xFF263238);

  static const Color textLight = Color(0xFF757575);

  static const Color border = Color(0xFFE0E0E0);

  static const Color notification = Color(0xFFE53935);
}
