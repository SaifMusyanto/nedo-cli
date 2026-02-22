// class PaginationResponseModel<T> {
//   final List<T> items;
//   final PaginationMetadata pagination;

//   const PaginationResponseModel({
//     required this.items,
//     required this.pagination,
//   });

//   factory PaginationResponseModel.fromJson(
//     Map<String, dynamic> json,
//     T Function(Map<String, dynamic>) fromJsonT,
//   ) {
//     return PaginationResponseModel(
//       items: (json['items'] as List<dynamic>)
//           .map((e) => fromJsonT(e as Map<String, dynamic>))
//           .toList(),
//       pagination: PaginationMetadata.fromJson(
//         json['pagination'] as Map<String, dynamic>,
//       ),
//     );
//   }
// }

// class PaginationMetadata {
//   final int page;
//   final int pageSize;
//   final int totalItems;
//   final int totalPages;

//   const PaginationMetadata({
//     required this.page,
//     required this.pageSize,
//     required this.totalItems,
//     required this.totalPages,
//   });

//   factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
//     return PaginationMetadata(
//       page: json['page'] as int,
//       pageSize: json['pageSize'] as int,
//       totalItems: json['totalItems'] as int,
//       totalPages: json['totalPages'] as int,
//     );
//   }
// }
