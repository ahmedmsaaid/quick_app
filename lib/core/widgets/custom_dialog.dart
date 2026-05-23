import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/old_text_style.dart';

import '../../core/exports/exports.dart';
import '../../core/styles/app_colors.dart';

enum AlertTypes { success, error, warning, loading, normal }

class CustomDialog extends StatelessWidget {
  final String? message;
  final String? title;
  final bool showCircularLoading;
  final AlertTypes dialogType;
  final String? asset;
  final VoidCallback? onConfirm;
  final String? confirmText;
  final bool showConfirmButton;

  const CustomDialog({
    super.key,
    this.message,
    this.title,
    this.asset,
    this.showCircularLoading = true,
    required this.dialogType,
    this.onConfirm,
    this.confirmText,
    this.showConfirmButton = false,
  });

  Color _typeColor(BuildContext context) {
    final colors = AppColors(context);
    switch (dialogType) {
      case AlertTypes.success:
        return colors.success;
      case AlertTypes.error:
        return colors.error;
      case AlertTypes.warning:
        return colors.warning;
      case AlertTypes.loading:
        return colors.primary;
      case AlertTypes.normal:
      default:
        return colors.primary;
    }
  }

  IconData _typeIcon() {
    switch (dialogType) {
      case AlertTypes.success:
        return Icons.check_circle_outline_rounded;
      case AlertTypes.error:
        return Icons.error_outline_rounded;
      case AlertTypes.warning:
        return Icons.warning_amber_rounded;
      case AlertTypes.loading:
        return Icons.autorenew_rounded;
      case AlertTypes.normal:
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _typeTitle() {
    if (title != null) return title!;

    switch (dialogType) {
      case AlertTypes.success:
        return AppStrings.successDone;
      case AlertTypes.error:
        return AppStrings.errorOccurred;
      case AlertTypes.warning:
        return AppStrings.toastInfo;
      case AlertTypes.loading:
        return AppStrings.loading;
      case AlertTypes.normal:
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final textStyles = OldTextStyle(context);
    final typeColor = _typeColor(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: 400.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withValues(alpha: 0.1),
              ),
              child: _buildIconOrLoader(context, typeColor),
            ),

            SizedBox(height: 20.h),

            // Title
            if (_typeTitle().isNotEmpty) ...[
              Text(
                _typeTitle(),
                style: textStyles.title.copyWith(fontSize: 20.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
            ],

            // Message
            if (message != null && message!.isNotEmpty) ...[
              Text(
                message!,
                style: textStyles.subtitle.copyWith(fontSize: 15.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
            ],

            // Confirm Button
            if (showConfirmButton && onConfirm != null) ...[
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    confirmText ?? AppStrings.ok,
                    style: textStyles.buttonText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconOrLoader(BuildContext context, Color typeColor) {
    if (dialogType == AlertTypes.loading && showCircularLoading) {
      return Center(
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: CircularProgressIndicator(strokeWidth: 3.5, color: typeColor),
        ),
      );
    }

    if (asset != null) {
      return Center(
        child: Image.asset(
          asset!,
          width: 40.w,
          height: 40.h,
          fit: BoxFit.contain,
        ),
      );
    }

    return Center(
      child: Icon(_typeIcon(), size: 40.sp, color: typeColor),
    );
  }
}

// Helper functions to show dialogs
class DialogHelper {
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String? message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        dialogType: AlertTypes.loading,
        message: message ?? AppStrings.loading,
      ),
    );
  }

  static Future<void> showSuccessDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        dialogType: AlertTypes.success,
        title: title,
        message: message,
        showConfirmButton: true,
        onConfirm: onConfirm ?? () => Navigator.pop(context),
      ),
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        dialogType: AlertTypes.error,
        title: title,
        message: message,
        showConfirmButton: true,
        onConfirm: onConfirm ?? () => Navigator.pop(context),
      ),
    );
  }

  static Future<void> showWarningDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        dialogType: AlertTypes.warning,
        title: title,
        message: message,
        showConfirmButton: true,
        onConfirm: onConfirm ?? () => Navigator.pop(context),
      ),
    );
  }

  static void dismissDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
