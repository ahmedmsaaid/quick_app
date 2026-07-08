import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/features/shared/chat/data/models/app_chat_default_models/get_all_chats_result_response.dart';

import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/models/app_result_model.dart';
import 'package:base_app/core/network/api_constants.dart';
import '../models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';

part 'app_chat_default_data_source.g.dart';

@riverpod
AppChatDefaultDataSource appChatDefaultDataSource(Ref ref) {
  return AppChatDefaultDataSource(ref.watch(dioProvider));
}

@RestApi()
abstract class AppChatDefaultDataSource {
  factory AppChatDefaultDataSource(Dio dio, {String? baseUrl}) =
      _AppChatDefaultDataSource;

  @PATCH(ApiConstants.chats)
  Future<AppResultModel<List<GetAllChatsResultResponse>>> getAllChats(
    @Body() Map<String, dynamic> parameters,
  );

  @PATCH(ApiConstants.chatMessages)
  Future<AppResultModel<List<ChatMessageResultsModel>>> getMessages(
    @Body() Map<String, dynamic> parameters,
  );
}

// import 'package:injectable/injectable.dart';
//
// import '../../../../../../config/list_generic/data/data_sources/list_remote_datasource.dart';
// import '../../../../../../core/network/constants/endpoinst.dart';
// import '../../../../../../core/network/model/response_model.dart';
// import '../models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';
// import '../models/app_chat_default_models/app_get_all_chats_response_model.dart';
//
// abstract class AppChatDefaultDataSource {
//   Future<ResponseModel> appGetAlChats(int page, int? closedChatId);
//   Future<ResponseModel> getChatMessages({
//     int? chatId,
//     int? userId,
//     required int pageSize,
//     required int pageIndex,
//     String? search,
//   });
// }
//
// @LazySingleton(as: AppChatDefaultDataSource)
// class AppChatDefaultDataSourceImpl extends RemoteExecuteImpl
//     implements AppChatDefaultDataSource {
//   AppChatDefaultDataSourceImpl({required super.dioConsumer});
//
//   @override
//   Future<ResponseModel> appGetAlChats(int page, int? closedChatId) {
//     return getData(
//       endPoint: EndPoints.chats,
//       query: {
//         "pageIndex": page,
//         "pageSize": 15,
//         if (closedChatId != null) 'closedChatId': closedChatId,
//       },
//       getFromJsonFunction: AppGetAllChatsResponseModel.fromJson,
//     );
//   }
//
//   @override
//   Future<ResponseModel> getChatMessages({
//     int? chatId,
//     int? userId,
//     required int pageIndex,
//     required int pageSize,
//     String? search,
//   }) {
//     return getData(
//       endPoint: EndPoints.chatMessages,
//       query: {
//         if (userId != null) 'userId': userId,
//         if (chatId != null) 'chatId': chatId,
//         'pageIndex': pageIndex,
//         'pageSize': 20,
//         'sortDirection': 1,
//         if (search != null && search.isNotEmpty) 'search': search,
//       },
//       getFromJsonFunction: AppChatMessagesResponseModel.fromJson,
//     );
//   }
// }


