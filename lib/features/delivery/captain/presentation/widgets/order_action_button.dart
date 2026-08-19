import 'package:base_app/core/widgets/lading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class OrderActionButton extends StatelessWidget {
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
    "استلام الطلب",
    "تم التوصيل",
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final isDeliveredStage = orderState == 2;
    final dist = distanceToCustomerMeters;
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
          ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isTooFar ? Colors.grey.shade400 : colors.primary,
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            ),
            child: isLoading
                ? const LoadingButton(color: Colors.white)
                : Text(
                    isTooFar
                        ? "اقترب من العميل لتأكيد التوصيل ($distanceText)"
                        : (orderState < _buttonTexts.length ? _buttonTexts[orderState] : "تم التوصيل"),
                    style: AppTextStyles.text16w700(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}
