///
/// Example:
/// ```dart
/// if (Validators.isValidEmail(email)) {
///   // Process email
/// }
/// ```
class Validators {
  Validators._();

  // Regular expressions for validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$',
  );

  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  static final RegExp _alphaNumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
  static final RegExp _alphaRegex = RegExp(r'^[a-zA-Z]+$');
  static final RegExp _numericRegex = RegExp(r'^[0-9]+$');

  /// Validate email address
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validate phone number
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    return _phoneRegex.hasMatch(phone.trim());
  }

  /// Validate URL
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    return _urlRegex.hasMatch(url.trim());
  }

  /// Validate password strength
  ///
  /// Requirements:
  /// - Minimum [minLength] characters (default: 8)
  /// - At least one uppercase letter (if [requireUppercase] is true)
  /// - At least one lowercase letter (if [requireLowercase] is true)
  /// - At least one number (if [requireNumber] is true)
  /// - At least one special character (if [requireSpecialChar] is true)
  static bool isValidPassword(
    String password, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = true,
  }) {
    if (password.isEmpty || password.length < minLength) {
      return false;
    }

    if (requireUppercase && !password.contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    if (requireLowercase && !password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    if (requireNumber && !password.contains(RegExp(r'[0-9]'))) {
      return false;
    }

    if (requireSpecialChar &&
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return false;
    }

    return true;
  }

  /// Get password strength (0-4)
  /// 0: Very weak, 1: Weak, 2: Fair, 3: Good, 4: Strong
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[0-9]'))) strength++;

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength > 4 ? 4 : strength;
  }

  /// Validate username
  ///
  /// Rules:
  /// - Alphanumeric and underscores only
  /// - Length between [minLength] and [maxLength]
  static bool isValidUsername(
    String username, {
    int minLength = 3,
    int maxLength = 20,
  }) {
    if (username.isEmpty ||
        username.length < minLength ||
        username.length > maxLength) {
      return false;
    }

    return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);
  }

  /// Validate Indonesian phone number
  static bool isValidIndonesianPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Indonesian phone patterns
    // 08xx-xxxx-xxxx or +628xx-xxxx-xxxx or 628xx-xxxx-xxxx
    return RegExp(r'^(\+62|62|0)[0-9]{9,12}$').hasMatch(cleanPhone);
  }

  /// Validate credit card number using Luhn algorithm
  static bool isValidCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s'), '');

    if (!_numericRegex.hasMatch(cleaned) || cleaned.length < 13) {
      return false;
    }

    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validate date of birth (must be in the past and reasonable age)
  static bool isValidDateOfBirth(
    DateTime? dob, {
    int minAge = 0,
    int maxAge = 150,
  }) {
    if (dob == null) return false;

    final now = DateTime.now();
    if (dob.isAfter(now)) return false;

    final age = now.year - dob.year;
    if (age < minAge || age > maxAge) return false;

    return true;
  }

  /// Validate that string is not empty or whitespace only
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  /// Validate exact length
  static bool hasExactLength(String value, int length) {
    return value.length == length;
  }

  /// Validate that string contains only alphabetic characters
  static bool isAlpha(String value) {
    return _alphaRegex.hasMatch(value);
  }

  /// Validate that string contains only numeric characters
  static bool isNumeric(String value) {
    return _numericRegex.hasMatch(value);
  }

  /// Validate that string contains only alphanumeric characters
  static bool isAlphaNumeric(String value) {
    return _alphaNumericRegex.hasMatch(value);
  }

  /// Validate Indonesian NIK (Nomor Induk Kependudukan)
  static bool isValidNIK(String nik) {
    final cleaned = nik.replaceAll(RegExp(r'\s'), '');
    return _numericRegex.hasMatch(cleaned) && cleaned.length == 16;
  }

  /// Validate Indonesian postal code
  static bool isValidIndonesianPostalCode(String postalCode) {
    final cleaned = postalCode.replaceAll(RegExp(r'\s'), '');
    return _numericRegex.hasMatch(cleaned) && cleaned.length == 5;
  }

  /// Validate matching values (e.g., password confirmation)
  static bool matches(String value1, String value2) {
    return value1 == value2;
  }

  /// Validate that value is within a numeric range
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  /// Custom regex validation
  static bool matchesPattern(String value, RegExp pattern) {
    return pattern.hasMatch(value);
  }

  /// Validator function generator for Flutter forms
  static String? Function(String?) formValidator({
    bool required = false,
    int? minLength,
    int? maxLength,
    String? Function(String)? customValidator,
    String? requiredMessage,
    String? minLengthMessage,
    String? maxLengthMessage,
  }) {
    return (String? value) {
      if (required && (value == null || value.trim().isEmpty)) {
        return requiredMessage ?? 'This field is required';
      }

      if (value != null && value.isNotEmpty) {
        if (minLength != null && value.length < minLength) {
          return minLengthMessage ?? 'Must be at least $minLength characters';
        }

        if (maxLength != null && value.length > maxLength) {
          return maxLengthMessage ??
              'Must be no more than $maxLength characters';
        }

        if (customValidator != null) {
          return customValidator(value);
        }
      }

      return null;
    };
  }

  /// Email validator for Flutter forms
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Phone validator for Flutter forms
  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Password validator for Flutter forms
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least 8 characters with uppercase, lowercase, number and special character';
    }
    return null;
  }
}
