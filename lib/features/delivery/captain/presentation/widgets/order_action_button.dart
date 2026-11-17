import 'package:base_app/core/widgets/lading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class OrderActionButton extends StatefulWidget {
  final int orderState; // 0: قبول الطلب, 1: استلام الطلب, 2: تم التوصيل
  final bool isLoading;
  final VoidCallback? onPressed;
  final double? distanceToCustomerMeters;

  const OrderActionButton({
    super.key,
    required this.orderState,
    required this.isLoading,
    this.onPressed,
    this.distanceToCustomerMeters,
  });

  static final List<String> _buttonTexts = [
    "قبول الطلب",
    "اسحب لاستلام الطلب",
    "تم التوصيل",
  ];

  @override
  State<OrderActionButton> createState() => _OrderActionButtonState();
}

class _OrderActionButtonState extends State<OrderActionButton> {
  double _dragProgress = 0.0;
  bool _hasTriggered = false;

  @override
  void didUpdateWidget(covariant OrderActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderState != widget.orderState ||
        (oldWidget.isLoading && !widget.isLoading)) {
      _dragProgress = 0.0;
      _hasTriggered = false;
    }
  }

  Widget _buildSlideToPickupButton(BuildContext context, AppColors colors) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: 56.h,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final thumbSize = 46.h;
          final padding = 5.w;
          final maxDrag = (trackWidth - thumbSize - (padding * 2)).clamp(1.0, double.infinity);
          final currentOffset = _dragProgress * maxDrag;

          return Container(
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: widget.isLoading
                ? Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      alignment: Alignment.center,
                      child: const LoadingButton(color: Colors.white),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress fill
                      Align(
                        alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: (thumbSize + (padding * 2) + currentOffset)
                              .clamp(0.0, trackWidth),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(
                              alpha: (0.2 + (_dragProgress * 0.8)).clamp(0.2, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      // Label text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            OrderActionButton._buttonTexts[1],
                            style: AppTextStyles.text15w700(
                              color: _dragProgress > 0.45
                                  ? Colors.white
                                  : colors.primary,
                            ),
                          ),
                          6.horizontalSpace,
                          Icon(
                            isRtl
                                ? Icons.keyboard_double_arrow_left_rounded
                                : Icons.keyboard_double_arrow_right_rounded,
                            color: _dragProgress > 0.45
                                ? Colors.white
                                : colors.primary,
                            size: 20.sp,
                          ),
                        ],
                      ),
                      // Draggable thumb
                      Positioned(
                        right: isRtl ? padding + currentOffset : null,
                        left: isRtl ? null : padding + currentOffset,
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            if (widget.isLoading || _hasTriggered) return;
                            final delta = isRtl ? -details.delta.dx : details.delta.dx;
                            setState(() {
                              _dragProgress =
                                  (_dragProgress + (delta / maxDrag)).clamp(0.0, 1.0);
                            });
                            if (_dragProgress >= 0.82 && !_hasTriggered) {
                              _hasTriggered = true;
                              setState(() => _dragProgress = 1.0);
                              widget.onPressed?.call();
                            }
                          },
                          onHorizontalDragEnd: (_) {
                            if (!_hasTriggered && mounted) {
                              setState(() => _dragProgress = 0.0);
                            }
                          },
                          onHorizontalDragCancel: () {
                            if (!_hasTriggered && mounted) {
                              setState(() => _dragProgress = 0.0);
                            }
                          },
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(13.r),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isRtl
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final isDeliveredStage = widget.orderState == 2;
    final dist = widget.distanceToCustomerMeters;
    final isTooFar = isDeliveredStage && dist != null && dist > 100;

    String distanceText = "";
    if (dist != null) {
      distanceText = dist >= 1000
          ? "${(dist / 1000).toStringAsFixed(1)} كم"
          : "${dist.toStringAsFixed(0)} متر";
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTooFar) ...[
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.orange.shade800, size: 20.w),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      "يجب الاقتراب من موقع العميل (أقل من 100م) لتأكيد التوصيل\nالمسافة الحالية: $distanceText",
                      style: AppTextStyles.text12w600(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.orderState == 1)
            _buildSlideToPickupButton(context, colors)
          else
            ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isTooFar ? Colors.grey.shade400 : colors.primary,
                minimumSize: Size(double.infinity, 55.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              ),
              child: widget.isLoading
                  ? const LoadingButton(color: Colors.white)
                  : Text(
                      isTooFar
                          ? "اقترب من العميل لتأكيد التوصيل ($distanceText)"
                          : (widget.orderState < OrderActionButton._buttonTexts.length
                              ? OrderActionButton._buttonTexts[widget.orderState]
                              : "تم التوصيل"),
                      style: AppTextStyles.text16w700(color: Colors.white),
                    ),
            ),
        ],
      ),
    );
  }
}
