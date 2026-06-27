import 'package:base_app/core/exports/exports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/home/presentation/widgets/location_bottom_sheet.dart';

class HomeSpeedHeader extends ConsumerWidget {
  const HomeSpeedHeader({super.key});

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    String addressName = AppStrings.homeLocation;
    if (profileState.locations.isNotEmpty) {
      final baseLoc = profileState.locations.firstWhere(
        (loc) => loc.base,
        orElse: () => profileState.locations.first,
      );
      addressName = baseLoc.address ?? AppStrings.homeLocation;
    } else if (user?.address != null && user?.address?.isNotEmpty == true) {
      addressName = user?.address??"";
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        border: Border(
          bottom: BorderSide(
            color: colors.secondary, // Bright orange speed trail bottom line
            width: 2.5.h,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Visual Speed Lines in the background
          Positioned(
            right: -30.w,
            top: 25.h,
            child: Container(
              width: 160.w,
              height: 1.5.h,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: -40.w,
            top: 65.h,
            child: Container(
              width: 220.w,
              height: 2.h,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            right: 40.w,
            bottom: 45.h,
            child: Container(
              width: 120.w,
              height: 1.h,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            left: 20.w,
            bottom: 95.h,
            child: Container(
              width: 100.w,
              height: 1.5.h,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),

          // Header Content
          // Header Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              MediaQuery.of(context).padding.top + 8.h,
              20.w,
              14.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Location (left), Logo (center), Profile (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Location Details
                    GestureDetector(
                      onTap: () => _showLocationSheet(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: colors.secondary,
                                size: 12.sp,
                              ),
                              3.horizontalSpace,
                              Container(
                                constraints: BoxConstraints(maxWidth: 100.w),
                                child: Text(
                                  addressName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          3.verticalSpace,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'تغيير العنوان',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                2.horizontalSpace,
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 10.sp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Logo
                    Image.asset(
                      'assets/image/quick_panner.png',
                      height: 60.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/image/quick_panner.png',
                        height: 60.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),

                    // Right Profile Avatar
                    GestureDetector(
                      onTap: () => context.pushNamed(AppRoutes.personalInfo),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: ClipOval(
                          child: (user?.photo != null &&
                                  user!.photo!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: user.photo!.startsWith('http')
                                      ? user.photo!
                                      : '${ApiConstants.streamUrl}${user.photo}',
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                      color: colors.shimmerBase),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                12.verticalSpace,

                // Search Bar nested inside (larger, search icon on right)
                Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              context.pushNamed(AppRoutes.searchResults,
                                  arguments: value);
                            }
                          },
                          style: AppTextStyles.text13w600(
                              color: colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن برجر، بيتزا، لبن، شيبسي...',
                            hintStyle: AppTextStyles.text11w500(
                                color: colors.textHint),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      Icon(
                        Icons.search_rounded,
                        color: colors.textHint,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
