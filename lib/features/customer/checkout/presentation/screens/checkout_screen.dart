import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/checkout/presentation/riverpod/checkout_provider.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/checkout/presentation/screens/order_success_screen.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_address_card_widget.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_branch_selection_card_widget.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_customer_notes_card_widget.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_payment_methods_widget.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_promo_code_card_widget.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_bill_summary_widget.dart';
import 'package:base_app/features/customer/checkout/presentation/widgets/checkout_confirm_button_widget.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/profile/data/models/invitation_code_model.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/core/utils/auth_guard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/user_wallet_provider.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/user_wallet_transactions_pagination_notifier.dart';
import 'package:base_app/features/shared/finance/data/models/payment_method.dart';
import 'package:base_app/features/shared/finance/data/payments_api_service.dart';




class CheckoutScreen extends ConsumerStatefulWidget {
  final OfferDto? offer;
  const CheckoutScreen({super.key, this.offer});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPayment = 0; // 0 for Cash, 1 for Online
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();
  DiscountCodeDto? _appliedDiscount;
  bool _isApplyingPromo = false;

  List<LocationDto> _vendorLocations = [];
  LocationDto? _selectedVendorLocation;
  bool _isLoadingBranches = false;
  String? _branchesError;
  bool _isVendorClosed = false;
  bool _isVendorBusy = false;

  @override
  void dispose() {
    _notesController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleApplyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingPromo = true);
    final vendorId = _getVendorId();
    final service = ref.read(profileApiServiceProvider);

    final result = await service.getDiscounts();
    if (!mounted) return;

    setState(() => _isApplyingPromo = false);

