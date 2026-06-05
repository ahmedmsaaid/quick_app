import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod/riverpod.dart'; // بدون riverpod_annotation

import '../../../core/error/app_error.dart';
import '../../../core/network/api_result.dart';
import '../data/models/stream_result_model.dart';
import '../data/repo/stream_repo_impl.dart';
import '../enum/stream_type_enum.dart';
import 'stream_state.dart';

final streamNotifierProvider =
    StateNotifierProvider<StreamNotifier, StreamState>((ref) {
      return StreamNotifier(ref);
    });

class StreamNotifier extends StateNotifier<StreamState> {
  final Ref ref;

  StreamNotifier(this.ref) : super(const StreamState.initial());

  Future<void> uploadStreams({
    required List<String> paths, // local file paths OR http urls
    required StreamType mediaType,
  }) async {
    state = StreamState.loading(total: paths.length);

    try {
      final futures = paths.map((path) async {
        final filename = path.split('/').last;

        final file = await MultipartFile.fromFile(
          path,
          filename: filename,
          contentType: _getContentType(filename),
        );

        final result = await ref.read(streamRepoProvider).uploadStream(
          streamType: mediaType.value,
          file: file,
        );

        return {'path': path, 'result': result};
      }).toList();

      final responses = await Future.wait(futures);

      final results = <StreamResult>[];
      final failures = <String>[];

      for (final response in responses) {
        final result = response['result'] as ApiResult<StreamResult>;
        final path = response['path'] as String;

        result.when(
          success: (stream) => results.add(stream),
          failure: (_) => failures.add(path),
        );
      }

      state = StreamState.success(results, failures);
    } catch (e) {
      state = StreamState.error('Upload failed: $e');
    }
  }

  // تبقي بهذا الشكل فقط إذا كان لديك URLs حقيقية (HTTP/HTTPS)
  Future<MultipartFile> _urlToMultipartFile(String url) async {
    final dio = Dio();
    final response = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    final filename = url.split('/').last;

    return MultipartFile.fromBytes(
      response.data!,
      filename: filename,
      contentType: _getContentType(filename),
    );
  }

  MediaType _getContentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'mp4': 'video/mp4',
      'pdf': 'application/pdf',
      'zip': 'application/zip',
    };
    final mime = mimeTypes[ext] ?? 'application/octet-stream';
    final parts = mime.split('/');
    return MediaType(parts[0], parts[1]);
  }

  void reset() => state = const StreamState.initial();

  Future<void> removeImage(String url) async {
    state = StreamState.loading();

    final result = await ref.read(streamRepoProvider).deleteStream(url: url);

    result.when(
      success: (streamResult) {
        state = StreamState.success([], []);
      },
      failure: (AppError appError) {},
    );
  }
}
