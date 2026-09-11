import 'package:flutter/material.dart';
import 'package:base_app/core/widgets/custom_toast.dart';

class CustomSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    CustomToast.show(
      context: context,
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }
}
