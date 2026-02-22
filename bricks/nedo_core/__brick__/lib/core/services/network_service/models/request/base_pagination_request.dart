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
