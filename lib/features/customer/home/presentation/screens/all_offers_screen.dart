import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';

class AllOffersScreen extends ConsumerWidget {
  final String title;
  const AllOffersScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          title,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(homeProvider.notifier).refreshAllData();
        },
        child: _buildBody(context, colors, homeState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppColors colors, HomeState homeState) {
    if (homeState.status == HomeStatus.loading && homeState.offers.isEmpty) {
      return const Center(child: LoadingButton());
    }

    final offers = homeState.offers
        .where((o) => o.active == true && o.products != null && o.products!.isNotEmpty)
        .toList();

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64.sp, color: colors.textHint),
            16.verticalSpace,
            Text(
              'لا توجد عروض متاحة حالياً',
              style: AppTextStyles.text16w600(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final String? featuredPhoto = offer.featuredPhoto;
        final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
            ? (featuredPhoto.startsWith('http')
                ? featuredPhoto
                : '${ApiConstants.streamUrl}$featuredPhoto')
            : '';

        final isEditable = offer.offerType == 1;

        return _buildOfferGridCard(
          context: context,
          colors: colors,
          title: offer.name ?? '',
          subtitle: offer.description ?? (isEditable ? 'صمم عرضك المفضل الآن' : 'عرض مميز لفترة محدودة'),
          imageUrl: imageUrl,
          badgeText: isEditable ? 'قابل للتعديل 🛠️' : 'عرض خاص',
          badgeColor: isEditable ? colors.secondary : colors.primary,
          onTap: () {
            context.pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
          },
        );
      },
    );
  }

  Widget _buildOfferGridCard({
    required BuildContext context,
    required AppColors colors,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: colors.primary.withValues(alpha: 0.25), width: 1.2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: colors.shimmerBase),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.local_offer_rounded,
                                    color: colors.primary,
                                    size: 36.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.local_offer_rounded,
                                  color: colors.primary,
                                  size: 36.sp,
                                ),
                        ),
                      ),
                    ),
                    8.verticalSpace,
                    Text(
                      title,
                      style: AppTextStyles.text14w700(color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: colors.textHint,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Badge
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
