import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class CreateOrderProductRequest {
  final int productId;
  final double price;
  final int quantity;
  final String? productName;
  final String? photo;
  final double? totalPrice;

  CreateOrderProductRequest({
    required this.productId,
    required this.price,
    required this.quantity,
    this.productName,
    this.photo,
    this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'price': price,
        'quantity': quantity,
        'productName': productName,
        'photo': photo,
        'totalPrice': totalPrice ?? (price * quantity),
      };
}

class CreateOrderRequest {
  final String address;
  final double longitude;
  final double latitude;
  final int paymentMethod; // 0 for COD, 1 for Online
  final double totalPrice;
  final double deliveryFee;
  final double orderFee;
  final int type; // 0 for Restaurant, 1 for Market
  final int userId;
  final int? offerId;
  final int? userLocationId;
  final List<CreateOrderProductRequest>? products;

  CreateOrderRequest({
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.paymentMethod,
    required this.totalPrice,
    required this.deliveryFee,
    required this.orderFee,
    required this.type,
    required this.userId,
    this.offerId,
    this.userLocationId,
    this.products,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'paymentMethod': paymentMethod,
      'totalPrice': totalPrice,
      'deliveryFee': deliveryFee,
      'orderFee': orderFee,
      'type': type,
      'userId': userId,
    };
    if (offerId != null) {
      data['offerId'] = offerId;
    }
    if (userLocationId != null) {
      data['userLocationId'] = userLocationId;
    }
    if (products != null) {
      data['products'] = products!.map((p) => p.toJson()).toList();
    }
    return data;
  }
}

class OrderProductDto {
  final int productId;
  final String? productName;
  final String? photo;
  final double price;
  final int quantity;
  final double totalPrice;

  OrderProductDto({
    required this.productId,
    this.productName,
    this.photo,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderProductDto.fromJson(Map<String, dynamic> json) {
    return OrderProductDto(
      productId: json['productId'] is int ? json['productId'] as int : 0,
      productName: json['productName']?.toString(),
      photo: json['photo']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] is int ? json['quantity'] as int : 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderDto {
  final int id;
  final String? address;
  final double longitude;
  final double latitude;
  final int paymentMethod;
  final int status;
  final double totalPrice;
  final double deliveryFee;
  final double orderFee;
  final int type;
  final int? offerId;
  final int userId;
  final int creatorId; // Vendor ID
  final String? createdOn;
  final List<OrderProductDto> products;
  final UserDto? user;
  final UserDto? creator;
  final UserDto? updator;
  final int? updatorId;
  final String? rowVersion;
  final int? userLocationId;
  final LocationDto? userLocation;

  OrderDto({
    required this.id,
    this.address,
    required this.longitude,
    required this.latitude,
    required this.paymentMethod,
    required this.status,
    required this.totalPrice,
    required this.deliveryFee,
    required this.orderFee,
    required this.type,
    this.offerId,
    required this.userId,
    required this.creatorId,
    this.createdOn,
    required this.products,
    this.user,
    this.creator,
    this.updator,
    this.updatorId,
    this.rowVersion,
    this.userLocationId,
    this.userLocation,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    var productsList = json['products'] as List?;
    List<OrderProductDto> products = productsList != null
        ? productsList.map((p) => OrderProductDto.fromJson(p as Map<String, dynamic>)).toList()
        : [];

    return OrderDto(
      id: json['id'] is int ? json['id'] as int : 0,
      address: json['address']?.toString(),
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] is int ? json['paymentMethod'] as int : 0,
      status: json['status'] is int ? json['status'] as int : 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      orderFee: (json['orderFee'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] is int ? json['type'] as int : 0,
      offerId: json['offerId'] as int?,
      userId: json['userId'] is int ? json['userId'] as int : 0,
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : 0,
      createdOn: json['createdOn']?.toString(),
      products: products,
      user: json['user'] != null ? UserDto.fromJson(json['user'] as Map<String, dynamic>) : null,
      creator: json['creator'] != null ? UserDto.fromJson(json['creator'] as Map<String, dynamic>) : null,
      updator: json['updator'] != null ? UserDto.fromJson(json['updator'] as Map<String, dynamic>) : null,
      updatorId: json['updatorId'] as int?,
      rowVersion: json['rowVersion']?.toString(),
      userLocationId: json['userLocationId'] as int?,
      userLocation: json['userLocation'] != null
          ? LocationDto.fromJson(json['userLocation'] as Map<String, dynamic>)
          : (json['userLocacion'] != null
              ? LocationDto.fromJson(json['userLocacion'] as Map<String, dynamic>)
              : null),
    );
  }
}
