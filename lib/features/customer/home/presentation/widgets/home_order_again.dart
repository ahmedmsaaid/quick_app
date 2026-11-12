import 'package:base_app/core/widgets/lading_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/see_all_widget.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/customer/orders/presentation/riverpod/orders_provider.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/customer/main_nav/presentation/riverpod/user_nav_provider.dart';

class HomeOrderAgain extends ConsumerStatefulWidget {
  const HomeOrderAgain({super.key});

  @override
  ConsumerState<HomeOrderAgain> createState() => _HomeOrderAgainState();
}

class _HomeOrderAgainState extends ConsumerState<HomeOrderAgain> {
  final Set<int> _loadingOrderIds = {};

  void _navigateToCompletedOrders() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    ref.read(ordersInitialTabProvider.notifier).state = 1;
    ref.read(userNavIndexProvider.notifier).state = 2;
    ref.read(ordersProvider.notifier).loadOrders();
  }

  String _getTimeAgo(String? createdOnStr) {
    if (createdOnStr == null || createdOnStr.isEmpty) return AppStrings.someTimeAgo;
    try {
      final createdOn = DateTime.parse(createdOnStr);
      final difference = DateTime.now().difference(createdOn);

      if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        if (m <= 1) return AppStrings.minuteAgo;
        if (m == 2) return AppStrings.twoMinutesAgo;
        return 'minutesAgo'.tr(args: [m.toString()]);
      } else if (difference.inHours < 24) {
        final h = difference.inHours;
        if (h <= 1) return AppStrings.hourAgo;
        if (h == 2) return AppStrings.twoHoursAgo;
        return 'hoursAgo'.tr(args: [h.toString()]);
      } else if (difference.inDays == 1) {
        return AppStrings.oneDayAgo;
      } else if (difference.inDays == 2) {
        return AppStrings.twoDaysAgo;
      } else if (difference.inDays < 7) {
        return 'daysAgo'.tr(args: [difference.inDays.toString()]);
      } else if (difference.inDays < 14) {
        return AppStrings.oneWeekAgo;
      } else if (difference.inDays < 30) {
        return 'weeksAgo'.tr(args: [(difference.inDays / 7).round().toString()]);
      } else {
        return AppStrings.moreThanAMonthAgo;
      }
    } catch (_) {
      return AppStrings.someTimeAgo;
    }
  }

  /// نفس منطق orders_screen — اسم المنتج الأول + صورته
  String _getOrderTitle(OrderDto order) {
    if (order.offerId != null) return '${AppStrings.specialOfferOrder} #${order.offerId}';
    if (order.products.isNotEmpty) {
      final firstProd = order.products.first;
      String title = firstProd.productName ?? '${AppStrings.order} #${order.id}';
      if (order.products.length > 1) {
        title += ' +${order.products.length - 1} ${AppStrings.otherProducts}';
      }
      return title;
    }
    return '${AppStrings.order} #${order.id}';
  }

  /// نفس منطق orders_screen — صورة المنتج الأول
  String _getOrderImageUrl(OrderDto order) {
    if (order.products.isEmpty) return '';
    final String? photo = order.products.first.photo;
    if (photo == null || photo.isEmpty) return '';
    return photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeRecentOrdersProvider.notifier).loadRecentOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final ordersState = ref.watch(homeRecentOrdersProvider);

    // نراقب الـ profile — لو الـ user اتحمّل والطلبات لسه فاضية نعيد التحميل
    ref.listen(profileProvider, (prev, next) {
      final wasNull = prev?.user == null;
      final isNowLoaded = next.user != null;
      final ordersNeedRetry = ordersState.status == OrdersStatus.error ||
          ordersState.status == OrdersStatus.initial;

      if (wasNull && isNowLoaded && ordersNeedRetry) {
        ref.read(homeRecentOrdersProvider.notifier).loadRecentOrders();
      }
    });

    // الطلبات السابقة ذات المنتجات التي يمكن إعادة طلبها (باستثناء الملغية أو المرفوضة)
    final pastOrders = ordersState.orders
        .where((o) => o.status != 8 && o.status != 9)
        .toList();
    final displayOrders = pastOrders.take(5).toList();

    // Loading state
    if (ordersState.status == OrdersStatus.loading && pastOrders.isEmpty) {
      return SizedBox(
        height: 175.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeeAllWidget(
              title: AppStrings.orderAgain,
              onTap: () {
                _navigateToCompletedOrders();
              },
            ),
            Expanded(
              child: Center(
                child: LoadingButton(
                   color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (pastOrders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeeAllWidget(
          title: AppStrings.orderAgain,
          onTap: () {
            _navigateToCompletedOrders();
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            height: 180.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: displayOrders.length,
              itemBuilder: (context, index) {
                final order = displayOrders[index];
                final String title = _getOrderTitle(order);
                final String imageUrl = _getOrderImageUrl(order);
                final bool isLoading = _loadingOrderIds.contains(order.id);

                return _buildOrderAgainCard(
                  context: context,
                  colors: colors,
                  title: title,
                  timeAgo: _getTimeAgo(order.createdOn),
                  imageUrl: imageUrl,
                  price: order.effectiveFinalPrice,
                  isLoading: isLoading,
                  onTap: () async {
                    if (isLoading) return;
                    setState(() => _loadingOrderIds.add(order.id));
                    final success =
                        await ref.read(ordersProvider.notifier).reorder(order);
                    if (!context.mounted) return;
                    setState(() => _loadingOrderIds.remove(order.id));
                    if (success) {
                      CustomToast.success(
                          context, AppStrings.reorderSuccessToast);
                      Navigator.of(context).pushNamed(AppRoutes.cartScreen);
                    } else {
                      final err = ref.read(ordersProvider).reorderError;
                      CustomToast.error(
                          context, err ?? AppStrings.reorderFailedToast);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderAgainCard({
    required BuildContext context,
    required AppColors colors,
    required String title,
    required String timeAgo,
    required String imageUrl,
    double? price,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLoading
              ? colors.primary.withValues(alpha: 0.5)
              : colors.border.withValues(alpha: 0.6),
          width: isLoading ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── صورة المنتج (مستطيل) ───
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: colors.shimmerBase),
                              errorWidget: (_, __, ___) => Container(
                                color: colors.background,
                                child: Icon(Icons.fastfood_rounded,
                                    color: colors.textHint, size: 28.sp),
                              ),
                            )
                          : Container(
                              color: colors.background,
                              child: Icon(Icons.fastfood_rounded,
                                  color: colors.textHint, size: 28.sp),
                            ),
                      if (isLoading)
                        Container(
                          color: Colors.black.withValues(alpha: 0.4),
                          child: const Center(
                            child: LoadingButton(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              6.verticalSpace,
              // ─── اسم المنتج ───
              Text(
                isLoading ? AppStrings.addingToCart : title,
                style: AppTextStyles.text11w700(
                  color: isLoading ? colors.primary : colors.textPrimary,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.verticalSpace,
              // ─── الوقت ───
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: colors.textHint,
                  fontFamily: 'Cairo',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              4.verticalSpace,
              // ─── السعر وزر إعادة الطلب ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (price != null && price > 0)
                    Flexible(
                      child: Text(
                        '${price.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: AppTextStyles.text11w700(
                          color: colors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 7.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_rounded,
                            color: Colors.white, size: 10.sp),
                        2.horizontalSpace,
                        Text(
                          AppStrings.order,
                          style: AppTextStyles.text10w700(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
