import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:base_app/core/models/creator_response.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

part 'get_all_chats_result_response.g.dart';

@JsonSerializable()
class GetAllChatsResultResponse {
  int? id;
  int? participantId;
  int? creatorId;
  bool? ai;
  int? countUnReadMessages;
  String? createdOn;
  LastMessageInChatModel? message;
  CreatorResponse? creator;
  CreatorResponse? participant;


  GetAllChatsResultResponse({
    this.id,
    this.participantId,
    this.creatorId,
    this.ai,
    this.countUnReadMessages,
    this.createdOn,
    this.message,
    this.creator,
    this.participant
  });

  factory GetAllChatsResultResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllChatsResultResponseFromJson(json);
}

@JsonSerializable()
class LastMessageInChatModel {
  int? id;
  int? chatId;
  int? recipientId;
  int? creatorId;
  String? content;
  String? mediaUrl;
  bool? read;
  int? messageType;
  dynamic readOn;
  String? createdOn;

  LastMessageInChatModel({
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

  factory LastMessageInChatModel.fromJson(Map<String, dynamic> json) =>
      _$LastMessageInChatModelFromJson(json);
}


