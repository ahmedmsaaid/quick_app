// lib/features/auth/presentation/widgets/services_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

import '../../../../../core/widgets/custom_toast.dart';
import '../../../domain/service_entity.dart';
import '../../riverpod/about_type_provider.dart';
import 'service_preview_card.dart';

class ServicesList extends ConsumerWidget {
  const ServicesList({super.key, required this.services});

  final List<ServiceEntity> services;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: services
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ServicePreviewCard(
                service: entry.value,
                onDelete: () {
                  ref.read(aboutTypeProvider.notifier).removeService(entry.key);
                  CustomToast.success(
                    context,
                    AppStrings.serviceDeletedSuccessfully,
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}
