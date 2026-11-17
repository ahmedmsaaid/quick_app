import 'package:base_app/core/localizations/localization_provider.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/providers/auth_state_provider.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/services/push_notification/push_notification_service.dart';
import 'package:base_app/core/utils/assets/app_assets.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/utils/jwt_helper.dart';
import 'package:base_app/features/customer/main_nav/presentation/riverpod/user_nav_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_nav_provider.dart';
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

const Color _splashBackground = Color(0xFF055060);
const Duration _splashDuration = Duration(milliseconds: 2500);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  /// 1.0 = السرعة العادية، 1.5 = أسرع بـ 50%
  static const double _lottieSpeed = 1.5;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await ref.read(pushNotificationServiceProvider).init();
      await ref
          .read(pushNotificationServiceProvider)
          .registerDeviceTokenWithBackend();
    } catch (e) {
      debugPrint('❌ Error initializing push notifications: $e');
    }

    try {
      final token = CacheHelper.getString(CacheKeys.token);
      if (token != null && token.isNotEmpty) {
        ref.read(notificationsProvider.notifier).fetchUnreadCount();
      }
    } catch (_) {}

    try {
      await _restoreSavedLocale();
    } catch (_) {}

    await Future.delayed(_splashDuration);
    if (!mounted) return;

    try {
      final bool isFirstTime =
          CacheHelper.getBool(CacheKeys.isFirstTime) ?? true;
      final String? token = CacheHelper.getString(CacheKeys.token);

      if (isFirstTime) {
        context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
        return;
      }

      if (token == null || token.isEmpty) {
        context.pushNamedAndRemoveUntil(
          AppRoutes.loginScreen,
          arguments: true,
        );
        return;
      }

      ref.read(guestModeProvider.notifier).state = false;
      ref.read(userNavIndexProvider.notifier).state = 0;
      ref.read(captainNavIndexProvider.notifier).state = 0;

      final int? roleInt = JwtHelper.getRoleIntFromToken(token);
      if (roleInt != null) {
        await CacheHelper.setInt('userRole', roleInt);
      }
      if (!mounted) return;

      final int role = CacheHelper.getInt('userRole') ?? (roleInt ?? 2);
      if (role == 2 || role == 0) {
        context.pushNamedAndRemoveUntil(AppRoutes.userNav);
      } else {
        final isValid = await _validateCaptainToken();
        if (!mounted) return;
        if (isValid) {
          context.pushNamedAndRemoveUntil(AppRoutes.captainNav);
        } else {
          context.pushNamedAndRemoveUntil(
            AppRoutes.loginScreen,
            arguments: false,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        context.pushNamedAndRemoveUntil(
          AppRoutes.loginScreen,
          arguments: true,
        );
      }
    }
  }

  Future<bool> _validateCaptainToken() async {
    try {
      final result = await ref.read(profileApiServiceProvider).getProfile();
      return await result.when(
        success: (_) => true,
        failure: (error) => error.statusCode != 401,
      );
    } catch (_) {
      return true;
    }
  }

  Future<void> _restoreSavedLocale() async {
    final savedLang = CacheHelper.getString(CacheKeys.appLocale);
    if (savedLang == null || savedLang.isEmpty) return;
    final parts = savedLang.split('_');
    final locale =
        parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts.first);
    ref.read(localizationProvider.notifier).changeLocale(locale);

    await Future.delayed(Duration.zero);
    if (mounted) {
      await context.setLocale(locale);
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackground,
      body: SizedBox.expand(
        child: Lottie.asset(
          AppAssets.logoSplash,
          controller: _lottieController,
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (composition) {
            _lottieController
              ..duration = Duration(
                milliseconds:
                    (composition.duration.inMilliseconds / _lottieSpeed).round(),
              )
              ..forward();
          },
        ),
      ),
    );
  }
}
