// lib/features/stream/data/data_source/stream_data_source.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/app_result_model.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_factory.dart';
import '../models/stream_result_model.dart';

part 'stream_data_source.g.dart';

@riverpod
StreamDataSource streamDataSource(Ref ref) {
  return StreamDataSource(ref.watch(dioProvider));
}

@RestApi()
abstract class StreamDataSource {
  factory StreamDataSource(Dio dio, {String? baseUrl}) = _StreamDataSource;

  @POST(ApiConstants.stream)
  @MultiPart()
  Future<AppResultModel<StreamResult>> uploadStream({
    @Query('streamType') required int streamType,
    @Part(name: 'file') required MultipartFile file,
  });

  @DELETE(ApiConstants.stream)
  Future<AppResultModel<void>> deleteStream({
    @Query('url') required String url,
  });
}
