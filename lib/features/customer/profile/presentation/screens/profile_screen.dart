import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/shared/auth/presentation/riverpod/auth_provider.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/network/api_constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load real profile data on first visit
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    // Show loading if we are in initial or loading state and don't have user data yet
    if (user == null && profileState.status != ProfileStatus.error) {
      return Scaffold(
        backgroundColor: AppColors(context).background,
        body: const Center(child: LoadingButton()),
      );
    }

    // Handle error state if no user data
    if (user == null && profileState.status == ProfileStatus.error) {
      return Scaffold(
        backgroundColor: AppColors(context).background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.errorMessage ?? AppStrings.errorOccurredTitle),
              10.verticalSpace,
              ElevatedButton(
                onPressed: () =>
                    ref.read(profileProvider.notifier).loadProfile(),
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
      backgroundColor: AppColors(context).background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(
              context,
              user?.name,
              user?.phone,
              resolvedPhotoUrl,
            ),
            20.verticalSpace,
            _buildMenuSection(context, ref, user),
            SizedBox(
              height:
                  64.h + 16.h + MediaQuery.of(context).padding.bottom + 16.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String? name,
    String? phone,
    String? photoUrl,
  ) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 2),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/image/logo.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset('assets/image/logo.png', fit: BoxFit.cover),
            ),
          ),
          15.verticalSpace,
          Text(
            name ?? AppStrings.userNamePlaceholder,
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          5.verticalSpace,
          Text(
            phone ?? '',
            style: AppTextStyles.text14w400(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, UserDto? user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors(context).surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            ref,
            Icons.person_outline,
            AppStrings.personalInformation,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.location_on_outlined,
            AppStrings.address,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.account_balance_wallet_outlined,
            AppStrings.wallet,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.notifications_none,
            AppStrings.notifications,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.chat_bubble_outline_rounded,
            AppStrings.chats,
          ),
          if (user?.role != 2)
            _buildMenuItem(
              context,
              ref,
              Icons.star_border,
              AppStrings.favorites,
            ),
          _buildMenuItem(
            context,
            ref,
            Icons.settings_outlined,
            AppStrings.settings,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.info_outline,
            AppStrings.aboutUs,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.privacy_tip_outlined,
            AppStrings.privacyPolicy,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.help_outline,
            AppStrings.contactUs,
          ),
          _buildMenuItem(
            context,
            ref,
            Icons.logout,
            AppStrings.logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red.withValues(alpha: 0.1)
              : AppColors(context).primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : AppColors(context).primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.text14w500(
          color: isLogout ? Colors.red : AppColors(context).textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14.sp,
        color: AppColors(context).textHint,
      ),
      onTap: () async {
        if (title == AppStrings.personalInformation) {
          Navigator.of(context).pushNamed(AppRoutes.personalInfo);
        } else if (title == AppStrings.address) {
          Navigator.of(context).pushNamed(AppRoutes.address);
        } else if (title == AppStrings.wallet) {
          Navigator.of(context).pushNamed(AppRoutes.wallet);
        } else if (title == AppStrings.notifications) {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        } else if (title == AppStrings.chats) {
          Navigator.of(context).pushNamed(AppRoutes.chatsScreen);
        } else if (title == AppStrings.favorites) {
          Navigator.of(context).pushNamed(AppRoutes.favorites);
        } else if (title == AppStrings.settings) {
          Navigator.of(context).pushNamed(AppRoutes.settings);
        } else if (title == AppStrings.aboutUs) {
          Navigator.of(context).pushNamed(AppRoutes.aboutUs);
        } else if (title == AppStrings.privacyPolicy) {
          Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
        } else if (title == AppStrings.contactUs) {
          Navigator.of(context).pushNamed(AppRoutes.contactUs);
        } else if (isLogout) {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.chooseUserTypeScreen,
              (route) => false,
            );
          }
        }
      },
    );
  }
}
