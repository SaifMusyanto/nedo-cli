import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static const String _tokenKey = 'auth_token';
  String? _cachedToken;
  static const String _idTokenKey = 'id_token';
  String? _cachedIdToken;
  static const String _roleActiveKey = 'role_active';
  String? _cachedRoleActive;

  static Future<SecureStorageService> create() async {
    final service = SecureStorageService();
    await service.init();
    return service;
  }

  Future<void> init() async {
    try {
      _cachedToken = await _storage.read(key: _tokenKey);
      _cachedIdToken = await _storage.read(key: _idTokenKey);
      _cachedRoleActive = await _storage.read(key: _roleActiveKey);
    } catch (e) {
      _cachedToken = null;
      _cachedIdToken = null;
      _cachedRoleActive = null;

      debugPrint('Error reading from secure storage: $e');
    }
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  String? getToken() {
    return _cachedToken;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    _cachedToken = null;
  }

  Future<void> saveIdToken(String idToken) async {
    _cachedIdToken = idToken;
    await _storage.write(key: _idTokenKey, value: idToken);
  }

  String? getIdToken() {
    return _cachedIdToken;
  }

  Future<void> deleteIdToken() async {
    await _storage.delete(key: _idTokenKey);
    _cachedIdToken = null;
  }

  Future<void> saveRoleActive(String roleActive) async {
    _cachedRoleActive = roleActive;
    await _storage.write(key: _roleActiveKey, value: roleActive);
  }

  String? getRoleActive() {
    return _cachedRoleActive;
  }

  Future<void> deleteRoleActive() async {
    await _storage.delete(key: _roleActiveKey);
    _cachedRoleActive = null;
  }

  Future<void> set(String key, String? value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> get(String key) async {
    return _storage.read(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
    _cachedToken = null;
    _cachedIdToken = null;
    _cachedRoleActive = null;
  }
}
