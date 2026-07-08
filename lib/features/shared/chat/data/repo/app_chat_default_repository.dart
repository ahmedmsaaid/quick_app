import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/features/shared/chat/domain/entity/get_messages_chat_parameters.dart';

import 'package:base_app/core/hilpers/repo_helper.dart';
import 'package:base_app/core/network/api_result.dart';
import '../../domain/entity/get_all_chats_parameters.dart';
import '../../domain/repo/app_chat_default_repo.dart';
import '../data_source/app_chat_default_data_source.dart';
import '../models/app_chat_default_models/get_all_chats_result_response.dart';
import '../models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';

part 'app_chat_default_repository.g.dart';

@Riverpod(keepAlive: false)
AppChatDefaultRepo appChatDefaultRepo(Ref ref) {
  final api = ref.watch(appChatDefaultDataSourceProvider);
  return AppChatDefaultRepository(api);
}

class AppChatDefaultRepository extends AppChatDefaultRepo {
  final AppChatDefaultDataSource api;

  AppChatDefaultRepository(this.api);

  @override
  Future<ApiResult<PaginatedResult<GetAllChatsResultResponse>>> getAllChats(
    GetAllChatsParameters parameters,
  ) {
    return RepositoryHelper.executePaginatedWithAppResultList(
      call: () => api.getAllChats(parameters.toJson()),
      mapper: (item) => item,
    );
  }

  @override
  Future<ApiResult<PaginatedResult<ChatMessageResultsModel>>> getAllMessages(
    GetMessagesChatParameters parameters,
  ) {
    return RepositoryHelper.executePaginatedWithAppResultList(
      call: () => api.getMessages(parameters.toJson()),
      mapper: (item) => item,
    );
  }
}



// import 'package:dartz/dartz.dart';
// import 'package:injectable/injectable.dart';
//
// import '../../../../../../config/failures/failure.dart';
// import '../../../../../../core/network/model/response_model.dart';
// import '../../../../../../core/network/network_helper.dart';
// import '../datasources/app_chat_default_data_source.dart';
//
// abstract class AppChatDefaultRepository {
//   Future<Either<Failure, ResponseModel>> appGetAlChats(
//     int page,
//     int? closedChatId,
//   );
//   Future<Either<Failure, ResponseModel>> getChatMessages({
//     int? chatId,
//     int? userId,
//     required int pageIndex,
//     required int pageSize,
//     String? search,
//   });
// }
//
// @LazySingleton(as: AppChatDefaultRepository)
// class AppChatDefaultRepositoryImpl implements AppChatDefaultRepository {
//   AppChatDefaultDataSource chatDefaultDataSource;
//   AppChatDefaultRepositoryImpl({required this.chatDefaultDataSource});
//
//   @override
//   Future<Either<Failure, ResponseModel>> appGetAlChats(
//     int page,
//     int? closedChatId,
//   ) => executeImpl(
//     () => chatDefaultDataSource.appGetAlChats(page, closedChatId),
//   );
//
//   @override
//   Future<Either<Failure, ResponseModel>> getChatMessages({
//     int? chatId,
//     int? userId,
//     required int pageIndex,
//     required int pageSize,
//     String? search,
//   }) => executeImpl(
//     () => chatDefaultDataSource.getChatMessages(
//       chatId: chatId,
//       userId: userId,
//       pageSize: pageSize,
//       pageIndex: pageIndex,
//       search: search,
//     ),
//   );
// }


