import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'interceptors/log_interceptor.dart';
import '../../utils/events/auth_event_bus.dart';
import '../../errors/exceptions.dart';
import '../storage_service/secure/secure_storage_service.dart';
import 'config/api_config.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/performance_interceptor.dart';

@LazySingleton()
class DioClient {
  final Dio _dio;
  final ApiConfig _config;
  final ApiInterceptor _interceptor;

  DioClient({
    required Dio dio,
    required ApiConfig config,
    required SecureStorageService secureStorageService,
    required AuthEventBus authEventBus,
  }) : _dio = dio,
       _config = config,
       _interceptor = ApiInterceptor(secureStorageService, authEventBus) {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      headers: _config.headers,
    );

    _dio.interceptors.clear();
    _dio.interceptors.add(_interceptor);
    if (kDebugMode) {
      _dio.interceptors.add(CustomDioLogger());
      _dio.interceptors.add(PerformanceInterceptor());
    }
  }

  Future<Response> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.cancel:
        return NetworkException(
          NetworkErrorType.fromDioType(error.type),
          message: error.message,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = error.message ?? 'Unknown server error';

        if (data is Map) {
          if (data.containsKey('message') && data['message'] != null) {
            message = data['message'].toString();
          } else if (data.containsKey('error') && data['error'] != null) {
            message = data['error'].toString();
          } else if (data.containsKey('detail') && data['detail'] != null) {
            message = data['detail'].toString();
          }
        }

        return ServerException(message, code: statusCode);
      case DioExceptionType.connectionError:
        return NetworkException(NetworkErrorType.other, message: '');
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException || error.error is HttpException) {
          return NetworkException(NetworkErrorType.other, message: '');
        }

        return NetworkException(
          NetworkErrorType.other,
          message: error.message ?? 'Unexpected error occurred',
        );
    }
  }
}
