class ProductDetailDto {
  final int id;
  final String? name;
  final String? photo;
  final String? description;
  final double price;
  final double rating;
  final bool isFavorite;
  final bool isAvailable;
  final bool hasDiscount;
  final double discountPercentage;
  final int categoryId;
  final String createdOn;
  final String? updatedOn;
  final int type; // 0 for Restaurant, 1 for Market
  final int? creatorId;

  ProductDetailDto({
    required this.id,
    this.name,
    this.photo,
    this.description,
    required this.price,
    required this.rating,
    required this.isFavorite,
    required this.isAvailable,
    required this.hasDiscount,
    required this.discountPercentage,
    required this.categoryId,
    required this.createdOn,
    this.updatedOn,
    required this.type,
    this.creatorId,
  });

  factory ProductDetailDto.fromJson(Map<String, dynamic> json) {
    return ProductDetailDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      photo: json['photo']?.toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      hasDiscount: json['hasDiscount'] as bool? ?? false,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['categoryId'] is int ? json['categoryId'] as int : 0,
      createdOn: json['createdOn']?.toString() ?? '',
      updatedOn: json['updatedOn']?.toString(),
      type: json['type'] is int ? json['type'] as int : 0,
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : int.tryParse(json['creatorId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photo': photo,
    'description': description,
    'price': price,
    'rating': rating,
    'isFavorite': isFavorite,
    'isAvailable': isAvailable,
    'hasDiscount': hasDiscount,
    'discountPercentage': discountPercentage,
    'categoryId': categoryId,
    'createdOn': createdOn,
    'updatedOn': updatedOn,
    'type': type,
    'creatorId': creatorId,
  };
}
