import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:base_app/features/shared/chat/data/models/app_chat_default_models/get_all_chats_result_response.dart';
import 'package:base_app/features/shared/chat/data/repo/app_chat_default_repository.dart';
import 'package:base_app/features/shared/chat/domain/repo/app_chat_default_repo.dart';

import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/pagination/models/pagination_params.dart';
import 'package:base_app/core/pagination/models/pagination_response.dart';
import 'package:base_app/core/pagination/riverpod/pagination_notifier.dart';
import 'package:base_app/core/pagination/riverpod/pagination_state.dart';
import '../../../domain/entity/get_all_chats_parameters.dart';

final getAllChatsProvider =
    StateNotifierProvider<
      GetAllChatsNotifier,
      PaginationState<GetAllChatsResultResponse>
    >((ref) {
      final repo = ref.watch(appChatDefaultRepoProvider);
      return GetAllChatsNotifier(repo);
    });

class GetAllChatsNotifier
    extends PaginationNotifier<GetAllChatsResultResponse> {
  final AppChatDefaultRepo chatRepo;
  GetAllChatsParameters _params = GetAllChatsParameters();
  Timer? _debounceTimer;

  GetAllChatsNotifier(this.chatRepo);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Future<ApiResult<PaginationResponse<GetAllChatsResultResponse>>> fetchData(
    PaginationParams params,
  ) async {
    final getAllChatParams = _params.copyWith(
      pageNumber: params.page,
      pageSize: params.limit,
    );

    final result = await chatRepo.getAllChats(getAllChatParams);

    return result.when(
      success: (paginatedResult) {
        return ApiResult.success(
          PaginationResponse<GetAllChatsResultResponse>(
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

  // Future<void> searchCategorys(String query) async {
  //   _params = _params.copyWith(search: query.isEmpty ? null : query);
  //
  //   _debounceTimer?.cancel();
  //   _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
  //     await loadInitial();
  //   });
  // }

  Future<void> clearFilters() async {
    _params = GetAllChatsParameters();
    await loadInitial();
  }

  GetAllChatsParameters get currentParams => _params;

  String? get currentSearch => _params.search;
}


