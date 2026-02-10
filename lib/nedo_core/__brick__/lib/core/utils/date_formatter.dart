import 'package:intl/intl.dart';

/// Utility class for formatting dates consistently across the app
///
/// Example:
/// ```dart
/// final formatted = DateFormatter.format(DateTime.now());
/// final relative = DateFormatter.relativeTime(pastDate);
/// ```
class DateFormatter {
  DateFormatter._();

  // Common date formats
  static const String defaultFormat = 'dd MMM yyyy';
  static const String fullFormat = 'EEEE, dd MMMM yyyy';
  static const String shortFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String isoFormat = 'yyyy-MM-dd';
  static const String apiFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  /// Format a DateTime with a custom pattern
  ///
  /// [date] - The date to format
  /// [pattern] - The format pattern (defaults to defaultFormat)
  /// [locale] - Optional locale for formatting
  static String format(
    DateTime date, {
    String pattern = defaultFormat,
    String? locale,
  }) {
    try {
      return DateFormat(pattern, locale).format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format to default format (dd MMM yyyy)
  static String toDefault(DateTime date) => format(date);

  /// Format to full format (EEEE, dd MMMM yyyy)
  static String toFull(DateTime date) => format(date, pattern: fullFormat);

  /// Format to short format (dd/MM/yyyy)
  static String toShort(DateTime date) => format(date, pattern: shortFormat);

  /// Format to time only (HH:mm)
  static String toTime(DateTime date) => format(date, pattern: timeFormat);

  /// Format to date and time (dd MMM yyyy HH:mm)
  static String toDateTime(DateTime date) =>
      format(date, pattern: dateTimeFormat);

  /// Format to ISO format (yyyy-MM-dd)
  static String toISO(DateTime date) => format(date, pattern: isoFormat);

  /// Format for API calls (yyyy-MM-ddTHH:mm:ss.SSSZ)
  static String toAPI(DateTime date) =>
      format(date.toUtc(), pattern: apiFormat);

  /// Parse a date string with a specific pattern
  static DateTime? parse(String dateString, {String? pattern}) {
    try {
      if (pattern != null) {
        return DateFormat(pattern).parse(dateString);
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse ISO date string
  static DateTime? parseISO(String dateString) {
    return parse(dateString, pattern: isoFormat);
  }

  /// Parse API date string
  static DateTime? parseAPI(String dateString) {
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String relativeTime(DateTime dateTime, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return _futureTimeString(difference.abs());
    } else {
      return _pastTimeString(difference);
    }
  }

  static String _pastTimeString(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  static String _futureTimeString(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'in $years ${years == 1 ? 'year' : 'years'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'in a moment';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get day name with optional relative naming
  /// Returns "Today", "Yesterday", "Tomorrow" or day name
  static String getDayName(DateTime date, {bool useRelative = true}) {
    if (useRelative) {
      if (isToday(date)) return 'Today';
      if (isYesterday(date)) return 'Yesterday';
      if (isTomorrow(date)) return 'Tomorrow';
    }
    return DateFormat('EEEE').format(date);
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Get first day of month
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get last day of month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
