import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:base_app/features/shared/chat/data/repo/app_chat_default_repository.dart';
import 'package:base_app/features/shared/chat/domain/repo/app_chat_default_repo.dart';

import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/pagination/models/pagination_params.dart';
import 'package:base_app/core/pagination/models/pagination_response.dart';
import 'package:base_app/core/pagination/riverpod/pagination_notifier.dart';
import 'package:base_app/core/pagination/riverpod/pagination_state.dart';
import 'package:base_app/core/utils/jwt_helper.dart';
import '../../../data/models/app_chat_message_defauilt_model/app_chat_messages_response_model.dart';
import '../../../domain/entity/get_messages_chat_parameters.dart';

final getAllMessagesChatProvider =
    StateNotifierProvider<
      GetAllMessagesNotifier,
      PaginationState<ChatMessageResultsModel>
    >((ref) {
      final repo = ref.watch(appChatDefaultRepoProvider);
      return GetAllMessagesNotifier(repo);
    });

class GetAllMessagesNotifier
    extends PaginationNotifier<ChatMessageResultsModel> {
  final AppChatDefaultRepo chatRepo;
  GetMessagesChatParameters _params = GetMessagesChatParameters();
  Timer? _debounceTimer;

  GetAllMessagesNotifier(this.chatRepo);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Future<ApiResult<PaginationResponse<ChatMessageResultsModel>>> fetchData(
    PaginationParams params,
  ) async {
    final getAllMessagesChatParams = _params.copyWith(
      pageNumber: params.page,
      pageSize: 100,
    );

    final result = await chatRepo.getAllMessages(getAllMessagesChatParams);

    return result.when(
      success: (paginatedResult) {
        print('✅ Loaded hazem ${paginatedResult.items.length} messagesALL');
        return ApiResult.success(
          PaginationResponse<ChatMessageResultsModel>(
            items: paginatedResult.items,
            total: paginatedResult.total,
            skip: paginatedResult.skip,
            limit: paginatedResult.limit,
          ),
        );
      },
      failure: (error) {
        return ApiResult.failure(error);
      },
    );
  }

  int? _currentUserId;

  Future<void> getAllMessages({int? chatId, int? targetUserId}) async {
    try {
      final String? extractedId = await JwtHelper.getUserId();
      if (extractedId == null) {
        print('❌ Failed to extract user ID from token');
      }

      _currentUserId = int.parse(extractedId ?? '0');
      print('✅ Current User ID: $_currentUserId');

      print('✅ Current User ID: $_currentUserId');
    } catch (e) {
      print('❌ Failed to extract user ID from token: $e');
    }
    _params = _params.copyWith(chatId: chatId, targetUserId: targetUserId);

    await loadInitial();
  }

  // Future<void> searchCategorys(String query) async {
  //   _params = _params.copyWith(search: query.isEmpty ? null : query);
  //
  //   _debounceTimer?.cancel();
  //   _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
  //     await loadInitial();
  //   });
  // }

  Future<void> clearFilters() async {
    _params = GetMessagesChatParameters();
    await loadInitial();
  }

  GetMessagesChatParameters get currentParams => _params;

  String? get currentSearch => _params.search;

  bool isMyMessage(int? creatorId) {
    return creatorId == _currentUserId;
  }
}


