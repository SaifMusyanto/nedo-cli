import 'package:dio/dio.dart';
import 'package:moncube_mobile/core/services/network_service/dio_client.dart';
import 'package:moncube_mobile/core/services/network_service/models/response/base_pagination_response.dart';

final voidType = _getType<void>();
Type _getType<T>() => T;

mixin CustomDioMixin {
  Future<List<T>> handleGetList<T>(
    DioClient dioClient, {
    required String endpoint,
    required T Function(Map<String, dynamic> json) itemMapper,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String itemsKey = 'data',
  }) async {
    final Response<dynamic> response = await dioClient.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );

    final dynamic rawData = response.data;

    if (rawData is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format from server');
    }

    final dynamic listData = rawData[itemsKey];

    if (listData is! List) {
      throw FormatException(
        'Expected a list under key "$itemsKey", got ${listData.runtimeType}',
      );
    }

    return listData
        .map<T>((e) => itemMapper(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<T>> handlePostList<T>(
    DioClient dioClient, {
    required String endpoint,
    required Object body,
    required T Function(Map<String, dynamic> json) itemMapper,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String itemsKey = 'data',
  }) async {
    final Response<dynamic> response = await dioClient.post(
      endpoint,
      data: body,
      queryParameters: queryParameters,
      options: options,
    );

    final dynamic rawData = response.data;

    if (rawData is! Map<String, dynamic>) {
      throw const FormatException('Invalid response format from server');
    }

    final dynamic listData = rawData[itemsKey];

    if (listData is! List) {
      throw FormatException(
        'Expected a list under key "$itemsKey", got ${listData.runtimeType}',
      );
    }

    return listData
        .map<T>((e) => itemMapper(e as Map<String, dynamic>))
        .toList();
  }

  Future<BasePaginationResponse<T>> handlePagination<T>(
    DioClient dioClient, {
    required String endpoint,
    required Map<String, dynamic> requestBody,
    required T Function(Map<String, dynamic> json) itemMapper,
    String itemsKey = 'items',
    String? indexKey,
  }) async {
    final Response<dynamic> response = await dioClient.post(
      endpoint,
      data: requestBody,
    );

    final Map<String, dynamic>? data = getResponseData(response.data);

    if (data == null) {
      throw const FormatException('Invalid response format from server');
    }

    final List<dynamic> items = data[itemsKey] as List<dynamic>;

    return BasePaginationResponse<T>.fromJson(data, (
      Map<String, dynamic> json,
    ) {
      if (indexKey != null) {
        final int index = items.indexOf(json) + 1;
        return itemMapper(<String, dynamic>{...json, indexKey: index});
      }
      return itemMapper(json);
    });
  }

  Future<T> handleGet<T>(
    DioClient dioClient, {
    required String endpoint,
    T Function(Map<String, dynamic> json)? mapper,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final Response<dynamic> response = await dioClient.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );

    final data = getResponseData(response.data);

    if (data == null) {
      throw const FormatException('Invalid response format from server');
    }
    if (mapper == null) {
      return data as T;
    } else {
      return mapper(data);
    }
  }

  Future<T> handlePost<T>(
    DioClient dioClient, {
    required String endpoint,
    required Object body,
    T Function(Map<String, dynamic> json)? mapper,
    bool getRawResponse = false,
    Options? options,
  }) async {
    final Response<dynamic> response = await dioClient.post(
      endpoint,
      data: body,
      options: options,
    );

    if (T == voidType) {
      return Future<T>.value();
    }

    final dynamic data = getRawResponse
        ? response.data
        : getResponseData(response.data);

    if (data == null) {
      throw const FormatException('Invalid response format from server');
    }

    if (data is T) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (mapper == null) {
        throw ArgumentError('Mapper is required for type $T');
      }
      return mapper(data);
    }

    throw FormatException(
      'Unsupported response type: ${data.runtimeType} for expected type $T',
    );
  }

  Future<T> handlePut<T>(
    DioClient dioClient, {
    required String endpoint,
    required Object body,
    T Function(Map<String, dynamic> json)? mapper,
    Options? options,
  }) async {
    final Response<dynamic> response = await dioClient.put(
      endpoint,
      data: body,
      options: options,
    );

    if (T == voidType) {
      return Future<T>.value();
    }

    final Map<String, dynamic>? data = getResponseData(response.data);

    if (data == null) {
      throw const FormatException('Invalid response format from server');
    }

    if (mapper == null) {
      throw ArgumentError('Mapper is required when T is not void');
    }

    return mapper(data);
  }

  Future<T> handlePatch<T>(
    DioClient dioClient, {
    required String endpoint,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic> json)? mapper,
    Options? options,
  }) async {
    final Response<dynamic> response = await dioClient.patch(
      endpoint,
      data: body,
      options: options,
    );

    if (T == voidType) {
      return Future<T>.value();
    }

    final Map<String, dynamic>? data = getResponseData(response.data);

    if (data == null) {
      throw const FormatException('Invalid response format from server');
    }

    if (mapper == null) {
      throw ArgumentError('Mapper is required when T is not void');
    }

    return mapper(data);
  }

  Future<T> handleDelete<T>(
    DioClient dioClient, {
    required String endpoint,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic> json)? mapper,
    Options? options,
  }) async {
    final Response<dynamic> response = await dioClient.delete(
      endpoint,
      data: body,
      options: options,
    );

    if (T == voidType) {
      return Future<T>.value();
    }

    final Map<String, dynamic>? data = getResponseData(response.data);

    if (data == null) {
      throw const FormatException('Invalid response format from server');
    }

    if (mapper == null) {
      throw ArgumentError('Mapper is required when T is not void');
    }

    return mapper(data);
  }

  dynamic getResponseData(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'];
    }
    return null;
  }
}
