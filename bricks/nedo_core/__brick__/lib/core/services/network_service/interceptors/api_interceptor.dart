import 'package:dio/dio.dart';
import '../../storage_service/secure/secure_storage_service.dart';
import '../../../utils/events/auth_event_bus.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageService _secureStorageService;
  final AuthEventBus _authEventBus;

  ApiInterceptor(this._secureStorageService, this._authEventBus);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _secureStorageService.getToken();
    final roleActive = _secureStorageService.getRoleActive();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      if (roleActive != null && roleActive.isNotEmpty) {
        options.headers['X-Role-Active'] = roleActive;
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _secureStorageService.clearAll();
      _authEventBus.emitSessionExpired();
    }

    super.onError(err, handler);
  }
}
