// lib/features/auth/presentation/widgets/service_image.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/features/auth/domain/service_entity.dart';

import '../../../../../core/styles/app_colors.dart';

class ServiceImage extends StatelessWidget {
  const ServiceImage({super.key, required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Padding(
      padding: EdgeInsets.all(8.0.sp),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: service.image != null
            ? Image.file(
                service.image!,
                width: 90.w,
                height: 90.w,
                fit: BoxFit.fill,
              )
            : Container(
                width: 80.w,
                height: 60.w,
                color: colors.divider,
                child: Icon(Icons.image, color: colors.textSecondary),
              ),
      ),
    );
  }
}
