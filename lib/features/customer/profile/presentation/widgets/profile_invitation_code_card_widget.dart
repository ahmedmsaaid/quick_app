import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';

class ProfileInvitationCodeCardWidget extends ConsumerWidget {
  const ProfileInvitationCodeCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final inviteAsync = ref.watch(myInvitationCodeProvider);

    return inviteAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (invite) {
        if (invite == null || invite.code.trim().isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  colors.primary.withValues(alpha: 0.12),
                  colors.primary.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.28),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.confirmation_number_rounded,
                        color: colors.primary,
                        size: 22.sp,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.myPromoCodeTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text14w700(
                              color: colors.textPrimary,
                            ),
                          ),
                          2.verticalSpace,
                          Text(
                            AppStrings.myPromoCodeSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.text11w400(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                14.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          invite.code,
                          maxLines: 1,
                          style: AppTextStyles.text18w700(
                            color: colors.primary,
                          ).copyWith(letterSpacing: 1.5),
                        ),
                      ),
                      8.horizontalSpace,
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: invite.code));
                          CustomToast.success(
                            context,
                            AppStrings.promoCodeCopiedMsg,
                          );
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy_rounded,
                                size: 15.sp,
                                color: Colors.white,
                              ),
                              6.horizontalSpace,
                              Text(
                                AppStrings.copyPromoCodeBtn,
                                style: AppTextStyles.text12w700(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                10.verticalSpace,
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      size: 16.sp,
                      color: colors.textSecondary,
                    ),
                    6.horizontalSpace,
                    Expanded(
                      child: Text(
                        AppStrings.promoCodeUsedCountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text12w500(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${invite.usedCount} ${AppStrings.promoCodeTimesUnit}',
                        style: AppTextStyles.text12w700(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

