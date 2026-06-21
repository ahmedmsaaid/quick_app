import 'dart:async';
 import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/home/presentation/widgets/banner_item.dart';
import 'package:base_app/core/exports/exports.dart';

class HomeModernBanner extends ConsumerStatefulWidget {
  const HomeModernBanner({super.key});

  @override
  ConsumerState<HomeModernBanner> createState() => _HomeModernBannerState();
}

class _HomeModernBannerState extends ConsumerState<HomeModernBanner> {
  final PageController _bannerController = PageController(viewportFraction: 0.9);
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        final homeState = ref.read(homeProvider);
        final offersCount = homeState.offers.isNotEmpty ? homeState.offers.length : 3;
        final totalCount = offersCount + 3; // API offers + 3 mock campaigns
        int nextPage = (_currentBannerPage + 1) % totalCount;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final colors = AppColors(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // If loading and we have no offers, show loading spinner
    if (homeState.status == HomeStatus.loading && homeState.offers.isEmpty) {
      return SizedBox(
        height: 140.h,
        child: const Center(child: LoadingButton()),
      );
    }

    final List<BannerItem> bannerItems = [];

    // 1. Convert real offers from backend to BannerItems
    for (final offer in homeState.offers) {
      final String? featuredPhoto = offer.featuredPhoto;
      final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
          ? (featuredPhoto.startsWith('http')
              ? featuredPhoto
              : '${ApiConstants.streamUrl}$featuredPhoto')
          : '';

      bannerItems.add(BannerItem(
        title: offer.name ?? '',
        description: offer.description ?? '',
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        isAsset: false,
        badgeText: AppStrings.specialOffer,
        price: '${offer.price} ${AppStrings.currency}',
        onTap: () {
          context.pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
        },
        gradientColors: [
          const Color(0xFF004D40), // Premium Dark Teal gradient
          const Color(0xFF00796B),
        ],
      ));
    }

    // 2. Add beautiful mockup advertisements (promotional campaigns) using local assets
    // Campaign 1: Free delivery
    bannerItems.add(BannerItem(
      title: AppStrings.freeDeliveryTitle,
      description: AppStrings.freeDeliveryDesc,
      imageUrl: 'assets/image/Delivery-bro.png',
      isAsset: true,
      badgeText: AppStrings.limitedTimeText,
      onTap: () {
        context.pushNamed(
          AppRoutes.StoreScreen,
          arguments: AppStrings.restaurantsCategory,
        );
      },
      gradientColors: [
        const Color(0xFFE65100), // Rich speed orange gradient
        const Color(0xFFF57C00),
      ],
    ));

    // Campaign 2: Discount offer
    bannerItems.add(BannerItem(
      title: AppStrings.discount50Title,
      description: AppStrings.discount50Desc,
      imageUrl: 'assets/image/Delivery-amico.png',
      isAsset: true,
      badgeText: AppStrings.bestOfferText,
      onTap: () {
        context.pushNamed(
          AppRoutes.StoreScreen,
          arguments: AppStrings.restaurantsCategory,
        );
      },
      gradientColors: [
        const Color(0xFF0D47A1), // Deep premium royal blue
        const Color(0xFF1976D2),
      ],
    ));

    // Campaign 3: Time flies / Speed delivery
    bannerItems.add(BannerItem(
      title: AppStrings.arrivesFasterTitle,
      description: AppStrings.arrivesFasterDesc,
      imageUrl: 'assets/image/time flies-rafiki.png',
      isAsset: true,
      badgeText: AppStrings.fastDelivery,
      onTap: () {
        context.pushNamed(
          AppRoutes.StoreScreen,
          arguments: AppStrings.restaurantsCategory,
        );
      },
      gradientColors: [
        const Color(0xFF4A148C), // Vibrant speed purple
        const Color(0xFF7B1FA2),
      ],
    ));

    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemCount: bannerItems.length,
            itemBuilder: (context, index) {
              final item = bannerItems[index];
              return _buildBannerCard(context, item, colors, isArabic);
            },
          ),
        ),
        10.verticalSpace,
        Center(
          child: SmoothPageIndicator(
            controller: _bannerController,
            count: bannerItems.length,
            effect: ExpandingDotsEffect(
              activeDotColor: colors.secondary,
              dotColor: colors.border,
              dotHeight: 4.5.h,
              dotWidth: 4.5.w,
              expansionFactor: 3.5,
              spacing: 5.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(
      BuildContext context, BannerItem item, AppColors colors, bool isArabic) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: item.gradientColors.first.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Subtle background wave/patterns
              Positioned(
                right: -20.w,
                bottom: -20.h,
                child: Opacity(
                  opacity: 0.12,
                  child: Container(
                    width: 130.w,
                    height: 130.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -30.w,
                top: -30.h,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Main content layout
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Text details
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (item.badgeText != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                item.badgeText!,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          4.verticalSpace,
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          3.verticalSpace,
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          6.verticalSpace,
                          if (item.price != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: colors.secondary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                item.price!,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.orderNowText,
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                3.horizontalSpace,
                                Icon(
                                  isArabic
                                      ? Icons.arrow_back_ios_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 8.sp,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    8.horizontalSpace,

                    // Right illustration image
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 95.h,
                        alignment: Alignment.center,
                        child: item.imageUrl != null
                            ? (item.isAsset
                                ? Image.asset(
                                    item.imageUrl!,
                                    fit: BoxFit.contain,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: item.imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.fastfood_rounded,
                                      color: Colors.white30,
                                      size: 30.sp,
                                    ),
                                  ))
                            : Icon(
                                Icons.fastfood_rounded,
                                color: Colors.white30,
                                size: 36.sp,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
