import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/orders/presentation/riverpod/orders_provider.dart';
import 'package:base_app/features/shared/chats/presentation/screens/app_chat_screen.dart';
import 'package:base_app/features/shared/chats/data/enums/role_type_enum.dart';

// ─── Order Status Constants ─────────────────────────────────────────────────
// 0 = Created
// 1 = PendingForPayment
// 2 = PendingForDelivery
// 3 = Confirmed
// 4 = Preparing
// 5 = ReadyForPickup
// 6 = OutForDelivery
// 7 = Delivered
// 8 = Cancelled
// 9 = Rejected

class OrderTrackingScreen extends ConsumerWidget {
  final OrderDto? order;

  const OrderTrackingScreen({super.key, this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final initialOrder = order;

    if (initialOrder == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          leading: const CustomArrowBack(),
          title: Text(
            AppStrings.trackOrderBtn,
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          backgroundColor: colors.surface,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 60.sp,
                color: colors.textHint,
              ),
              16.verticalSpace,
              Text(
                'لا توجد بيانات للطلب',
                style: AppTextStyles.text14w500(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Watch the trackOrderProvider to keep getting the updated order data
    final trackingAsync = ref.watch(trackOrderProvider(initialOrder.id));
    final o = trackingAsync.value ?? initialOrder;

    final isCancelled = o.status == 8 || o.status == 9;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // ── Map placeholder bg ────────────────────────────────────────────
          Container(
            color: colors.containerBackground,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 90.sp,
                    color: colors.textHint.withValues(alpha: 0.4),
                  ),
                  8.verticalSpace,
                  Text(
                    AppStrings.orderTrackingMapPlaceholder,
                    style: AppTextStyles.text12w400(
                      color: colors.textHint.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Back button ───────────────────────────────────────────────────
          Positioned(top: 50.h, right: 20.w, child: const CustomArrowBack()),

          // ── Order ID badge ────────────────────────────────────────────────
          Positioned(
            top: 50.h,
            left: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8)],
              ),
              child: Text(
                '#${o.id}',
                style: AppTextStyles.text14w700(color: colors.primary),
              ),
            ),
          ),

          // ── Bottom sheet ──────────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 30.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  16.verticalSpace,

                  // ── Header: ETA or cancelled/rejected ─────────────────────
                  if (isCancelled)
                    _CancelledBanner(status: o.status, colors: colors)
                  else
                    _EtaHeader(order: o, colors: colors),

                  20.verticalSpace,

                  // ── Tracking Steps ────────────────────────────────────────
                  _TrackingSteps(status: o.status, colors: colors),

                  20.verticalSpace,
                  Divider(color: colors.divider),
                  16.verticalSpace,

                  // ── Vendor & products info ────────────────────────────────
                  _VendorRow(order: o, colors: colors, context: context),
                  _DriverRow(order: o, colors: colors),
                  if (o.status < 6) ...[
                    16.verticalSpace,
                    _CancelOrderButton(order: o, colors: colors),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cancelled/Rejected Banner ────────────────────────────────────────────────
class _CancelledBanner extends StatelessWidget {
  final int status;
  final AppColors colors;
  const _CancelledBanner({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isRejected = status == 9;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, color: colors.error, size: 22.sp),
          10.horizontalSpace,
          Text(
            isRejected
                ? 'تم رفض هذا الطلب من قبل المتجر'
                : 'تم إلغاء هذا الطلب',
            style: AppTextStyles.text14w700(color: colors.error),
          ),
        ],
      ),
    );
  }
}

// ─── ETA Header ──────────────────────────────────────────────────────────────
class _EtaHeader extends StatelessWidget {
  final OrderDto order;
  final AppColors colors;
  const _EtaHeader({required this.order, required this.colors});

  String get _statusLabel {
    switch (order.status) {
      case 0:
        return 'تم إنشاء الطلبية، في انتظار قبول المتجر';
      case 1:
        return 'في انتظار إتمام الدفع';
      case 2:
        return 'قبل المتجر طلبك، في انتظار تعيين سائق توصيل';
      case 3:
        return 'تم تأكيد الطلب من الدليفري، يبدأ المتجر التحضير الآن';
      case 4:
        return 'جاري تحضير الطلب الآن 👨‍🍳';
      case 5:
        return 'الطلب جاهز وبانتظار استلام السائق';
      case 6:
        return 'السائق في الطريق إليك بالطلب 🚗';
      case 7:
        return 'تم توصيل الطلب بنجاح! 🎉';
      default:
        return 'جاري المعالجة...';
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case 0:
        return Icons.create_new_folder_rounded;
      case 1:
        return Icons.payment_rounded;
      case 2:
        return Icons.person_search_rounded;
      case 3:
        return Icons.assignment_turned_in_rounded;
      case 4:
        return Icons.restaurant_rounded;
      case 5:
        return Icons.shopping_bag_rounded;
      case 6:
        return Icons.delivery_dining_rounded;
      case 7:
        return Icons.check_circle_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _statusColor(AppColors c) {
    switch (order.status) {
      case 7:
        return c.success;
      default:
        return c.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clr = _statusColor(colors);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: clr.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_statusIcon, color: clr, size: 28.sp),
        ),
        15.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.orderWillArriveMsg,
                style: AppTextStyles.text12w400(color: colors.textSecondary),
              ),
              4.verticalSpace,
              Text(
                _statusLabel,
                style: AppTextStyles.text15w700(color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tracking Steps ───────────────────────────────────────────────────────────
class _TrackingSteps extends StatelessWidget {
  final int status;
  final AppColors colors;
  const _TrackingSteps({required this.status, required this.colors});

  // Steps representation matching the real order flow:
  // 1. الطلب مقبول من المتجر + الدليفري (status 0-3)
  // 2. التحضير (status 3-5)
  // 3. السائق في الطريق (status 5-7)
  // 4. تم التوصيل (status 7)
  static const _steps = [
    (icon: Icons.check_circle_outline_rounded, label: 'تم قبول الطلب'),
    (icon: Icons.restaurant_rounded, label: 'جاري تحضير الطلب'),
    (icon: Icons.delivery_dining_rounded, label: 'السائق في الطريق'),
    (icon: Icons.home_rounded, label: 'تم التوصيل'),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine how many steps are completed:
    int completedCount = 0;
    int currentStep = -1;

    if (status == 8 || status == 9) {
      // Cancelled or Rejected: no active step
      completedCount = 0;
      currentStep = -1;
    } else if (status < 2) {
      // status 0 (Created) or 1 (PendingForPayment): waiting for restaurant to accept
      completedCount = 0;
      currentStep = 0; // step 1 pulsing
    } else if (status == 2) {
      // PendingForDelivery: restaurant accepted, waiting for captain
      completedCount = 0;
      currentStep = 0; // step 1 still pulsing (not yet confirmed by captain)
    } else if (status == 3) {
      // Confirmed by captain: step 1 done, step 2 starting
      completedCount = 1;
      currentStep = 1; // step 2 (تحضير) pulsing
    } else if (status == 4) {
      // Preparing
      completedCount = 1;
      currentStep = 1; // step 2 (تحضير) pulsing
    } else if (status == 5) {
      // ReadyForPickup: prep done, waiting for driver pickup
      completedCount = 2;
      currentStep = -1; // step 2 done, step 3 not yet started
    } else if (status == 6) {
      // OutForDelivery: driver is on the way
      completedCount = 2;
      currentStep = 2; // step 3 (السائق في الطريق) pulsing
    } else if (status == 7) {
      // Delivered: all done
      completedCount = 4;
      currentStep = -1;
    }

    return Column(
      children: List.generate(_steps.length, (i) {
        final isCompleted = i < completedCount;
        final isCurrent = i == currentStep;
        final isLast = i == _steps.length - 1;

        return _StepRow(
          icon: _steps[i].icon,
          label: _steps[i].label,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          isLast: isLast,
          colors: colors,
        );
      }),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final AppColors colors;

  const _StepRow({
    required this.icon,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isCompleted ? colors.primary : colors.divider;
    final Color lineColor = isCompleted && !isCurrent
        ? colors.primary
        : colors.divider;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Timeline column ──────────────────────────────────────────────
        SizedBox(
          width: 28.w,
          child: Column(
            children: [
              // animated dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 22.w : 16.w,
                height: isCurrent ? 22.w : 16.w,
                decoration: BoxDecoration(
                  color: isCurrent ? colors.primary : dotColor,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: isCurrent ? 12.sp : 10.sp,
                        color: Colors.white,
                      )
                    : null,
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 2.5.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
            ],
          ),
        ),
        12.horizontalSpace,
        // ── Label ────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(top: 1.h, bottom: isLast ? 0 : 20.h),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isCompleted ? colors.primary : colors.textDisabled,
              ),
              8.horizontalSpace,
              Text(
                label,
                style: AppTextStyles.text13w600(
                  color: isCurrent
                      ? colors.primary
                      : (isCompleted
                            ? colors.textPrimary
                            : colors.textDisabled),
                ),
              ),
              if (isCurrent) ...[
                6.horizontalSpace,
                _PulsingDot(color: colors.primary),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Pulsing dot animation ────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

// ─── Vendor Row ───────────────────────────────────────────────────────────────
class _VendorRow extends StatelessWidget {
  final OrderDto order;
  final AppColors colors;
  final BuildContext context;

  const _VendorRow({
    required this.order,
    required this.colors,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final vendor = order.creator;
    final String? photoKey = vendor?.photo ?? vendor?.avatar;
    final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
        ? (photoKey.startsWith('http')
              ? photoKey
              : '${ApiConstants.streamUrl}$photoKey')
        : '';

    // Build product summary line
    String productSummary = '';
    if (order.products.isNotEmpty) {
      productSummary = order.products
          .map((p) => '${p.productName ?? ''} ×${p.quantity}')
          .join('  •  ');
    } else if (order.offerId != null) {
      productSummary = 'عرض خاص #${order.offerId}';
    }

    return Column(
      children: [
        Row(
          children: [
            // Vendor avatar
            ClipOval(
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48.w,
                        height: 48.w,
                        color: colors.shimmerBase,
                      ),
                      errorWidget: (_, __, ___) => _fallbackAvatar(),
                    )
                  : _fallbackAvatar(),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor?.name ?? 'المتجر',
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  4.verticalSpace,
                  Text(
                    '${order.totalPrice.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: AppTextStyles.text13w600(color: colors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (productSummary.isNotEmpty) ...[
          12.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.containerBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              productSummary,
              style: AppTextStyles.text11w400(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 48.w,
      height: 48.w,
      color: colors.shimmerBase,
      child: Icon(
        Icons.storefront_rounded,
        color: colors.textHint,
        size: 22.sp,
      ),
    );
  }
}

// ─── Driver Row ───────────────────────────────────────────────────────────────
class _DriverRow extends StatelessWidget {
  final OrderDto order;
  final AppColors colors;

  const _DriverRow({
    required this.order,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final driver = order.updator;
    if (driver == null) return const SizedBox.shrink();

    final String? photoKey = driver.photo ?? driver.avatar;
    final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
        ? (photoKey.startsWith('http')
            ? photoKey
            : '${ApiConstants.streamUrl}$photoKey')
        : '';

    return Column(
      children: [
        16.verticalSpace,
        Divider(color: colors.divider),
        16.verticalSpace,
        Row(
          children: [
            ClipOval(
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48.w,
                        height: 48.w,
                        color: colors.shimmerBase,
                      ),
                      errorWidget: (_, __, ___) => _fallbackAvatar(),
                    )
                  : _fallbackAvatar(),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver.name ?? 'السائق',
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  4.verticalSpace,
                  Text(
                    'كابتن التوصيل',
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            // Chat with Captain
            _ActionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              color: colors.primary,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.chatDetailsScreen,
                arguments: AppChatArgument(
                  chatId: null,
                  recipientId: order.updatorId!,
                  profileId: 0,
                  typeEnum: RoleTypeEnum.captain,
                  recipientName: driver.name ?? 'السائق',
                  recipientImage: photoUrl,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 48.w,
      height: 48.w,
      color: colors.shimmerBase,
      child: Icon(
        Icons.delivery_dining_rounded,
        color: colors.textHint,
        size: 22.sp,
      ),
    );
  }
}

// ─── Small action button ──────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}

// ─── Cancel Order Button Widget ───────────────────────────────────────────────
class _CancelOrderButton extends ConsumerStatefulWidget {
  final OrderDto order;
  final AppColors colors;
  const _CancelOrderButton({required this.order, required this.colors});

  @override
  ConsumerState<_CancelOrderButton> createState() => _CancelOrderButtonState();
}

class _CancelOrderButtonState extends ConsumerState<_CancelOrderButton> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _cancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: widget.colors.error,
          side: BorderSide(color: widget.colors.error.withValues(alpha: 0.5)),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: _isCancelling
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(color: widget.colors.error, strokeWidth: 2),
              )
            : Text(
                'إلغاء الطلب',
                style: AppTextStyles.text14w700(color: widget.colors.error),
              ),
      ),
    );
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إلغاء الطلب'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('تراجع', style: TextStyle(color: widget.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('نعم، إلغاء', style: TextStyle(color: widget.colors.error, fontWeight: FontWeight.bold)),
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

