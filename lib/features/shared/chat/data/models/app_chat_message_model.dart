import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:base_app/core/utils/format_date.dart';
import '../data_source/generated/Chat.pb.dart' as pb;
import 'app_chat_message_defauilt_model/app_chat_messages_response_model.dart';
import 'app_message_type.dart';

class AppChatMessageGrpcModel extends Equatable {
  final int chatId;
  final int? id;
  final int recipientId;
  final int creatorId;
  final String? content;
  final AppMessageType type;
  final String? mediaUrl;
  final String createdOn;
  final bool isMe;
  final bool isRead;
  final DateTime? readOn;

  const AppChatMessageGrpcModel({
    required this.chatId,
    required this.recipientId,
    this.isRead = false,
    this.readOn,
    this.id,
    this.isMe = false,
    required this.creatorId,
    this.content,
    required this.type,
    this.mediaUrl,
    required this.createdOn,
  });

  factory AppChatMessageGrpcModel.fromProto(pb.GrpcRrecipientMessage proto) {
    return AppChatMessageGrpcModel(
      chatId: proto.chatId.toInt(),
      id: UniqueKey().hashCode,
      recipientId: proto.recipientId.toInt(),
      creatorId: proto.creatorId.toInt(),
      content: proto.hasContent() ? proto.content : null,
      type: AppMessageType.fromProtoValue(proto.type.value),
      mediaUrl: proto.hasMediaUrl() ? proto.mediaUrl : null,
      createdOn: formatDateChatPMAM(
        DateTime.fromMillisecondsSinceEpoch(
          proto.createdOn.seconds.toInt() * 1000 +
              proto.createdOn.nanos ~/ 1000000,
        ).toLocal(),
      ),
    );
  }

  @override
  List<Object?> get props => [
    chatId,
    recipientId,
    creatorId,
    content,
    type,
    mediaUrl,
    createdOn,
    isRead,
    readOn,
  ];

  AppChatMessageGrpcModel copyWith({
    int? chatId,
    int? id,
    int? recipientId,
    int? creatorId,
    String? content,
    AppMessageType? type,
    String? mediaUrl,
    String? createdOn,
    bool? isMe,
    bool? isRead,
    DateTime? readOn,
  }) {
    return AppChatMessageGrpcModel(
      chatId: chatId ?? this.chatId,
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      creatorId: creatorId ?? this.creatorId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdOn: createdOn ?? this.createdOn,
      isMe: isMe ?? this.isMe,
      isRead: isRead ?? this.isRead,
      readOn: readOn ?? this.readOn,
    );
  }

  static AppChatMessageGrpcModel fromDefaultModel(ChatMessageResultsModel e) {
    return AppChatMessageGrpcModel(
      chatId: e.chatId ?? 0,
      id: e.id,
      isRead: e.isRead,
      readOn: e.readOn,
      recipientId: e.recipientId ?? 0,
      creatorId: e.creatorId ?? 0,
      content: e.content,
      type: AppMessageType.fromProtoValue(e.messageType ?? 0),
      mediaUrl: e.mediaUrl,
      createdOn: e.createdOn != null
          ? e.createdOn!
          : DateTime.now().toUtc().toLocal().toString(),
    );
  }
}


