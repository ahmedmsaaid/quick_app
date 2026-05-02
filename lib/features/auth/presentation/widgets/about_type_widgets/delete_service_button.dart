// lib/features/auth/presentation/widgets/delete_service_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteServiceButton extends StatelessWidget {
  const DeleteServiceButton({super.key, required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onDelete,
      icon: Icon(Icons.delete_outline, color: Colors.red, size: 24.w),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
