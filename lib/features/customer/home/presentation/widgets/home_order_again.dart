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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final ordersState = ref.watch(ordersProvider);

    // فلتر الأوردرات المكتملة أو المُسلّمة (status=3) لعرض "اطلب مرة أخرى"
    final completedOrders = ordersState.orders
        .where((o) => o.status == 3 && o.products.isNotEmpty)
        .toList();

    // إزالة التكرار — عرض أوردر واحد لكل متجر
    final List<OrderDto> uniqueVendorOrders = [];
    final Set<int> seenVendorIds = {};
    for (final order in completedOrders) {
      if (!seenVendorIds.contains(order.creatorId)) {
        seenVendorIds.add(order.creatorId);
        uniqueVendorOrders.add(order);
      }
    }

    if (uniqueVendorOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeeAllWidget(
          title: 'اطلب مرة أخرى',
          onTap: () {},
        ),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: uniqueVendorOrders.length,
            itemBuilder: (context, index) {
              final order = uniqueVendorOrders[index];
              final vendor = order.creator;
              final String? photoKey = vendor?.photo ?? vendor?.avatar;
              final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
                  ? (photoKey.startsWith('http')
                      ? photoKey
                      : '${ApiConstants.streamUrl}$photoKey')
                  : '';
              final bool isLoading = _loadingOrderIds.contains(order.id);

              return _buildOrderAgainCard(
                context: context,
                colors: colors,
                title: vendor?.name ?? 'متجر',
                timeAgo: _getTimeAgo(order.createdOn),
                imageUrl: photoUrl,
                isAsset: false,
                isLoading: isLoading,
                onTap: () async {
                  if (isLoading) return;
                  setState(() => _loadingOrderIds.add(order.id));
                  final success = await ref
                      .read(ordersProvider.notifier)
                      .reorder(order);
                  if (!context.mounted) return;
                  setState(() => _loadingOrderIds.remove(order.id));
                  if (success) {
                    CustomToast.success(context, 'تم إضافة المنتجات إلى السلة! 🛒');
                    Navigator.of(context).pushNamed(AppRoutes.cartScreen);
                  } else {
                    final err = ref.read(ordersProvider).reorderError;
                    CustomToast.error(
                      context,
                      err ?? 'فشل إضافة المنتجات، حاول مرة أخرى',
                    );
                  }
                },
              );
            },
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
    required bool isAsset,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: 110.w,
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vendor Logo Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.background,
                      border: Border.all(
                        color: isLoading ? colors.primary : colors.border,
                        width: isLoading ? 2 : 1,
                      ),
                    ),
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? (isAsset
                              ? Image.asset(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: colors.shimmerBase,
                                  ),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.storefront_rounded,
                                    color: colors.textHint,
                                    size: 24.sp,
                                  ),
                                ))
                          : Icon(
                              Icons.storefront_rounded,
                              color: colors.textHint,
                              size: 24.sp,
                            ),
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: 54.w,
                      height: 54.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.primary,
                      ),
                    ),
                ],
              ),
              8.verticalSpace,
              // Vendor Name
              Text(
                title,
                style: AppTextStyles.text11w700(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.verticalSpace,
              // Time Elapsed
              Text(
                isLoading ? 'جاري الطلب...' : timeAgo,
                style: TextStyle(
                  fontSize: 8.sp,
                  color: isLoading ? colors.primary : colors.textHint,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
