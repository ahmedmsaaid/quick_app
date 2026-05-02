// lib/features/auth/presentation/widgets/services_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../riverpod/about_type_provider.dart';
import 'service_input_card.dart';
import 'services_list.dart';

class ServicesSection extends ConsumerWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final services = ref.watch(
      aboutTypeProvider.select((state) => state.services),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.services,
          style: AppTextStyles.text16w600(color: colors.textPrimary),
        ),
        10.verticalSpace,
        const ServiceInputCard(),
        if (services.isNotEmpty) ...[
          30.verticalSpace,
          Text(
            '${AppStrings.addedServices} (${services.length})',
            style: AppTextStyles.text16w600(color: colors.textPrimary),
          ),
          10.verticalSpace,
          ServicesList(services: services),
        ],
      ],
    );
  }
}
