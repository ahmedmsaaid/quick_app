import 'package:base_app/core/extintions/extintios.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import '../exports/exports.dart';

class SeeAllWidget extends StatelessWidget {
  const SeeAllWidget({
    super.key,
    required this.title,
    required this.onTap,
    this.isReviews,
  });

  final String title;
  final VoidCallback onTap;
  final bool? isReviews;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.text18w600(color: colors.textPrimary),
          ),Spacer(),
          TextButton(
            onPressed: onTap,
            child: Text(
              isReviews ?? false
                  ? AppStrings.reviewNow.trans
                  : AppStrings.seeAll.trans,
              style: AppTextStyles.text14w500(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
