import 'package:permission_handler/permission_handler.dart';

/// Result of permission request
class PermissionResult {
  final bool isGranted;
  final bool isPermanentlyDenied;
  final bool isDenied;
  final String message;

  const PermissionResult({
    required this.isGranted,
    required this.isPermanentlyDenied,
    required this.isDenied,
    required this.message,
  });

  factory PermissionResult.granted() => const PermissionResult(
    isGranted: true,
    isPermanentlyDenied: false,
    isDenied: false,
    message: 'Permission granted',
  );

  factory PermissionResult.denied() => const PermissionResult(
    isGranted: false,
    isPermanentlyDenied: false,
    isDenied: true,
    message: 'Permission denied',
  );

  factory PermissionResult.permanentlyDenied() => const PermissionResult(
    isGranted: false,
    isPermanentlyDenied: true,
    isDenied: true,
    message: 'Permission permanently denied. Please enable in settings.',
  );
}

/// Wrapper for permission_handler with simplified API
///
/// Example:
/// ```dart
/// final result = await PermissionHandlerWrapper.requestCamera();
/// if (result.isGranted) {
///   // Use camera
/// } else if (result.isPermanentlyDenied) {
///   // Show dialog to open settings
/// }
/// ```
class PermissionHandlerWrapper {
  PermissionHandlerWrapper._();

  /// Request camera permission
  static Future<PermissionResult> requestCamera() async {
    return _requestPermission(Permission.camera);
  }

  /// Request microphone permission
  static Future<PermissionResult> requestMicrophone() async {
    return _requestPermission(Permission.microphone);
  }

  /// Request photo/gallery permission
  static Future<PermissionResult> requestPhotos() async {
    return _requestPermission(Permission.photos);
  }

  /// Request storage permission
  static Future<PermissionResult> requestStorage() async {
    return _requestPermission(Permission.storage);
  }

  /// Request location permission (always)
  static Future<PermissionResult> requestLocation() async {
    return _requestPermission(Permission.location);
  }

  /// Request location permission (when in use)
  static Future<PermissionResult> requestLocationWhenInUse() async {
    return _requestPermission(Permission.locationWhenInUse);
  }

  /// Request location permission (always)
  static Future<PermissionResult> requestLocationAlways() async {
    return _requestPermission(Permission.locationAlways);
  }

  /// Request contacts permission
  static Future<PermissionResult> requestContacts() async {
    return _requestPermission(Permission.contacts);
  }

  /// Request calendar permission
  static Future<PermissionResult> requestCalendar() async {
    return _requestPermission(Permission.calendar);
  }

  /// Request notification permission
  static Future<PermissionResult> requestNotification() async {
    return _requestPermission(Permission.notification);
  }

  /// Request bluetooth permission
  static Future<PermissionResult> requestBluetooth() async {
    return _requestPermission(Permission.bluetooth);
  }

  /// Request bluetooth scan permission
  static Future<PermissionResult> requestBluetoothScan() async {
    return _requestPermission(Permission.bluetoothScan);
  }

  /// Request bluetooth connect permission
  static Future<PermissionResult> requestBluetoothConnect() async {
    return _requestPermission(Permission.bluetoothConnect);
  }

