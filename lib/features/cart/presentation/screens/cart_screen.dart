import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int quantity1 = 1;
  int quantity2 = 1;
  final int pricePerItem = 8500;
  final int deliveryFee = 2500;
  final int serviceFee = 500;

  @override
  Widget build(BuildContext context) {
    int subtotal = (quantity1 + quantity2) * pricePerItem;
    int total = subtotal + deliveryFee + serviceFee;

    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.shoppingCartTitle,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                _buildCartItem(
                  context,
                  AppStrings.classicBurgerDoubleTitle,
                  quantity1,
                  () => setState(() { if (quantity1 > 1) quantity1--; }),
                  () => setState(() => quantity1++),
                ),
                15.verticalSpace,
                _buildCartItem(
                  context,
                  AppStrings.quickChickenMealTitle,
                  quantity2,
                  () => setState(() { if (quantity2 > 1) quantity2--; }),
                  () => setState(() => quantity2++),
                ),
              ],
            ),
          ),
          _buildSummarySection(context, subtotal, total),
        ],
      ),
      bottomNavigationBar: _buildCheckoutButton(context),
    );
  }

  Widget _buildCartItem(BuildContext context, String name, int qty, VoidCallback onRemove, VoidCallback onAdd) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors(context).surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors(context).border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              'assets/image/logo.png',
              width: 70.w,
              height: 70.h,
              fit: BoxFit.cover,
            ),
          ),
          15.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                ),
                5.verticalSpace,
                Text(
                  '$pricePerItem ${AppStrings.currency}',
                  style: AppTextStyles.text14w700(color: AppColors(context).primary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildIconBtn(Icons.remove, AppColors(context).border, AppColors(context).textPrimary, onRemove),
              10.horizontalSpace,
              Text('$qty', style: AppTextStyles.text14w700(color: AppColors(context).textPrimary)),
              10.horizontalSpace,
              _buildIconBtn(Icons.add, AppColors(context).primary, Colors.white, onAdd),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(icon, color: iconColor, size: 18.sp),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, int subtotal, int total) {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: AppColors(context).surface,
      child: Column(
        children: [
          _buildSummaryRow(AppStrings.subtotalLabel, '${subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${AppStrings.currency}'),
          10.verticalSpace,
          _buildSummaryRow(AppStrings.deliveryFeesLabel, '2,500 ${AppStrings.currency}'),
          10.verticalSpace,
          _buildSummaryRow(AppStrings.serviceFeesLabel, '500 ${AppStrings.currency}'),
          15.verticalSpace,
          Divider(color: AppColors(context).divider),
          15.verticalSpace,
          _buildSummaryRow(AppStrings.finalTotalLabel, '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${AppStrings.currency}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal 
            ? AppTextStyles.text16w700(color: AppColors(context).textPrimary)
            : AppTextStyles.text14w400(color: AppColors(context).textSecondary),
        ),
        Text(
          value,
          style: isTotal 
            ? AppTextStyles.text16w700(color: AppColors(context).primary)
            : AppTextStyles.text14w600(color: AppColors(context).textPrimary),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: AppColors(context).surface,
      child: CustomAppButton(
        text: AppStrings.confirmOrder,
        onPressed: () {
          context.pushNamed(AppRoutes.cart);
        },
      ),
    );
  }
}
