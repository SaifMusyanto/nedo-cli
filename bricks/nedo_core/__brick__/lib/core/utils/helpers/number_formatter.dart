import 'package:intl/intl.dart';

/// Utility class for formatting numbers, currency, and percentages
///
/// Example:
/// ```dart
/// final formatted = NumberFormatter.currency(10000); // Rp 10.000
/// final compact = NumberFormatter.compact(1500000); // 1.5M
/// ```
class NumberFormatter {
  NumberFormatter._();

  /// Format number as Indonesian Rupiah currency
  ///
  /// [amount] - The amount to format
  /// [symbol] - Currency symbol (default: 'Rp ')
  /// [decimalDigits] - Number of decimal places (default: 0)
  static String currency(
    num amount, {
    String symbol = 'Rp ',
    int decimalDigits = 0,
    String locale = 'id_ID',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Format number as USD currency
  static String usd(num amount, {int decimalDigits = 2}) {
    return currency(
      amount,
      symbol: r'$',
      decimalDigits: decimalDigits,
      locale: 'en_US',
    );
  }

  /// Format number with thousand separators
  ///
  /// Example: 1000000 → 1.000.000
  static String decimal(
    num number, {
    int decimalDigits = 0,
    String locale = 'id_ID',
  }) {
    final formatter = NumberFormat.decimalPattern(locale);
    if (decimalDigits > 0) {
      return number.toStringAsFixed(decimalDigits);
    }
    return formatter.format(number);
  }

  /// Format number as percentage
  ///
  /// [value] - Value between 0 and 1 (or 0 and 100 if [isPercentValue] is true)
  /// [decimalDigits] - Number of decimal places (default: 1)
  /// [isPercentValue] - If true, treats input as percentage value (default: false)
  static String percentage(
    num value, {
    int decimalDigits = 1,
    bool isPercentValue = false,
  }) {
    final percentValue = isPercentValue ? value : value * 100;
    return '${percentValue.toStringAsFixed(decimalDigits)}%';
  }

  /// Format large numbers in compact form
  ///
  /// Examples:
  /// - 1000 → 1K
  /// - 1500000 → 1.5M
  /// - 1000000000 → 1B
  static String compact(num number, {int decimalDigits = 1}) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(decimalDigits)}K';
    } else if (number < 1000000000) {
      return '${(number / 1000000).toStringAsFixed(decimalDigits)}M';
    } else if (number < 1000000000000) {
      return '${(number / 1000000000).toStringAsFixed(decimalDigits)}B';
    } else {
      return '${(number / 1000000000000).toStringAsFixed(decimalDigits)}T';
    }
  }

  /// Format number with compact notation using NumberFormat
  ///
  /// Example: 1234567 → 1.2M
  static String compactLong(num number, {String locale = 'id_ID'}) {
    final formatter = NumberFormat.compact(locale: locale);
    return formatter.format(number);
  }

  /// Format number with full compact notation
  ///
  /// Example: 1234567 → 1.234567 million
  static String compactFull(num number, {String locale = 'en_US'}) {
    final formatter = NumberFormat.compactLong(locale: locale);
    return formatter.format(number);
  }

  /// Format file size in human-readable format
  ///
  /// Example: 1536 → 1.5 KB
  static String fileSize(int bytes, {int decimalDigits = 1}) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(decimalDigits)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(decimalDigits)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(decimalDigits)} GB';
    }
  }

  /// Format duration in human-readable format
  ///
  /// Example: 3665 seconds → 1h 1m 5s
  static String duration(int seconds, {bool showSeconds = true}) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final parts = <String>[];

    if (hours > 0) {
      parts.add('${hours}h');
    }

    if (minutes > 0 || hours > 0) {
      parts.add('${minutes}m');
    }

    if (showSeconds && (secs > 0 || parts.isEmpty)) {
      parts.add('${secs}s');
    }

    return parts.join(' ');
  }

  /// Format ordinal numbers (1st, 2nd, 3rd, etc.)
  static String ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  /// Parse formatted currency string to number
  static double? parseCurrency(String value) {
    try {
      // Remove currency symbols and thousand separators
      final cleaned = value
          .replaceAll(RegExp(r'[Rp$,.\s]'), '')
          .replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Parse formatted number string to number
  static double? parseNumber(String value) {
    try {
      final cleaned = value.replaceAll(RegExp(r'[,.]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format number with custom pattern
  static String custom(num number, String pattern, {String locale = 'id_ID'}) {
    final formatter = NumberFormat(pattern, locale);
    return formatter.format(number);
  }

  /// Format Indonesian phone number
  ///
  /// Example: 628123456789 → +62 812-3456-789
  static String phoneNumber(String phone) {
    // Remove all non-numeric characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length < 10) return phone;

    // Handle Indonesian format
    if (cleaned.startsWith('62')) {
      final countryCode = cleaned.substring(0, 2);
      final rest = cleaned.substring(2);

      if (rest.length >= 9) {
        return '+$countryCode ${rest.substring(0, 3)}-${rest.substring(3, 7)}-${rest.substring(7)}';
      }
    } else if (cleaned.startsWith('0')) {
      final rest = cleaned.substring(1);
      if (rest.length >= 9) {
        return '0${rest.substring(0, 3)}-${rest.substring(3, 7)}-${rest.substring(7)}';
      }
    }

    return phone;
  }

  /// Format Indonesian ID (NIK)
  ///
  /// Example: 3201234567890123 → 3201-2345-6789-0123
  static String indonesianID(String nik) {
    final cleaned = nik.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 16) return nik;

    return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
  }

  /// Format credit card number
  ///
  /// Example: 1234567890123456 → 1234 5678 9012 3456
  static String creditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }

    return buffer.toString();
  }

  /// Round number to specified decimal places
  static double roundTo(double number, int decimalPlaces) {
    final mod = 10.0 * decimalPlaces;
    return (number * mod).round() / mod;
  }

  /// Format rating (e.g., for star ratings)
  ///
  /// Example: 4.567 → 4.6
  static String rating(double rating, {int decimalDigits = 1}) {
    return rating.toStringAsFixed(decimalDigits);
  }

  /// Format as roman numerals
  static String toRoman(int number) {
    if (number < 1 || number > 3999) {
      return number.toString();
    }

    const List<int> values = [
      1000,
      900,
      500,
      400,
      100,
      90,
      50,
      40,
      10,
      9,
      5,
      4,
      1,
    ];
    const List<String> numerals = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I',
    ];

    String result = '';
    int remaining = number;

    for (int i = 0; i < values.length; i++) {
      while (remaining >= values[i]) {
        result += numerals[i];
        remaining -= values[i];
      }
    }

    return result;
  }

  /// Calculate and format percentage change
  ///
  /// Example: oldValue: 100, newValue: 150 → +50%
  static String percentageChange(
    num oldValue,
    num newValue, {
    int decimalDigits = 1,
  }) {
    if (oldValue == 0) return 'N/A';

    final change = ((newValue - oldValue) / oldValue) * 100;
    final sign = change >= 0 ? '+' : '';

    return '$sign${change.toStringAsFixed(decimalDigits)}%';
  }
}
