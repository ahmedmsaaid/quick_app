// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_chat_default_data_source.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main

class _AppChatDefaultDataSource implements AppChatDefaultDataSource {
  _AppChatDefaultDataSource(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<AppResultModel<List<GetAllChatsResultResponse>>> getAllChats(
    Map<String, dynamic> parameters,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(parameters);
    final _options =
        _setStreamType<AppResultModel<List<GetAllChatsResultResponse>>>(
          Options(method: 'PATCH', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                'chats',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AppResultModel<List<GetAllChatsResultResponse>> _value;
    try {
      _value = AppResultModel<List<GetAllChatsResultResponse>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                  .map<GetAllChatsResultResponse>(
                    (i) => GetAllChatsResultResponse.fromJson(
                      i as Map<String, dynamic>,
                    ),
                  )
                  .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<AppResultModel<List<ChatMessageResultsModel>>> getMessages(
    Map<String, dynamic> parameters,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(parameters);
    final _options =
        _setStreamType<AppResultModel<List<ChatMessageResultsModel>>>(
          Options(method: 'PATCH', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                'messages',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AppResultModel<List<ChatMessageResultsModel>> _value;
    try {
      _value = AppResultModel<List<ChatMessageResultsModel>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                  .map<ChatMessageResultsModel>(
                    (i) => ChatMessageResultsModel.fromJson(
                      i as Map<String, dynamic>,
                    ),
                  )
                  .toList()
            : List.empty(),
      );
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

@ProviderFor(appChatDefaultDataSource)
final appChatDefaultDataSourceProvider = AppChatDefaultDataSourceProvider._();

final class AppChatDefaultDataSourceProvider
    extends
        $FunctionalProvider<
          AppChatDefaultDataSource,
          AppChatDefaultDataSource,
          AppChatDefaultDataSource
        >
    with $Provider<AppChatDefaultDataSource> {
  AppChatDefaultDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appChatDefaultDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appChatDefaultDataSourceHash();

  @$internal
  @override
  $ProviderElement<AppChatDefaultDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppChatDefaultDataSource create(Ref ref) {
    return appChatDefaultDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppChatDefaultDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppChatDefaultDataSource>(value),
    );
  }
}

String _$appChatDefaultDataSourceHash() =>
    r'7d73d0779a7ce596f104fa6b2b0e96d5ecb2b97d';
