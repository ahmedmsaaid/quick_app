import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:base_app/core/hilpers/repo_helper.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/stream/data/data_source/stream_data_source.dart';
import 'package:base_app/features/customer/stream/data/models/stream_result_model.dart';

part 'stream_repo_impl.g.dart';

@riverpod
StreamRepo streamRepo(Ref ref) {
  return StreamRepoImpl(ref.watch(streamDataSourceProvider));
}

abstract class StreamRepo {
  Future<ApiResult<StreamResult>> uploadStream({
    required int streamType,
    required MultipartFile file,
  });

  Future<ApiResult<void>> deleteStream({required String url});
}

class StreamRepoImpl implements StreamRepo {
  final StreamDataSource api;

  StreamRepoImpl(this.api);

  @override
  Future<ApiResult<StreamResult>> uploadStream({
    required int streamType,
    required MultipartFile file, // ✅
  }) {
    return RepositoryHelper.execute(
      call: () => api.uploadStream(streamType: streamType, file: file),
      mapper: (model) => model.result!,
    );
  }

  @override
  Future<ApiResult<void>> deleteStream({required String url}) {
    return RepositoryHelper.execute(
      call: () => api.deleteStream(url: url),
      mapper: (data) => (),
    );
  }
}
