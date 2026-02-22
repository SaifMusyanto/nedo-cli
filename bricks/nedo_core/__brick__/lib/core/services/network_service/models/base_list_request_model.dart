// class BasePaginationRequest {
//   final String? search;
//   final Pagination? pagination;
//   final List<SortOption>? sort;
//   final List<FilterOption>? filter;

//   const BasePaginationRequest({
//     this.search,
//     this.pagination,
//     this.sort,
//     this.filter,
//   });

//   static BasePaginationRequest initial({int pageSize = 10}) =>
//       BasePaginationRequest(
//         pagination: Pagination(page: 1, pageSize: pageSize),
//         sort: <SortOption>[],
//         filter: <FilterOption>[],
//       );

//   Map<String, dynamic> toMap() {
//     return {
//       if (search != null) 'search': search,
//       if (pagination != null) 'pagination': pagination!.toMap(),
//       if (sort != null) 'sort': sort!.map((e) => e.toMap()).toList(),
//       if (filter != null) 'filter': filter!.map((e) => e.toMap()).toList(),
//     };
//   }
// }

// class Pagination {
//   final int page;
//   final int pageSize;

//   const Pagination({required this.page, required this.pageSize});

//   Map<String, dynamic> toMap() => {'page': page, 'pageSize': pageSize};
// }

// class SortOption {
//   final String field;
//   final String direction;

//   const SortOption({required this.field, required this.direction});

//   Map<String, dynamic> toMap() => {'field': field, 'direction': direction};
// }

// class FilterOption {
//   final String field;
//   final String operator;
//   final String value;

//   const FilterOption({
//     required this.field,
//     required this.operator,
//     required this.value,
//   });

//   Map<String, dynamic> toMap() => {
//     'field': field,
//     'operator': operator,
//     'value': value,
//   };
// }
