import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:base_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:base_app/core/constans/app_localizations_constants.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/theme/app_theme.dart';
import 'package:base_app/core/theme/theme_provider.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _DevHttpOverrides();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await EasyLocalization.ensureInitialized();

  final cacheHelper = CacheHelper();
  await cacheHelper.init();
  // await cacheHelper.clear();

  runApp(
    EasyLocalization(
      startLocale: AppLocalizationsConstants().arLocale,
      supportedLocales: AppLocalizationsConstants().supportedLocales,
      path: AppLocalizationsConstants().path,
      saveLocale: true,
      child: const ProviderScope(child: BaseApp()),
    ),
  );
}

class BaseApp extends ConsumerStatefulWidget {
  const BaseApp({super.key});

  @override
  ConsumerState<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends ConsumerState<BaseApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Ensure any ringtone started in background or during launch is stopped
    OrderSoundService.stopRingtone();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OrderSoundService.stopRingtone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Quick Delivery',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRoutes.splash,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        themeAnimationDuration: const Duration(milliseconds: 300),
        themeAnimationCurve: Curves.easeInOut,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}

///dart tools/generate_app_strings_easy.dart
