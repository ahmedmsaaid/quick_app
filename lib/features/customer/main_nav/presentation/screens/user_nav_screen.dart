import 'package:base_app/features/customer/home/presentation/screens/home_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/features/customer/orders/presentation/screens/orders_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/profile_screen.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/orders/presentation/riverpod/orders_provider.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

class UserNavScreen extends ConsumerStatefulWidget {
  const UserNavScreen({super.key});

  @override
  ConsumerState<UserNavScreen> createState() => _UserNavScreenState();
}

class _UserNavScreenState extends ConsumerState<UserNavScreen> {
  int _selectedIndex = 0;
  final Map<int, DateTime> _lastRefreshTimes = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  void _refreshTabEndpoint(int index) {
    final now = DateTime.now();
    final lastRefresh = _lastRefreshTimes[index];

    // Throttle: ignore taps within 2.5 seconds for the same tab
    if (lastRefresh != null && now.difference(lastRefresh) < const Duration(milliseconds: 2500)) {
      return;
    }

    _lastRefreshTimes[index] = now;

    switch (index) {
      case 0:
        ref.read(homeProvider.notifier).refreshAllData();
        break;
      case 2:
        ref.read(ordersProvider.notifier).loadOrders();
        break;
      case 3:
        ref.read(profileProvider.notifier).loadProfile();
        break;
    }
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const WalletScreen(isFromNav: true),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  Widget _buildNavItem(int index, AppColors colors) {
    final isSelected = _selectedIndex == index;
    final String label = _getLabel(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _refreshTabEndpoint(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected
            ? EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h)
            : EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
            : null,
        child: isSelected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(index, true, colors),
                  6.horizontalSpace,
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.secondary, // Active Orange
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(index, false, colors),
                  4.verticalSpace,
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return AppStrings.home;
      case 1:
        return AppStrings.wallet;
      case 2:
        return AppStrings.calendar;
      case 3:
        return AppStrings.profile;
      default:
        return '';
    }
  }

  Widget _buildIcon(int index, bool isSelected, AppColors colors) {
    final color = isSelected ? colors.secondary : Colors.white;
    switch (index) {
      case 0:
        return CustomSVGImage(
          asset: AppIcons.homeIcon,
          height: 20.h,
          color: color,
        );
      case 1:
        return Icon(
          isSelected
              ? Icons.account_balance_wallet_rounded
              : Icons.account_balance_wallet_outlined,
          size: 20.sp,
          color: color,
        );
      case 2:
        return CustomSVGImage(
          asset: AppIcons.bookNavIcon,
          height: 20.h,
          color: color,
        );
      case 3:
        return CustomSVGImage(
          asset: AppIcons.personIcon,
          height: 20.h,
          color: color,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 64.h,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) => _buildNavItem(index, colors)),
        ),
      ),
    );
  }
}
