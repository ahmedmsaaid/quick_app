import 'package:flutter/material.dart';
import 'package:base_app/main.dart';

import '../styles/app_colors.dart';

class CustomSnackBar {

  static void show(
    BuildContext context,
    String message, {
    Color backgroundColor = AppColors.white,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    backgroundColor  = AppColors (context).primary;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }
}
