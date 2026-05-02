// lib/features/auth/presentation/screens/about_type_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_toast.dart';
import '../../domain/business_type.dart';
import '../riverpod/about_type_provider.dart';
import '../widgets/about_type_widgets/services_section.dart';
import '../widgets/about_type_widgets/type_description_section.dart';

class AboutTypeScreen extends ConsumerWidget {
  const AboutTypeScreen({super.key, required this.businessType});

  final BusinessType businessType;

  void _submitForm(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(aboutTypeProvider.notifier);
    final success = await notifier.submitForm();

    if (success) {
      CustomToast.success(context, AppStrings.dataSavedSuccessfully);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);

    ref.listen(aboutTypeProvider, (previous, next) {
      if (next.errorMessage != null) {
        CustomToast.error(context, next.errorMessage!);
        ref.read(aboutTypeProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: CustomAppBar(title: businessType.title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TypeDescriptionSection(label: businessType.descriptionLabel),
              30.verticalSpace,
              const ServicesSection(),
              40.verticalSpace,
              Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(
                    aboutTypeProvider.select((state) => state.isLoading),
                  );

                  return CustomAppButton(
                    text: AppStrings.add,
                    onPressed: isLoading
                        ? null
                        : () => _submitForm(context, ref),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
