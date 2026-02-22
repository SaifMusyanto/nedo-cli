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
