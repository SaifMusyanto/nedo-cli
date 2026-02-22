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

