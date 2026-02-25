import 'dart:io';

class BaseModelsGenerator {
  static const String _basePath = 'lib/core/services/network_service/models';

  static Future<void> generate() async {
    final requestDir = Directory('$_basePath/request');
    final responseDir = Directory('$_basePath/response');

    if (!requestDir.existsSync()) {
      requestDir.createSync(recursive: true);
    }
    if (!responseDir.existsSync()) {
      responseDir.createSync(recursive: true);
    }

    await Future.wait([
      // --- Request Files ---
      _writeFile(requestDir, 'base_pagination_request.dart',
          _basePaginationRequestContent),

      // --- Response Files ---
      _writeFile(responseDir, 'base_pagination_response.dart',
          _basePaginationResponseContent),
      _writeFile(responseDir, 'base_response.dart', _baseResponseContent),
      _writeFile(responseDir, 'pagination_item_base_response.dart',
          _paginationItemBaseResponseContent),
      _writeFile(
          responseDir, 'pagination_response.dart', _paginationResponseContent),
    ]);
  }

  static Future<void> _writeFile(
      Directory dir, String filename, String content) async {
    final file = File('${dir.path}/$filename');
    if (!file.existsSync()) {
      await file.writeAsString(content);
    }
  }

  // ---------------- REQUEST ----------------
  static const String _basePaginationRequestContent = r'''
class FilterRequestModel {
  final String field;
  final String operator;
  final String value;

  FilterRequestModel({
    required this.field,
    required this.operator,
    required this.value,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'field': field,
    'operator': operator,
    'value': value,
  };
}

class PaginationRequestModel {
  final int page;
  final int pageSize;

  PaginationRequestModel({this.page = 1, this.pageSize = 10});

  Map<String, dynamic> toMap() => <String, dynamic>{
    'page': page,
    'pageSize': pageSize,
  };
}

class SortRequestModel {
  final String field;
  final String direction;

  SortRequestModel({required this.field, required this.direction});

  Map<String, dynamic> toMap() => <String, dynamic>{
    'field': field,
    'direction': direction,
  };
}

class BasePaginationRequest {
  final String search;
  final PaginationRequestModel pagination;
  final List<SortRequestModel>? sort;
  final List<FilterRequestModel> filters;

  BasePaginationRequest({
    this.search = '',
    required this.pagination,
    this.sort,
    this.filters = const <FilterRequestModel>[],
  });

  BasePaginationRequest copyWith({
    String? search,
    PaginationRequestModel? pagination,
    List<SortRequestModel>? sort,
    List<FilterRequestModel>? filters,
  }) => BasePaginationRequest(
    search: search ?? this.search,
    pagination: pagination ?? this.pagination,
    sort: sort ?? this.sort,
    filters: filters ?? this.filters,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    if (search.isNotEmpty) 'search': search,
    if (pagination.page > 0) 'pagination': pagination.toMap(),

    if (sort != null && sort!.isNotEmpty)
      'sort': sort?.map((s) => s.toMap()).toList(),

    if (filters.isNotEmpty) 'filter': filters.map((f) => f.toMap()).toList(),
  };

  static BasePaginationRequest initial({int pageSize = 10}) =>
      BasePaginationRequest(
        pagination: PaginationRequestModel(pageSize: pageSize),
        sort: <SortRequestModel>[],
        filters: <FilterRequestModel>[],
      );
}
''';

  // ---------------- RESPONSE ----------------

  static const String _basePaginationResponseContent = r'''
import 'pagination_response.dart';

class BasePaginationResponse<T> {
  final List<T> items;
  final PaginationResponse pagination;

  BasePaginationResponse({required this.items, required this.pagination});

  factory BasePaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final List<T> itemsList =
        (json['items'] as List<dynamic>?)
            ?.map((dynamic item) => fromJsonT(item as Map<String, dynamic>))
            .toList() ??
        <T>[];
    final Map<String, dynamic>? paginationData =
        json['pagination'] as Map<String, dynamic>?;

    if (paginationData == null) {
      throw const FormatException('Pagination data is missing in the response');
    }

    return BasePaginationResponse<T>(
      items: itemsList,
      pagination: PaginationResponse.fromJson(paginationData),
    );
  }

  Map<String, Object> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'pagination': pagination.toJson(),
    };
  }

  @override
  String toString() {
    final itemsStr = items.map((e) => e.toString()).join(', ');
    return 'BasePaginationResponse{items: [$itemsStr], pagination: $pagination}';
  }
}
''';

  static const String _baseResponseContent = r'''
class BaseResponse<T> {
  final bool success;
  final String code;
  final String message;
  final T? data;

  const BaseResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'success': success,
      'code': code,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}
''';

  static const String _paginationItemBaseResponseContent = r'''
class PaginationBaseItemResponse {
  final int index;

  const PaginationBaseItemResponse({required this.index});

  factory PaginationBaseItemResponse.fromJson(Map<String, dynamic> json) {
    return PaginationBaseItemResponse(index: json['index'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'index': index};
  }
}
''';

  static const String _paginationResponseContent = r'''
class PaginationResponse {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationResponse({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationResponse.fromJson(Map<String, Object?> json) =>
      PaginationResponse(
        currentPage: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalItems: json['totalItems'] as int,
        totalPages: json['totalPages'] as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'currentPage': currentPage,
    'pageSize': pageSize,
    'totalItems': totalItems,
    'totalPages': totalPages,
  };
}
''';
}
