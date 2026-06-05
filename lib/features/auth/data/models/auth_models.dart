// lib/features/auth/data/models/auth_models.dart

class LocationModel {
  final double longitude;
  final double latitude;

  LocationModel({required this.longitude, required this.latitude});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    longitude: (json['longitude'] as num).toDouble(),
    latitude: (json['latitude'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'longitude': longitude,
    'latitude': latitude,
  };
}

class TokenDto {
  final String? accessToken;
  final String? refreshToken;
  final double? expiredIn;

  TokenDto({this.accessToken, this.refreshToken, this.expiredIn});

  factory TokenDto.fromJson(Map<String, dynamic> json) => TokenDto(
    accessToken: json['accessToken'] as String?,
    refreshToken: json['refreshToken'] as String?,
    expiredIn: (json['expiredIn'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiredIn': expiredIn,
  };
}

class UserDto {
  final int id;
  final String? phone;
  final String? email;
  final String? photo;
  final String? avatar;
  final String? name;
  final String? address;
  final int role; // 0: Customer, 1: Driver/Captain, etc.
  final int status;
  final LocationModel? location;

  UserDto({
    required this.id,
    this.phone,
    this.email,
    this.photo,
    this.avatar,
    this.name,
    this.address,
    required this.role,
    required this.status,
    this.location,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // 1. Resolve the data object (handle nesting)
    final Map<String, dynamic> data = json.containsKey('result') && json['result'] is Map
        ? json['result'] as Map<String, dynamic>
        : (json.containsKey('user') ? json['user'] as Map<String, dynamic> : json);

    // 2. Resolve final user fields (handle double nesting result -> user)
    final Map<String, dynamic> userMap = data.containsKey('user') && data['user'] is Map
        ? data['user'] as Map<String, dynamic>
        : (data.containsKey('data') && data['data'] is Map ? data['data'] as Map<String, dynamic> : data);

    // 3. Robust role parsing
    int parsedRole = 0;
    final dynamic rawRole = userMap['role'];
    if (rawRole is int) {
      parsedRole = rawRole;
    } else if (rawRole != null) {
      final roleStr = rawRole.toString().toLowerCase();
      if (roleStr == 'captain' || roleStr == 'driver' || roleStr == '1') {
        parsedRole = 1;
      } else if (roleStr == 'customer' || roleStr == 'user' || roleStr == '0') {
        parsedRole = 0;
      } else {
        parsedRole = int.tryParse(roleStr) ?? 0;
      }
    }

    return UserDto(
      id: userMap['id'] is int ? userMap['id'] as int : int.tryParse(userMap['id']?.toString() ?? '0') ?? 0,
      phone: (userMap['phone'] ?? userMap['phoneNumber'] ?? userMap['identifier'])?.toString(),
      email: userMap['email']?.toString(),
      photo: (userMap['photo'] ?? userMap['avatar'] ?? userMap['profilePicture'] ?? userMap['image'])?.toString(),
      avatar: (userMap['avatar'] ?? userMap['photo'])?.toString(),
      name: (userMap['name'] ?? userMap['fullName'] ?? userMap['userName'] ?? userMap['username'])?.toString(),
      address: userMap['address']?.toString(),
      role: parsedRole,
      status: userMap['status'] is int ? userMap['status'] as int : int.tryParse(userMap['status']?.toString() ?? '0') ?? 0,
      location: userMap['location'] == null
          ? null
          : LocationModel.fromJson(userMap['location'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'email': email,
    'photo': photo,
    'avatar': avatar,
    'name': name,
    'address': address,
    'role': role,
    'status': status,
    'location': location?.toJson(),
  };
}

class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String? message;
  final T? result;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.message,
    this.result,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) => ApiResponse(
    success: json['success'] as bool? ?? false,
    statusCode: json['statusCode'] as int? ?? 0,
    message: json['message'] as String?,
    result: json['result'] == null ? null : fromJsonT(json['result']),
  );
}

class SendOTPResult {
  final double expiredIn;

  SendOTPResult({required this.expiredIn});

  factory SendOTPResult.fromJson(Map<String, dynamic> json) => SendOTPResult(
    expiredIn: (json['expiredIn'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'expiredIn': expiredIn,
  };
}
