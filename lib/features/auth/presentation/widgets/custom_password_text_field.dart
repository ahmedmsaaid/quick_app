// lib/core/widgets/password_text_field.dart
import 'package:flutter/material.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';

class CustomPasswordTextField extends StatelessWidget {
  const CustomPasswordTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.fillColor,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      fillColor: fillColor ?? Colors.transparent,
      hintText: hintText,
      showPasswordToggle: true,
      prefixIcon: Icon(
        Icons.lock,
        color: AppColors(context).textPrimary.withOpacity(0.6),
      ),
      obscureText: true,
      validator: validator,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }
}
