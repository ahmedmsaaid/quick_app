// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_data_source.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _StreamDataSource implements StreamDataSource {
  _StreamDataSource(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<InvalidType> uploadStream({
    required int streamType,
    required MultipartFile file,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'streamType': streamType};
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.files.add(MapEntry('file', file));
    final _options = _setStreamType<InvalidType>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            null,
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late InvalidType _value;
    try {
      _value = InvalidType.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<InvalidType> deleteStream({required String url}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'url': url};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<InvalidType>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            null,
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late InvalidType _value;
    try {
      _value = InvalidType.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(streamDataSource)
final streamDataSourceProvider = StreamDataSourceProvider._();

final class StreamDataSourceProvider
    extends
        $FunctionalProvider<
          StreamDataSource,
          StreamDataSource,
          StreamDataSource
        >
    with $Provider<StreamDataSource> {
  StreamDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamDataSourceHash();

  @$internal
  @override
  $ProviderElement<StreamDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreamDataSource create(Ref ref) {
    return streamDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreamDataSource>(value),
    );
  }
}

String _$streamDataSourceHash() => r'3cdca541cd1bd01d2665521dbf4bcfb211f0f969';
