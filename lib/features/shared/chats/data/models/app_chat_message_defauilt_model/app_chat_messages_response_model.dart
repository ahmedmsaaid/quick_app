import '../date_formatter.dart';

class AppChatMessagesResponseModel {
  bool? success;
  int? statusCode;
  String? message;
  AppChatMessagesDataModel? result;

  AppChatMessagesResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.result,
  });

  factory AppChatMessagesResponseModel.fromJson(Map<String, dynamic> json) {
    return AppChatMessagesResponseModel(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
      result: json['result'] != null
          ? (json['result'] is List
              ? AppChatMessagesDataModel.fromJson(json)
              : AppChatMessagesDataModel.fromJson(json['result'] as Map<String, dynamic>))
          : null,
    );
  }
}

class AppChatMessagesDataModel {
  List<ChatMessageModel>? result;
  int? pageSize;
  int? pageIndex;
  int? totalCount;
  int? count;
  int? totalPages;
  bool? moveNext;
  bool? movePrevious;

  AppChatMessagesDataModel({
    this.result,
    this.pageSize,
    this.pageIndex,
    this.totalCount,
    this.count,
    this.totalPages,
    this.moveNext,
    this.movePrevious,
  });

  factory AppChatMessagesDataModel.fromJson(Map<String, dynamic> json) {
    return AppChatMessagesDataModel(
      result: json['result'] != null
          ? (json['result'] as List)
              .map((e) => ChatMessageModel.fromJson(e))
              .toList()
          : null,
      pageSize: json['pageSize'],
      pageIndex: json['pageIndex'] ?? json['pageNumber'],
      totalCount: json['totalCount'],
      count: json['count'],
      totalPages: json['totalPages'],
      moveNext: json['moveNext'],
      movePrevious: json['movePrevious'],
    );
  }
}

class ChatMessageModel {
  int? id;
  int? chatId;
  int? recipientId;
  int? creatorId;
  String? content;
  String? mediaUrl;
  bool? read;
  int? messageType;
  DateTime? readOn;
  String? createdOn;
  bool isRead;

  ChatMessageModel({
    this.id,
    this.chatId,
    required this.isRead,
    this.recipientId,
    this.creatorId,
    this.content,
    this.mediaUrl,
    this.read,
    this.messageType,
    this.readOn,
    this.createdOn,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      chatId: json['chatId'],
      recipientId: json['recipientId'],
      isRead: json['read'] ?? false,
      creatorId: json['creatorId'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      read: json['read'],
      messageType: json['messageType'],
      readOn: json['readOn'] != null ? DateTime.parse(json['readOn']) : null,
      createdOn: json['createdOn'] != null
          ? formatDateChatPMAM(DateTime.parse(json['createdOn']).toLocal())
          : null,
    );
  }
}
