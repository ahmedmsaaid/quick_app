class InvitationCodeDto {
  final int id;
  final String code;
  final int userId;
  final int usedCount;
  final String? createdOn;

  const InvitationCodeDto({
    required this.id,
    required this.code,
    required this.userId,
    required this.usedCount,
    this.createdOn,
  });

  factory InvitationCodeDto.fromJson(Map<String, dynamic> json) {
    return InvitationCodeDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      usedCount: json['usedCount'] is int
          ? json['usedCount'] as int
          : int.tryParse(json['usedCount']?.toString() ?? '0') ?? 0,
      createdOn: json['createdOn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'userId': userId,
    'usedCount': usedCount,
    'createdOn': createdOn,
  };
}

class DiscountCodeDto {
  final int id;
  final String name;
  final String? description;
  final double percentage;
  final int type;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int? creatorId;

  const DiscountCodeDto({
    required this.id,
    required this.name,
    this.description,
    required this.percentage,
    required this.type,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.creatorId,
  });

  factory DiscountCodeDto.fromJson(Map<String, dynamic> json) {
    return DiscountCodeDto(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] is int
          ? json['type'] as int
          : int.tryParse(json['type']?.toString() ?? '0') ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      isActive: json['isActive'] == true,
      creatorId: json['creatorId'] is int
          ? json['creatorId'] as int
          : int.tryParse(json['creatorId']?.toString() ?? ''),
    );
  }

  /// `type == 1` indicates Free Delivery promo code; `type == 0` indicates percentage discount.
  bool get isFreeDelivery => type == 1;

  bool get isCurrentlyValid {
    if (!isActive) return false;
    if (!isFreeDelivery && percentage <= 0) return false;
    final now = DateTime.now().toUtc();
    if (startDate != null && endDate != null) {
      final startUtc = startDate!.toUtc();
      final endUtc = endDate!.toUtc();
      if (now.isAfter(startUtc) && now.isAfter(endUtc)) {
        return false;
      }
    } else if (endDate != null) {
      if (now.isAfter(endDate!.toUtc())) return false;
    }
    return true;
  }
}

