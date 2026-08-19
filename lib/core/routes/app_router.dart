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
import 'package:base_app/features/customer/orders/presentation/screens/rate_order_screen.dart';
import 'package:base_app/features/customer/vendor_list/presentation/screens/vendor_list_screen.dart';
import 'package:base_app/features/customer/home/presentation/screens/search_results_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/profile_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/personal_info_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/address_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/add_address_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/wallet_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/settings_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/contact_us_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/about_us_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/terms_and_conditions_screen.dart';
import 'package:base_app/features/customer/profile/presentation/screens/change_password_screen.dart';
import 'package:base_app/features/shared/chat/presentation/screens/chat_details_screen.dart';
import 'package:base_app/features/shared/chat/presentation/screens/chats_screen.dart';
import 'package:base_app/core/models/app_chat_argument.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_nav_screen.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_order_details_screen.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_registration_details_screen.dart';

import 'package:base_app/features/customer/home/presentation/screens/special_offer_details_screen.dart';
import 'package:base_app/features/customer/home/presentation/screens/all_offers_screen.dart';
import 'package:base_app/features/customer/favorites/presentation/screens/favorites_screen.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/vendor_details/presentation/screens/store_product_details_screen.dart';
import 'package:base_app/features/customer/home/presentation/screens/category_products_screen.dart';
import 'package:base_app/features/customer/home/presentation/screens/all_categories_screen.dart';
import 'package:base_app/features/delivery/captain/presentation/screens/captain_register_screen.dart';

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
        final OrderDto order = settings.arguments as OrderDto;
        return _buildAnimatedRoute(CaptainOrderDetailsScreen(order: order), settings);
      case AppRoutes.providerNav:
        return _buildAnimatedRoute(
          const Scaffold(body: Center(child: Text('Page not found'))),
          settings,
        );
      case AppRoutes.providerStoreScreen:
      case AppRoutes.providerProductDetailsScreen:
        final UserDto vendor;
        final CategoryDto? initialCategory;
        if (settings.arguments is Map<String, dynamic>) {
          final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
          vendor = args['vendor'] as UserDto;
          initialCategory = args['initialCategory'] as CategoryDto?;
        } else {
          vendor = settings.arguments as UserDto;
          initialCategory = null;
        }
        return _buildAnimatedRoute(
          VendorDetailsScreen(vendor: vendor, initialCategory: initialCategory),
          settings,
        );
      case AppRoutes.chatsScreen:
        return _buildAnimatedRoute(const ChatsScreen(), settings);
      case AppRoutes.chatDetailsScreen:
        final args = settings.arguments;
        int? chatId;
        UserDto creator;

        if (args is AppChatArgument) {
          chatId = args.chatId;
          creator = UserDto(
            id: args.recipientId,
            name: args.recipientName,
            photo: args.recipientImage,
            role: args.typeEnum.index,
            status: 1,
          );
        } else if (args is Map<String, dynamic>) {
          chatId = args['chatId'] as int?;
          creator = args['creator'] as UserDto;
        } else {
          final String title = (args as String?) ?? AppStrings.technicalSupportTitle;
          chatId = null;
          creator = UserDto(
            id: 1,
            name: title,
            role: 4,
            status: 1,
          );
        }
        return _buildAnimatedRoute(ChatDetailsScreen(chatId: chatId, creator: creator), settings);
      case AppRoutes.cartScreen:
        return _buildAnimatedRoute(const CartScreen(), settings);
      case AppRoutes.cart: // Re-using cart if needed or specifically for Checkout
        final Object? args = settings.arguments;
        final OfferDto? offer = args is OfferDto ? args : null;
        return _buildAnimatedRoute(CheckoutScreen(offer: offer), settings);
      case AppRoutes.orderDetailsScreen:
        final OrderDto? trackOrder = settings.arguments is OrderDto ? settings.arguments as OrderDto : null;
        return _buildAnimatedRoute(OrderTrackingScreen(order: trackOrder), settings);
      case AppRoutes.allCategoriesScreen:
        return _buildAnimatedRoute(const AllCategoriesScreen(), settings);
      case AppRoutes.captainRegisterScreen:
        return _buildAnimatedRoute(const CaptainRegisterScreen(), settings);
      case AppRoutes.StoreScreen:
        final Object? args = settings.arguments;
        if (args is VendorListArgs) {
          return _buildAnimatedRoute(
            VendorListScreen(title: args.title, categoryId: args.categoryId, userRole: args.userRole),
            settings,
          );
        }
        final String title = (args as String?) ?? AppStrings.storesTitle;
        return _buildAnimatedRoute(VendorListScreen(title: title), settings);
      case AppRoutes.specialOfferDetails:
        final OfferDto? offer = settings.arguments as OfferDto?;
        return _buildAnimatedRoute(SpecialOfferDetailsScreen(offer: offer), settings);
      case AppRoutes.allOffersScreen:
        final String title = (settings.arguments as String?) ?? 'العروض';
        return _buildAnimatedRoute(AllOffersScreen(title: title), settings);
      case AppRoutes.searchResults:
        final String query = (settings.arguments as String?) ?? '';
        return _buildAnimatedRoute(SearchResultsScreen(query: query), settings);
      case AppRoutes.categoryProductsScreen:
        if (settings.arguments is CategoryDto) {
          final CategoryDto category = settings.arguments as CategoryDto;
          return _buildAnimatedRoute(CategoryProductsScreen(category: category), settings);
        } else if (settings.arguments is Map<String, dynamic>) {
          final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
          final CategoryDto category = CategoryDto(
            id: args['categoryId'] as int,
            name: args['categoryTitle'] as String?,
            type: (args['type'] as int?) ?? 1,
            creatorId: (args['creatorId'] as int?) ?? 0,
          );
          return _buildAnimatedRoute(CategoryProductsScreen(category: category), settings);
        }
        return _buildAnimatedRoute(
          const Scaffold(body: Center(child: Text('Invalid Arguments'))),
          settings,
        );
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
      case AppRoutes.aboutUs:
        return _buildAnimatedRoute(const AboutUsScreen(), settings);
      case AppRoutes.termsAndConditions:
        return _buildAnimatedRoute(const TermsAndConditionsScreen(), settings);
      case AppRoutes.contactUs:
        return _buildAnimatedRoute(const ContactUsScreen(), settings);
      case AppRoutes.changePassword:
        return _buildAnimatedRoute(const ChangePasswordScreen(), settings);
      case AppRoutes.favorites:
        return _buildAnimatedRoute(const FavoritesScreen(), settings);
      case AppRoutes.sendReview:
        final UserDto? vendor = settings.arguments as UserDto?;
        return _buildAnimatedRoute(RateOrderScreen(vendor: vendor), settings);
      case AppRoutes.storeProductDetailsScreen:
        final args = settings.arguments;
        if (args is ProductDetailDto) {
          return _buildAnimatedRoute(StoreProductDetailsScreen(product: args), settings);
        } else if (args is Map<String, dynamic>) {
          return _buildAnimatedRoute(
            StoreProductDetailsScreen(
              product: args['product'] as ProductDetailDto,
              vendorId: args['vendorId'] as int?,
            ),
            settings,
          );
        }
        return _buildAnimatedRoute(
          const Scaffold(body: Center(child: Text('Invalid Arguments'))),
          settings,
        );
      case AppRoutes.profileScreen:
        return _buildAnimatedRoute(const ProfileScreen(), settings);
      case AppRoutes.products:
        final CategoryDto category = settings.arguments as CategoryDto;
        return _buildAnimatedRoute(CategoryProductsScreen(category: category), settings);

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

class VendorListArgs {
  final String title;
  final int? categoryId;
  final int? userRole;

  VendorListArgs({required this.title, this.categoryId, this.userRole});
}
