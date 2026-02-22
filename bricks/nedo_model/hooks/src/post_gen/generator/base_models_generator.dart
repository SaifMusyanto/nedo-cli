import 'dart:io';

class BaseModelsGenerator {
  static Future<void> generate() async {
    final baseDir = Directory('lib/core/network/models');
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    await _writeFileIfMissing(
        baseDir, 'base_list_request_model.dart', _baseListRequestModelContent);
    await _writeFileIfMissing(baseDir, 'pagination_response_model.dart',
        _paginationResponseModelContent);
  }

  static Future<void> _writeFileIfMissing(
      Directory dir, String filename, String content) async {
    final file = File('${dir.path}/$filename');
    if (!file.existsSync()) {
      await file.writeAsString(content);
    }
  }

  static const String _baseListRequestModelContent = r'''
class BaseListRequestModel {
  final String? search;
  final Pagination? pagination;
  final List<SortOption>? sort;
  final List<FilterOption>? filter;

  const BaseListRequestModel({
    this.search,
    this.pagination,
    this.sort,
    this.filter,
  });

  static BaseListRequestModel initial({int pageSize = 10}) =>
      BaseListRequestModel(
        pagination: Pagination(page: 1, pageSize: pageSize),
        sort: <SortOption>[],
        filter: <FilterOption>[],
      );

  Map<String, dynamic> toMap() {
    return {
      if (search != null) 'search': search,
      if (pagination != null) 'pagination': pagination!.toMap(),
      if (sort != null) 'sort': sort!.map((e) => e.toMap()).toList(),
      if (filter != null) 'filter': filter!.map((e) => e.toMap()).toList(),
    };
  }
}

class Pagination {
  final int page;
  final int pageSize;

  const Pagination({required this.page, required this.pageSize});

  Map<String, dynamic> toMap() => {'page': page, 'pageSize': pageSize};
}

class SortOption {
  final String field;
  final String direction;

  const SortOption({required this.field, required this.direction});

  Map<String, dynamic> toMap() => {'field': field, 'direction': direction};
}

class FilterOption {
  final String field;
  final String operator;
  final String value;

  const FilterOption({
    required this.field,
    required this.operator,
    required this.value,
  });

  Map<String, dynamic> toMap() => {
        'field': field,
        'operator': operator,
        'value': value,
      };
}
''';

  static const String _paginationResponseModelContent = r'''
class PaginationResponseModel<T> {
  final List<T> items;
  final PaginationMetadata pagination;

  const PaginationResponseModel({
    required this.items,
    required this.pagination,
  });

  factory PaginationResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResponseModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationMetadata.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );
  }
}

class PaginationMetadata {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  const PaginationMetadata({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      totalItems: json['totalItems'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
''';
}
