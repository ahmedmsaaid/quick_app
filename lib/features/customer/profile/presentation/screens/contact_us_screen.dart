import 'package:base_app/core/widgets/lading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/services/cms_api_service.dart';
import 'package:base_app/core/models/cms_models.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  bool _isLoading = true;
  CmsContactUsResponse? _contactUsResponse;

  @override
  void initState() {
    super.initState();
    _fetchContactInfo();
  }

  Future<void> _fetchContactInfo() async {
    final res = await ref.read(cmsApiServiceProvider).getContactUs();
    if (mounted) {
      setState(() {
        _contactUsResponse = res;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String urlStr) async {
    if (urlStr.isEmpty) return;
    final Uri uri = Uri.parse(urlStr.startsWith('http') || urlStr.startsWith('tel:') || urlStr.startsWith('mailto:') ? urlStr : 'https://$urlStr');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final fields = _contactUsResponse?.contactUsFields;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.contactUs,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: LoadingButton(color: colors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.headset_mic, color: colors.primary, size: 40.sp),
                        20.horizontalSpace,
                        Expanded(
                          child: Text(
                            AppStrings.contactUsMsg,
                            style: AppTextStyles.text14w600(color: colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.verticalSpace,

                  if (fields != null && fields.isNotEmpty)
                    Column(
                      children: fields.map((f) {
                        final val = f.url ?? '';
                        IconData iconData = Icons.link;
                        Color iconColor = colors.primary;
                        if (f.type == 0) {
                          iconData = Icons.phone;
                          iconColor = Colors.green;
                        } else if (f.type == 1) {
                          iconData = Icons.email;
                          iconColor = Colors.orange;
                        } else if (f.type == 2) {
                          iconData = Icons.location_on;
                          iconColor = Colors.red;
                        } else if (f.type == 7) {
                          iconData = Icons.chat;
                          iconColor = Colors.teal;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: InkWell(
                            onTap: () => _launchUrl(val),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Icon(iconData, color: iconColor, size: 24.sp),
                                  14.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      val,
                                      style: AppTextStyles.text14w500(color: colors.textPrimary),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 14.sp, color: colors.textHint),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}
