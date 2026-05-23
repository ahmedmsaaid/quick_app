import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:base_app/features/wallet/presentation/screens/captain_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'captain_home_screen.dart';
import 'captain_orders_screen.dart';

class CaptainNavScreen extends StatefulWidget {
  const CaptainNavScreen({super.key});

  @override
  State<CaptainNavScreen> createState() => _CaptainNavScreenState();
}

class _CaptainNavScreenState extends State<CaptainNavScreen> {
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
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
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
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.surface,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.textHint,
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
    );
  }
}
