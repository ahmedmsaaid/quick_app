/// Base class for all paginated request models.
/// Provides common pagination, search, ordering, and filter parameters.
class BaseRequestModel {
  final int pageNumber;
  final int pageSize;
  final String? search;
  final List<String>? searchFilter;
  final bool? orderBeforPagination;
  final int? orderDirection;
  final List<String>? includesPath;
  final Map<String, dynamic>? additionalFilters;

  BaseRequestModel({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
    this.searchFilter,
    this.orderBeforPagination,
    this.orderDirection,
    this.includesPath,
    this.additionalFilters,
  });

  /// Override in subclasses to add specific filters to the base map.
  Map<String, dynamic> buildFilters() {
    return additionalFilters ?? {};
  }

  /// Combined filter map used in API requests.
  Map<String, dynamic> get filters => buildFilters();

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (search != null && search!.isNotEmpty) 'search': search,
      if (searchFilter != null && searchFilter!.isNotEmpty) 'searchFilter': searchFilter,
      if (orderBeforPagination != null) 'orderBeforPagination': orderBeforPagination,
      if (orderDirection != null) 'orderDirection': orderDirection,
      if (includesPath != null && includesPath!.isNotEmpty) 'includesPath': includesPath,
      ...filters,
    };
  }
}
