// lib/features/auth/presentation/widgets/service_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../../domain/service_entity.dart';

class ServiceInfo extends StatelessWidget {
  const ServiceInfo({super.key, required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: AppTextStyles.text14w600(color: colors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          5.verticalSpace,
          Text(
            '${service.price} ${AppStrings.currency}',
            style: AppTextStyles.text14w600(color: colors.primaryVariant),
          ),
        ],
      ),
    );
  }
}