  /// Request bluetooth advertise permission
  static Future<PermissionResult> requestBluetoothAdvertise() async {
    return _requestPermission(Permission.bluetoothAdvertise);
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionResult>> requestMultiple(
    List<Permission> permissions,
  ) async {
    final results = await permissions.request();
    final Map<Permission, PermissionResult> permissionResults = {};

    for (final entry in results.entries) {
      permissionResults[entry.key] = _mapStatus(entry.value);
    }

    return permissionResults;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async {
    return _isGranted(Permission.camera);
  }

  /// Check if microphone permission is granted
  static Future<bool> isMicrophoneGranted() async {
    return _isGranted(Permission.microphone);
  }

  /// Check if photos permission is granted
  static Future<bool> isPhotosGranted() async {
    return _isGranted(Permission.photos);
  }

  /// Check if storage permission is granted
  static Future<bool> isStorageGranted() async {
    return _isGranted(Permission.storage);
  }

  /// Check if location permission is granted
  static Future<bool> isLocationGranted() async {
    return _isGranted(Permission.location);
  }

  /// Check if notification permission is granted
  static Future<bool> isNotificationGranted() async {
    return _isGranted(Permission.notification);
  }

  /// Check if contacts permission is granted
  static Future<bool> isContactsGranted() async {
    return _isGranted(Permission.contacts);
  }

  /// Open app settings
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Check permission status
  static Future<PermissionStatus> checkStatus(Permission permission) async {
    return await permission.status;
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Request permission with rationale
  ///
  /// Shows a rationale dialog before requesting permission if needed
  static Future<PermissionResult> requestWithRationale({
    required Permission permission,
    String? rationaleTitle,
    String? rationaleMessage,
    Future<bool> Function(String title, String message)? showRationaleDialog,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return PermissionResult.granted();
    }

    // If denied before, show rationale
    if (status.isDenied && showRationaleDialog != null) {
      final shouldRequest = await showRationaleDialog(
        rationaleTitle ?? 'Permission Required',
        rationaleMessage ?? 'This permission is needed to continue',
      );

      if (!shouldRequest) {
        return PermissionResult.denied();
      }
    }

    return _requestPermission(permission);
  }

  /// Request camera and microphone permissions (for video calls)
  static Future<Map<String, PermissionResult>>
  requestVideoCallPermissions() async {
    final cameraResult = await requestCamera();
    final microphoneResult = await requestMicrophone();

    return {'camera': cameraResult, 'microphone': microphoneResult};
  }

  /// Request location and storage permissions (for location-based features)
  static Future<Map<String, PermissionResult>>
  requestLocationFeaturePermissions() async {
    final locationResult = await requestLocation();
    final storageResult = await requestStorage();

    return {'location': locationResult, 'storage': storageResult};
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllGranted(List<Permission> permissions) async {
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  /// Get detailed status for multiple permissions
  static Future<Map<Permission, PermissionStatus>> getStatusMap(
    List<Permission> permissions,
  ) async {
    final Map<Permission, PermissionStatus> statusMap = {};
    for (final permission in permissions) {
      statusMap[permission] = await permission.status;
    }
    return statusMap;
  }

  // Private helper methods

  static Future<PermissionResult> _requestPermission(
    Permission permission,
  ) async {
    try {
      final status = await permission.request();
      return _mapStatus(status);
    } catch (e) {
      print('Error requesting permission: $e');
      return PermissionResult.denied();
    }
  }

  static Future<bool> _isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  static PermissionResult _mapStatus(PermissionStatus status) {
    if (status.isGranted) {
      return PermissionResult.granted();
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied();
    } else {
      return PermissionResult.denied();
    }
  }
}

/// Extension to get user-friendly permission names
extension PermissionExtension on Permission {
  String get displayName {
    switch (this) {
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.photos:
        return 'Photos';
      case Permission.storage:
        return 'Storage';
      case Permission.location:
        return 'Location';
      case Permission.locationWhenInUse:
        return 'Location (When In Use)';
      case Permission.locationAlways:
        return 'Location (Always)';
      case Permission.contacts:
        return 'Contacts';
      case Permission.calendar:
        return 'Calendar';
      case Permission.notification:
        return 'Notifications';
      case Permission.bluetooth:
        return 'Bluetooth';
      case Permission.bluetoothScan:
        return 'Bluetooth Scan';
      case Permission.bluetoothConnect:
        return 'Bluetooth Connect';
      case Permission.bluetoothAdvertise:
        return 'Bluetooth Advertise';
      default:
        return toString();
    }
  }

  String get rationaleMessage {
    switch (this) {
      case Permission.camera:
        return 'Camera access is needed to take photos and videos';
      case Permission.microphone:
        return 'Microphone access is needed to record audio';
      case Permission.photos:
        return 'Photo library access is needed to select images';
      case Permission.storage:
        return 'Storage access is needed to save and read files';
      case Permission.location:
        return 'Location access is needed to provide location-based features';
      case Permission.contacts:
        return 'Contacts access is needed to connect with your friends';
      case Permission.notification:
        return 'Notification permission is needed to keep you updated';
      default:
        return '$displayName permission is required';
    }
  }
}
