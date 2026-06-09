// lib/features/stream/presentation/riverpod/stream_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:base_app/features/customer/stream/data/models/stream_result_model.dart';

part 'stream_state.freezed.dart';

@freezed
class StreamState with _$StreamState {
  const factory StreamState.initial() = _Initial;

  const factory StreamState.loading({int? current, int? total}) = _Loading;

  const factory StreamState.success(
    List<StreamResult> results,
    List<String> failedUrls,
  ) = _Success;

  const factory StreamState.error(String message) = _Error;
}
