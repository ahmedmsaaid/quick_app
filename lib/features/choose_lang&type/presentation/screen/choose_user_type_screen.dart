import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/exports/exports.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/service_provider_selection_widget.dart';
import '../widgets/user_type_selection_widget.dart';

class ChooseUserTypeScreen extends StatelessWidget {
  const ChooseUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.chooseYourType,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: UserTypeSelection(
            onUserTap: () {
              context.pushNamed(
                AppRoutes.loginScreen,
                arguments: true,
              );
            },
            onDeliveryTap: () {
              context.pushNamed(
                AppRoutes.loginScreen,
                arguments: false,
              );
            },
          ),
        ),
      ),
    );
  }
}