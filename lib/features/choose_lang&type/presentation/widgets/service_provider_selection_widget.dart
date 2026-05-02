import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/widgets/custom_button.dart';

import '../../../../core/exports/exports.dart';
import 'custom_choose_service_provider_type.dart';

class ServiceProviderSelection extends StatelessWidget {
  final int? selectedServiceType;
  final VoidCallback onBackPressed;
  final ValueChanged<int> onServiceTypeSelected;
  final VoidCallback onNextPressed;

  const ServiceProviderSelection({
    super.key,
    required this.selectedServiceType,
    required this.onBackPressed,
    required this.onServiceTypeSelected,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('serviceProvider'),
      children: [
        50.verticalSpace,

        CustomChooseServiceProviderType(
          txt: 'سيا ومسباو',
          img: AppIcons.massageIcon,
          isSelected: selectedServiceType == 0,
          onTap: () => onServiceTypeSelected(0),
        ),
        CustomChooseServiceProviderType(
          txt: 'صالون الحلاقة',
          img: AppIcons.cutIcon,
          isSelected: selectedServiceType == 1,
          onTap: () => onServiceTypeSelected(1),
        ),
        CustomChooseServiceProviderType(
          txt: 'كوافير حريمي',
          img: AppIcons.hairDresserIcon,
          isSelected: selectedServiceType == 2,
          onTap: () => onServiceTypeSelected(2),
        ),

        const Spacer(),

        CustomAppButton(
          text: AppStrings.next,
          onPressed: selectedServiceType != null ? onNextPressed : null,
          type: ButtonType.primary,
          isEnabled: selectedServiceType != null,
        ),
        24.verticalSpace,
      ],
    );
  }
}
