import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class ProductDto {
  final int id;
  final String? name;
  final String? photo;
  final String? description;
  final double price;
  final int categoryId;
  final int creatorId;
  final int quantity;

  ProductDto({
    required this.id,
    this.name,
    this.photo,
    this.description,
    required this.price,
    required this.categoryId,
    required this.creatorId,
    this.quantity = 1,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      photo: json['photo']?.toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] is int ? json['categoryId'] as int : 0,
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : 0,
      quantity: json['quantity'] is int ? json['quantity'] as int : (int.tryParse(json['quantity']?.toString() ?? '1') ?? 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photo': photo,
    'description': description,
    'price': price,
    'categoryId': categoryId,
    'creatorId': creatorId,
    'quantity': quantity,
  };
}

class OfferDto {
  final int id;
  final String? name;
  final double price;
  final String? featuredPhoto;
  final List<String>? otherPhotos;
  final String? description;
  final int type; // 0 for Restaurant, 1 for Market
  final int offerType; // 0 for Non-editable, 1 for Editable
  final bool active;
  final bool approved;
  final int numberOfClicks;
  final int numberOfWatches;
  final int numberOfBooking;
  final int numberOfAsks;
  final String createdOn;
  final int creatorId;
  final UserDto? creator;
  final List<ProductDto>? products;

  OfferDto({
    required this.id,
    this.name,
    required this.price,
    this.featuredPhoto,
    this.otherPhotos,
    this.description,
    required this.type,
    this.offerType = 0,
    required this.active,
    required this.approved,
    required this.numberOfClicks,
    required this.numberOfWatches,
    required this.numberOfBooking,
    required this.numberOfAsks,
    required this.createdOn,
    required this.creatorId,
    this.creator,
    this.products,
  });

  factory OfferDto.fromJson(Map<String, dynamic> json) {
    return OfferDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      featuredPhoto: json['featuredPhoto']?.toString(),
      otherPhotos: json['otherPhotos'] is List
          ? (json['otherPhotos'] as List).map((e) => e.toString()).toList()
          : null,
      description: json['description']?.toString(),
      type: json['type'] is int ? json['type'] as int : 0,
      offerType: json['offerType'] is int ? json['offerType'] as int : (int.tryParse(json['offerType']?.toString() ?? '0') ?? 0),
      active: json['active'] as bool? ?? false,
      approved: json['approved'] as bool? ?? false,
      numberOfClicks: json['numberOfClicks'] is int ? json['numberOfClicks'] as int : 0,
      numberOfWatches: json['numberOfWatches'] is int ? json['numberOfWatches'] as int : 0,
      numberOfBooking: json['numberOfBooking'] is int ? json['numberOfBooking'] as int : 0,
      numberOfAsks: json['numberOfAsks'] is int ? json['numberOfAsks'] as int : 0,
      createdOn: json['createdOn']?.toString() ?? '',
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : 0,
      creator: json['creator'] != null ? UserDto.fromJson(json['creator'] as Map<String, dynamic>) : null,
      products: json['products'] is List
          ? (json['products'] as List).map((e) => ProductDto.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'featuredPhoto': featuredPhoto,
    'otherPhotos': otherPhotos,
    'description': description,
    'type': type,
    'offerType': offerType,
    'active': active,
    'approved': approved,
    'numberOfClicks': numberOfClicks,
    'numberOfWatches': numberOfWatches,
    'numberOfBooking': numberOfBooking,
    'numberOfAsks': numberOfAsks,
    'createdOn': createdOn,
    'creatorId': creatorId,
    'creator': creator?.toJson(),
    'products': products?.map((e) => e.toJson()).toList(),
  };
}
