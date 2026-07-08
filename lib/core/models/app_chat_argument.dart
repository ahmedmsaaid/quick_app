import 'package:base_app/core/constans/role_type_enum.dart';

class AppChatArgument {
  final int? chatId;
  final int recipientId;
  final int? profileId;
  final RoleTypeEnum typeEnum;
  final String recipientName;
  final String recipientImage;

  AppChatArgument({
    this.chatId,
    required this.recipientId,
    this.profileId,
    required this.typeEnum,
    required this.recipientName,
    required this.recipientImage,
  });
}
