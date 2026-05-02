import 'package:base_app/core/extintions/extintios.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import '../exports/exports.dart';

class SowAllWidget extends StatelessWidget {
  const SowAllWidget({super.key, required this.title, required this.onTap});

  final String title;
  final Function() onTap;

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
            style: AppTextStyles.text14w600(color: colors.textPrimary),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              AppStrings.viewAll.trans,
              style: AppTextStyles.text12w400(color: colors.primaryVariant),
            ),
          ),
        ],
      ),
    );
  }
}
