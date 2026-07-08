import 'package:base_app/core/models/generic_body_params.dart';

class GetAllChatsParameters extends BaseRequestModel {
  GetAllChatsParameters({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBeforPagination,
    super.orderDirection,
    super.includesPath = const [],
    super.additionalFilters,
    this.creatorId,
  });

  String? creatorId;

  @override
  Map<String, dynamic> buildFilters() {
    final filters = Map<String, dynamic>.from(super.buildFilters());
    if (creatorId != null) filters['CreatorId'] = int.parse(creatorId!);

    return filters;
  }

  GetAllChatsParameters copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    bool? orderBeforPagination,
    int? orderDirection,
    List<String>? includesPath,

    Map<String, dynamic>? additionalFilters,
    String? creatorId,
  }) {
    return GetAllChatsParameters(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBeforPagination: orderBeforPagination ?? this.orderBeforPagination,
      orderDirection: orderDirection ?? this.orderDirection,
      includesPath: includesPath ?? this.includesPath ?? [],
      additionalFilters: additionalFilters ?? super.filters,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}


