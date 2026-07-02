// This is a generated file - do not edit.
//
// Generated from Chat.proto.

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

import 'Chat.pb.dart' as $0;

export 'Chat.pb.dart';

/// service
@$pb.GrpcServiceName('chat.GrpcChatService')
class GrpcChatServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GrpcChatServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.GrpcRrecipientMessage> sendMessage(
    $async.Stream<$0.GrpcSendMessageRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$sendMessage, request, options: options);
  }

  // method descriptors

  static final _$sendMessage =
      $grpc.ClientMethod<$0.GrpcSendMessageRequest, $0.GrpcRrecipientMessage>(
          '/chat.GrpcChatService/SendMessage',
          ($0.GrpcSendMessageRequest value) => value.writeToBuffer(),
          $0.GrpcRrecipientMessage.fromBuffer);
}

@$pb.GrpcServiceName('chat.GrpcChatService')
abstract class GrpcChatServiceBase extends $grpc.Service {
  $core.String get $name => 'chat.GrpcChatService';

  GrpcChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GrpcSendMessageRequest,
            $0.GrpcRrecipientMessage>(
        'SendMessage',
        sendMessage,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.GrpcSendMessageRequest.fromBuffer(value),
        ($0.GrpcRrecipientMessage value) => value.writeToBuffer()));
  }

  $async.Stream<$0.GrpcRrecipientMessage> sendMessage(
      $grpc.ServiceCall call, $async.Stream<$0.GrpcSendMessageRequest> request);
}
