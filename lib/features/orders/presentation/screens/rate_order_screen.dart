import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';

class RateOrderScreen extends StatefulWidget {
  const RateOrderScreen({super.key});

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(AppStrings.rateOrderTitle, style: AppTextStyles.text18w700(color: colors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundImage: const AssetImage('assets/image/logo.png'),
            ),
            20.verticalSpace,
            Text(
              AppStrings.howWasExperienceMsg, 
              style: AppTextStyles.text16w600(color: colors.textPrimary),
            ),
            20.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40.sp,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            30.verticalSpace,
            CustomTextField(
              hintText: AppStrings.writeOpinionHintMsg,
              maxLines: 4,
            ),
            40.verticalSpace,
            CustomAppButton(
              text: AppStrings.sendRatingBtn,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.thanksForRatingMsg)));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
