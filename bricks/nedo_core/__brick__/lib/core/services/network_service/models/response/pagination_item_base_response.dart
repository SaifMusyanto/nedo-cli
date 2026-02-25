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
