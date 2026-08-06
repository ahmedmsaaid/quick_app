import 'dart:async';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/services/cach_helper/secure_storage_helper.dart';

import 'generated/Tracking.pb.dart' as pb;
import 'generated/Tracking.pbgrpc.dart';

part 'app_order_tracking_grpc_data_source.g.dart';

@riverpod
AppOrderTrackingGrpcDataSource appOrderTrackingGrpcDataSource(Ref ref) {
  return AppOrderTrackingGrpcDataSourceImpl();
}

abstract class AppOrderTrackingGrpcDataSource {
  /// Customer: Subscribe to live order tracking location stream
  Future<Stream<pb.GrpcLocationUpdate>> subscribeToOrderTracking(int orderId);

  /// Driver/Captain: Stream live location updates to server
  Future<pb.GrpcTrackingAck> sendLocation(Stream<pb.GrpcLocationUpdate> locationStream);

  /// Disconnect gRPC channel
  Future<void> disconnect();
}

class AppOrderTrackingGrpcDataSourceImpl implements AppOrderTrackingGrpcDataSource {
  final String host = "quick-service.runasp.net";
  final int port = 443;
  final bool useSecure = true;

  ClientChannel? _channel;
  GrpcOrderTrackingServiceClient? _client;

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

      _client = GrpcOrderTrackingServiceClient(_channel!);
    }
  }

  Future<CallOptions> _getCallOptions() async {
    final token = await SecureStorageHelper.getToken();
    return CallOptions(
      metadata: {
        'authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<Stream<pb.GrpcLocationUpdate>> subscribeToOrderTracking(int orderId) async {
    _initializeClient();
    final options = await _getCallOptions();

    debugPrint("📡 [gRPC Tracking] Subscribing to order tracking for orderId: $orderId");

    final request = pb.GrpcSubscribeRequest(orderId: Int64(orderId));
    final responseStream = _client!.subscribeToOrderTracking(request, options: options);

    return responseStream;
  }

  @override
  Future<pb.GrpcTrackingAck> sendLocation(Stream<pb.GrpcLocationUpdate> locationStream) async {
    _initializeClient();
    final options = await _getCallOptions();

    debugPrint("🚚 [gRPC Tracking] Starting location stream to server...");

    final ack = await _client!.sendLocation(locationStream, options: options);
    debugPrint("✅ [gRPC Tracking] Server Ack received: ${ack.received}");
    return ack;
  }

  @override
  Future<void> disconnect() async {
    await _channel?.shutdown();
    _channel = null;
    _client = null;
    debugPrint("🔌 [gRPC Tracking] Disconnected channel");
  }
}
