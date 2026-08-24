import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/format_price.dart';
import 'package:base_app/core/widgets/lading_button.dart';
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
import 'package:base_app/core/constans/role_type_enum.dart';
import 'package:base_app/core/models/app_chat_argument.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import 'package:base_app/core/services/maps_service.dart';

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
          // ── Live gRPC Order Tracking Map ────────────────────────────────
          Positioned.fill(
            child: _LiveOrderTrackingMap(order: o, colors: colors),
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
                  if (o.status == 0) ...[
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
    final String storeName = order.user?.name ?? order.userLocation?.name ?? 'المتجر';
    final String? rawPhoto = order.user?.photo ?? order.user?.avatar;
    final String photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
        ? (rawPhoto.startsWith('http')
            ? rawPhoto
            : '${ApiConstants.streamUrl}$rawPhoto')
        : '';

    // Build product summary line
    String productSummary = '';
    if (order.products.isNotEmpty) {
      productSummary = order.products
          .map((p) => '${p.productName ?? ''} ×${p.quantity}')
          .join('  •  ');
    } else if (order.offerId != null) {
      productSummary = 'طلب عرض خاص';
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
                    storeName,
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  4.verticalSpace,
                  Text(
                    '${formatPrice(order.totalPrice)} ${AppStrings.currency}',
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
    final driver = order.delivery;
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
            // Chat & Call Captain
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (driver.phone != null && driver.phone!.isNotEmpty)
                  _ActionBtn(
                    icon: Icons.call_rounded,
                    color: colors.success,
                    onTap: () => _launchCall(context, driver.phone!),
                  ),
                if (driver.phone != null && driver.phone!.isNotEmpty)
                  6.horizontalSpace,
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: colors.primary,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.chatDetailsScreen,
                    arguments: AppChatArgument(
                      chatId: null,
                      recipientId: order.deliveryId!,
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

// ─── Launch phone call ───────────────────────────────────────────────────────
Future<void> _launchCall(BuildContext context, String phone) async {
  final Uri uri = Uri(scheme: 'tel', path: phone);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن الاتصال بالرقم $phone')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء الاتصال: $e')),
      );
    }
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
                child: LoadingButton(color: widget.colors.error,  ),
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

// ─── Live gRPC Order Tracking Map Widget ──────────────────────────────────────
class _LiveOrderTrackingMap extends ConsumerStatefulWidget {
  final OrderDto order;
  final AppColors colors;
  const _LiveOrderTrackingMap({required this.order, required this.colors});

  @override
  ConsumerState<_LiveOrderTrackingMap> createState() => _LiveOrderTrackingMapState();
}

class _LiveOrderTrackingMapState extends ConsumerState<_LiveOrderTrackingMap> {
  final MapController _mapController = MapController();
  RouteResult? _roadRouteResult;
  bool _isAutoCentering = true;

  // Track previous captain position to detect real movement
  double? _prevCaptainLat;
  double? _prevCaptainLng;

  @override
  void initState() {
    super.initState();
    _fetchRoadRoute(widget.order);
  }

  void _onOrderUpdate(OrderDto o) {
    final capLat = o.delivery?.location?.latitude;
    final capLng = o.delivery?.location?.longitude;

    // Detect meaningful captain movement (> ~20 meters)
    final captainMoved = capLat != null &&
        capLng != null &&
        capLat != 0 &&
        capLng != 0 &&
        (_prevCaptainLat == null ||
            (capLat - (_prevCaptainLat ?? 0)).abs() > 0.0002 ||
            (capLng - (_prevCaptainLng ?? 0)).abs() > 0.0002);

    if (captainMoved) {
      _prevCaptainLat = capLat;
      _prevCaptainLng = capLng;

      // Auto-follow captain when active
      if (_isAutoCentering) {
        _mapController.move(
          ll.LatLng(capLat, capLng),
          _mapController.camera.zoom > 10 ? _mapController.camera.zoom : 15.5,
        );
      }

      // Invalidate route cache and re-fetch
      MapService.invalidateRouteCache(ll.LatLng(capLat, capLng));
      _fetchRoadRoute(o);
    }
  }

  Future<void> _fetchRoadRoute(OrderDto o) async {
    final destLat = o.latitude;
    final destLng = o.longitude;

    final storeLat = o.creator?.location?.latitude;
    final storeLng = o.creator?.location?.longitude;

    final captainLat = o.delivery?.location?.latitude;
    final captainLng = o.delivery?.location?.longitude;

    final startLat = (o.status == 6 && captainLat != null && captainLat != 0) ? captainLat : storeLat;
    final startLng = (o.status == 6 && captainLng != null && captainLng != 0) ? captainLng : storeLng;

    if (destLat != 0 && destLng != 0 && startLat != null && startLng != null && startLat != 0 && startLng != 0) {
      if ((startLat - destLat).abs() < 0.0001 && (startLng - destLng).abs() < 0.0001) {
        return;
      }
      final route = await MapService.getDrivingRoute(
        ll.LatLng(startLat, startLng),
        ll.LatLng(destLat, destLng),
      );
      if (mounted) {
        setState(() {
          _roadRouteResult = route;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch live updates directly from gRPC stream
    final liveOrderAsync = ref.watch(trackOrderProvider(widget.order.id));
    final o = liveOrderAsync.value ?? widget.order;

    // Trigger captain-movement side effects after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final liveVal = liveOrderAsync.value;
      if (liveVal != null) _onOrderUpdate(liveVal);
    });
    final destLat = o.latitude;
    final destLng = o.longitude;

    final storeLat = o.creator?.location?.latitude;
    final storeLng = o.creator?.location?.longitude;

    final captainLat = o.delivery?.location?.latitude;
    final captainLng = o.delivery?.location?.longitude;

    final hasDest = destLat != 0 && destLng != 0;
    final hasStore = storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0;
    final hasCaptain = captainLat != null && captainLng != null && captainLat != 0 && captainLng != 0;

    final centerLat = hasDest ? destLat : (hasStore ? storeLat : 30.0444);
    final centerLng = hasDest ? destLng : (hasStore ? storeLng : 31.2357);

    final markers = <Marker>[];
    final polylines = <Polyline>[];

    // Real OSRM Road Polyline
    final routePoints = _roadRouteResult?.points ?? [];
    if (routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: routePoints,
          strokeWidth: 5.5,
          color: widget.colors.primary,
          borderStrokeWidth: 2.0,
          borderColor: const Color(0xFF0F172A),
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round,
        ),
      );
    }

    // Store marker
    if (hasStore) {
      markers.add(
        Marker(
          point: ll.LatLng(storeLat, storeLng),
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: widget.colors.shadow, blurRadius: 6)],
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
          ),
        ),
      );
    }

    // Customer destination marker
    if (hasDest) {
      markers.add(
        Marker(
          point: ll.LatLng(destLat, destLng),
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: BoxDecoration(
              color: widget.colors.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: widget.colors.shadow, blurRadius: 6)],
            ),
            child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    // Live Captain / Driver Marker (when out for delivery)
    if (o.status == 6 && (hasCaptain || hasDest)) {
      final capPoint = hasCaptain ? ll.LatLng(captainLat, captainLng) : ll.LatLng(destLat, destLng);
      markers.add(
        Marker(
          point: capPoint,
          width: 48.w,
          height: 48.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.colors.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 26),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: ll.LatLng(centerLat, centerLng),
            initialZoom: 14.5,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && _isAutoCentering) {
                setState(() {
                  _isAutoCentering = false;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
              userAgentPackageName: 'com.quick.app',
            ),
            if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),

        // Live Route ETA & Distance Banner (أعلى الخريطة)
        if (_roadRouteResult != null && _roadRouteResult!.distanceMeters > 0)
          Positioned(
            top: 105.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: widget.colors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: widget.colors.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.shadow.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9.r),
                    decoration: BoxDecoration(
                      color: widget.colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delivery_dining_rounded,
                      color: widget.colors.primary,
                      size: 24.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          o.status == 6 ? "السائق في الطريق إليك الآن 🚗" : "المسافة والوقت المقدر للوصول 🛣️",
                          style: AppTextStyles.text12w600(color: widget.colors.textSecondary),
                        ),
                        3.verticalSpace,
                        Text(
                          "${_roadRouteResult!.formattedDistance} • ${_roadRouteResult!.formattedDuration}",
                          style: AppTextStyles.text15w700(color: widget.colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Floating Uber-Style Controls Panel (Zoom In +, Zoom Out -, Recenter 🎯)
        Positioned(
          bottom: 240.h,
          left: 20.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom Controls Pill
              Container(
                decoration: BoxDecoration(
                  color: widget.colors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: widget.colors.border.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: widget.colors.shadow.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zoom In (+)
                    InkWell(
                      onTap: () {
                        final newZoom = (_mapController.camera.zoom + 0.8).clamp(1.0, 19.0);
                        _mapController.move(_mapController.camera.center, newZoom);
                      },
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Icon(
                          Icons.add_rounded,
                          color: widget.colors.textPrimary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 28.w,
                      color: widget.colors.border.withValues(alpha: 0.6),
                    ),
                    // Zoom Out (-)
                    InkWell(
                      onTap: () {
                        final newZoom = (_mapController.camera.zoom - 0.8).clamp(1.0, 19.0);
                        _mapController.move(_mapController.camera.center, newZoom);
                      },
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Icon(
                          Icons.remove_rounded,
                          color: widget.colors.textPrimary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.verticalSpace,

              // Recenter FAB Button (🎯)
              Material(
                color: _isAutoCentering ? widget.colors.primary : widget.colors.surface,
                elevation: 6,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    setState(() => _isAutoCentering = true);
                    final capLat = o.delivery?.location?.latitude;
                    final capLng = o.delivery?.location?.longitude;
                    // Recenter → captain if out for delivery, else customer destination
                    final hasCap = capLat != null && capLng != null && capLat != 0 && capLng != 0;
                    final targetLat = (o.status == 6 && hasCap) ? capLat! : centerLat;
                    final targetLng = (o.status == 6 && hasCap) ? capLng! : centerLng;
                    _mapController.move(ll.LatLng(targetLat, targetLng), 15.5);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAutoCentering ? widget.colors.primary : widget.colors.surface,
                      border: Border.all(
                        color: _isAutoCentering ? widget.colors.primary : widget.colors.border.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.colors.shadow.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: _isAutoCentering ? Colors.white : widget.colors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


