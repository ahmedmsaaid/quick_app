import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:base_app/core/localizations/localization_provider.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

import '../../../../core/exports/exports.dart';
import '../../../../core/services/cach_helper/cache_helper.dart';
import '../widgets/custom_language_card.dart';

class ChooseYourLanguageScreen extends StatelessWidget {
  const ChooseYourLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isFromSettings = (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;

    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: isFromSettings 
          ? AppBar(
              backgroundColor: AppColors(context).surface,
              elevation: 0,
              leading: const CustomArrowBack(),
              title: Text(
                AppStrings.chooseYourLanguage,
                style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
              ),
            )
          : null,
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final language = ref.watch(localizationProvider.notifier);

            ref.listen(localizationProvider, (previous, next) async {
              context.setLocale(next);
              await CacheHelper.setBool(CacheKeys.isFirstTime, false);

              if (isFromSettings) {
                Navigator.of(context).pop();
              } else {
                context.pushNamed(AppRoutes.chooseUserTypeScreen);
              }
            });

            return Center(
              child: Column(
                children: [
                  if (!isFromSettings) ...[
                    40.verticalSpace,
                    Text(
                      AppStrings.chooseYourLanguage,
                      style: AppTextStyles.text20w700(color: AppColors(context).textPrimary),
                    ),
                  ],

                  CustomChooseCard(
                    txt: AppStrings.arabic,
                    img: AppIcons.iraqIcon,
                    onTap: () {
                      language.changeToArabic();
                    },
                  ),

                  CustomChooseCard(
                    txt: 'English',
                    img: AppIcons.ukIcon,
                    onTap: () {
                      language.changeToEnglish();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
