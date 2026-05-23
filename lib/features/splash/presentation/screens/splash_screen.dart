import 'package:base_app/core/styles/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localizations/localization_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/cach_helper/cache_helper.dart';
import '../../../../core/services/cach_helper/cache_helper_keys.dart';
import '../../../../core/utils/assets/app_images.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _speedLinesAnimation;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initApp();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Scaling up from small to normal for Logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Fading in
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Fast slide from left to center
    _slideAnimation = Tween<Offset>(begin: const Offset(-2.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.fastOutSlowIn),
      ),
    );

    // Speed lines effect
    _speedLinesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Text scale animation (starts small and grows from center)
    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  Future<void> _initApp() async {
    try {
      await _restoreSavedLocale();
      debugPrint('✅ Locale restored');
    } catch (e) {
      debugPrint('❌ Error restoring locale: $e');
    }

    await Future.delayed(const Duration(milliseconds: 2500)); // قلل الوقت مؤقتًا للتجربة
    debugPrint('✅ Delay done, mounted: $mounted');

    if (!mounted) return;

    try {
      final bool isFirstTime = CacheHelper.getBool(CacheKeys.isFirstTime) ?? true;
      debugPrint('✅ isFirstTime: $isFirstTime');

      final String? token = CacheHelper.getString(CacheKeys.token);
      debugPrint('✅ token: ${token?.substring(0, token!.length > 10 ? 10 : token.length)}...');

      if (!mounted) return;

      if (isFirstTime) {
        debugPrint('🚀 Navigating to Onboarding');
        context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
      } else {
        if (token != null && token.isNotEmpty) {
          debugPrint('🚀 Navigating to UserNav');
          context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
        } else {
          debugPrint('🚀 Navigating to Login');
          context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in navigation logic: $e');
      debugPrint('Stack: $stackTrace');
      // Fallback: اذهب لـ login screen
      if (mounted) {
        context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
      }
    }
  }

  Future<void> _restoreSavedLocale() async {
    final savedLang = CacheHelper.getString(CacheKeys.appLocale);
    if (savedLang == null || savedLang.isEmpty) return;
    final parts = savedLang.split('_');
    final locale = parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts.first);
    ref.read(localizationProvider.notifier).changeLocale(locale);
    await context.setLocale(locale);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CacheHelper.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors(context).background,
      body: Stack(
        children: [
          // Background Speed Lines Decoration
          AnimatedBuilder(
            animation: _speedLinesAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: (1.0 - _speedLinesAnimation.value) * 0.5,
                child: CustomPaint(
                  painter: SpeedLinesPainter(progress: _speedLinesAnimation.value, color: AppColors(context).primaryVariant),
                  size: Size.infinite,
                ),
              );
            },
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          isDark ? AppImages.styleImageDark : AppImages.logo,
                          width: MediaQuery.sizeOf(context).width * 0.6,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Speed streak effect following the logo
          Positioned(
            bottom: 290.h,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _textScaleAnimation,
                child: Center(
                  child: Text(
                    "كويك...راحتك اهم",
                    style: TextStyle(
                      color: AppColors(context).primaryVariant,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpeedLinesPainter extends CustomPainter {
  final double progress;
  final Color color;

  SpeedLinesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double lineLength = 100.0;
    final int lineCount = 15;

    for (int i = 0; i < lineCount; i++) {
      final double y = (size.height / lineCount) * i + (i * 20 % 50);
      final double startX = (size.width * progress * 2) - (i * 30 % 200);
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + lineLength, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpeedLinesPainter oldDelegate) => oldDelegate.progress != progress;
}
