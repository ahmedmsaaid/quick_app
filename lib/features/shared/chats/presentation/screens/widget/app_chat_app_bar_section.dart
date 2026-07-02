import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import '../../../data/enums/role_type_enum.dart';

class AppChatAppBarSection extends StatelessWidget {
  const AppChatAppBarSection({
    super.key,
    required this.image,
    required this.name,
    required this.type,
    required this.profileId,
    required this.userId,
    this.isOnline = true,
  });

  final String image;
  final String name;
  final int userId;
  final bool isOnline;
  final RoleTypeEnum type;
  final int profileId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.divider.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const CustomArrowBack(),
            12.horizontalSpace,
            CircleAvatar(
              radius: 20.r,
              backgroundColor: colors.divider,
              backgroundImage: image.isNotEmpty
                  ? NetworkImage(image) as ImageProvider
                  : const AssetImage('assets/image/logo.png'),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  Text(
                    isOnline ? 'نشط الآن' : 'غير نشط',
                    style: AppTextStyles.text10w400(
                      color: isOnline ? colors.success : colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
