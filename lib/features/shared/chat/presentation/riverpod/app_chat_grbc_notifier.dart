// lib/features/chat/presentation/providers/app_chat_grbc_notifier.dart
import 'dart:async';
import 'dart:io';

import 'package:base_app/core/network/api_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/utils/jwt_helper.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:base_app/features/customer/stream/data/repo/stream_repo_impl.dart';
import 'package:base_app/core/network/dio_factory.dart';

import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/utils/format_date.dart';
import 'package:base_app/core/pagination/riverpod/pagination_state.dart';
import '../../data/models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';
import '../../data/models/app_chat_message_model.dart';
import '../../data/models/app_message_type.dart';
import '../../data/repo/app_chat_default_repository.dart';
import '../../data/repo/app_chat_grbc_repository.dart';
import '../../domain/entity/get_messages_chat_parameters.dart';
import 'app_chat_grbc_state.dart';
import 'get_all_messages_riverpod/get_all_messages_notifier.dart';

part 'app_chat_grbc_notifier.g.dart';

@riverpod
class AppChatGrbcNotifier extends _$AppChatGrbcNotifier {
  late int _currentUserId;
  AppChatGrbcRepository? _repository;

  StreamSubscription<AppChatMessageGrpcModel>? _chatSubscription;
  final List<AppChatMessageGrpcModel> _messages = [];

  // REST fallback state
  bool _isGrpcConnected = false;
  int? _chatId;
  int? _targetUserId;

  @override
  AppChatGrbcState build() {
    ref.onDispose(_cleanup);
    return const AppChatGrbcState.initial();
  }

  void _cleanup() {
    print('\n🚪 ═══════════════════════════════════════════════════════');
    print('🚪 Riverpod disposing resources...');

    _chatSubscription?.cancel();
    _repository?.disconnect();
    _messages.clear();
    _chatId = null;
    _targetUserId = null;
    _isGrpcConnected = false;

    print('✅ All resources cleaned up!');
    print('═══════════════════════════════════════════════════════\n');
  }

  Future<void> connect({int? chatId, int? targetUserId}) async {
    _chatId = chatId;
    _targetUserId = targetUserId;
    _messages.clear();

    state = const AppChatGrbcState.connecting();

    print('\n🔗 ═══════════════════════════════════════════════════════');
    print('📱 Starting connection for chatId: $_chatId, targetUserId: $_targetUserId...');

    try {
      final extractedId = await JwtHelper.getUserId();
      if (extractedId == null) {
        print('❌ Failed to extract user ID from token');
        state = const AppChatGrbcState.error(
          'فشل استخراج معرف المستخدم من الـ token',
        );
        return;
      }

      _currentUserId = int.parse(extractedId);
      print('✅ Current User ID: $_currentUserId');

      _repository = ref.read(appChatGrbcRepositoryProvider);

      final stream = _repository!.connectToChat(targetUserId ?? _targetUserId ?? 0);

      _chatSubscription = stream.listen(
        (message) {
          print('\n📨 ═══════════════════════════════════════════════════════');
          print('📩 Received message from stream:');
          print('   • From: ${message.creatorId}');
          print('   • To: ${message.recipientId}');
          print('   • Content: ${message.content}');
          print('   • Type: ${message.type}');
          print('   • Time: ${message.createdOn}');
          print('   • ChatId: ${message.chatId}');

          final isForCurrentChat = (_chatId != null && _chatId != 0 && message.chatId == _chatId) ||
              ((_chatId == null || _chatId == 0) && _targetUserId != null && _targetUserId != 0 &&
                  (message.creatorId == _targetUserId || message.recipientId == _targetUserId));

          if ((message.recipientId == _currentUserId ||
                  message.creatorId == _currentUserId) && isForCurrentChat) {
            print('✅ Message is for current active chat, adding to list');
            addMessage(message);
          } else {
            print('⚠️ Message is not for current open chat screen, skipping UI update');
          }
        },
        onError: (error) {
          print('\n[STREAM STATUS] ❌ ERROR ══════════════════════════════════');
          print('❌ gRPC Stream encountered an error: $error');
          print('═══════════════════════════════════════════════════════\n');
          _isGrpcConnected = false;
          _repository?.markStreamDead();
        },
        onDone: () {
          print('\n[STREAM STATUS] 🔴 DISCONNECTED ══════════════════════════');
          print('🔌 gRPC Stream closed by server (onDone)');
          print('═══════════════════════════════════════════════════════\n');
          _isGrpcConnected = false;
          _repository?.markStreamDead();
        },
      );

      _isGrpcConnected = true;
      state = AppChatGrbcState.connected(currentUserId: _currentUserId);
      print('\n[STREAM STATUS] 🟢 CONNECTED ═════════════════════════════');
      print('✅ gRPC Stream is now active for recipientId: ${targetUserId ?? _targetUserId}');
      print('═══════════════════════════════════════════════════════\n');
    } catch (e) {
      print('\n[STREAM STATUS] ❌ CONNECTION FAILED ═════════════════════');
      print('❌ gRPC connection failed: $e');
      print('═══════════════════════════════════════════════════════\n');
      _isGrpcConnected = false;
    }
  }



