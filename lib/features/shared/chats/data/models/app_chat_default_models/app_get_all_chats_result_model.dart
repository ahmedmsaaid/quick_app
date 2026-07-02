import 'app_last_message_model.dart';
import 'user.dart';

class AppGetAllChatsResultModel {
  AppGetAllChatsResultModel({
    this.chatId,
    this.participantId,
    this.creatorId,
    this.ai,
    this.profileId,
    this.createdOn,
    this.message,
    this.user,
  });

  AppGetAllChatsResultModel.fromJson(dynamic json) {
    chatId = json['chatId'];
    participantId = json['participantId'];
    creatorId = json['creatorId'];
    ai = json['ai'];
    createdOn = json['createdOn'];
    profileId = json['profileId'];
    message =
        json['message'] != null
            ? AppLastMessageModel.fromJson(json['message'])
            : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  int? chatId;
  int? participantId;
  int? creatorId;
  int? profileId;
  bool? ai;
  String? createdOn;
  AppLastMessageModel? message;
  User? user;
}
