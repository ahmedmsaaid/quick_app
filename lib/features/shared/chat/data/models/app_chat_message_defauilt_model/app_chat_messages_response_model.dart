import 'package:base_app/core/utils/format_date.dart';

class ChatMessageResultsModel {
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

  ChatMessageResultsModel({
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

  factory ChatMessageResultsModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageResultsModel(
      id: json['id'],
      chatId: json['chatId'],
      recipientId: json['recipientId'],
      isRead: json['read'],
      creatorId: json['creatorId'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      read: json['read'],
      messageType: json['messageType'],
      readOn: json['readOn'] != null ? DateTime.parse(json['readOn']) : null,
      createdOn: formatDateChatPMAM(
        DateTime.parse(json['createdOn']).toLocal(),
      ),
    );
  }
}


