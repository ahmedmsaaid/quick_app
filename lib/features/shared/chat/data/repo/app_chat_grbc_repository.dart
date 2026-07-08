import 'package:grpc/grpc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data_source/app_chat_grpc_data_source.dart';
import '../models/app_chat_message_model.dart';
import '../models/app_message_type.dart';
import '../models/app_send_message_model.dart';

part 'app_chat_grbc_repository.g.dart';

@riverpod
AppChatGrbcRepository appChatGrbcRepository(Ref ref) {
  return AppChatGrbcRepository(
    dataSource: ref.watch(appChatGrpcDataSourceProvider),
  );
}

class AppChatGrbcRepository {
  final AppChatGrpcDataSource dataSource;

  AppChatGrbcRepository({required this.dataSource});

  Stream<AppChatMessageGrpcModel> connectToChat(int recipientId) async* {
    try {
      final stream = await dataSource.connectToChat(recipientId);

      await for (final protoMessage in stream) {
        try {
          print("📩 Received message: ${protoMessage.content}");
          final message = AppChatMessageGrpcModel.fromProto(protoMessage);
          yield message;
        } catch (e) {
          print('❌ Failed to parse message: $e');
        }
      }
    } on GrpcError catch (e) {
      print('❌ gRPC Error: ${e.message}');
    } catch (e) {
      print('❌ Connection error: $e');
      rethrow;
    }
  }

  Future<void> sendMessage({
    required int recipientId,
    String? message,
    required AppMessageType type,
    String? mediaUrl,
  }) async {
    try {
      final sendMessageModel = AppSendMessageModel(
        recipientId: recipientId,
        message: message,
        type: type,
        mediaUrl: mediaUrl,
      );

      final protoMessage = sendMessageModel.toProto();
      await dataSource.sendMessage(protoMessage);

      print("✅ Message sent successfully");
    } catch (e) {
      print('❌ Failed to send message: $e');
      rethrow;
    }
  }

  void markStreamDead() {
    dataSource.markStreamDead();
  }

  Future<void> disconnect() async {
    await dataSource.disconnect();
  }
}


