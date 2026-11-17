/// Response of `GET dashboard/delivery` and `GET wallets/delivery/summary`.
class DeliveryDashboardModel {
  final int deliveryId;
  final String? deliveryName;
  final int ordersCount;
  final int deliveredOrdersCount;
  final double totalCashToRemit;
  final double cashOrdersTotal;
  final double totalEarnings;
  final double quickCommission;
  final double settledAmount;
  final double duePayout;
  final double currentWalletBalance;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? filterType;

  /// إجمالي ثمن التوصيل + العمولة فقط
  double get deliveryAndCommissionTotal => totalEarnings + quickCommission;

  const DeliveryDashboardModel({
    required this.deliveryId,
    this.deliveryName,
    this.ordersCount = 0,
    required this.deliveredOrdersCount,
    this.totalCashToRemit = 0.0,
    this.cashOrdersTotal = 0.0,
    required this.totalEarnings,
    required this.quickCommission,
    required this.settledAmount,
    required this.duePayout,
    required this.currentWalletBalance,
    this.fromDate,
    this.toDate,
    this.filterType,
  });

  factory DeliveryDashboardModel.fromJson(Map<String, dynamic> json) {
    final parsedOrdersCount =
        (json['ordersCount'] as num?)?.toInt() ??
        (json['deliveredOrdersCount'] as num?)?.toInt() ??
        0;
    return DeliveryDashboardModel(
      deliveryId: (json['deliveryId'] as num?)?.toInt() ?? 0,
      deliveryName: json['deliveryName']?.toString(),
      ordersCount: parsedOrdersCount,
      deliveredOrdersCount:
          (json['deliveredOrdersCount'] as num?)?.toInt() ?? parsedOrdersCount,
      totalCashToRemit: (json['totalCashToRemit'] as num?)?.toDouble() ?? 0.0,
      cashOrdersTotal: (json['cashOrdersTotal'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      quickCommission: (json['quickCommission'] as num?)?.toDouble() ?? 0.0,
      settledAmount: (json['settledAmount'] as num?)?.toDouble() ?? 0.0,
      duePayout: (json['duePayout'] as num?)?.toDouble() ?? 0.0,
      currentWalletBalance:
          (json['currentWalletBalance'] as num?)?.toDouble() ?? 0.0,
      fromDate: json['fromDate'] != null
          ? DateTime.tryParse(json['fromDate'].toString())
          : null,
      toDate: json['toDate'] != null
          ? DateTime.tryParse(json['toDate'].toString())
          : null,
      filterType: (json['filterType'] as num?)?.toInt(),
    );
  }
}
