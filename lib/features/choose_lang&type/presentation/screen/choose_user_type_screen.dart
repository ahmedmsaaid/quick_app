import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/exports/exports.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/service_provider_selection_widget.dart';
import '../widgets/user_type_selection_widget.dart';

class ChooseUserTypeScreen extends StatefulWidget {
  const ChooseUserTypeScreen({super.key});

  @override
  State<ChooseUserTypeScreen> createState() => _ChooseUserTypeScreenState();
}

class _ChooseUserTypeScreenState extends State<ChooseUserTypeScreen> {
  bool isService = false;
  int? selectedServiceType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.chooseYourType),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            // final language = ref.watch(localizationProvider.notifier);
            // ref.listen(localizationProvider, (previous, next) {
            //   CacheHelper.setBool(CacheKeys.isFirstTime, true);
            //   context.setLocale(next.locale);
            //   context.pushNamedAndRemoveUntil(AppRoutes.chooseUserTypeScreen);
            // });

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  29.verticalSpace,
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: child,
                              ),
                            );
                          },
                      child: !isService
                          ? UserTypeSelection(
                              onServiceProviderTap: () {
                                setState(() {
                                  isService = true;
                                });
                              },
                              onUserTap: () {
                                context.pushNamedAndRemoveUntil(
                                  AppRoutes.loginScreen,
                                  arguments: true,
                                );
                              },
                            )
                          : ServiceProviderSelection(
                              selectedServiceType: selectedServiceType,
                              onBackPressed: () {
                                setState(() {
                                  isService = false;
                                  selectedServiceType = null;
                                });
                              },
                              onServiceTypeSelected: (index) {
                                setState(() {
                                  selectedServiceType = index;
                                });
                              },
                              onNextPressed: () {
                                context.pushNamedAndRemoveUntil(
                                  AppRoutes.loginScreen,
                                );
                              },
                            ),
                    ),
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