  Future<void> _syncNewMessages() async {
    try {
      final repo = ref.read(appChatDefaultRepoProvider);
      final params = GetMessagesChatParameters(
        chatId: _chatId,
        targetUserId: _targetUserId,
        pageNumber: 1,
        pageSize: 50,
      );
      final result = await repo.getAllMessages(params);
      result.when(
        success: (paginated) {
          final fetched = paginated.items
              .map((item) => AppChatMessageGrpcModel.fromDefaultModel(item))
              .where((m) => m.content != 'register') // Skip register handshake
              .toList();

          // Merge: add only messages not already in _messages (by id)
          final existingIds = _messages.map((m) => m.id).toSet();
          final newOnes = fetched
              .where((m) => !existingIds.contains(m.id))
              .toList();

          if (newOnes.isNotEmpty) {
            _messages.addAll(newOnes);
            // Sort messages by id to preserve exact chronological order
            _messages.sort((a, b) => a.id!.compareTo(b.id??0));
            state = AppChatGrbcState.loaded(
              messages: List.from(_messages),
              currentUserId: _currentUserId,
            );
            print('📬 REST poll: added ${newOnes.length} new message(s)');
          }
        },
        failure: (err) {
          print('⚠️ REST poll failed: ${err.message}');
        },
      );
    } catch (e) {
      print('⚠️ REST poll exception: $e');
    }
  }

  Future<void> getAllMessages({int? chatId, int? targetUserId}) async {
    // Store for polling reuse
    _chatId = chatId;
    _targetUserId = targetUserId;

    print('\n📥 ═══════════════════════════════════════════════════════');
    print('📥 Loading all messages for chat: $chatId');

    try {
      _messages.clear();
      state = const AppChatGrbcState.connecting();

      await ref
          .read(getAllMessagesChatProvider.notifier)
          .getAllMessages(chatId: chatId, targetUserId: targetUserId);

      final messagesState = ref.read(getAllMessagesChatProvider);
      final messages = messagesState.maybeWhen(
        data: (items, hasMore, page) => items,
        orElse: () => <ChatMessageResultsModel>[],
      );

      print('✅ Loaded ${messages.length} old messages');

      _messages.clear();
      for (var item in messages) {
        if (item.content == 'register') continue; // Skip register handshake
        _messages.add(AppChatMessageGrpcModel.fromDefaultModel(item));
      }

      state = AppChatGrbcState.loaded(
        messages: List.from(_messages),
        currentUserId: _currentUserId,
      );
    } catch (e) {
      print('❌ Failed to load messages: $e');
      state = AppChatGrbcState.error('فشل تحميل الرسائل: $e');
    }
  }

  void addMessage(AppChatMessageGrpcModel message) {
    if (message.content == 'register') return; // Skip register handshake

    print('\n➕ ═══════════════════════════════════════════════════════');
    print('➕ Adding message to list:');
    print('   • Creator: ${message.creatorId}');
    print('   • Content: ${message.content}');

    _messages.add(message);
    print('📋 Total messages now: ${_messages.length}');

    state = AppChatGrbcState.loaded(
      messages: List.from(_messages),
      currentUserId: _currentUserId,
    );
    print('✅ State emitted: ChatLoaded');
    print('═══════════════════════════════════════════════════════\n');
  }

  Future<void> sendTextMessage({
    required int recipientId,
    required String message,
    int? chatId,
  }) async {
    if (message.trim().isEmpty) return;

    print('\n📤 ═══════════════════════════════════════════════════════');
    print('📤 Sending text message:');
    print('   • From: $_currentUserId');
    print('   • To: $recipientId');
    print('   • Via: gRPC');

    state = const AppChatGrbcState.sendingMessage();

    // Optimistically add the message to the UI
    final localMessage = AppChatMessageGrpcModel(
      creatorId: _currentUserId,
      recipientId: recipientId,
      content: message,
      id: UniqueKey().hashCode,
      isMe: true,
      type: AppMessageType.text,
      chatId: chatId ?? _chatId ?? 0,
      createdOn: formatDateChatPMAM(DateTime.now().toUtc().toLocal()),
    );

    addMessage(localMessage);

    try {
      if (_repository == null) {
        throw Exception('gRPC not initialized');
      }

      // gRPC is the only send channel
      await _repository!.sendMessage(
        recipientId: recipientId,
        message: message,
        type: AppMessageType.text,
      );
      print('✅ Message sent via gRPC');

      state = AppChatGrbcState.messageSent(currentUserId: _currentUserId);
      state = AppChatGrbcState.loaded(
        messages: List.from(_messages),
        currentUserId: _currentUserId,
      );

      print('═══════════════════════════════════════════════════════\n');
    } catch (e) {
      print('❌ Failed to send via gRPC: $e');

      // Remove the optimistic message — don't leave a fake unsaved message
      _messages.removeWhere((m) => m.id == localMessage.id);

      state = AppChatGrbcState.error('فشل الإرسال: $e');

      await Future.delayed(const Duration(seconds: 2));
      state = AppChatGrbcState.loaded(
        messages: List.from(_messages),
        currentUserId: _currentUserId,
      );
    }
  }

