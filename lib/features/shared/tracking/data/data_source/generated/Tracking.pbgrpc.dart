// This is a generated file - do not edit.
//
// Generated from Tracking.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'Tracking.pb.dart' as $0;

export 'Tracking.pb.dart';

@$pb.GrpcServiceName('tracking.GrpcOrderTrackingService')
class GrpcOrderTrackingServiceClient extends $grpc.Client {
  static const $core.String defaultHost = '';
  static const $core.List<$core.String> oauthScopes = [''];

  GrpcOrderTrackingServiceClient(super.channel, {super.options, super.interceptors});

  /// Client Streaming: Driver sends live location updates
  $grpc.ResponseFuture<$0.GrpcTrackingAck> sendLocation(
    $async.Stream<$0.GrpcLocationUpdate> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$sendLocation, request, options: options).single;
  }

  /// Server Streaming: Customer subscribes to order tracking
  $grpc.ResponseStream<$0.GrpcLocationUpdate> subscribeToOrderTracking(
    $0.GrpcSubscribeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
      _$subscribeToOrderTracking,
      $async.Stream.value(request),
      options: options,
    );
  }

  static final _$sendLocation =
      $grpc.ClientMethod<$0.GrpcLocationUpdate, $0.GrpcTrackingAck>(
          '/tracking.GrpcOrderTrackingService/SendLocation',
          ($0.GrpcLocationUpdate value) => value.writeToBuffer(),
          $0.GrpcTrackingAck.fromBuffer);

  static final _$subscribeToOrderTracking =
      $grpc.ClientMethod<$0.GrpcSubscribeRequest, $0.GrpcLocationUpdate>(
          '/tracking.GrpcOrderTrackingService/SubscribeToOrderTracking',
          ($0.GrpcSubscribeRequest value) => value.writeToBuffer(),
          $0.GrpcLocationUpdate.fromBuffer);
}

@$pb.GrpcServiceName('tracking.GrpcOrderTrackingService')
abstract class GrpcOrderTrackingServiceBase extends $grpc.Service {
  $core.String get $name => 'tracking.GrpcOrderTrackingService';

  GrpcOrderTrackingServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GrpcLocationUpdate, $0.GrpcTrackingAck>(
        'SendLocation',
        sendLocation,
        true,
        false,
        ($core.List<$core.int> value) => $0.GrpcLocationUpdate.fromBuffer(value),
        ($0.GrpcTrackingAck value) => value.writeToBuffer()));

    $addMethod($grpc.ServiceMethod<$0.GrpcSubscribeRequest, $0.GrpcLocationUpdate>(
        'SubscribeToOrderTracking',
        subscribeToOrderTracking,
        false,
        true,
        ($core.List<$core.int> value) => $0.GrpcSubscribeRequest.fromBuffer(value),
        ($0.GrpcLocationUpdate value) => value.writeToBuffer()));
  }

  $async.Future<$0.GrpcTrackingAck> sendLocation(
      $grpc.ServiceCall call, $async.Stream<$0.GrpcLocationUpdate> request);

  $async.Stream<$0.GrpcLocationUpdate> subscribeToOrderTracking(
      $grpc.ServiceCall call, $0.GrpcSubscribeRequest request);
}
