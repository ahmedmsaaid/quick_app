import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/home/data/rating_api_service.dart';

part 'rating_provider.g.dart';

enum RatingStatus { idle, loading, success, error }

class RatingState {
  final RatingStatus status;
  final String? errorMessage;

  RatingState({
    this.status = RatingStatus.idle,
    this.errorMessage,
  });

  RatingState copyWith({
    RatingStatus? status,
    String? errorMessage,
  }) {
    return RatingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class Rating extends _$Rating {
  @override
  RatingState build() {
    return RatingState();
  }

  Future<bool> submitProductRating({
    required int productId,
    required int value,
    required String note,
  }) async {
    state = state.copyWith(status: RatingStatus.loading);
    final service = ref.read(ratingApiServiceProvider);
    final result = await service.createProductRating(
      productId: productId,
      value: value,
      note: note,
    );

    return result.when(
      success: (data) {
        state = state.copyWith(status: RatingStatus.success);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  Future<bool> submitUserRating({
    required int userId,
    required int value,
    required String note,
  }) async {
    state = state.copyWith(status: RatingStatus.loading);
    final service = ref.read(ratingApiServiceProvider);
    final result = await service.createUserRating(
      userId: userId,
      value: value,
      note: note,
    );

    return result.when(
      success: (data) {
        state = state.copyWith(status: RatingStatus.success);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: RatingStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }
}
