import 'package:base_app/core/hilpers/repo_helper.dart';
import 'package:base_app/core/network/api_result.dart';
import '../../data/models/app_chat_default_models/get_all_chats_result_response.dart';
import '../../data/models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';
import '../entity/get_all_chats_parameters.dart';
import '../entity/get_messages_chat_parameters.dart';

abstract class AppChatDefaultRepo {
  Future<ApiResult<PaginatedResult<GetAllChatsResultResponse>>> getAllChats(
    GetAllChatsParameters parameters,
  );

  Future<ApiResult<PaginatedResult<ChatMessageResultsModel>>> getAllMessages(
    GetMessagesChatParameters parameters,
  );
}
