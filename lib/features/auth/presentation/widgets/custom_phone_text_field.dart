import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localizations/app_strings.g.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';

class CustomPhoneTextField extends StatefulWidget {
  const CustomPhoneTextField({
    super.key,
    this.controller,
    this.onCountryChanged,
    this.validator,
  });

  final TextEditingController? controller;
  final Function(Country)? onCountryChanged;
  final String? Function(String?)? validator;

  @override
  State<CustomPhoneTextField> createState() => _CustomPhoneTextFieldState();
}

class _CustomPhoneTextFieldState extends State<CustomPhoneTextField> {
  Country? selectedCountry;

  @override
  void initState() {
    super.initState();
    _setDefaultCountry();
  }

  void _setDefaultCountry() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      if (locale.countryCode != null) {
        selectedCountry = CountryParser.parseCountryCode(locale.countryCode!);
      } else {
        selectedCountry = CountryParser.parseCountryCode('EG');
      }
      setState(() {});
    } catch (e) {
      selectedCountry = CountryParser.parseCountryCode('EG');
      setState(() {});
    }
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      useSafeArea: true,
      useRootNavigator: true,
      favorite: <String>['EG', 'SA', 'AE', 'US'],
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        inputDecoration: InputDecoration(
          labelText: 'ابحث عن دولة',
          hintText: 'ابدأ الكتابة...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        searchTextStyle: TextStyle(fontSize: 14.sp, color: AppColors.black),
      ),
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
        widget.onCountryChanged?.call(country);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      fillColor: Colors.transparent,
      hintText: AppStrings.phoneNumber,
      keyboardType: TextInputType.phone,
      prefixIcon: Icon(
        Icons.phone,
        color: AppColors(context).textPrimary.withValues(alpha: 0.6),
      ),
      suffixIcon: InkWell(
        onTap: _showCountryPicker,
        borderRadius: BorderRadius.circular(8.r),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: Directionality.of(context),
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${selectedCountry?.phoneCode ?? "20"}+',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors(context).textPrimary,
                ),
              ),
              4.horizontalSpace,
              Text(
                selectedCountry?.flagEmoji ?? '🇪🇬',
                style: TextStyle(fontSize: 20.sp),
              ),
              4.horizontalSpace,
              Icon(
                Icons.arrow_drop_down,
                size: 20.sp,

                color: AppColors(context).textPrimary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
