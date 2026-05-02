// lib/features/auth/presentation/models/business_type.dart
import 'package:base_app/core/localizations/app_strings.g.dart';

enum BusinessType {
  salon,
  spa;

  String get title {
    switch (this) {
      case BusinessType.salon:
        return AppStrings.aboutSalon;
      case BusinessType.spa:
        return AppStrings.aboutSpa;
    }
  }

  String get descriptionLabel {
    switch (this) {
      case BusinessType.salon:
        return AppStrings.describeSalon;
      case BusinessType.spa:
        return AppStrings.describeSpa;
    }
  }
}
