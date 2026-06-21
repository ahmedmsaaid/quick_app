import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class CreateProductRatingRequest {
  final int productId;
  final int value;
  final String note;
  final dynamic creator;
  final int creatorId;

  CreateProductRatingRequest({
    required this.productId,
    required this.value,
    required this.note,
    this.creator,
    this.creatorId = 0,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'value': value,
        'note': note,
        'creator': creator,
        'creatorId': creatorId,
      };
}

class CreateRatingRequest {
  final int userId;
  final int value;
  final String note;
  final dynamic creator;
  final int creatorId;

  CreateRatingRequest({
    required this.userId,
    required this.value,
    required this.note,
    this.creator,
    this.creatorId = 0,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'value': value,
        'note': note,
        'creator': creator,
        'creatorId': creatorId,
      };
}

class ProductRatingDto {
  final int id;
  final String? note;
  final int value;
  final int productId;
  final UserDto? creator;
  final int creatorId;

  ProductRatingDto({
    required this.id,
    this.note,
    required this.value,
    required this.productId,
    this.creator,
    required this.creatorId,
  });

  factory ProductRatingDto.fromJson(Map<String, dynamic> json) {
    return ProductRatingDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      note: json['note']?.toString(),
      value: json['value'] is int ? json['value'] as int : int.tryParse(json['value']?.toString() ?? '0') ?? 0,
      productId: json['productId'] is int ? json['productId'] as int : int.tryParse(json['productId']?.toString() ?? '0') ?? 0,
      creator: json['creator'] != null ? UserDto.fromJson(json['creator'] as Map<String, dynamic>) : null,
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : int.tryParse(json['creatorId']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'note': note,
        'value': value,
        'productId': productId,
        'creator': creator?.toJson(),
        'creatorId': creatorId,
      };
}

class RatingDto {
  final int id;
  final String? note;
  final int value;
  final int userId;
  final UserDto? creator;
  final int creatorId;

  RatingDto({
    required this.id,
    this.note,
    required this.value,
    required this.userId,
    this.creator,
    required this.creatorId,
  });

  factory RatingDto.fromJson(Map<String, dynamic> json) {
    return RatingDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      note: json['note']?.toString(),
      value: json['value'] is int ? json['value'] as int : int.tryParse(json['value']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      creator: json['creator'] != null ? UserDto.fromJson(json['creator'] as Map<String, dynamic>) : null,
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : int.tryParse(json['creatorId']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'note': note,
        'value': value,
        'userId': userId,
        'creator': creator?.toJson(),
        'creatorId': creatorId,
      };
}
