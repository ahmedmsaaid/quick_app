import 'package:base_app/core/widgets/lading_button.dart';
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

class HomeOrderAgain extends ConsumerStatefulWidget {
  const HomeOrderAgain({super.key});

  @override
  ConsumerState<HomeOrderAgain> createState() => _HomeOrderAgainState();
}

class _HomeOrderAgainState extends ConsumerState<HomeOrderAgain> {
  final Set<int> _loadingOrderIds = {};

  String _getTimeAgo(String? createdOnStr) {
    if (createdOnStr == null || createdOnStr.isEmpty) return 'منذ فترة';
    try {
      final createdOn = DateTime.parse(createdOnStr);
      final difference = DateTime.now().difference(createdOn);

      if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        if (m <= 1) return 'منذ دقيقة';
        if (m == 2) return 'منذ دقيقتين';
        return 'منذ $m دقيقة';
      } else if (difference.inHours < 24) {
        final h = difference.inHours;
        if (h <= 1) return 'منذ ساعة';
        if (h == 2) return 'منذ ساعتين';
        return 'منذ $h ساعة';
      } else if (difference.inDays == 1) {
        return 'منذ يوم';
      } else if (difference.inDays == 2) {
        return 'منذ يومين';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else if (difference.inDays < 14) {
        return 'منذ أسبوع';
      } else if (difference.inDays < 30) {
        return 'منذ ${(difference.inDays / 7).round()} أسابيع';
      } else {
        return 'منذ أكثر من شهر';
      }
    } catch (_) {
      return 'منذ فترة';
    }
  }

  /// نفس منطق orders_screen — اسم المنتج الأول + صورته
  String _getOrderTitle(OrderDto order) {
    if (order.offerId != null) return 'طلب عرض خاص #${order.offerId}';
    if (order.products.isEmpty) return 'طلب جديد';
    final firstProd = order.products.first;
    String title = firstProd.productName ?? 'طلب جديد';
    if (order.products.length > 1) {
      title += ' و ${order.products.length - 1} منتجات أخرى';
    }
    return title;
  }

  /// نفس منطق orders_screen — صورة المنتج الأول
  String _getOrderImageUrl(OrderDto order) {
    if (order.products.isEmpty) return '';
    final String? photo = order.products.first.photo;
    if (photo == null || photo.isEmpty) return '';
    return photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final ordersState = ref.watch(ordersProvider);

    // نراقب الـ profile — لو الـ user اتحمّل والطلبات لسه فاضية نعيد التحميل
    ref.listen(profileProvider, (prev, next) {
      final wasNull = prev?.user == null;
      final isNowLoaded = next.user != null;
      final ordersNeedRetry = ordersState.status == OrdersStatus.error ||
          ordersState.status == OrdersStatus.initial;

      if (wasNull && isNowLoaded && ordersNeedRetry) {
        ref.read(ordersProvider.notifier).loadOrders();
      }
    });

    // فقط الطلبات المسلّمة Delivered = 7 اللي تستحق "اطلب مرة أخرى"
    // Cancelled = 8 و Rejected = 9 لا يظهران هنا
    final pastOrders = ordersState.orders
        .where((o) => o.status == 7 && o.products.isNotEmpty)
        .toList();

    // Loading state
    if (ordersState.status == OrdersStatus.loading && pastOrders.isEmpty) {
      return SizedBox(
        height: 175.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeeAllWidget(title: 'اطلب مرة أخرى', onTap: () {}),
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
          title: 'اطلب مرة أخرى',
          onTap: () {},
        ),
        Padding(
          padding:   EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            height: 155.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: pastOrders.length,
              itemBuilder: (context, index) {
                final order = pastOrders[index];
                final String title = _getOrderTitle(order);
                final String imageUrl = _getOrderImageUrl(order);
                final bool isLoading = _loadingOrderIds.contains(order.id);

                return _buildOrderAgainCard(
                  context: context,
                  colors: colors,
                  title: title,
                  timeAgo: _getTimeAgo(order.createdOn),
                  imageUrl: imageUrl,
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
                          context, 'تم إضافة المنتجات إلى السلة! 🛒');
                      Navigator.of(context).pushNamed(AppRoutes.cartScreen);
                    } else {
                      final err = ref.read(ordersProvider).reorderError;
                      CustomToast.error(
                          context, err ?? 'فشل إضافة المنتجات، حاول مرة أخرى');
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
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: 130.w,
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLoading
              ? colors.primary.withValues(alpha: 0.5)
              : colors.border.withValues(alpha: 0.5),
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
              // ─── صورة المنتج (مستطيل) — نفس نهج orders_screen ───
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
                          child: Center(
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
                isLoading ? 'جاري الطلب...' : title,
                style: AppTextStyles.text11w700(
                  color: isLoading ? colors.primary : colors.textPrimary,
                ),
                maxLines: 2,
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
            ],
          ),
        ),
      ),
    );
  }
}
