import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';

class ProviderNavScreen extends StatefulWidget {
  const ProviderNavScreen({super.key});

  @override
  State<ProviderNavScreen> createState() => _ProviderNavScreenState();
}

class _ProviderNavScreenState extends State<ProviderNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Scaffold(body: Center(child: Text('Provider Dashboard'))),
    const Scaffold(body: Center(child: Text('Bookings'))),
    const Scaffold(body: Center(child: Text('Community'))),
    const Scaffold(body: Center(child: Text('Profile'))),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -5),
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
          items: [
            BottomNavigationBarItem(
              icon: CustomSVGImage(
                asset: AppIcons.homeIcon,
                color: _selectedIndex == 0 ? colors.primary : colors.textHint,
              ),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: CustomSVGImage(
                asset: AppIcons.bookNavIcon,
                color: _selectedIndex == 1 ? colors.primary : colors.textHint,
              ),
              label: AppStrings.bookings,
            ),
            BottomNavigationBarItem(
              icon: CustomSVGImage(
                asset: AppIcons.navCommunityIcon,
                color: _selectedIndex == 2 ? colors.primary : colors.textHint,
              ),
              label: AppStrings.community,
            ),
            BottomNavigationBarItem(
              icon: CustomSVGImage(
                asset: AppIcons.personIcon,
                color: _selectedIndex == 3 ? colors.primary : colors.textHint,
              ),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}
