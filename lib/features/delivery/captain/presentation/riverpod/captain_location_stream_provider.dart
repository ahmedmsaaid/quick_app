import 'dart:async';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/features/shared/tracking/data/data_source/app_order_tracking_grpc_data_source.dart';
import 'package:base_app/features/shared/tracking/data/data_source/generated/Tracking.pb.dart' as pb;

part 'captain_location_stream_provider.g.dart';

@riverpod
class CaptainLocationStreamNotifier extends _$CaptainLocationStreamNotifier {
  StreamSubscription<Position>? _positionSubscription;
  StreamController<pb.GrpcLocationUpdate>? _grpcLocationController;
  bool _isStreaming = false;

  @override
  bool build() {
    ref.onDispose(() {
      stopStreaming();
    });
    return false;
  }

  Future<bool> startStreaming({required int orderId, required int deliveryId}) async {
    if (_isStreaming) return true;

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint("⚠️ Location permission denied for streaming driver location.");
        return false;
      }

      _grpcLocationController = StreamController<pb.GrpcLocationUpdate>();
      final dataSource = ref.read(appOrderTrackingGrpcDataSourceProvider);

      // Start gRPC client stream call in background
      dataSource.sendLocation(_grpcLocationController!.stream).then((ack) {
        debugPrint("✅ Location streaming completed with server ack: ${ack.received}");
      }).catchError((e) {
        debugPrint("⚠️ gRPC SendLocation error: $e");
      });

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update every 5 meters movement
      );

      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (position) {
          if (_grpcLocationController != null && !_grpcLocationController!.isClosed) {
            final locationUpdate = pb.GrpcLocationUpdate(
              orderId: Int64(orderId),
              deliveryId: Int64(deliveryId),
              latitude: position.latitude,
              longitude: position.longitude,
              status: pb.GrpcOrderStatus.OutForDelivery,
            );
            _grpcLocationController!.add(locationUpdate);
            debugPrint("🚚 [Captain Location Streamed] Lat: ${position.latitude}, Lng: ${position.longitude}");
          }
        },
        onError: (e) {
          debugPrint("⚠️ Position stream error: $e");
        },
      );

      _isStreaming = true;
      state = true;
      return true;
    } catch (e) {
      debugPrint("⚠️ Failed to start captain location stream: $e");
      stopStreaming();
      return false;
    }
  }

  Future<void> sendDeliveredSignal({required int orderId, required int deliveryId}) async {
    if (_grpcLocationController != null && !_grpcLocationController!.isClosed) {
      try {
        final position = await Geolocator.getCurrentPosition();
        final finalUpdate = pb.GrpcLocationUpdate(
          orderId: Int64(orderId),
          deliveryId: Int64(deliveryId),
          latitude: position.latitude,
          longitude: position.longitude,
          status: pb.GrpcOrderStatus.Delivered,
        );
        _grpcLocationController!.add(finalUpdate);
      } catch (e) {
        debugPrint("⚠️ Error sending final delivered signal: $e");
      }
    }
    await stopStreaming();
  }

  Future<void> stopStreaming() async {
    _isStreaming = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await _grpcLocationController?.close();
    _grpcLocationController = null;
    state = false;
    debugPrint("🛑 Captain location stream stopped.");
  }
}
