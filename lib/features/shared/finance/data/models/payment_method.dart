import 'package:flutter/material.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';

/// Supported payment methods matching backend enum:
/// ```csharp
/// public enum PaymentMethod
/// {
///     Cash,   // 0
///     Visa,   // 1
///     Wallet, // 2
/// }
/// ```
enum PaymentMethod {
  cash(0),
  visa(1),
  wallet(2);

  final int value;
  const PaymentMethod(this.value);

  static PaymentMethod fromValue(int? val) {
    switch (val) {
      case 1:
        return PaymentMethod.visa;
      case 2:
        return PaymentMethod.wallet;
      case 0:
      default:
        return PaymentMethod.cash;
    }
  }

  bool get isPaidOnline =>
      this == PaymentMethod.visa || this == PaymentMethod.wallet;

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return AppStrings.cashOnDeliveryLabel;
      case PaymentMethod.visa:
        return AppStrings.onlinePaymentLabel;
      case PaymentMethod.wallet:
        return AppStrings.payWithWalletLabel;
    }
  }

  /// Compact label suitable for badges and summary rows.
  String get shortLabel {
    switch (this) {
      case PaymentMethod.cash:
        return AppStrings.cashOnDeliveryLabel;
      case PaymentMethod.visa:
        return 'دفع إلكتروني';
      case PaymentMethod.wallet:
        return AppStrings.payWithWalletLabel;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.visa:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
