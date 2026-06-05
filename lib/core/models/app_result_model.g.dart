// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppResultModel<T> _$AppResultModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => AppResultModel<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  result: _$nullableGenericFromJson(json['result'], fromJsonT),
  statusCode: (json['statusCode'] as num).toInt(),
  pageSize: (json['pageSize'] as num?)?.toInt(),
  pageNumber: (json['pageNumber'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  count: (json['count'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  moveNext: json['moveNext'] as bool?,
  movePrevious: json['movePrevious'] as bool?,
);

Map<String, dynamic> _$AppResultModelToJson<T>(
  AppResultModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'result': _$nullableGenericToJson(instance.result, toJsonT),
  'statusCode': instance.statusCode,
  'pageSize': instance.pageSize,
  'pageNumber': instance.pageNumber,
  'totalCount': instance.totalCount,
  'count': instance.count,
  'totalPages': instance.totalPages,
  'moveNext': instance.moveNext,
  'movePrevious': instance.movePrevious,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
