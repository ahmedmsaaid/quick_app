import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MockCategoryCard extends StatelessWidget {
  final String name;
  final String? emoji;
  final String? photoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const MockCategoryCard({
    super.key,
    required this.name,
    this.emoji,
    this.photoUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 82.w,
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.containerBackground,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // White circle with emoji or photo
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: ClipOval(
                child: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: photoUrl!,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40.w,
                          height: 40.w,
                          color: Colors.white,
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            emoji ?? '🍽️',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          emoji ?? '🍽️',
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
              ),
            ),
            2.verticalSpace,
            // Name
            Text(
              name,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : colors.textPrimary,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            4.verticalSpace,
            // Small button at the bottom
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.secondary
                    : colors.textHint.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
