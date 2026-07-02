import 'package:fixnum/fixnum.dart';

import '../datasources/generated/Chat.pb.dart' as pb;
import 'app_message_type.dart';

class AppSendMessageModel {
  final int recipientId;
  final String? message;
  final AppMessageType type;
  final String? mediaUrl;

  AppSendMessageModel({
    required this.recipientId,
    this.message,
    required this.type,
    this.mediaUrl,
  });

  pb.GrpcSendMessageRequest toProto() {
    final proto =
        pb.GrpcSendMessageRequest()
          ..recipientId = Int64(recipientId)
          ..type = pb.GrpcMessageType.valueOf(type.toProtoValue())!;

    if (message != null && message!.isNotEmpty) {
      proto.message = message!;
    }

    if (mediaUrl != null && mediaUrl!.isNotEmpty) {
      proto.mediaUrl = mediaUrl!;
    }

    return proto;
  }
}
