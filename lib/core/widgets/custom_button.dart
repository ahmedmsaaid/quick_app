import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_style.dart';

enum ButtonType { primary, secondary, outlined, text }

class CustomAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final ButtonType type;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.elevation = 2,
    this.padding,
    this.textStyle,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width?.w ?? double.infinity,
      height: height?.h,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(context);
      case ButtonType.secondary:
        return _buildSecondaryButton(context);
      case ButtonType.outlined:
        return _buildOutlinedButton(context);
      case ButtonType.text:
        return _buildTextButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors(context).primary,
        disabledBackgroundColor: AppColors(context).primary.withOpacity(0.5),
        elevation: elevation,
        shadowColor: (backgroundColor ?? AppColors(context).primary)
            .withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!.r),
        ),
        padding: padding ?? EdgeInsets.zero,
      ),
      child: _buildButtonChild(context, textColor ?? Colors.white),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.green,
        disabledBackgroundColor: (backgroundColor ?? Colors.green).withOpacity(
          0.5,
        ),
        elevation: elevation,
        shadowColor: (backgroundColor ?? Colors.green).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!.r),
        ),
        padding: padding ?? EdgeInsets.zero,
      ),
      child: _buildButtonChild(context, textColor ?? Colors.white),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: borderColor ?? AppColors(context).primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!.r),
        ),
        padding: padding ?? EdgeInsets.zero,
      ),
      child: _buildButtonChild(
        context,
        textColor ?? AppColors(context).primary,
      ),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: TextButton.styleFrom(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!.r),
        ),
      ),
      child: _buildButtonChild(
        context,
        textColor ?? AppColors(context).primary,
      ),
    );
  }

  Widget _buildButtonChild(BuildContext context, Color defaultTextColor) {
    if (isLoading) {
      return SizedBox(
        height: 20.h,
        width: 20.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(defaultTextColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon!, 8.horizontalSpace, _buildText(defaultTextColor)],
      );
    }

    return _buildText(defaultTextColor);
  }

  Widget _buildText(Color defaultTextColor) {
    return Text(
      text,
      style:
          textStyle ??
          AppTextStyles.text16w600(
            color: defaultTextColor,
          ).copyWith(fontSize: fontSize?.sp, fontWeight: fontWeight),
    );
  }
}
