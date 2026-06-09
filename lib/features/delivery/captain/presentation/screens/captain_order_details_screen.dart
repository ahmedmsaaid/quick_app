import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class CaptainOrderDetailsScreen extends StatefulWidget {
  const CaptainOrderDetailsScreen({super.key});

  @override
  State<CaptainOrderDetailsScreen> createState() => _CaptainOrderDetailsScreenState();
}

class _CaptainOrderDetailsScreenState extends State<CaptainOrderDetailsScreen> {
  int _orderState = 0; // 0: Available, 1: Accepted/Going to store, 2: At Store/Picked up, 3: Delivered

  final List<String> _buttonTexts = [
    AppStrings.acceptAndGoToStoreBtn,
    AppStrings.arrivedStoreBtn,
    AppStrings.pickedUpAndOnWayBtn,
    AppStrings.deliveredDoneBtn,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          '${AppStrings.captainOrderDetailsTitle} #12345',
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildOrderInfoCard(context),
            20.verticalSpace,
            _buildLocationTimeline(context),
            20.verticalSpace,
            _buildOrderSummary(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionBtn(context),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(context, AppStrings.netProfitLabel, '5,000 ${AppStrings.currency}', colors.success),
          _buildInfoItem(context, AppStrings.tripDistanceLabel, '4.2 ${AppStrings.kmAway}', Colors.blue),
          _buildInfoItem(context, AppStrings.paymentMethodLabel, AppStrings.cashLabel, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.text12w400(color: AppColors(context).textSecondary)),
        5.verticalSpace,
        Text(value, style: AppTextStyles.text14w700(color: color)),
      ],
    );
  }

  Widget _buildLocationTimeline(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.surface, 
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            context,
            Icons.store,
            AppStrings.pickupPointLabel,
            '${AppStrings.quickBurgerRestaurant} - ${AppStrings.mansourLabel}',
            AppStrings.mansourAddressMsg,
            Colors.blue,
          ),
          20.verticalSpace,
          _buildTimelineItem(
            context,
            Icons.location_on,
            AppStrings.deliveryPointLabel,
            AppStrings.userNamePlaceholder,
            AppStrings.mockClientAddress,
            colors.error,
            isLast: true,
            isCustomer: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, IconData icon, String type, String title, String subtitle, Color color, {bool isLast = false, bool isCustomer = false}) {
    final colors = AppColors(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            if (!isLast)
              Container(width: 2.w, height: 40.h, color: colors.divider),
          ],
        ),
        15.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: AppTextStyles.text10w500(color: color)),
              Text(title, style: AppTextStyles.text14w700(color: colors.textPrimary)),
              Text(subtitle, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            ],
          ),
        ),
        if (isCustomer)
           Row(
             children: [
               IconButton(onPressed: () {}, icon: Icon(Icons.call, color: colors.success, size: 22.sp)),
               IconButton(
                 onPressed: () {
                   Navigator.of(context).pushNamed(AppRoutes.chatDetailsScreen, arguments: title);
                 }, 
                 icon: Icon(Icons.chat, color: colors.primary, size: 22.sp)
               ),
             ],
           ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.surface, 
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.orderDetails, style: AppTextStyles.text14w700(color: colors.textPrimary)),
          15.verticalSpace,
          _buildSummaryRow(context, '2 ${AppStrings.classicBurgerDoubleTitle}', '17,000 ${AppStrings.currency}'),
          10.verticalSpace,
          Divider(color: colors.divider),
          10.verticalSpace,
          _buildSummaryRow(context, AppStrings.requiredFromCustomerLabel, '17,000 ${AppStrings.currency}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, {bool isTotal = false}) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: isTotal ? AppTextStyles.text14w700(color: colors.textPrimary) : AppTextStyles.text14w400(color: colors.textSecondary)),
        Text(value, style: isTotal ? AppTextStyles.text16w700(color: colors.primary) : AppTextStyles.text14w600(color: colors.textPrimary)),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (_orderState < 3) {
              _orderState++;
            } else {
              Navigator.pop(context);
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          minimumSize: Size(double.infinity, 55.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
        child: Text(
          _buttonTexts[_orderState],
          style: AppTextStyles.text16w700(color: Colors.white),
        ),
      ),
    );
  }
}
