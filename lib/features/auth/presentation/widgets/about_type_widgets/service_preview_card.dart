// lib/features/auth/presentation/widgets/service_preview_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/features/auth/presentation/widgets/about_type_widgets/service_info.dart';

import '../../../../../core/styles/app_colors.dart';
import '../../../domain/service_entity.dart';
import 'delete_service_button.dart';
import 'service_image.dart';

class ServicePreviewCard extends StatelessWidget {
  const ServicePreviewCard({
    super.key,
    required this.service,
    required this.onDelete,
  });

  final ServiceEntity service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ServiceImage(service: service),
          10.horizontalSpace,
          ServiceInfo(service: service),
          Spacer(),
          DeleteServiceButton(onDelete: onDelete),
        ],
      ),
    );
  }
}
