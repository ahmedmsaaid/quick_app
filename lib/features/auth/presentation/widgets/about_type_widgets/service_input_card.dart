// lib/features/auth/presentation/widgets/service_input_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/custom_toast.dart';
import '../../riverpod/about_type_provider.dart';
import 'add_service_button.dart';
import 'service_image_picker.dart';

class ServiceInputCard extends ConsumerStatefulWidget {
  const ServiceInputCard({super.key});

  @override
  ConsumerState<ServiceInputCard> createState() => _ServiceInputCardState();
}

class _ServiceInputCardState extends ConsumerState<ServiceInputCard> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addService() {
    final notifier = ref.read(aboutTypeProvider.notifier);
    final error = notifier.addService();

    if (error != null) {
      CustomToast.error(context, error);
    } else {
      CustomToast.success(context, AppStrings.serviceAddedSuccessfully);
      _nameController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            hintText: AppStrings.serviceName,
            fillColor: colors.surface,
            onChanged: (value) {
              ref.read(aboutTypeProvider.notifier).updateServiceName(value);
            },
          ),
          15.verticalSpace,
          CustomTextField(
            controller: _priceController,
            hintText: AppStrings.price,
            fillColor: colors.surface,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              ref.read(aboutTypeProvider.notifier).updateServicePrice(value);
            },
          ),
          15.verticalSpace,
          const ServiceImagePicker(),
          20.verticalSpace,
          AddServiceButton(onPressed: _addService),
        ],
      ),
    );
  }
}
