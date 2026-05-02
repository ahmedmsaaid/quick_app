import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/service_entity.dart';

part 'about_type_state.freezed.dart';

@freezed
abstract class AboutTypeState with _$AboutTypeState {
  const factory AboutTypeState({
    @Default('') String description,
    @Default([]) List<ServiceEntity> services,
    @Default('') String currentServiceName,
    @Default('') String currentServicePrice,
    File? currentServiceImage,
    @Default(false) bool isLoading,
    @Default(false) bool isPickingImage,
    String? errorMessage,
  }) = _AboutTypeState;

  factory AboutTypeState.initial() => const AboutTypeState();
}
