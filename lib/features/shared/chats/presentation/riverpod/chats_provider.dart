import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';

import '../../data/models/app_chat_default_models/app_get_all_chats_result_model.dart';
import '../../data/models/app_chat_message_model.dart';
import '../../data/models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';
import '../../data/models/app_message_type.dart';
import '../../data/models/date_formatter.dart';
import '../../data/chats_api_service.dart';
import 'grpc_providers.dart';

// --- Chats List State & Notifier ---

class ChatsListState {
  final List<AppGetAllChatsResultModel> chats;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int pageIndex;
  final String? error;

  ChatsListState({
    required this.chats,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.pageIndex = 1,
    this.error,
  });

  ChatsListState copyWith({
    List<AppGetAllChatsResultModel>? chats,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? pageIndex,
    String? error,
  }) {
    return ChatsListState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      pageIndex: pageIndex ?? this.pageIndex,
      error: error,
    );
  }
}

class ChatsListNotifier extends StateNotifier<ChatsListState> {
  final ChatsApiService _apiService;

  ChatsListNotifier(this._apiService) : super(ChatsListState(chats: []));

  Future<void> fetchChats({bool isRefresh = false, int? closedChatId}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (isRefresh) {
      state = state.copyWith(isLoading: true, pageIndex: 1, hasMore: true);
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final response = await _apiService.getChats(
        pageIndex: state.pageIndex,
        closedChatId: closedChatId,
      );
      final list = response.result?.result ?? [];
      final hasMore = response.result?.moveNext ?? false;

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        chats: isRefresh ? list : [...state.chats, ...list],
        pageIndex: state.pageIndex + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final chatsListProvider = StateNotifierProvider<ChatsListNotifier, ChatsListState>((ref) {
  final apiService = ref.watch(chatsApiServiceProvider);
  return ChatsListNotifier(apiService);
});

// --- Chat Room State & Notifier (Family-based by recipientId) ---

class ChatRoomState {
  final List<AppChatMessageGrpcModel> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int pageIndex;
  final bool isConnected;
  final int currentUserId;
  final String? error;

  ChatRoomState({
    required this.messages,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.pageIndex = 1,
    this.isConnected = false,
    required this.currentUserId,
    this.error,
  });

  ChatRoomState copyWith({
    List<AppChatMessageGrpcModel>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? pageIndex,
    bool? isConnected,
    int? currentUserId,
    String? error,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      pageIndex: pageIndex ?? this.pageIndex,
      isConnected: isConnected ?? this.isConnected,
      currentUserId: currentUserId ?? this.currentUserId,
      error: error,
    );
  }
}

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final ChatsApiService _apiService;
  final Dio _dio;
  final Ref _ref;
  final int recipientId;
  StreamSubscription<AppChatMessageGrpcModel>? _grpcSub;
  Timer? _pollTimer;

  ChatRoomNotifier(this._ref, this._apiService, this._dio, this.recipientId)
      : super(ChatRoomState(messages: [], currentUserId: 0)) {
    _initUserId();
  }

  void _initUserId() {
    try {
      final token = CacheHelper.getString(CacheKeys.token) ?? '';
      if (token.isNotEmpty) {
        final decoded = JwtDecoder.decode(token);
        final userIdStr = decoded['UserId'] ?? decoded['id'] ?? '0';
        final uid = int.parse(userIdStr);
        state = state.copyWith(currentUserId: uid);
      }
    } catch (e) {
      print('❌ Failed to parse user ID from token in ChatRoomNotifier: $e');
    }
  }

  Future<void> initChat({int? chatId}) async {
    // 1. Fetch initial history
    await fetchMessages(chatId: chatId, isRefresh: true);

    // 2. Connect to gRPC stream
    connectGrpc(chatId: chatId);
  }

  void connectGrpc({int? chatId}) {
    if (state.isConnected) return;
    try {
      final repo = _ref.read(chatGrpcRepositoryProvider);
      final stream = repo.connectToChat();

      _grpcSub = stream.listen(
        (msg) {
          if (msg.recipientId == state.currentUserId || msg.creatorId == state.currentUserId) {
            // Only add if doesn't exist
            final exists = state.messages.any((m) => m.id == msg.id);
            if (!exists) {
              state = state.copyWith(messages: [msg, ...state.messages]);
            }
          }
        },
        onError: (err) {
          print('❌ gRPC Stream error (activating REST polling): $err');
          state = state.copyWith(error: err.toString(), isConnected: false);
          _startRestPolling(chatId);
        },
        onDone: () {
          print('🔌 gRPC Stream closed (activating REST polling)');
          state = state.copyWith(isConnected: false);
          _startRestPolling(chatId);
        },
      );

      state = state.copyWith(isConnected: true);
    } catch (e) {
      print('❌ Failed to connect gRPC (activating REST polling): $e');
      state = state.copyWith(error: e.toString(), isConnected: false);
      _startRestPolling(chatId);
    }
  }

  void _startRestPolling(int? chatId) {
    if (_pollTimer != null) return;
    print('🔄 Restoring chat stream with REST Polling Fallback...');
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      await _syncMessages(chatId);
    });
  }

  Future<void> _syncMessages(int? chatId) async {
    try {
      final response = await _apiService.getChatMessages(
        chatId: chatId,
        targetUserId: chatId == null ? recipientId : null,
        currentUserId: chatId == null ? state.currentUserId : null,
        pageIndex: 1,
        pageSize: 30,
      );
      final list = response.result?.result ?? [];
      final List<AppChatMessageGrpcModel> newMessages = list
          .map((e) => AppChatMessageGrpcModel.fromDefaultModel(e))
          .toList();

      final List<AppChatMessageGrpcModel> merged = List.from(state.messages);
      bool stateChanged = false;
      for (final msg in newMessages) {
        if (!merged.any((m) => m.id == msg.id)) {
          merged.insert(0, msg);
          stateChanged = true;
        }
      }
      if (stateChanged) {
        state = state.copyWith(messages: merged);
      }
    } catch (e) {
      print('❌ Failed to sync messages via REST polling: $e');
    }
  }

