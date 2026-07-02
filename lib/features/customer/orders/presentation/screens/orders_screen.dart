import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/orders/presentation/riverpod/orders_provider.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final ordersState = ref.watch(ordersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          title: Text(
            AppStrings.myBookings,
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.textHint,
            indicatorColor: colors.primary,
            labelStyle: AppTextStyles.text14w600(),
            tabs: [
              Tab(text: AppStrings.currentOrders),
              Tab(text: AppStrings.completed),
            ],
          ),
        ),
        body: _buildBody(context, ref, ordersState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrdersState state) {
    if (state.status == OrdersStatus.loading) {
      return const Center(child: LoadingButton());
    }

    if (state.status == OrdersStatus.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.sp, color: AppColors(context).error),
              15.verticalSpace,
              Text(
                state.errorMessage ?? 'حدث خطأ أثناء تحميل الطلبات',
                style: AppTextStyles.text14w500(color: AppColors(context).textSecondary),
                textAlign: TextAlign.center,
              ),
              20.verticalSpace,
              ElevatedButton(
                onPressed: () {
                  ref.read(ordersProvider.notifier).loadOrders();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors(context).primary),
                child: Text('إعادة المحاولة', style: AppTextStyles.text14w600(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final allOrders = state.orders;

    // Filter current: status is less than 7 (Delivered) and not Cancelled/Rejected (8, 9)
    final currentOrders = allOrders.where((o) => o.status < 7).toList();
    // Filter completed/canceled: Delivered (7), Cancelled (8), Rejected (9)
    final pastOrders = allOrders.where((o) => o.status >= 7).toList();

    return TabBarView(
      children: [
        _buildOrdersList(context, currentOrders, isCurrent: true),
        _buildOrdersList(context, pastOrders, isCurrent: false),
      ],
    );
  }

  Widget _buildOrdersList(BuildContext context, List<OrderDto> orders, {required bool isCurrent}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 60.sp, color: AppColors(context).textHint),
            12.verticalSpace,
            Text(
              isCurrent ? 'لا توجد طلبات حالية حالياً' : 'لا توجد طلبات سابقة',
              style: AppTextStyles.text14w500(color: AppColors(context).textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: orders.length,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderDto order) {
    final colors = AppColors(context);

    // Dynamic Title & Image from products or offer
    String orderTitle = 'طلب جديد';
    String photoUrl = '';
    
    if (order.offerId != null) {
      orderTitle = 'طلب عرض خاص #${order.offerId}';
    } else if (order.products.isNotEmpty) {
      final firstProd = order.products.first;
      orderTitle = firstProd.productName ?? 'طلب جديد';
      if (order.products.length > 1) {
        orderTitle += ' و ${order.products.length - 1} منتجات أخرى';
      }
      final String? photo = firstProd.photo;
      photoUrl = (photo != null && photo.isNotEmpty)
          ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
          : '';
    }

    String dateStr = order.createdOn != null && order.createdOn!.isNotEmpty
        ? order.createdOn!.split('T').first
        : '';

    final isCurrent = order.status < 7;

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(width: 50.w, height: 50.h, color: colors.shimmerBase),
                        errorWidget: (_, __, ___) => Image.asset('assets/image/logo.png', width: 50.w, height: 50.h, fit: BoxFit.cover),
                      )
                    : Image.asset('assets/image/logo.png', width: 50.w, height: 50.h, fit: BoxFit.cover),
              ),
              15.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderTitle,
                      style: AppTextStyles.text14w600(color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    5.verticalSpace,
                    Text(
                      '${AppStrings.uniqueNumber}: #${order.id}',
                      style: AppTextStyles.text12w400(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status, colors).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: AppTextStyles.text10w500(
                    color: _getStatusColor(order.status, colors),
                  ),
                ),
              ),
            ],
          ),
          15.verticalSpace,
          Divider(color: colors.divider),
          15.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: AppTextStyles.text12w400(color: colors.textSecondary),
              ),
              Text(
                '${order.totalPrice.toStringAsFixed(0)} جنيه مصري',
                style: AppTextStyles.text14w700(color: colors.primary),
              ),
            ],
          ),
          if (isCurrent) ...[
            15.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.orderDetailsScreen,
                        arguments: order,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      AppStrings.trackOrderBtn,
                      style: AppTextStyles.text12w600(color: colors.primary),
                    ),
                  ),
                ),
                15.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.of(context).pushNamed(AppRoutes.chatDetailsScreen, arguments: AppStrings.technicalSupportTitle);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      AppStrings.helpBtn,
                      style: AppTextStyles.text12w600(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (order.status < 6) ...[
              10.verticalSpace,
              _CancelOrderCardButton(order: order),
            ],
          ] else ...[
            15.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.sendReview,
                          arguments: UserDto(
                            id: order.creatorId,
                            name: orderTitle,
                            role: 0,
                            status: 1,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text(AppStrings.rateOrderTitle, style: AppTextStyles.text12w600(color: colors.primary)),
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: _ReorderButton(order: order),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'قيد الانتظار';
      case 1:
        return 'في انتظار الدفع';
      case 2:
        return 'قيد التوصيل';
      case 3:
        return 'تم التأكيد';
      case 4:
        return 'جاري التحضير';
      case 5:
        return 'جاهز للاستلام';
      case 6:
        return 'في الطريق';
      case 7:
        return 'تم التوصيل';
      case 8:
        return 'ملغي';
      case 9:
        return 'مرفوض';
      default:
        return 'قيد المعالجة';
    }
  }

  Color _getStatusColor(int status, AppColors colors) {
    switch (status) {
      case 7:
        return colors.success;
      case 8:
      case 9:
        return colors.error;
      default:
        return colors.primary;
    }
  }
}

// ─── زر إعادة الطلب مع loading state مستقل لكل كارت ───
class _ReorderButton extends ConsumerStatefulWidget {
  final OrderDto order;
  const _ReorderButton({required this.order});

  @override
  ConsumerState<_ReorderButton> createState() => _ReorderButtonState();
}

class _ReorderButtonState extends ConsumerState<_ReorderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return ElevatedButton.icon(
      onPressed: _isLoading
          ? null
          : () async {
              setState(() => _isLoading = true);
              final success = await ref
                  .read(ordersProvider.notifier)
                  .reorder(widget.order);
              if (!context.mounted) return;
              setState(() => _isLoading = false);
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
      icon: _isLoading
          ? SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
      label: Text(
        AppStrings.reBooking,
        style: AppTextStyles.text12w600(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isLoading ? colors.primary.withValues(alpha: 0.6) : colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

// ─── زر إلغاء الطلب من داخل الكارت ───
class _CancelOrderCardButton extends ConsumerStatefulWidget {
  final OrderDto order;
  const _CancelOrderCardButton({required this.order});

  @override
  ConsumerState<_CancelOrderCardButton> createState() => _CancelOrderCardButtonState();
}

class _CancelOrderCardButtonState extends ConsumerState<_CancelOrderCardButton> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _cancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: _isCancelling
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(color: colors.error, strokeWidth: 2),
              )
            : Text(
                'إلغاء الطلب',
                style: AppTextStyles.text12w600(color: colors.error),
              ),
      ),
    );
  }

  Future<void> _cancel() async {
    final colors = AppColors(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إلغاء الطلب'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('نعم، إلغاء', style: TextStyle(color: colors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    final success = await ref.read(ordersProvider.notifier).cancelOrder(widget.order);
    if (mounted) setState(() => _isCancelling = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إلغاء الطلب، يرجى المحاولة لاحقاً')),
        );
      }
    }
  }
}

