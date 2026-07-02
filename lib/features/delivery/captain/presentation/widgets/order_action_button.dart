import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class OrderActionButton extends StatelessWidget {
  final int orderState;
  final bool isLoading;
  final VoidCallback? onPressed;

  const OrderActionButton({
    super.key,
    required this.orderState,
    required this.isLoading,
    this.onPressed,
  });

  static final List<String> _buttonTexts = [
    "قبول الطلب",
    "وصلت للمتجر",
    "استلام الطلب",
    "تم التوصيل",
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          minimumSize: Size(double.infinity, 55.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _buttonTexts[orderState],
                style: AppTextStyles.text16w700(color: Colors.white),
              ),
      ),
    );
  }
}
