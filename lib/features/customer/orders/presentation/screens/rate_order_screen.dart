// ignore_for_file: unused_import, unused_element, unused_local_variable
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class RateOrderScreen extends ConsumerStatefulWidget {
  final UserDto? vendor;

  const RateOrderScreen({super.key, this.vendor});

  @override
  ConsumerState<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends ConsumerState<RateOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    // Resolve vendor image URL
    final String? photo = widget.vendor?.photo ?? widget.vendor?.avatar;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.rateOrderTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            30.verticalSpace,
            // Vendor Image
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colors.shimmerBase),
                        errorWidget: (_, __, ___) => Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                      )
                    : Image.asset('assets/image/logo.png', fit: BoxFit.cover),
              ),
            ),
            20.verticalSpace,
            Text(
              widget.vendor?.name ?? "كويك برجر",
              style: AppTextStyles.text18w700(color: colors.textPrimary),
            ),
            10.verticalSpace,
            Text(
              AppStrings.howWasExperienceMsg,
              style: AppTextStyles.text14w400(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            30.verticalSpace,
            /*
            // Star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                final bool isSelected = starIndex <= _rating;
                return IconButton(
                  icon: Icon(
                    isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 44.sp,
                  ),
                  onPressed: isLoading ? null : () => setState(() => _rating = starIndex),
                );
              }),
            ),
            30.verticalSpace,
            CustomTextField(
              controller: _commentController,
              hintText: AppStrings.writeOpinionHintMsg,
              maxLines: 4,
              enabled: !isLoading,
            ),
            40.verticalSpace,
            isLoading
                ? const LoadingButton()
                : CustomAppButton(
                    text: AppStrings.sendRatingBtn,
                    onPressed: _submitRating,
                  ),
            */
            30.verticalSpace,
            Text(
              "خدمة التقييمات غير متاحة حالياً",
              style: AppTextStyles.text14w600(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
