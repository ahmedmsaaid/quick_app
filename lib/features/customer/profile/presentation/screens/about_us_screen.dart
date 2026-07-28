import 'package:base_app/core/widgets/lading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/services/cms_api_service.dart';
import 'package:base_app/core/models/cms_models.dart';

class AboutUsScreen extends ConsumerStatefulWidget {
  const AboutUsScreen({super.key});

  @override
  ConsumerState<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends ConsumerState<AboutUsScreen> {
  bool _isLoading = true;
  CmsAboutUsResponse? _aboutUsResponse;

  @override
  void initState() {
    super.initState();
    _fetchAboutUs();
  }

  Future<void> _fetchAboutUs() async {
    final res = await ref.read(cmsApiServiceProvider).getAboutUs();
    if (mounted) {
      setState(() {
        _aboutUsResponse = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final sections = _aboutUsResponse?.aboutUsSections;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.aboutUs,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: LoadingButton(color: colors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sections != null && sections.isNotEmpty) ...[
                    ...sections.map((sec) {
                      final title = sec.titleAr ?? sec.titleEn ?? '';
                      final content = sec.contentAr ?? sec.contentEn ?? '';
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title.isNotEmpty) ...[
                                Text(
                                  title,
                                  style: AppTextStyles.text16w700(
                                    color: colors.primary,
                                  ),
                                ),
                                10.verticalSpace,
                              ],
                              if (content.isNotEmpty)
                                Text(
                                  content,
                                  style: AppTextStyles.text14w400(
                                    color: colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 50.sp, color: colors.primary),
                          16.verticalSpace,
                          Text(
                            AppStrings.appName,
                            style: AppTextStyles.text20w700(color: colors.primary),
                          ),
                          10.verticalSpace,
                          Text(
                            AppStrings.aboutUsPlaceholderDesc,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text14w400(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
