import 'package:base_app/core/network/api_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/checkout/presentation/riverpod/checkout_provider.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/checkout/presentation/screens/order_success_screen.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final OfferDto? offer;
  const CheckoutScreen({super.key, this.offer});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPayment = 0; // 0 for Cash, 1 for Online

  List<LocationDto> _vendorLocations = [];
  LocationDto? _selectedVendorLocation;
  bool _isLoadingBranches = false;
  String? _branchesError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
      final vendorId = _getVendorId();
      if (vendorId != null) {
        _fetchVendorBranches(vendorId);
      }
    });
  }

  int? _getVendorId() {
    if (widget.offer != null) {
      return widget.offer!.creatorId;
    }
    final cart = ref.read(cartProvider);
    return cart.vendorId;
  }

  Future<void> _fetchVendorBranches(int vendorId) async {
    setState(() {
      _isLoadingBranches = true;
      _branchesError = null;
    });
    final result = await ref
        .read(profileApiServiceProvider)
        .getLocations(creatorId: vendorId);
    if (!mounted) return;
    result.when(
      success: (response) {
        final locs = response.result ?? [];
        setState(() {
          _vendorLocations = locs;
          _isLoadingBranches = false;
          if (locs.length == 1) {
            _selectedVendorLocation = locs.first;
          } else if (locs.isNotEmpty) {
            _selectedVendorLocation = locs.firstWhere(
              (l) => l.base,
              orElse: () => locs.first,
            );
          }
        });
      },
      failure: (error) {
        setState(() {
          _branchesError = error.message;
          _isLoadingBranches = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    // Find default/base location
    LocationDto? selectedLocation;
    if (profileState.locations.isNotEmpty) {
      selectedLocation = profileState.locations.firstWhere(
        (loc) => loc.base,
        orElse: () => profileState.locations.first,
      );
    }

    final String addressName =
        selectedLocation?.address ?? user?.address ?? AppStrings.homeLocation;

    // Calculate Prices dynamically
    final double productsPrice;
    final int? offerId;
    final List<CreateOrderProductRequest>? products;
    final int type;

    if (widget.offer != null) {
      productsPrice = widget.offer!.price;
      offerId = widget.offer!.id;
      products = null;
      type = widget.offer!.type;
    } else {
      final cart = ref.watch(cartProvider);
      productsPrice = cart.subtotal;
      offerId = null;
      products = cart.items
          .map(
            (item) => CreateOrderProductRequest(
              productId: item.product.id,
              price: item.effectivePrice,
              quantity: item.quantity,
            ),
          )
          .toList();
      type = cart.items.isNotEmpty ? cart.items.first.product.type : 0;
    }

    // Get settings from shared provider
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.asData?.value;
    final double deliveryFee = settings?.deliveryFee ?? 0.0;
    final double serviceFee = settings != null ? calcOrderFee(productsPrice, settings) : 0.0;
    final double totalRequired = productsPrice + deliveryFee + serviceFee;

    final checkoutState = ref.watch(checkoutProvider);
    final isLoading = checkoutState.status == CheckoutStatus.loading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.confirmBooking,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, AppStrings.whereToDeliverLabel),
            10.verticalSpace,
            _buildAddressCard(context, addressName),
            25.verticalSpace,
            _buildSectionTitle(context, "فرع المطعم / الماركت"),
            10.verticalSpace,
            _buildBranchSelectionCard(context),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.howToPayLabel),
            10.verticalSpace,
            _buildPaymentMethods(context),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.billSummaryLabel),
            10.verticalSpace,
            _buildOrderSummary(
              context,
              productsPrice,
              deliveryFee,
              serviceFee,
              totalRequired,
            ),
            30.verticalSpace,
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(
        context,
        isLoading,
        addressName,
        selectedLocation,
        user,
        totalRequired,
        deliveryFee,
        serviceFee,
        type,
        offerId,
        products,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.text16w700(color: AppColors(context).textPrimary),
    );
  }

  Widget _buildAddressCard(BuildContext context, String addressName) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: colors.primary, size: 24.sp),
          15.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeLabel,
                  style: AppTextStyles.text14w600(color: colors.textPrimary),
                ),
                Text(
                  addressName,
                  style: AppTextStyles.text12w400(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.address);
            },
            child: Text(
              AppStrings.changeBtn,
              style: AppTextStyles.text12w600(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      children: [
        _buildPaymentItem(
          context,
          0,
          Icons.money,
          AppStrings.cashOnDeliveryLabel,
        ),
        10.verticalSpace,
        _buildPaymentItem(
          context,
          1,
          Icons.credit_card,
          AppStrings.onlinePaymentLabel,
        ),
      ],
    );
  }

  Widget _buildPaymentItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
  ) {
    final colors = AppColors(context);
    bool isSelected = _selectedPayment == index;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colors.primary : colors.textHint),
            15.horizontalSpace,
            Text(
              title,
              style: AppTextStyles.text14w500(color: colors.textPrimary),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    double productsPrice,
    double deliveryFee,
    double serviceFee,
    double totalRequired,
  ) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            AppStrings.productsPriceLabel,
            '${productsPrice.toStringAsFixed(0)} جنيه مصري',
          ),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.deliveryFeesLabelMsg,
            '${deliveryFee.toStringAsFixed(0)} جنيه مصري',
          ),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.serviceFeesLabel,
            '${serviceFee.toStringAsFixed(0)} جنيه مصري',
          ),
          10.verticalSpace,
          const Divider(),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.totalRequiredLabel,
            '${totalRequired.toStringAsFixed(0)} جنيه مصري',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    String value, {
    bool isTotal = false,
  }) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isTotal
              ? AppTextStyles.text16w700(color: colors.textPrimary)
              : AppTextStyles.text14w400(color: colors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.text16w700(color: colors.primary)
              : AppTextStyles.text14w600(color: colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildBranchSelectionCard(BuildContext context) {
    final colors = AppColors(context);
    if (_isLoadingBranches) {
      return Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
            15.horizontalSpace,
            Text(
              "جاري تحميل فروع المتجر...",
              style: AppTextStyles.text14w500(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_branchesError != null) {
      return Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 24.sp),
            15.horizontalSpace,
            Expanded(
              child: Text(
                _branchesError!,
                style: AppTextStyles.text12w400(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                final vId = _getVendorId();
                if (vId != null) _fetchVendorBranches(vId);
              },
              child: Text(
                "إعادة المحاولة",
                style: AppTextStyles.text12w600(color: colors.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (_vendorLocations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          "لا توجد فروع متوفرة لهذا المطعم/الماركت",
          style: AppTextStyles.text12w400(color: colors.textSecondary),
        ),
      );
    }

    if (_vendorLocations.length == 1) {
      return Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.storefront, color: colors.primary, size: 24.sp),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الفرع الرئيسي (تلقائي)",
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
                  ),
                  Text(
                    _selectedVendorLocation?.address ?? "العنوان غير متوفر",
                    style: AppTextStyles.text12w400(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<LocationDto>(
          initialValue: _selectedVendorLocation,
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: Icon(Icons.storefront, color: colors.primary, size: 24.sp),
          ),
          hint: Text(
            "اختر الفرع المناسب",
            style: AppTextStyles.text14w500(color: colors.textSecondary),
          ),
          isExpanded: true,
          dropdownColor: colors.surface,
          items: _vendorLocations.map((loc) {
            final isBase = loc.base ? " (الفرع الرئيسي)" : "";
            return DropdownMenuItem<LocationDto>(
              value: loc,
              child: Text(
                "${loc.address ?? ''}$isBase",
                style: AppTextStyles.text14w500(color: colors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedVendorLocation = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
    BuildContext context,
    bool isLoading,
    String addressName,
    LocationDto? selectedLocation,
    UserDto? user,
    double totalRequired,
    double deliveryFee,
    double serviceFee,
    int type,
    int? offerId,
    List<CreateOrderProductRequest>? products,
  ) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      color: colors.surface,
      child: isLoading
          ? const LoadingButton()
          : CustomAppButton(
              text: AppStrings.confirmBooking,
              onPressed: () async {
                if (user == null) {
                  CustomToast.error(context, "الرجاء تسجيل الدخول أولاً");
                  return;
                }

                if (_selectedVendorLocation == null) {
                  CustomToast.error(
                    context,
                    "الرجاء اختيار فرع المطعم/الماركت أولاً",
                  );
                  return;
                }

                final request = CreateOrderRequest(
                  address: addressName,
                  longitude:
                      selectedLocation?.longitude ??
                      user.location?.longitude ??
                      44.4,
                  latitude:
                      selectedLocation?.latitude ??
                      user.location?.latitude ??
                      33.3,
                  paymentMethod: _selectedPayment,
                  totalPrice: totalRequired,
                  deliveryFee: deliveryFee,
                  orderFee: serviceFee,
                  type: type,
                  userId: user.id,
                  offerId: offerId,
                  userLocationId: _selectedVendorLocation!.id,
                  products: products,
                );

                final success = await ref
                    .read(checkoutProvider.notifier)
                    .submitOrder(request);

                if (context.mounted) {
                  if (success) {
                    // Clear cart if this was a normal products order
                    if (offerId == null) {
                      ref.read(cartProvider.notifier).clearCart();
                    }

                    // Show order success screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const OrderSuccessScreen(),
                      ),
                    );
                  } else {
                    final errorMsg =
                        ref.read(checkoutProvider).errorMessage ??
                        "حدث خطأ أثناء تقديم الطلب";
                    CustomToast.error(context, errorMsg);
                  }
                }
              },
            ),
    );
  }
}
