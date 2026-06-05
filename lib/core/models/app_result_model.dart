import 'package:json_annotation/json_annotation.dart';

part 'app_result_model.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class AppResultModel<T> {
  final bool success;
  final String? message;
  final T? result;
  final int statusCode;

  // ✅ حقول الـ pagination الجديدة
  final int? pageSize;
  final int? pageNumber;
  final int? totalCount;
  final int? count;
  final int? totalPages;
  final bool? moveNext;
  final bool? movePrevious;

  AppResultModel({
    required this.success,
    this.message,
    this.result,
    required this.statusCode,
    this.pageSize,
    this.pageNumber,
    this.totalCount,
    this.count,
    this.totalPages,
    this.moveNext,
    this.movePrevious,
  });

  factory AppResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$AppResultModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$AppResultModelToJson(this, toJsonT);
}
