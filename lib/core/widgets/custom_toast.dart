import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/styles/app_colors.dart';

enum ToastType { success, error, warning, info }

class CustomToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    bool showCloseButton = false,
  }) {
    if (_isVisible) {
      hide();
    }

    final colors = AppColors(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        colors: colors,
        showCloseButton: showCloseButton,
        onClose: hide,
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
    _isVisible = true;

    Future.delayed(duration, () {
      hide();
    });
  }

  static void hide() {
    if (_isVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }

  // Success Toast
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.success,
      duration: duration,
    );
  }

  // Error Toast
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.error,
      duration: duration,
    );
  }

  // Warning Toast
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.warning,
      duration: duration,
    );
  }

  // Info Toast
  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final AppColors colors;
  final bool showCloseButton;
  final VoidCallback onClose;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.colors,
    required this.showCloseButton,
    required this.onClose,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return widget.colors.success;
      case ToastType.error:
        return widget.colors.error;
      case ToastType.warning:
        return widget.colors.warning;
      case ToastType.info:
        return AppColors.brandTeal;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10.h,
      left: 20.w,
      right: 20.w,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(), color: Colors.white, size: 20.sp),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTextStyles.text14w600(color: Colors.white),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.showCloseButton) ...[
                    8.horizontalSpace,
                    InkWell(
                      onTap: () {
                        _controller.reverse().then((_) => widget.onClose());
                      },
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
