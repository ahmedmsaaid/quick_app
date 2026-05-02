import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_state.freezed.dart';

@freezed
class PaginationState<T> with _$PaginationState<T> {
  const factory PaginationState.initial() = _Initial<T>;

  const factory PaginationState.loading() = _Loading<T>;

  const factory PaginationState.data({
    required List<T> items,
    required bool hasMore,
    required int page,
  }) = _Data<T>;

  const factory PaginationState.error({
    required String message,
    List<T>? items, // Keep old items if error on loadMore
  }) = _Error<T>;
}
