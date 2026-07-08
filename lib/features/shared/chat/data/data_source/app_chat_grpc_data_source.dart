import 'dart:async';
import 'package:fixnum/fixnum.dart';

import 'package:grpc/grpc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/services/cach_helper/secure_storage_helper.dart';

import 'generated/Chat.pb.dart' as pb;
import 'generated/Chat.pbgrpc.dart';

part 'app_chat_grpc_data_source.g.dart';

@riverpod
AppChatGrpcDataSource appChatGrpcDataSource(Ref ref) {
  return AppChatGrpcDataSourceImpl();
}

abstract class AppChatGrpcDataSource {
  Future<Stream<pb.GrpcRrecipientMessage>> connectToChat(int recipientId);

  Future<void> sendMessage(pb.GrpcSendMessageRequest message);

  void markStreamDead();

  Future<void> disconnect();
}

class AppChatGrpcDataSourceImpl implements AppChatGrpcDataSource {
  final String host = "quick-service.runasp.net";
  final int port = 443;
  final bool useSecure = true;

  ClientChannel? _channel;
  GrpcChatServiceClient? _eng;
  StreamController<pb.GrpcSendMessageRequest>? _requestController;
  ResponseStream<pb.GrpcRrecipientMessage>? _responseStream;

  bool _isStreamAlive = false;

  void _initializeClient() {
    if (_channel == null) {
      _channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(
          credentials: useSecure
              ? const ChannelCredentials.secure()
              : const ChannelCredentials.insecure(),
          keepAlive: const ClientKeepAliveOptions(
            pingInterval: Duration(seconds: 15),
            timeout: Duration(seconds: 5),
            permitWithoutCalls: true,
          ),
        ),
      );

      _eng = GrpcChatServiceClient(_channel!);
    }
  }

  @override
  Future<Stream<pb.GrpcRrecipientMessage>> connectToChat(int recipientId) async {
    _initializeClient();

    _requestController = StreamController<pb.GrpcSendMessageRequest>();

    print("🔗 Connecting to: $host:$port");
    final token = await SecureStorageHelper.getToken();
    print("Bearer $token");

    final callOptions = CallOptions(
      metadata: {
        'authorization': 'Bearer ${token}',
      },
    );

    _responseStream = _eng!.sendMessage(
      _requestController!.stream,
      options: callOptions,
    );

    _isStreamAlive = true;
    print("✅ gRPC stream opened — sending handshake to register recipientId: $recipientId");

    // Send handshake — server uses recipientId to register stream routing context
    try {
      _requestController!.add(
        pb.GrpcSendMessageRequest()
          ..recipientId = Int64(recipientId)
          ..message = "register"
          ..type = pb.GrpcMessageType.Text,
      );
      print("✅ Handshake sent for recipientId: $recipientId");
    } catch (e) {
      print("⚠️ Failed to send handshake: $e");
    }

    return _responseStream!;
  }

  @override
  Future<void> sendMessage(pb.GrpcSendMessageRequest message) async {
    if (_requestController == null || _requestController!.isClosed || !_isStreamAlive) {
      throw Exception('Chat stream is not connected or has been closed by server');
    }

    print("📤 Sending message to recipientId: ${message.recipientId}");
    _requestController!.add(message);
  }

  @override
  void markStreamDead() {
    _isStreamAlive = false;
    print("⚠️ Stream marked as dead — messages will no longer be sent via gRPC");
  }

  @override
  Future<void> disconnect() async {
    _isStreamAlive = false;
    await _requestController?.close();
    await _channel?.shutdown();

    _requestController = null;
    _channel = null;
    _eng = null;
    _responseStream = null;

    print("🔌 Disconnected");
  }
}


