import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        final offersCount = homeState.offers.length;
        if (offersCount <= 1) return;
        int nextPage = (_currentBannerPage + 1) % offersCount;
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

    // Convert real offers from backend to BannerItems
    for (final offer in homeState.offers) {
      final String? featuredPhoto = offer.featuredPhoto;
      final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
          ? (featuredPhoto.startsWith('http')
              ? featuredPhoto
              : '${ApiConstants.streamUrl}$featuredPhoto')
          : '';

      // Debug print
      print('🖼️ [BannerItem] featuredPhoto: $featuredPhoto | fullUrl: $imageUrl');

      final bool hasProducts = offer.products != null && offer.products!.isNotEmpty;

      bannerItems.add(BannerItem(
        title: offer.name ?? '',
        description: offer.description ?? '',
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        isAsset: false,
        badgeText: AppStrings.specialOffer,
        price: hasProducts ? '${offer.price} ${AppStrings.currency}' : null,
        onTap: hasProducts
            ? () {
                context.pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
              }
            : null,
        gradientColors: [
          const Color(0xFF004D40),
          const Color(0xFF00796B),
        ],
      ));
    }

    if (bannerItems.isEmpty) {
      return const SizedBox.shrink();
    }

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
        if (bannerItems.length > 1)
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.containerBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ? SizedBox.expand(
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: colors.shimmerBase,
                    child: const Center(child: LoadingButton(size: 20)),
                  ),
                  errorWidget: (_, url, error) {
                    print('❌ [BannerImage] FAILED to load: $url | error: $error');
                    return Center(
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: colors.primary,
                        size: 40.sp,
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: Icon(
                  Icons.local_offer_rounded,
                  color: colors.primary,
                  size: 40.sp,
                ),
              ),
      ),
    );
  }
}
