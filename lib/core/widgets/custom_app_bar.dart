import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

import '../exports/exports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeading;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final bool showTrailing;
  final IconData trailingIcon;
  final void Function()? onTrailingTap;
  final Color buttonBgColor;
  final Color iconColor;
  final Color? appBarColor;
  final Widget? leadingWidget;
  final VoidCallback? onTitleTap;
  final bool isCircularIcon;

  const CustomAppBar({
    super.key,
    this.onTitleTap,
    required this.title,
    this.showLeading = true,
    this.leadingIcon = Icons.arrow_back_ios_new,
    this.onLeadingTap,
    this.showTrailing = true,
    this.trailingIcon = Icons.arrow_forward_ios,
    this.onTrailingTap,
    this.buttonBgColor = AppColors.white,
    this.iconColor = AppColors.black,
    this.appBarColor,
    this.leadingWidget,
    this.isCircularIcon = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appBarColor ?? AppColors(context).background,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 60.h,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: showLeading ? 55.w : 0,
      actions: [
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          child: CustomArrowBack(
            isCircular: isCircularIcon,
            onTap: onTrailingTap ?? () => Navigator.pop(context),
            color: AppColors(context).primaryVariant.withAlpha(30),
          ),
        ),
      ],

      title: GestureDetector(
        onTap: onTitleTap,
        child: Text(
          title,
          style: AppTextStyles.text20w500().copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
