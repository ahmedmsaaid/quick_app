import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/services/cms_api_service.dart';
import 'package:base_app/core/models/cms_models.dart';

class TermsAndConditionsScreen extends ConsumerStatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  ConsumerState<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends ConsumerState<TermsAndConditionsScreen> {
  bool _isLoading = true;
  CmsPolicyResponse? _termsResponse;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    final res = await ref.read(cmsApiServiceProvider).getPolicies();
    if (mounted) {
      setState(() {
        _termsResponse = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final sections = _termsResponse?.policySections;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.termsAndConditions,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
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
                    Text(
                      AppStrings.termsAndConditionsPlaceholderTitle,
                      style: AppTextStyles.text16w700(color: colors.textPrimary),
                    ),
                    15.verticalSpace,
                    Text(
                      AppStrings.termsAndConditionsPlaceholderDesc,
                      style: AppTextStyles.text14w400(color: colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