    result.when(
      success: (response) {
        final list = response.result ?? [];
        final normalizedInput = code.toLowerCase();
        DiscountCodeDto? matched;

        for (final d in list) {
          final matchesName = d.name.trim().toLowerCase() == normalizedInput;
          final matchesVendor = d.creatorId == null ||
              d.creatorId == 0 ||
              vendorId == null ||
              d.creatorId == vendorId;
          if (matchesName && d.isCurrentlyValid && matchesVendor) {
            matched = d;
            break;
          }
        }

        if (matched != null) {
          setState(() => _appliedDiscount = matched);
          CustomToast.success(context, AppStrings.promoCodeAppliedSuccess);
        } else {
          CustomToast.error(context, AppStrings.invalidOrExpiredPromoCode);
        }
      },
      failure: (_) {
        CustomToast.error(context, AppStrings.invalidOrExpiredPromoCode);
      },
    );
  }

  void _handleRemovePromoCode() {
    setState(() {
      _appliedDiscount = null;
      _promoCodeController.clear();
    });
  }

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

    final vendorResult = await ref.read(homeApiServiceProvider).getUserById(vendorId);
    if (mounted) {
      vendorResult.when(
        success: (res) {
          if (res.success && res.result != null) {
            final v = res.result!;
            if (v.busy == true) {
              setState(() {
                _isVendorBusy = true;
              });
            }
            if (!(v.active ?? true) || v.status == 0) {
              setState(() {
                _isVendorClosed = true;
              });
            }
          }
        },
        failure: (_) {},
      );
    }

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

  Future<void> _handleConfirmOrder({
    required UserDto? user,
    required String addressName,
    required LocationDto? selectedLocation,
    required double productsPrice,
    required double deliveryFee,
    required double serviceFee,
    required int type,
    required int? offerId,
    required List<CreateOrderProductRequest>? products,
  }) async {
    final hasAuth = await AuthGuard.requireAuth(context, ref);
    if (!hasAuth || !mounted) return;

    if (user == null) {
      CustomToast.error(context, AppStrings.loginRequiredToContinue);
      return;
    }

    if (_isVendorBusy) {
      CustomToast.error(context, AppStrings.storeBusyCannotOrder);
      return;
    }

    if (_isVendorClosed) {
      CustomToast.error(context, AppStrings.storeClosedCannotOrder);
      return;
    }

    if (_selectedVendorLocation == null) {
      CustomToast.error(context, AppStrings.selectBranchFirst);
      return;
    }

    final vendorId = _getVendorId();
    if (vendorId == null) {
      CustomToast.error(context, AppStrings.storeNotSelectedTryAgain);
      return;
    }

    if (_selectedPayment == PaymentMethod.wallet.value) {
      final totalRequired = productsPrice + deliveryFee + serviceFee;
      final walletAsync = ref.read(userWalletProvider);
      final balance = walletAsync.asData?.value.availableBalance;
      if (balance != null && balance < totalRequired) {
        CustomToast.error(
          context,
          '${AppStrings.insufficientWalletBalance} (${balance.toStringAsFixed(2)} ${AppStrings.currency})',
        );
        return;
      }
    }

    final String rawNotes = _notesController.text.trim();
    final String promoNote = _appliedDiscount != null
        ? '[Promo: ${_appliedDiscount!.name} (-${_appliedDiscount!.percentage.toStringAsFixed(0)}%)]'
        : '';
    final String notesText = [
      if (rawNotes.isNotEmpty) rawNotes,
      if (promoNote.isNotEmpty) promoNote,
    ].join(' | ');
    final request = CreateOrderRequest(
      address: addressName,
      notes: notesText.isNotEmpty ? notesText : null,
      longitude: selectedLocation?.longitude ?? user.location?.longitude ?? 44.4,
      latitude: selectedLocation?.latitude ?? user.location?.latitude ?? 33.3,
      paymentMethod: _selectedPayment,
      totalPrice: productsPrice,
      deliveryFee: deliveryFee,
      orderFee: serviceFee,
      type: type,
      userId: vendorId,
      offerId: offerId,
      userLocationId: _selectedVendorLocation!.id,
      products: products,
    );

    final success = await ref.read(checkoutProvider.notifier).submitOrder(request);

    if (!mounted) return;

    if (success) {
      if (offerId == null) {
        ref.read(cartProvider.notifier).clearCart();
      }

      final createdOrder = ref.read(checkoutProvider).createdOrder;
      if (createdOrder != null) {
        if (_selectedPayment == PaymentMethod.visa.value) {
          final payResult = await ref
              .read(paymentsApiServiceProvider)
              .payOrder(createdOrder.id);
          if (mounted) {
            payResult.when(
              success: (res) async {
                final paymentUrl = res.result;
                if (paymentUrl != null && paymentUrl.isNotEmpty) {
                  final uri = Uri.tryParse(paymentUrl);
                  if (uri != null) {
                    try {
                      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                    } catch (_) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                }
              },
              failure: (_) {},
            );
          }
        } else if (_selectedPayment == PaymentMethod.wallet.value) {
          // Wallet was debited on backend, refresh local wallet state
          ref.invalidate(userWalletProvider);
          ref.invalidate(userWalletTransactionsPaginationProvider);
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(order: createdOrder),
            ),
          );
        }
      }
    } else {

      final errorMsg = ref.read(checkoutProvider).errorMessage ?? AppStrings.orderSubmitError;
      CustomToast.error(context, errorMsg);
    }
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

    final String addressName = selectedLocation?.address ?? user?.address ?? AppStrings.homeLocation;

    // Calculate Prices dynamically
    final double productsPrice;
    final int? offerId;
    final List<CreateOrderProductRequest>? products;
    final int type;

    if (widget.offer != null) {
      final offer = widget.offer!;
      if (offer.offerType == 1 && offer.products != null && offer.products!.isNotEmpty) {
        double sum = 0.0;
        for (final p in offer.products!) {
          sum += p.price * p.quantity;
        }
        productsPrice = sum > 0 ? sum : offer.price;
        offerId = null;
        products = offer.products!
            .map((p) => CreateOrderProductRequest(
                  productId: p.id,
                  price: p.price,
                  quantity: p.quantity,
                  productName: p.name,
                  photo: p.photo,
                  totalPrice: p.price * p.quantity,
                ))
            .toList();
        type = offer.type;
      } else {
        productsPrice = offer.price;
        offerId = offer.id;
        products = null;
        type = offer.type;
      }
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
              productName: item.product.name,
              photo: item.product.photo,
              totalPrice: item.effectivePrice * item.quantity,
            ),
          )
          .toList();
      type = cart.items.isNotEmpty ? cart.items.first.product.type : 0;
    }

    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.asData?.value ?? defaultAppSettings;

    final double userLat = selectedLocation?.latitude ?? user?.location?.latitude ?? 0.0;
    final double userLng = selectedLocation?.longitude ?? user?.location?.longitude ?? 0.0;
    final double storeLat = _selectedVendorLocation?.latitude ?? 0.0;
    final double storeLng = _selectedVendorLocation?.longitude ?? 0.0;

    final double distanceKm = calculateDistanceKm(userLat, userLng, storeLat, storeLng);
    final double discountAmount = _appliedDiscount != null
        ? (productsPrice * (_appliedDiscount!.percentage / 100.0))
        : 0.0;
    final double discountedProductsPrice =
        (productsPrice - discountAmount).clamp(0.0, double.infinity);
    final double deliveryFee = calcDeliveryFee(distanceKm, settings);
    final double serviceFee = calcOrderFee(discountedProductsPrice, settings);
    final double totalRequired =
        discountedProductsPrice + deliveryFee + serviceFee;

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
            CheckoutAddressCardWidget(
              addressName: addressName,
              selectedLocation: selectedLocation,
            ),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.vendorBranchLabel),
            10.verticalSpace,
            CheckoutBranchSelectionCardWidget(
              isLoadingBranches: _isLoadingBranches,
              branchesError: _branchesError,
              vendorLocations: _vendorLocations,
              selectedVendorLocation: _selectedVendorLocation,
              onLocationChanged: (newValue) {
                setState(() {
                  _selectedVendorLocation = newValue;
                });
              },
              onRetry: () {
                final vId = _getVendorId();
                if (vId != null) _fetchVendorBranches(vId);
              },
            ),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.customerNotesLabel),
            10.verticalSpace,
            CheckoutCustomerNotesCardWidget(controller: _notesController),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.howToPayLabel),
            10.verticalSpace,
            CheckoutPaymentMethodsWidget(
              selectedPayment: _selectedPayment,
              walletBalance: ref.watch(userWalletProvider).asData?.value.availableBalance,
              onPaymentSelected: (index) => setState(() => _selectedPayment = index),
            ),

            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.enterPromoCodeLabel),
            10.verticalSpace,
            CheckoutPromoCodeCardWidget(
              controller: _promoCodeController,
              isApplying: _isApplyingPromo,
              appliedDiscount: _appliedDiscount,
              onApply: _handleApplyPromoCode,
              onRemove: _handleRemovePromoCode,
            ),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.billSummaryLabel),
            10.verticalSpace,
            CheckoutBillSummaryWidget(
              productsPrice: productsPrice,
              deliveryFee: deliveryFee,
              serviceFee: serviceFee,
              discountAmount: discountAmount,
              totalRequired: totalRequired,
            ),
            30.verticalSpace,
          ],
        ),
      ),
      bottomNavigationBar: CheckoutConfirmButtonWidget(
        isLoading: isLoading,
        onConfirm: () => _handleConfirmOrder(
          user: user,
          addressName: addressName,
          selectedLocation: selectedLocation,
          productsPrice: discountedProductsPrice,
          deliveryFee: deliveryFee,
          serviceFee: serviceFee,
          type: type,
          offerId: offerId,
          products: products,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.text16w700(color: AppColors(context).textPrimary),
    );
  }
}