  Future<void> sendVoiceRecordMessage({
    required int recipientId,
    required String filePath,
  }) async {
    if (filePath.isEmpty) return;

    print('\n🎙️ ═══════════════════════════════════════════════════════');
    print('🎙️ Sending voice record message:');
    print('   • From: $_currentUserId');
    print('   • To: $recipientId');
    print('   • Path: $filePath');

    state = const AppChatGrbcState.sendingMessage();

    // Optimistically add the message to the UI
    final localMessage = AppChatMessageGrpcModel(
      creatorId: _currentUserId,
      recipientId: recipientId,
      content: "[تسجيل صوتي]",
      id: UniqueKey().hashCode,
      isMe: true,
      type: AppMessageType.audio,
      mediaUrl: filePath,
      chatId: _chatId ?? 0,
      createdOn: formatDateChatPMAM(DateTime.now().toUtc().toLocal()),
    );

    addMessage(localMessage);

    try {
      if (_repository == null) {
        throw Exception('gRPC not initialized');
      }

      // 1. Upload audio file directly using Dio
      final filename = filePath.split('/').last;
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filename,
          contentType: MediaType('audio', 'm4a'),
        ),
      });

      final response = await dio.post(
        'stream/public',
        queryParameters: {'streamType': 0},
        data: formData,
      );

      final success = response.data['success'] as bool? ?? false;
      if (!success) {
        throw Exception(response.data['message'] ?? 'Failed to upload audio');
      }

      final uploadedUrl = response.data['result'] as String?;
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        throw Exception('Uploaded URL is empty');
      }

      print('✅ Voice record uploaded: $uploadedUrl');

      // 2. Send message via gRPC with the uploaded URL
      await _repository!.sendMessage(
        recipientId: recipientId,
        mediaUrl: uploadedUrl,
        type: AppMessageType.audio,
      );
      print('✅ Voice message sent via gRPC');

      // Update the local message's mediaUrl to the remote uploaded URL
      final index = _messages.indexWhere((m) => m.id == localMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(mediaUrl: uploadedUrl);
      }

      state = AppChatGrbcState.messageSent(currentUserId: _currentUserId);
      state = AppChatGrbcState.loaded(
        messages: List.from(_messages),
        currentUserId: _currentUserId,
      );

      print('═══════════════════════════════════════════════════════\n');
    } catch (e) {
      print('❌ Failed to send voice message: $e');

      _messages.removeWhere((m) => m.id == localMessage.id);

      state = AppChatGrbcState.error('فشل إرسال التسجيل الصوتي: $e');

      await Future.delayed(const Duration(seconds: 2));
      state = AppChatGrbcState.loaded(
        messages: List.from(_messages),
        currentUserId: _currentUserId,
      );
    }
  }

  Future<void> refreshFromPush() async {
    print('🔄 refreshFromPush called');
    final isLoaded = state.maybeWhen(
      loaded: (_, __) => true,
      connected: (_) => true,
      orElse: () => false,
    );
    if (!isLoaded) {
      print('⚠️ Notifier not in active chat state, skipping push refresh');
      return;
    }
    await _syncNewMessages();
  }

  bool isMyMessage(int creatorId) {
    return creatorId == _currentUserId;
  }

  Future<void> disconnect() async {
    print('\n🔌 ═══════════════════════════════════════════════════════');
    print('🔌 Disconnecting...');

    await _chatSubscription?.cancel();
    await _repository?.disconnect();
    _messages.clear();
    _chatId = null;
    _targetUserId = null;
    _isGrpcConnected = false;

    print('✅ Disconnected successfully');
    print('═══════════════════════════════════════════════════════\n');
  }

  Future<void> retry() async {
    print('\n🔄 ═══════════════════════════════════════════════════════');
    print('🔄 Retrying connection...');
    _isGrpcConnected = false;
    await connect();
  }
}
