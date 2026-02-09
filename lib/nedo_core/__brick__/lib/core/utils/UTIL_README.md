# Utilities

Comprehensive utility classes for Flutter development with clean architecture principles.

## Features

### ✅ Date Formatter

Powerful date formatting utilities with support for:

- Multiple date format patterns
- Relative time (e.g., "2 hours ago")
- ISO and API date formats
- Date parsing and manipulation
- Age calculation, day helpers

**Usage:**

```dart
import 'package:my_project/core/utils/utils.dart';

// Format dates
final formatted = DateFormatter.format(DateTime.now());
final relative = DateFormatter.relativeTime(pastDate);
final age = DateFormatter.getAge(birthDate);

// Check dates
if (DateFormatter.isToday(date)) {
  print('Today!');
}
```

### ✅ Validators

Comprehensive input validation for:

- Email, phone, URL validation
- Password strength checking
- Indonesian-specific validators (NIK, phone, postal code)
- Credit card validation (Luhn algorithm)
- Form validators for Flutter

**Usage:**

```dart
import 'package:my_project/core/utils/utils.dart';

// Basic validation
if (Validators.isValidEmail(email)) {
  // Process email
}

// Password strength
final strength = Validators.getPasswordStrength(password);

// Form validators
TextFormField(
  validator: Validators.emailValidator,
)
```

### ✅ Number Formatter

Format numbers, currency, and more:

- Currency formatting (IDR, USD, etc.)
- Compact notation (1K, 1.5M, 1B)
- File size formatting
- Percentage formatting
- Phone number, credit card formatting

**Usage:**

```dart
import 'package:my_project/core/utils/utils.dart';

// Currency
final price = NumberFormatter.currency(10000); // Rp 10.000

// Compact
final views = NumberFormatter.compact(1500000); // 1.5M

// File size
final size = NumberFormatter.fileSize(1536); // 1.5 KB

// Percentage
final percent = NumberFormatter.percentage(0.75); // 75.0%
```

### ✅ Image Picker Wrapper

Simplified image and video picking:

- Single and multiple image selection
- Camera and gallery support
- Image compression
- Cross-platform support (Web, Mobile)
- File size validation

**Usage:**

```dart
import 'package:my_project/core/utils/utils.dart';

// Pick from gallery
final result = await ImagePickerWrapper.pickFromGallery(
  maxWidth: 800,
  compressQuality: 70,
);

if (result?.hasImage ?? false) {
  // Use result.file or result.bytes
}

// Pick multiple
final images = await ImagePickerWrapper.pickMultipleImages(
  maxImages: 5,
);
```

### ✅ Permission Handler Wrapper

Easy permission management:

- Simplified permission requests
- Multiple permissions support
- Rationale dialog support
- Permission status checking
- Settings navigation

**Usage:**

```dart
import 'package:my_project/core/utils/utils.dart';

// Request single permission
final result = await PermissionHandlerWrapper.requestCamera();

if (result.isGranted) {
  // Use camera
} else if (result.isPermanentlyDenied) {
  // Open settings
  await PermissionHandlerWrapper.openSettings();
}

// Check permission
if (await PermissionHandlerWrapper.isCameraGranted()) {
  // Camera is granted
}
```

### ✅ Connectivity Checker

Monitor network connectivity:

- Real-time connectivity monitoring
- Network type detection (WiFi, Mobile, etc.)
- Wait for connection
- Execute when online
- Connectivity mixin for widgets

**Usage:**

```dart
import 'package:my_project/core/utils/utils.dart';

// Check connectivity
if (await ConnectivityChecker.isConnected()) {
  // Online
}

// Listen to changes
ConnectivityChecker.instance.initialize();
ConnectivityChecker.instance.onConnectivityChanged.listen((status) {
  if (status == NetworkStatus.online) {
    // Handle online
  }
});

// Wait for connection
await ConnectivityChecker.waitForConnection(
  timeout: Duration(seconds: 30),
);

// Use mixin in StatefulWidget
class MyWidget extends StatefulWidget {
  // ...
}

class _MyWidgetState extends State<MyWidget> with ConnectivityMixin {
  @override
  void onConnectivityChanged(NetworkStatus status) {
    // Handle connectivity change
  }
}
```

## Installation

This utilities package is already included in your project. All dependencies are specified in `pubspec.yaml`.

## Project Structure

```
lib/
└── core/
    └── utils/
        ├── date_formatter.dart
        ├── validators.dart
        ├── number_formatter.dart
        ├── image_picker_wrapper.dart
        ├── permission_handler_wrapper.dart
        ├── connectivity_checker.dart
        ├── platform_utils.dart
        └── utils.dart (exports)
```

## Best Practices

1. **Import Once**: Import from `utils.dart` to get all utilities

   ```dart
   import 'package:my_project/core/utils/utils.dart';
   ```

2. **Error Handling**: All utilities include proper error handling and return null/false on errors

3. **Security**:
   - Use validators before processing user input
   - Check permissions before accessing sensitive features
   - Validate network connectivity before API calls

4. **Performance**:
   - Utilities are designed to be lightweight
   - Use singleton pattern where appropriate
   - Stream subscriptions are properly managed

5. **Testing**: All utilities are easily testable and mockable

## License

This is a boilerplate generated by Mason. Customize as needed for your project.

---

Generated by Mason 🧱
