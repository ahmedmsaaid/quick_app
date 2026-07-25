import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/features/customer/profile/presentation/screens/profile_screen.dart';
import 'package:base_app/features/delivery/wallet/presentation/screens/captain_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import '../riverpod/captain_orders_provider.dart';
import 'captain_home_screen.dart';
import 'captain_orders_screen.dart';

class CaptainNavScreen extends ConsumerStatefulWidget {
  const CaptainNavScreen({super.key});

  @override
  ConsumerState<CaptainNavScreen> createState() => _CaptainNavScreenState();
}

class _CaptainNavScreenState extends ConsumerState<CaptainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CaptainHomeScreen(),
    const CaptainOrdersScreen(),
    const CaptainWalletScreen(),
    const ProfileScreen(),
  ];

  Widget _buildNavItem(int index, AppColors colors, bool isActivated) {
    final isSelected = _selectedIndex == index;
    final String label = _getLabel(index);

    return GestureDetector(
      onTap: isActivated
          ? () {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) {
                ref.read(captainMyOrdersProvider.notifier).loadOrders();
              } else if (index == 0) {
                ref.read(captainOrdersProvider.notifier).loadAll();
              } else if (index == 3) {
                ref.read(profileProvider.notifier).loadProfile();
              }
            }
          : null,
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
                      color: Colors.white.withValues(alpha: isActivated ? 0.85 : 0.4),
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
        return AppStrings.mainTab;
      case 1:
        return AppStrings.ordersTab;
      case 2:
        return AppStrings.walletTab;
      case 3:
        return AppStrings.myAccountTab;
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
        return CustomSVGImage(
          asset: AppIcons.bookNavIcon,
          height: 20.h,
          color: color,
        );
      case 2:
        return Icon(
          isSelected
              ? Icons.account_balance_wallet_rounded
              : Icons.account_balance_wallet_outlined,
          size: 20.sp,
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
    final profileState = ref.watch(profileProvider);
    final userStatus = profileState.user?.status ?? 0;
    final bool isActivated = userStatus == 1;

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: AbsorbPointer(
        absorbing: !isActivated,
        child: Container(
          height: 64.h,
          margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isActivated ? colors.primary : colors.primary.withValues(alpha: 0.6),
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
            children: List.generate(4, (index) => _buildNavItem(index, colors, isActivated)),
          ),
        ),
      ),
    );
  }
}
