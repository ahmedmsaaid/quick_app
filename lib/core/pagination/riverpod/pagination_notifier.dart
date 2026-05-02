import 'package:flutter_riverpod/legacy.dart';
import '../../network/api_result.dart';
import '../models/pagination_params.dart';
import '../models/pagination_response.dart';
import 'pagination_state.dart';

abstract class PaginationNotifier<T> extends StateNotifier<PaginationState<T>> {
  PaginationNotifier() : super(const PaginationState.initial());

  final List<T> _items = [];
  int _currentPage = 1;
  int _total = 0;
  final int _limit = 10;

  Future<ApiResult<PaginationResponse<T>>> fetchData(PaginationParams params);

  Future<void> loadInitial({Map<String, dynamic>? filters}) async {
    state = const PaginationState.loading();

    _items.clear();
    _currentPage = 1;
    _total = 0;

    final params = PaginationParams(page: 1, limit: _limit, filters: filters);

    await _loadData(params: params);
  }

  Future<void> loadMore({Map<String, dynamic>? filters}) async {
    if (!hasMore) return;

    // ✅ استخدم when أو maybeWhen بدل is check
    state.maybeWhen(
      data: (items, hasMore, page) {
        _currentPage++;

        final params = PaginationParams(
          page: _currentPage,
          limit: _limit,
          filters: filters,
        );

        _loadData(params: params);
      },
      orElse: () {}, // مش هيعمل حاجة لو مش في data state
    );
  }

  Future<void> refresh({Map<String, dynamic>? filters}) async {
    _items.clear();
    _currentPage = 1;
    _total = 0;

    state = const PaginationState.loading();

    final params = PaginationParams(page: 1, limit: _limit, filters: filters);

    await _loadData(params: params);
  }

  Future<void> _loadData({required PaginationParams params}) async {
    final result = await fetchData(params);

    result.when(
      success: (response) {
        _total = response.total;
        _items.addAll(response.items);

        state = PaginationState<T>.data(
          items: List.unmodifiable(_items),
          hasMore: hasMore,
          page: _currentPage,
        );
      },
      failure: (error) {
        state = PaginationState<T>.error(
          message: error.message ?? 'Unknown error',
          items: _items.isEmpty ? null : List.unmodifiable(_items),
        );
      },
    );
  }

  bool get hasMore => _items.length < _total;
  int get currentPage => _currentPage;
  List<T> get items => List.unmodifiable(_items);
}
