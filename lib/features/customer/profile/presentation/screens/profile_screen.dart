import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/profile/presentation/widgets/user_dashboard_stats_widget.dart';
import 'package:base_app/features/customer/profile/presentation/widgets/profile_header_widget.dart';
import 'package:base_app/features/customer/profile/presentation/widgets/profile_invitation_code_card_widget.dart';
import 'package:base_app/features/customer/profile/presentation/widgets/profile_menu_section_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    // Show loading if we are in initial or loading state and don't have user data yet
    if (user == null && profileState.status != ProfileStatus.error) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: LoadingButton()),
      );
    }

    // Handle error state if no user data
    if (user == null && profileState.status == ProfileStatus.error) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.errorMessage ?? AppStrings.errorOccurredTitle),
              10.verticalSpace,
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                child: Text(AppStrings.okText),
              ),
            ],
          ),
        ),
      );
    }

    final rawPhoto = user?.photo ?? user?.avatar;
    final resolvedPhotoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
        ? (rawPhoto.startsWith('http')
            ? rawPhoto
            : '${ApiConstants.streamUrl}$rawPhoto')
        : '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ProfileHeaderWidget(
              name: user?.name,
              phone: user?.phone,
              photoUrl: resolvedPhotoUrl,
            ),
            if (user?.role == 2) ...[
              16.verticalSpace,
              const UserDashboardStatsWidget(),
            ],
            16.verticalSpace,
            const ProfileInvitationCodeCardWidget(),
            20.verticalSpace,
            ProfileMenuSectionWidget(user: user),
            SizedBox(
              height: 64.h + 16.h + MediaQuery.of(context).padding.bottom + 16.h,
            ),
          ],
        ),
      ),
    );
  }
}

