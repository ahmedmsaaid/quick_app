// lib/features/auth/presentation/widgets/type_description_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../riverpod/about_type_provider.dart';

class TypeDescriptionSection extends ConsumerWidget {
  const TypeDescriptionSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.text16w600(color: colors.textPrimary)),
        10.verticalSpace,
        CustomTextField(
          hintText: AppStrings.descriptionPlaceholder,
          fillColor: colors.surface,
          maxLines: 4,
          onChanged: (value) {
            ref.read(aboutTypeProvider.notifier).updateDescription(value);
          },
        ),
      ],
    );
  }
}
