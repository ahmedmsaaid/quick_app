import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import '../../../../core/exports/exports.dart';

class CustomChooseServiceProviderType extends StatefulWidget {
  const CustomChooseServiceProviderType({
    super.key,
    required this.txt,
    required this.img,
    required this.isSelected,
    required this.onTap,
  });

  final String txt;
  final String img;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<CustomChooseServiceProviderType> createState() =>
      _CustomChooseServiceProviderTypeState();
}

class _CustomChooseServiceProviderTypeState
    extends State<CustomChooseServiceProviderType>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedScale(
        scale: widget.isSelected ? 1.0 : 0.98,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(vertical: 8.w),
          height: 88.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors(context).primaryVariant
                  : AppColors(context).border,
              width: widget.isSelected ? 2 : 1,
            ),
            color: widget.isSelected
                ? AppColors(context).primaryVariant.withOpacity(0.02)
                : Colors.transparent,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors(context).primaryVariant.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52.h,
                    width: 52.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected
                          ? AppColors(context).primaryVariant.withOpacity(0.15)
                          : AppColors(context).cardBackground,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        widget.img,
                        width: 24.w,
                        colorFilter: ColorFilter.mode(
                          AppColors(context).primaryVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),

                  16.horizontalSpace,

                  Expanded(
                    child: Text(
                      widget.txt,
                      style: AppTextStyles.text18w700().copyWith(
                        color: widget.isSelected
                            ? AppColors(context).primaryVariant
                            : null,
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Radio<bool>(
                      value: true,
                      groupValue: widget.isSelected ? true : null,
                      onChanged: (_) => widget.onTap(),
                      activeColor: AppColors(context).primaryVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
