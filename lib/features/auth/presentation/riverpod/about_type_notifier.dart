import 'package:flutter_riverpod/legacy.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../domain/service_entity.dart';
import 'about_type_state.dart';

class AboutTypeNotifier extends StateNotifier<AboutTypeState> {
  AboutTypeNotifier(this._imagePickerService) : super(AboutTypeState.initial());

  final ImagePickerService _imagePickerService;

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateServiceName(String name) {
    state = state.copyWith(currentServiceName: name);
  }

  void updateServicePrice(String price) {
    state = state.copyWith(currentServicePrice: price);
  }

  Future<void> pickImage() async {
    state = state.copyWith(isPickingImage: true, errorMessage: null);

    try {
      final image = await _imagePickerService.pickSingleImage();

      if (image != null) {
        state = state.copyWith(
          currentServiceImage: image,
          isPickingImage: false,
        );
      } else {
        state = state.copyWith(isPickingImage: false);
      }
    } on ImagePickerException catch (e) {
      state = state.copyWith(errorMessage: e.message, isPickingImage: false);
    }
  }

  Future<void> pickImageFromCamera() async {
    state = state.copyWith(isPickingImage: true, errorMessage: null);

    try {
      final image = await _imagePickerService.pickImageFromCamera();

      if (image != null) {
        state = state.copyWith(
          currentServiceImage: image,
          isPickingImage: false,
        );
      } else {
        state = state.copyWith(isPickingImage: false);
      }
    } on ImagePickerException catch (e) {
      state = state.copyWith(errorMessage: e.message, isPickingImage: false);
    }
  }

  String? addService() {
    if (state.currentServiceName.trim().isEmpty) {
      return AppStrings.pleaseEnterServiceName;
    }

    if (state.currentServicePrice.trim().isEmpty) {
      return AppStrings.pleaseEnterServicePrice;
    }

    if (state.currentServiceImage == null) {
      return AppStrings.pleaseSelectServiceImage;
    }

    final service = ServiceEntity(
      name: state.currentServiceName,
      price: state.currentServicePrice,
      image: state.currentServiceImage,
    );

    state = state.copyWith(
      services: [...state.services, service],
      currentServiceName: '',
      currentServicePrice: '',
      currentServiceImage: null,
    );

    return null;
  }

  void removeService(int index) {
    final updatedServices = List<ServiceEntity>.from(state.services)
      ..removeAt(index);
    state = state.copyWith(services: updatedServices);
  }

  String? validateForm() {
    if (state.description.trim().isEmpty) {
      return AppStrings.pleaseEnterDescription;
    }

    if (state.description.trim().length < 20) {
      return AppStrings.descriptionMinLength;
    }

    if (state.services.isEmpty) {
      return AppStrings.pleaseAddAtLeastOneService;
    }

    return null;
  }

  Future<bool> submitForm() async {
    final error = validateForm();
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      // TODO: API call here
      // final response = await _repository.submitAboutType(
      //   description: state.description,
      //   services: state.services,
      // );

      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.errorOccurred,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = AboutTypeState.initial();
  }
}
