// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_chats_result_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllChatsResultResponse _$GetAllChatsResultResponseFromJson(
  Map<String, dynamic> json,
) => GetAllChatsResultResponse(
  id: (json['id'] as num?)?.toInt(),
  participantId: (json['participantId'] as num?)?.toInt(),
  creatorId: (json['creatorId'] as num?)?.toInt(),
  ai: json['ai'] as bool?,
  countUnReadMessages: (json['countUnReadMessages'] as num?)?.toInt(),
  createdOn: json['createdOn'] as String?,
  message: json['message'] == null
      ? null
      : LastMessageInChatModel.fromJson(
          json['message'] as Map<String, dynamic>,
        ),
  creator: json['creator'] == null
      ? null
      : UserDto.fromJson(json['creator'] as Map<String, dynamic>),
  participant: json['participant'] == null
      ? null
      : UserDto.fromJson(json['participant'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetAllChatsResultResponseToJson(
  GetAllChatsResultResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'participantId': instance.participantId,
  'creatorId': instance.creatorId,
  'ai': instance.ai,
  'countUnReadMessages': instance.countUnReadMessages,
  'createdOn': instance.createdOn,
  'message': instance.message,
  'creator': instance.creator,
  'participant': instance.participant,
};

LastMessageInChatModel _$LastMessageInChatModelFromJson(
  Map<String, dynamic> json,
) => LastMessageInChatModel(
  id: (json['id'] as num?)?.toInt(),
  chatId: (json['chatId'] as num?)?.toInt(),
  recipientId: (json['recipientId'] as num?)?.toInt(),
  creatorId: (json['creatorId'] as num?)?.toInt(),
  content: json['content'] as String?,
  mediaUrl: json['mediaUrl'] as String?,
  read: json['read'] as bool?,
  messageType: (json['messageType'] as num?)?.toInt(),
  readOn: json['readOn'],
  createdOn: json['createdOn'] as String?,
);

Map<String, dynamic> _$LastMessageInChatModelToJson(
  LastMessageInChatModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'chatId': instance.chatId,
  'recipientId': instance.recipientId,
  'creatorId': instance.creatorId,
  'content': instance.content,
  'mediaUrl': instance.mediaUrl,
  'read': instance.read,
  'messageType': instance.messageType,
  'readOn': instance.readOn,
  'createdOn': instance.createdOn,
};
