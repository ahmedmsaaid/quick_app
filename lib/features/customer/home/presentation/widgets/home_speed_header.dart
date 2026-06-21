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
          Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              MediaQuery.of(context).padding.top + 8.h,
              20.w,
              18.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Logo, Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Avatar
                    GestureDetector(
                      onTap: () => context.pushNamed(AppRoutes.personalInfo),
                      child: Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: (user?.photo != null && user!.photo!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: user.photo!.startsWith('http')
                                      ? user.photo!
                                      : '${ApiConstants.streamUrl}${user.photo}',
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: colors.shimmerBase),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                        ),
                      ),
                    ),

                    // Centered Brand Logo
                    Image.asset(
                      'assets/image/home_logo.png',
                      height: 42.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/image/logo.png',
                        height: 32.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),

                    // Actions Right: Notifications + Settings
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () =>
                              context.pushNamed(AppRoutes.notifications),
                        ),
                        10.horizontalSpace,
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () =>
                              context.pushNamed(AppRoutes.settings),
                        ),
                      ],
                    ),
                  ],
                ),
                10.verticalSpace,

                // Location Selector
                GestureDetector(
                  onTap: () => _showLocationSheet(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: colors.secondary, // Orange color to pop
                        size: 14.sp,
                      ),
                      4.horizontalSpace,
                      Container(
                        constraints: BoxConstraints(maxWidth: 200.w),
                        child: Text(
                          addressName,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      2.horizontalSpace,
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
                10.verticalSpace,

                // Speed Badge + Titles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.food,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          AppStrings.deliciousAndFast,
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    // Orange Glowing Speed Badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: colors.secondary.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 12.sp),
                          3.horizontalSpace,
                          Text(
                            AppStrings.fastDelivery,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                14.verticalSpace,

                // Search Bar nested inside
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: colors.textHint,
                        size: 18.sp,
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: TextField(
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              context.pushNamed(AppRoutes.searchResults,
                                  arguments: value);
                            }
                          },
                          style: AppTextStyles.text12w600(
                              color: colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: AppStrings.searchHint,
                            hintStyle: AppTextStyles.text11w600(
                                color: colors.textHint),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
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
