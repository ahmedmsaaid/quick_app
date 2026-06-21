class CategoryDto {
  final int id;
  final String? name;
  final String? description;
  final String? photo;
  final int type;
  final String? createdOn;
  final int creatorId;

  CategoryDto({
    required this.id,
    this.name,
    this.description,
    this.photo,
    required this.type,
    this.createdOn,
    required this.creatorId,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      photo: json['photo']?.toString(),
      type: json['type'] is int ? json['type'] as int : int.tryParse(json['type']?.toString() ?? '0') ?? 0,
      createdOn: json['createdOn']?.toString(),
      creatorId: json['creatorId'] is int ? json['creatorId'] as int : int.tryParse(json['creatorId']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'photo': photo,
    'type': type,
    'createdOn': createdOn,
    'creatorId': creatorId,
  };
}

class MainCategoryDto {
  final int id;
  final String? name;
  final String? description;
  final String? photo;
  final int userRole;
  final String? createdOn;

  MainCategoryDto({
    required this.id,
    this.name,
    this.description,
    this.photo,
    required this.userRole,
    this.createdOn,
  });

  factory MainCategoryDto.fromJson(Map<String, dynamic> json) {
    return MainCategoryDto(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      photo: json['photo']?.toString(),
      userRole: json['userRole'] is int ? json['userRole'] as int : int.tryParse(json['userRole']?.toString() ?? '0') ?? 0,
      createdOn: json['createdOn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'photo': photo,
    'userRole': userRole,
    'createdOn': createdOn,
  };
}
