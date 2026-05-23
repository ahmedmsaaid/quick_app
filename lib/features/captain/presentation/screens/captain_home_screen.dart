import 'dart:async';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';

class CaptainHomeScreen extends StatefulWidget {
  const CaptainHomeScreen({super.key});

  @override
  State<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends State<CaptainHomeScreen> {
  bool _isOnline = true;
  Timer? _breakTimer;
  int _breakSecondsRemaining = 1800; // 30 minutes

  void _toggleStatus(bool val) {
    setState(() {
      _isOnline = val;
      if (!_isOnline) {
        _startBreakTimer();
      } else {
        _breakTimer?.cancel();
        _breakSecondsRemaining = 1800;
      }
    });
  }

  void _startBreakTimer() {
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_breakSecondsRemaining > 0) {
        setState(() {
          _breakSecondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isOnline = true;
          _breakSecondsRemaining = 1800;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _breakTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          AppStrings.controlPanelTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? AppStrings.onlineNowStatus : AppStrings.breakLabel.split(' ')[0],
                style: AppTextStyles.text12w600(color: _isOnline ? AppColors(context).success : AppColors(context).warning),
              ),
              Switch(
                value: _isOnline,
                onChanged: _toggleStatus,
                activeColor: AppColors(context).success,
                inactiveThumbColor: AppColors(context).warning,
                inactiveTrackColor: AppColors(context).warning.withOpacity(0.3),
              ),
            ],
          ),
          10.horizontalSpace,
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildStatusCard(context),
            20.verticalSpace,
            _buildStatsGrid(context),
            20.verticalSpace,
            _buildSectionHeader(context, AppStrings.availableOrdersNow),
            10.verticalSpace,
            if (_isOnline) _buildAvailableOrdersList(context) else _buildBreakMessage(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: _isOnline ? colors.success.withOpacity(0.1) : colors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: _isOnline ? colors.success : colors.warning, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.check_circle : Icons.timer_outlined,
            color: _isOnline ? colors.success : colors.warning,
          ),
          15.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? AppStrings.onlineReadyToWorkMsg : AppStrings.breakLabel,
                  style: AppTextStyles.text14w600(color: _isOnline ? colors.success : colors.warning),
                ),
                if (!_isOnline)
                  Text(
                    '${AppStrings.timeLeftLabel}: ${_formatTime(_breakSecondsRemaining)}',
                    style: AppTextStyles.text12w400(color: colors.warning),
                  ),
              ],
            ),
          ),
          if (!_isOnline)
            TextButton(
              onPressed: () => _toggleStatus(true),
              child: Text(AppStrings.endBreakBtn, style: TextStyle(color: colors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(context, AppStrings.todayOrders, '12', Icons.shopping_bag_outlined, Colors.blue),
        15.horizontalSpace,
        _buildStatItem(context, AppStrings.todayEarnings, '45,000 ${AppStrings.currency}', Icons.account_balance_wallet_outlined, Colors.orange),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    final colors = AppColors(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.sp),
            10.verticalSpace,
            Text(title, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            5.verticalSpace,
            Text(value, style: AppTextStyles.text16w700(color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.text16w700(color: colors.textPrimary)),
        TextButton(onPressed: () {}, child: Text(AppStrings.refresh, style: TextStyle(color: colors.primary))),
      ],
    );
  }

  Widget _buildAvailableOrdersList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, index);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, int index) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: colors.primary.withOpacity(0.1), child: Icon(Icons.restaurant, color: colors.primary, size: 20.sp)),
              15.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.quickBurgerRestaurant, style: AppTextStyles.text14w700(color: colors.textPrimary)),
                    Text(AppStrings.mansourAddressMsg, style: AppTextStyles.text12w400(color: colors.textSecondary)),
                  ],
                ),
              ),
              Text('5,000 ${AppStrings.currency}', style: AppTextStyles.text14w700(color: colors.primary)),
            ],
          ),
          20.verticalSpace,
          Row(
            children: [
              Icon(Icons.location_on, color: colors.error, size: 18.sp),
              10.horizontalSpace,
              Text('${AppStrings.distanceAwayMsg} 1.5 ${AppStrings.kmAway}', style: AppTextStyles.text12w400(color: colors.textSecondary)),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.captainOrderDetails),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(AppStrings.viewDetailsBtn, style: AppTextStyles.text12w600(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakMessage(BuildContext context) {
    final colors = AppColors(context);
    return Column(
      children: [
        40.verticalSpace,
        Icon(Icons.coffee_outlined, size: 80.sp, color: colors.warning),
        20.verticalSpace,
        Text(AppStrings.breakLabel, style: AppTextStyles.text14w600(color: colors.textSecondary)),
        Text(AppStrings.openOnlineToReceiveOrdersMsg, style: AppTextStyles.text12w400(color: colors.textHint)),
        30.verticalSpace,
        ElevatedButton(
          onPressed: () => _toggleStatus(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text(AppStrings.endBreakBtn, style: AppTextStyles.text12w600(color: Colors.white)),
        ),
      ],
    );
  }
}
