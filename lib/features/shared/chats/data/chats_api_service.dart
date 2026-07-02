import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'models/app_chat_default_models/app_get_all_chats_response_model.dart';
import 'models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';

final chatsApiServiceProvider = Provider<ChatsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatsApiService(dio);
});

class ChatsApiService {
  final Dio _dio;

  ChatsApiService(this._dio);

  Future<AppGetAllChatsResponseModel> getChats({
    required int pageIndex,
    int pageSize = 15,
    int? closedChatId,
  }) async {
    final response = await _dio.patch(
      'chats',
      data: {
        'pageNumber': pageIndex,
        'pageSize': pageSize,
        if (closedChatId != null) 'closedChatId': closedChatId,
      },
    );
    return AppGetAllChatsResponseModel.fromJson(response.data);
  }

  Future<AppChatMessagesResponseModel> getChatMessages({
    int? chatId,
    int? targetUserId,
    int? currentUserId,
    required int pageIndex,
    int pageSize = 20,
    int sortDirection = 1,
    String? search,
  }) async {
    final response = await _dio.patch(
      'messages',
      data: {
        'pageNumber': pageIndex,
        'pageSize': pageSize,
        if (chatId != null) 'chatId': chatId,
        if (targetUserId != null) 'targetUserId': targetUserId,
        if (currentUserId != null) 'userId': currentUserId,
        'sortDirection': sortDirection,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return AppChatMessagesResponseModel.fromJson(response.data);
  }

  Future<void> sendChatMessage({
    int? chatId,
    required int recipientId,
    required int creatorId,
    String? content,
    String? mediaUrl,
    int messageType = 0,
  }) async {
    await _dio.post(
      'messages',
      data: {
        if (chatId != null) 'chatId': chatId,
        'recipientId': recipientId,
        'creatorId': creatorId,
        if (content != null) 'content': content,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        'messageType': messageType,
      },
    );
  }
}
