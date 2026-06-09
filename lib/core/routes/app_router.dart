// lib/core/routes/app_router.dart
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/features/customer/cart/presentation/screens/cart_screen.dart';
import 'package:base_app/features/shared/on_boarding/screens/on_boarding_screen.dart';
import 'package:base_app/features/shared/splash/presentation/screens/splash_screen.dart';
import 'package:base_app/features/customer/vendor_details/presentation/screens/vendor_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/shared/auth/presentation/screens/login_screen.dart';
import 'package:base_app/features/shared/choose_lang_and_type/presentation/screens/choose_user_type_screen.dart';
import 'package:base_app/features/shared/choose_lang_and_type/presentation/screens/choose_your_language_screen.dart';
import 'package:base_app/features/shared/notifications/presentation/screens/notifications_screen.dart';

import 'package:base_app/features/shared/auth/domain/business_type.dart';
import 'package:base_app/features/shared/auth/presentation/screens/about_type_screen.dart';
import 'package:base_app/features/shared/auth/presentation/screens/create_new_password_screen.dart';
import 'package:base_app/features/shared/auth/presentation/screens/forget_password_screen.dart';
import 'package:base_app/features/shared/auth/presentation/screens/otp_screen.dart';

import 'package:base_app/features/shared/auth/presentation/screens/register_screen.dart';

import 'package:base_app/features/customer/main_nav/presentation/screens/user_nav_screen.dart';

import 'package:base_app/features/customer/checkout/presentation/screens/checkout_screen.dart';
import 'package:base_app/features/customer/orders/presentation/screens/order_tracking_screen.dart';
import 'package:base_app/features/customer/vendor_list/presentation/screens/vendor_list_screen.dart';
import 'package:base_app/features/customer/home/presentation/screens/search_results_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/personal_info_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/address_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/add_address_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/wallet_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/settings_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/contact_us_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/change_password_screen.dart';
import 'package:base_app/features/shared/chats/presentation/screens/chat_details_screen.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_nav_screen.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_order_details_screen.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_registration_details_screen.dart';

import 'package:base_app/features/customer/home/presentation/screens/special_offer_details_screen.dart';

abstract class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onBoarding:
        return _buildAnimatedRoute(const OnboardingScreen(), settings);
      case AppRoutes.splash:
        return _buildAnimatedRoute(const SplashScreen(), settings);
      case AppRoutes.chooseYourLanguageScreen:
        return _buildAnimatedRoute(const ChooseYourLanguageScreen(), settings);
      case AppRoutes.chooseUserTypeScreen:
        return _buildAnimatedRoute(ChooseUserTypeScreen(), settings);
      case AppRoutes.loginScreen:
        final bool isUser = (settings.arguments as bool?) ?? false;
        return _buildAnimatedRoute(LoginScreen(isUser: isUser), settings);
      case AppRoutes.forgetPasswordScreen:
        final bool isUser = (settings.arguments as bool?) ?? false;
        return _buildAnimatedRoute(
          ForgetPasswordScreen(isUser: isUser),
          settings,
        );
      case AppRoutes.otpScreen:
        final args = settings.arguments;
        OtpArgs otpArgs;
        if (args is OtpArgs) {
          otpArgs = args;
        } else if (args is bool) {
          // Legacy: bool argument from old code
          otpArgs = OtpArgs(isUser: args);
        } else {
          otpArgs = const OtpArgs();
        }
        return _buildAnimatedRoute(
          OtpScreen(isUser: otpArgs.isUser, mode: otpArgs.mode),
          settings,
        );
      case AppRoutes.createNewPasswordScreen:
        final bool isUser = (settings.arguments as bool?) ?? false;
        return MaterialPageRoute(
          builder: (_) => CreateNewPasswordScreen(isUser: isUser),
        );
      case AppRoutes.registerScreen:
        final bool isUser = (settings.arguments as bool?) ?? false;
        return _buildAnimatedRoute(RegisterScreen(isUser: isUser), settings);
      case AppRoutes.completeRegisterScreen:
        return _buildAnimatedRoute(
          AboutTypeScreen(businessType: BusinessType.salon),
          settings,
        );
      case AppRoutes.notifications:
        return _buildAnimatedRoute(const NotificationsScreen(), settings);
      case AppRoutes.userNav:
        return _buildAnimatedRoute(const UserNavScreen(), settings);
      case AppRoutes.captainNav:
        return _buildAnimatedRoute(const CaptainNavScreen(), settings);
      case AppRoutes.captainRegistrationDetails:
        return _buildAnimatedRoute(const CaptainRegistrationDetailsScreen(), settings);
      case AppRoutes.captainOrderDetails:
        return _buildAnimatedRoute(const CaptainOrderDetailsScreen(), settings);
      case AppRoutes.providerNav:
        return _buildAnimatedRoute(
          const Scaffold(body: Center(child: Text('Page not found'))),
          settings,
        );
      case AppRoutes.providerProductDetailsScreen:
        final bool isMarket = (settings.arguments as bool?) ?? false;
        return _buildAnimatedRoute(VendorDetailsScreen(isMarket: isMarket), settings);
      case AppRoutes.chatDetailsScreen:
        final String name = (settings.arguments as String?) ?? AppStrings.technicalSupportTitle;
        return _buildAnimatedRoute(ChatDetailsScreen(name: name), settings);
      case AppRoutes.cartScreen:
        return _buildAnimatedRoute(const CartScreen(), settings);
      case AppRoutes.cart: // Re-using cart if needed or specifically for Checkout
        return _buildAnimatedRoute(const CheckoutScreen(), settings);
      case AppRoutes.orderDetailsScreen:
        return _buildAnimatedRoute(const OrderTrackingScreen(), settings);
      case AppRoutes.StoreScreen:
        final String title = (settings.arguments as String?) ?? AppStrings.storesTitle;
        return _buildAnimatedRoute(VendorListScreen(title: title), settings);
      case AppRoutes.specialOfferDetails:
        return _buildAnimatedRoute(const SpecialOfferDetailsScreen(), settings);
      case AppRoutes.searchResults:
        final String query = (settings.arguments as String?) ?? '';
        return _buildAnimatedRoute(SearchResultsScreen(query: query), settings);
      case AppRoutes.personalInfo:
        return _buildAnimatedRoute(const PersonalInfoScreen(), settings);
      case AppRoutes.address:
        return _buildAnimatedRoute(const AddressScreen(), settings);
      case AppRoutes.addAddress:
        return _buildAnimatedRoute(const AddAddressScreen(), settings);
      case AppRoutes.wallet:
        return _buildAnimatedRoute(const WalletScreen(), settings);
      case AppRoutes.settings:
        return _buildAnimatedRoute(const SettingsScreen(), settings);
      case AppRoutes.privacyPolicy:
        return _buildAnimatedRoute(const PrivacyPolicyScreen(), settings);
      case AppRoutes.contactUs:
        return _buildAnimatedRoute(const ContactUsScreen(), settings);
      case AppRoutes.changePassword:
        return _buildAnimatedRoute(const ChangePasswordScreen(), settings);

      default:
        return _buildAnimatedRoute(
          const Scaffold(body: Center(child: Text('Page not found'))),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildAnimatedRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page, // ✅ Riverpod مش محتاج wrapper
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
