import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CustomDioLogger extends Interceptor {
  var logger = Logger(filter: null, printer: PrettyPrinter(), output: null);

  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('''
\x1B[33m=== REQUEST ===\x1B[0m
➡️  [${options.method}] ${options.uri}
🔍 Query: ${_prettyJson(options.queryParameters)}')
📦 Headers: ${_prettyJson(options.headers)}
🧾 Body : ${options.data}
\x1B[33m================\x1B[0m
''');
    // super.onRequest(options, handler);
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      logger.i('''
\x1B[32m=== RESPONSE ===\x1B[0m
✅ URL: ${response.requestOptions.uri}
📦 Status: ${response.statusCode}
🧾 Data: ${_prettyJson(response.data)}
\x1B[32m================\x1B[0m
      ''');
    }
    // super.onResponse(response, handler);
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      logger.e('''
\x1B[31m=== ERROR ===\x1B[0m
❌ URL: ${err.requestOptions.uri}
🚨 Message: ${err.message}
📦 Status: ${err.response?.statusCode}
🧾 Data: ${_prettyJson(err.response?.data)}
\x1B[31m==============\x1B[0m
''');
    }
    // super.onError(err, handler);
    return handler.next(err);
  }

  String _prettyJson(dynamic data) {
    try {
      if (data is String) {
        return _encoder.convert(json.decode(data));
      }
      if (data is Map || data is List) {
        return _encoder.convert(data);
      }
      // fallback aman untuk tipe selain Map/List
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }
}
