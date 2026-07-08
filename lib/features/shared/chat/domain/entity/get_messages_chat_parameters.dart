import 'package:base_app/core/models/generic_body_params.dart';

class GetMessagesChatParameters extends BaseRequestModel {
  final int? chatId;
  final int? targetUserId;

  GetMessagesChatParameters({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBeforPagination,
    super.orderDirection=0,
    super.includesPath = const [],
    super.additionalFilters,
    this.chatId,
    this.targetUserId,
  });

  @override
  Map<String, dynamic> buildFilters() {
    final filters = Map<String, dynamic>.from(super.buildFilters());
    return filters;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['chatId'] = chatId ?? 0;
    json['targetUserId'] = targetUserId ?? 0;
    return json;
  }

  GetMessagesChatParameters copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    bool? orderBeforPagination,
    int? orderDirection,
    List<String>? includesPath,
    Map<String, dynamic>? additionalFilters,
    int? chatId,
    int? targetUserId,
  }) {
    return GetMessagesChatParameters(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBeforPagination: orderBeforPagination ?? this.orderBeforPagination,
      orderDirection: orderDirection ?? this.orderDirection,
      includesPath: includesPath ?? this.includesPath ?? [],
      additionalFilters: additionalFilters ?? super.filters,
      chatId: chatId ?? this.chatId,
      targetUserId: targetUserId ?? this.targetUserId,
    );
  }
}


