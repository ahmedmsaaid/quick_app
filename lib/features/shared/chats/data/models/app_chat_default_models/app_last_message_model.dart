import '../date_formatter.dart';

class AppLastMessageModel {
  AppLastMessageModel({
    this.id,
    this.chatId,
    this.recipientId,
    this.creatorId,
    this.content,
    this.mediaUrl,
    this.read,
    this.messageType,
    this.readOn,
    this.createdOn,
  });

  AppLastMessageModel.fromJson(dynamic json) {
    id = json['id'];
    chatId = json['chatId'];
    recipientId = json['recipientId'];
    creatorId = json['creatorId'];
    content = json['content'];
    mediaUrl = json['mediaUrl'];
    read = json['read'];
    messageType = json['messageType'];
    readOn = json['readOn'];
    createdOn = formatDateChatPMAM(DateTime.parse(json['createdOn']).toLocal());
  }
  int? id;
  int? chatId;
  int? recipientId;
  int? creatorId;
  String? content;
  String? mediaUrl;
  bool? read;
  int? messageType;
  String? readOn;
  String? createdOn;
}
