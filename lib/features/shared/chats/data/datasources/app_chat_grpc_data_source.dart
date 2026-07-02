import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';

import 'generated/Chat.pb.dart' as pb;
import 'generated/Chat.pbgrpc.dart';

abstract class AppChatGrpcDataSource {
  Stream<pb.GrpcRrecipientMessage> connectToChat();
  Future<void> sendMessage(pb.GrpcSendMessageRequest message);
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

  void _initializeClient() {
    if (_channel == null) {
      _channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(
          credentials:
              useSecure
                  ? const ChannelCredentials.secure()
                  : const ChannelCredentials.insecure(),
          keepAlive: const ClientKeepAliveOptions(),
        ),
      );

      _eng = GrpcChatServiceClient(_channel!);
    }
  }

  @override
  Stream<pb.GrpcRrecipientMessage> connectToChat() {
    _initializeClient();

    _requestController = StreamController<pb.GrpcSendMessageRequest>();

    print("🔗 Connecting to: $host:$port");

    final callOptions = CallOptions(
      metadata: {
        'authorization': 'Bearer ${CacheHelper.getString(CacheKeys.token) ?? ""}',
      },
    );

    _responseStream = _eng!.sendMessage(
      _requestController!.stream,
      options: callOptions,
    );

    print("✅ Stream created");
    return _responseStream!;
  }

  @override
  Future<void> sendMessage(pb.GrpcSendMessageRequest message) async {
    if (_requestController == null || _requestController!.isClosed) {
      throw Exception('Chat stream is not connected');
    }

    print("📤 Sending message: ${message.recipientId}");
    _requestController!.add(message);
  }

  @override
  Future<void> disconnect() async {
    await _requestController?.close();
    await _channel?.shutdown();

    _requestController = null;
    _channel = null;
    _eng = null;
    _responseStream = null;

    print("🔌 Disconnected");
  }
}