  Future<void> fetchMessages({int? chatId, bool isRefresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (isRefresh) {
      state = state.copyWith(isLoading: true, pageIndex: 1, hasMore: true);
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final response = await _apiService.getChatMessages(
        chatId: chatId,
        targetUserId: chatId == null ? recipientId : null,
        currentUserId: chatId == null ? state.currentUserId : null,
        pageIndex: state.pageIndex,
      );

      final list = response.result?.result ?? [];
      final hasMore = response.result?.moveNext ?? false;

      final List<AppChatMessageGrpcModel> newMessages = list
          .map((e) => AppChatMessageGrpcModel.fromDefaultModel(e))
          .toList();

      final List<AppChatMessageGrpcModel> merged = List.from(state.messages);
      for (final msg in newMessages) {
        if (!merged.any((m) => m.id == msg.id)) {
          merged.add(msg);
        }
      }

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        messages: merged,
        pageIndex: state.pageIndex + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;

    final localMsg = AppChatMessageGrpcModel(
      chatId: 1,
      recipientId: recipientId,
      creatorId: state.currentUserId,
      content: content,
      id: UniqueKey().hashCode,
      isMe: true,
      type: AppMessageType.text,
      createdOn: formatDateChatPMAM(DateTime.now().toUtc().toLocal()),
    );

    // Optimistic UI update
    state = state.copyWith(messages: [localMsg, ...state.messages]);

    try {
      if (state.isConnected) {
        final repo = _ref.read(chatGrpcRepositoryProvider);
        await repo.sendMessage(
          recipientId: recipientId,
          message: content,
          type: AppMessageType.text,
        );
      } else {
        await _apiService.sendChatMessage(
          recipientId: recipientId,
          creatorId: state.currentUserId,
          content: content,
          messageType: AppMessageType.text.index,
        );
      }
    } catch (e) {
      print('❌ Failed to send gRPC text message, trying REST fallback: $e');
      try {
        await _apiService.sendChatMessage(
          recipientId: recipientId,
          creatorId: state.currentUserId,
          content: content,
          messageType: AppMessageType.text.index,
        );
      } catch (restErr) {
        print('❌ REST fallback send failed: $restErr');
        state = state.copyWith(error: 'فشل إرسال الرسالة');
      }
    }
  }

  Future<void> sendMediaMessage(AppMessageType type, List<File> files, String? caption) async {
    if (files.isEmpty) return;

    try {
      final urls = await Future.wait(
        files.map((file) => _uploadFile(file)),
      );

      // If caption exists and we have multiple images, send caption first
      if (caption != null && caption.trim().isNotEmpty && urls.length > 1) {
        await sendTextMessage(caption.trim());
        caption = null;
      }

      for (int i = 0; i < urls.length; i++) {
        final currentCaption = (urls.length == 1) ? caption : null;
        final imageUrl = urls[i];

        final localMsg = AppChatMessageGrpcModel(
          chatId: 1,
          recipientId: recipientId,
          creatorId: state.currentUserId,
          content: currentCaption,
          mediaUrl: imageUrl,
          id: UniqueKey().hashCode,
          isMe: true,
          type: type,
          createdOn: formatDateChatPMAM(DateTime.now().toUtc().toLocal()),
        );

        state = state.copyWith(messages: [localMsg, ...state.messages]);

        try {
          if (state.isConnected) {
            final repo = _ref.read(chatGrpcRepositoryProvider);
            await repo.sendMessage(
              recipientId: recipientId,
              message: currentCaption,
              type: type,
              mediaUrl: imageUrl,
            );
          } else {
            await _apiService.sendChatMessage(
              recipientId: recipientId,
              creatorId: state.currentUserId,
              content: currentCaption,
              mediaUrl: imageUrl,
              messageType: type.index,
            );
          }
        } catch (e) {
          print('❌ Failed to send gRPC media message, trying REST fallback: $e');
          try {
            await _apiService.sendChatMessage(
              recipientId: recipientId,
              creatorId: state.currentUserId,
              content: currentCaption,
              mediaUrl: imageUrl,
              messageType: type.index,
            );
          } catch (restErr) {
            print('❌ REST fallback media send failed: $restErr');
            state = state.copyWith(error: 'فشل إرسال الوسائط');
          }
        }
      }
    } catch (e) {
      print('❌ Failed to upload or send media message: $e');
      state = state.copyWith(error: 'فشل إرسال الوسائط');
    }
  }

  Future<String> _uploadFile(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'type': 1,
    });
    final response = await _dio.post(
      'stream/public',
      data: formData,
    );
    final success = response.data['success'] as bool? ?? false;
    final result = response.data['result'] as String?;
    if (success && result != null) {
      return "${ApiConstants.streamUrl}$result";
    }
    throw Exception(response.data['message'] ?? 'فشل رفع الملف');
  }

  void disconnect() {
    _grpcSub?.cancel();
    _pollTimer?.cancel();
    _pollTimer = null;
    try {
      _ref.read(chatGrpcRepositoryProvider).disconnect();
    } catch(e) {}
    state = state.copyWith(isConnected: false);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final chatRoomProvider = StateNotifierProvider.family<ChatRoomNotifier, ChatRoomState, int>((ref, recipientId) {
  final apiService = ref.watch(chatsApiServiceProvider);
  final dio = ref.watch(dioProvider);
  return ChatRoomNotifier(ref, apiService, dio, recipientId);
});
