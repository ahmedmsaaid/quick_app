import 'app_get_all_chats_result_model.dart';

class AppGetAllChatsResponseModel {
  bool? success;
  int? statusCode;
  String? message;
  AppChatDefaultPaginationModel? result;

  AppGetAllChatsResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.result,
  });

  factory AppGetAllChatsResponseModel.fromJson(Map<String, dynamic> json) {
    return AppGetAllChatsResponseModel(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
      result: json['result'] != null
          ? AppChatDefaultPaginationModel.fromJson(json['result'])
          : null,
    );
  }
}

class AppChatDefaultPaginationModel {
  int? pageSize;
  int? pageIndex;
  int? totalCount;
  int? count;
  int? totalPages;
  bool? moveNext;
  bool? movePrevious;
  List<AppGetAllChatsResultModel>? result;

  AppChatDefaultPaginationModel({
    this.pageSize,
    this.pageIndex,
    this.totalCount,
    this.count,
    this.totalPages,
    this.moveNext,
    this.movePrevious,
    required this.result,
  });

  factory AppChatDefaultPaginationModel.fromJson(Map<String, dynamic> json) {
    return AppChatDefaultPaginationModel(
      pageSize: json['pageSize'],
      pageIndex: json['pageIndex'],
      totalCount: json['totalCount'],
      count: json['count'],
      totalPages: json['totalPages'],
      moveNext: json['moveNext'],
      movePrevious: json['movePrevious'],
      result: json['result'] != null
          ? (json['result'] as List)
              .map((v) => AppGetAllChatsResultModel.fromJson(v))
              .toList()
          : null,
    );
  }
}
