import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

class NumberHelper {
  static const _nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];

  /// Converts any number/string to Nepali Devanagari digits if current 
  /// locale is Nepali, otherwise returns as-is (English digits)
  static String toLocalized(BuildContext context, dynamic number) {
    final text = number.toString();
    final isNepali = context.locale.languageCode == 'ne';

    if (!isNepali) return text;

    return text.split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? _nepaliDigits[digit] : char;
    }).join();
  }
}