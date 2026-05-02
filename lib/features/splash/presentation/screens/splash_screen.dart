import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/localizations/localization_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/cach_helper/cache_helper.dart';
import '../../../../core/services/cach_helper/cache_helper_keys.dart';
import '../../../../core/utils/assets/app_images.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final language = ref.read(localizationProvider.notifier);
      final state = ref.watch(localizationProvider);
      print('savedLang: $state');

      final savedLang = CacheHelper.getString(CacheKeys.appLocale);
      print('savedLang44: $savedLang');

      if (savedLang != null) {
        final parts = savedLang.split('_');

        language.changeLocale(Locale(parts[0], parts[1]));
        context.setLocale(state);
      }
      //   context.pushNamedAndRemoveUntil(AppRoutes.products);

      if (CacheHelper.getBool(CacheKeys.isFirstTime) == true ||
          CacheHelper.getBool(CacheKeys.isFirstTime) == null) {
        context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
      } else {
        context.pushNamedAndRemoveUntil(AppRoutes.onBoarding);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              CacheHelper.isDarkMode
                  ? AppImages.styleImageDark
                  : AppImages.styleImage,
            ),
          ),

          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: const CircularProgressIndicator(),
          // ),
        ],
      ),
    );
  }
}
