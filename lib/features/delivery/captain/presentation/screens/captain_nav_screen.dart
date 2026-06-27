import 'package:base_app/core/localizations/app_strings.g.dart';
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
    const ProfileScreen(), // Reusing profile screen with captain logic if needed
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final userStatus = profileState.user?.status ?? 0;
    final bool isActivated = userStatus == 1;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: AbsorbPointer(
        absorbing: !isActivated,
        child: Container(
          height: 85.h,
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: isActivated
                ? (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (index == 1) {
                      ref.read(captainMyOrdersProvider.notifier).loadOrders();
                    }
                  }
                : null,
            type: BottomNavigationBarType.fixed,
            backgroundColor: colors.surface,
            selectedItemColor: isActivated ? colors.primary : colors.primary.withValues(alpha: 0.5),
            unselectedItemColor: isActivated ? colors.textHint : colors.textHint.withValues(alpha: 0.5),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Cairo',
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined, size: 24.sp),
                activeIcon: Icon(Icons.dashboard, size: 24.sp),
                label: AppStrings.mainTab,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined, size: 24.sp),
                activeIcon: Icon(Icons.list_alt, size: 24.sp),
                label: AppStrings.ordersTab,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 24.sp),
                activeIcon: Icon(Icons.account_balance_wallet, size: 24.sp),
                label: AppStrings.walletTab,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 24.sp),
                activeIcon: Icon(Icons.person, size: 24.sp),
                label: AppStrings.myAccountTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
