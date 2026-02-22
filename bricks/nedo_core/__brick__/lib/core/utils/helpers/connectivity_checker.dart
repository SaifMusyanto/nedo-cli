import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Network connectivity status
enum NetworkStatus { online, offline, unknown }

/// Network type
enum NetworkType { wifi, mobile, ethernet, vpn, bluetooth, other, none }

/// Callback for connectivity changes
typedef ConnectivityCallback =
    void Function(NetworkStatus status, NetworkType type);

/// Wrapper for connectivity_plus with enhanced features
///
/// Example:
/// ```dart
/// // Check current status
/// final isOnline = await ConnectivityChecker.isConnected();
///
/// // Listen to changes
/// ConnectivityChecker.instance.onConnectivityChanged.listen((status) {
///   if (status == NetworkStatus.online) {
///     // Handle online
///   }
/// });
///
/// // Check specific connection type
/// final isWifi = await ConnectivityChecker.isWifi();
/// ```
class ConnectivityChecker {
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();
  static ConnectivityChecker get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();
  final StreamController<NetworkType> _typeController =
      StreamController<NetworkType>.broadcast();

  NetworkStatus _currentStatus = NetworkStatus.unknown;
  NetworkType _currentType = NetworkType.none;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityChecker._internal();

  /// Stream of network status changes
  Stream<NetworkStatus> get onConnectivityChanged => _statusController.stream;

  /// Stream of network type changes
  Stream<NetworkType> get onNetworkTypeChanged => _typeController.stream;

  /// Get current network status
  NetworkStatus get currentStatus => _currentStatus;

  /// Get current network type
  NetworkType get currentType => _currentType;

  /// Initialize connectivity checker and start listening
  Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startListening();
  }

  /// Dispose and clean up resources
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
    _typeController.close();
  }

  /// Check if device is connected to internet
  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Check if device is connected via WiFi
  static Future<bool> isWifi() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Check if device is connected via mobile data
  static Future<bool> isMobile() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }

  /// Check if device is connected via ethernet
  static Future<bool> isEthernet() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.ethernet);
  }

  /// Check if device is connected via VPN
  static Future<bool> isVPN() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.vpn);
  }

  /// Get current connectivity type
  static Future<NetworkType> getNetworkType() async {
    final result = await Connectivity().checkConnectivity();
    return _mapConnectivityResult(result);
  }

  /// Execute callback when internet is available
  ///
  /// [callback] - Function to execute when online
  /// [timeout] - Maximum time to wait (optional)
  /// [checkInterval] - How often to check connectivity (default: 1 second)
  static Future<bool> executeWhenOnline(
    Future<void> Function() callback, {
    Duration? timeout,
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    final startTime = DateTime.now();

    while (true) {
      if (await isConnected()) {
        await callback();
        return true;
      }

      if (timeout != null && DateTime.now().difference(startTime) > timeout) {
        return false;
      }

      await Future.delayed(checkInterval);
    }
  }

  /// Wait until internet connection is available
  ///
  /// [timeout] - Maximum time to wait (optional)
  /// [checkInterval] - How often to check connectivity (default: 1 second)
  static Future<bool> waitForConnection({
    Duration? timeout,
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    if (await isConnected()) return true;

    final startTime = DateTime.now();

    while (true) {
      if (await isConnected()) {
        return true;
      }

      if (timeout != null && DateTime.now().difference(startTime) > timeout) {
        return false;
      }

      await Future.delayed(checkInterval);
    }
  }

  /// Check connectivity with retry mechanism
  ///
  /// [maxRetries] - Maximum number of retry attempts
  /// [retryDelay] - Delay between retries
  static Future<bool> checkWithRetry({
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      if (await isConnected()) {
        return true;
      }

      if (i < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    }

    return false;
  }

  /// Get detailed connectivity information
  static Future<Map<String, dynamic>> getDetailedInfo() async {
    final result = await Connectivity().checkConnectivity();
    final isOnline = !result.contains(ConnectivityResult.none);
    final networkType = _mapConnectivityResult(result);

    return {
      'isOnline': isOnline,
      'networkType': networkType.toString(),
      'isWifi': result.contains(ConnectivityResult.wifi),
      'isMobile': result.contains(ConnectivityResult.mobile),
      'isEthernet': result.contains(ConnectivityResult.ethernet),
      'isVPN': result.contains(ConnectivityResult.vpn),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Private methods

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateStatus,
      onError: (error) {
        print('Connectivity error: $error');
      },
    );
  }

  void _updateStatus(List<ConnectivityResult> result) {
    final newType = _mapConnectivityResult(result);
    final newStatus = result.contains(ConnectivityResult.none)
        ? NetworkStatus.offline
        : NetworkStatus.online;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }

    if (newType != _currentType) {
      _currentType = newType;
      _typeController.add(newType);
    }
  }

  static NetworkType _mapConnectivityResult(List<ConnectivityResult> result) {
    if (result.contains(ConnectivityResult.wifi)) {
      return NetworkType.wifi;
    } else if (result.contains(ConnectivityResult.mobile)) {
      return NetworkType.mobile;
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return NetworkType.ethernet;
    } else if (result.contains(ConnectivityResult.vpn)) {
      return NetworkType.vpn;
    } else if (result.contains(ConnectivityResult.bluetooth)) {
      return NetworkType.bluetooth;
    } else if (result.contains(ConnectivityResult.other)) {
      return NetworkType.other;
    } else {
      return NetworkType.none;
    }
  }
}

/// Extension for easy connectivity checking
extension ConnectivityExtension on BuildContext {
  /// Check if device is connected to internet
  Future<bool> get isConnected => ConnectivityChecker.isConnected();

  /// Get current network type
  Future<NetworkType> get networkType => ConnectivityChecker.getNetworkType();
}

/// Mixin for widgets that need connectivity monitoring
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<NetworkStatus>? _connectivitySubscription;
  NetworkStatus _networkStatus = NetworkStatus.unknown;

  NetworkStatus get networkStatus => _networkStatus;
  bool get isOnline => _networkStatus == NetworkStatus.online;
  bool get isOffline => _networkStatus == NetworkStatus.offline;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _initConnectivity() {
    ConnectivityChecker.instance.initialize();
    _networkStatus = ConnectivityChecker.instance.currentStatus;

    _connectivitySubscription = ConnectivityChecker
        .instance
        .onConnectivityChanged
        .listen((status) {
          setState(() {
            _networkStatus = status;
          });
          onConnectivityChanged(status);
        });
  }

  /// Override this method to handle connectivity changes
  void onConnectivityChanged(NetworkStatus status) {}
}
