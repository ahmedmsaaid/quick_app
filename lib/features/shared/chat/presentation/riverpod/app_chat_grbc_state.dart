// lib/features/chat/presentation/providers/app_chat_grbc_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/app_chat_message_model.dart';

part 'app_chat_grbc_state.freezed.dart';

@freezed
class AppChatGrbcState with _$AppChatGrbcState {
  const factory AppChatGrbcState.initial() = _Initial;

  const factory AppChatGrbcState.connecting() = _Connecting;

  const factory AppChatGrbcState.connected({
    required int currentUserId,
  }) = _Connected;

  const factory AppChatGrbcState.sendingMessage() = _SendingMessage;

  const factory AppChatGrbcState.messageSent({
    required int currentUserId,
  }) = _MessageSent;

  const factory AppChatGrbcState.loaded({
    required List<AppChatMessageGrpcModel> messages,
    required int currentUserId,
  }) = _Loaded;

  const factory AppChatGrbcState.error(String message) = _Error;

  const factory AppChatGrbcState.disconnected() = _Disconnected;
}


