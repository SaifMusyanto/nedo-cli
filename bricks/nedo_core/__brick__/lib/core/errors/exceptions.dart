import 'package:dio/dio.dart';

enum NetworkErrorType {
  connectTimeout,
  sendTimeout,
  receiveTimeout,
  cancel,
  other;

  static NetworkErrorType fromDioType(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout => NetworkErrorType.connectTimeout,
      DioExceptionType.sendTimeout => NetworkErrorType.sendTimeout,
      DioExceptionType.receiveTimeout => NetworkErrorType.receiveTimeout,
      DioExceptionType.cancel => NetworkErrorType.cancel,
      _ => NetworkErrorType.other,
    };
  }
}

class NetworkException implements Exception {
  final NetworkErrorType type;
  final String? message;

  NetworkException(this.type, {this.message});
}

class ServerException implements Exception {
  final String message;
  final int? code;

  ServerException(this.message, {this.code});
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}

