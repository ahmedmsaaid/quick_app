import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';

import '../../../../core/exports/exports.dart';
import 'custom_user_type_card.dart';
class UserTypeSelection extends StatelessWidget {
  final VoidCallback onDeliveryTap;
  final VoidCallback onUserTap;

  const UserTypeSelection({
    super.key,
    required this.onDeliveryTap,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        key: const ValueKey('userType'),
        children: [
          30.verticalSpace,

          CustomUserTypeCard(
            txt: AppStrings.customer,
            img: AppIcons.userIcon,
            onTap: onUserTap,
          ),

          CustomUserTypeCard(
            txt: AppStrings.deliveryCaptain,
            img: AppIcons.deliveryIcon,
            onTap: onDeliveryTap,
          ),
        ],
      ),
    );
  }
}
