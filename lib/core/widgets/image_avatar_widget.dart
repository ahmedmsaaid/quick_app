import 'package:base_app/core/styles/app_colors.dart';

import '../exports/exports.dart';

class ImageAvatarWidget extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final void Function()? onTap;

  const ImageAvatarWidget({
    super.key,
    required this.size,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.h,
        width: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors(context).primary.withValues(alpha: 0.2),
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageUrl == null
            ? Icon(
                Icons.person,
                color: AppColors(context).primary,
                size: (size * 0.6).sp,
              )
            : null,
      ),
    );
  }
}
