import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logDuration(response.requestOptions, response.statusCode, 'SUCCESS');

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logDuration(err.requestOptions, err.response?.statusCode, 'ERROR');

    return super.onError(err, handler);
  }

  void _logDuration(RequestOptions options, int? statusCode, String status) {
    final startTime = options.extra['start_time'] as int?;
    if (startTime == null) return;

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final duration = endTime - startTime;

    if (kDebugMode) {
      print('   [PERFORMANCE] ${options.method} ${options.path}');
      print('   Status: $statusCode ($status)');
      print('   Duration: ${duration}ms');
      print('-------------------------------------------------------');
    }
  }
}
