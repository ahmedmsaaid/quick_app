# Quick Project — AI Agent Rules & Architecture Reference

> **Purpose**: Complete reference for the `Quick` Flutter application and Dashboard. An AI agent should read this file FIRST before touching any code to understand architecture, patterns, and conventions. Keep this file in sync with every change.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Structure — Flutter App](#2-project-structure--flutter-app)
3. [Project Structure — Dashboard](#3-project-structure--dashboard)
4. [User Roles](#4-user-roles)
5. [Tech Stack](#5-tech-stack)
6. [State Management (Riverpod)](#6-state-management-riverpod)
7. [Network Layer](#7-network-layer)
8. [API Endpoints Reference](#8-api-endpoints-reference)
9. [Backend API Rules (Swagger)](#9-backend-api-rules-swagger)
10. [Navigation & Routing](#10-navigation--routing)
11. [Theming & Colors](#11-theming--colors)
12. [Typography](#12-typography)
13. [Localization](#13-localization)
14. [Local Storage (Cache)](#14-local-storage-cache)
15. [Core Widgets](#15-core-widgets)
16. [Feature Structure Pattern](#16-feature-structure-pattern)
17. [Dashboard Architecture](#17-dashboard-architecture)
18. [Coding Conventions](#18-coding-conventions)
19. [Common Patterns & How-Tos](#19-common-patterns--how-tos)

---

## 1. Project Overview

| Field | Value |
|-------|-------|
| **App Name** | Quick |
| **Package** | `base_app` (internal Dart package name) |
| **Version** | `1.0.0+1` |
| **Dart SDK** | `^3.8.1` |
| **Framework** | Flutter |
| **Architecture** | Feature-Driven (Data → Presentation, no domain layer) |
| **State Management** | **Riverpod** (flutter_riverpod ^3.1.0 + riverpod_annotation) |
| **HTTP Client** | Dio ^5.8.0 |
| **Backend Base URL** | `https://quick-service.runasp.net/api/v1/` |
| **Supabase Storage URL** | `https://uzpvlmgqwpxcuvngsayb.supabase.co/storage/v1/object/public/quick-service-photos/` |
| **API Reference** | `tools/swagger.json` — Primary source of truth for all API endpoints |
| **Locales** | Arabic (`ar`), English (`en`) |
| **Default Locale** | Arabic (`ar`) |
| **Font** | Cairo (all weights from ExtraLight to Black) |
| **Design Size** | 393x852 (ScreenUtil) |

There are **two separate projects**:
- **Flutter App**: `f:\StudioProjects\FREELANCE\quick\` — serves Customer and Captain (delivery) users
- **Dashboard** (Web): `f:\StudioProjects\FREELANCE\quick_dashboard\` — serves Restaurant/Market vendors and Super Admin

---

## 2. Project Structure — Flutter App

```
lib/
├── main.dart                          # Entry point — ProviderScope + EasyLocalization + Hive
├── core/
│   ├── bloc_observer.dart
│   ├── constans/                      # App-wide constants + localization constants
│   ├── error/                         # Error handling (error_handler.dart)
│   ├── exports/                       # Barrel exports
│   ├── extintions/                    # Extensions (NOTE: typo in folder name — DO NOT rename)
│   ├── hilpers/                       # repo_helper.dart — RepositoryHelper & RepositoryExecutor
│   ├── localizations/
│   │   ├── app_strings.g.dart        # Auto-generated localization keys — DO NOT edit manually
│   │   └── localization_provider.dart
│   ├── models/                        # Shared data models
│   ├── network/
│   │   ├── api_constants.dart        # All API endpoint constants — ADD NEW ENDPOINTS HERE
│   │   ├── api_error_model.dart
│   │   ├── api_result.dart           # ApiResult<T> (success/failure freezed union)
│   │   ├── dio_factory.dart          # dioProvider — Riverpod provider for Dio instance
│   │   └── dio_interceptor.dart      # Auth token injection + 401 auto-refresh
│   ├── pagination/                    # Pagination utilities
│   ├── providers/
│   │   └── image_picker_provider.dart
│   ├── routes/
│   │   ├── app_router.dart           # Route handler — onGenerateRoute switch
│   │   └── app_routes.dart           # Route name constants — ADD NEW ROUTES HERE
│   ├── services/
│   │   ├── api_service_module.dart
│   │   ├── cach_helper/              # (typo in folder — DO NOT rename)
│   │   │   ├── cache_helper.dart     # Hive-based key-value storage
│   │   │   └── cache_helper_keys.dart # CacheKeys class
│   │   ├── image_picker_service.dart
│   │   ├── local_notification/
│   │   ├── maps_service.dart
│   │   └── push_notification/
│   ├── styles/
│   │   ├── app_colors.dart           # AppColors — theme-aware color system
│   │   └── app_text_style.dart       # AppTextStyles — Cairo font text styles
│   ├── theme/
│   │   ├── app_theme.dart            # Light & Dark theme definitions
│   │   └── theme_provider.dart       # themeNotifierProvider (Riverpod)
│   ├── usecase.dart
│   ├── utils/
│   └── widgets/                      # Shared reusable widgets
│       ├── app_drop_down.dart
│       ├── cached_network_image.dart
│       ├── custom_app_bar.dart
│       ├── custom_arrow_back.dart
│       ├── custom_button.dart
│       ├── custom_cached_network_img.dart
│       ├── custom_dialog.dart
│       ├── custom_icon_badge.dart
│       ├── custom_text_field.dart
│       ├── custom_toast.dart
│       ├── custome_svg_image.dart
│       ├── image_avatar_widget.dart
│       ├── lading_button.dart
│       ├── loading_dialog.dart
│       ├── see_all_widget.dart
│       ├── shimmer_palcholder.dart
│       └── shimmer_widget.dart
└── features/
    ├── customer/                      # Customer-facing features
    │   ├── cart/
    │   ├── checkout/
    │   ├── community/
    │   ├── favorites/
    │   ├── home/
    │   ├── main_nav/
    │   ├── orders/
    │   ├── profile/
    │   ├── stream/
    │   ├── vendor_details/
    │   └── vendor_list/
    ├── delivery/                      # Captain (delivery) features
    │   ├── captain/
    │   ├── main_nav/
    │   └── wallet/
    └── shared/                        # Shared between all user types
        ├── auth/                      # Login, Register, OTP, Forgot Password
        ├── chats/
        ├── choose_lang_and_type/
        ├── notifications/
        ├── on_boarding/
        └── splash/
```

---

## 3. Project Structure — Dashboard

**Path**: `f:\StudioProjects\FREELANCE\quick_dashboard\`

```
quick_dashboard/
├── index.html           # Super Admin dashboard entry
├── login.html           # Shared login page for all dashboard roles
├── restaurant.html      # Restaurant vendor dashboard
├── market.html          # Market vendor dashboard
├── super-admin.html     # Super Admin panel
├── swagger.json         # Full API Swagger spec (same as app's tools/swagger.json)
├── css/
│   └── style.css        # Single CSS file for entire dashboard
└── js/
    ├── login.js         # Login logic + role detection + token storage
    ├── restaurant.js    # Restaurant dashboard: orders, products, offers, stats
    ├── market.js        # Market dashboard: orders, products, categories, stats
    ├── super-admin.js   # Super admin: users, settings, content management
    ├── auth-check.js            # Auth guard for super-admin
    ├── auth-check-restaurant.js # Auth guard for restaurant
    ├── auth-check-market.js     # Auth guard for market
    ├── gateway.js       # API gateway / base URL configuration
    ├── translations.js  # i18n strings (AR/EN) for dashboard
    ├── ui-utils.js      # Shared UI utility functions
    ├── mock-data.js     # Mock/test data for development
    ├── pretty-logger.js # Console logger utility
    └── chart.umd.min.js # Chart.js library (bundled)
```

---

## 4. User Roles

| Role | Value | App/Dashboard | Nav Screen |
|------|-------|---------------|------------|
| **Customer** | `role: 0` (user) | Flutter App | `UserNavScreen` → `/userNav` |
| **Captain** (Delivery) | Captain account | Flutter App | `CaptainNavScreen` → `/captainNav` |
| **Restaurant** (Vendor) | `role: 0` (provider) | Dashboard | `restaurant.html` |
| **Market** (Vendor) | `role: 1` (provider) | Dashboard | `market.html` |
| **Super Admin** | Admin account | Dashboard | `super-admin.html` |

### Role Detection (Flutter)
- Stored in `CacheHelper` via `CacheKeys.token` and `'refreshToken'`
- User type determined by API response on login
- Vendors (providers) currently routed to placeholder — `providerNav` route shows "Page not found"
- Captain goes to `/captainNav`

### Dashboard Role Detection
- Login page (`login.html` + `login.js`) detects role from API response
- Stores `accessToken`, `refreshToken`, `userRole` in `localStorage`
- Redirects to appropriate HTML page based on role

---

## 5. Tech Stack

### Flutter App
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^3.1.0 | State management |
| `riverpod_annotation` | ^4.0.0 | Code gen for providers |
| `riverpod_generator` | ^4.0.0+1 | Build runner code gen |
| `dio` | ^5.8.0+1 | HTTP client |
| `retrofit` | 4.9.0 | Available but NOT used — use raw Dio instead |
| `hive_ce` + `hive_ce_flutter` | ^2.x | Local storage |
| `easy_localization` | ^3.0.8 | i18n |
| `flutter_screenutil` | ^5.9.0 | Responsive sizing |
| `freezed` + `freezed_annotation` | ^3.x | Immutable models & unions |
| `json_serializable` | ^6.9.0 | JSON serialization |
| `firebase_messaging` | ^15.x | Push notifications |
| `google_maps_flutter` | latest | Maps |
| `geolocator` | ^13.0.1 | GPS location |
| `cached_network_image` | ^3.3.1 | Image caching |
| `flutter_svg` | ^2.2.3 | SVG rendering |
| `lottie` | ^3.3.2 | Animations |
| `shimmer` | ^3.0.0 | Loading placeholders |
| `image_picker` | ^1.2.1 | Camera/gallery |
| `curved_navigation_bar` | ^1.0.6 | Bottom nav bar |
| `smooth_page_indicator` | ^2.0.1 | Page indicators |

### Dashboard
- **Vanilla HTML + CSS + JavaScript** (no framework, no build tool)
- **Chart.js** (bundled as `chart.umd.min.js`) for statistics charts
- **No npm/node** — pure static files

---

## 6. State Management (Riverpod)

The app uses **Riverpod** exclusively. No BLoC, no GetIt.

### Provider Types Used

| Type | Usage |
|------|-------|
| `@riverpod` (function) | Simple providers, API service instances |
| `@riverpod` class (`Notifier`) | Stateful logic with StateNotifier-like pattern |
| `ref.watch()` | In build methods to reactively rebuild |
| `ref.read()` | In event handlers (mutations, one-time reads) |

### Standard Notifier Pattern
```dart
class FeatureState {
  final FeatureStatus status;
  final List<SomeDto> items;
  final String? errorMessage;
  
  const FeatureState({
    this.status = FeatureStatus.initial,
    this.items = const [],
    this.errorMessage,
  });
  
  FeatureState copyWith({...}) => FeatureState(...);
}

enum FeatureStatus { initial, loading, loaded, error }

@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  FeatureState build() {
    Future.microtask(() => loadData());
    return const FeatureState();
  }
  
  Future<void> loadData() async {
    state = state.copyWith(status: FeatureStatus.loading);
    final result = await ref.read(featureApiServiceProvider).getSomething();
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(status: FeatureStatus.loaded, items: response.result!);
        } else {
          state = state.copyWith(status: FeatureStatus.error, errorMessage: response.message);
        }
      },
      failure: (error) => state = state.copyWith(
        status: FeatureStatus.error, errorMessage: error.message),
    );
  }
}
```

### Code Generation
After adding/modifying any `@riverpod` annotated code, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### ApiResult Usage
```dart
// ApiResult<T> is a Freezed union:
result.when(
  success: (data) { /* data is the parsed response */ },
  failure: (error) { /* error.message is the error string */ },
);
```

---

## 7. Network Layer

### Dio Instance
- Provider: `dioProvider` in `lib/core/network/dio_factory.dart`
- Each API service class takes `Dio` via constructor and watches `dioProvider`

### DioInterceptor (`lib/core/network/dio_interceptor.dart`)
- Injects `Authorization: Bearer <token>` from `CacheHelper.getString(CacheKeys.token)` or fallback `'tempToken'`
- Injects `Accept-Language` from `CacheHelper.currentLang`
- **Auto token refresh**: On `401`, calls `PATCH /api/v1/users/refresh-token` with `{refreshToken}`, stores new tokens, retries original request

### API Service Pattern
```dart
@riverpod
MyApiService myApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MyApiService(dio);
}

class MyApiService {
  final Dio _dio;
  MyApiService(this._dio);
  
  Future<ApiResult<ApiResponse<T>>> doSomething() async {
    try {
      final response = await _dio.get('endpoint-path');
      final apiResponse = ApiResponse<T>.fromJson(
        response.data, (json) => T.fromJson(json));
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
```

### Pagination Pattern (PATCH requests)
The backend uses `PATCH` for paginated queries with body:
```dart
await _dio.patch(
  'endpoint',
  data: {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'enablePagination': true,        // false = get all
    'filters': { 'field': value },   // optional filters
    'includesPath': ['Relation'],    // optional eager loading
    'search': 'query',               // optional search
    'orderByRate': true,             // optional ordering
  },
);
```

### ApiResponse Structure
```json
{
  "success": true,
  "message": "...",
  "result": {}
}
```
Always check `response.success && response.result != null` before using data.

---

## 8. API Endpoints Reference

### `lib/core/network/api_constants.dart` — Current Endpoint Constants
| Constant | Path |
|----------|------|
| `baseUrl` | `https://quick-service.runasp.net/api/v1/` |
| `streamUrl` | `https://uzpvlmgqwpxcuvngsayb.supabase.co/storage/v1/object/public/quick-service-photos/` |
| `signup` | `users/signup` |
| `captainSignup` | `deliveries/signup` |
| `login` | `users/login` |
| `sendOtp` | `users/send-otp` |
| `verifyOtp` | `users/verify-otp` |
| `refreshToken` | `users/refresh-token` (PATCH) |
| `logout` | `users/logout` |
| `logoutAllDevices` | `users/logout-all-devices` |
| `changePassword` | `users/change-password` |
| `resetPassword` | `users/reset-password` |
| `locations` | `locations` |
| `toggleActivity` | `users/toggle-activity` |
| `profile` | `users` |
| `getById` | `users/get-by-id` |
| `updateProfile` | `users/update-profile` |
| `deleteAccount` | `users/delete-account` |
| `addFcmToken` | `users/add-fcm-token` |
| `stream` | `stream/public` |
| `offers` | `offers` |
| `productsPaginate` | `products/paginate` |
| `usersPaginate` | `users/paginate` |
| `categories` | `categories` |
| `mainCategories` | `main-categories` |
| `productRating` | `product-rating` |
| `userRating` | `user-rating` |
| `settings` | `settings` |

### All Available API Paths (from Swagger)
> **IMPORTANT**: For any new API call, ALWAYS check `tools/swagger.json` first.

| Path | Tags |
|------|------|
| `/api/v1/about-us` | AboutUs |
| `/api/v1/about-us/{id}` | AboutUs |
| `/api/v1/categories` | Categories |
| `/api/v1/categories/{id}` | Categories |
| `/api/v1/chats` | Chats |
| `/api/v1/chats/{id}` | Chats |
| `/api/v1/contact-us` | ContactUs |
| `/api/v1/contact-us/{id}` | ContactUs |
| `/api/v1/deliveries/signup` | Deliveries |
| `/api/v1/deliveries/get-by-id/{id}` | Deliveries |
| `/api/v1/deliveries` | Deliveries |
| `/api/v1/deliveries/update-identification` | Deliveries |
| `/api/v1/discounts` | Discounts |
| `/api/v1/discounts/{id}` | Discounts |
| `/api/v1/favorites` | Favorites |
| `/api/v1/locations` | Locations |
| `/api/v1/locations/{id}` | Locations |
| `/api/v1/main-categories` | MainCategories |
| `/api/v1/main-categories/{id}` | MainCategories |
| `/api/v1/messages` | Messages |
| `/api/v1/messages/{id}` | Messages |
| `/api/v1/offers/toggle-approval/{id}` | Offers |
| `/api/v1/offers` | Offers |
| `/api/v1/offers/{id}` | Offers |
| `/api/v1/orders/status` | Orders |
| `/api/v1/orders` | Orders |
| `/api/v1/orders/{id}` | Orders |
| `/api/v1/policies` | Policies |
| `/api/v1/policies/{id}` | Policies |
| `/api/v1/products/{id}` | Products |
| `/api/v1/products/paginate` | Products |
| `/api/v1/products/favorites` | Products |
| `/api/v1/products` | Products |
| `/api/v1/product-rating` | ProductRating |
| `/api/v1/product-rating/{id}` | ProductRating |
| `/api/v1/user-rating` | UserRating |
| `/api/v1/user-rating/{id}` | UserRating |
| `/api/v1/settings` | Settings |
| `/api/v1/stream` | Stream |
| `/api/v1/stream/public` | Stream |
| `/api/v1/users/signup` | Users |
| `/api/v1/users/login` | Users |
| `/api/v1/users/google-auth` | Users |
| `/api/v1/users/add-fcm-token` | Users |
| `/api/v1/users/update-profile` | Users |
| `/api/v1/users/delete-account` | Users |
| `/api/v1/users/send-otp` | Users |
| `/api/v1/users/verify-otp` | Users |
| `/api/v1/users/recover` | Users |
| `/api/v1/users/reset-password` | Users |
| `/api/v1/users/refresh-token` | Users |
| `/api/v1/users/logout` | Users |
| `/api/v1/users/logout-all-devices` | Users |
| `/api/v1/users/change-password` | Users |
| `/api/v1/users/toggle-status` | Users |
| `/api/v1/users/toggle-activity/{userId}` | Users |
| `/api/v1/users/get-by-id/{id}` | Users |
| `/api/v1/users` | Users |
| `/api/v1/users/notifications` | Users |
| `/api/v1/users/count-notifications` | Users |
| `/api/v1/users/read-notifications/{auditId}` | Users |
| `/api/v1/users/paginate` | Users |

---

## 9. Backend API Rules (Swagger)

> **RULE**: For any new feature requiring API calls, open `tools/swagger.json` and verify:
> 1. The exact HTTP method (GET, POST, PUT, PATCH, DELETE)
> 2. The exact path
> 3. Required/optional request body fields and types
> 4. The response schema structure

### Key Behavioral Patterns
- **PATCH = Paginated Query**: `PATCH` on collection endpoints returns a paginated list via request body
- **GET = Single/Simple Query**: `GET` on `/{id}` endpoints returns a single item
- **POST = Create**, **PUT = Update**, **DELETE = Delete**
- All responses wrapped in `{ success: bool, message: string, result: T }`

### Authentication
- All protected endpoints require `Authorization: Bearer <accessToken>` header (injected automatically by `DioInterceptor`)
- Token refresh: `PATCH /api/v1/users/refresh-token` with body `{ "refreshToken": "..." }`

---

## 10. Navigation & Routing

### Route Names (`lib/core/routes/app_routes.dart`)
| Constant | Route | Navigates To |
|----------|-------|-------------|
| `splash` | `/` | `SplashScreen` |
| `onBoarding` | `/onBoarding` | `OnboardingScreen` |
| `chooseYourLanguageScreen` | `/chooseYourLanguageScreen` | `ChooseYourLanguageScreen` |
| `chooseUserTypeScreen` | `/chooseUserTypeScreen` | `ChooseUserTypeScreen` |
| `loginScreen` | `/loginScreen` | `LoginScreen(isUser: bool)` |
| `registerScreen` | `/registerScreen` | `RegisterScreen(isUser: bool)` |
| `forgetPasswordScreen` | `/forgetPasswordScreen` | `ForgetPasswordScreen(isUser: bool)` |
| `createNewPasswordScreen` | `/createNewPasswordScreen` | `CreateNewPasswordScreen` |
| `otpScreen` | `/otpScreen` | `OtpScreen(isUser, mode)` |
| `userNav` | `/userNav` | `UserNavScreen` |
| `captainNav` | `/captainNav` | `CaptainNavScreen` |
| `captainRegistrationDetails` | `/captainRegistrationDetails` | `CaptainRegistrationDetailsScreen` |
| `captainOrderDetails` | `/captainOrderDetails` | `CaptainOrderDetailsScreen(order: OrderDto)` |
| `captainRegisterScreen` | `/captainRegisterScreen` | `CaptainRegisterScreen` |
| `notifications` | `/notifications` | `NotificationsScreen` |
| `cartScreen` | `/cartScreen` | `CartScreen` |
| `cart` | `/cart` | `CheckoutScreen(offer: OfferDto?)` |
| `orderDetailsScreen` | `/orderDetailsScreen` | `OrderTrackingScreen` |
| `providerStoreScreen` | `/providerStoreScreen` | `VendorDetailsScreen(vendor, initialCategory)` |
| `StoreScreen` | `/clientStoreScreen` | `VendorListScreen` |
| `storeProductDetailsScreen` | `/storeProductDetailsScreen` | `StoreProductDetailsScreen` |
| `allCategoriesScreen` | `/allCategoriesScreen` | `AllCategoriesScreen` |
| `products` | `/products` | `CategoryProductsScreen(category: CategoryDto)` |
| `specialOfferDetails` | `/specialOfferDetails` | `SpecialOfferDetailsScreen(offer: OfferDto?)` |
| `searchResults` | `/searchResults` | `SearchResultsScreen(query: String)` |
| `chatDetailsScreen` | `/chatDetailsScreen` | `ChatDetailsScreen(name: String)` |
| `personalInfo` | `/personalInfo` | `PersonalInfoScreen` |
| `address` | `/address` | `AddressScreen` |
| `addAddress` | `/addAddress` | `AddAddressScreen` |
| `wallet` | `/wallet` | `WalletScreen` |
| `settings` | `/settings` | `SettingsScreen` |
| `privacyPolicy` | `/privacyPolicy` | `PrivacyPolicyScreen` |
| `contactUs` | `/contactUs` | `ContactUsScreen` |
| `changePassword` | `/changePassword` | `ChangePasswordScreen` |
| `favorites` | `/favorites` | `FavoritesScreen` |
| `sendReview` | `/sendReview` | `RateOrderScreen(vendor: UserDto?)` |

### Route Transition
All routes use `_buildAnimatedRoute` which applies **FadeTransition + SlideTransition** (0.1 offset from bottom) with 300ms duration.

---

## 11. Theming & Colors

### Theme Provider
```dart
final themeMode = ref.watch(themeNotifierProvider); // returns ThemeMode
```

### AppColors (`lib/core/styles/app_colors.dart`)
Must be instantiated with context: `AppColors(context)`.

| Color Property | Light | Dark | Usage |
|----------------|-------|------|-------|
| `primary` | `#22373F` (brandTeal) | `#20B8B8` | Primary brand color |
| `secondary` | `#FF8A1F` (brandOrange) | `#FFA64D` | Secondary / accent |
| `background` | `#F7FAFA` | `#101718` | Screen background |
| `surface` | `#FFFFFF` | `#172224` | Cards, sheets |
| `cardBackground` | `#FFFFFF` | `#1D2B2D` | Card background |
| `textPrimary` | `#172124` | `#FFFFFF` | Main text |
| `textSecondary` | `#5F6F72` | `#B8C7C7` | Secondary text |
| `textHint` | `#9AA6A8` | `#7E8E90` | Hints, placeholders |
| `error` | `#E54848` | `#E54848` | Error states |
| `success` | `#20A66A` | `#20A66A` | Success states |
| `warning` | `#FFC145` | `#FFC145` | Warning states |
| `border` | `#E1EEEE` | `#2E4245` | Input borders |
| `price` | `#16834A` | `#49D17D` | Price display |
| `discount` | `#E54848` | `#E54848` | Strikethrough price |
| `buttonPrimary` | same as `secondary` | same as `secondary` | Primary button |
| `ratingActive` | `#FFC145` | `#FFC145` | Star rating |

#### Static Colors (no context needed)
```dart
AppColors.white         // Colors.white
AppColors.black         // Colors.black
AppColors.gray          // #A7A7A7
AppColors.brandTeal     // #22373F
AppColors.brandOrange   // #FF8A1F
AppColors.gradient      // LinearGradient teal (#008C8C to #006D6D)
AppColors.orangeGradient // LinearGradient orange (#FF9A2E to #FF7A00)
AppColors.blue          // #0077FF
```

### Usage Pattern
```dart
final colors = AppColors(context);
Container(color: colors.background)
Text('Hello', style: TextStyle(color: colors.textPrimary))
```

---

## 12. Typography

All text uses **Cairo** font. Text styles from `AppTextStyles` (static, no context needed):

```dart
AppTextStyles.text10w500(color: colors.textSecondary)
AppTextStyles.text12w500(color: colors.textPrimary)
AppTextStyles.text14w500()
AppTextStyles.text15w500()
AppTextStyles.text11w400()
// More variants available with weight suffixes (w400, w500, w600, w700, w800, w900)
```

- All font sizes use `.sp` (ScreenUtil responsive)
- Always pass `color` via parameter, NOT via `copyWith` unless necessary
- Default font weight is `w500`

---

## 13. Localization

### Setup
- `EasyLocalization` with `startLocale: ar`, `supportedLocales: [ar, en]`
- Translation files: `assets/translations/ar.json` and `assets/translations/en.json`
- Keys auto-generated into `lib/core/localizations/app_strings.g.dart` via tool

### Usage
```dart
import 'package:base_app/core/localizations/app_strings.g.dart';
Text(AppStrings.someKey.tr())
```

### Adding New Strings
1. Add key + value to both `assets/translations/ar.json` and `assets/translations/en.json`
2. Run: `dart tools/generate_app_strings_easy.dart` to regenerate `app_strings.g.dart`
3. Use `AppStrings.newKey.tr()` in code

> **RULE**: NEVER hardcode Arabic or English text strings in widget code. Always use `AppStrings.key.tr()`.

---

## 14. Local Storage (Cache)

### CacheHelper — `lib/core/services/cach_helper/cache_helper.dart`
Hive-based persistent key-value storage.

### CacheKeys — `lib/core/services/cach_helper/cache_helper_keys.dart`
```dart
CacheKeys.lang          // 'lang' — current language code
CacheKeys.isDark        // 'isDark' — dark mode bool
CacheKeys.token         // 'token' — access token
CacheKeys.isFirstTime   // 'isFirstTime' — onboarding flag
CacheKeys.appLocale     // 'appLocale' — saved locale
```

### Other Keys (used as raw strings)
```dart
'refreshToken'    // Stored by DioInterceptor
'tempToken'       // Fallback token (used before full auth)
```

### Usage
```dart
CacheHelper.getString(CacheKeys.token)        // read string
await CacheHelper.setString(CacheKeys.token, val)  // write string
CacheHelper.getBool(CacheKeys.isDark)          // read bool
await CacheHelper.setBool(CacheKeys.isDark, true)  // write bool
CacheHelper.currentLang                        // getter for current lang string
await CacheHelper.clear()                      // clear all (logout)
```

---

## 15. Core Widgets

Use these shared widgets instead of creating duplicates:

| File | Widget | Purpose |
|------|--------|---------|
| `custom_button.dart` | `CustomButton` | Primary action button |
| `lading_button.dart` | `LadingButton` | Loading state button |
| `custom_text_field.dart` | `CustomTextField` | Form input field |
| `app_drop_down.dart` | `AppDropDown` | Dropdown selector |
| `custom_app_bar.dart` | `CustomAppBar` | Consistent app bar |
| `custom_arrow_back.dart` | `CustomArrowBack` | Back navigation button |
| `cached_network_image.dart` | `CachedNetworkImageWidget` | Remote image with cache |
| `custom_cached_network_img.dart` | `CustomCachedNetworkImg` | Alternative cached image |
| `custome_svg_image.dart` | `CustomSvgImage` | SVG renderer |
| `image_avatar_widget.dart` | `ImageAvatarWidget` | User/vendor avatar |
| `custom_dialog.dart` | `CustomDialog` | Confirmation/info dialogs |
| `loading_dialog.dart` | `LoadingDialog` | Full-screen loading overlay |
| `custom_toast.dart` | `CustomToast` | Toast messages |
| `shimmer_widget.dart` | `ShimmerWidget` | Shimmer loading animation |
| `shimmer_palcholder.dart` | `ShimmerPalcholder` | Shimmer placeholder |
| `custom_icon_badge.dart` | `CustomIconBadge` | Icon with notification badge |
| `see_all_widget.dart` | `SeeAllWidget` | "See all" row with navigation |

---

## 16. Feature Structure Pattern

Each feature follows this two-layer structure (no domain layer):

```
features/<category>/<feature_name>/
├── data/
│   ├── <feature>_api_service.dart    # @riverpod + Dio API class
│   ├── <feature>_api_service.g.dart  # Auto-generated
│   └── models/
│       ├── <feature>_model.dart      # Freezed DTO + fromJson/toJson
│       └── <feature>_model.g.dart    # Auto-generated
└── presentation/
    ├── riverpod/
    │   ├── <feature>_provider.dart   # Notifier + State class
    │   └── <feature>_provider.g.dart # Auto-generated
    ├── screens/
    │   └── <feature>_screen.dart
    └── widgets/
        └── <feature>_widget.dart
```

### Key Rules
- **No repository pattern** — API service is called directly from Notifiers via `ref.read()`
- **No BLoC/Cubit** — use Riverpod Notifiers only
- **No domain entities** — use DTOs directly in UI
- `RepositoryHelper` in `core/hilpers/repo_helper.dart` is available but optional

---

## 17. Dashboard Architecture

### Technology
- Pure **HTML + CSS + JavaScript** (no framework, no build tool)
- Single `css/style.css` for all pages
- Each page has its own dedicated JS file

### Base URL
Defined in `js/gateway.js`:
```javascript
const BASE_URL = 'https://quick-service.runasp.net/api/v1/';
```

### Auth Flow (Dashboard)
1. `login.html` — user enters credentials
2. `login.js` calls `POST /api/v1/users/login`
3. Response role determines redirect to appropriate HTML page
4. Tokens stored in `localStorage` (`accessToken`, `refreshToken`, `userRole`)
5. Each page's auth-check JS validates token on load and redirects to login if invalid

### i18n (Dashboard)
- All strings in `js/translations.js` as `{ ar: {...}, en: {...} }` objects
- Language toggle stored in `localStorage`
- Apply translations with `element.textContent = translations[lang].key`

### Dashboard Pages Summary
| Page | HTML File | JS File | Role |
|------|-----------|---------|------|
| Login | `login.html` | `login.js` | All roles |
| Restaurant | `restaurant.html` | `restaurant.js` | Restaurant vendor |
| Market | `market.html` | `market.js` | Market vendor |
| Super Admin | `super-admin.html` | `super-admin.js` | Admin |

---

## 18. Coding Conventions

### File Naming
- All Dart files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`

### Known Folder Name Typos — DO NOT RENAME
These typos exist in the codebase and renaming would break all imports:
- `extintions/` (should be `extensions/`)
- `hilpers/` (should be `helpers/`)
- `cach_helper/` (should be `cache_helper/`)
- `constans/` (should be `constants/`)

### Import Style — Always Absolute
```dart
// CORRECT
import 'package:base_app/core/styles/app_colors.dart';

// WRONG
import '../../../styles/app_colors.dart';
```

### Null Safety
- Use `??` for defaults, `?.` for optional chaining
- Always check `response.success && response.result != null` before using API data

### Responsive Sizing (ScreenUtil)
- Use `.w` for widths, `.h` for heights, `.sp` for font sizes
- Design reference size: **393x852**
- Never use raw pixel values

---

## 19. Common Patterns & How-Tos

### How to Add a New Screen
1. Create file in `features/<category>/<feature>/presentation/screens/`
2. Add route constant to `AppRoutes` in `lib/core/routes/app_routes.dart`
3. Add case to `AppRouter.onGenerateRoute` in `lib/core/routes/app_router.dart`
4. Navigate using `Navigator.pushNamed(context, AppRoutes.newScreen)`

### How to Add a New API Call
1. Check `tools/swagger.json` for endpoint spec
2. Add constant to `ApiConstants` in `lib/core/network/api_constants.dart`
3. Add method to the feature's `_api_service.dart`
4. Call from Notifier via `ref.read(featureApiServiceProvider).newMethod()`
5. Run: `dart run build_runner build --delete-conflicting-outputs`

### How to Add a New Riverpod Provider
1. Create `_provider.dart` with `@riverpod` annotation
2. Add `part '<file>_provider.g.dart';` at top of file
3. Run: `dart run build_runner build --delete-conflicting-outputs`

### How to Add a New Freezed Model
1. Create `_model.dart` with `@freezed` annotation
2. Add `part '<file>_model.freezed.dart';` and `part '<file>_model.g.dart';`
3. Run: `dart run build_runner build --delete-conflicting-outputs`

### How to Handle Network Images
```dart
// Network image (preferred — auto-caches)
CachedNetworkImageWidget(
  imageUrl: '${ApiConstants.streamUrl}$photoPath'
)
```

### How to Show Loading/Error States
```dart
final state = ref.watch(featureNotifierProvider);

if (state.status == FeatureStatus.loading) return const ShimmerWidget();
if (state.status == FeatureStatus.error) {
  return Center(child: Text(state.errorMessage ?? 'Error'));
}
// loaded state — render data
```

### Dashboard: How to Make an API Call
```javascript
const response = await fetch(`${BASE_URL}endpoint`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${localStorage.getItem('accessToken')}`,
    'Accept-Language': localStorage.getItem('lang') || 'ar',
  },
  body: JSON.stringify({ key: value }),
});
const data = await response.json();
if (data.success) { /* use data.result */ }
```

---

*Last Updated: 2026-06-30 — Update this file whenever architecture changes.*
