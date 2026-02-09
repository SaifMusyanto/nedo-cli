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

  Future<void> init() async {
    try {
      _cachedToken = await _storage.read(key: _tokenKey);
      _cachedIdToken = await _storage.read(key: _idTokenKey);
    } catch (e) {
      _cachedToken = null;
      _cachedIdToken = null;

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

  Future<void> clearAll() async {
    await _storage.deleteAll();
    _cachedToken = null;
    _cachedIdToken = null;
  }
}
