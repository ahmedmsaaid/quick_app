import 'package:base_app/features/home/presentation/screens/home_screen.dart';
import 'package:base_app/features/profile/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:base_app/features/profile/presentation/screens/profile_screen.dart';

class UserNavScreen extends StatefulWidget {
  const UserNavScreen({super.key});

  @override
  State<UserNavScreen> createState() => _UserNavScreenState();
}

class _UserNavScreenState extends State<UserNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const WalletScreen(isFromNav: true),
    const OrdersScreen(),
    const ProfileScreen(),
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
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: CustomSVGImage(
                  asset: AppIcons.homeIcon,
                  height: 24.h,
                  color: _selectedIndex == 0 ? colors.primary : colors.textHint,
                ),
              ),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 24.sp,
                  color: _selectedIndex == 1 ? colors.primary : colors.textHint,
                ),
              ),
              label: AppStrings.wallet,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: CustomSVGImage(
                  asset: AppIcons.bookNavIcon,
                  height: 24.h,
                  color: _selectedIndex == 2 ? colors.primary : colors.textHint,
                ),
              ),
              label: AppStrings.calendar,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: CustomSVGImage(
                  asset: AppIcons.personIcon,
                  height: 24.h,
                  color: _selectedIndex == 3 ? colors.primary : colors.textHint,
                ),
              ),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
