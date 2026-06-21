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
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

class UserNavScreen extends ConsumerStatefulWidget {
  const UserNavScreen({super.key});

  @override
  ConsumerState<UserNavScreen> createState() => _UserNavScreenState();
}

class _UserNavScreenState extends ConsumerState<UserNavScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }


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
      bottomNavigationBar: CurvedNavigationBar(
        // height: 72.h,
        index: _selectedIndex,
        color: colors.primary,
        buttonBackgroundColor: colors.surface,
        backgroundColor: colors.background,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSVGImage(
                asset: AppIcons.homeIcon,
                height: 22.h,
                color: _selectedIndex == 0 ? colors.secondary : Colors.white,
              ),
              4.verticalSpace,
              Text(
                AppStrings.home,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _selectedIndex == 0 ? colors.secondary : Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedIndex == 1
                    ? Icons.account_balance_wallet_rounded
                    : Icons.account_balance_wallet_outlined,
                size: 22.sp,
                color: _selectedIndex == 1 ? colors.secondary : Colors.white,
              ),
              4.verticalSpace,
              Text(
                AppStrings.wallet,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _selectedIndex == 1 ? colors.secondary : Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSVGImage(
                asset: AppIcons.bookNavIcon,
                height: 22.h,
                color: _selectedIndex == 2 ? colors.secondary : Colors.white,
              ),
              4.verticalSpace,
              Text(
                AppStrings.calendar,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _selectedIndex == 2 ? colors.secondary : Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSVGImage(
                asset: AppIcons.personIcon,
                height: 22.h,
                color: _selectedIndex == 3 ? colors.secondary : Colors.white,
              ),
              4.verticalSpace,
              Text(
                AppStrings.profile,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: _selectedIndex == 3 ? colors.secondary : Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
