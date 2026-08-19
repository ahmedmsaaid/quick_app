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
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/search_history_provider.dart';

class HomeSpeedHeader extends ConsumerStatefulWidget {
  const HomeSpeedHeader({super.key});

  @override
  ConsumerState<HomeSpeedHeader> createState() => _HomeSpeedHeaderState();
}

class _HomeSpeedHeaderState extends ConsumerState<HomeSpeedHeader> {
  late final TextEditingController _searchController;
  bool _isNavigatingToSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationBottomSheet(),
    );
  }

  Future<void> _onPerformSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty || _isNavigatingToSearch) return;

    _isNavigatingToSearch = true;
    FocusScope.of(context).unfocus();

    // Save to persistent search history
    ref.read(searchHistoryProvider.notifier).addQuery(query);

    // Clear search controller so returning to Home leaves the search bar empty
    _searchController.clear();

    await Navigator.of(context).pushNamed(AppRoutes.searchResults, arguments: query);

    if (mounted) {
      setState(() {
        _isNavigatingToSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      child: Stack(
        children: [
          // Background subtle speed trail curve
          Positioned(
            right: -30.w,
            top: -20.h,
            child: Container(
              width: 140.w,
              height: 140.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, MediaQuery.of(context).padding.top + 8.h, 16.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Bar: Location + App Badge + Notification & Cart
                Row(
                  children: [
                    // Location Pill
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showLocationSheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: colors.secondary,
                                size: 16.sp,
                              ),
                              5.horizontalSpace,
                              Flexible(
                                child: Text(
                                  addressName,
                                  style: AppTextStyles.text12w600(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              4.horizontalSpace,
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70,
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    10.horizontalSpace,

                    // Action Icons: Cart & Notification
                    Row(
                      children: [
                        // Cart Button
                        GestureDetector(
                          onTap: () => context.pushNamed(AppRoutes.cartScreen),
                          child: Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),

                        8.horizontalSpace,

                        // Notification Bell Widget
                        const _NotificationBell(),
                      ],
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
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => _onPerformSearch(value),
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
                      GestureDetector(
                        onTap: () => _onPerformSearch(_searchController.text),
                        child: Icon(
                          Icons.search_rounded,
                          color: colors.textHint,
                          size: 20.sp,
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

/// Notification bell button with animated unread badge.
/// Placed in the home header; taps navigate to NotificationsScreen.
class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref.watch(notificationsProvider.select((s) => s.unreadCount));

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(AppRoutes.notifications);
        // ignore: use_build_context_synchronously
        ref.read(notificationsProvider.notifier).fetchUnreadCount();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
            child: Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Container(
                  key: ValueKey(unreadCount),
                  constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(9.r),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
