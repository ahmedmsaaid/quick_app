import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_entity.freezed.dart';
part 'service_entity.g.dart';

@freezed
abstract class ServiceEntity with _$ServiceEntity {
  const factory ServiceEntity({
    required String name,
    required String price,
    @JsonKey(includeToJson: false, includeFromJson: false) File? image,
    String? imagePath,
  }) = _Service;

  factory ServiceEntity.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
}
